unit TPLMAnalysisUnit ;

interface

uses
  classes, SysUtils, Dialogs,  TMatrixObject, RegressionObjects,
  TBatchBasicFunctions, TSpectraRangeObject ;


type
  TPLMAnalysis  = class
  public
     numX, numY : integer ;
     numAngles : integer ;
     angleFloatStrm : TMemoryStream; // contains angles at which polariser was set (in Degrees)
     totalSamples : integer ; // = numX * numY * numAngles
     actualDepth : single ;
     pixelSpacing : single ;
     normaliseDepth : boolean ;
     boneToSurface : boolean ;  // bone to surface = true surface to bone = false
     resultsFileName : string ;

     bB : TBatchBasics ;  // functions like : LeftSideOfEqual() etc
     regressionObject :  TRegression ;

     // TSpectraRanges objects for graphing. These objects will be stored in StringGrid1.Objects[] cells.
     // For 1D line scan data these are simple X-Y plots of 'value Vs Position'
     allXData : TSpectraRanges ;
     anglePlot: TSpectraRanges ;
     rangePlot : TSpectraRanges ;
     offsetPlot : TSpectraRanges ;
     RPlot : TSpectraRanges ;

     constructor Create(SDPrec : integer) ;
     destructor  Destroy; // override;
     procedure   Free;

     function  GetPLMBatchArguments(lineNum, iter : integer; tStrList : TStringList ) : integer ; // get input data from memo1 text. Returns final line number of String list
     function  GetAnglesAsFloatStream(angleStr : string) : TMemoryStream ;  // Used by GetIRPolBatchArguments;

     function  ProcessPLMStackData( lc : pointer ) : boolean ;
     function  GetAllXData( sourceSpecRange : TSpectraRanges ) : boolean ;

     // return value is angle of first peak maximum => the angle of maximum absorption
     function FitSineData(xyData : TMatrix; frequency : single; minStep : single) : TMatrix ;
     function SumOfSquaresOfDifferences(direction, param : integer; step : single; xyData : TMatrix; paramsStr : TMemoryStream;  SSDiff_i : single) : single ;
     function SumOfSquaresOfDirection(direction, param : integer; step : single; xyData : TMatrix; paramsStr : TMemoryStream;  SSDiff_i : single) : integer ;

     function  ReturnExclusionString(inMat : TMatrix; numStddevs : single; colNum : integer) : string ;  // this is identical to  AutoExcludeData()
     function  AutoExcludeData(inMat : TMatrix; numStddevs : single; colNum : integer ) : TMatrix;
  private
end;


implementation


constructor TPLMAnalysis.Create(SDPrec : integer) ;
begin
   angleFloatStrm := TMemoryStream.Create ;
   allXData := TSpectraRanges.Create(SDPrec,0,0,nil) ;
   bB := TBatchBasics.Create ;
   regressionObject := TRegression.Create(SDPrec) ;
end ;

destructor TPLMAnalysis.Destroy ;
begin
   angleFloatStrm.Free ;

   anglePlot.Free ;
   rangePlot.Free ;
   offsetPlot.Free ;
   RPlot.Free ;

   bB.free ;

   inherited Destroy;
end ;

procedure TPLMAnalysis.Free;
begin
 regressionObject.Free ; 
 if Self <> nil then
   Destroy;
end;


function TPLMAnalysis.GetAllXData( sourceSpecRange : TSpectraRanges ) : boolean ;
begin

  sourceSpecRange.CopySpectraObject(allXData) ;

end ;


function TPLMAnalysis.GetAnglesAsFloatStream(angleStr : string) : TMemoryStream ;
var
  t1, t2, tNumCols, tcol : integer ;
  delimeter, tStr2 : string ;
  ts1 : single ;
