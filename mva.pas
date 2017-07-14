// N.B. To enable this feature, add the /3GB switch to the Boot.ini file


program mva;

{$define FREEPASCAL=1}
{$define LINUX=1}

{$ifdef FREEPASCAL}
{$mode delphi}
{$endif}

// {$APPTYPE CONSOLE}


// To access the command line arguments (line in C/C++)use:
//  ParamStr (Counter)
// to return the string. Counter is 0 based and ParamStr(0) is the full path inclusive name of the executing program.
uses
  SysUtils,
  Classes,
  BLASLAPACKfreePas in 'BLASLAPACKfreePas.pas',
  FFTUnit in 'FFTUnit.pas',
  TASMTimerUnit in 'TASMTimerUnit.pas',
  TBatchBasicFunctions in 'TBatchBasicFunctions.pas',
  TMatrixObject in 'TMatrixObject.pas',
  TMatrixOperations in 'TMatrixOperations.pas',
  TMaxMinObject in 'TMaxMinObject.pas',
  TPCABatchObject in 'TPCABatchObject.pas',
  TPCAResultsObject in 'TPCAResultsObject.pas',
  TPCResultsObjects in 'TPCResultsObjects.pas',
  TPCRPredictBatchUnit in 'TPCRPredictBatchUnit.pas',
  TPLSPredictBatchUnit in 'TPLSPredictBatchUnit.pas',
  TPLSResultsObjects in 'TPLSResultsObjects.pas',
  TPLSYPredictTestBatchUnit in 'TPLSYPredictTestBatchUnit.pas',
  TPreprocessUnit in 'TPreprocessUnit.pas',
  TSpectraRangeObject in 'TSpectraRangeObject.pas',
  TStringListExtUnit in 'TStringListExtUnit.pas',
  TVarAndCoVarOperations in 'TVarAndCoVarOperations.pas',
  mkl_types in 'mkl_types.pas',
  TPCalBatchObject in 'TPCalBatchObject.pas',
  TPCalResultsObjects in 'TPCalResultsObjects.pas';

const
{$ifdef LINUX}
DIRSLASH = '/' ;
{$else}
DIRSLASH = '\' ;
//const IMAGE_FILE_LARGE_ADDRESS_AWARE = $0020;
//{$SetPEFlags IMAGE_FILE_LARGE_ADDRESS_AWARE}
{$endif}




procedure WritePCRPLS;
var
  outputStr : TStringList ;
  strName   : string ;
begin
   outputStr := TStringList.Create ;


   outputStr.Add('type = PLS1/PCR  // edit choice to PLS1 *OR* PCR') ;
   outputStr.Add('// input x and y data') ;

   outputStr.Add('x data file = x.bin') ;
   outputStr.Add('y data file = y.bin') ;

   outputStr.Add('x sample range = 1-     // (ROWS)') ;    // can select subset using this
   outputStr.Add('x var range = 1-65536   // (COLS)') ;
   outputStr.Add('y in x data = false') ;
   outputStr.Add('y sample range = 1-     // (ROWS)') ;    // can select subset using this
   outputStr.Add('y var range = 1-1       // (COLS)') ;
   outputStr.Add('number of PCs = 1-20') ;
   outputStr.Add('// pre-processing') ;  //
   outputStr.Add('mean centre = true') ;  //
   outputStr.Add('column standardise = false') ;  //
   outputStr.Add('smooth =   // average,15  // fourier,15,50,remove complex  // %,power') ;  //
   outputStr.Add('derivative =   // fourier,2,remove complex,true,1 // inputs: "diff type: 1st 2nd deriv etc: true = Hanning Window: 1 2 3 etc = zero fill"  N.B. type=fourier only available;') ;
   outputStr.Add('// EVects output - none of these are used') ;
   outputStr.Add('positive or negative =  ') ;
   outputStr.Add('autoexclude =     // 0.75 ') ;
   outputStr.Add('normalised output = true') ;
   outputStr.Add('results file = pls1_results.out') ;
   outputStr.Add('') ;


   writeln('Enter name of batch file: ') ;
   readln(strName) ;
   outputStr.SaveToFile( strName ) ;
end;

procedure WriteILS() ;
var
  outputStr : TStringList ;
  strName   : string ;
