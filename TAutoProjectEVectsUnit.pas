unit TAutoProjectEVectsUnit;

interface


uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  FileInfo{for access to StatusBar1}, PCAResultsObject, TMatrixObject,
  TSpectraRangeObject, BLASLAPACKfreePas, TBatch ;



type
  TAutoProjectEVects  = class(TBatchMVA)
  public
     numPCs : integer ;
     factorPCs  : string ;
     factorSampleRowStr, factorVarStr : string ;
     factorVarRangeIsPositon : boolean ;
     projFactorOnly : boolean ;

     factorSpectra : TSpectraRanges ;  // eqivalent to AllYData
     MinimisedPCs : TSpectraRanges ;   // this is the minimised Sum((PC1.y-PC2.y) - PCA(KBr).PC1.y)^2

     minimumSS_PCsvsFactor : single ; // goodness of fit data
     vectorPrefactor  : single ;      // scalar value to multiply PC2 by before addition to PC1


//     eigenValSpectra  :  TSpectraRanges ;  // this is inherited // for display in column #
//     residualsSpectra :  TSpectraRanges ;  // this is inherited // for display in column #. Created in ProcessPCAData()  function as need to get sizes from input data
//     regenSpectra     :  TSpectraRanges ;  // this is inherited // for display in column #

     tPCAnalysis : TPCA ;
     
     constructor Create(SDPrec : integer) ;
     destructor  Destroy; // override;
     procedure   Free;


     function  GetPCABatchArguments(lineNum, iter : integer; tStrList : TStringList ) : string ; // get input data from memo1 text. Returns final line number of String list
     // These two functions have to be called from external code which has access to the source data (sourceSpecRange)
     function  GetAllXData( interleavedOrBlocked : integer;  sourceSpecRange : TSpectraRanges ) : boolean ; override  ; // TBatch virtual method
     function  GetFactorData( interleavedOrBlocked : integer;  sourceSpecRange : TSpectraRanges ) : boolean   ; // retrieves 'factorSpecra'

     // PC_Spectra contains the two PCs to be subtracted and matched to the factor
     // fills in 'minimumSS_PCsvsFactor' float falue and  'MinimisedPCs' TSpectra
     procedure  MinimiseDifference( PC_Spectra, factSpect : TSpectraRanges) ;
     function  SumOfSquaresOfDifferences( value: single ; A_sub_B, COPY_B, Factor : TMatrix) : single ;
     function  MultAndSub : boolean ; // returns success or failure (true / fasle)
     // factorSpectra and AllXData must be filled before this function is called using 'GatAllXData' and 'GetFactorData'
     function  ProcessData( lc : pointer ) : boolean ;

    // function  ReturnExclusionString(inMat : TMatrix; numStddevs : single; colNum : integer) : string ;  // this is identical to  AutoExcludeData() but returns a string
    // function  AutoExcludeData(inMat : TMatrix; numStddevs : single; colNum : integer ) : TMatrix;
  private
end;



implementation


constructor TAutoProjectEVects.Create(SDPrec : integer) ;
begin
  tPCAnalysis   := TPCA.Create(SDPrec) ;

  allXData      := TSpectraRanges.Create(SDPrec,0,0,nil) ;
  factorSpectra := TSpectraRanges.Create(SDPrec,0,0,nil) ;
  MinimisedPCs  := TSpectraRanges.Create(SDPrec,0,0,nil) ;

  minimumSS_PCsvsFactor := 0.0 ;
  vectorPrefactor       := 0.0 ;

  inherited Create;
end ;


destructor  TAutoProjectEVects.Destroy; // override;
begin
  tPCAnalysis.Free ;

  factorSpectra.Free ;
  MinimisedPCs.Free ;

 { eigenValSpectra.Free ;
  XresidualsSpectra.Free ;
  regenSpectra.Free ;   }

//  inherited destroy ;
  inherited Free;
end ;


procedure TAutoProjectEVects.Free;
begin
 if Self <> nil then Destroy;
end;



function  TAutoProjectEVects.GetPCABatchArguments(lineNum, iter : integer; tStrList : TStringList ) : string ; // get input data from memo1 text. Returns final line number of String list
// if result has a comma then input has failed, and return value is message stating line number of batch file of problem.
var
   tstr1  : string ;

