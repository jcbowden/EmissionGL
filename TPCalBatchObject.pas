unit TPCalBatchObject ;
//  This unit obtains input data from a batch file so we can create
//  a model using 'P calibration' method (using TPcalResultsObject)
//  by inputing eigenvectors or scores only.
// (i.e. without a PCA of the dataa to obtain them)
//{$define FREEPASCAL=1}
{$ifdef FREEPASCAL}
{$mode delphi}
{$endif}
interface

uses
   SysUtils, Classes, TBatchBasicFunctions, TSpectraRangeObject, TMatrixObject,
   TMatrixOperations , TPCalResultsObjects, TPreprocessUnit ;

type
  TPCalBatch  = class
  public
     numPCsPCR : integer ;

     // the X data details
     xFilename : string ; // used in command line version
     XsampleRange : string ;
     xVarRange : string ; // variable range or filled in by ConvertValueStringToPosString()
     xVarRangeIsPositon : boolean ;

     yFilename : string ;  // this where data is stored on disk
     YsampleRange : string ;
     yVarRange : string ; // variable range or filled in by ConvertValueStringToPosString()
     YinXData  : boolean ;

     ScoresOrEvectsFileName : string ;
     isScoresThenTrue : boolean ;

     SDPrecPCR      : integer ;  // 4 or 8 depeding on floating point precission

     resultsFileName : string;
     PCsString : string;
     firstSpectra : integer ;  // not needed in PCA, PCR, PLS... it is first value in sampleRange

     normalisedEVects, meanCentre, colStd : boolean ;
     xDiskEQxData  : boolean ; // if data from disk is identical to what is processed then this is 'true'
     interleaved : integer ;

     // if not empty then preprocess data with smoothing and derivatives
     smooth     :   string  ; // = average 15  // fourier 15,50 remove complex  // %,power
     derivative :   string  ; // = fourier 2 : remove complex // fourier only available

     // not used:
     flipRange : string ; // section of e-vector of interest. if  flipRange = '' then do not do test
     positive  : boolean ; // if true then area of e-vect should be positive else area should be negative. Flip if not true.

     bB                 : TBatchBasics ;  // functions like : LeftSideOfEqual() etc
     pp                 : TPreprocess ;

     PCalResults        : TPCalResults  ;      // does the calculations

     allXData           : TSpectraRanges ;
     allYData           : TSpectraRanges ;  // for display in column 2 and 3 - The original data sets

//     scoresSpectra      : TSpectraRanges ;
//     eigenVSpectra      : TSpectraRanges ;
//     eigenValSpectra    : TSpectraRanges ;  // Eigenvalue = scores(PCx)' * scores(PCx)  ==  variance of each PC

     YresidualsSpectra  : TSpectraRanges ;
     regresCoefSpectra  : TSpectraRanges ;  // X Coefficients for regression with a cirtain number of PCs for known Y values
     predictedYPCR      : TSpectraRanges ;
     R_sqrd_PCR         : TSpectraRanges ;

     constructor Create(SDPrec : integer) ;  //
     destructor  Destroy; // override;
     procedure   Free ;

     // get input data from memo1 text. Returns final line number of String list
     function  GetBatchArguments(lineNum, iter : integer; tStrList : TStringList ) : string ;
     function  ProcessPCRBatchFile(inputX, inputY, inScores : TSpectraRanges)   : string ;  // this calls private functions and creates model
     procedure  SaveSpectra(filenameIn : string)  ;
  private
     function  GetAllXData( interleavedOrBlocked : integer;  sourceSpecRange : TSpectraRanges ) : string  ; // TBatch virtual method
     function  GetAllYData( interleavedOrBlocked : integer;  sourceSpecRange : TSpectraRanges )  : string  ; // TBatch virtual method
     function  PreProcessData(XdataExists : boolean) : string ; // override  ;
     function  CreatePCRDisplayData  : boolean ;   // lc is pointer to TGLLineColor type, holding the line colour TSpectraRange.LineColor
     procedure CheckResult(resultStringIn : string) ;
  end;