begin
   outputStr := TStringList.Create ;


   outputStr.Add('type = ILS // inverse least squares') ;
   outputStr.Add('// input (optional)x, y and scores/evectors') ;
   outputStr.Add('// if x is input then data type = evectors') ;
   outputStr.Add('// if x is omitted then data type = scores') ;
   outputStr.Add('x data file = x.bin') ;
   outputStr.Add('y data file = y.bin') ;
   outputStr.Add('scores or evects filename = scores.bin') ;
   outputStr.Add('data type = scores') ;

   outputStr.Add('x sample range = 1-     // (ROWS)') ;    // can select subset using this
   outputStr.Add('x var range = 1-65536   // (COLS)') ;
   outputStr.Add('y in x data = false') ;
   outputStr.Add('y sample range = 1-     // (ROWS)') ;    // can select subset using this
   outputStr.Add('y var range = 1-1       // (COLS)') ;
   outputStr.Add('number of PCs = 1-20    // has to be <= evects.rows or scores.cols') ;
   outputStr.Add('// pre-processing') ;  //
   outputStr.Add('mean centre = true') ;  //
   outputStr.Add('column standardise = false') ;  //
   outputStr.Add('smooth =   // average,15  // fourier,15,50,remove complex  // %,power') ;  //
   outputStr.Add('derivative =   // fourier,2,remove complex,true,1 // inputs: "diff type: 1st 2nd deriv etc: true = Hanning Window: 1 2 3 etc = zero fill"  N.B. type=fourier only available;') ;
   outputStr.Add('// EVects output - none of these are used') ;
   outputStr.Add('positive or negative =  ') ;
   outputStr.Add('autoexclude =     // 0.75 ') ;
   outputStr.Add('normalised output = true') ;
   outputStr.Add('results file = pls1_results.out') ;
   outputStr.Add('') ;


   writeln('Enter name of batch file: ') ;
   readln(strName) ;
   outputStr.SaveToFile( strName ) ;
end;


procedure WritePCA;
var
  outputStr : TStringList ;
  strName   : string ;
begin
   outputStr := TStringList.Create ;

   outputStr.Add('type = PCA') ;

   outputStr.Add('x data file = x.bin') ;

   outputStr.Add('sample range = 1-  // can select subset using this') ; // can select subset using this
   outputStr.Add('x var range = 1-65536') ;
   outputStr.Add('number of PCs = 1-6') ;
   outputStr.Add('pos or neg range = 1200-1260 cm-1  // can be variable number or value found in x coordinate (space essential between value and units) ') ;
   outputStr.Add('positive or negative = negative') ;
   outputStr.Add('autoexclude = 0.0') ;
   outputStr.Add('exclude from PCs = 0') ;
   outputStr.Add('mean centre = true') ;
   outputStr.Add('column standardise = false') ;
   outputStr.Add('normalised output = true') ;
   outputStr.Add('results file = PCA.out') ;
   outputStr.Add('') ;

   writeln('Enter name of batch file: ') ;
   readln(strName) ;
   outputStr.SaveToFile( strName ) ;
end;


procedure WritePredictY;
var
  outputStr : TStringList ;
  strName   : string ;
begin
   outputStr := TStringList.Create ;

   outputStr.Add('type = PREDICT Y') ;
   outputStr.Add('// X column: new x data; Y column: Y reference data; Then regression coefficients ') ;
   outputStr.Add('// input x and y data') ;

   outputStr.Add('x data file = x.bin') ;
   outputStr.Add('y data file = y.bin') ;
   outputStr.Add('reg coef file = regcoef.bin') ;

   outputStr.Add('x sample range = 1-      // (ROWS)') ;    // can select subset using this
   outputStr.Add('x var range = 1-65536    // (COLS)') ;
   outputStr.Add('y in x data = false') ;
   outputStr.Add('y sample range = 1-      // (ROWS)') ;    // can select subset using this
   outputStr.Add('y var range = 1-1        // (COLS)') ;
   outputStr.Add('// pre-processing') ;
   outputStr.Add('mean centre = true') ;
   outputStr.Add('column standardise = false') ;
   outputStr.Add('smooth =   // average,15  // fourier,15,50,remove complex  // %,power') ;
   outputStr.Add('derivative =   // fourier,2,remove complex,true,1 // inputs: "diff type: 1st 2nd deriv etc: true = Hanning Window: 1 2 3 etc = zero fill"  N.B. type=fourier only available;') ;
   outputStr.Add('results file = prediction_results.out') ;
   outputStr.Add('') ;

   writeln('Enter name of batch file: ') ;
   readln(strName) ;
   outputStr.SaveToFile( strName ) ;
