unit TPLMAnalysisUnit1 ;

interface

uses
  Windows, classes, SysUtils, Dialogs,  TMatrixObject,
  TBatchBasicFunctions, TVarAndCoVarOperations, TSpectraRangeObject, TMaxMinObject  ;


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
     autosave : boolean ;
     resultsFileName : string ;

     bB : TBatchBasics ;  // functions like : LeftSideOfEqual() etc
     varCovarFunctions :  TVarAndCoVarFunctions ;

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
     function  GetPLMAnglesAsFloatStream(angleStr : string) : TMemoryStream ;  // Used by GetIRPolBatchArguments;

     function  ProcessPLMStackData( lc : pointer ) : boolean ;
     function  GetAllXData( sourceSpecRange : TSpectraRanges ) : boolean ;

     // return value is angle of first peak maximum => the angle of maximum absorption
     function FitSineData(xyData : TMatrix; frequency : single; minStep : single) : TMatrix ;
     function SumOfSquaresOfDifferences(direction, param : integer; step : single; xyData : TMatrix; paramsStr : TMemoryStream;  SSDiff_i : single) : single ;
     function SumOfSquaresOfDirection(direction, param : integer; step : single; xyData : TMatrix; paramsStr : TMemoryStream;  SSDiff_i : single) : integer ;

  private
end;


implementation

uses
  Fileinfo , BLASLAPACKfreePas  ;


constructor TPLMAnalysis.Create(SDPrec : integer) ;
begin
   angleFloatStrm := TMemoryStream.Create ;
   allXData := TSpectraRanges.Create(SDPrec,0,0,nil) ;
   bB := TBatchBasics.Create ;
   varCovarFunctions := TVarAndCoVarFunctions.Create ;
   autosave := false ;
end ;

destructor TPLMAnalysis.Destroy ;
begin
   angleFloatStrm.Free ;
   varCovarFunctions.Free ;
   allXData.Free ;

   anglePlot.Free ;
   rangePlot.Free ;
   offsetPlot.Free ;
   RPlot.Free ;

   bB.free ;

   inherited Destroy;
end ;

procedure TPLMAnalysis.Free;
begin
 if Self <> nil then
   Destroy;
end;


function TPLMAnalysis.GetAllXData( sourceSpecRange : TSpectraRanges ) : boolean ;
begin

  allXData.CopySpectraObject(sourceSpecRange) ;

end ;


function TPLMAnalysis.GetPLMAnglesAsFloatStream(angleStr : string) : TMemoryStream ;
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
   start row = 1
   num angle = 19
   angles = -45,-40,-35,-30,-25,-20,-15,-10,-5,-0.0,5,10,15,20,25,30,35,40,45  // delete one of these
   angles = 0,10,20,30,40,50,60,70,80,90                                       // delete one of these
   pixel spacing = 1.3587  // distance between pixels
   bone to surface = true  //
   actual depth = 0  // depth in mm
   normalise depth = false  // 1
   results file = PLM_angles.out
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
                 angleFloatStrm :=  GetPLMAnglesAsFloatStream(anglesStr) ;
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

             // ********************** Autosave ******************************************
             repeat
               inc(lineNum) ;
               tstr1 := bB.GetStringFromStrList(tStrList, lineNum) ;
             until (trim(tstr1) <> '') or (linenum > tStrList.Count)  ;
             if bB.LeftSideOfEqual(tstr1) = 'autosave' then
               if bB.RightSideOfEqual(tstr1) = 'true'  then
                   autosave := true
                else
                   autosave :=  false ;

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
  tMat, resMat, autoExMat, angleMatrix : TMatrix ;
  ts1, ts2, angleUsed, avearge1 : single ;
  tstring : string ;
  d1, d2 : double ;

  p1 : pointer ;
begin
try
try
  result := true ;

  // ******   Create TSpectraRanges for display of data *******
  // 1/ simple X-Y data : variable Vs Position
  anglePlot      := TSpectraRanges.Create(self.allXData.yCoord.SDPrec div 4, numY, numX , lc)  ;   // numX = number of positions data collected from
  rangePlot      := TSpectraRanges.Create(self.allXData.yCoord.SDPrec div 4, numY, numX , lc)  ;
  offsetPlot     := TSpectraRanges.Create(self.allXData.yCoord.SDPrec div 4, numY, numX , lc)  ;
  RPlot          := TSpectraRanges.Create(self.allXData.yCoord.SDPrec div 4, numY, numX , lc)  ;

  anglePlot.nativeImage := true ;
  rangePlot.nativeImage := true ;
  offsetPlot.nativeImage := true ;
  RPlot.nativeImage := true ;

  anglePlot.xPix := numX ; anglePlot.yPix := numY ;   anglePlot.xPixSpacing := pixelSpacing ;   anglePlot.yPixSpacing := pixelSpacing ;
  rangePlot.xPix := numX ; rangePlot.yPix := numY ;   rangePlot.xPixSpacing := pixelSpacing ;   rangePlot.yPixSpacing := pixelSpacing ;
  offsetPlot.xPix := numX ; offsetPlot.yPix := numY ;  offsetPlot.xPixSpacing := pixelSpacing ;   offsetPlot.yPixSpacing := pixelSpacing ;
  RPlot.xPix := numX ; RPlot.yPix := numY ;           RPlot.xPixSpacing := pixelSpacing ;   RPlot.yPixSpacing := pixelSpacing ;
  anglePlot.xCoord.CopyMatrix(self.allXData.XCoord) ;
  rangePlot.xCoord.CopyMatrix(self.allXData.XCoord) ;
  offsetPlot.xCoord.CopyMatrix(self.allXData.XCoord) ;
  RPlot.xCoord.CopyMatrix(self.allXData.XCoord) ;
  
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
   // 1/ create and add x data (angle, in radians)
   angleMatrix := TMatrix.Create2(1,numAngles,1) ;
   angleFloatStrm.Seek(0, soFromBeginning) ;
   for  t4 := 1 to numAngles do
   begin
      angleFloatStrm.Read(s1,4) ;
      s2 := (s1/180) * Pi ;
      angleMatrix.F_Mdata.Write(s2,4) ;
   end ;


