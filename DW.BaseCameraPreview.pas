unit DW.BaseCameraPreview;

(*

  DelphiWorlds cross-platform Camera project
  ------------------------------------------

  A (potentially) cross-platform Camera, aimed at supporting newer APIs

*)

{$I DW.GlobalDefines.inc}

interface

uses
  // RTL
  System.Classes,
  // FMX
  FMX.Types,
  // DW
{$IF Defined(Android)}
  DW.NativeControl.Android;
{$ELSE}
  DW.NativeControl.Default;
{$ENDIF}

type
  TBaseNativeCameraPreview = class(TNativeControl)
  public
    constructor Create(AOwner: TComponent); override;
  end;

implementation

{ TBaseNativeCameraPreview }

constructor TBaseNativeCameraPreview.Create(AOwner: TComponent);
begin
  inherited;
  Align := TAlignLayout.Client;
end;

end.
