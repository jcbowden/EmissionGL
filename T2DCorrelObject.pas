unit T2DCorrelObject;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  TBatchBasicFunctions, TSpectraRangeObject, TMatrixObject, TMatrixOperations,
  TVarAndCoVarOperations ;

type
  T2DCorrelation  = class(TObject)
  public
     resultsFileName : string ;
     meanCentre, colstd : boolean ;
     standardiseVarCovar : boolean ;  // standardise covariance to 1 (Pearsons R Matrix)

     sampleRange : string ;
     xVarRange : string ;
     xVarRangeIsPositon : boolean ;

     wwSynchronous  :  TSpectraRanges ;  // wavenumber - wavenumber syncronous correlation
     wwAsynchronous :  TSpectraRanges ;  // wavenumber - wavenumber asyncronous correlation
     ssSynchronous  :  TSpectraRanges ;  // sample - sample syncronous correlation
     ssAsynchronous  :  TSpectraRanges ;  // sample - sample asyncronous correlation

     allXData       : TSpectraRanges ;  // for display in column #2 - The original data set

     bB : TBatchBasics ;  // functions like : LeftSideOfEqual() etc
     mo : TMatrixOps ;  // matrix multiply


     constructor Create(SDPrec : integer) ;  // 
     destructor  Destroy; // override;
     procedure Free ;

     function  GetAllXData( sourceSpecRange : TSpectraRanges ) : boolean   ;
     function  Get2DCorrelBatchArguments(lineNum, iter : integer; tStrList : TStringList ) : integer ; // get input data from memo1 text. Returns final line number of String list
     function  ReturnHilbertNodaMatrix(singlOrDouble : integer ; row, cols: integer )  : TMatrix ;
     function  Process2DCorrelData( lc : pointer ) : boolean ;  // lc is pointer to TGLLineColor object

  private
end;

implementation


constructor T2DCorrelation.Create(SDPrec : integer);  // need SDPrec 
begin
   allXData := TSpectraRanges.Create(SDPrec,0,0,nil) ;
   bB :=   TBatchBasics.Create ;
   mo :=   TMatrixOps.Create ;
   inherited Create ;
end ;


destructor  T2DCorrelation.Destroy; // override;
begin
  allXData.Free ;
  wwSynchronous.Free ;
  wwAsynchronous.Free ;
  ssSynchronous.Free ;
  ssAsynchronous.Free ;

  bB.Free ;
  mo.Free ;

  inherited Destroy ;
end ;

procedure T2DCorrelation.Free;
begin
 if Self <> nil then Destroy;
end;


