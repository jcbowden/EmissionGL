unit TASMTimerUnit;

interface

uses SysUtils, Dialogs ;

type
  TASMTimer  = class
  public

      constructor  Create(CPU_Hz_input : Int64) ;
      destructor   Destroy ;

      procedure    setTimeDifSec ;
      procedure    setTimeDifSecUpdateT1  ;

      function     getRecordedTic  : Int64 ;
      function     getRecordedTime : single ;

      function     returnCPUSpeedHz : Int64 ;
      function     returnCPUSpeedMHz : Int64 ;
      function     returnCPUSpeedGHz : single ;

      procedure    outputTimeSec(mssg : string) ;

  private
      T1 : Int64 ;
      T2 : Int64 ;
      lastRecordedTime : single ;
      lastRecordedTic  : Int64 ;
      cpuSpeedHz : Int64 ;
      function Ticker() : Int64 ;

  end;



implementation

constructor TASMTimer.Create(CPU_Hz_input : Int64) ;
var
  loopMax : integer ;
begin
    loopMax := 1 ;
    if CPU_Hz_input = 0 then
    begin
      while (CPU_Hz_input <= 0) and (loopMax < 3) do
      begin
       T1 := Ticker ;
       sleep(250) ;
       T2 := Ticker ;
       CPU_Hz_input := T2 -T1 ;
       inc(loopMax) ;
      end
    end
    else
    begin
       T1 := Ticker ;
    end;

    
    self.cpuSpeedHz :=  CPU_Hz_input * 4 ;
end;


destructor  TASMTimer.Destroy ;
begin

end;


procedure    TASMTimer.setTimeDifSec ;
begin
  T2 := Ticker ;
  lastRecordedTic := (T2 - T1) ;
  lastRecordedTime := lastRecordedTic /  cpuSpeedHz ;
end;


procedure    TASMTimer.setTimeDifSecUpdateT1  ;
begin
  T2 := Ticker ;
  lastRecordedTic := (T2 - T1) ;
  lastRecordedTime := lastRecordedTic /  cpuSpeedHz ;
  T1 := Ticker ;
end;


function    TASMTimer.returnCPUSpeedHz : Int64 ;
begin
  result := cpuSpeedHz  ;
end;

function    TASMTimer.returnCPUSpeedMHz : Int64 ;
begin
  result := cpuSpeedHz div 1000000; // sleep(256)
end;

function    TASMTimer.returnCPUSpeedGHz : single ;
begin
   result := cpuSpeedHz / 1000000000 ;
end;


function    TASMTimer.getRecordedTime : single ;
begin
   result := lastRecordedTime  ;
end;

function    TASMTimer.getRecordedTic : Int64 ;
begin
   result := lastRecordedTic  ;
end;

procedure    TASMTimer.outputTimeSec(mssg : string) ;
begin
  messagedlg(mssg + floattostrf(getRecordedTime,ffGeneral,4,5) ,mtInformation,[mbOK],0) ;
end;

{$O-}
function TASMTimer.Ticker() : Int64;
begin
  asm
    db $0F, $31  //opcode for RDTSC
    mov dword ptr [result+00],eax
    mov dword ptr [result+04],edx
  end;
end;
{$O+}



end.