//  copyFcols := TMemoryStream.Create ;
  for t1 := 1 to  numY do // for y each pixel
  begin
    rowsToFetchString := '' ;
    for t3 := 0 to numAngles - 1 do  rowsToFetchString := rowsToFetchString + inttostr((t1) + t3*numY)+',' ;

    for t2 := 1 to  numX do // for x each pixel
    begin
       // *****************  For each pixel in stack, fit a sine function to the PCA scores *****************
       tMat := TMatrix.Create2(1,numAngles,1) ;  // # of rows =  numAngles  => single column vector
       tMat.F_Mdata.Seek(0, soFromBeginning) ;

       // 1/ Add x data (angle, in radians)
       tMat.CopyMatrix(angleMatrix) ;
       // 2/ add y data from originsl allXCoord matrix
       tMat.AddColumnsToMatrix(rowsToFetchString, inttostr(t2),allXdata.yCoord)  ;

       // **************** Fit the data to sin(angle)^2 curve *****************************
       resMat := self.FitSineData(tMat,2.0, 0.001) ;    // 2.0 = frequency

       Form4.StatusBar1.Panels[0].Text := 'pixel number = ' + inttostr(((t1-1)*numX)+t2) + ' / '+ inttostr(numY*numX) ;
       Form4.BringToFront ;

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
       tMat.Free ;   // this holds a single set of Scores at each angle
     end ;
  end ;



finally
begin
  angleMatrix.Free ;
 // tMat.Free ;
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
  R_pearsons : single ;
  offset_scores, absolute_score, phase, phase_bkp, range : single ;
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
  SSDiff_i, SSDiff_f : single ;
begin
  if frequency <> 0 then
  begin

    // get approximate starting values for variables to fit
    maxMinValue := xyData.GetMinAndMaxValAndPos(0, 2) ; // 0 means all rows, 2 means 2nd column
    phase := 0 ;
    range :=  (single(maxMinValue.GetDataPointer(2)^) - single(maxMinValue.GetDataPointer(1)^)) ; /// 2  ; // ==  (ymax - ymin) / 2
    offset_scores := single(maxMinValue.GetDataPointer(1)^) ;
    maxMinValue.Free ; // has to be freed after creation in GetMinAndMaxValAndPos() function

    // start of iterative minimisation
    iteration := 1 ;
    param := 1 ;
    paramStrm := TMemoryStream.Create ;
    paramStrm.SetSize(xyData.SDPrec * 4)  ;  // change 4 to the number of parameters for model
    paramStrm.Write(range   ,4) ; // was offset
    paramStrm.Write( offset_scores,4) ;
    paramStrm.Write( phase ,4) ;
    paramStrm.Write(frequency,4) ;
    paramStrm.Seek(0,soFromBeginning) ;
    paramMinimised := TMemoryStream.Create ;
    paramMinimised.SetSize(sizeof(integer) * 3)  ;  // change 3 to the number of parameters for model
    t2 := 0 ;
    for t1 := 1 to 3 do   //
      paramMinimised.Write(t2,4) ;  // set flag for each parameter as NOT minimised (=0)
    minimised := false ;
    step_num := 1 ;

    SSDiff_i := SumOfSquaresOfDifferences(1,param,0.0,xyData,paramStrm,-1.0) ;

    step := 10000 * minStep  ;

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
        if (allMinimised = true) and (step_num = 4) then
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
        end ;
        // continue with next parameter
        inc(param) ; // this is added from where it was right at start of loop
        if param > 3 then param := 1 ; // this is added from where it was right at start of loop  - changed for mean centred

        if param = 3 then  // reduce size of steps for angle variable
          step := step / 1000
        else
        if param = 1 then
          step := step * 1000 ;


      inc(iteration) ;
    end ;

    paramMinimised.Free ;
    // create fitted model data
    paramStrm.Seek(0,soFromBeginning) ;
    paramStrm.Read(range ,4) ;
    paramStrm.Read(offset_scores,4) ;
    paramStrm.Read(phase ,4) ;

