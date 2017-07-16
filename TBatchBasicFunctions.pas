unit TBatchBasicFunctions;
//{$define FREEPASCAL=1}
{$ifdef FREEPASCAL}
{$mode delphi}
{$endif}
interface

uses
 SysUtils, Classes,  TMatrixObject ;

type
  TBatchBasics  = class
  public
     constructor Create ;  //
     destructor  Destroy; // override;
     procedure   free;
     function  LeftSideOfEqual(tStr : string) : string ;
     function  RightSideOfEqual(tStr : string) : string ;
     function  GetStringFromStrList(tStrList : TStringList; lineNum : integer ) : string ;
     function  ConvertValueStringToPosString(inXVarRange : string; xCoordData : TMatrix) : string ; // returns '' if values are out of range of spectra xCoord data ;
  private
end;

implementation

constructor TBatchBasics.Create;  // need SDPrec for TRegression object
begin
//   inherited Create ;
end ;


destructor  TBatchBasics.Destroy; // override;
begin
//  inherited Destroy ;
end ;

procedure TBatchBasics.Free;
begin
 if Self <> nil then Destroy;
end;


function  TBatchBasics.LeftSideOfEqual(tStr : string) : string ;
begin
  if tStr <> '' then
  result := lowerCase(trim(copy(tStr,1,pos('=',tStr)-1)))
  else
  result := '' ;
end ;


function  TBatchBasics.RightSideOfEqual(tStr : string) : string ;
begin
  result := lowerCase(trim(copy(tStr,pos('=',tStr)+1,length(tStr)-length(copy(tStr,1,pos('=',tStr)))))) ;
end ;


function  TBatchBasics.GetStringFromStrList(tStrList : TStringList; lineNum : integer ) : string ;
// this removes any comments from a line with instructions and returns the instruction string
var
  tstr1 : string ;
begin
  if lineNum <  tStrList.Count then
  begin
    tstr1 := tStrList.Strings[lineNum] ;
    tstr1 := trim( tstr1 ) ;
    if (pos('//',tstr1) = 1) then   // only comment on this line
    begin
      tstr1 := '' ;
    end
    else
    if (pos('//',tstr1) > 1) then
    begin
      tstr1 := copy(tstr1,1,pos('//',tstr1)-1) ;
    end ;
    result := tstr1 ;
  end
  else
    result := '' ;
end ;

function  TBatchBasics.ConvertValueStringToPosString(inXVarRange : string; xCoordData : TMatrix) : string  ;
var
  t1, t2 : integer ;
  posNum1, posNum2 : integer ;
  tstr1 : string ;
  s1, s2, s_f1, s_f2 : single ;
begin
  tStr1 := copy(inXVarRange,1,pos('-',inXVarRange)-1) ;
  s_f1 := strtofloat(tStr1) ;
  tStr1 := copy(inXVarRange,pos('-',inXVarRange)+1,pos(' ',inXVarRange)-pos('-',inXVarRange)) ;
  s_f2 := strtofloat(tStr1) ;

  // make sure s_f1 is smaller than s_f2
  if s_f1 > s_f2 then
  begin
    s1 := s_f1 ;
    s_f1 := s_f2 ;
    s_f2 := s1 ;
  end ;

  // make sure s_f1 and s_f2 are in range of data
  xCoordData.F_Mdata.Seek(0,soFromBeginning) ;
  xCoordData.F_Mdata.Read(s1,4) ;
  xCoordData.F_Mdata.Seek(-xCoordData.SDPrec,soFromEnd) ;
  xCoordData.F_Mdata.Read(s2,4) ;

  if s1 > s2 then // x data is from high to low so swap
  begin
    if (s_f1 > s1) or (s_f1 < s2) or (s_f2 > s1) or (s_f2 < s2) then
    begin
      result := '' ;
      exit ;
    end ;

    posNum1 := 0 ;
    posNum2 := 0 ;
    xCoordData.F_Mdata.Seek(0,soFromBeginning) ;
    xCoordData.F_Mdata.Read(s1,4) ;
    while s1 > s_f2 do
    begin
      xCoordData.F_Mdata.Read(s1,4) ;
      inc(posNum1) ;
    end ;
    s2 :=  s_f2 - s1 ;
    xCoordData.F_Mdata.Seek(-8,soFromCurrent) ;
    xCoordData.F_Mdata.Read(s1,4) ;
    s1 :=  s1 - s_f2 ;
{    if s1 < s2 then
      inc(posNum1) ;   }

    xCoordData.F_Mdata.Read(s1,4) ;
    while s1 > s_f1 do
    begin
      xCoordData.F_Mdata.Read(s1,4) ;
      inc(posNum2) ;
    end ;
    s2 := s_f1 - s1  ;
    xCoordData.F_Mdata.Seek(-8,soFromCurrent) ;
    xCoordData.F_Mdata.Read(s1,4) ;
    s1 :=  s1 - s_f1 ;
{    if s1 < s2 then
      inc(posNum2) ;  }

     result := inttostr(posNum1)+'-'+ inttostr(posNum1+posNum2) ;
//    result := self.xVarRange ;
  end
  else
  if s2 > s1 then // x data is from low to high
  begin
    if (s_f1 < s1) or (s_f1 > s2) or (s_f2 < s1) or (s_f2 > s2) then
    begin
      result := '' ;
      exit ;
    end ;

    posNum1 := 0 ;
    posNum2 := 0 ;
    xCoordData.F_Mdata.Seek(0,soFromBeginning) ;
    xCoordData.F_Mdata.Read(s1,4) ;
    while s1 < s_f1 do
    begin
      xCoordData.F_Mdata.Read(s1,4) ;
      inc(posNum1) ;
    end ;
    s2 :=  s1 - s_f1 ;
    xCoordData.F_Mdata.Seek(-8,soFromCurrent) ;
    xCoordData.F_Mdata.Read(s1,4) ;
    s1 :=  s_f1 - s1 ;
    if s1 < s2 then
      dec(posNum1) ;

    xCoordData.F_Mdata.Read(s1,4) ;
    while (s1 < s_f2) {and (xCoordData.F_Mdata.Position < xCoordData.numCols )} do
    begin
      xCoordData.F_Mdata.Read(s1,4) ;
      inc(posNum2) ;
    end ;
    s2 := s1  - s_f2    ;
    xCoordData.F_Mdata.Seek(-8,soFromCurrent) ;
    xCoordData.F_Mdata.Read(s1,4) ;
    s1 :=  s_f2 - s1 ;
    if s1 < s2 then
      dec(posNum2) ;

    result := inttostr(posNum1)+'-'+ inttostr(posNum1+posNum2) ;
    xCoordData.F_Mdata.Seek(0,soFromBeginning) ;
  end ;
end ;


end.
 
