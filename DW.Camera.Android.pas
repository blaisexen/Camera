unit DW.Camera.Android;

(*

  DelphiWorlds cross-platform Camera project
  ------------------------------------------

  A (potentially) cross-platform Camera, aimed at supporting newer APIs

  This is the Android implementation, which  supports only API 21 (Lollipop, Android 5) or greater, because it uses the Camera2 API.

  Some parts of the code inspired from the following links:
    http://coderzpassion.com/android-working-camera2-api/
    http://werner-dittmann.blogspot.com.au/2016/03/using-androids-imagereader-with-camera2.html

 TODOs:
   A whole bunch of stuff, including controlling the flash, torch, focus modes, blah blah etc

*)

{$I DW.GlobalDefines.inc}

interface

uses
  // Android
  Androidapi.JNIBridge, Androidapi.JNI.Util, Androidapi.Gles, Androidapi.JNI.GraphicsContentViewText, Androidapi.JNI.Os, Androidapi.JNI.Media,
  // FMX
  FMX.Controls, FMX.Graphics,
  // DW
  DW.Camera, DW.Androidapi.JNI.Os, DW.Androidapi.JNI.Camera2, DW.Androidapi.JNI.CameraHelpers, DW.Androidapi.JNI.TextureView;

type
  TPlatformCamera = class;

  TCameraCaptureSession = class(TObject)
  private
    FCaptureSessionCaptureCallback: JDWCameraCaptureSessionCaptureCallback;
    FCaptureSessionCaptureCallbackListener: JDWCameraCaptureSessionCaptureCallbackListener;
    FCaptureSessionStateCallback: JDWCameraCaptureSessionStateCallback;
    FCaptureSessionStateCallbackListener: JDWCameraCaptureSessionStateCallbackListener;
    FIsCapturing: Boolean;
    FImageReader: JImageReader;
    FImageAvailableListener: JImageReader_OnImageAvailableListener;
    FHandler: JHandler;
    FPlatformCamera: TPlatformCamera;
    FPreviewControl: TControl;
    FPreviewSurface: JSurface;
    FSession: JCameraCaptureSession;
    FTextureView: JTextureView;
    FThread: JHandlerThread;
    procedure CaptureCompleted(session: JCameraCaptureSession; request: JCaptureRequest; result: JTotalCaptureResult); virtual;
    procedure CaptureProgressed(session: JCameraCaptureSession; request: JCaptureRequest; partialResult: JCaptureResult); virtual;
    procedure CaptureSessionConfigured(session: JCameraCaptureSession); virtual;
    procedure CaptureSessionConfigureFailed(session: JCameraCaptureSession); virtual;
    procedure CheckFaces(const ACaptureResult: JTotalCaptureResult);
    procedure CreatePreviewSurface;
    procedure CreateReader;
    procedure StartThread;
    procedure StopThread;
  protected
    procedure TakePicture;
    procedure ExtractImage(reader: JImageReader);
    procedure ImageAvailable(reader: JImageReader);
    procedure StartSession;
    procedure StopSession;
    property IsCapturing: Boolean read FIsCapturing;
    property PreviewControl: TControl read FPreviewControl;
    property Handler: JHandler read FHandler;
    property PlatformCamera: TPlatformCamera read FPlatformCamera;
    property Session: JCameraCaptureSession read FSession;
  public
    constructor Create(const APlatformCamera: TPlatformCamera); virtual;
    destructor Destroy; override;
  end;

  TPlatformCamera = class(TCustomPlatformCamera)
  private
    FCameraDevice: JCameraDevice;
    FCameraManager: JCameraManager;
    FDetectionDateTime: TDateTime;
    FFaces: TFacesArray;
    FFacesDetected: Boolean;
    FDeviceStateCallback: JDWCameraDeviceStateCallback;
    FDeviceStateCallbackListener: JDWCameraDeviceStateCallbackListener;
    FHandler: JHandler;
    FCaptureSession: TCameraCaptureSession;
    FViewSize: Jutil_Size;
  protected
    procedure CameraDisconnected(camera: JCameraDevice);
    procedure CameraError(camera: JCameraDevice; error: Integer);
    procedure CameraOpened(camera: JCameraDevice);
    procedure CapturedStillImage(const ABitmap: TBitmap);
    procedure DetectedFaces(const AFaces: TJavaObjectArray<JFace>);
    function GetHighestFaceDetectMode: TFaceDetectMode;
    function GetPreviewControl: TControl; override;
    procedure StillCaptureFailed;
    property CameraDevice: JCameraDevice read FCameraDevice;
    property ViewSize: Jutil_Size read FViewSize;
  protected
    procedure CloseCamera; override;
    procedure OpenCamera; override;
    procedure StartCapture; override;
    procedure StopCapture; override;
  public
    constructor Create;
    destructor Destroy; override;
  end;

