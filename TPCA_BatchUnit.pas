unit TPCA_BatchUnit;
//{$define FREEPASCAL=1}
{$ifdef FREEPASCAL}
{$mode delphi}
{$endif}
interface

uses
  SysUtils, Classes,   TPCA_ResultsObject, TMatrixObject, TSpectraRangeObject,
  TBatchBasicFunctions ;



type
  TPCABatch  = class
  public

     numPCsPCA : integer ;
     PCsString : string;
     xFilename : string ; // used in command line version
     XsampleRange : string ;  //  not needed in IR-pol
     xVarRange : string ; // variable range or filled in by ConvertValueStringToPosString()
     xVarRangeIsPositon : boolean ;
     // input data is identical to XData desired therfore do not copy, just point to input data
     xDiskEQxData : boolean ;
     autoExclude : single;     // used in IR-pol analysis but not PCA as yet.
     excludePCsStr : string;   // used in IR-pol analysis but not PCA as yet.

     normalisedEVects, meanCentre, colStd : boolean ;


     resultsFileName : string;

     // not used:
     flipRange : string ; // section of e-vector of interest. if  flipRange = '' then do not do test
     positive : boolean ; // if true then area of e-vect should be positive else area should be negative. Flip if not true.

     bB : TBatchBasics ;  // functions like : LeftSideOfEqual() etc

     allXData            :  TSpectraRanges ;     // for display in column #2
     scoresSpectra       :  TSpectraRanges ;     //  for display in column #4. Created in ProcessPCAData() or ProcessIRPolData() functions as need to get sizes from input data
     eigenVSpectra       :  TSpectraRanges ;     // for display in column #5. Created in ProcessPCAData() or ProcessIRPolData() functions
     eigenValSpectra     :  TSpectraRanges ;        // this is inherited // for display in column #


     tPCAnalysis : TPCA ;
     
     constructor Create(SDPrec : integer) ;
     destructor  Destroy; // override;
     procedure   Free;


     function  GetPCABatchArguments(lineNum, iter : integer; tStrList : TStringList ) : string ; // get input data from memo1 text. Returns final line number of String list
     function  GetAllXData( sourceSpecRange : TSpectraRanges ) : string   ; // TBatch virtual method
     function  ProcessPCAData(inputX : TSpectraRanges) : string ;
     function  DetermineNumPCs : string ;
     function  CreatePCADisplayData  : string   ;
     procedure SaveSpectra(filenameIn : string)  ;

  private
end;



implementation


constructor TPCABatch.Create(SDPrec : integer) ;
begin
  tPCAnalysis := TPCA.Create(SDPrec) ;
  bB := TBatchBasics.Create ;
end ;


destructor  TPCABatch.Destroy; // override;
begin
  tPCAnalysis.Free ;

  if scoresSpectra      <> nil then  scoresSpectra.Free ;
  if eigenVSpectra      <> nil then  eigenVSpectra.Free ;
  if eigenValSpectra    <> nil then  eigenValSpectra.Free ;

  bb.free ;
end ;


procedure TPCABatch.Free;
begin
 if Self <> nil then Destroy;
end;



function  TPCABatch.GetPCABatchArguments(lineNum, iter : integer; tStrList : TStringList ) : string ; // get input data from memo1 text. Returns final line number of String list
// if result has a comma then input has failed, and return value is message stating line number of batch file of problem.
var
   tstr1  : string ;