end;


procedure WriteConcat ;
var
  outputStr : TStringList ;
  strName   : string ;
begin
   outputStr := TStringList.Create ;

   outputStr.Add('type = CONCAT') ;
   outputStr.Add('//Enter directories to search and file extension ') ;
   outputStr.Add('// if input directory =...\* then all dir in current dir will be searched') ;
   outputStr.Add('// if input directory = empty then current dir will be searched') ;
   outputStr.Add('input directory =    // this is also the output directory') ;
   outputStr.Add('file extension = .bin  // include the .') ;  //
   outputStr.Add('output filename = concat_files.bin  // ') ;
   outputStr.Add('') ;

   writeln('Enter name of batch file: ') ;
   readln(strName) ;
   outputStr.SaveToFile( strName ) ;
end;

function StartupInterface : TStringList ;
var
     inputYN : string ;
     inputNum : integer ;
begin
     // Read input text batch file instructions and palce them in a TStringList.
     {$ifndef FREEPASCAL}
 //      WriteLn('Number of threads: ' + GetEnvironmentVariable('MKL_NUM_THREADS')) ;
     {$endif}

     if FileExists(ParamStr(1)) then
     begin
         Result := TStringList.Create ;
         Result.LoadFromFile(ParamStr(1));
     end
     else
     if FileExists('analysis.bat') and ((ParamStr(1)) = '') then
     begin
       writeln('Default analysis file found (analysis.bat).') ;
       write('Use this file? (y/n): ') ;
       readln(inputYN) ;
       if uppercase(copy(inputYN,1,1)) = 'Y'  then
       begin
         Result := TStringList.Create ;
         Result.LoadFromFile('analysis.bat');
       end
       else
       begin
         result := nil ;
         exit ;
       end;
     end
     else
     begin
       write('Input analysis file not present: ') ;
       writeln(ParamStr(1)) ;
//       writeln('Either on command line or in default file "analysis.bat"') ;
       write('Would you like to create one? (y/n): ') ;
       readln(inputYN) ;
       if uppercase(copy(inputYN,1,1)) = 'Y' then
       begin
         writeln('What kind:') ;
         writeln('PCA..................1') ;
         writeln('PCR/PLS1.............2') ;
         writeln('ILS..................3') ;
         writeln('Predict Y............4') ;
         writeln('Concatenate files....5') ;
         write('(enter number, then filename): ') ;
         readln(inputNum) ;
         case inputNum of
            1: WritePCA();
            2: WritePCRPLS();
            3: WriteILS() ;
            4: WritePredictY();
            5: WriteConcat();
         else
         begin
            writeln('Not a valid response. Exiting.') ;
            Result := nil ;
            exit ;
         end;
         end; // of case statement
         Result := nil ;
       end;
     end;
end ;



function FunctionConcat(tStrList: TStringList; lineNum : integer ; bb : TBatchBasics) : integer ;
// collects together all matrix type files that are in a directory or a set of sub-directorys
// and creates a combined matrix from them.
var
   DirInfo, FileInfo : TSearchRec;
   fileExt, directoryPWD, directoryPWDOrig, directoryOutput, filenameOutput : string ;
   tSR1, tSR2 : TSpectraRanges ;
   recurseBool, firstCall : boolean ;
   tstr1 : string ;
   firstNumCols, totalNumRows : integer ;
   t1     : integer ;
 //  s1 : single ;
 //  d1, d2 : double ;
   inputYN : char ;
   resetFileF : file ;
   tSTRLST : TStringList ;
