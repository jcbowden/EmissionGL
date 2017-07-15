unit TPCABatchObject;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, PCAResultsObject,
  TMatrixObject, TSpectraRangeObject, TBatch ;



type
  TPCABatch  = class(TBatchMVA)
  public
     numPCs : integer ;

//     eigenValSpectra  :  TSpectraRanges ;  // this is inherited // for display in column #
//     residualsSpectra :  TSpectraRanges ;  // this is inherited // for display in column #. Created in ProcessPCAData()  function as need to get sizes from input data
//     regenSpectra     :  TSpectraRanges ;  // this is inherited // for display in column #

     // not used:
     flipRange : string ; // section of e-vector of interest. if  flipRange = '' then do not do test
     positive : boolean ; // if true then area of e-vect should be positive else area should be negative. Flip if not true.

     tPCAnalysis : TPCA ;
     
     constructor Create(SDPrec : integer) ;
     destructor  Destroy; // override;
     procedure   Free;


     function  GetPCABatchArguments(lineNum, iter : integer; tStrList : TStringList ) : string ; // get input data from memo1 text. Returns final line number of String list
     function  GetAllXData( interleavedOrBlocked : integer;  sourceSpecRange : TSpectraRanges ) : boolean ; override  ; // TBatch virtual method
     function  ProcessPCAData( lc : pointer ) : boolean ;

    // function  ReturnExclusionString(inMat : TMatrix; numStddevs : single; colNum : integer) : string ;  // this is identical to  AutoExcludeData() but returns a string
    // function  AutoExcludeData(inMat : TMatrix; numStddevs : single; colNum : integer ) : TMatrix;
  private
end;



implementation


constructor TPCABatch.Create(SDPrec : integer) ;
begin
  tPCAnalysis := TPCA.Create(SDPrec) ;
  allXData := TSpectraRanges.Create(SDPrec,0,0,nil) ;
  inherited Create;
end ;


destructor  TPCABatch.Destroy; // override;
begin
  tPCAnalysis.Free ;
{  eigenValSpectra.Free ;
  XresidualsSpectra.Free ;
  regenSpectra.Free ;       }

//  inherited destroy ;
  inherited Free;
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



function TPCABatch.GetAllXData( interleavedOrBlocked : integer; sourceSpecRange : TSpectraRanges ) : boolean ;
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
        MessageDlg('TPCABatch.GetAllXData() Error...'#13'x var range values not appropriate: '+xVarRange,mtError, [mbOK], 0)  ;
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




function  TPCABatch.ProcessPCAData( lc : pointer ) : boolean ;
var
  t1 : integer ;
  s1 : single ;
  d1 : double ;
  pcsToFitMemStrm : TMemoryStream ;
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
       tPCAnalysis.XMatrix.MakeComplex(allXData.yImaginary) ; // interleaves real complex pairs
       tPCAnalysis.XResiduals.CopyMatrix( tPCAnalysis.XMatrix ) ;
       // Do PCA (complex)
       tPCAnalysis.PCAcomplex(tPCAnalysis.XResiduals, numPCs, meanCentre, colStd) ;
    end ;


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
    pcsToFitMemStrm.Free ;
  end ;
  except
    // exception in code => failure of function: result = false ;
    result := false ;
  end ;

  result := true ;

end ;




end.
