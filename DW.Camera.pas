unit DW.Camera;

(*

  DelphiWorlds cross-platform Camera project
  ------------------------------------------

  A (potentially) cross-platform Camera, aimed at supporting newer APIs

*)

{$I DW.GlobalDefines.inc}

interface

uses
  // RTL
  System.Classes, System.Types,
  // FMX
  FMX.Controls, FMX.Media, FMX.Graphics;

type
  TFaceDetectMode = (None, Simple, Full);

  TFaceDetectModes = set of TFaceDetectMode;

  TFace = record
    Bounds: TRectF;
    LeftEyePosition: TPointF;
    MouthPosition: TPointF;
    RightEyePosition: TPointF;
    Score: Integer;
  end;

  TFacesArray = array of TFace;

  TDetectedFacesEvent = procedure(Sender: TObject; const Image: TBitmap; const Faces: TFacesArray) of object;

  TCustomPlatformCamera = class(TObject)
  private
    FCameraPosition: TDevicePosition;
    FFaceDetectMode: TFaceDetectMode;
    function GetActive: Boolean;
    function GetCameraPosition: TDevicePosition;
    procedure ResetCamera;
    procedure SetActive(const Value: Boolean);
    procedure SetCameraPosition(const Value: TDevicePosition);
  protected
    FAvailableFaceDetectModes: TFaceDetectModes;
    FIsActive: Boolean;
    FIsCapturing: Boolean;
    FIsFaceDetectActive: Boolean;
    FOnDetectedFaces: TDetectedFacesEvent;
    FOnStatusChange: TNotifyEvent;
    procedure CloseCamera; virtual;
    procedure DoDetectedFaces(const Image: TBitmap; const Faces: TFacesArray);
    procedure DoStatusChange;
    function GetPreviewControl: TControl; virtual;
    procedure InternalSetActive(const AValue: Boolean);
    procedure OpenCamera; virtual;
    procedure SetFaceDetectMode(const Value: TFaceDetectMode); virtual;
    procedure StartCapture; virtual;
    procedure StopCapture; virtual;
    property Active: Boolean read GetActive write SetActive;
    property CameraPosition: TDevicePosition read GetCameraPosition write SetCameraPosition;
    property FaceDetectMode: TFaceDetectMode read FFaceDetectMode write SetFaceDetectMode;
  public
    property PreviewControl: TControl read GetPreviewControl;
  end;

  TCamera = class(TObject)
  private
    FPlatformCamera: TCustomPlatformCamera;
    function GetCameraPosition: TDevicePosition;
    procedure SetCameraPosition(const Value: TDevicePosition);
    function GetActive: Boolean;
    procedure SetActive(const Value: Boolean);
    function GetAvailableFaceDetectModes: TFaceDetectModes;
    function GetOnStatusChange: TNotifyEvent;
    procedure SetOnStatusChange(const Value: TNotifyEvent);
    function GetPreviewControl: TControl;
    function GetFaceDetectMode: TFaceDetectMode;
    procedure SetFaceDetectMode(const Value: TFaceDetectMode);
    function GetOnDetectedFaces: TDetectedFacesEvent;
    procedure SetOnDetectedFaces(const Value: TDetectedFacesEvent);
  public
    constructor Create;
    destructor Destroy; override;
    property Active: Boolean read GetActive write SetActive;
    property AvailableFaceDetectModes: TFaceDetectModes read GetAvailableFaceDetectModes;
    property CameraPosition: TDevicePosition read GetCameraPosition write SetCameraPosition;
    property FaceDetectMode: TFaceDetectMode read GetFaceDetectMode write SetFaceDetectMode;
    property PreviewControl: TControl read GetPreviewControl;
    property OnDetectedFaces: TDetectedFacesEvent read GetOnDetectedFaces write SetOnDetectedFaces;
    property OnStatusChange: TNotifyEvent read GetOnStatusChange write SetOnStatusChange;
  end;

implementation

uses
  // FMX
  FMX.Types,
  // DW
{$IFDEF ANDROID}
  DW.Camera.Android;
{$ENDIF}

{ TCamera }