begin

  repeat
    inc(lineNum) ;
    tstr1 := bB.GetStringFromStrList(tStrList, lineNum) ;
  until (trim(tstr1) <> '') or (linenum > tStrList.Count)  ;
  if bB.LeftSideOfEqual(tstr1) = 'input directory' then
     directoryOutput :=  bB.RightSideOfEqual(tstr1) ;
  // directoryOutput is the initial directory is in not changed


  tstr1 := copy(directoryOutput,length(directoryOutput),1) ;
  if tstr1 = '*' then
  begin
  recurseBool := true ;
  directoryOutput := copy(directoryOutput,1,length(directoryOutput)-1)  // remove the '*'
  end
  else
  recurseBool := false ;

  if directoryOutput='' then
    directoryOutput := GetCurrentDir()  ;

  tstr1 := copy(directoryOutput,length(directoryOutput),1) ;
  if (tstr1 <> DIRSLASH) then
    directoryOutput := directoryOutput + DIRSLASH ;

 // if recurseBool = false then
  directoryPWD := directoryOutput ;
  directoryPWDOrig :=  directoryOutput ;

  repeat
    inc(lineNum) ;
    tstr1 := bB.GetStringFromStrList(tStrList, lineNum) ;
  until (trim(tstr1) <> '') or (linenum > tStrList.Count)  ;
  if bB.LeftSideOfEqual(tstr1) = 'file extension' then
     fileExt :=  bB.RightSideOfEqual(tstr1) ;


  repeat
    inc(lineNum) ;
    tstr1 := bB.GetStringFromStrList(tStrList, lineNum) ;
  until (trim(tstr1) <> '') or (linenum > tStrList.Count)  ;
  if bB.LeftSideOfEqual(tstr1) = 'output filename' then
     filenameOutput :=  bB.RightSideOfEqual(tstr1) ;

  filenameOutput := extractFileName(filenameOutput);

  if FileExists(directoryOutput+filenameOutput) then
  begin
       writeln('The output file: "' + filenameOutput + '" exists ') ;
       write('Do you want to overwrite this file? ') ;
       readln(inputYN) ;
       if uppercase(copy(inputYN,1,1)) = 'Y' then
       begin
          AssignFile(resetFileF,directoryOutput+filenameOutput) ;
          Erase(resetFileF);
//          CloseFile(resetFileF) ;
       end
       else
       begin
           result := lineNum+1 ;
           exit ;
       end
  end;

  totalNumRows := 0 ;
  firstCall    := true ;
  tSR1         := TSpectraRanges.Create(4,0,0) ;
  tSR2         := TSpectraRanges.Create(4,0,0) ;

  try
    tSTRLST := TStringList.Create ;
    if  (recurseBool = true) then
    begin
      if (findfirst( directoryPWD + '*',faDirectory,DirInfo)=0) then
      begin
        if (DirInfo.Name = '.') then
          findnext(DirInfo)  ;
        while (findnext(DirInfo)=0) do
        begin
          writeln('Directory found: '+ DirInfo.Name) ;
          // this is list of all 1st level sub-directories
          tSTRLST.Add(directoryPWDOrig + DirInfo.Name + DIRSLASH)
         end;
      findclose(DirInfo) ;
      end;
    end
    else
    tSTRLST.Add(directoryPWDOrig) ;  // this is the current directory


 for t1 := 0 to tSTRLST.Count - 1 do
 begin
    directoryPWD := tSTRLST.Strings[t1]  ;
    if (findfirst( directoryPWD + '*' + fileExt,faAnyFile,FileInfo)=0) then
    begin
      writeln('File found: '+ FileInfo.Name) ;
      if firstCall then
      begin
        tSR1.LoadSpectraRangeDataBinV2(directoryPWD+FileInfo.Name);
        firstNumCols := tSR1.xCoord.numCols ;
        totalNumRows := totalNumRows + tSR1.yCoord.numRows ;
        tSR1.yCoord.SaveMatrixDataRaw(directoryOutput+filenameOutput);
        tSR1.srFileStrm := TFileStream.Create(directoryOutput+filenameOutput,fmOpenReadWrite ) ;
        tSR1.srFileStrm.CopyFrom(tSR1.yCoord.F_Mdata ,0)  ;
        tSR1.yCoord.F_Mdata.Free ;   // free the memory
        tSR1.yCoord.F_Mdata := TMemoryStream.Create ; // recreate the object as it is destroyed lateter again
        firstCall := false ;
      end
      else
      begin
         tSR2.LoadSpectraRangeDataBinV2(directoryPWD+FileInfo.Name);
         totalNumRows := totalNumRows + tSR2.yCoord.numRows ;
         tSR1.srFileStrm.CopyFrom(tSR2.yCoord.F_Mdata,0)   ;
         tSR2.Free ;
         tSR2 := TSpectraRanges.Create(4,0,0) ;
      end ;

    while (findnext(FileInfo)=0) do   // loop through files in PWD
    begin
      writeln('File found: '+ FileInfo.Name) ;
      tSR2.LoadSpectraRangeDataBinV2(directoryPWD+FileInfo.Name);
      if firstNumCols <> tSR1.xCoord.numCols then
      begin
         writeln('Error: File has non matching number of columns. Can not concatenate.') ;
         exit ;
      end;
      totalNumRows := totalNumRows + tSR2.yCoord.numRows ;
      tSR1.srFileStrm.CopyFrom(tSR2.yCoord.F_Mdata,0)   ;
      tSR2.Free ;
      tSR2 := TSpectraRanges.Create(4,0,0) ;
    end;
    findclose(FileInfo) ;
  end; // for loop through directories
  end ;

    writeln('Total rows written to file:' + inttostr(totalNumRows)) ;
    tSR1.addBinFileEndingToTFileStrm(tSR1.xCoord.SDPrec,totalNumRows,firstNumCols) ;
    tSR1.srFileStrm.Free ;

  finally
    tSR1.Free ;
    tSR2.Free ;
    tSTRLST.Free ;
    result := lineNum+1 ;
  end;
