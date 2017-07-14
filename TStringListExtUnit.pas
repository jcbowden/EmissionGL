unit TStringListExtUnit;

interface
//{$define FREEPASCAL=1}
{$ifdef FREEPASCAL}
{$mode delphi}
{$endif}

uses  classes, SysUtils  ;

type
  TStringListExt  = class(TStringList)
  public
     filename : string ;
     textModified : boolean ;
     constructor Create ;
     destructor  Destroy; override;
     procedure Free ;
     function  IndexOf(const S: string) :  integer ;
     procedure SortListNumeric ;
  private
end;

implementation

constructor TStringListExt.Create ;
begin
   inherited Create;
end ;

destructor TStringListExt.Destroy ;
begin
//   inherited Free;
//   inherited Destroy;
end ;

procedure TStringListExt.Free;
begin
// if Self <> nil then Destroy;
inherited Free;
end;



function TStringListExt.IndexOf(const S: string) :  integer ;
var
  t1 : integer ;
begin
// if Self <> nil then Destroy;
  if Self.Count > 0 then
   t1 := inherited IndexOf(s)
  else
   t1 := -1 ;

  result := t1 ;
end;

procedure TStringListExt.SortListNumeric ;
var
  swapped, didswap : boolean ;
  tint1 : integer ;
begin
     if Self.Count > 1 then
     begin
     swapped  := true ;
     didswap := false ;
     while swapped = true do
     begin
        for tint1 := 0 to self.Count-2 do
        begin
          if strtoint(self.Strings[tint1]) > strtoint(self.Strings[tint1+1]) then
          begin
            self.Exchange(tint1, tint1+1) ;
            didswap := true ;
          end ;
        end ;

        if didswap = true then
           swapped := true
        else
           swapped := false ;

        didswap := false ;
     end ;
     end;
end ;


end.