implementation

uses
  // RTL
  System.SysUtils, System.Types, System.Classes, System.DateUtils, System.Math,
  // Android
  Androidapi.Helpers, Androidapi.JNI, Androidapi.JNI.App, Androidapi.JNI.JavaTypes,
  // FMX
  FMX.Media, FMX.Types,
  // DW
  DW.CameraPreview, DW.CameraPreview.Android, DW.Helpers.Android;

type
  TDWCameraDeviceStateCallbackListener = class(TJavaLocal, JDWCameraDeviceStateCallbackListener)
  private
    FPlatformCamera: TPlatformCamera;
  public
    { JDWCameraDeviceStateCallbackListener }
    procedure Disconnected(camera: JCameraDevice); cdecl;
    procedure Error(camera: JCameraDevice; error: Integer); cdecl;
    procedure Opened(camera: JCameraDevice); cdecl;
  public
    constructor Create(const APlatformCamera: TPlatformCamera);
  end;

  TDWCameraCaptureSessionCaptureCallbackListener = class(TJavaLocal, JDWCameraCaptureSessionCaptureCallbackListener)
  private
    FCaptureSession: TCameraCaptureSession;
  public
    { JDWCameraCaptureSessionCaptureCallbackListener }
    procedure CaptureProgressed(session: JCameraCaptureSession; request: JCaptureRequest; partialResult: JCaptureResult); cdecl;
    procedure CaptureCompleted(session: JCameraCaptureSession; request: JCaptureRequest; result: JTotalCaptureResult); cdecl;
  public
    constructor Create(const ACaptureSession: TCameraCaptureSession);
  end;

  TDWCameraCaptureSessionStateCallbackListener = class(TJavaLocal, JDWCameraCaptureSessionStateCallbackListener)
  private
    FCaptureSession: TCameraCaptureSession;
  public
    { JDWCameraCaptureSessionStateCallbackListener }
    procedure ConfigureFailed(session: JCameraCaptureSession); cdecl;
    procedure Configured(session: JCameraCaptureSession); cdecl;
  public
    constructor Create(const ACaptureSession: TCameraCaptureSession);
  end;

  TImageAvailableListener = class(TJavaLocal, JImageReader_OnImageAvailableListener)
  private
    FCaptureSession: TCameraCaptureSession;
  public
    { JImageReader_OnImageAvailableListener }
    procedure onImageAvailable(reader: JImageReader); cdecl;
  public
    constructor Create(const ACaptureSession: TCameraCaptureSession);
  end;

function GetSizeArea(const ASize: Jutil_Size): Integer;
begin
  Result := ASize.getHeight * ASize.getWidth;
end;

{ TDWCameraDeviceStateCallbackListener }

constructor TDWCameraDeviceStateCallbackListener.Create(const APlatformCamera: TPlatformCamera);
begin
  inherited Create;
  FPlatformCamera := APlatformCamera;
end;

procedure TDWCameraDeviceStateCallbackListener.Disconnected(camera: JCameraDevice);
begin
  FPlatformCamera.CameraDisconnected(camera);
end;

procedure TDWCameraDeviceStateCallbackListener.Error(camera: JCameraDevice; error: Integer);
begin
  FPlatformCamera.CameraError(camera, error);
end;

procedure TDWCameraDeviceStateCallbackListener.Opened(camera: JCameraDevice);
begin
  FPlatformCamera.CameraOpened(camera);
end;

{ TDWCameraCaptureSessionCaptureCallbackListener }

constructor TDWCameraCaptureSessionCaptureCallbackListener.Create(const ACaptureSession: TCameraCaptureSession);
begin
  inherited Create;
  FCaptureSession := ACaptureSession;
end;

procedure TDWCameraCaptureSessionCaptureCallbackListener.CaptureCompleted(session: JCameraCaptureSession; request: JCaptureRequest;
  result: JTotalCaptureResult);