implementation


constructor TPCalBatch.Create(SDPrec : integer);  // need SDPrec
begin
   SDPrecPCR := SDPrec ;
   bB := TBatchBasics.Create ;
   pp := TPreprocess.Create ;
   PCalResults := TPCalResults.Create('PCR_Results.out',SDPrecPCR)  ;
   xDiskEQxData  := false ;
   YinXData := false ;
end ;


destructor  TPCalBatch.Destroy; // override;
begin

  YresidualsSpectra.Free ;
  regresCoefSpectra.Free ;
  predictedYPCR.Free ;
  R_sqrd_PCR.Free ;

  bb.Free;
  pp.Free ;
  PCalResults.Free ;

end ;

procedure TPCalBatch.Free;
begin
 if Self <> nil then Destroy;
end;




{
type = ILS

// input x and y data
x sample range = 1-686     // (ROWS)
x var range = 1-520        // (COLS)

y sample range = 1-686     // (ROWS)
y var range = 1-1          // (COLS)

number of PCs = 1-20

// pre-processing
mean centre = true
column standardise = false
smooth = average,15  // fourier,15,50,remove complex  // %,power
derivative = fourier, 2, remove complex, true, 1 // inputs: "diff type: 1st 2nd deriv etc: true = Hanning Window: 1 2 3 etc = zero fill"  N.B. type=fourier only available;

// EVects output
pos or neg range =              // 1200-1260 cm-1
positive or negative = positive
normalised EVects = true

// output
results file = PLS.out
}

function  TPCalBatch.GetBatchArguments( lineNum, iter : integer; tStrList : TStringList ) : string   ;
// return result is either:
// on success:  string version of line number
// on fail :    string of 'line number + ', error message'
// comma present indicates failure
var
 t1 : integer ;
 tstr1  : string ;
