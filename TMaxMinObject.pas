unit TMaxMinObject;

interface
//{$define FREEPASCAL=1}
{$ifdef FREEPASCAL}
{$mode delphi}
{$endif}

uses  classes, SysUtils  ;

type
  TMaxMin = Class
  public
     SDPrec : integer ;
     p1 : pointer ;
     constructor Create(singleOrDouble : integer) ;   // data structure is <single/double = MinData> <single/double = MaxData> <integer = byte offset of MinData> <integer = byte offset of maxData>
     destructor  Destroy;
     procedure Free ;

     procedure   SetData(data : pointer; position : integer) ;
     procedure   SaveData(filename : string) ;
     function    MovePointer(tp : pointer; amount : integer ) : pointer;
     function    GetDataPointer(whichData : integer) : pointer ;
{  private}
end;


implementation

//////////////////////////////////////////////////////////////////////////////////////
// TMaxMin implementation...
// Class TMaxMin, used to hold a min value and max value of a set of numbers
// and the position in bytes of the max/min values in the original data set
//////////////////////////////////////////////////////////////////////////////////////
constructor TMaxMin.Create(singleOrDouble : integer) ;
begin
//   inherited Create;
   SDPrec := singleOrDouble  ;  // this used to be * 4, but all inputs were div 4 so it seems redundant
   GetMem(p1,SDPrec*2 + 8) ;
end ;

destructor TMaxMin.Destroy ;
begin
   FreeMem(p1,SDPrec*2 + 8) ;
//   inherited Destroy;
end ;

procedure TMaxMin.Free;
begin
 if Self <> nil then Destroy;
end;

function TMaxMin.GetDataPointer(whichData : integer) : pointer ;  // data structure is <single/double> <single/double> <integer> <integer>
begin
     if SDPrec = 4 then
     begin
        if whichData = 1 then result := p1
        else if whichData = 2 then
          begin
            result := MovePointer(p1,4) ;// move pointer
            MovePointer(p1,-4) ;         // move pointer back
          end
       else if whichData = 3 then
          begin
            result := MovePointer(p1,8) ;
            MovePointer(p1,-8) ;
          end
       else if whichData = 4 then
          begin
            result := MovePointer(p1,12) ;
            MovePointer(p1,-12) ;
          end ;
     end
     else // if SDPrec = 8 then
     begin
        if whichData = 1 then result := p1
        else if whichData = 2 then
          begin
            result := MovePointer(p1,8) ;
            MovePointer(p1,-8) ;
          end
        else if whichData = 3 then
          begin
            result := MovePointer(p1,16) ;
            MovePointer(p1,-16) ;
          end
        else if whichData = 4 then
          begin
            result := MovePointer(p1,20) ;
            MovePointer(p1,-20) ;
          end ;
     end

end ;

procedure TMaxMin.SetData(data : pointer ; position : integer) ;
begin
     if SDPrec = 4 then          // add 2 singles followed by 2 integers
     begin
        if position = 1 then
         single(p1^) := single(data^)
        else if position = 2 then
        begin
          p1 := MovePointer(p1,4) ;
          single(p1^) := single(data^) ;
          p1 := MovePointer(p1,-4) ;
        end
        else if position = 3 then  // add minValues 'byte offset'
        begin
          p1 := MovePointer(p1,8) ;
          integer(p1^) := integer(data^) ;
          p1 := MovePointer(p1,-8) ;

        end
        else if position = 4 then  // add max values 'byte offset'
        begin
          p1 := MovePointer(p1,12) ;
          integer(p1^) := integer(data^) ;
          p1 := MovePointer(p1,-12) ;
        end ;
     end
     else if SDPrec = 8 then  // add 2 doubles followed by 2 integers
     begin
        if position = 1 then
         double(p1^) := double(data^)
        else if position = 2 then
        begin
          p1 := MovePointer(p1,8) ;
          double(p1^) := double(data^) ;
          p1 := MovePointer(p1,-8) ;
        end
        else if position = 3 then  // add minValues 'byte offset'
        begin
          p1 := MovePointer(p1,16) ;
          integer(p1^) := integer(data^) ;
          p1 := MovePointer(p1,-16) ;
        end
        else if position = 4 then  // add max values 'byte offset'
        begin
          p1 := MovePointer(p1,20) ;
          integer(p1^) := integer(data^) ;
          p1 := MovePointer(p1,-20) ;
        end ;
     end
end ;

{$ifdef FREEPASCAL}
function TMaxMin.MovePointer(tp : pointer; amount : int64 ) : pointer;
begin
   asm
     MOV     RAX,tp
     MOV     RDX,amount
     ADD     RAX,RDX
     MOV     @Result,RAX
   end;
end ;
{$else}
function TMaxMin.MovePointer(tp : pointer; amount : integer ) : pointer;
begin
   asm
     MOV     EAX,tp
     MOV     EDX,amount
     ADD     EAX,EDX
     MOV     @Result,EAX
   end;
end ;
{$endif}

procedure   TMaxMin.SaveData(filename : string) ;
Var
   tempList: TStringList ;
   tstr1 : string ;

begin
   tempList := TStringList.Create ;

   if SDPrec = 4 then
   begin
     tstr1 := floatToStr(single(p1^) ) ;
     p1 := MovePointer(p1,4) ;
     tstr1 := tstr1 + ' ' + floatToStr(single(p1^) ) ;
     p1 := MovePointer(p1,4) ;
     tstr1 := tstr1 + ' ' + IntToStr(integer(p1^) ) ;
     p1 := MovePointer(p1,4) ;
     tstr1 := tstr1 + ' ' + IntToStr(integer(p1^) ) ;
     p1 := MovePointer(p1,-12) ;
   end
   else if SDPrec = 8 then
   begin
     tstr1 := floatToStr(single(p1^) ) ;
     p1 := MovePointer(p1,8) ;
     tstr1 := tstr1 + ' ' + floatToStr(single(p1^) ) ;
     p1 := MovePointer(p1,8) ;
     tstr1 := tstr1 + ' ' + IntToStr(integer(p1^) ) ;
     p1 := MovePointer(p1,4) ;
     tstr1 := tstr1 + ' ' + IntToStr(integer(p1^) ) ;
     p1 := MovePointer(p1,-20) ;
   end ;

   tempList.Add(tstr1) ;
   tempList.SaveToFile(filename) ;

   tempList.Free ;
end ;

end.