end;




var
   lineNum : integer ;
   lineNumStr : string ;
   t1, iter : integer ;

   tStrList : TStringList ;
   tstr1  : string ;

   // variables for batch processing
   tPCA   : TPCABatch ;
   tPLS   : TPLSYPredictBatch ;
   tPCR   : TPCRYPredictBatch ;
   tYPredict : TPLSYPredictTestBatch ;
   tILS   :  TPCalBatch ;

   tSR_x, tSR_y, tSR_recoef : TSpectraRanges ;
   bB : TBatchBasics ;

   tTimer : TASMTimer ;

begin
   try

     // determines user input or availabilituy of "analysis.bat" file
     // and if none present then asks user to create one
     tStrList :=  StartupInterface ;
     if tStrList = nil then
     exit ;

     bB  := TBatchBasics.Create ;
     tTimer := TASMTimer.Create(0) ;

     lineNumStr := '' ;
     iter := 0 ;
     lineNum := 0 ;

     while lineNum <=  tStrList.Count-1 do   // Iterate through every line in the memo text
     begin
       inc(iter) ;  // used for code error messages
       tstr1 := bB.GetStringFromStrList(tStrList, lineNum) ;
       trim(tstr1) ;

       while tstr1 = '' do  // ignore empty strings
       begin
         inc(lineNum) ;
         if lineNum >= tStrList.Count then
           exit ;
         tstr1 := tStrList.Strings[lineNum] ;
       end ;

//       initialLineNum := lineNum ;

       if bB.LeftSideOfEqual(tstr1) = 'type' then
       begin

          if (bB.RightSideOfEqual(tstr1) = 'pcr') then
          begin
             try
              // Create PCR batch file processing object
write('Creating tPCR object: ') ;
              tPCR := TPCRYPredictBatch.Create(4) ;   // this has to be released on deletion of row or close of appliction
writeln('successful') ;
              // get all the batch arguments from tStrList
write('Getting batch file arguments: ') ;
              lineNumStr := tPCR.GetBatchArguments(lineNum, iter, tStrList) ;
              if pos(',',lineNumStr) > 0 then
              begin
                 tPCR.Free ;
                 exit ;
              end
              else
              lineNum := strtoint( lineNumStr ) ;
writeln('Got batch arguments') ;

write('Creating x and y data memory storage: ') ;
              tSR_x :=  TSpectraRanges.Create(sizeof(single),0,0);
              tSR_y :=  TSpectraRanges.Create(sizeof(single),0,0);
writeln('created') ;

writeln('loading x data to memory: '+ tPCR.xFilename) ;
              tSR_x.LoadSpectraRangeDataBinV2(tPCR.xFilename);
writeln('x data loaded to memory: '+ tPCR.xFilename) ;
              if tPCR.YinXData = true then
                tSR_y := tSR_x
              else
	      begin
writeln('loading y data to memory: '+ tPCR.yFilename) ;
                tSR_y.LoadSpectraRangeDataBinV2(tPCR.yFilename);
	      end ;	
	

              // This gets the data from the X an Y data column spectra and does all the processing of the batch file
              // and creation of a model with desired number of PCs included