begin
       try
        // ********************** X data file name ******************************************
        // Only needed if Evects are input (so they can be projected against this XData to produce scores data)
             repeat
               inc(lineNum) ;
               tstr1 := bB.GetStringFromStrList(tStrList, lineNum) ;
             until (trim(tstr1) <> '') or (linenum > tStrList.Count)  ;
             if bB.LeftSideOfEqual(tstr1) = 'x data file' then
               xFilename :=  bB.RightSideOfEqual(tstr1) ;

        // ********************** Y data file name **********************************
             repeat
               inc(lineNum) ;
               tstr1 := bB.GetStringFromStrList(tStrList, lineNum) ;
             until (trim(tstr1) <> '') or (linenum > tStrList.Count)  ;
             if bB.LeftSideOfEqual(tstr1) = 'y data file' then
               yFilename :=  bB.RightSideOfEqual(tstr1) ;

       // **************** Scores or Evects input data file name ************************
             repeat
               inc(lineNum) ;
               tstr1 := bB.GetStringFromStrList(tStrList, lineNum) ;
             until (trim(tstr1) <> '') or (linenum > tStrList.Count)  ;
             if bB.LeftSideOfEqual(tstr1) = 'scores or evects filename' then
               ScoresOrEvectsFileName :=  bB.RightSideOfEqual(tstr1) ;

       // *********** Boolean value to say if the data is scores or eigenvectors  ********************
             repeat
               inc(lineNum) ;
               tstr1 := bB.GetStringFromStrList(tStrList, lineNum) ;
             until (trim(tstr1) <> '') or (linenum > tStrList.Count)  ;
             if bB.LeftSideOfEqual(tstr1) = 'data type' then
             begin
               if bB.RightSideOfEqual(tstr1) = 'scores'  then
                 isScoresThenTrue :=  true
               else
                 isScoresThenTrue :=  false ;
              end ;

        // ********************** X Samples ******************************************
        repeat
          inc(lineNum) ;
          tstr1 := bB.GetStringFromStrList(tStrList, lineNum) ;
        until (trim(tstr1) <> '') or (linenum > tStrList.Count)  ;
        if bB.LeftSideOfEqual(tstr1) = 'x sample range' then
          XsampleRange :=  bB.RightSideOfEqual(tstr1) ;

        // ********************** X Variables  ******************************************
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

        // ********************** Y in X data ******************************************
         repeat
           inc(lineNum) ;
           tstr1 := bB.GetStringFromStrList(tStrList, lineNum) ;
         until (trim(tstr1) <> '') or (linenum > tStrList.Count)  ;
         if bB.LeftSideOfEqual(tstr1) = 'y in x data' then
         begin
           if bB.RightSideOfEqual(tstr1) = 'true'  then
             YinXData :=  true
           else
             YinXData :=  false ;
         end ;

        // ********************** Y Samples ******************************************
        repeat
          inc(lineNum) ;
          tstr1 := bB.GetStringFromStrList(tStrList, lineNum) ;
        until (trim(tstr1) <> '') or (linenum > tStrList.Count)  ;
        if bB.LeftSideOfEqual(tstr1) = 'y sample range' then
          YsampleRange :=  bB.RightSideOfEqual(tstr1) ;

        // ********************** Y Variables  ******************************************
        repeat
          inc(lineNum) ;
          tstr1 := bB.GetStringFromStrList(tStrList, lineNum) ;
        until (trim(tstr1) <> '') or (linenum > tStrList.Count)  ;
        if bB.LeftSideOfEqual(tstr1) = 'y var range' then
          yVarRange    :=  bB.RightSideOfEqual(tstr1) ;  //  = 800-1800 cm-1

         // ********************** number of PCs ******************************************
         repeat
           inc(lineNum) ;
           tstr1 := bB.GetStringFromStrList(tStrList, lineNum) ;
         until (trim(tstr1) <> '') or (linenum > tStrList.Count)  ;
         if bB.LeftSideOfEqual(tstr1) = 'number of pcs' then
           PCsString :=  bB.RightSideOfEqual(tstr1)  ;

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

         // ********************** smooth ******************************************
         // smooth = average,15  // fourier,15,50,remove complex  // %,power
        repeat
          inc(lineNum) ;
          tstr1 := bB.GetStringFromStrList(tStrList, lineNum) ;
        until (trim(tstr1) <> '') or (linenum > tStrList.Count)  ;
        if bB.LeftSideOfEqual(tstr1) = 'smooth' then
          smooth :=  bB.RightSideOfEqual(tstr1) ;

        // ********************** derivative ******************************************
        // derivative = "fourier, 2, remove complex, true, 1" // inputs: "diff type: 1st 2nd deriv etc: true = Hanning Window: 1 2 3 etc = zero fill"  N.B. type=fourier only available;
        repeat
          inc(lineNum) ;
          tstr1 := bB.GetStringFromStrList(tStrList, lineNum) ;
        until (trim(tstr1) <> '') or (linenum > tStrList.Count)  ;
        if bB.LeftSideOfEqual(tstr1) = 'derivative' then
          derivative :=  bB.RightSideOfEqual(tstr1) ;


       // ********************** pos or neg range = 1200-1260 cm-1 ******************************************
       repeat
         inc(lineNum) ;
         tstr1 := bB.GetStringFromStrList(tStrList, lineNum) ;
       until (trim(tstr1) <> '') or (linenum > tStrList.Count)  ;
       if bB.LeftSideOfEqual(tstr1) = 'positive or negative' then
         flipRange :=  bB.RightSideOfEqual(tstr1) ;

       // **********************  positive or negative ******************************************
       repeat
         inc(lineNum) ;
         tstr1 := bB.GetStringFromStrList(tStrList, lineNum) ;
       until (trim(tstr1) <> '') or (linenum > tStrList.Count)  ;
       if bB.LeftSideOfEqual(tstr1) = 'autoexclude' then
       if bB.RightSideOfEqual(tstr1) = 'positive'  then
           positive := true
       else
           positive :=  false ;


       // ********************** normalised output of scores and EVects ******************************************
       repeat                     // this is not used at preset
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
         result := inttostr(lineNum) + ', ILS batch input conversion error' +  #13 ;
      end ;
      end ;