begin
  FCaptureSession.CaptureCompleted(session, request, result);
end;

procedure TDWCameraCaptureSessionCaptureCallbackListener.CaptureProgressed(session: JCameraCaptureSession; request: JCaptureRequest;
  partialResult: JCaptureResult);
begin
  FCaptureSession.CaptureProgressed(session, request, partialResult);
end;

{ TDWCameraCaptureSessionStateCallbackListener }

constructor TDWCameraCaptureSessionStateCallbackListener.Create(const ACaptureSession: TCameraCaptureSession);
begin
  inherited Create;
  FCaptureSession := ACaptureSession;
end;

procedure TDWCameraCaptureSessionStateCallbackListener.Configured(session: JCameraCaptureSession);
begin
  FCaptureSession.CaptureSessionConfigured(session);
end;

procedure TDWCameraCaptureSessionStateCallbackListener.ConfigureFailed(session: JCameraCaptureSession);
begin
  FCaptureSession.CaptureSessionConfigureFailed(session);
end;

constructor TImageAvailableListener.Create(const ACaptureSession: TCameraCaptureSession);
begin
  inherited Create;
  FCaptureSession := ACaptureSession;
end;

procedure TImageAvailableListener.onImageAvailable(reader: JImageReader);
begin
  FCaptureSession.ImageAvailable(reader);
end;

{ TCameraCaptureSession }

constructor TCameraCaptureSession.Create(const APlatformCamera: TPlatformCamera);
begin
  inherited Create;
  FPlatformCamera := APlatformCamera;
  FCaptureSessionCaptureCallbackListener := TDWCameraCaptureSessionCaptureCallbackListener.Create(Self);
  FCaptureSessionCaptureCallback := TJDWCameraCaptureSessionCaptureCallback.JavaClass.init(FCaptureSessionCaptureCallbackListener);
  FCaptureSessionStateCallbackListener := TDWCameraCaptureSessionStateCallbackListener.Create(Self);
  FCaptureSessionStateCallback := TJDWCameraCaptureSessionStateCallback.JavaClass.init(FCaptureSessionStateCallbackListener);
  FPreviewControl := TCameraPreview.Create(nil);
  FTextureView := TCustomNativeCameraPreview(FPreviewControl).TextureView;
  StartThread;
end;

destructor TCameraCaptureSession.Destroy;
begin
  StopThread;
  inherited;
end;

procedure TCameraCaptureSession.StartThread;
begin
  FThread := TJHandlerThread.JavaClass.init(StringToJString('CameraPreview'));
  FThread.start;
  FHandler := TJHandler.JavaClass.init(FThread.getLooper);
end;

procedure TCameraCaptureSession.StopThread;
begin
  FThread.quitSafely;
  FThread.join;
  FThread := nil;
  FHandler := nil;
end;

procedure TCameraCaptureSession.CreatePreviewSurface;
var
  LSurfaceTexture: JSurfaceTexture;
begin
  FPreviewControl.Visible := True;
  FPreviewSurface := nil;
  LSurfaceTexture := FTextureView.getSurfaceTexture;
  LSurfaceTexture.setDefaultBufferSize(PlatformCamera.ViewSize.getWidth, PlatformCamera.ViewSize.getHeight);
  FPreviewSurface := TJSurface.JavaClass.init(LSurfaceTexture);
end;

procedure TCameraCaptureSession.CreateReader;
begin
  FImageAvailableListener := nil;
  FImageAvailableListener := TImageAvailableListener.Create(Self);
  FImageReader := nil;
  FImageReader := TJImageReader.JavaClass.newInstance(PlatformCamera.ViewSize.getWidth, PlatformCamera.ViewSize.getHeight,
    TJImageFormat.JavaClass.JPEG, 1);
  FImageReader.setOnImageAvailableListener(FImageAvailableListener, Handler);
end;

procedure TCameraCaptureSession.StartSession;
var
  LSurfaceTexture: JSurfaceTexture;
  LSurface: JSurface;
  LOutputs: JArrayList;
  LPreviewSize: TPoint;
