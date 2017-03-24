unit DW.CameraPreview;

(*

  DelphiWorlds cross-platform Camera project
  ------------------------------------------

  A (potentially) cross-platform Camera, aimed at supporting newer APIs

*)

{$I DW.GlobalDefines.inc}

interface

uses
  // DW
  DW.BaseCameraPreview,
{$IF Defined(Android)}
  DW.CameraPreview.Android;
{$ENDIF}

type
  TCameraPreview = class(TCustomNativeCameraPreview);

implementation

end.
