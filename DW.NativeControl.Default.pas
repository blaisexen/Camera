unit DW.NativeControl.Default;

//!!!! include defines

interface

uses
  // FMX
  FMX.Controls;

type
  TNativeControl = class(TControl)
  protected
    function GetIsVisible: Boolean; virtual;
  public
    property IsVisible: Boolean read GetIsVisible;
  end;

implementation

{ TNativeControl }

function TNativeControl.GetIsVisible: Boolean;
begin
  Result := GetVisible;
end;

end.
