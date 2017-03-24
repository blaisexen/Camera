unit DW.Helpers.Android;

{$I DW.GlobalDefines.inc}

interface

uses
  // Android
  Androidapi.JNI.JavaTypes, Androidapi.JNI.GraphicsContentViewText,
  // FMX
  FMX.Graphics;

function GetObjectID(const AObject: JObject): Pointer;
function JBitmapToBitmap(const AJBitmap: JBitmap; const ABitmap: TBitmap): Boolean;

implementation

uses
  // Android
  Androidapi.JNIBridge,
  // FMX
  FMX.Surfaces, FMX.Helpers.Android;

function GetObjectID(const AObject: JObject): Pointer;
begin
  Result := (AObject as ILocalObject).GetObjectID;
end;

function JBitmapToBitmap(const AJBitmap: JBitmap; const ABitmap: TBitmap): Boolean;
var
  LSurface: TBitmapSurface;
begin
  LSurface := TBitmapSurface.Create;
  try
    Result := JBitmapToSurface(AJBitmap, LSurface);
    if Result  then
      ABitmap.Assign(LSurface);
  finally
    LSurface.Free;
  end;
end;

end.