end ;





function  TPCalBatch.GetAllXData( interleavedOrBlocked : integer;  sourceSpecRange : TSpectraRanges ) : string  ; // TBatch virtual method
var
  t2 : integer ;
// TBatch virtual method
// sourceMatrix is either interleaved (interleavedOrBlocked =1) or block structure (interleavedOrBlocked =2)
  t1 : integer ;
  s1 : single ;
  d1 : double ;
begin
  result := '' ;
  try

  // converts cm-1 or other units into range of data positions in matrix (i.e. 800-1600 cm-1  ->  228-526 )
  if xVarRangeIsPositon = false then
  begin
      self.xVarRange :=  bB.ConvertValueStringToPosString(xVarRange, sourceSpecRange.xCoord) ;
      if  self.xVarRange = '' then
      begin
//        MessageDlg('TIPCRPredict.GetAllXData() Error...'#13'x var range values not appropriate: '+xVarRange,mtError, [mbOK], 0)  ;
        result := 'ILS input error: x var range values not appropriate: '  + #13  ;
        exit ;
      end ;
  end ;

  // *****************   Get the y data of TSpectraRanges object *****************
  // set up the string of rows to collect

  // sampleRange string is open ended (e.g. '12-')
  if pos('-',XsampleRange) = length(trim(XsampleRange)) then
    XsampleRange := XsampleRange + inttostr(sourceSpecRange.yCoord.numRows) ;

  // if the data is exactly as recieved in sourceSpecRange then do not copy (saves memory)
  if (sourceSpecRange.yCoord.numRows = sourceSpecRange.yCoord.GetTotalRowsColsFromString(XsampleRange)) and (sourceSpecRange.yCoord.numCols = sourceSpecRange.yCoord.GetTotalRowsColsFromString(xVarRange))then
  begin
    allXData :=  sourceSpecRange ;
    xDiskEQxData := true ;
    exit ;
  end;

  // otherwise copy the data wanted
  allXData := TSpectraRanges.Create(sourceSpecRange.yCoord.SDPrec,1,1) ;

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
        result := 'ILS input error: fetching x data failed'   + #13 ;
  end ;
  end ;


end ;




function  TPCalBatch.GetAllYData( interleavedOrBlocked : integer;  sourceSpecRange : TSpectraRanges ) : string  ; // TBatch virtual method
var
  t1, t2 : integer ;
  s1 : single ;
  d1 : double ;
begin
  result := '' ;
  try

  // *****************   Get the y data of TSpectraRanges object *****************
  if pos('-',YsampleRange) = length(trim(YsampleRange)) then       // sampleRange string is open ended (e.g. '12-')
    YsampleRange := YsampleRange + inttostr(sourceSpecRange.yCoord.numRows) ;

  allYData := TSpectraRanges.Create(sourceSpecRange.yCoord.SDPrec,1,1) ;  

  // *****************  This actually retrieves the data  ********************
  allYData.yCoord.FetchDataFromTMatrix( YsampleRange, yVarRange , sourceSpecRange.yCoord ) ;
  if sourceSpecRange.yImaginary <> nil then
  begin
    allYData.yImaginary := TMatrix.Create(allYData.yCoord.SDPrec) ;
    allYData.yImaginary.FetchDataFromTMatrix( YsampleRange, yVarRange , sourceSpecRange.yImaginary ) ;
  end ;


  // *****************   Get the x data of TSpectraRanges object - X data can be disjoint (it just will display disjoint) *****************
  allYData.xString := sourceSpecRange.xString ;
  allYData.yString := sourceSpecRange.yString ;
  allYData.xCoord.numCols :=  allYData.yCoord.numCols ;
  allYData.xCoord.numRows := 1 ;
  allYData.xCoord.Filename := resultsFileName ;
  allYData.xCoord.F_Mdata.SetSize(allYData.xCoord.numCols * 1 * allYData.xCoord.SDPrec) ;
  allYData.xCoord.F_Mdata.Seek(0,soFromBeginning) ;
  // COPY X DATA VALUES FROM INPUT TSPECTRARANGES TO NEW TSPECTRARANGE in new row
  t2 := allYData.xCoord.GetTotalRowsColsFromString(yVarRange, allYData.xCoord.Fcols) ;
  allYData.xCoord.Fcols.Seek(0,soFromBeginning) ;
  for t1 := 1 to allYData.xCoord.numCols do
  begin
     allYData.xCoord.Fcols.Read(t2,4) ;
     sourceSpecRange.xCoord.F_Mdata.Seek(t2*sourceSpecRange.xCoord.SDPrec,soFromBeginning) ;
     if sourceSpecRange.xCoord.SDPrec = 4 then
     begin
        sourceSpecRange.xCoord.F_Mdata.Read(s1, 4) ;
        allYData.xCoord.F_Mdata.Write(s1,4) ;
     end
     else
     if sourceSpecRange.xCoord.SDPrec = 8 then
     begin
        sourceSpecRange.xCoord.F_Mdata.Read(d1, 8) ;
        allYData.xCoord.F_Mdata.Write(d1,8) ;
     end ;
  end ;

  except
  begin
        result := 'ILS input error: fetching y data failed'  + #13 ;
  end ;
  end ;