writeln('Creating a timer: ') ;
	      tTimer.setTimeDifSecUpdateT1 ;
writeln('Calculated CPU speed:' + floattostrf(tTimer.returnCPUSpeedGHz,ffGeneral,5,4) + ' GHz') ;
              tStr1 := tPCR.ProcessPCRBatchFile(tSR_x,tSR_y) ;
              if  length(tStr1 ) > 0 then
              begin
writeln('Function ProcessPCRBatchFile() failed. Line :'+inttostr(lineNum) + ' Error: '+ tStr1 ) ;
                 tPCR.Free ;
                 exit ;
              end ;
              t1 := pos('.', tPCR.resultsFileName)-1 ;
              tPCR.SaveSpectra( copy(tPCR.resultsFileName,1,t1) );
              tTimer.setTimeDifSec ;
writeln('processing time: ' + floattostrf(tTimer.getRecordedTime,ffGeneral,5,4)) ;

              // *** THESE ARE THE RESULTS  ***
              // Free the memory
              tPCR.free  ;
 //             tSR_x.Free ;  is freed during tPCR.GetAllXData()
//              if tPCR.YinXData = false then
//                tSR_y.Free ;
writeln('PCR completed ') ;
             // readln(inputNum) ;
            except
            begin
writeln('-----') ;
writeln('PCR code encountered a problem.') ;
              // Free the memory
//              tSR_x.Free ;
//              tSR_y.Free ;
              tPCR.free
            end;
            end ;
          end
          else if  (bB.RightSideOfEqual(tstr1) = 'pls1') then
          begin
            try
              // This is the X data (Y data is specified in batch file as "YinXData = true" or "YinXData = false"
        //      tSR  ;

write('Creating tPLS1 object') ;
              // Create PLS batch file processing object
              tPLS := TPLSYPredictBatch.Create(4) ;   // this has to be released on deletion of row or close of appliction
writeln('successful') ;
write('Getting batch file arguments: ') ;
              lineNumStr := tPLS.GetBatchArguments(lineNum, iter, tStrList) ;
              if pos(',',lineNumStr) > 0 then
              begin
                 tPLS.Free ;
                 exit ;
              end
              else
              lineNum := strtoint( lineNumStr ) ;
writeln('successful') ;
write('Creating x and y data memory storage: ') ;
              tSR_x :=  TSpectraRanges.Create(sizeof(single),0,0);
              tSR_y :=  TSpectraRanges.Create(sizeof(single),0,0);
writeln('successful') ;
write('loading x data to memory ('+ extractfilename(tPLS.xFilename)+'): ') ;
              tSR_x.LoadSpectraRangeDataBinV2(tPLS.xFilename);
writeln('successful') ;
write('loading y data to memory('+ extractfilename(tPLS.yFilename)+'): ') ;
              if tPLS.YinXData = true then
                tSR_y := tSR_x
              else
                tSR_y.LoadSpectraRangeDataBinV2(tPLS.yFilename);
writeln('successful') ;

              // This gets the data from the X an Y data column spectra and does all the processing of the batch file
              // and creation of a model with desired number of PCs included
              tTimer.setTimeDifSecUpdateT1 ;
writeln('Processing data: ') ;
              tStr1 := tPLS.ProcessPLSBatchFile(tSR_x,tSR_y) ;
              if  length(tStr1 ) > 0 then
              begin
                 writeln('-----') ;
                 writeln('Function ProcessPLSBatchFile() failed. Line :'+inttostr(lineNum) + ' Error: '+ tStr1 ) ;
//                 tSR_x.Free ;
//                 tSR_y.Free ;
                 tPLS.Free ;
                 exit ;
              end ;
              tTimer.setTimeDifSec ;
              // *** THESE ARE THE RESULTS  ***  Graph and add to stringgrid1
              tPLS.SaveSpectra( copy(tPLS.resultsFileName,1,t1) );
writeln('processing time: ' + floattostrf(tTimer.getRecordedTime,ffGeneral,5,4)) ;
writeln('PLS1 completed ') ;
              tPLS.free ;

            except