constructor TCamera.Create;
begin
  inherited;
  FPlatformCamera := TPlatformCamera.Create;
end;

destructor TCamera.Destroy;
begin
  FPlatformCamera.Free;
  inherited;
end;

function TCamera.GetActive: Boolean;
begin
  Result := FPlatformCamera.Active;
end;

function TCamera.GetAvailableFaceDetectModes: TFaceDetectModes;
begin
  Result := FPlatformCamera.FAvailableFaceDetectModes;
end;

function TCamera.GetCameraPosition: TDevicePosition;
begin
  Result := FPlatformCamera.CameraPosition;
end;

function TCamera.GetFaceDetectMode: TFaceDetectMode;
begin
  Result := FPlatformCamera.FaceDetectMode;
end;

function TCamera.GetOnDetectedFaces: TDetectedFacesEvent;
begin
  Result := FPlatformCamera.FOnDetectedFaces;
end;

function TCamera.GetOnStatusChange: TNotifyEvent;
begin
  Result := FPlatformCamera.FOnStatusChange
end;

function TCamera.GetPreviewControl: TControl;
begin
  Result := FPlatformCamera.PreviewControl;
end;

procedure TCamera.SetActive(const Value: Boolean);
begin
  FPlatformCamera.Active := Value;
end;

procedure TCamera.SetCameraPosition(const Value: TDevicePosition);
begin
  FPlatformCamera.CameraPosition := Value;
end;

procedure TCamera.SetFaceDetectMode(const Value: TFaceDetectMode);
begin
  FPlatformCamera.FaceDetectMode := Value;
end;

procedure TCamera.SetOnDetectedFaces(const Value: TDetectedFacesEvent);
begin
  FPlatformCamera.FOnDetectedFaces := Value;
end;

procedure TCamera.SetOnStatusChange(const Value: TNotifyEvent);
begin
  FPlatformCamera.FOnStatusChange := Value;
end;

{ TCustomPlatformCamera }

procedure TCustomPlatformCamera.InternalSetActive(const AValue: Boolean);
begin
  FIsActive := AValue;
  TThread.Queue(nil,
    procedure
    begin
      DoStatusChange;
    end
  );
end;

procedure TCustomPlatformCamera.CloseCamera;
begin
  //
end;

procedure TCustomPlatformCamera.DoDetectedFaces(const Image: TBitmap; const Faces: TFacesArray);
begin
  if Assigned(FOnDetectedFaces) then
    FOnDetectedFaces(Self, Image, Faces);
end;

procedure TCustomPlatformCamera.DoStatusChange;
begin
  Log.d('+TCustomPlatformCamera.DoStatusChange');
  if Assigned(FOnStatusChange) then
    FOnStatusChange(Self);
  Log.d('-TCustomPlatformCamera.DoStatusChange');
end;

function TCustomPlatformCamera.GetActive: Boolean;
begin
  Result := FIsActive;
end;

function TCustomPlatformCamera.GetCameraPosition: TDevicePosition;
begin
  Result := FCameraPosition;
end;

function TCustomPlatformCamera.GetPreviewControl: TControl;
begin
  Result := nil;
end;

procedure TCustomPlatformCamera.OpenCamera;
begin
  //
end;

procedure TCustomPlatformCamera.ResetCamera;
begin
  if not FIsActive then
    Exit; // <======
  CloseCamera;
  OpenCamera;
end;

procedure TCustomPlatformCamera.SetActive(const Value: Boolean);
begin
  if FIsActive = Value then
    Exit; // <======
  if Value then
    OpenCamera
  else
    CloseCamera;
end;

procedure TCustomPlatformCamera.SetCameraPosition(const Value: TDevicePosition);
begin
  //!!!! Some devices may not support all positions
  if Value = FCameraPosition then
    Exit; // <======
  FCameraPosition := Value;
  ResetCamera;
end;

procedure TCustomPlatformCamera.SetFaceDetectMode(const Value: TFaceDetectMode);
begin
  FFaceDetectMode := Value;
end;

procedure TCustomPlatformCamera.StartCapture;
begin
  //
end;

procedure TCustomPlatformCamera.StopCapture;
begin
  //
end;

end.