//    modelData := TMatrix.Create2(xyData.SDPrec div 4,xyData.numRows,2) ;

    xyData.F_Mdata.Seek(0, soFromBeginning) ;  // xydata is <angle (in radians)><>
    modelData := TMatrix.Create2(xyData.SDPrec div 4,xyData.numRows,2) ;
    modelData.F_Mdata.Seek(0,soFromBeginning) ; // modelData is <predicted data><PCA score> pairs
    for t1 := 1 to xyData.numRows do
    begin
       xyData.F_Mdata.Read(s1,4) ;  // read the angle
       s2 :=  frequency*(s1 +phase)  ;
       s2 :=  sin(s2) ;// create the model data
       s2 := (range* s2 * s2 ) + offset_scores ;
       modelData.F_Mdata.Write(s2, 4) ;         // write the model data
       xyData.F_Mdata.Read(s2, 4) ;             // read the original scores data
       modelData.F_Mdata.Write(s2, 4) ;         // write the original scores data
    end ;
    xyData.F_Mdata.Seek(0, soFromBeginning) ;
    modelData.F_Mdata.Seek(0, soFromBeginning) ;

    if  modelData.numRows > 1 then
    begin
      R_matrix := varCovarFunctions.GetVarCovarMatrix(modelData) ;  // simple matrix multiply to end with symmetric matrix
      varCovarFunctions.StandardiseVarCovar(R_matrix) ;  // returns 'Pearsons R matrix' or the 'correlation' matrix
      R_pearsons :=  varCovarFunctions.ReturnPearsonsCoeffFromStandardisedVarCovar(R_matrix,1,2) ; // this is the R value for data
      R_matrix.Free ;
    end ;


    // write calculated angles in degrees and other variables for display
    modelData.Frows.SetSize(4 * 4) ;  // use this to return the data with
    modelData.Frows.Seek(0,soFromBeginning) ;

    // to get from phase to angle of polariser:
    // Sine function results in phase value being a minimum value of the function
    // at the particular angle of the polariser. This angle
    // is 45 degrees from maximum. As direction of slow (or fast) axis
    // is 45 degrees from the angle of the polariser when at a maximum
    // then the phase angle is the angle of the slow (or fast) axis.

    max_angle := (phase)/(pi) *180 ; //(((pi-phase)*frequency)/pi)*180 ;

    modelData.Frows.Write(max_angle,4) ;
    modelData.Frows.Write(range ,4) ;
    modelData.Frows.Write(offset_scores,4) ;
    modelData.Frows.Write(R_pearsons,4) ;
    result := modelData ;   // return TMatrix has to be freed when finished with in calling function
    paramStrm.Free ;
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
    if  param = 3 then   // = phase
    begin
      if s1 > (pi / 4) then  s1 := (-pi / 4) + (s1 - (pi / 4))
      else
      if s1 < (-pi / 4) then  s1 := (pi / 4) - (s1 + (pi / 4)) ;
    end
    else
    if  param = 1 then  // = range
    begin
      if s1 < 0 then  s1 := s1 * -1 ;
    end ;
    paramsStr.Write(s1,4) ;         // write the new parameter value to the parameter list (if R_f < R_i then change back to param_i at end of function)
    paramsStr.Seek(0,soFromBeginning) ;

    paramsStr.Read(range ,4) ;
    paramsStr.Read(offset,4) ;
    paramsStr.Read(phase ,4) ;
    paramsStr.Read(frequency,4) ;
    SSDiff_f := 0.0 ;


    xyData.F_Mdata.Seek(0, soFromBeginning) ;
    for t1 := 1 to xyData.numRows do
    begin
       xyData.F_Mdata.Read(s1,4) ; // read angle value
       s2 :=  frequency*(s1 +phase)  ;
       s2 :=  sin(s2) ;// create the model data
       s2 := (range* s2 * s2 )+ offset ;
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
    if  param = 3 then
    begin
      if s1 > (pi / 4) then  s1 := (-pi / 4)  + (s1 - (pi / 4))
      else
      if s1 < (-pi / 4) then  s1 := (pi / 4)  - (s1 + (pi / 4));
    end
    else
    if  (param = 1) and (s1 < 0) then  // = range
    begin
//        s1 := s1 * -1 ;
//        paramsStr.Write(s1,4) ;
//        paramsStr.Seek(0,soFromBeginning) ;
          result := 1  ;
          exit ;
    end   ;
    paramsStr.Write(s1,4) ;
    paramsStr.Seek(0,soFromBeginning) ;

    paramsStr.Read(range ,4) ;
    paramsStr.Read(offset,4) ;
    paramsStr.Read(phase ,4) ;
    paramsStr.Read(frequency,4) ;
    SSDiff_f := 0.0 ;
    xyData.F_Mdata.Seek(0, soFromBeginning) ;

    for t1 := 1 to xyData.numRows do
    begin
       xyData.F_Mdata.Read(s1,4) ; // read x value (angle)
       s2 :=  frequency*(s1 +phase)  ;
       s2 :=  sin(s2) ;// create the model data
       s2 := (range* s2 * s2 )+ offset;
       xyData.F_Mdata.Read(s1,4) ; // read data value
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





end.

 