end ;


function  TPCalBatch.PreProcessData(XdataExists : boolean) : string ;
{  meanCentre, colStd : boolean ;
   smooth       :   string   // = average 15  // fourier 15,50 remove complex  // %,power
   derivative   :   string   // = fourier 2 : remove complex // fourier only available
}
begin
   writeln('Mean Centre Y data  ') ;
   self.allYData.yCoord.MeanCentre ; // Y data has to be mean centred (i think)

   if XdataExists then
   begin
     if  meanCentre then
     begin
        writeln('Mean Centre X data  ') ;
        self.allXData.yCoord.MeanCentre ;
     end;

     if  colStd then
     begin
        writeln('Column standardise X data  ') ;
        self.allXData.yCoord.ColStandardize ; // not sure what to do with y data with col standardise
     end;


     if length(trim(smooth)) > 0 then
     begin
        writeln('Smooth X data  ') ;
        result := pp.Smooth(smooth,allXData) ;
     end ;

     if length(trim(derivative)) > 0 then
     begin
        writeln('Differentiate X data  ') ;
        if length(result) > 0 then
          result := result + #13 + pp.Differentiate(derivative,allXData)
        else
          result :=  pp.Differentiate(derivative,allXData)   ;
     end  ;
   end ;

   if length(result) > 0 then
     result := result +  #13 ;
     
end ;