{File input is of this format:
   Memo1.Lines.Add('type = PCA') ;
   Memo1.Lines.Add('x data file =    ') ;
   Memo1.Lines.Add('sample range = 1-') ;
   Memo1.Lines.Add('x var range = 1-') ;
   Memo1.Lines.Add('number of PCs = 1-6') ;
   Memo1.Lines.Add('start row = 1') ;
   Memo1.Lines.Add('pos or neg range = 1200-1260 cm-1  // can be variable number or value found in x coordinate (space essential) ') ;
   Memo1.Lines.Add('positive or negative = negative') ;
   Memo1.Lines.Add('autoexclude = 0.0') ;
   Memo1.Lines.Add('exclude from PCs = 0') ;

   BatchMemo1.Lines.Add('normalise to peak = area  // or height, leave blank for none') ;
   BatchMemo1.Lines.Add('peak =  1620-1660 cm-1') ;

   Memo1.Lines.Add('mean centre = true') ;  //
   Memo1.Lines.Add('column standardise = false') ;  //
   Memo1.Lines.Add('normalised output = true') ;
   Memo1.Lines.Add('results file = output_filename.out') ;
}
begin
   //messagedlg('the analysis type is: ' + lowerCase(trim(copy(tstr1,pos('=',tstr1)+1,length(tstr1)-length(copy(tstr1,1,pos('=',tstr1)))))) ,mtinformation,[mbOK],0) ;

             // **********************  load data file into TRegression object ******************************************
            { inc(lineNum) ;
             "filename"   has been removed
             tstr1 := tStrList.Strings[lineNum] ;   // should be 'data file = xxxxxxx', where xxxxxxx = data loaded OR xxxxxxx = c:\...\filename.ext
             tFilename := trim(copy(tstr1,pos('=',tstr1)+1,length(tstr1)-length(copy(tstr1,1,pos('=',tstr1))))) ;
              }
           try

             // ********************** X data file name ******************************************
             repeat
               inc(lineNum) ;
               tstr1 := bB.GetStringFromStrList(tStrList, lineNum) ;
             until (trim(tstr1) <> '') or (linenum > tStrList.Count)  ;
             if bB.LeftSideOfEqual(tstr1) = 'x data file' then
               xFilename :=  bB.RightSideOfEqual(tstr1) ;

             // ********************** Samples ******************************************
             repeat
               inc(lineNum) ;
               tstr1 := bB.GetStringFromStrList(tStrList, lineNum) ;
             until (trim(tstr1) <> '') or (linenum > tStrList.Count)  ;
             if bB.LeftSideOfEqual(tstr1) = 'sample range' then
               XsampleRange :=  bB.RightSideOfEqual(tstr1) ;

             // ********************** Variables  ******************************************
             repeat
               inc(lineNum) ;
               tstr1 := bB.GetStringFromStrList(tStrList, lineNum) ;
             until (trim(tstr1) <> '') or (linenum > tStrList.Count)  ;
             if bB.LeftSideOfEqual(tstr1) = 'x var range' then
               xVarRange :=  bB.RightSideOfEqual(tstr1) ;  //  = 800-1800 cm-1

             if pos(' ',trim(xVarRange)) > 0 then
                xVarRangeIsPositon := false
              else
                xVarRangeIsPositon := true ;

              // ********************** number of PCs ******************************************
             repeat
               inc(lineNum) ;
               tstr1 := bB.GetStringFromStrList(tStrList, lineNum) ;
             until (trim(tstr1) <> '') or (linenum > tStrList.Count)  ;
             if bB.LeftSideOfEqual(tstr1) = 'number of pcs' then
               PCsString :=  bB.RightSideOfEqual(tstr1) ;


              // ********************** pos or neg range = 1200-1260 cm-1 ******************************************
             repeat
               inc(lineNum) ;
               tstr1 := bB.GetStringFromStrList(tStrList, lineNum) ;
             until (trim(tstr1) <> '') or (linenum > tStrList.Count)  ;
             if bB.LeftSideOfEqual(tstr1) = 'pos or neg range' then
                 flipRange :=  bB.RightSideOfEqual(tstr1) ;

              // **********************  positive or negative ******************************************
             repeat
               inc(lineNum) ;
               tstr1 := bB.GetStringFromStrList(tStrList, lineNum) ;
             until (trim(tstr1) <> '') or (linenum > tStrList.Count)  ;
             if bB.LeftSideOfEqual(tstr1) = 'positive or negative' then
               if bB.RightSideOfEqual(tstr1) = 'positive'  then
                   positive := true
                else
                   positive :=  false ;



             // ********************** Auto exclude outliers - proportion of deviation ******************************************
             repeat
               inc(lineNum) ;
               tstr1 := bB.GetStringFromStrList(tStrList, lineNum) ;
             until (trim(tstr1) <> '') or (linenum > tStrList.Count)  ;
             if bB.LeftSideOfEqual(tstr1) = 'autoexclude' then
               autoExclude :=  strtofloat(bB.RightSideOfEqual(tstr1)) ;  //
             // ********************** exclude from PCs ******************************************
             repeat
               inc(lineNum) ;
               tstr1 := bB.GetStringFromStrList(tStrList, lineNum) ;
             until (trim(tstr1) <> '') or (linenum > tStrList.Count)  ;
             if bB.LeftSideOfEqual(tstr1) = 'exclude from pcs' then
               excludePCsStr := bB. RightSideOfEqual(tstr1) ;  // so, if an outlier exists in any of these PCs, then the spectra are excluded and the PCA redone.


        {     // ********************** normalise to peak ******************************************
             //  BatchMemo1.Lines.Add('normalise to peak = area  // or height, leave blank for none') ;
             repeat
               inc(lineNum) ;
               tstr1 := bB.GetStringFromStrList(tStrList, lineNum) ;
             until (trim(tstr1) <> '') or (linenum > tStrList.Count)  ;
             if bB.LeftSideOfEqual(tstr1) = 'normalise to peak' then
             begin



               //   BatchMemo1.Lines.Add('peak =  1620-1660 cm-1') ;
             end
             else
               dec(linenum) ;
          }


             // ********************** Mean Centre ******************************************
             repeat
               inc(lineNum) ;
               tstr1 := bB.GetStringFromStrList(tStrList, lineNum) ;
             until (trim(tstr1) <> '') or (linenum > tStrList.Count)  ;
             if bB.LeftSideOfEqual(tstr1) = 'mean centre' then
             begin
                if bB.RightSideOfEqual(tstr1) = 'true'  then
                   meanCentre := true
                else
                   meanCentre :=  false ;
             end ;
             // ********************** Column Centred ******************************************
             repeat
               inc(lineNum) ;
               tstr1 := bB.GetStringFromStrList(tStrList, lineNum) ;
             until (trim(tstr1) <> '') or (linenum > tStrList.Count)  ;
             if bB.LeftSideOfEqual(tstr1) = 'column standardise' then
                if bB.RightSideOfEqual(tstr1) = 'true'  then
                   colStd := true
                else
                   colStd :=  false ;

              // ********************** normalised output of scores and EVects ******************************************
             repeat
               inc(lineNum) ;
               tstr1 := bB.GetStringFromStrList(tStrList, lineNum) ;
             until (trim(tstr1) <> '') or (linenum > tStrList.Count)  ;
             if bB.LeftSideOfEqual(tstr1) = 'normalised output' then
                if bB.RightSideOfEqual(tstr1) = 'true'  then
                   normalisedEVects := true
                else
                   normalisedEVects :=  false ;
             // ********************** Get output filename 'resultsFile' ******************************************
             repeat
               inc(lineNum) ;
               tstr1 := bB.GetStringFromStrList(tStrList, lineNum) ;
             until (trim(tstr1) <> '') or (linenum > tStrList.Count)  ;
             if bB.LeftSideOfEqual(tstr1) = 'results file' then
               resultsFileName :=  bB.RightSideOfEqual(tstr1) ;

             repeat
               inc(lineNum) ;
               tstr1 := bB.GetStringFromStrList(tStrList, lineNum) ;
             until (trim(tstr1) <> '') or (lineNum>=tStrList.Count)  ;

             result := inttostr(lineNum) ;  // if result has a comma then input has failed
         except on eConvertError do
         begin
           result := inttostr(lineNum) + ', PCA batch input conversion error' + #13 ;
         end ;
         end ;