writeln('-----') ;
writeln('PLS1 code encountered a problem') ;
              tPLS.free ;
            end ;
          end
          else if  (bB.RightSideOfEqual(tstr1) = 'predict y') then
          begin
             try
               // This is the X data (Y data is specified in batch file as "YinXData = true" or "YinXData = false

               // Create PLS batch file processing object
               tYPredict := TPLSYPredictTestBatch.Create(4) ;   // this has to be released on deletion of row or close of appliction

               lineNumStr := tYPredict.GetBatchArguments(lineNum, iter, tStrList) ;
               if pos(',',lineNumStr) > 0 then
               begin
                 tYPredict.Free ;
                 exit ;
               end
               else
               lineNum := strtoint( lineNumStr ) ;

              tSR_x :=  TSpectraRanges.Create(sizeof(single),0,0);
              tSR_y :=  TSpectraRanges.Create(sizeof(single),0,0);
              tSR_recoef :=  TSpectraRanges.Create(sizeof(single),0,0);

              tSR_x.LoadSpectraRangeDataBinV2(tYPredict.xFilename);
              if tYPredict.YinXData = true then
                tSR_y := tSR_x
              else
                tSR_y.LoadSpectraRangeDataBinV2(tYPredict.yFilename);

              tSR_recoef.LoadSpectraRangeDataBinV2(tYPredict.regresCoefFilename);


               // This gets the data from the X an Y data column spectra and does all the processing of the batch file
               // and creation of a model with desired number of PCs included
               tTimer.setTimeDifSecUpdateT1 ;
               tStr1 := tYPredict.TestModelData(tSR_x,tSR_y, tSR_recoef) ; // this does the processing
               if  length(tStr1 ) > 0 then
               begin
                 writeln('Function TestModelData() failed. Line :'+inttostr(lineNum) + ' Error: '+ tStr1 ) ;
                 tYPredict.Free ;
                 tSR_x.Free ;
                 tSR_y.Free ;
                 tSR_recoef.Free ;
                 exit ;
               end ;
               tTimer.setTimeDifSec ;
               writeln('processing time: ' + floattostrf(tTimer.getRecordedTime,ffGeneral,5,4)) ;


               tYPredict.Free ;
               tSR_x.Free ;
               tSR_y.Free ;
               tSR_recoef.Free ;
             except
             begin
               writeln( 'Predict Y data code encountered a problem') ;
               tYPredict.Free ;
               tSR_x.Free ;
               tSR_y.Free ;
               tSR_recoef.Free ;
             end ;
             end ;
          end
          else if  (bB.RightSideOfEqual(tstr1) = 'pca') then
          begin

              tPCA := TPCABatch.Create(4) ;   // this has to be released on deletion of row or close of appliction

              // read in batch arguments
              lineNumStr := tPCA.GetPCABatchArguments(lineNum, iter, tStrList) ;
              if pos(',',lineNumStr) > 0 then
              begin
                 tPCA.Free ;
                 exit ;
              end
              else
              lineNum := strtoint( lineNumStr ) ;

              // get the data from file
              tSR_x.LoadSpectraRangeDataBinV2(tPCA.xFilename );

              // select data from file
              if not tPCA.GetAllXData( tSR_x ) then
              begin
                 tPCA.Free ;
                 tSR_x.Free ;
                 writeln('Function tPCA.GetAllXData() failed.') ;
                 exit ;
              end ;

              tTimer.setTimeDifSecUpdateT1 ;
              if  (tPCA.ProcessPCAData = false) then
              begin
                 tPCA.Free ;
                 tSR_x.Free ;
                 writeln('Function tPCA.ProcessPCAData() failed.') ;
                 exit ;
              end ;
              tTimer.setTimeDifSec ;
              writeln(ExtractFileName(tPCA.allXData.XCoord.Filename) );
              writeln('//processing time: ' + floattostrf(tTimer.getRecordedTime,ffGeneral,5,4) + ' / ' + floattostrf(tTimer.returnCPUSpeedGHz,ffGeneral,5,4) + 'GHz') ;


              tPCA.Free ;
              tSR_x.Free ;
          end
          else if  (bB.RightSideOfEqual(tstr1) = 'concat') then
          begin  // DirInfo
               writeln('concatenate files') ;

               lineNum := FunctionConcat(tStrList,lineNum,bb) ;

          end
          else
          if (bB.RightSideOfEqual(tstr1) = 'ils') then   // inverse least squares
          begin
             try
              // Create PCR batch file processing object