begin
    result := TMemoryStream.Create ;

    t1 := pos(',',angleStr) ;  // start choosing delimeter
    if t1 > 0 then
       delimeter :=   ','    // comma
    else
    begin
         t1 := pos(#32,angleStr)  ;
         if t1 > 0  then delimeter :=  #32    // space
         else
         begin
           t1 := pos(#9,angleStr)  ;
           if t1 > 0 then delimeter :=   #9     // tab
           else
           begin
              messagedlg('Delimeter is not comma, space or tab' ,mtError,[mbOK],0) ;
              exit ;  // have to free result TmemoryStream in calling code.
           end ;
          end ;
    end ;   // end choosing delimeter

    tNumCols := 0 ;
    inc(tNumCols) ;
    tStr2 := angleStr ;
    t1 := pos(delimeter,tStr2)+1 ;
    while t1 > 1 do
    begin
       t2 := length(tStr2) ;
       tStr2 := copy(tStr2,t1,t2) ;
       tStr2 := trim(tStr2) ;
       t1 := pos(delimeter,tStr2)+1 ;
       inc(tNumCols) ;
    end ;

    result.SetSize(tNumCols*4) ;

    for tcol := 0 to tNumCols-1 do
      begin
          angleStr := trim(angleStr) ;
          t1 := pos(delimeter,angleStr) ;
          t2 := length(angleStr) ;
          if tcol < tNumCols-1 then
            tStr2 := copy(angleStr,1,t1-1)
          else
            tStr2 := angleStr ;
          angleStr := copy(angleStr,t1+1,t2) ;
          if length(tStr2) > 0 then
          begin
            ts1 := strtofloat(tStr2) ;
            result.Write(ts1,4) ;
          end ;
      end ;
end ;



function TPLMAnalysis.GetPLMBatchArguments(lineNum, iter : integer; tStrList : TStringList ) : integer ;
// lineNum : is the line number of the input batch text list (tStrList) that we are reading in.
// iter : used for code error messages
// tStrList : is the string list we are getting lines from
var
   t2 : integer ;
   tstr1, tstr2, anglesStr  : string ;
   resBool : boolean ;

{File input is of this format:

   type = PLM STACK  // Does PCA on each analysis point then fits cos^2 to scores') ;
   number of x positions = 512      // numX
   number of y positions = 256      // numY
//   interleaved = 1  // (or 2)') ;
   start row = 1
//   pcs to fit = 1-2') ;
//   x var range = 800-1800 cm-1  // can be variable number or value found in x coordinate (space essential between value and units) ') ;
   num angle = 19
   angles = -45,-40,-35,-30,-25,-20,-15,-10,-5,-0.0,5,10,15,20,25,30,35,40,45  // delete one of these
   angles = 0,10,20,30,40,50,60,70,80,90                                       // delete one of these
//   pos or neg range = 1200-1260 cm-1  // can be variable number or value found in x coordinate (space essential between value and units) ')
//   positive or negative = negative') ;
//   autoexclude = 0.0   // 0.75 ') ;
//   exclude from PCs = 0  // 1') ;
   pixel spacing = 1.3587  // distance between pixels
   bone to surface = true  //
   actual depth = 0  // depth in mm
   normalise depth = false  // 1
//   mean centre = true') ;
//   column standardise = false') ;
//   normalised output = false
   results file = PLM_angles.out') ;


}
begin

             // ********************** load number of x positions (number of 'pixels' in x direction) ******************************************
             repeat
               inc(lineNum) ;
               tstr1 := bB.GetStringFromStrList(tStrList, lineNum) ;
             until (trim(tstr1) <> '') or (linenum > tStrList.Count)  ;
             if bB.LeftSideOfEqual(tstr1) = 'number of x positions' then
               numX :=  strtoint(bB.RightSideOfEqual(tstr1)) ;
             // ********************** load number of y positions (number of 'pixels' in y direction) ******************************************
             repeat
               inc(lineNum) ;
               tstr1 := bB.GetStringFromStrList(tStrList, lineNum) ;
             until (trim(tstr1) <> '') or (linenum > tStrList.Count)  ;
             if bB.LeftSideOfEqual(tstr1) = 'number of y positions' then
               numY :=  strtoint(bB.RightSideOfEqual(tstr1)) ;

             // ********************** load number of angles  ******************************************
             inc(lineNum) ;
             tstr1 := bB.GetStringFromStrList(tStrList, lineNum) ;
             if bB.LeftSideOfEqual(tstr1) = 'num angle' then
               numAngles :=  strtoint(bB.RightSideOfEqual(tstr1)) ;
             // ********************** load angles of polariser relative to surface normal (analyser is 90 degrees to this) ******************************************
             inc(lineNum) ;
             tstr1 := bB.GetStringFromStrList(tStrList, lineNum) ;
             if bB.LeftSideOfEqual(tstr1) = 'angles' then
             begin
               anglesStr :=  bB.RightSideOfEqual(tstr1) ;
               if length(anglesStr) > 0 then
                 angleFloatStrm :=  GetAnglesAsFloatStream(anglesStr) ;
               if (angleFloatStrm.Size div 4) <> numAngles then
                 begin
                   messagedlg('Number of angles ('+inttostr(numAngles)+') did not equal number in list ('+ inttostr(angleFloatStrm.Size div 4)+') (iteration = '+inttostr(iter)+')' ,mtinformation,[mbOK],0) ;
                   exit ;
                 end ;
             //  inc(t1) ;
             end ;

             // ********************** Pixel spacing ******************************************
             repeat
               inc(lineNum) ;
               tstr1 := bB.GetStringFromStrList(tStrList, lineNum) ;
             until (trim(tstr1) <> '') or (linenum > tStrList.Count)  ;
             if bB.LeftSideOfEqual(tstr1) = 'pixel spacing' then
               pixelSpacing :=  strtofloat(bB.RightSideOfEqual(tstr1)) ;  // so, if an outlier exists in any of these PCs, then the spectra are excluded and the PCA redone.

             // ********************** bone to surface = true surface to bone = false ******************************************
             repeat
               inc(lineNum) ;
               tstr1 := bB.GetStringFromStrList(tStrList, lineNum) ;
             until (trim(tstr1) <> '') or (linenum > tStrList.Count)  ;
             if bB.LeftSideOfEqual(tstr1) = 'bone to surface' then
               if bB.RightSideOfEqual(tstr1) = 'true'  then
                   boneToSurface := true
                else
                   boneToSurface :=  false ;
             // ********************** Actual depth ******************************************
             repeat
               inc(lineNum) ;
               tstr1 := bB.GetStringFromStrList(tStrList, lineNum) ;
             until (trim(tstr1) <> '') or (linenum > tStrList.Count)  ;
             if bB.LeftSideOfEqual(tstr1) = 'actual depth' then
               actualDepth :=  strtofloat(bB.RightSideOfEqual(tstr1)) ;  // so, if an outlier exists in any of these PCs, then the spectra are excluded and the PCA redone.
             // ********************** normalise Depth ******************************************
             repeat
               inc(lineNum) ;
               tstr1 := bB.GetStringFromStrList(tStrList, lineNum) ;
             until (trim(tstr1) <> '') or (linenum > tStrList.Count)  ;
             if bB.LeftSideOfEqual(tstr1) = 'normalise depth' then
               if bB.RightSideOfEqual(tstr1) = 'true'  then
                   normaliseDepth := true
                else
                   normaliseDepth :=  false ;

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


             totalSamples := numX * numY * numAngles ;
             result := lineNum ;

end ;




function TPLMAnalysis.ProcessPLMStackData(  lc : pointer ) : boolean ;
// lc : pointer  is pointer to TGLLineColor GLFloat array
{ These are the old input parameters for this function that are now members of the TIRPolAnalysis object:
   numX, numY, firstSpecta : integer; xVarRange, PCsString,
   resultsFileName : string; angleFloatStrm : TMemoryStream; autoExclude : single;
   excludeIter : integer;  meanCentre, colStd : boolean
}
var
  t1, t2, t3, t4, t5, t6, t7, t8: integer ;
  lineNum : integer ;

  currentFirstSpectra : integer ;
  rowsToFetchString : string ;


  inMatrix : boolean ;

  s1, s2 : single ;
  pcsToFitMemStrm : TMemoryStream ;
  highestPC, numPCs : integer ;

  max_angle, range, offset, r_sqrd : single ;
  tMat, tmat2, resMat : TMatrix ;
  ts1, ts2, angleUsed, avearge1 : single ;
  tstring : string ;
  d1, d2 : double ;
  tjump : integer ;

begin
try
try
  result := true ;
  // ******   Determine number of PCs to create (can not be greater than number of angles at each position)  *******

  tMat := TMatrix.Create2(1,numAngles,1) ;  // numAngles is equal to number of spectra in each PCA (= num rows in scores matrix)

  // ******   Create TSpectraRanges for display of data *******
  // 1/ simple X-Y data : variable Vs Position
  anglePlot      := TSpectraRanges.Create(self.allXData.yCoord.SDPrec div 4, numY, numX , lc)  ;   // numX = number of positions data collected from
  rangePlot      := TSpectraRanges.Create(self.allXData.yCoord.SDPrec div 4, numY, numX , lc)  ;
  offsetPlot     := TSpectraRanges.Create(self.allXData.yCoord.SDPrec div 4, numY, numX , lc)  ;
  RPlot          := TSpectraRanges.Create(self.allXData.yCoord.SDPrec div 4, numY, numX , lc)  ;


  // *************** SET X DATA ********************
  // 1/ add position value to each 'value-pos' type of TSpectraRanges object
  if boneToSurface then
  begin
    ts1 := pixelSpacing * (numX -1) ; //xxxx   added -1 to the numX bit
    pixelSpacing := pixelSpacing * -1 ;
  end
  else
  begin
    ts1 := 0 ;
  end ;
  if (actualDepth = 0)  then
  begin
    normaliseDepth := false ;
  end ;

  for t1 := 0 to numX -1 do   // need to add multi Y data if numY > 1
  begin
    ts2 := ts1 + ( t1 * pixelSpacing)  ;
    if normaliseDepth then
       ts2 := ts2 / actualDepth ;
    if self.allXData.yCoord.SDPrec = 4 then
    begin
      anglePlot.xCoord.F_Mdata.Write(ts2,4) ;
      rangePlot.xCoord.F_Mdata.Write(ts2,4) ;
      offsetPlot.xCoord.F_Mdata.Write(ts2,4) ;
      RPlot.xCoord.F_Mdata.Write(ts2,4) ;
    end
    else
    if self.allXData.yCoord.SDPrec = 8 then
    begin
      d2 :=   ts2 ;
      anglePlot.xCoord.F_Mdata.Write(d2,8) ;
      rangePlot.xCoord.F_Mdata.Write(d2,8) ;
      offsetPlot.xCoord.F_Mdata.Write(d2,8) ;
      RPlot.xCoord.F_Mdata.Write(d2,8) ;
    end
  end ;

  allXData.SeekFromBeginning(3,1,0) ;


  //  ************  seek from beginning ******************
  anglePlot.SeekFromBeginning(3,1,0) ;
  rangePlot.SeekFromBeginning(3,1,0) ;
  offsetPlot.SeekFromBeginning(3,1,0) ;
  RPlot.SeekFromBeginning(3,1,0) ;



  //  ************  start PCA and Sine fit section ******************


  for t1 := 1 to  numY do // for y each pixel
  begin
    rowsToFetchString := '' ;
    for t3 := 0 to numAngles - 1 do
      rowsToFetchString := rowsToFetchString + inttostr((t1-1) + t3*numY) ;

    for t2 := 1 to  numX do // for x each pixel
    begin

       // *****************  For each pixel in stack, fit a sine function to the PCA scores *****************
       tMat.Free ; // this holds a single set of Scores at each angle
       tMat := TMatrix.Create2(1,numAngles,1) ;  // # of rows =  numAngles  => single column vector
       tMat.F_Mdata.Seek(0, soFromBeginning) ;

       // 1/ create and add x data (angle, in radians)
       angleFloatStrm.Seek(0, soFromBeginning) ;
       for  t4 := 1 to numAngles do
       begin
          angleFloatStrm.Read(s1,4) ;
          s2 := (s1/180) * Pi ;
          tMat.F_Mdata.Write(s2,4) ;
       end ;

       // 2/ add y data from originsl allXCoord matrix
       tMat.AddColumnsToMatrix(rowsToFetchString, inttostr(t2),allXdata.yCoord)  ;


       // **************** Fit the data to sin(angle)^2 curve *****************************
       resMat := self.FitSineData(tMat,2.0, 0.001) ;    // 2.0 = frequency  // autoExMat returns model approx of scores data


       // **************** add data to output TSpectrRanges  *************************
       resMat.Frows.Seek(0,soFromBeginning) ;
       resMat.Frows.Read(max_angle,4) ;
       resMat.Frows.Read(range,4)  ;
       resMat.Frows.Read(offset,4) ;
       resMat.Frows.Read(r_sqrd,4) ;


       anglePlot.yCoord.F_Mdata.Write(max_angle,4) ;
       rangePlot.yCoord.F_Mdata.Write(range,4) ;
       offsetPlot.yCoord.F_Mdata.Write(offset,4) ;
       RPlot.yCoord.F_Mdata.Write(r_sqrd,4) ;


       resMat.Free ; // has to be freed each time FitSine() is called

     end ;
  end ;

finally
begin
  tMat.Free ;
end ;
end ;
except
   result := false ;
end ;



end ;




// xyData is list of x (= in radians, the angle of the polariser) and y values  (from PCA scores)
// Minimise sum of squares of differences between experimental and model data
function TPLMAnalysis.FitSineData(xyData : TMatrix; frequency : single; minStep : single) : TMatrix ;  // return value is angle (in radians) of firt peak maximum => the angle of maximum absorption
var
  t1, t2 : integer ;
  s1, s2 : single ;
//  R_i, R_f : single ;  // only need single precision version of these
  R_pearsons : single ;
  offset_scores, absolute_score, phase, range, pc10_score : single ;
  x_ymax_s, ymax, ymin : single ;
  numData : integer ;
  maxMinValue : TMaxMin ;  // this has to be disposed of at end of function
  R_matrix, modelData : TMatrix ;
  add, sub : integer ;
  iteration : integer ;
  param : integer ;
  paramStrm, paramMinimised : TMemoryStream ;
  step : single ;  // used for step value - starts at (100 * minStep) and then (10* minStep) then = minStep
  step_num : integer ; // fit is done in 3 steps, course step, medium step, fine step - flag for which step is happening
  minimised, allMinimised : boolean ;
  tstrList : TStringList ;
  max_angle : single ;
//  y_int_i, y_int_f : single ;
//  slope_i, slope_f, slope_max : single ;
//  covar_i, covar_f : single ;
  SSDiff_i, SSDiff_f : single ;
begin
  if frequency <> 0 then
  begin
    maxMinValue := xyData.GetMinAndMaxValAndPos(0, 2) ; // 0 means all rows, 2 means 2nd column

    t1 := integer((maxMinValue.GetDataPointer(4)^))-4 ;
    xyData.F_Mdata.Seek(t1 ,soFromBeginning) ; // the -4 is so we get the x data (which preceeds the max Y data position by 4 (or 8 for double) bytes)
    xyData.F_Mdata.Read(x_ymax_s, 4) ;
//    phase :=  x_ymax_s  + ((Pi /2) / frequency) ;
    phase := 0.0 ;
    range :=  (single(maxMinValue.GetDataPointer(2)^) - single(maxMinValue.GetDataPointer(1)^)) / 2  ; // ==  (ymax - ymin) / 2
    pc10_score :=  range * 0.1 ;

    absolute_score :=  single(maxMinValue.GetDataPointer(1)^)  ;
    absolute_score := abs(absolute_score) ;
    xyData.F_Mdata.Seek(4,soFromBeginning) ;
    for t1 := 1 to  xyData.numRows do
    begin                                  // offset scores so cos^2 function will fit OK (cos^2 can not fit negative values)
       xyData.F_Mdata.Read(s1,4) ;
       s1 := s1 + absolute_score + pc10_score;    // add 10% so lowest point not on zero ( take it away later )
       xyData.F_Mdata.Seek(-4,soFromCurrent) ;
       xyData.F_Mdata.Write(s1,4) ;
       xyData.F_Mdata.Seek(4,soFromCurrent) ;
    end ;

    maxMinValue.Free ; // has to be freed after creation in GetMinAndMaxValAndPos() function

    xyData.Average ;
    xyData.F_MAverage.Seek(4,soFromBeginning) ;
    xyData.F_MAverage.Read(offset_scores,4) ;

    // start of iterative minimisation
    iteration := 1 ;
    param := 1 ;
    paramStrm := TMemoryStream.Create ;
    paramStrm.SetSize(xyData.SDPrec * 4)  ;  // change 4 to the number of parameters for model
    paramStrm.Write(phase ,4) ; // was offset
    paramStrm.Write(range,4) ;
    paramStrm.Write(offset_scores,4) ;
    paramStrm.Write(frequency,4) ;
    paramStrm.Seek(0,soFromBeginning) ;
    paramMinimised := TMemoryStream.Create ;
    paramMinimised.SetSize(sizeof(integer) * 2)  ;  // change 3 to the number of parameters for model
    t2 := 0 ;
    for t1 := 1 to 3 do   //
      paramMinimised.Write(t2,4) ;  // set flag for each parameter as NOT minimised (=0)
    minimised := false ;
    step := 100 * minStep ;
    step_num := 1 ;

    SSDiff_i := SumOfSquaresOfDifferences(1,param,0.0,xyData,paramStrm,-1.0) ;

    while (iteration < 1000) and (minimised = false) do
    begin
        add := SumOfSquaresOfDirection(1,param,step,xyData,paramStrm,SSDiff_i) ;
        if add <> 0 then
        begin
          SSDiff_f := SumOfSquaresOfDifferences(add,param,step,xyData,paramStrm,SSDiff_i) ;
          while SSDiff_f < SSDiff_i do
          begin
            SSDiff_i := SSDiff_f ;
            SSDiff_f := SumOfSquaresOfDifferences(add,param,step,xyData,paramStrm,SSDiff_i) ;
          end ;
        end ;

        t2 := 1 ;
        paramMinimised.Seek((param-1)*4,soFromBeginning) ;
        paramMinimised.Write(t2,4) ; // flag this parameter as minimised
        paramMinimised.Seek(0,soFromBeginning) ;
        for t1 := 1 to 3 do  // check if all paramters minimised - changed for mean centred
        begin
           paramMinimised.Read(t2,4) ; // cycle through flags
           if t2 = 1 then
             allMinimised := true
           else
             allMinimised := false ;
        end ;
        if (allMinimised = true) and (step_num = 5) then
        begin
           minimised := true ;  // this means the minimum has been found at the step resolution indicated by minStep input variable
        end
        else  if  (allMinimised = true) then
        begin
           step := step / 10 ;
           inc(step_num) ;
           t2 := 0 ;
           paramMinimised.Seek(0,soFromBeginning) ;
           for t1 := 1 to 3 do  // set all paramters as not minimised
             paramMinimised.Write(t2,4) ;

           // *** ADD TO STOP INVERTED DATA  ******
           paramStrm.Seek(0,soFromBeginning) ;
           paramStrm.Read(phase ,4) ;
           paramStrm.Read(range,4) ;
           paramStrm.Read(offset_scores,4) ;

           xyData.F_Mdata.Seek(0, soFromBeginning) ;  // xydata is <angle (in radians)><PCA score>
           modelData := TMatrix.Create2(xyData.SDPrec div 4,xyData.numRows,2) ;
           modelData.F_Mdata.Seek(0,soFromBeginning) ; // modelData is <predicted data><PCA score> pairs
           for t1 := 1 to xyData.numRows do
           begin
              xyData.F_Mdata.Read(s1,4) ;  // read the angle
              s2 :=  (cos(frequency*(s1+phase))) ;// create the model data
              s2 := range* s2 * s2 ;
              s2 := s2 {- pc10_score} {+ offset_scores - absolute_score } ;               // add the original offset to the model data
              modelData.F_Mdata.Write(s2, 4) ;         // write the model data
              xyData.F_Mdata.Read(s2, 4) ;             // read the original scores data
              s2 := s2 {-pc10_score} { -  absolute_score}  ;
              modelData.F_Mdata.Write(s2, 4) ;         // write the original scores data
           end ;
           xyData.F_Mdata.Seek(0, soFromBeginning) ;
           modelData.F_Mdata.Seek(0, soFromBeginning) ;

           R_matrix := regressionObject.PCResults.GetVarCovarMatrix(modelData) ;  // simple matrix multiply to end with symmetric matrix
           regressionObject.PCResults.StandardiseVarCovar(R_matrix) ;  // returns 'Pearsons R matrix' or the 'correlation' matrix
           R_pearsons :=  regressionObject.PCResults.ReturnPearsonsCoeffFromStandardisedVarCovar(R_matrix,1,2) ; // this is the R value for data
           // ***** THIS IS IMPORTANT BIT ******
           if R_pearsons < 0 then
           begin
              phase := phase + (pi/4) ;
              paramStrm.Seek(0,soFromBeginning) ;
              paramStrm.Write(phase ,4) ;
           end ;

           modelData.Free ;
           // *** END ADD TO STOP INVERTED DATA  ******

        end ;
        // continue with next parameter
        inc(param) ; // this is added from where it was right at start of loop
        if param > 3 then param := 1 ; // this is added from where it was right at start of loop  - changed for mean centred

      inc(iteration) ;
    end ;

    // create fitted model data
    paramStrm.Seek(0,soFromBeginning) ;
    paramStrm.Read(phase ,4) ;
    paramStrm.Read(range,4) ;
    paramStrm.Read(offset_scores,4) ;

    xyData.F_Mdata.Seek(0, soFromBeginning) ;  // xydata is <angle (in radians)><PCA score>
    modelData := TMatrix.Create2(xyData.SDPrec div 4,xyData.numRows,2) ;
    modelData.F_Mdata.Seek(0,soFromBeginning) ; // modelData is <predicted data><PCA score> pairs
    for t1 := 1 to xyData.numRows do
    begin
       xyData.F_Mdata.Read(s1,4) ;  // read the angle
//       s2 := range*(cos(frequency*(s1+phase))) ;// create the model data
       s2 :=  (cos(frequency*(s1+phase))) ;// create the model data
       s2 := range* s2 * s2 ;
       s2 := s2 {- pc10_score} {+ offset_scores - absolute_score } ;               // add the original offset to the model data
       modelData.F_Mdata.Write(s2, 4) ;         // write the model data
       xyData.F_Mdata.Read(s2, 4) ;             // read the original scores data
       s2 := s2 {-pc10_score} { -  absolute_score}  ;
       modelData.F_Mdata.Write(s2, 4) ;         // write the original scores data
    end ;
    xyData.F_Mdata.Seek(0, soFromBeginning) ;
    modelData.F_Mdata.Seek(0, soFromBeginning) ;

    if  modelData.numRows > 1 then
    begin
      R_matrix := regressionObject.PCResults.GetVarCovarMatrix(modelData) ;  // simple matrix multiply to end with symmetric matrix
      regressionObject.PCResults.StandardiseVarCovar(R_matrix) ;  // returns 'Pearsons R matrix' or the 'correlation' matrix
      R_pearsons :=  regressionObject.PCResults.ReturnPearsonsCoeffFromStandardisedVarCovar(R_matrix,1,2) ; // this is the R value for data
      if R_pearsons < 0 then
//        phase := phase + (pi/2) ;
    end ;


    modelData.Frows.SetSize(4 * 4) ;  // use this to return the data with
    modelData.Frows.Seek(0,soFromBeginning) ;
    max_angle := (phase)/(pi) *180 ; //(((pi-phase)*frequency)/pi)*180 ;
    while  (max_angle > 0) do
      max_angle := max_angle - 180 ;
      
    while  (max_angle < 0) do
      if max_angle > -90 then
        max_angle := abs(max_angle)
      else
      if max_angle < -90 then
        max_angle := max_angle + 180 ;
    max_angle := 90 - max_angle  ;
    modelData.Frows.Write(max_angle,4) ;
    modelData.Frows.Write(range ,4) ;
    modelData.Frows.Write(offset_scores,4) ;
    modelData.Frows.Write(R_pearsons,4) ;
    result := modelData ;   // return TMatrix has to be freed when finished with in calling function
  end ;


end ;


function TPLMAnalysis.SumOfSquaresOfDifferences(direction, param : integer; step : single; xyData : TMatrix; paramsStr : TMemoryStream;  SSDiff_i : single) : single ;
var     // param is the paramter number to step in value (reference into paramsStr memory stream)
  t1 : integer ;
  SSDiff_f, param_i : single ;
  s1, s2 : single ;
  range, frequency, phase, offset : single ;
begin
    // read the parameter ;
    paramsStr.Seek((param-1)*4,soFromBeginning) ;
    paramsStr.Read(s1,4) ;
    paramsStr.Seek(-4,soFromCurrent) ;
    param_i := s1 ;
    s1 := s1 + (direction* step) ;  // step forward or backward
    paramsStr.Write(s1,4) ;         // write the new parameter value to the parameter list (if R_f < R_i then change back to param_i at end of function)
    paramsStr.Seek(0,soFromBeginning) ;

    paramsStr.Read(phase ,4) ; // was
    paramsStr.Read(range,4) ;
    paramsStr.Read(offset,4) ;
    paramsStr.Read(frequency,4) ;
    SSDiff_f := 0.0 ;

    xyData.F_Mdata.Seek(0, soFromBeginning) ;
    for t1 := 1 to xyData.numRows do
    begin
       xyData.F_Mdata.Read(s1,4) ; // read angle value
//       s2 := range*(cos(frequency*(s1+phase))) + offset  ;// +offset ; // create model y data
       s2 :=  (cos(frequency*(s1+phase))) ;// create the model data
       s2 := range* s2 * s2 ;
       xyData.F_Mdata.Read(s1,4) ;
       SSDiff_f := SSDiff_f + ((s1-s2)*(s1-s2)) ;
    end ;
    xyData.F_Mdata.Seek(0, soFromBeginning) ;

    result :=  SSDiff_f ;

    if (SSDiff_i <= SSDiff_f) or (SSDiff_i = -1.0) then  // if step does not improve fit then place original parameter back
    begin
      // write the inital value of the paramater back
      paramsStr.Seek((param-1)*4,soFromBeginning) ;
      paramsStr.Write(param_i,4) ;
      paramsStr.Seek(0,soFromCurrent) ;
    end ;
end ;

// determine if we have to add or subtract 'step' value to minimise Sum of Squares
function TPLMAnalysis.SumOfSquaresOfDirection(direction, param : integer; step : single; xyData : TMatrix; paramsStr : TMemoryStream;  SSDiff_i : single) : integer ;
var     // param is the paramter number to step in value (reference into paramsStr memory stream)
  t1 : integer ;
  SSDiff_f, param_i : single ;
  s1, s2 : single ;
  range, frequency, phase, offset : single ;
begin
    // read the parameter ;
    paramsStr.Seek((param-1)*4,soFromBeginning) ;
    paramsStr.Read(s1,4) ;
    paramsStr.Seek(-4,soFromCurrent) ;
    param_i := s1 ;
    s1 := s1 + (direction* step) ;  // step forward or backward
    paramsStr.Write(s1,4) ;
    paramsStr.Seek(0,soFromBeginning) ;

    paramsStr.Read(phase ,4) ;
    paramsStr.Read(range,4) ;
    paramsStr.Read(offset ,4) ;
    paramsStr.Read(frequency,4) ;
    SSDiff_f := 0.0 ;
    xyData.F_Mdata.Seek(0, soFromBeginning) ;

    for t1 := 1 to xyData.numRows do
    begin
       xyData.F_Mdata.Read(s1,4) ; // read x value
//       s2 := range*(cos(frequency*(s1+phase))) + offset ;  // create model data
       s2 :=  (cos(frequency*(s1+phase))) ;// create the model data
       s2 := range* s2 * s2 ;
       xyData.F_Mdata.Read(s1,4) ; // read x value
       SSDiff_f := SSDiff_f + ((s1-s2)*(s1-s2)) ;
    end ;
    xyData.F_Mdata.Seek(0, soFromBeginning) ;

    if direction = 1 then // direction is forward
    begin
      if SSDiff_f > SSDiff_i then result := -1
      else if SSDiff_f < SSDiff_i then result :=  1
      else result := 0 ;
    end
    else
    begin
      if SSDiff_i > SSDiff_f then result :=  1
      else if SSDiff_i < SSDiff_f then result := -1
      else result := 0 ;
    end  ;

    // write the inital value of the paramater back
    paramsStr.Seek((param-1)*4,soFromBeginning) ;
    paramsStr.Write(param_i,4) ;
    paramsStr.Seek(0,soFromCurrent) ;

end ;



function  TPLMAnalysis.ReturnExclusionString(inMat : TMatrix; numStddevs : single; colNum : integer) : string ;
 // only works for 2 column data
// removes data points from list that are > numStdevs away from surrounding data points
var
  t1, t2 : integer ;
  s1, s2, stdev_s : single ;
  d1, d2, stdev_d : double ;
  tStream : TMemoryStream ;
  trueFalse_f, trueFalse_b : integer ;
  rowRange : string ;

begin
   tStream := TMemoryStream.Create ;
   tStream.SetSize(4*inMat.numRows) ;

   inMat.Stddev;
   inMat.F_MStdDev.Seek(inMat.SDPrec*(colNum-1),soFromBeginning) ;
   if  inMat.SDPrec = 4 then
     inMat.F_MStdDev.Read(stdev_s,inMat.SDPrec)
   else if  inMat.SDPrec = 8 then
     inMat.F_MStdDev.Read(stdev_d,inMat.SDPrec) ;

   colNum := colNum - 1 ;
   inMat.F_Mdata.Seek(inMat.SDPrec*colNum,soFromBeginning) ; // get to correct column number

   // read first data point
   if  inMat.SDPrec = 4 then
     inMat.F_Mdata.Read(s1,4)
   else if  inMat.SDPrec = 8 then
     inMat.F_Mdata.Read(d1,8) ;

   // go forward through data
   trueFalse_f := 0 ;
   tStream.Seek(0,soFromBeginning) ;
   tStream.Write(trueFalse_f,4) ;

   for t1 := 1 to inMat.numRows-1 do
   begin
      if  inMat.SDPrec = 4 then
      begin
         inMat.F_Mdata.Seek(inMat.SDPrec,soFromCurrent) ; // get to correct column number
         inMat.F_Mdata.Read(s2,4) ;
         if (s2 > (s1+(stdev_s*numStddevs))) or (s2 < (s1-(stdev_s*numStddevs))) then
         begin
            trueFalse_f := 1 ;
            tStream.Write(trueFalse_f,4) ;
         end
         else
         begin
            trueFalse_f := 0 ;
            tStream.Write(trueFalse_f,4) ;
         end ;
         s1 := s2 ;
      end
      else if  inMat.SDPrec = 8 then
      begin

      end ;
   end ;  // going forward through data


   inMat.F_Mdata.Seek(inMat.SDPrec*colNum,soFromBeginning) ; // get to correct column number
   // read first data point
   if  inMat.SDPrec = 4 then
     inMat.F_Mdata.Read(s1,4) 
   else if  inMat.SDPrec = 8 then
     inMat.F_Mdata.Read(d1,8) ;

  // go forward through data again but compare the other way
//   rowRange := '1,' ;
   tStream.Seek(0,soFromBeginning) ;
   for t1 := 1 to inMat.numRows do
   begin
      if  inMat.SDPrec = 4 then
      begin
         inMat.F_Mdata.Seek(inMat.SDPrec,soFromCurrent) ; // get to correct column number
         inMat.F_Mdata.Read(s2,4) ;
         tStream.Read(trueFalse_f,4) ;

         if (s1 > (s2+(stdev_s*numStddevs))) or (s1 < (s2-(stdev_s*numStddevs))) then
         begin
            if (trueFalse_f = 0) and (t1 <> 1) then
            begin
              rowRange := rowRange + inttostr(t1) + ',' ;
            end
         end
         else
         begin
            if (t1 <> 13) then
              rowRange := rowRange + inttostr(t1) + ','
            else if (t1 = 13) and (trueFalse_f = 0) then
              rowRange := rowRange + inttostr(t1) + ','
         end ;
         s1 := s2 ;
      end
      else if  inMat.SDPrec = 8 then
      begin

      end ;
   end ;  // going forward through data with comparison the other way

   // remove last comma
   rowRange := copy(rowRange,1,Length(rowRange)-1) ;

   // re-create Matrix, excluding unwanted data
//   for t1 := 0 to inMat.numRows


   result := rowRange ;

   tStream.Free ;
end ;


function TPLMAnalysis.AutoExcludeData(inMat : TMatrix; numStddevs : single; colNum : integer ) : TMatrix ;
// only works for 2 column data
// removes data points from list that are > numStdevs away from surrounding data points
var
  t1, t2 : integer ;
  s1, s2, stdev_s : single ;
  d1, d2, stdev_d : double ;
  tStream : TMemoryStream ;
  trueFalse_f, trueFalse_b : integer ;
  rowRange : string ;
  resMat : TMatrix ;
begin
   tStream := TMemoryStream.Create ;
   tStream.SetSize(4*inMat.numRows) ;

   inMat.Stddev;
   inMat.F_MStdDev.Seek(inMat.SDPrec*(colNum-1),soFromBeginning) ;
   if  inMat.SDPrec = 4 then
     inMat.F_MStdDev.Read(stdev_s,inMat.SDPrec)
   else if  inMat.SDPrec = 8 then
     inMat.F_MStdDev.Read(stdev_d,inMat.SDPrec) ;

   colNum := colNum - 1 ;
   inMat.F_Mdata.Seek(inMat.SDPrec*colNum,soFromBeginning) ; // get to correct column number

   // read first data point
   if  inMat.SDPrec = 4 then
     inMat.F_Mdata.Read(s1,4)
   else if  inMat.SDPrec = 8 then
     inMat.F_Mdata.Read(d1,8) ;

   // go forward through data
   trueFalse_f := 0 ;
   tStream.Seek(0,soFromBeginning) ;
   tStream.Write(trueFalse_f,4) ;

   for t1 := 1 to inMat.numRows-1 do
   begin
      if  inMat.SDPrec = 4 then
      begin
         inMat.F_Mdata.Seek(inMat.SDPrec,soFromCurrent) ; // get to correct column number
         inMat.F_Mdata.Read(s2,4) ;
         if (s2 > (s1+(stdev_s*numStddevs))) or (s2 < (s1-(stdev_s*numStddevs))) then
         begin
            trueFalse_f := 1 ;
            tStream.Write(trueFalse_f,4) ;
         end
         else
         begin
            trueFalse_f := 0 ;
            tStream.Write(trueFalse_f,4) ;
         end ;
         s1 := s2 ;
      end
      else if  inMat.SDPrec = 8 then
      begin

      end ;
   end ;  // going forward through data


   inMat.F_Mdata.Seek(inMat.SDPrec*colNum,soFromBeginning) ; // get to correct column number
   // read first data point
   if  inMat.SDPrec = 4 then
     inMat.F_Mdata.Read(s1,4) 
   else if  inMat.SDPrec = 8 then
     inMat.F_Mdata.Read(d1,8) ;

  // go forward through data again but compare the other way
//   rowRange := '1,' ;
   tStream.Seek(0,soFromBeginning) ;
   for t1 := 1 to inMat.numRows do
   begin
      if  inMat.SDPrec = 4 then
      begin
         inMat.F_Mdata.Seek(inMat.SDPrec,soFromCurrent) ; // get to correct column number
         inMat.F_Mdata.Read(s2,4) ;
         tStream.Read(trueFalse_f,4) ;

         if (s1 > (s2+(stdev_s*numStddevs))) or (s1 < (s2-(stdev_s*numStddevs))) then
         begin
            if (trueFalse_f = 0) and (t1 <> 1) then
            begin
              rowRange := rowRange + inttostr(t1) + ',' ;
            end
         end
         else
         begin
            if (t1 <> 13) then
              rowRange := rowRange + inttostr(t1) + ','
            else if (t1 = 13) and (trueFalse_f = 0) then
              rowRange := rowRange + inttostr(t1) + ','
         end ;
         s1 := s2 ;
      end
      else if  inMat.SDPrec = 8 then
      begin

      end ;
   end ;  // going forward through data with comparison the other way

   // remove last comma
   rowRange := copy(rowRange,1,Length(rowRange)-1) ;

   // re-create Matrix, excluding unwanted data
//   for t1 := 0 to inMat.numRows
   resMat := TMatrix.Create(inMat.SDPrec div 4) ;
   resMat.FetchDataFromTMatrix(rowRange,'1-2',inMat) ;

   result := resMat ;

   tStream.Free ;
end ;



{$R *.DFM}

end.


 