end ;



function TPCABatch.GetAllXData( sourceSpecRange : TSpectraRanges ) : string ;
var
  t2 : integer ;
  t1 : integer ;
  s1 : single ;
  d1 : double ;
begin
  result := '' ;
  try

  if xVarRangeIsPositon = false then
  begin
      // conversts from some form of units to the position in along the x-direction set
      self.xVarRange :=  bB.ConvertValueStringToPosString(xVarRange, sourceSpecRange.xCoord) ;
      if  self.xVarRange = '' then
      begin
        result := 'x var range values not appropriate:' ;
        exit ;
      end ;
  end ;

  // *****************   Get the y data of TSpectraRanges object *****************
  if pos('-',XsampleRange) = length(trim(XsampleRange)) then       // sampleRange string is open ended (e.g. '12-')
    XsampleRange := XsampleRange + inttostr(sourceSpecRange.yCoord.numRows) ;


  // if the data is exactly as recieved in sourceSpecRange then do not copy (saves memory)
  if (sourceSpecRange.yCoord.numRows = sourceSpecRange.yCoord.GetTotalRowsColsFromString(XsampleRange)) and (sourceSpecRange.yCoord.numCols = sourceSpecRange.yCoord.GetTotalRowsColsFromString(xVarRange))then
  begin
    if allXData <> nil then  allXData.Free ;
    allXData := sourceSpecRange ;
    xDiskEQxData := true ;
    exit ;
  end;

  // othersise, extract data from the matrix
  allXData := TSpectraRanges.Create(sourceSpecRange.yCoord.SDPrec,0,0) ;
  // *****************  This actually retrieves the data  ********************
  allXData.yCoord.FetchDataFromTMatrix( XsampleRange, xVarRange , sourceSpecRange.yCoord ) ;
  if sourceSpecRange.yImaginary <> nil then
  begin
    allXData.yImaginary := TMatrix.Create(allXData.yCoord.SDPrec) ;
    allXData.yImaginary.FetchDataFromTMatrix( XsampleRange, xVarRange , sourceSpecRange.yImaginary ) ;
  end ;


  // *****************   Get the x data of TSpectraRanges object - X data can be disjoint (it just will display disjoint) *****************
  allXData.xString := sourceSpecRange.xString ;
  allXData.yString := sourceSpecRange.yString ;
  allXData.xCoord.numCols :=  allXData.yCoord.numCols ;
  allXData.xCoord.numRows := 1 ;
  allXData.xCoord.Filename := resultsFileName ;
  allXData.xCoord.F_Mdata.SetSize(allXData.xCoord.numCols * 1 * allXData.xCoord.SDPrec) ;
  allXData.xCoord.F_Mdata.Seek(0,soFromBeginning) ;
  // COPY X DATA VALUES FROM INPUT TSPECTRARANGES TO NEW TSPECTRARANGE in new row
  t2 := allXData.xCoord.GetTotalRowsColsFromString(xVarRange, allXData.xCoord.Fcols) ;
  allXData.xCoord.Fcols.Seek(0,soFromBeginning) ;
  for t1 := 1 to allXData.xCoord.numCols do
  begin
     allXData.xCoord.Fcols.Read(t2,4) ;
     sourceSpecRange.xCoord.F_Mdata.Seek(t2*sourceSpecRange.xCoord.SDPrec,soFromBeginning) ;
     if sourceSpecRange.xCoord.SDPrec = 4 then
     begin
        sourceSpecRange.xCoord.F_Mdata.Read(s1, 4) ;
        allXData.xCoord.F_Mdata.Write(s1,4) ;
     end
     else
     if sourceSpecRange.xCoord.SDPrec = 8 then
     begin
        sourceSpecRange.xCoord.F_Mdata.Read(d1, 8) ;
        allXData.xCoord.F_Mdata.Write(d1,8) ;
     end ;
  end ;


  except
    begin
        result := ' Fetching X data failed'  + #13 ;
    end ;

  end ;
