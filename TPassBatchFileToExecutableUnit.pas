unit TPassBatchFileToExecutableUnit;

interface

uses  Windows, Classes, SysUtils, TSpectraRangeObject, TBatchBasicFunctions ;

// type TGLLineColor = Array[0..2] of single ;  // holds color of spectra in GL notation (ie 0..1 float value)

type
  TPassBatchFileToExecutable  = class
  public
     listSectn            : TStringList ;  // this is batch file section saved for Batch processing
     PID_int              : cardinal    ;  // this is returned by GetCurrentProcessId() of process created (used in back-end process)
     ProcHandle_int       : cardinal    ;  // handle to te process - used to test if process is still running
     resultFileNameStr    : string      ;  // this is output directory of results
     resultFileDirStr     : string      ;
     exeNameAndPathString : string      ; // this is path and name of exectable that is called to run the batch file
     batchFilename        : string      ;

     lineCol              : TGLlineColor    ;  // points to TGLlineColor
     bb                   : TBatchBasics ;

     constructor Create(exeNameAndPathStringIn : string) ;
     destructor  Destroy; override;
     procedure   Free ;

     function ReadBatchSection(tStrL: TStringList; linenumIn : integer) : string ;
     // translates cell references in the batch file into data on disk with path information
     // for input into executable.
     procedure ProcessFileReferences ;
     // creates process that does calculation
     function CreateBatchProcess : boolean;

  private

end;

implementation


constructor TPassBatchFileToExecutable.Create(exeNameAndPathStringIn : string) ;
begin
   bb := TBatchBasics.Create ;
   listSectn    := TStringList.Create ;
   exeNameAndPathString := exeNameAndPathStringIn ;

   if exeNameAndPathString[length(exeNameAndPathString)] <> '"' then
     exeNameAndPathString := exeNameAndPathString + '"' ;
   if pos('"',exeNameAndPathString) <> 0 then
     exeNameAndPathString := '"'+ exeNameAndPathString ;

   PID_int := 0 ;
end ;

destructor TPassBatchFileToExecutable.Destroy ;
begin
   bb.Free   ;
   listSectn.Free ;
end ;

procedure TPassBatchFileToExecutable.Free;
begin
  if Self <> nil then Destroy;
end;

function TPassBatchFileToExecutable.ReadBatchSection(tStrL: TStringList; linenumIn : integer) : string;
// returns true if successfull, otherwise returns false
var
  tStr : string ;
begin
  result := '' ;
  listSectn.Clear ;
  tStr := '' ;

  tStr := bB.GetStringFromStrList(tStrL,linenumIn) ;
  repeat

     if bB.LeftSideOfEqual(tStr) = 'batch filename' then
     begin
       batchFilename  := bB.RightSideOfEqual(tStr) ;
       tStr := '//' + tStr ;
     end;
     // add string to short batch file
     if tStr <> '' then
       listSectn.Add(tStr) ;

     if bB.LeftSideOfEqual(tStr) = 'results file' then
       resultFileNameStr  := bB.RightSideOfEqual(tStr) ;

     inc(linenumIn) ;
     tStr := bB.GetStringFromStrList(tStrL,linenumIn) ;
  until (bB.LeftSideOfEqual(tStr) = 'type') or (lineNumIn >= tStrL.Count) ;

  // file path **cannot** have spaces as it is passed as an argument to the executable (like on a command line)
  // this is directory where results will be stored
  resultFileNameStr := ExpandFileName(resultFileNameStr) ; // adds drive and full directory structure to filename
  if (pos(' ',resultFileNameStr) > 0)  then
  begin
    result := inttostr(lineNumIn) + ', ' + ' File path **cannot** have spaces as it is passed as an argument to the executable (like on a command line)' ;
    exit ;
  end;
  
  resultFileDirStr  := ExtractFileDir(resultFileNameStr) ;
  resultFileNameStr := ExtractFileName(resultFileNameStr) ;

  if resultFileDirStr[length(resultFileDirStr)] <> '\' then
   resultFileDirStr := resultFileDirStr + '\' ;

  // create directory for output if needed
  if DirectoryExists(resultFileDirStr) = false then
  begin
     if not ForceDirectories(resultFileDirStr) then
     begin
       result := inttostr(lineNumIn) + ', error creating directory' ;
       exit ;
     end;

  end;

  // add a default name for batchfilename if it is empty
  if trim(batchFilename) = '' then batchFilename := 'analysis.bat' ;
  batchFilename :=  ExtractFileName(batchFilename) ;  // ensure batch file filename has no directory path

  // Save batch file (this should be done after file processing)
  listSectn.SaveToFile(resultFileDirStr+ExtractFileName(batchFilename));

  result := inttostr(lineNumIn) ;
end;



procedure TPassBatchFileToExecutable.ProcessFileReferences ;
begin


end;



function TPassBatchFileToExecutable.CreateBatchProcess : boolean ;
var
  t_pi :  TProcessInformation ;
  t_si :  TStartupInfo ;
  exeNameAndPathStringQuoted : string ;
//  ProcHandle : cardinal ;
begin

  FillMemory( @t_si, sizeof(t_si),0) ;
  FillMemory( @t_pi, sizeof(t_pi),0) ;
  t_si.cb := sizeof(t_si) ;

  t_si.lpTitle :=  PChar(batchFilename) ;
  t_si.dwFillAttribute := FOREGROUND_RED or BACKGROUND_RED or BACKGROUND_GREEN or BACKGROUND_BLUE ;
  t_si.lpReserved := NIL ;
  t_si.cbReserved2 := 0 ;
  t_si.lpReserved2 := NIL ;
  t_si.dwFlags :=    CREATE_NEW_CONSOLE or STARTF_USEFILLATTRIBUTE ;
  t_si.wShowWindow := SW_SHOWDEFAULT ; // SW_MINIMIZE ;
  exeNameAndPathStringQuoted := '"' + exeNameAndPathString +'"' ;
  // '"'+resultFileDirStr+batchFilename+'"'   // PChar(batchFilename)
  // file path **cannot** have spaces as it is passed as an argument to the executable (like on a command line)
  result := CreateProcess(NIL,PChar(exeNameAndPathString+' '+resultFileDirStr+batchFilename),NIL,NIL,FALSE,
                                                  NORMAL_PRIORITY_CLASS,NIL,PChar(resultFiledIRStr),t_si,t_pi) ;   //  IDLE_PRIORITY_CLASS

  if result then
  begin
    ProcHandle_int :=  t_pi.hProcess ;     // this is used to get info about the process
    PID_int        :=  t_pi.dwProcessId ;  // this is returned by GetCurrentProcessId() of process created (used in back-end process)
  end ;



end;



end.
