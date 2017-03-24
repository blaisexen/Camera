unit DW.NativeControl.Android;

{$I DW.GlobalDefines.inc}

interface

uses
  // RTL
  System.Types, System.Classes,
  // Android
  Androidapi.JNI.Embarcadero, Androidapi.JNI.GraphicsContentViewText,
  // FMX
  FMX.Controls;

type
  TNativeControl = class(TControl)
  private
    FBounds: TRect;
    FNativeLayout: JNativeLayout;
    FScale: Single;
    procedure DoHide;
    procedure DoResize;
    procedure DoShow;
    procedure FinaliseLayout;
    procedure Initialise;
    procedure InitialiseLayout;
    procedure UpdateBounds;
    function GetNativeControl: Pointer;
  protected
    FNativeControl: JView;
    function CreateNativeControl: JView; virtual;
    function GetIsVisible: Boolean;
    procedure Resize; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Hide; override;
    procedure Show; override;
    property NativeControl: Pointer read GetNativeControl;
  end;

implementation

uses
  // RTL
  System.SysUtils,
  // Android
  Androidapi.Helpers, Androidapi.JNI.App,
  // FMX
  FMX.Helpers.Android, FMX.Types, FMX.Forms, FMX.Platform, FMX.Platform.Android;

type
  TOpenControl = class(TControl);

{ TNativeControl }

constructor TNativeControl.Create(AOwner: TComponent);
begin
  inherited;
  Initialise;
end;

destructor TNativeControl.Destroy;
begin
  if (FNativeControl <> nil) and (FNativeLayout <> nil) then
    FinaliseLayout;
  inherited;
end;

procedure TNativeControl.FinaliseLayout;
begin
  TUIThreadCaller.Call<JView, JNativeLayout>(
    procedure (ANativeControl: JView; ANativeLayout: JNativeLayout)
    begin
      ANativeControl.setVisibility(TJView.JavaClass.INVISIBLE);
      ANativeLayout.setControl(nil);
    end, FNativeControl, FNativeLayout);
end;

function TNativeControl.CreateNativeControl: JView;
begin
  Result := nil;
end;

procedure TNativeControl.Initialise;
var
  LScreenService: IFMXScreenService;
begin
  if TPlatformServices.Current.SupportsPlatformService(IFMXScreenService, LScreenService) then
    FScale := LScreenService.GetScreenScale
  else
    FScale := 1;
  CallInUIThreadAndWaitFinishing(InitialiseLayout);
end;

procedure TNativeControl.InitialiseLayout;
begin
  FNativeControl := CreateNativeControl;
  if FNativeControl <> nil then
  begin
    FNativeLayout := TJNativeLayout.JavaClass.init(TAndroidHelper.Activity, MainActivity.getWindow.getDecorView.getWindowToken);
    FNativeLayout.setControl(FNativeControl);
  end;
end;

procedure TNativeControl.UpdateBounds;
var
  LPoint: TPointF;
  LControl: IControl;
begin
  if Parent is TCommonCustomForm then
    LPoint := Position.Point
  else if Supports(ParentControl, IControl, LControl) then
    LPoint := LControl.LocalToScreen(Position.Point)
  else
    Exit; // <======
  FBounds := Rect(Round(LPoint.X * FScale), Round(LPoint.Y * FScale), Round(Width * FScale), Round(Height * FScale));
end;

procedure TNativeControl.DoResize;
begin
  UpdateBounds;
  FNativeLayout.setPosition(FBounds.Left, FBounds.Top);
  FNativeLayout.setSize(FBounds.Right, FBounds.Bottom);
end;

procedure TNativeControl.Resize;
begin
  inherited;
  CallInUIThread(DoResize);
end;

function TNativeControl.GetIsVisible: Boolean;
begin
  Result := (FNativeControl <> nil) and (FNativeControl.getVisibility = TJView.JavaClass.VISIBLE);
end;

function TNativeControl.GetNativeControl: Pointer;
begin
  Result := FNativeControl;
end;

procedure TNativeControl.DoHide;
begin
  if (FNativeControl <> nil) and (FNativeControl.getVisibility <> TJView.JavaClass.INVISIBLE) then
    FNativeControl.setVisibility(TJView.JavaClass.INVISIBLE);
end;

procedure TNativeControl.Hide;
begin
  inherited;
  CallInUIThread(DoHide);
end;

procedure TNativeControl.DoShow;
begin
  if (FNativeControl <> nil) and (FNativeControl.getVisibility <> TJView.JavaClass.VISIBLE) then
  begin
    DoResize;
    FNativeControl.setVisibility(TJView.JavaClass.VISIBLE);
  end;
end;

procedure TNativeControl.Show;
begin
  inherited;
  CallInUIThread(DoShow);
end;

end.