end ;




function  TPCABatch.DetermineNumPCs : string ;
var
  t1 : integer ;
  pcsToFitMemStrm : TMemoryStream ;
begin
  try
    result := '' ;
    pcsToFitMemStrm := TMemoryStream.Create ;
    t1 := allXData.yCoord.GetTotalRowsColsFromString(PCsString, pcsToFitMemStrm) ; // number of PCs to fit

    pcsToFitMemStrm.Seek(-4,soFromEnd) ;
    pcsToFitMemStrm.Read(numPCsPCA,4) ; // read final number in range (don't use t1 as it is number in set, not the maximum PC needed)
    numPCsPCA := numPCsPCA + 1 ;        // add one because the numbers returned are zero based
    if numPCsPCA > allXData.yCoord.numRows then
    begin
      result :=  'Have to exit batch process, number of PCs wanted is greater than number of spectra'  ;
      pcsToFitMemStrm.free ;
      exit ;
    end ;
  except on Exception do
  begin
    pcsToFitMemStrm.free ;
    result := 'determining number of PCs for PLS analysis failed' + #13 ;
  end ;
  end ;
  pcsToFitMemStrm.free ;
end ;




function  TPCABatch.ProcessPCAData(inputX : TSpectraRanges) : string ;
var
  t1 : integer ;