begin
  if FPreviewControl.ParentControl = nil then
    Exit; // <======
  Log.d('+TCameraCaptureSession.StartSession');
  CreateReader;
  CreatePreviewSurface;
  LOutputs := TJArrayList.JavaClass.init(2);
  LOutputs.add(FPreviewSurface);
  LOutputs.add(FImageReader.getSurface);
  Log.d('FPlatformCamera.CameraDevice.createCaptureSession');
  FPlatformCamera.CameraDevice.createCaptureSession(TJList.Wrap(GetObjectID(LOutputs)), FCaptureSessionStateCallback, FHandler);
  Log.d('-TCameraCaptureSession.StartSession');
end;

procedure TCameraCaptureSession.StopSession;
begin
  if FSession <> nil then
  begin
    FSession.close;
    FSession := nil;
  end;
  FPreviewControl.Visible := False;
  FIsCapturing := False;
end;

procedure TCameraCaptureSession.TakePicture;
var
  LBuilder: JCaptureRequest_Builder;
begin
  LBuilder := FPlatformCamera.CameraDevice.createCaptureRequest(TJCameraDevice.JavaClass.TEMPLATE_STILL_CAPTURE);
  LBuilder.addTarget(FImageReader.getSurface);
  FSession.capture(LBuilder.build, nil, FHandler);
end;

procedure TCameraCaptureSession.ImageAvailable(reader: JImageReader);
begin
  Log.d('+TCameraCaptureSession.ImageAvailable');
  // if PlatformCamera.ImageRequested then
  ExtractImage(reader);
  Log.d('-TCameraCaptureSession.ImageAvailable');
end;

procedure TCameraCaptureSession.ExtractImage(reader: JImageReader);
var
  LImage: JImage;
  LBuffer: JByteBuffer;
  LBytes: TJavaArray<Byte>;
  LBitmap: TBitmap;
  LJBitmap: JBitmap;
begin
  // From: http://stackoverflow.com/questions/41775968/how-to-convert-android-media-image-to-bitmap-object
  Log.d('+TCameraCaptureSession.ExtractImage');
  // Attempting to retrieve the buffer after using acquireLatestImage does not work when maxImages = 1 when creating the reader
  LImage := reader.acquireNextImage;
  try
    LBuffer := LImage.getPlanes.Items[0].getBuffer;
    LBytes := TJavaArray<Byte>.Create(LBuffer.capacity);
    LBuffer.get(LBytes);
    LJBitmap := TJBitmapFactory.JavaClass.decodeByteArray(LBytes, 0, LBytes.Length);
    TThread.Synchronize(nil,
      procedure
      begin
        LBitmap := TBitmap.Create;
        try
          if JBitmapToBitmap(LJBitmap, LBitmap) then
            PlatformCamera.CapturedStillImage(LBitmap);
        finally
          LBitmap.Free;
        end;
      end
    );
  finally
    LImage.close;
  end;
  Log.d('-TCameraCaptureSession.ExtractImage');
end;

procedure TCameraCaptureSession.CheckFaces(const ACaptureResult: JTotalCaptureResult);
var
  LHelper: JDWCaptureResultHelper;
  LFaces: TJavaObjectArray<JFace>;
begin
  LHelper := TJDWCaptureResultHelper.JavaClass.init;
  LHelper.setCaptureResult(ACaptureResult);
  LFaces := LHelper.getFaces;
  if (LFaces <> nil) and (LFaces.Length > 0) then
    PlatformCamera.DetectedFaces(LFaces);
end;

procedure TCameraCaptureSession.CaptureCompleted(session: JCameraCaptureSession; request: JCaptureRequest; result: JTotalCaptureResult);
begin
  CheckFaces(result);
end;

procedure TCameraCaptureSession.CaptureProgressed(session: JCameraCaptureSession; request: JCaptureRequest; partialResult: JCaptureResult);
begin
  //
end;

procedure TCameraCaptureSession.CaptureSessionConfigured(session: JCameraCaptureSession);
var
  LBuilder: JCaptureRequest_Builder;
  LHelper: JDWCaptureRequestBuilderHelper;
begin
  FSession := session;
  LBuilder := FPlatformCamera.CameraDevice.createCaptureRequest(TJCameraDevice.JavaClass.TEMPLATE_PREVIEW);
  LBuilder.addTarget(FPreviewSurface);
  LHelper := TJDWCaptureRequestBuilderHelper.JavaClass.init;
  LHelper.setCaptureRequestBuilder(LBuilder);
  LHelper.setFaceDetectMode(Ord(FPlatformCamera.GetHighestFaceDetectMode));
  // This will need to be added to the helper class, if required
  // FPreviewBuilder.&set(TJCaptureRequest.JavaClass.CONTROL_MODE, JObject(TJCameraMetadata.JavaClass.CONTROL_MODE_AUTO));
  session.setRepeatingRequest(LBuilder.build, FCaptureSessionCaptureCallback, FHandler);
  FIsCapturing := True;