write('Creating tILS object: ') ;
              tILS := TPCalBatch.Create(4) ;   // this has to be released on deletion of row or close of appliction
writeln('successful') ;
              // get all the batch arguments from tStrList
write('Getting batch file arguments: ') ;
              lineNumStr :=  tILS.GetBatchArguments(lineNum, iter, tStrList) ;
              if pos(',',lineNumStr) > 0 then
              begin
                  tILS.Free ;
                 exit ;
              end
              else
              lineNum := strtoint( lineNumStr ) ;
writeln('Got batch arguments') ;

write('Creating x and y data memory storage: ') ;
              tSR_x :=  TSpectraRanges.Create(sizeof(single),0,0);
              tSR_y :=  TSpectraRanges.Create(sizeof(single),0,0);
              tSR_recoef  :=  TSpectraRanges.Create(sizeof(single),0,0);
writeln('created') ;


              if tILS.xFilename <> '' then
              begin
write('loading x data to memory: '+ tILS.xFilename) ;
                 if FileExists(tILS.xFilename) then
                  tSR_x.LoadSpectraRangeDataBinV2(tILS.xFilename)
                else
                begin
                   writeln('Error: File does not exist - '+ tILS.xFilename) ;
                   exit ;
                end;
writeln(' : done') ;
              end;

write('loading y data to memory: '+ tILS.yFilename) ;
              if (tILS.YinXData = true) and (tILS.xFilename <> '') then
                tSR_y := tSR_x
              else
	            begin
                if FileExists(tILS.yFilename) then
                  tSR_y.LoadSpectraRangeDataBinV2(tILS.yFilename)
                else
                begin
                   writeln('Error: File does not exist - '+ tILS.yFilename) ;
                   exit ;
                end;
	            end ;
writeln(' : done') ;
writeln('loading ILS data into memory: '+ tILS.ScoresOrEvectsFileName) ;
              if FileExists(tILS.ScoresOrEvectsFileName) then
                tSR_recoef.LoadSpectraRangeDataBinV2(tILS.ScoresOrEvectsFileName)
              else
              begin
                writeln('Error: File does not exist - '+ tILS.ScoresOrEvectsFileName) ;
                exit ;
              end;


              // This gets the data from the X an Y data column spectra and does all the processing of the batch file
              // and creation of a model with desired number of PCs included
write('Creating a timer:  ') ;
	            tTimer.setTimeDifSecUpdateT1 ;
writeln('created ') ;
writeln('Processing ILS data.....  ') ;
              if FileExists(tILS.xFilename) then
                tStr1 := tILS.ProcessPCRBatchFile(tSR_x,tSR_y,tSR_recoef)
              else
                tStr1 := tILS.ProcessPCRBatchFile(nil,tSR_y,tSR_recoef)  ;
              if  length(tStr1 ) > 0 then
              begin
writeln('Error: ILS calculation '+ tStr1 ) ;
                 tILS.Free ;
                 exit ;
              end ;
              t1 := pos('.',  tILS.resultsFileName)-1 ;
              tILS.SaveSpectra( copy( tILS.resultsFileName,1,t1) );
              tTimer.setTimeDifSec ;
writeln('processing time: ' + floattostrf(tTimer.getRecordedTime,ffGeneral,5,4)) ;

              // *** THESE ARE THE RESULTS  ***
              // Free the memory
              tILS.free  ;
 //             tSR_x.Free ;  is freed during tPCR.GetAllXData()
//              if tPCR.YinXData = false then
//                tSR_y.Free ;
writeln('ILS completed ') ;
             // readln(inputNum) ;
            except
            begin
writeln('-----') ;
writeln('ILS code encountered a problem.') ;
              // Free the memory
//              tSR_x.Free ;
//              tSR_y.Free ;
              tPCR.free
            end;
            end ;
          end




       else  // the text is not recognised as any particular directive
       begin
          lineNum := lineNum + 1 ;
       end ;
     end ;
     end;
  finally
   write('mva exiting. Press enter to continue ') ;
   readln(lineNumStr) ;
   tTimer.Free ;
   bB.Free ;
   tStrList.Free ;
  end ;


  { TODO -oUser -cConsole Main : Insert code here }
end.