begin
  try
    result :=  '' ;
    result :=  GetAllXData( inputX ) ;  //
    if (xDiskEQxData  = false) then  // input (disk) file and matrix data are identical so do not delete
       inputX.Free ;

    result := result + DetermineNumPCs ;
    if  length(result) > 0 then
     begin
       writeln('ProcessPCAData failed:' + #13 + result ) ;
       exit ;
     end ;


    // ************** do PCA on X matrix, leaves residuals only ***********************************
    if allXData.yImaginary = nil then
    begin
        tPCAnalysis.PCA(allXData.yCoord , numPCsPCA, meanCentre, colStd) ;
    end
    else  // data is complex
    begin
       // load data into X matrix
        allXData.yCoord.MakeComplex(allXData.yImaginary);  // if not allready complex, then make complex (interleaved)
        tPCAnalysis.PCAcomplex(allXData.yCoord, numPCsPCA, meanCentre, colStd) ;
    end ;

  except
    // exception in code => failure of function: result = false ;
    result := 'Exception in ProcessPCAData: ' + result ;
  end ;

  self.CreatePCADisplayData ;
  allXData.Free ; // this will remove inputX.Free if "xDiskEQxData = true"
end ;


procedure TPCABatch.SaveSpectra(filenameIn : string)  ;
var
 t1 : integer ;
begin
    t1 := pos('.', filenameIn)-1 ;
    filenameIn := copy(filenameIn,1,t1) ;

    writeln('Saving PCA data: ') ;
    scoresSpectra.SaveSpectraRangeDataBinV2(filenameIn+'_scoresPCA.bin') ;
    writeln(filenameIn+'_scoresPCA.bin') ;
    eigenVSpectra.SaveSpectraRangeDataBinV2(filenameIn+'_eigenVectPCA.bin') ;
    writeln(filenameIn+'_eigenVectPCA.bin') ;
    eigenValSpectra.SaveSpectraRangeDataBinV2(filenameIn+'_eigenValPCA.bin') ;
    writeln(filenameIn+'_eigenValPCA.bin') ;
end ;




function TPCABatch.CreatePCADisplayData  : string   ;
var
  t1 : integer ;
  s1 : single ;
  d1 : double ;
begin
  try

       // 1/ ****  Create display objects for calculated data ****
    scoresSpectra    := TSpectraRanges.Create(self.allXData.yCoord.SDPrec, allXData.yCoord.numRows, numPCsPCA )  ; // x2 due to scores & fit data being included
    eigenVSpectra    := TSpectraRanges.Create(self.allXData.yCoord.SDPrec, numPCsPCA                 , allXData.yCoord.numCols)  ;
    eigenValSpectra  := TSpectraRanges.Create(self.allXData.yCoord.SDPrec, 1                      , numPcsPCA )  ;

    // 2/ ****  Copy calculated data to output display objects ****
    if normalisedEVects then
    begin
//      scoresSpectra.yCoord.CopyMatrix( tPCAnalysis.ScoresNormalised ) ;
//      eigenVSpectra.yCoord.CopyMatrix( tPCAnalysis.EVectNormalsied ) ;
    end
    else  // not normalisedEVects
    begin
      scoresSpectra.yCoord.CopyMatrix( tPCAnalysis.Scores ) ;
      eigenVSpectra.yCoord.CopyMatrix( tPCAnalysis.EVects ) ;
    end ;

    eigenValSpectra.yCoord.CopyMatrix( tPCAnalysis.EigenValues ) ;


    if eigenVSpectra.yCoord.complexMat = 2 then
    begin
         scoresSpectra.yImaginary := TMatrix.Create2(scoresSpectra.yCoord.SDPrec, scoresSpectra.yCoord.numRows, scoresSpectra.yCoord.numCols ) ;
         scoresSpectra.yCoord.MakeUnComplex( scoresSpectra.yImaginary ) ;
         eigenVSpectra.yImaginary := TMatrix.Create2(eigenVSpectra.yCoord.SDPrec, eigenVSpectra.yCoord.numRows, eigenVSpectra.yCoord.numCols ) ;
         eigenVSpectra.yCoord.MakeUnComplex( eigenVSpectra.yImaginary ) ;
         eigenValSpectra.yImaginary := TMatrix.Create2(eigenValSpectra.yCoord.SDPrec, eigenValSpectra.yCoord.numRows, eigenValSpectra.yCoord.numCols) ;
         eigenValSpectra.yCoord.MakeUnComplex( eigenValSpectra.yImaginary ) ;
    end ;

    // 3/ ****  Create X data for output display objects  ****
    // A/ add 'sample number' to scores matrix (may be able to reference a 'string' value from this value in the future)
    scoresSpectra.xCoord.F_Mdata.Seek(0,soFromBeginning) ;
    for t1 := 1 to allXData.yCoord.numRows do
    begin
      s1 := t1 ;
      if self.allXData.yCoord.SDPrec = 4 then
      begin
        scoresSpectra.xCoord.F_Mdata.Write(s1,4) ;
      end
      else
      if self.allXData.yCoord.SDPrec = 8 then
      begin
        d1 := t1 ;
        scoresSpectra.xCoord.F_Mdata.Write(d1,8) ;
      end
    end ;
    // B/ add wavelength values as xCoord for EVects matrix storage
    allXData.SeekFromBeginning(3,1,0) ;
    eigenVSpectra.SeekFromBeginning(3,1,0) ;
    if self.allXData.xCoord.SDPrec = 4 then
    begin
      for t1 := 1 to allXData.yCoord.numCols do
      begin
        allXData.xCoord.F_Mdata.Read(s1,4) ;
        eigenVSpectra.xCoord.F_Mdata.Write(s1,4) ;
      end  ;
    end
    else
    if self.allXData.xCoord.SDPrec = 8 then
    begin
      for t1 := 1 to allXData.yCoord.numCols do
      begin
        allXData.xCoord.F_Mdata.Read(d1,8) ;
        eigenVSpectra.xCoord.F_Mdata.Write(d1,8) ;
      end  ;
    end ;
    // C/ create x coord data for eigenValSpectra (one point for each PC)
    eigenValSpectra.xCoord.F_Mdata.Seek(0,soFromBeginning) ;
    if self.allXData.yCoord.SDPrec = 4 then
    begin
       for t1 := 1 to self.numPCsPCA do
       begin
         s1 := t1 ;
         eigenValSpectra.xCoord.F_Mdata.Write(s1,4) ;
       end ;
    end
    else
    if self.allXData.yCoord.SDPrec = 8 then
    begin
      for t1 := 1 to self.numPCsPCA do
      begin
        d1 := t1 ;
        eigenValSpectra.xCoord.F_Mdata.Write(d1,8) ;
      end
    end ;

  except
    writeln('Exception in CreatePCADisplayData') ;

  end ;
end ;




end.