end;

procedure TCameraCaptureSession.CaptureSessionConfigureFailed(session: JCameraCaptureSession);
begin

end;

{ TPlatformCamera }

constructor TPlatformCamera.Create;
begin
  inherited;
  Log.d('+TPlatformCamera.Create');
  FCameraManager := TJCameraManager.Wrap(TAndroidHelper.Activity.getSystemService(TJContext.JavaClass.CAMERA_SERVICE));
  Log.d('FCameraManager created');
  FDeviceStateCallbackListener := TDWCameraDeviceStateCallbackListener.Create(Self);
  FDeviceStateCallback := TJDWCameraDeviceStateCallback.JavaClass.init(FDeviceStateCallbackListener);
  FCaptureSession := TCameraCaptureSession.Create(Self);
  FHandler := TJHandler.JavaClass.init(TJLooper.JavaClass.getMainLooper);
  Log.d('-TPlatformCamera.Create');
end;

destructor TPlatformCamera.Destroy;
begin
  FDeviceStateCallbackListener := nil;
  FDeviceStateCallback := nil;
  FCaptureSession.Free;
  FHandler := nil;
  inherited;
end;

procedure TPlatformCamera.DetectedFaces(const AFaces: TJavaObjectArray<JFace>);
var
  I: Integer;
  LFace: JFace;
  LPoint: JPoint;
  LRect: JRect;
begin
  if FFacesDetected or (MilliSecondsBetween(Now, FDetectionDateTime) < 1000) then
    Exit; // <======
  FFacesDetected := True;
  FDetectionDateTime := Now;
  Log.d('+TPlatformCamera.DetectedFaces');
  SetLength(FFaces, AFaces.Length);
  for I := 0 to AFaces.Length - 1 do
  begin
    LFace := AFaces.Items[I];
    LRect := LFace.getBounds;
    if LRect <> nil then
      FFaces[I].Bounds := TRectF.Create(LRect.left, LRect.top, LRect.right, LRect.bottom);
    LPoint := LFace.getLeftEyePosition;
    if LPoint <> nil then
      FFaces[I].LeftEyePosition := TPointF.Create(LPoint.x, LPoint.y);
    LPoint := LFace.getRightEyePosition;
    if LPoint <> nil then
      FFaces[I].RightEyePosition := TPointF.Create(LPoint.x, LPoint.y);
    LPoint := LFace.getMouthPosition;
    if LPoint <> nil then
      FFaces[I].MouthPosition := TPointF.Create(LPoint.x, LPoint.y);
  end;
  FCaptureSession.TakePicture;
  Log.d('-TPlatformCamera.DetectedFaces');
end;

procedure TPlatformCamera.StillCaptureFailed;
begin
  FFacesDetected := False;
end;

function TPlatformCamera.GetHighestFaceDetectMode: TFaceDetectMode;
var
  LMode: TFaceDetectMode;
begin
  Result := TFaceDetectMode.None;
  for LMode := High(TFaceDetectMode) downto Low(TFaceDetectMode) do
  begin
    // Set the highest available mode, or none if none selected
    if (LMode in FAvailableFaceDetectModes) and (FaceDetectMode >= LMode) then
    begin
      Log.d('Highest face detect mode of: %d', [Ord(LMode)]);
      Result := LMode;
      Break;
    end;
  end;
end;

function TPlatformCamera.GetPreviewControl: TControl;
begin
  Result := FCaptureSession.PreviewControl;
end;

procedure TPlatformCamera.OpenCamera;
var
  LCameraIDList: TJavaObjectArray<JString>;
  LItem: JString;
  LCameraID: JString;
  LLensFacing: Integer;
  LMap: JStreamConfigurationMap;
  LCharacteristics: JCameraCharacteristics;
  LHelper: JDWCameraCharacteristicsHelper;
  LSizes: TJavaObjectArray<Jutil_Size>;
  LFaceDetectModes: TJavaArray<Integer>;
  I: Integer;