procedure   TPCalBatch.CheckResult(resultStringIn : string) ;
begin
     if  length(resultStringIn) > 0 then
     begin
       writeln('ProcessPCRBatchFile failed:' + #13 + resultStringIn ) ;
       exit ;
     end ;
end ;


function  TPCalBatch.ProcessPCRBatchFile(inputX, inputY, inScores : TSpectraRanges)  : string ;  // this calls all above functions and creates model
var
  resultString : string ;
begin
   result := '' ;
   // N.B. if YinXData is true then inputX points to inputY
   try
     // only need X data if we need to project Evectors onto it so as to make scaores data.

     if inputX <> nil then
     begin
       writeln('Getting X data  ') ;
       resultString := resultString + GetAllXData( interleaved,  inputX ) ;  // Selected Y data is placed in allXData
       if (xDiskEQxData  = false) and (YinXData = false) then  // input (disk) file and matrix data are identical so do not delete
         inputX.Free ;
     end;

     // Selected Y data is placed in allYData
     writeln('Getting Y data  ') ;
     resultString := resultString + GetAllYData( interleaved,  inputY ) ;

     if (xDiskEQxData  = false) and (YinXData = true) and (inputX <> nil) then  // input (disk) file and matrix data are identical so do not delete
       inputX.Free
     else
       inputY.Free ;

     writeln('Preprocessing data ') ;
     resultString := resultString + PreProcessData( (inputX <> nil) )   ;
     CheckResult(resultString) ;
     writeln('Finished preprocessing') ;

     if allXData.yImaginary = nil then  // do not have code for complex data type
     begin
       writeln('Create ILS model ') ;
       if isScoresThenTrue then
         PCalResults.CreateILSModel(nil, allYData.yCoord , inScores.yCoord, PCsString )  // PCsString has been checked
       else
         PCalResults.CreateILSModel(allXData.yCoord, allYData.yCoord, inScores.yCoord, PCsString ) ; // PCsString has been checked

     end
     else  // data is complex
     begin
       writeln('ILS code does not accept complex data. Remove imaginary component first') ;
       exit ;
     end ;

     CreatePCRDisplayData ;  // may have problems with this
     if allXData <> nil then allXData.Free ; // this will remove inputX.Free if "xDiskEQxData = true"
     allYData.Free ; // created in  GetAllYData
     inScores.Free ;

    except on Exception do
    begin

       result := 'Exception in PLS1 ProcessPLSBatchFile()' ;
    end ;
    end ;
end ;




function  TPCalBatch.CreatePCRDisplayData  : boolean ;
var
 t1 : integer ;
 s1 : single ;
 d1 : double ;
 tstr : string ;
begin
      // 1/ ****  Create display objects for calculated data ****  Then just add Y data matric from PLSResultsObject
   YresidualsSpectra := TSpectraRanges.Create(self.allXData.yCoord.SDPrec,allXData.yCoord.numRows                   ,  numPCsPCR  )  ; // numPCs by number of Samples
   regresCoefSpectra:= TSpectraRanges.Create(self.allXData.yCoord.SDPrec,  numPCsPCR                  , allXData.yCoord.numCols )  ;
    predictedYPCR  := TSpectraRanges.Create(self.allXData.yCoord.SDPrec,  numPCsPCR                  , allXData.yCoord.numRows )  ;
    R_sqrd_PCR       := TSpectraRanges.Create(self.allXData.yCoord.SDPrec,  1                       , numPCsPCR                  )  ;

    // 2/ ****  Copy calculated data to output display objects ****

    regresCoefSpectra.yCoord.CopyMatrix( PCalResults.RegressionCoef ) ;
    predictedYPCR.yCoord.CopyMatrix( PCalResults.PredictedY ) ;
    YresidualsSpectra.yCoord.CopyMatrix( PCalResults.YResidualsPCR )   ;
    R_sqrd_PCR.yCoord.CopyMatrix( PCalResults.R_sqrd_PCR ) ;


    if YresidualsSpectra.yCoord.complexMat = 2 then
    begin
         YresidualsSpectra.yImaginary := TMatrix.Create2(YresidualsSpectra.yCoord.SDPrec, YresidualsSpectra.yCoord.numRows, YresidualsSpectra.yCoord.numCols) ;
         YresidualsSpectra.yCoord.MakeUnComplex( YresidualsSpectra.yImaginary ) ;
         // not sure if these are ever going to be complex
         regresCoefSpectra.yImaginary := TMatrix.Create2(regresCoefSpectra.yCoord.SDPrec, regresCoefSpectra.yCoord.numRows, regresCoefSpectra.yCoord.numCols) ;
         regresCoefSpectra.yCoord.MakeUnComplex( regresCoefSpectra.yImaginary ) ;
         predictedYPCR.yImaginary := TMatrix.Create2(predictedYPCR.yCoord.SDPrec, predictedYPCR.yCoord.numRows, predictedYPCR.yCoord.numCols) ;
         predictedYPCR.yCoord.MakeUnComplex( predictedYPCR.yImaginary ) ;
    end ;

    // 3/ ****  Create X data for output display objects  ****
    // A/ add 'sample number' to scores matrix (may be able to reference a 'string' value from this value in the future)

    YresidualsSpectra.SeekFromBeginning(3,1,0) ;

    // B/ add wavelength values as xCoord for EVects matrix storage
    allXData.SeekFromBeginning(3,1,0) ;
    allYData.SeekFromBeginning(3,1,0) ;

    regresCoefSpectra.SeekFromBeginning(3,1,0) ;
    predictedYPCR.SeekFromBeginning(3,1,0) ;
    R_sqrd_PCR.SeekFromBeginning(3,1,0) ;

    if self.allXData.xCoord.SDPrec = 4 then
    begin
      for t1 := 1 to allXData.yCoord.numCols do
      begin
        allXData.xCoord.F_Mdata.Read(s1,4) ;
        regresCoefSpectra.xCoord.F_Mdata.Write(s1,4) ;
      end  ;
    end
    else
    if self.allXData.xCoord.SDPrec = 8 then
    begin
      for t1 := 1 to allXData.yCoord.numCols do
      begin
        allXData.xCoord.F_Mdata.Read(d1,8) ;
        regresCoefSpectra.xCoord.F_Mdata.Write(d1,8) ;
      end  ;
    end ;

    // C/ create x coord data for eigenValSpectra and R_sqrd_PLS and YResiduals (one point for each PC)
    YresidualsSpectra.xCoord.F_Mdata.Seek(0,soFromBeginning) ;
    if self.allXData.yCoord.SDPrec = 4 then
    begin
       for t1 := 1 to self.numPCsPCR do
       begin
         s1 := t1 ;
         R_sqrd_PCR.xCoord.F_Mdata.Write(s1,4) ;
         YresidualsSpectra.xCoord.F_Mdata.Write(s1,4) ;
       end ;
    end
    else
    if self.allXData.yCoord.SDPrec = 8 then
    begin
      for t1 := 1 to self.numPCsPCR do
      begin
        d1 := t1 ;
        R_sqrd_PCR.xCoord.F_Mdata.Write(d1,8) ;
        YresidualsSpectra.xCoord.F_Mdata.Write(d1,8) ;
      end
    end ;

  // predictedYPLS
  // D/ create x coord data for predictedYPLS (one point for each sample)
    predictedYPCR.yCoord.Transpose ;
    predictedYPCR.xCoord.F_Mdata.Seek(0,soFromBeginning) ;
    allYData.SeekFromBeginning(3,1,0) ;
    if allYData.yCoord.SDPrec = 4 then
    begin
       for t1 := 1 to allYData.yCoord.numRows do
       begin
         allYData.yCoord.F_Mdata.Read(s1,4) ;
         predictedYPCR.xCoord.F_Mdata.Write(s1,4) ;
       end ;
    end
    else
    if allYData.yCoord.SDPrec = 8 then
    begin
      for t1 := 1 to allYData.yCoord.numRows  do
      begin
        allYData.yCoord.F_Mdata.Read(d1,8) ;
        predictedYPCR.xCoord.F_Mdata.Write(d1,8) ;
      end
    end ;

    // reset data to first positions

    YresidualsSpectra.SeekFromBeginning(3,1,0) ;
    regresCoefSpectra.SeekFromBeginning(3,1,0) ;
    predictedYPCR.SeekFromBeginning(3,1,0) ;
    R_sqrd_PCR.SeekFromBeginning(3,1,0) ;

    tstr := copy(self.xFilename,1,pos(extractfileext(self.xFilename),self.xFilename))  ;

end ;



procedure TPCalBatch.SaveSpectra(filenameIn : string)  ;
begin
    regresCoefSpectra.SaveSpectraRangeDataBinV2(filenameIn+'_regCoefILS.bin') ;
    predictedYPCR.SaveSpectraRangeDataBinV2(filenameIn+'_predictedYILS.bin') ;
    YresidualsSpectra.SaveSpectraRangeDataBinV2(filenameIn+'_residualsYILS.bin') ;
    R_sqrd_PCR.SaveSpectraRangeDataBinV2(filenameIn+'_R_sqrd_ILS.bin') ;
end ;


end.