{File input is of this format:
   Memo1.Lines.Add('type = Auto Project EVects') ;
   Memo1.Lines.Add('sample range = 1-') ;
   Memo1.Lines.Add('x var range = 1-') ;
   Memo1.Lines.Add('target factor sample row = 1') ;   // sore in  factorSampleRowStr
   Memo1.Lines.Add('target factor var range  = 1-') ;  // store in factorVarStr
   Memo1.Lines.Add('project target factor only  = true // false' // if true then do not fit PCs to factor
   Memo1.Lines.Add('number of PCs = 1-2') ;
   Memo1.Lines.Add('PCs for factor match = 1-2') ;  // store in 'factorPCs'
   Memo1.Lines.Add('mean centre = false') ;  //
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

             // ********************** Target 'Factor' row ******************************************
             repeat
               inc(lineNum) ;
               tstr1 := bB.GetStringFromStrList(tStrList, lineNum) ;
             until (trim(tstr1) <> '') or (linenum > tStrList.Count)  ;
             if bB.LeftSideOfEqual(tstr1) = 'target factor sample row' then
               factorSampleRowStr :=  bB.RightSideOfEqual(tstr1) ;

             // ********************** Target 'Factor' Variables  ******************************************
             repeat
               inc(lineNum) ;
               tstr1 := bB.GetStringFromStrList(tStrList, lineNum) ;
             until (trim(tstr1) <> '') or (linenum > tStrList.Count)  ;
             if bB.LeftSideOfEqual(tstr1) = 'target factor var range' then
               factorVarStr :=  bB.RightSideOfEqual(tstr1) ;  //  = 800-1800 cm-1

             if pos(' ',trim(factorVarStr)) > 0 then
                factorVarRangeIsPositon := false
              else
                factorVarRangeIsPositon := true ;



             // ********************** Project target factor only  ******************************************
             repeat
               inc(lineNum) ;
               tstr1 := bB.GetStringFromStrList(tStrList, lineNum) ;
             until (trim(tstr1) <> '') or (linenum > tStrList.Count)  ;
             if bB.LeftSideOfEqual(tstr1) = 'project target factor only' then
               if bB.RightSideOfEqual(tstr1) = 'true'  then
                   projFactorOnly := true
                else
                   projFactorOnly :=  false ;


              // ********************** number of PCs ******************************************
             repeat
               inc(lineNum) ;
               tstr1 := bB.GetStringFromStrList(tStrList, lineNum) ;
             until (trim(tstr1) <> '') or (linenum > tStrList.Count)  ;
             if bB.LeftSideOfEqual(tstr1) = 'number of pcs' then
               PCsString :=  bB.RightSideOfEqual(tstr1) ;

            // **********************  PCs for factor match ******************************************
             repeat
               inc(lineNum) ;
               tstr1 := bB.GetStringFromStrList(tStrList, lineNum) ;
             until (trim(tstr1) <> '') or (linenum > tStrList.Count)  ;
             if bB.LeftSideOfEqual(tstr1) = 'pcs for factor match' then
               factorPCs :=  bB.RightSideOfEqual(tstr1) ;




             // ********************** Mean Centre ******************************************
             repeat        // this has to be false for Auto Project EVects
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
             repeat    // this has to be true to get correct output
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
           result := inttostr(lineNum) + ', AutoProjectEVects batch input conversion error' + #13 ;
         end ;
         end ;


end ;


// has to be called from external code which has access to the source data (sourceSpecRange)
function TAutoProjectEVects.GetAllXData( interleavedOrBlocked : integer; sourceSpecRange : TSpectraRanges ) : boolean ;
var
  t2 : integer ;
// TBatch virtual method
// sourceMatrix is either interleaved (interleavedOrBlocked =1) or block structure (interleavedOrBlocked =2)
  t1 : integer ;
  s1 : single ;
  d1 : double ;
begin
  result := false ;
  try

  if xVarRangeIsPositon = false then
  begin
      self.xVarRange :=  bB.ConvertValueStringToPosString(xVarRange, sourceSpecRange.xCoord) ;
      if  self.xVarRange = '' then
      begin
        MessageDlg('TAutoProjectEVects.GetAllXData() Error...'#13'x var range values not appropriate: '+xVarRange,mtError, [mbOK], 0)  ;
        result := false ;
        exit ;
      end ;
  end ;

  // *****************   Get the y data of TSpectraRanges object *****************
  if pos('-',XsampleRange) = length(trim(XsampleRange)) then       // sampleRange string is open ended (e.g. '12-')
    XsampleRange := XsampleRange + inttostr(sourceSpecRange.yCoord.numRows) ;


  // *****************  This actually retrieves the data  ********************
  allXData.yCoord.FetchDataFromTMatrix( XsampleRange, xVarRange , sourceSpecRange.yCoord ) ;
  if sourceSpecRange.yImaginary <> nil then
  begin
    allXData.yImaginary := TMatrix.Create(allXData.yCoord.SDPrec div 4) ;
    allXData.yImaginary.FetchDataFromTMatrix( XsampleRange, xVarRange , sourceSpecRange.yImaginary ) ;
//    allXData.
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

  result := true ;
  finally

  end ;
end ;


// has to be called from external code which has access to the source data (sourceSpecRange)
function TAutoProjectEVects.GetFactorData( interleavedOrBlocked : integer; sourceSpecRange : TSpectraRanges ) : boolean ;
var
  t2 : integer ;
// TBatch virtual method
// sourceMatrix is either interleaved (interleavedOrBlocked =1) or block structure (interleavedOrBlocked =2)
  t1 : integer ;
  s1 : single ;
  d1 : double ;
begin
  result := false ;
  try

  // ***************** prepare to retrive desired data range
  if factorVarRangeIsPositon = false then
  begin
      self.factorVarStr :=  bB.ConvertValueStringToPosString(factorVarStr, sourceSpecRange.xCoord) ;
      if  self.factorVarStr = '' then
      begin
        MessageDlg('GetFactorData() Error...'#13'x var range values not appropriate: '+factorVarStr,mtError, [mbOK], 0)  ;
        result := false ;
        exit ;
      end ;
  end ;

  // *****************   Get the y data of TSpectraRanges object *****************
  if pos('-',factorSampleRowStr) = length(trim(factorSampleRowStr)) then       // sampleRange string is open ended (e.g. '12-')
    factorSampleRowStr := factorSampleRowStr + inttostr(sourceSpecRange.yCoord.numRows) ;


  // *****************  This actually retrieves the data  ********************
  factorSpectra.yCoord.FetchDataFromTMatrix( factorSampleRowStr, factorVarStr , sourceSpecRange.yCoord ) ;
  if sourceSpecRange.yImaginary <> nil then
  begin
    factorSpectra.yImaginary := TMatrix.Create(factorSpectra.yCoord.SDPrec div 4) ;
    factorSpectra.yImaginary.FetchDataFromTMatrix( factorSampleRowStr, factorVarStr , sourceSpecRange.yImaginary ) ;
  end ;


  // *****************   Get the x data of TSpectraRanges object - X data can be disjoint (it just will display disjoint) *****************
  factorSpectra.xString := sourceSpecRange.xString ;
  factorSpectra.yString := sourceSpecRange.yString ;
  factorSpectra.xCoord.numCols :=  factorSpectra.yCoord.numCols ;
  factorSpectra.xCoord.numRows := 1 ;
  factorSpectra.xCoord.Filename := resultsFileName ;
  factorSpectra.xCoord.F_Mdata.SetSize(factorSpectra.xCoord.numCols * 1 * factorSpectra.xCoord.SDPrec) ;
  factorSpectra.xCoord.F_Mdata.Seek(0,soFromBeginning) ;
  // COPY X DATA VALUES FROM INPUT TSPECTRARANGES TO NEW TSPECTRARANGE in new row
  t2 := factorSpectra.xCoord.GetTotalRowsColsFromString(factorVarStr, factorSpectra.xCoord.Fcols) ;
  factorSpectra.xCoord.Fcols.Seek(0,soFromBeginning) ;
  for t1 := 1 to factorSpectra.xCoord.numCols do
  begin
     factorSpectra.xCoord.Fcols.Read(t2,4) ;
     sourceSpecRange.xCoord.F_Mdata.Seek(t2*sourceSpecRange.xCoord.SDPrec,soFromBeginning) ;
     if sourceSpecRange.xCoord.SDPrec = 4 then
     begin
        sourceSpecRange.xCoord.F_Mdata.Read(s1, 4) ;
        factorSpectra.xCoord.F_Mdata.Write(s1,4) ;
     end
     else
     if sourceSpecRange.xCoord.SDPrec = 8 then
     begin
        sourceSpecRange.xCoord.F_Mdata.Read(d1, 8) ;
        factorSpectra.xCoord.F_Mdata.Write(d1,8) ;
     end ;
  end ;

  result := true ;
  finally

  end ;
end ;


// Fills in 'minimumSS_PCsvsFactor' float falue and  'MinimisedPCs' TSpectra
// PC_Spectra contains the two PCs to be subtracted and matched to the factor
procedure  TAutoProjectEVects.MinimiseDifference( PC_Spectra, factSpect : TSpectraRanges) ;
var
  t1 : integer ;
  tVectPrefactor, s1 : single ;
  d1 : double ;
  PC_A, PC_B, Copy_A, Copy_B : TMatrix ;
  i_SS, f_SS : single  ;
  direction : single ;
  step          : single ;
  iteration : integer ;
  initial, final : single ;
  beenInLoop : boolean ;
begin
//    MinimisedPCs := TSpectraRanges.Create(xData.yCoord.SDPrec div 4, xData.yCoord.numRows, xData.yCoord.numCols, @xData.LineColor) ;

  try
    PC_A        := TMatrix.Create2(PC_Spectra.yCoord.SDPrec div 4,1,PC_Spectra.yCoord.numCols) ;
    PC_B        := TMatrix.Create2(PC_Spectra.yCoord.SDPrec div 4,1,PC_Spectra.yCoord.numCols) ;
    Copy_A      := TMatrix.Create(PC_Spectra.yCoord.SDPrec div 4) ;
    Copy_B      := TMatrix.Create(PC_Spectra.yCoord.SDPrec div 4) ;

    PC_A.FetchDataFromTMatrix('1','1-'+inttostr(PC_Spectra.yCoord.numCols), PC_Spectra.yCoord) ;
    PC_B.FetchDataFromTMatrix('2','1-'+inttostr(PC_Spectra.yCoord.numCols), PC_Spectra.yCoord) ;
    Copy_A.CopyMatrix(PC_A) ;
    Copy_B.CopyMatrix(PC_B) ;

    direction       := -1.0 ;
    step            :=  0.1 ;

    tVectPrefactor := 1.0 ;
    i_SS := SumOfSquaresOfDifferences(tVectPrefactor, Copy_A, Copy_B ,factSpect.yCoord) ;

    iteration := 1 ;
    initial :=  i_SS ;
    final   :=  i_SS + 1.0 ;
    while (iteration < 100) and (abs(final - initial) > 0.000001) do
    begin
       Copy_A.F_Mdata.CopyFrom(PC_A.F_Mdata,0) ;  Copy_B.F_Mdata.CopyFrom(PC_B.F_Mdata,0) ;
       if iteration <> 1 then  initial :=  final ;
       tVectPrefactor := tVectPrefactor + (direction * step) ;
       f_SS := SumOfSquaresOfDifferences(tVectPrefactor, Copy_A, Copy_B ,factSpect.yCoord) ;
       beenInLoop := false ;
       if  f_SS < i_SS then
       begin
         while f_SS < i_SS do
         begin
            i_SS := f_SS ;
            tVectPrefactor := tVectPrefactor + (direction * step) ;
            Copy_A.F_Mdata.CopyFrom(PC_A.F_Mdata,0) ;  Copy_B.F_Mdata.CopyFrom(PC_B.F_Mdata,0) ;
            f_SS := SumOfSquaresOfDifferences(tVectPrefactor, Copy_A, Copy_B ,factSpect.yCoord) ;
            if f_SS < i_SS then
             beenInLoop := true ;
         end ;
         if beenInLoop = true  then
         begin
           direction := direction * -1.0 ;
           tVectPrefactor := tVectPrefactor + (direction * step) ;  // go back to where we were
           direction := direction * -1.0 ;
           f_SS := i_SS ;
         end ;
      end
      else    // gone too far or wrong direction to start with
      begin
           direction := direction * -1.0 ; // change direction
           tVectPrefactor := tVectPrefactor + (direction * step) ;   // go back to where we were
          // direction := direction * -1.0 ;
      end  ;

      step := step / 10 ;
      final :=  f_SS ;
      inc(iteration) ;
      Form4.StatusBar1.Panels[0].Text := 'Sum of Squares: ' + floattoStrf(f_SS,ffGeneral,7,6) ;
    end ;

    minimumSS_PCsvsFactor :=  f_SS ;
    vectorPrefactor := tVectPrefactor ;

    MinimisedPCs.CopySpectraObject( factorSpectra ) ;
    MinimisedPCs.yCoord.CopyMatrix(PC_A) ;
    PC_B.MultiplyByScalar(tVectPrefactor) ;
    MinimisedPCs.yCoord.AddVectToMatrixRows(PC_B.F_Mdata) ;

  finally
  begin
    PC_A.Free ;
    PC_B.Free ;
    Copy_A.Free ;
    Copy_B.Free ;
  end ;
  end ;
end ;



function TAutoProjectEVects.SumOfSquaresOfDifferences( value: single ;A_sub_B, COPY_B, Factor : TMatrix) : single ;
var     // param is the paramter number to step in value (reference into paramsStr memory stream)
  t1 : integer ;
  f_SS : single ;
  s1, s2 : single ;
//  A_sub_B, COPY_B : TMatrix ;
begin

try
    Copy_B.MultiplyByScalar(value) ;
    A_sub_B.AddVectToMatrixRows(Copy_B.F_Mdata) ;

    f_SS := 0.0 ;
    A_sub_B.F_Mdata.Seek(0, soFromBeginning) ;
    Factor.F_Mdata.Seek(0, soFromBeginning) ;
    for t1 := 1 to Factor.numCols do
    begin
       A_sub_B.F_Mdata.Read(s1,4) ; // read angle value
       Factor.F_Mdata.Read(s2,4) ; // read angle value
       s2 :=  (s1-s2) ;
       f_SS := f_SS + ( s2 *s2 ) ;
    end ;
    A_sub_B.F_Mdata.Seek(0, soFromBeginning) ;
    Factor.F_Mdata.Seek(0, soFromBeginning) ;

    result :=  f_SS ;

finally

end ;

end ;



function  TAutoProjectEVects.MultAndSub : boolean ; // returns success or failure (true / fasle)
var
  tScores: TSpectraRanges ;
  MKLbetas : single ;
  MKLEVects, MKLscores, MKLdata : pointer ;
  MKLtint, MKLlda : integer ;
begin
    try
      result := false ;

      // create scores by projection of EVects onto original data
      tScores := TSpectraRanges.Create(AllXData.yCoord.SDPrec div 4, AllXData.yCoord.numRows, 1, @AllXData.LineColor) ;
      tScores.yCoord.Free ;
      tScores.yCoord := tPCAnalysis.mo.MultiplyMatrixByMatrix(AllXData.yCoord,MinimisedPCs.yCoord,false,true,1.0,false) ;

      // use BLAS level 2 routine - subtract reconstructed data from original data
      MKLEVects := MinimisedPCs.yCoord.F_Mdata.Memory ;

      MKLscores   := tScores.yCoord.F_Mdata.Memory ;
      MKLdata     := AllXData.yCoord.F_Mdata.Memory ;
      MKLlda      := AllXData.yCoord.numCols  ;
      MKLtint     :=  1 ;
      MKLbetas    := -1.0 ;
      sger (AllXData.yCoord.numCols , AllXData.yCoord.numRows, MKLbetas, MKLEVects, MKLtint, MKLscores , MKLtint, MKLdata, MKLlda) ;

      tScores.Free ;
      result := true ;
    except
    begin
      tScores.Free ;
    end ;
    end ;
end ;



function  TAutoProjectEVects.ProcessData( lc : pointer ) : boolean ;
// factorSpectra and AllXData must be filled before this function is called using 'GatAllXData' and 'GetFactorData'
var
  t1 : integer ;
  s1 : single ;
  d1 : double ;
  pcsToFitMemStrm : TMemoryStream ;
  PC_AandB : TSpectraRanges ;
begin
  try
  try
    result := false ;
    pcsToFitMemStrm := TMemoryStream.Create ;
    t1 := allXData.yCoord.GetTotalRowsColsFromString(PCsString, pcsToFitMemStrm) ; // number of PCs to fit

    pcsToFitMemStrm.Seek(-4,soFromEnd) ;
    pcsToFitMemStrm.Read(numPCs,4) ; // read final number in range (don't use t1 as it is number in set, not the maximum PC needed)
    numPCs := numPCs + 1 ;    // add one because the numbers returned are zero based
    if numPcs > allXData.yCoord.numRows then
    begin
      messagedlg('Function ProcessPCAData() failed. Have to exit batch process, number of PCs wanted is greater than number of spectra' ,mtError,[mbOK],0) ;
      exit ;
    end ;

    // ************** do PCA on copy of X matrix (i.e. XResiduals) ***********************************
    if allXData.yImaginary = nil then
    begin
      // load data into X matrix
//      tPCAnalysis.XMatrix.CopyMatrix( allXData.yCoord )  ;  // XMatrix copy is done in the tPCAnalysis.PCA() function
      tPCAnalysis.XResiduals.CopyMatrix( allXData.yCoord ) ;
      // Do PCA
      tPCAnalysis.PCA(tPCAnalysis.XResiduals, numPCs, meanCentre, colStd) ;
    end
    else  // data is complex
    begin
       // load data into X matrix
       // XMatrix copy is done in the tPCAnalysis.PCA() function - do first here for complex data
       tPCAnalysis.XMatrix.CopyMatrix( allXData.yCoord )  ;  // assign pointer to new object
       tPCAnalysis.XMatrix.MakeComplex( allXData.yImaginary ) ; // interleaves real complex pairs
       tPCAnalysis.XResiduals.CopyMatrix( tPCAnalysis.XMatrix ) ;
       // Do PCA (complex)
       tPCAnalysis.PCAcomplex(tPCAnalysis.XResiduals, numPCs, meanCentre, colStd) ;
    end ;


    PC_AandB := TSpectraRanges.Create(allXData.yCoord.SDPrec div 4, 0, 0, nil) ;
    // get desired PCs from tPCAnalysis EVects matrix
    tPCAnalysis.EVects.F_Mdata.Seek(0,soFromBeginning) ;
    PC_AandB.yCoord.FetchDataFromTMatrix( factorPCs, factorVarStr , tPCAnalysis.EVectNormalsied ) ;


    if projFactorOnly = false then
    begin
      // minimise the difference between the actual PC1 and the 'pure' KBr PC1
      MinimiseDifference(PC_AandB, factorSpectra) ;
      // MessageDlg('PC1-PC2 minimised. SS of errors = '+  floattostrf(minimumSS_PCsvsFactor,ffGeneral,7,6) +' Prefactor = '+floattostrf(vectorPrefactor,ffGeneral,7,6) ,mtInformation, [mbOK], 0)  ;
    end
    else
    begin
       MinimisedPCs.CopySpectraObject(factorSpectra) ;
    end ;

    // Project the minimised factor (or original factor) onto the original data
    MultAndSub ;   // this modifies the AllXData matrix by subtracting the (artificial) PC1 (=PC1-PC2 fit to PCA(KBr).PC1)

    // do PCA of new AllXData
    tPCAnalysis.ClearAll ;  // resets PCA object
    if allXData.yImaginary = nil then
    begin
      // load data into X matrix
      tPCAnalysis.XResiduals.CopyMatrix( allXData.yCoord ) ;
      tPCAnalysis.PCA(tPCAnalysis.XResiduals, numPCs, meanCentre, colStd) ;  // Do PCA
    end  ;


    // 1/ ****  Create display objects for calculated data ****
    scoresSpectra    := TSpectraRanges.Create(self.allXData.yCoord.SDPrec div 4, allXData.yCoord.numRows, numPCs,  lc )  ; // x2 due to scores & fit data being included
    eigenVSpectra  := TSpectraRanges.Create(self.allXData.yCoord.SDPrec div 4, numPCs                 , allXData.yCoord.numCols, lc )  ;
    XresidualsSpectra := TSpectraRanges.Create(self.allXData.yCoord.SDPrec div 4, allXData.yCoord.numRows, allXData.yCoord.numCols, lc )  ;
    eigenValSpectra  := TSpectraRanges.Create(self.allXData.yCoord.SDPrec div 4, 1                      , numPcs, lc )  ;
    regenSpectra     := TSpectraRanges.Create(self.allXData.yCoord.SDPrec div 4, allXData.yCoord.numRows, allXData.yCoord.numCols, lc )  ;

    // 2/ ****  Copy calculated data to output display objects ****
    if normalisedEVects then
    begin
      scoresSpectra.yCoord.CopyMatrix( tPCAnalysis.ScoresNormalised ) ;
      eigenVSpectra.yCoord.CopyMatrix( tPCAnalysis.EVectNormalsied ) ;
    end
    else  // not normalisedEVects
    begin
      scoresSpectra.yCoord.CopyMatrix( tPCAnalysis.Scores ) ;
      eigenVSpectra.yCoord.CopyMatrix( tPCAnalysis.EVects ) ;
    end ;

    XresidualsSpectra.yCoord.CopyMatrix( tPCAnalysis.XResiduals )   ;
    eigenValSpectra.yCoord.CopyMatrix( tPCAnalysis.EigenValues ) ;
//    tPCAnalysis.RegenerateData( '1-'+inttostr(numPCs),'1-'+inttostr(tPCAnalysis.EVects.numCols),meanCentre,tPCAnalysis.XResiduals.F_MAverage) ;  // this is done in PCAResultsObject code
    regenSpectra.yCoord.CopyMatrix( tPCAnalysis.RegenMatrix ) ;


    if eigenVSpectra.yCoord.complexMat = 2 then
    begin
         scoresSpectra.yImaginary := TMatrix.Create2(scoresSpectra.yCoord.SDPrec div 4, scoresSpectra.yCoord.numRows, scoresSpectra.yCoord.numCols ) ;
         scoresSpectra.yCoord.MakeUnComplex( scoresSpectra.yImaginary ) ;
         eigenVSpectra.yImaginary := TMatrix.Create2(eigenVSpectra.yCoord.SDPrec div 4, eigenVSpectra.yCoord.numRows, eigenVSpectra.yCoord.numCols ) ;
         eigenVSpectra.yCoord.MakeUnComplex( eigenVSpectra.yImaginary ) ;
         XresidualsSpectra.yImaginary := TMatrix.Create2(XresidualsSpectra.yCoord.SDPrec div 4, XresidualsSpectra.yCoord.numRows, XresidualsSpectra.yCoord.numCols) ;
         XresidualsSpectra.yCoord.MakeUnComplex( XresidualsSpectra.yImaginary ) ;
         eigenValSpectra.yImaginary := TMatrix.Create2(eigenValSpectra.yCoord.SDPrec div 4, eigenValSpectra.yCoord.numRows, eigenValSpectra.yCoord.numCols) ;
         eigenValSpectra.yCoord.MakeUnComplex( eigenValSpectra.yImaginary ) ;
         regenSpectra.yImaginary := TMatrix.Create2(regenSpectra.yCoord.SDPrec div 4, regenSpectra.yCoord.numRows, regenSpectra.yCoord.numCols) ;
         regenSpectra.yCoord.MakeUnComplex( regenSpectra.yImaginary ) ;
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
    XresidualsSpectra.SeekFromBeginning(3,1,0) ;
    regenSpectra.SeekFromBeginning(3,1,0) ;
    if self.allXData.xCoord.SDPrec = 4 then
    begin
      for t1 := 1 to allXData.yCoord.numCols do
      begin
        allXData.xCoord.F_Mdata.Read(s1,4) ;
        eigenVSpectra.xCoord.F_Mdata.Write(s1,4) ;
        XresidualsSpectra.xCoord.F_Mdata.Write(s1,4) ;
        regenSpectra.xCoord.F_Mdata.Write(s1,4) ;
      end  ;
    end
    else
    if self.allXData.xCoord.SDPrec = 8 then
    begin
      for t1 := 1 to allXData.yCoord.numCols do
      begin
        allXData.xCoord.F_Mdata.Read(d1,8) ;
        eigenVSpectra.xCoord.F_Mdata.Write(d1,8) ;
        XresidualsSpectra.xCoord.F_Mdata.Write(d1,8) ;
        regenSpectra.xCoord.F_Mdata.Write(d1,8) ;
      end  ;
    end ;
    // C/ create x coord data for eigenValSpectra (one point for each PC)
    eigenValSpectra.xCoord.F_Mdata.Seek(0,soFromBeginning) ;
    if self.allXData.yCoord.SDPrec = 4 then
    begin
       for t1 := 1 to self.numPCs do
       begin
         s1 := t1 ;
         eigenValSpectra.xCoord.F_Mdata.Write(s1,4) ;
       end ;
    end
    else
    if self.allXData.yCoord.SDPrec = 8 then
    begin
      for t1 := 1 to self.numPCs do
      begin
        d1 := t1 ;
        eigenValSpectra.xCoord.F_Mdata.Write(d1,8) ;
      end
    end ;

  finally
  begin
    pcsToFitMemStrm.Free ;
    PC_AandB.Free ;
  end ;
  end ;
  except
  begin
    // exception in code => failure of function: result = false ;
    pcsToFitMemStrm.Free ;
    PC_AandB.Free ;
    result := false ;
  end ;
  end ;

  result := true ;

end ;


end.
 