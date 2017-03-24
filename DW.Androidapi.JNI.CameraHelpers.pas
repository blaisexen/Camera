unit DW.Androidapi.JNI.CameraHelpers;

interface

uses
  Androidapi.JNIBridge, Androidapi.JNI.GraphicsContentViewText, Androidapi.JNI.JavaTypes, Androidapi.JNI.Os,
  DW.Androidapi.JNI.Camera2;

type
  JDWCameraCharacteristicsHelper = interface;//com.delphiworlds.firemonkey.DWCameraCharacteristicsHelper
  JDWCaptureRequestBuilderHelper = interface;//com.delphiworlds.firemonkey.DWCaptureRequestBuilderHelper
  JDWCaptureResultHelper = interface;//com.delphiworlds.firemonkey.DWCaptureResultHelper
  JDWCameraCaptureSessionStateCallback = interface;//com.delphiworlds.firemonkey.DWCameraCaptureSessionStateCallback
  JDWCameraCaptureSessionStateCallbackListener = interface;//com.delphiworlds.firemonkey.DWCameraCaptureSessionStateCallbackListener
  JDWCameraDeviceStateCallback = interface;//com.delphiworlds.firemonkey.DWCameraDeviceStateCallback
  JDWCameraDeviceStateCallbackListener = interface;//com.delphiworlds.firemonkey.DWCameraDeviceStateCallbackListener
  JDWCameraCaptureSessionCaptureCallback = interface;//com.delphiworlds.firemonkey.DWCameraCaptureSessionCaptureCallback
  JDWCameraCaptureSessionCaptureCallbackListener = interface;//com.delphiworlds.firemonkey.DWCameraCaptureSessionCaptureCallbackListener

  JDWCameraCharacteristicsHelperClass = interface(JObjectClass)
    ['{546D0D05-92AF-4D33-8AC5-0EC46022E85D}']
    {class} function init: JDWCameraCharacteristicsHelper; cdecl;
  end;

  [JavaSignature('com/delphiworlds/firemonkey/DWCameraCharacteristicsHelper')]
  JDWCameraCharacteristicsHelper = interface(JObject)
    ['{66872D0B-17E3-4AF1-8B27-1D1731A40DE9}']
    function getFaceDetectModes: TJavaArray<Integer>; cdecl;
    function getLensFacing: Integer; cdecl;
    function getMap: JStreamConfigurationMap; cdecl;
    procedure setCameraCharacteristics(P1: JCameraCharacteristics); cdecl;
  end;
  TJDWCameraCharacteristicsHelper = class(TJavaGenericImport<JDWCameraCharacteristicsHelperClass, JDWCameraCharacteristicsHelper>) end;

  JDWCaptureRequestBuilderHelperClass = interface(JObjectClass)
    ['{2A88D2A3-036C-4F46-88DF-297241184A70}']
    {class} function init: JDWCaptureRequestBuilderHelper; cdecl;
  end;

  [JavaSignature('com/delphiworlds/firemonkey/DWCaptureRequestBuilderHelper')]
  JDWCaptureRequestBuilderHelper = interface(JObject)
    ['{ECDB6573-589C-4C0E-B8B9-D68F43425D98}']
    procedure setCaptureRequestBuilder(P1: JCaptureRequest_Builder); cdecl;
    procedure setFaceDetectMode(mode: Integer); cdecl;
  end;
  TJDWCaptureRequestBuilderHelper = class(TJavaGenericImport<JDWCaptureRequestBuilderHelperClass, JDWCaptureRequestBuilderHelper>) end;

  JDWCaptureResultHelperClass = interface(JObjectClass)
    ['{D6B024D2-1244-4BEF-A2F9-DE5FC1171E95}']
    {class} function init: JDWCaptureResultHelper; cdecl;
  end;

  [JavaSignature('com/delphiworlds/firemonkey/DWCaptureResultHelper')]
  JDWCaptureResultHelper = interface(JObject)
    ['{88F9C12C-DB60-4E77-A511-F7BB25DCB38B}']
    function getFaceDetectMode: Integer; cdecl;
    function getFaces: TJavaObjectArray<JFace>; cdecl;
    procedure setCaptureResult(P1: JCaptureResult); cdecl;
  end;
  TJDWCaptureResultHelper = class(TJavaGenericImport<JDWCaptureResultHelperClass, JDWCaptureResultHelper>) end;

  JDWCameraCaptureSessionStateCallbackClass = interface(JCameraCaptureSession_StateCallbackClass)
    ['{D8539E16-3066-4BF1-8483-DA4B95854D39}']
    {class} function init(listener: JDWCameraCaptureSessionStateCallbackListener): JDWCameraCaptureSessionStateCallback; cdecl;
  end;

  [JavaSignature('com/delphiworlds/firemonkey/DWCameraCaptureSessionStateCallback')]
  JDWCameraCaptureSessionStateCallback = interface(JCameraCaptureSession_StateCallback)
    ['{AB18B118-492E-4ED4-856A-1BC58F655BB3}']
    procedure onConfigureFailed(session: JCameraCaptureSession); cdecl;
    procedure onConfigured(session: JCameraCaptureSession); cdecl;
  end;
  TJDWCameraCaptureSessionStateCallback = class(TJavaGenericImport<JDWCameraCaptureSessionStateCallbackClass,
    JDWCameraCaptureSessionStateCallback>) end;

  JDWCameraCaptureSessionStateCallbackListenerClass = interface(IJavaClass)
    ['{0275BFB6-4DB5-4A8A-B8AC-925A0DA09A69}']
  end;

  [JavaSignature('com/delphiworlds/firemonkey/DWCameraCaptureSessionStateCallbackListener')]
  JDWCameraCaptureSessionStateCallbackListener = interface(IJavaInstance)
    ['{29110A8F-CD76-443F-9311-BBF17EB82C8A}']
    procedure ConfigureFailed(session: JCameraCaptureSession); cdecl;
    procedure Configured(session: JCameraCaptureSession); cdecl;
  end;
  TJDWCameraCaptureSessionStateCallbackListener = class(TJavaGenericImport<JDWCameraCaptureSessionStateCallbackListenerClass,
    JDWCameraCaptureSessionStateCallbackListener>) end;

  JDWCameraCaptureSessionCaptureCallbackClass = interface(JCameraCaptureSession_CaptureCallbackClass)
    ['{5DF98741-D7C1-451F-BCD9-767A2AF1F7A7}']
    {class} function init(listener: JDWCameraCaptureSessionCaptureCallbackListener): JDWCameraCaptureSessionCaptureCallback; cdecl;
  end;

  [JavaSignature('com/delphiworlds/firemonkey/DWCameraCaptureSessionCaptureCallback')]
  JDWCameraCaptureSessionCaptureCallback = interface(JCameraCaptureSession_CaptureCallback)
    ['{8684B527-A48D-4F16-BBEA-B07336EB3295}']
    procedure onCaptureProgressed(session: JCameraCaptureSession; request: JCaptureRequest; partialResult: JCaptureResult); cdecl;
    procedure onCaptureCompleted(session: JCameraCaptureSession; request: JCaptureRequest; result: JTotalCaptureResult); cdecl;
  end;
  TJDWCameraCaptureSessionCaptureCallback = class(TJavaGenericImport<JDWCameraCaptureSessionCaptureCallbackClass,
    JDWCameraCaptureSessionCaptureCallback>) end;

  JDWCameraCaptureSessionCaptureCallbackListenerClass = interface(IJavaClass)
    ['{F672F04E-A294-43A9-A2E2-14D4986E9F66}']
  end;

  [JavaSignature('com/delphiworlds/firemonkey/DWCameraCaptureSessionCaptureCallbackListener')]
  JDWCameraCaptureSessionCaptureCallbackListener = interface(IJavaInstance)
    ['{A4783EF9-ABEB-4342-9453-1C6AF15C7E2A}']
    procedure CaptureProgressed(session: JCameraCaptureSession; request: JCaptureRequest; partialResult: JCaptureResult); cdecl;
    procedure CaptureCompleted(session: JCameraCaptureSession; request: JCaptureRequest; result: JTotalCaptureResult); cdecl;
  end;
  TJDWCameraCaptureSessionCaptureCallbackListener = class(TJavaGenericImport<JDWCameraCaptureSessionCaptureCallbackListenerClass,
    JDWCameraCaptureSessionCaptureCallbackListener>) end;

  JDWCameraDeviceStateCallbackClass = interface(JCameraDevice_StateCallbackClass)
    ['{2569DA5F-9292-4F17-8153-E0B657A0A704}']
    {class} function init(listener: JDWCameraDeviceStateCallbackListener): JDWCameraDeviceStateCallback; cdecl;
  end;

  [JavaSignature('com/delphiworlds/firemonkey/DWCameraDeviceStateCallback')]
  JDWCameraDeviceStateCallback = interface(JCameraDevice_StateCallback)
    ['{E29208A3-94CA-4383-82AF-527090ED2B5B}']
    procedure onDisconnected(camera: JCameraDevice); cdecl;
    procedure onError(camera: JCameraDevice; P2: Integer); cdecl;
    procedure onOpened(camera: JCameraDevice); cdecl;
  end;
  TJDWCameraDeviceStateCallback = class(TJavaGenericImport<JDWCameraDeviceStateCallbackClass, JDWCameraDeviceStateCallback>) end;

  JDWCameraDeviceStateCallbackListenerClass = interface(IJavaClass)
    ['{189B3248-8E4F-49DA-ADAF-5B1A2A7569D1}']
  end;

  [JavaSignature('com/delphiworlds/firemonkey/DWCameraDeviceStateCallbackListener')]
  JDWCameraDeviceStateCallbackListener = interface(IJavaInstance)
    ['{CF9CD6DA-55B3-4EC6-9DC3-84FB2F73722E}']
    procedure Disconnected(camera: JCameraDevice); cdecl;
    procedure Error(camera: JCameraDevice; error: Integer); cdecl;
    procedure Opened(camera: JCameraDevice); cdecl;
  end;
  TJDWCameraDeviceStateCallbackListener = class(TJavaGenericImport<JDWCameraDeviceStateCallbackListenerClass,
    JDWCameraDeviceStateCallbackListener>) end;

implementation

end.

