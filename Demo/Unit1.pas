unit Unit1;

(*

  DelphiWorlds cross-platform Camera project
  ------------------------------------------

  A (potentially) cross-platform Camera, aimed at supporting newer APIs

  Demo app that does basic preview and capture on face detection

*)

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.ScrollBox, FMX.Memo, FMX.TabControl,
  FMX.Objects, FMX.Controls.Presentation, FMX.StdCtrls, FMX.Layouts,
  DW.Camera;

type
  TForm1 = class(TForm)
    ButtonsLayout: TLayout;
    StartCameraButton: TButton;
    MemoLayout: TLayout;
    LogMemo: TMemo;
    TabControl: TTabControl;
    PreviewTab: TTabItem;
    CaptureTab: TTabItem;
    CaptureImage: TImage;
    procedure StartCameraButtonClick(Sender: TObject);
    procedure TabControlChange(Sender: TObject);
  private
    FCamera: TCamera;
    procedure CameraDetectedFacesHandler(Sender: TObject; const AImage: TBitmap; const AFaces: TFacesArray);
    procedure CameraStatusChangeHandler(Sender: TObject);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  end;

var
  Form1: TForm1;

implementation

{$R *.fmx}

uses
  FMX.Media;

const
  cStartCaptions: array[Boolean] of string = ('Start', 'Stop');

{ TForm1 }

constructor TForm1.Create(AOwner: TComponent);
begin
  inherited;
  TabControl.ActiveTab := PreviewTab;
  FCamera := TCamera.Create;
  FCamera.FaceDetectMode := TFaceDetectMode.Full;
  FCamera.CameraPosition := TDevicePosition.Front;
  FCamera.OnStatusChange := CameraStatusChangeHandler;
  FCamera.OnDetectedFaces := CameraDetectedFacesHandler;
end;

destructor TForm1.Destroy;
begin
  FCamera.Free;
  inherited;
end;

procedure TForm1.StartCameraButtonClick(Sender: TObject);
begin
  FCamera.PreviewControl.Parent := PreviewTab;
  FCamera.Active := not FCamera.Active;
end;

procedure TForm1.CameraStatusChangeHandler(Sender: TObject);
begin
  StartCameraButton.Text := cStartCaptions[FCamera.Active];
end;

procedure TForm1.CameraDetectedFacesHandler(Sender: TObject; const AImage: TBitmap; const AFaces: TFacesArray);
var
  I: Integer;
  LBounds: TRectF;
begin
  for I := 0 to Length(AFaces) - 1 do
  begin
    LBounds := AFaces[I].Bounds;
    LogMemo.Lines.Add(Format('Detected face at: %.0f, %0.f, %0.f, %0.f', [LBounds.Left, LBounds.Top, LBounds.Right, LBounds.Bottom]));
    AImage.Canvas.BeginScene;
    try
      AImage.Canvas.Stroke.Color := TAlphaColorRec.Red;
      AImage.Canvas.Stroke.Thickness := 2;
      AImage.Canvas.DrawEllipse(LBounds, 1);
    finally
      AImage.Canvas.EndScene;
    end;
  end;
  CaptureImage.Bitmap.Assign(AImage);
  TabControl.ActiveTab := CaptureTab;
end;

procedure TForm1.TabControlChange(Sender: TObject);
begin
  // This is necessary because the native preview will otherwise show over the top of the FMX controls
  FCamera.PreviewControl.Visible := TabControl.ActiveTab = PreviewTab;
end;

end.