begin
  Log.d('+TPlatformCamera.OpenCamera');
  LCameraIDList := FCameraManager.getCameraIdList;
  LCameraID := nil;
  LMap := nil;
  LHelper := TJDWCameraCharacteristicsHelper.JavaClass.init;
  for I := 0 to LCameraIDList.Length - 1 do
  begin
    LItem := LCameraIDList.Items[I];
	  LCharacteristics := FCameraManager.getCameraCharacteristics(LItem);
    LHelper.setCameraCharacteristics(LCharacteristics);
    LFaceDetectModes := LHelper.getFaceDetectModes;
    LLensFacing := LHelper.getLensFacing;
    case CameraPosition of
      TDevicePosition.Back:
      begin
        if LLensFacing = TJCameraMetadata.JavaClass.LENS_FACING_BACK then
          LCameraID := LItem;
      end;
      TDevicePosition.Front:
      begin
        if LLensFacing = TJCameraMetadata.JavaClass.LENS_FACING_FRONT then
          LCameraID := LItem;
      end;
    end;
    if LCameraID <> nil then
    begin
      LMap := LHelper.getMap;
      Break;
    end;
  end;
  if (LCameraID = nil) or (LMap = nil) then
    Exit; // <======
  Log.d('TPlatformCamera.OpenCamera obtained ID and map');
  FAvailableFaceDetectModes := [];
  if LFaceDetectModes <> nil then
  begin
    for I := 0 to LFaceDetectModes.Length - 1 do
      Include(FAvailableFaceDetectModes, TFaceDetectMode(LFaceDetectModes.Items[I]));
  end;
  FViewSize := nil;
  // May need to rethink this - largest preview size may not be appropriate, except for stills
  LSizes := LMap.getOutputSizes(TJImageFormat.JavaClass.JPEG);
  for I := 0 to LSizes.Length - 1 do
  begin
    if (FViewSize = nil) or (GetSizeArea(LSizes.Items[I]) > GetSizeArea(FViewSize)) then
      FViewSize := LSizes.Items[I];
  end;
  FCameraManager.openCamera(LCameraID, FDeviceStateCallback, FHandler);
  Log.d('-TPlatformCamera.OpenCamera');
end;

procedure TPlatformCamera.CloseCamera;
begin
  StopCapture;
  FCameraDevice.close;
  FCameraDevice := nil;
  FAvailableFaceDetectModes := [];
  SetFaceDetectMode(TFaceDetectMode.None);
  InternalSetActive(False);
end;

procedure TPlatformCamera.StartCapture;
begin
  if FCameraDevice = nil then
    Exit; // <======
  FCaptureSession.StartSession;
  FIsCapturing := FCaptureSession.IsCapturing;
end;

procedure TPlatformCamera.StopCapture;
begin
  FCaptureSession.StopSession;
  FIsCapturing := False;
end;

procedure TPlatformCamera.CameraDisconnected(camera: JCameraDevice);
begin
  Log.d('+TPlatformCamera.CameraDisconnected');
  //!!!!
  FCameraDevice := nil;
  FIsActive := False;
  FIsCapturing := False;
  Log.d('-TPlatformCamera.CameraDisconnected');
end;

procedure TPlatformCamera.CameraError(camera: JCameraDevice; error: Integer);
begin
  Log.d('+TPlatformCamera.CameraError - Error: %d', [error]);
//  FCameraDevice := nil;
//  FIsActive := False;
  Log.d('-TPlatformCamera.CameraError');
end;

procedure TPlatformCamera.CameraOpened(camera: JCameraDevice);
begin
  Log.d('+TPlatformCamera.CameraOpened');
  FCameraDevice := camera;
  InternalSetActive(True);
  StartCapture;
  Log.d('-TPlatformCamera.CameraOpened');
end;

procedure TPlatformCamera.CapturedStillImage(const ABitmap: TBitmap);
begin
  Log.d('+TPlatformCamera.CapturedStillImage');
  TThread.Synchronize(nil,
    procedure
    begin
      Log.d('TPlatformCamera.CapturedStillImage - DoDetectedFaces');
      DoDetectedFaces(ABitmap, FFaces);
    end
  );
  FFacesDetected := False;
  Log.d('-TPlatformCamera.CapturedStillImage');
end;

end.