function  T2DCorrelation.GetAllXData( sourceSpecRange : TSpectraRanges ) : boolean   ; 
var
  t1, t2 : integer ;
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
        MessageDlg('T2DCorrelation.GetAllXData() Error...'#13'x var range values not appropriate: '+xVarRange,mtError, [mbOK], 0)  ;
        result := false ;
        exit ;
      end ;
  end ;

  // *****************   Get the y data of TSpectraRanges object *****************
  if pos('-',sampleRange) = length(sampleRange) then       // sampleRange string is open ended (e.g. '12-')
    sampleRange := sampleRange + inttostr(sourceSpecRange.yCoord.numRows) ;

  allXData.yCoord.FetchDataFromTMatrix( sampleRange, xVarRange , sourceSpecRange.yCoord ) ;

  if meanCentre then
    allXData.yCoord.MeanCentre() ;
  if colstd then
    allXData.yCoord.ColStandardize() ;

  // *****************   Get the x data of TSpectraRanges object - X data can be disjoint (it just will display disjointedly) *****************
  allXData.xString := sourceSpecRange.xString ;
  allXData.yString := sourceSpecRange.yString ;
  allXData.xCoord.numCols :=  allXData.yCoord.numCols ;
  allXData.xCoord.numRows := 1 ;
  allXData.xCoord.Filename := resultsFileName ;
  allXData.xCoord.F_Mdata.SetSize(allXData.xCoord.numCols * allXData.xCoord.numRows * allXData.xCoord.SDPrec) ;
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


{ if flipRange <> '' then     // flipRange inverts an eigenvector if needed (and scores for this eigenvector)
  begin
      if pos(' ',trim(flipRange)) > 0 then  // check for ' cm-1' or other unit (if no unit the assume it is a variable range - in range of 'xVarRange' (should test for that))
        self.flipRange :=  bB.ConvertValueStringToPosString(flipRange, allXData.xCoord) ;
      if  self.flipRange = '' then
      begin
        MessageDlg('T2DCorrelation.GetAllXData() Error...'#13'flipRange range is out of data range: '+xVarRange,mtError, [mbOK], 0)  ;
        result := false ;
        exit ;
      end ; ;
  end ;   }

  result := true ;
  finally

  end ;
end ;


function  T2DCorrelation.Get2DCorrelBatchArguments(lineNum, iter : integer; tStrList : TStringList ) : integer ; // get input data from memo1 text. Returns final line number of String list
var
   tstr1  : string ;
{File input is of this format:
   Memo1.Lines.Add('type = 2D correlation') ;
   Memo1.Lines.Add('sample range = 1-') ;
   Memo1.Lines.Add('x var range = 800-1800 cm-1 ') ;
   Memo1.Lines.Add('mean centre = true') ;  //
   Memo1.Lines.Add('column standardise = false') ;  //
   Memo1.Lines.Add('results file = 2D_correlation.out') ;}
begin
             // ********************** Sample range  ******************************************
             repeat
               inc(lineNum) ;
               tstr1 := bB.GetStringFromStrList(tStrList, lineNum) ;
             until trim(tstr1) <> ''  ;
             if bB.LeftSideOfEqual(tstr1) = 'sample range' then
               sampleRange :=  bB.RightSideOfEqual(tstr1) ;

             // ********************** Variable range  **************************************
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

              // **************  standardise covariance to 1 (Pearsons R Matrix) *************
             repeat
               inc(lineNum) ;
               tstr1 := bB.GetStringFromStrList(tStrList, lineNum) ;
             until (trim(tstr1) <> '') or (linenum > tStrList.Count)  ;
             if bB.LeftSideOfEqual(tstr1) = 'standardize var covar' then
                if bB.RightSideOfEqual(tstr1) = 'true'  then
                   standardiseVarCovar := true
                else
                   standardiseVarCovar :=  false ;

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

             // ********************** Get output filename 'resultsFile' ******************************************
             repeat
               inc(lineNum) ;
               tstr1 := bB.GetStringFromStrList(tStrList, lineNum) ;
             until (trim(tstr1) <> '') or (linenum > tStrList.Count)  ;
             if bB.LeftSideOfEqual(tstr1) = 'results file' then
               resultsFileName :=  bB.RightSideOfEqual(tstr1) ;

             // **********************  ******************************************
             repeat
               inc(lineNum) ;
               tstr1 := bB.GetStringFromStrList(tStrList, lineNum) ;
             until (trim(tstr1) <> '') or (lineNum>=tStrList.Count)  ;

             result := lineNum ;
end ;


function  T2DCorrelation.ReturnHilbertNodaMatrix(singlOrDouble : integer ; row, cols: integer )  : TMatrix ;
var
   t1, t2 : integer ;
   s1 : single ;
   d1 : double ;
   resultMatrix : TMatrix ;  // the reult is transposed as obtained from _gemm
begin

  resultMatrix := TMatrix.Create2(singlOrDouble,row,cols) ;
  resultMatrix.F_Mdata.Seek(0,soFromBeginning) ;

  if singlOrDouble = 1 then
  begin
  for t1 := 1 to row do
  begin
    for t2 := 1 to cols do
    begin
       if t1 <> t2 then
       begin
          s1 :=  1 / ((t2 - t1) * pi ) ;
          resultMatrix.F_Mdata.Write(s1,4) ;
       end
       else
       begin
         s1 := 0 ;
         resultMatrix.F_Mdata.Write(s1,4) ;
       end ;
    end ;
  end ;
  end
  else
  if singlOrDouble = 2 then
  begin
  for t1 := 1 to row do
  begin
    for t2 := 1 to cols do
    begin
       if t1 <> t2 then
       begin
         d1 :=  1 / ((t2 - t1) * pi ) ;
         resultMatrix.F_Mdata.Write(d1,8) ;
       end
       else
       begin
         d1 := 0 ;
         resultMatrix.F_Mdata.Write(d1,8) ;
       end ;
    end ;
  end ;
  end  ;

  result :=  resultMatrix ;  // need to dispose of this in calling function
end ;


function  T2DCorrelation.Process2DCorrelData( lc : pointer ) : boolean ;
var
  t1 : integer ;
  s1 : single ;
  d1 : double ;
  allXDataTrans : TMatrix ;
  hnMatrix : TMatrix  ;  // Hilbert-Noda transformation matrix
  tempMat : TMatrix ;
  pcres : TVarAndCoVarFunctions  ; // only used for GetVarCovarMatrix() and StandardiseVarCovar() functions
  stdVarCovar : boolean ;
begin
  try
  try
    result := true ;
    pcres :=  TVarAndCoVarFunctions.Create ;
    // copy allXData to another matrix
    allXDataTrans := TMatrix.Create(allXData.yCoord.SDPrec div 4) ;
    allXDataTrans.CopyMatrix( allXData.yCoord ) ;

      // 1/ ****  Create display objects for calculated data ****
    wwSynchronous   := TSpectraRanges.Create(self.allXData.yCoord.SDPrec div 4, allXData.yCoord.numCols, allXData.yCoord.numCols, lc )  ; // x2 due to scores & fit data being included
    wwAsynchronous  := TSpectraRanges.Create(self.allXData.yCoord.SDPrec div 4, allXData.yCoord.numCols, allXData.yCoord.numCols, lc )  ;
    ssSynchronous   := TSpectraRanges.Create(self.allXData.yCoord.SDPrec div 4, allXData.yCoord.numRows, allXData.yCoord.numRows, lc )  ;
    ssAsynchronous   := TSpectraRanges.Create(self.allXData.yCoord.SDPrec div 4, allXData.yCoord.numRows, allXData.yCoord.numRows, lc )  ;

    // 2/ ****  Calculated data and assign to output display objects ****
    if self.allXData.xCoord.SDPrec = 4 then
    begin
    try
      s1 := 1 / (allXData.yCoord.numRows -1) ;
      wwSynchronous.yCoord.Free ;

      wwSynchronous.yCoord :=  pcres.GetVarCovarMatrix(allXData.yCoord) ;
      if standardiseVarCovar then
        stdVarCovar := pcres.StandardiseVarCovar( wwSynchronous.yCoord ) ;
      if stdVarCovar = false then
      begin
        messagedlg('Could not standardise wwSynchronous' ,mtError,[mbOK],0) ;
        result := false ;
       // exit ;
      end ;

     //   mo.MultiplyMatrixByMatrix(allXDataTrans, allXData.yCoord, true, false, s1, false) ;


      hnMatrix :=  ReturnHilbertNodaMatrix(allXData.yCoord.SDPrec div 4, allXData.yCoord.numRows, allXData.yCoord.numRows) ;
      tempMat :=  mo.MultiplyMatrixByMatrix(allXDataTrans, hnMatrix, true, false, 1.0, false) ;
      wwAsynchronous.yCoord.Free ;
      wwAsynchronous.yCoord  :=  mo.MultiplyMatrixByMatrix(tempMat, allXDataTrans, false, false, 1.0, true) ;
{      if standardiseVarCovar then
        stdVarCovar := pcres.StandardiseVarCovar( wwAsynchronous.yCoord ) ;
      if stdVarCovar = false then
      begin
        messagedlg('Could not standardise wwAsynchronous' ,mtError,[mbOK],0) ;
        result := false ;
      //  exit ;
      end ;  }

      ssSynchronous.yCoord.Free ;
      ssSynchronous.yCoord :=  mo.MultiplyMatrixByMatrix(allXDataTrans, allXData.yCoord, false, true, s1, false) ;
      if standardiseVarCovar then
        stdVarCovar := pcres.StandardiseVarCovar( ssSynchronous.yCoord ) ;
      if stdVarCovar = false then
      begin
        messagedlg('Could not standardise ssSynchronous' ,mtError,[mbOK],0) ;
        result := false ;
      //  exit ;
      end ;

      hnMatrix.Free ;
      tempMat.Free ;
      hnMatrix :=  ReturnHilbertNodaMatrix(allXData.yCoord.SDPrec div 4, allXData.yCoord.numCols, allXData.yCoord.numCols) ;
      tempMat :=  mo.MultiplyMatrixByMatrix(allXDataTrans, hnMatrix, false, false, 1.0, false) ;
      ssAsynchronous.yCoord.Free ;
      ssAsynchronous.yCoord  :=  mo.MultiplyMatrixByMatrix(tempMat, allXDataTrans, false, true, 1.0, false) ;
{      if standardiseVarCovar then
        stdVarCovar := pcres.StandardiseVarCovar( ssAsynchronous.yCoord ) ;
      if stdVarCovar = false then
      begin
        messagedlg('Could not standardise ssAsynchronous' ,mtError,[mbOK],0) ;
        result := false ;
      //  exit ;
      end ;  }
    finally
       tempMat.Free ;
       hnMatrix.Free ;
    end ;
    end ;


    // 3/ ****  Create X data for output display objects  ****
    // Add wavelength values as xCoord for EVects matrix storage
    wwSynchronous.SeekFromBeginning(3,1,0) ;
    wwAsynchronous.SeekFromBeginning(3,1,0) ;
    ssSynchronous.SeekFromBeginning(3,1,0) ;
    ssAsynchronous.SeekFromBeginning(3,1,0) ;
    self.allXData.xCoord.F_Mdata.Seek(0,soFromBeginning) ;
    if self.allXData.xCoord.SDPrec = 4 then
    begin
      for t1 := 1 to allXData.yCoord.numCols do
      begin
        self.allXData.xCoord.F_Mdata.Read(s1,4) ;
        wwSynchronous.xCoord.F_Mdata.Write(s1,4) ;
        wwAsynchronous.xCoord.F_Mdata.Write(s1,4) ;
      end  ;
      for t1 := 1 to ssSynchronous.yCoord.numCols do
      begin
        s1 := t1 ;
        ssSynchronous.xCoord.F_Mdata.Write(s1,4) ;
        ssAsynchronous.xCoord.F_Mdata.Write(s1,4) ;
      end ;
    end
    else
    if self.allXData.xCoord.SDPrec = 8 then
    begin
      for t1 := 1 to allXData.yCoord.numCols do
      begin
        self.allXData.xCoord.F_Mdata.Read(d1,8) ;
        wwSynchronous.xCoord.F_Mdata.write(d1,8) ;
        wwAsynchronous.xCoord.F_Mdata.Write(d1,8) ;
      end  ;
      for t1 := 1 to ssSynchronous.yCoord.numCols do
      begin
        d1 := t1 ;
        ssSynchronous.xCoord.F_Mdata.Write(d1,8) ;
        ssAsynchronous.xCoord.F_Mdata.Write(d1,8) ;
      end ;
    end ;

  finally
    pcres.Free ;
    allXDataTrans.Free  ;
  end ;
  except
    result := false ;
  end ;

end ;



{
function  T2DCorrelation.Process2DCorrelData( lc : pointer ) : boolean ;
var
  t1 : integer ;
  s1 : single ;
  d1 : double ;
  allXDataTrans : TMatrix ;
  hnMatrix : TMatrix  ;  // Hilbert-Noda transformation matrix
  tempMat : TMatrix ;
  pcres : TPCResults ;
begin
  try
    // copy allXData to another matrix
    allXDataTrans := TMatrix.Create(allXData.yCoord.SDPrec div 4) ;
    allXDataTrans.CopyMatrix( allXData.yCoord ) ;

      // 1/ ****  Create display objects for calculated data ****
    wwSynchronous   := TSpectraRanges.Create(self.allXData.yCoord.SDPrec div 4, allXData.yCoord.numCols, allXData.yCoord.numCols, lc )  ; // x2 due to scores & fit data being included
    wwAsynchronous  := TSpectraRanges.Create(self.allXData.yCoord.SDPrec div 4, allXData.yCoord.numCols, allXData.yCoord.numCols, lc )  ;
    ssSynchronous   := TSpectraRanges.Create(self.allXData.yCoord.SDPrec div 4, allXData.yCoord.numRows, allXData.yCoord.numRows, lc )  ;
    ssAsynchronous   := TSpectraRanges.Create(self.allXData.yCoord.SDPrec div 4, allXData.yCoord.numRows, allXData.yCoord.numRows, lc )  ;

    // 2/ ****  Calculated data and assign to output display objects ****
    if self.allXData.xCoord.SDPrec = 4 then
    begin
      s1 := 1 / (allXData.yCoord.numRows -1) ;
      wwSynchronous.yCoord.Free ;
      wwSynchronous.yCoord :=  mo.MultiplyMatrixByMatrix(allXDataTrans, allXData.yCoord, true, false, s1, false) ;

      hnMatrix :=  ReturnHilbertNodaMatrix(allXData.yCoord.SDPrec div 4, allXData.yCoord.numRows, allXData.yCoord.numRows) ;
      tempMat :=  mo.MultiplyMatrixByMatrix(allXDataTrans, hnMatrix, true, false, 1.0, false) ;
      wwAsynchronous.yCoord.Free ;
      wwAsynchronous.yCoord  :=  mo.MultiplyMatrixByMatrix(tempMat, allXDataTrans, false, false, 1.0, false) ;

      ssSynchronous.yCoord.Free ;
      ssSynchronous.yCoord :=  mo.MultiplyMatrixByMatrix(allXDataTrans, allXData.yCoord, false, true, s1, false) ;

      hnMatrix.Free ;
      tempMat.Free ;
      hnMatrix :=  ReturnHilbertNodaMatrix(allXData.yCoord.SDPrec div 4, allXData.yCoord.numCols, allXData.yCoord.numCols) ;
      tempMat :=  mo.MultiplyMatrixByMatrix(allXDataTrans, hnMatrix, false, false, 1.0, false) ;
      ssAsynchronous.yCoord.Free ;
      ssAsynchronous.yCoord  :=  mo.MultiplyMatrixByMatrix(tempMat, allXDataTrans, false, true, 1.0, false) ;

      tempMat.Free ;
      hnMatrix.Free ;
    end ;


    // 3/ ****  Create X data for output display objects  ****
    // Add wavelength values as xCoord for EVects matrix storage
    wwSynchronous.SeekFromBeginning(3,1,0) ;
    wwAsynchronous.SeekFromBeginning(3,1,0) ;
    ssSynchronous.SeekFromBeginning(3,1,0) ;
    ssAsynchronous.SeekFromBeginning(3,1,0) ;
    self.allXData.xCoord.F_Mdata.Seek(0,soFromBeginning) ;
    if self.allXData.xCoord.SDPrec = 4 then
    begin
      for t1 := 1 to allXData.yCoord.numCols do
      begin
        self.allXData.xCoord.F_Mdata.Read(s1,4) ;
        wwSynchronous.xCoord.F_Mdata.Write(s1,4) ;
        wwAsynchronous.xCoord.F_Mdata.Write(s1,4) ;
        ssSynchronous.xCoord.F_Mdata.Write(s1,4) ;
        ssAsynchronous.xCoord.F_Mdata.Write(s1,4) ;
      end  ;
    end
    else
    if self.allXData.xCoord.SDPrec = 8 then
    begin
      for t1 := 1 to allXData.yCoord.numCols do
      begin
        self.allXData.xCoord.F_Mdata.Read(d1,8) ;
        wwSynchronous.xCoord.F_Mdata.write(d1,8) ;
        wwAsynchronous.xCoord.F_Mdata.Write(d1,8) ;
        ssSynchronous.xCoord.F_Mdata.Write(d1,8) ;
        ssAsynchronous.xCoord.F_Mdata.Write(d1,8) ;
      end  ;
    end ;

  finally
    allXDataTrans.Free
  end ;

end ;      }


end.
 