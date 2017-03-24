unit DW.CameraPreview.Android;

(*

  DelphiWorlds cross-platform Camera project
  ------------------------------------------

  A (potentially) cross-platform Camera, aimed at supporting newer APIs

*)

interface

uses
  // RTL
  System.Classes,
  // Android
  Androidapi.JNI.GraphicsContentViewText,
  // DW
  DW.BaseCameraPreview, DW.Androidapi.JNI.TextureView;

type
  TCustomNativeCameraPreview = class(TBaseNativeCameraPreview)
  private
    FTextureView: JTextureView;
  protected
    function CreateNativeControl: JView; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    property TextureView: JTextureView read FTextureView;
  end;

implementation

uses
  // RTL
  System.SysUtils,
  // Android
  Androidapi.Helpers, Androidapi.JNI.App;

{ TCustomNativeCameraPreview }

constructor TCustomNativeCameraPreview.Create(AOwner: TComponent);
begin
  inherited;
  //
end;

destructor TCustomNativeCameraPreview.Destroy;
begin
  //
  inherited;
end;

function TCustomNativeCameraPreview.CreateNativeControl: JView;
begin
  FTextureView := TJTextureView.JavaClass.init(TAndroidHelper.Activity);
  Result := FTextureView;
end;

end.
