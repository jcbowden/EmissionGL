unit TSpectraRangeObject;

interface

uses  Windows, OpenGL, classes, StdCtrls,  Dialogs, Graphics, Math, SysUtils, TMatrixObject, FFTUnit,
      StringGridDataViewer, TStringListExtUnit, TMaxMinObject ;

type
  TGLLineColor = Array[0..2] of GLFloat ;  // holds color of spectra in GL notation (ie 0..1 float value)
  TGLRangeArray = Array[0..3] of GLFloat ; // holds values for range of X and Y scale values (OrthoVarXMax etc.)
  TGLRangeArrayD = Array[0..3] of Double ; // holds values for range of X and Y scale values (OrthoVarXMax etc.)

  TSingle = Array[1..4] of single ;
  TDouble = Array[1..4] of double ;

const
  MAXDISPLAYTYPEFORSPECTRA = 14 ;  // this is the current number of display possibilities of TSpectraRanges data
                      // see : CreateGLList()
type
  TSpectraRanges = class
  public

    // holds the data, xCoord contains 'filename' property
    xCoord     : TMatrix ;     // always a 1 row matrix.
    yCoord     : TMatrix ;     // Contains the number of spectra as numRows property
    yImaginary : TMatrix ;

    predYdataYOffsetRegCoef : TSingle  ;  // if .bin file type is a 'rc' then it will contain a value for this

    // Hold axes name and unit for display
    xString : string ;     // holds x axes name and unit type
    yString : string ;     // holds y axes name and unit type
    columnLabel : string ; // Short version for display on top of column of StringGrid dispaly of data
                         

    SGDataView : TSGDataView ;    // points to a form that has a string grid so we can view the numerical data in the TSpectraRange
    batchList  : TStringListExt ; // storage for list of strings that contains analysis instructions for the data

    // 2D imaging data structures
    image2DSpecR  : TSpectraRanges ; // Used to store spatial image file display image when native data is spectral and not spatial
    frequencyImage  : boolean ;   // if True then:
                                     // 1/ check # spectra = num pixelX x numPixelY
                                     // 2/ Extract intensity value and place in image2DSpecR (update FrequencySlider1 max value etc)
                                     // 3/ in CreateGLList() use 2nd TSpectraRange (image2DSpecR) data to make 2D surface.
    currentSlice : integer ;         // Current X variable position for imaging
                                     // (if needed - i.e. when IR imaging (frequencyImage=true) ) Use for storing FrequencySlider1.Frequency position
    nativeImage : boolean ;          // true if "File native 2D data" check box is checked
                                     // true if data is processed - i.e. scores from PCA, IR-pol angle, range or R value or standard "intensity" based image;
                                     // Image created directly from first xPix * yPix variables and placed in image2DSpecR TSpectraObject.
                                     // Further images are accessed using "Image/PC number:" text box to change "currentImageNumber" property
    xPix, yPix : integer ;           // number of pixels in x and y pixel direction
    xPixSpacing, yPixSpacing : single ;   // pixel spacing if IR image (or native image)

    xyScatterPlot : boolean ;       // uses SetOpenGLXYRangeScatterPlot and prevents Transpose1Click working
    averageIsDisplayed : boolean ;
    varianceIsDisplayed : boolean ;

    // interleaved = 1 this is standard interleaved format with image in large block (i.e. 32x32 spectra, followed by another 32x32 etc at each angle )
    // interleaved = 2 where each polarisation angle spectra at an individual pixel is one after another - this is IR-pol format (after precessing a type 1 data set)
    interleaved : integer ;
    numImagesOrAngles   : integer ;
    currentImageNumber : integer ;   // in multi (angle) images this is the current image at a cirtain angle

    
    fft : TFFTFunctions ;

    // used to store data on disk until specific data is known (and then loaded into yCoord.F_Mdata TMemoryStream)
    srFileStrm : TFileStream ;

    //  text labels for samples : Storage: "xx label", inclusive of double quotes, where xx is row where the label is applied
    yRowLabels: TStringList ;  //  to do: fill with double quoted " " data at start of text based input files - [ N.B. Could be stored in SPC file subheader areas]
    // text labels for variables : Storage: "xx label", inclusive of double quotes, where xx is column where the label is applied
    xColLabels: TStringList ;

    // Display properties for OpenGL code
    LineColor : TGLLineColor ;
    GLListNumber : integer ; // Number to identify precompiled list of OpenGL data
    glTextureReference : pointer ; // pointer to integer. Created by OpenGL function "glGenTextures" and used for texture rendering of 2D images to keep track of what texture is being used
    xLow, xHigh, yLow, yHigh, zHigh, zLow : single ;  // range of data in X and Y directions
    lineType : integer ;  // the type of OpenGl line to be drawn for spectra (dotted, plain etc)


 //   mapPointer : TMemoryStream ;

    constructor Create(singleOrDouble: integer; numSpectra, numXCoords : integer;  lc : pointer); // lc is pointer to TGLLineColor GLFloat array
    destructor  Destroy; override; // found in implementation part below
    procedure   Free ;                  // (DC : HDC;  RC : HGLRC)

    procedure  CopySpectraObject( sourceSpectra : TSpectraRanges )  ; // copies all data objects to input TSpectraRanges object. Does not copy LineColor or GLlistnumber as they have to be unique and are chosen when object is created
    procedure  CopyDataTo2DSpecR ;  // usefull for re-populating the 2D image ("image2DSpecR") after modification of the main data matrix
    procedure  FillDataGrid(SG1_ROW_in, SG1_COL_in: integer; caption : string) ;  // fills  SGDataView object string grid - should be called whenever data modified
    procedure  SetSize(singleOrDouble: integer; numSpectra, numXCoords, complexMatIn : integer) ;

    // display procedures with OpenGL
    // rowRange = range of lines to draw ('1-' = all spectra)
    procedure CreateGLList(rowRange: string; DC: HDC; RC: HGLRC; drawLine, Graphtype : integer) ;  // lineType := Graphtype ; 1 is standard x y or x y...y
    procedure SetOpenGLXYRange(draw : integer) ;  // calculates XLow, XHigh, YLow, YHigh
    procedure SetOpenGLXYRangeScatterPlot(draw : integer) ;
    procedure SetOpenGLXYRangeVariance(draw : integer) ;  // for when variance is being displayed

    function  ReturnTColorFromLineColor : TColor ;  // returns an integer value from 3 floating point values that are in range 0.0..1.0
    procedure SetTGLColourData( LineColorIn : TGLLineColor ) ;
    function  ReturnRowColRangeString : string ;

     // 2D image display functions
    procedure SetUpTextureEnvironment(DC: HDC; RC: HGLRC) ;
    procedure SetUpGLPixelTransfer(P : PByteArray; redPre :single; redMin, redMax:integer; redPost, greenPre:single;  greenMin, greenMax:integer; greenPost, bluePre:single; blueMin, blueMax:integer; bluePost :single   )  ;
    procedure ClearOpenGLData ;   // for when closing file

    // 3D image display functions
    procedure Correl2DSurface(aveData : integer ) ;  // creates OpenGL surface of 2D correlation data
    function  GetGLColor( height : single ; c1 : pointer ) : pointer ;  // returns color as proportion of point to max height
    function  GetNormalS_V(v1, v2, v3: pointer ; normalize : boolean;  returnArray : pointer) : pointer  ;
    procedure GetNormalAveragedS_V(v0, v1, v2, v3, v4, v5, v6 : pointer ;  retAr : pointer) ;

    // file loading and saving functions
    function  LoadXYDataFile : integer ;
    procedure DoMODISSOAPDataImport(filename : string; YStart,YFin, numBandsIn : integer)  ;
    procedure SaveSpectraDelimExcel(filenameOutput : String ; delim : String) ;
    procedure SaveSpectraDelimited(filenameOutput : String; delim : String) ;
    procedure SaveSpectraRangeDataBinV2( filenameOutput : String ) ; // binary format :  <DATA><rowNum><colNum><meanCentred><colStandardized><firstxCoord><lastxCoord><SDPrec><'v2'> at end
    procedure SaveSpectraRangeDataBinV3( filenameOutput : String ) ; // binary format :  <DATA><X Data><rowNum><colNum><meanCentred><colStandardized><SDPrec><'v3'> at end
    procedure LoadSpectraRangeDataBinV2( filenameInput : String ) ;  // loads V1 or V2 or V3 or V4 type binary files
    procedure LoadRawData( filenameInput : String ; numDataPoints, dataType : integer ) ;
    procedure LoadSpectraRangeDataTIFF(Filename : String; dim1D_ifTrue : boolean);
    procedure FillXCoordData(startVal, increment: single; direction : integer) ;

       // new functions dealing with TFileStream object
    procedure LoadSpectraToTFileStreamBinV2( filenameInput : String ) ;  //
    procedure AddBinFileEndingToTFileStrm(SDPrecIn : integer; numRowsIn, numColsIn : integer) ;



    // data access funcions
    function  ReturnIndexOfClosestXPosition(inPointer : pointer) : integer ;
    procedure SeekFromBeginning(XYBoth : integer;  spectraNum: integer; offsetBytes: integer) ; // XYBoth = 1 for X, 2 for Y, 3 for both.
    procedure Read_XYrYi_Data(xyryiPos : integer;spectraNum: integer; returnArray : pointer; seekNeeded : boolean) ;  // returns values in input array
    procedure Read_YrYi_Data(yryiPos : integer;spectraNum: integer; returnArray : pointer; seekNeeded : boolean) ;  // returns values in input array
    procedure Write_YrYi_Data(yryiPos : integer;spectraNum: integer; inputArray : pointer; seekNeeded : boolean) ;   //  value in input array
    procedure WriteExtend_XYrYi_Data(yryiPos : integer; spectraNum: integer; inputArray : pointer; seekNeeded : boolean) ;   // input value is in input array

    function  AddData(xdata : double;  ydata : TMemoryStream) : integer ;   // adds a data point to xCoord and yCoord dependent upon its xCoord value (i.e. placess data between closest xcoords)
    function  RemoveData(xdata : double) : integer ;

    procedure ShiftData(offSet : single) ;  // moves x axis up or down
    procedure AverageReduce(inputNumAves : integer;  rowOrCol: RowsOrCols) ;  // rows1orCols2 = 1 then average rows or rows1orCols2 = 2 = average cols
    procedure Reduce(inputNumAves : integer;  rowOrCol: RowsOrCols) ;  // rows1orCols2 = 1 then average rows or rows1orCols2 = 2 = average cols
    procedure Transpose ;
    procedure RotateRight ;

  private
    function DrawReal(draw : integer) :  boolean ;
    function DrawImaginary(draw : integer) :  boolean ;
  end;


implementation

uses ColorsEM, SpectraLibrary, FileInfo, batchEdit;


constructor TSpectraRanges.Create(singleOrDouble: integer; numSpectra, numXCoords : integer;  lc : pointer);
begin
//  inherited Create;

  GLListNumber := 0 ;

    xCoord := TMatrix.Create2(singleOrDouble,1,numXCoords) ;
  try
    yCoord := TMatrix.Create2(singleOrDouble,numSpectra,numXCoords) ;
  except on EOutofMemory do
      messagedlg('Out of Memory. Check if /3GB switch is in Boot.ini file',mtError,[mbOK],0) ;
  end;

  yRowLabels := TStringList.Create ;
  xColLabels := TStringList.Create ;

  frequencyImage := false ; // image generated from particular wavenumber/frequency variable
  nativeImage := false ;    // image created directly from first xPix * yPix variables and placed in image2DSpecR TSpectraObject
  xPix := 1 ;
  yPix := 1 ;
  xPixSpacing := 1 ;
  yPixSpacing := 1 ;
  
  interleaved := 1 ;  // i.e. all positions at a single angle
  numImagesOrAngles   := 1 ;
  currentImageNumber := 1 ;

  xyScatterPlot := false ;
  lineType  := 1 ;
  
  if lc <> nil then
  begin
    LineColor[0] :=  TGLLineColor(lc^)[0] ;
    LineColor[1] :=  TGLLineColor(lc^)[1] ;
    LineColor[2] :=  TGLLineColor(lc^)[2] ;
  end ;

  fft := TFFTFunctions.Create ;
  fft.hanningWindow := false ;
  fft.FFTReverse := false ; // false is forward FFT
//  fft.firstXVal

  batchList := TStringListExt.Create  ;

  columnLabel := 'X Data' ; // label for top of colum that displays the data
end;


destructor TSpectraRanges.Destroy;
begin

  SGDataView.Free ;
  batchList.Free ;

  xCoord.Free ;
  yCoord.Free ;

  yRowLabels.Free;
  xColLabels.Free;
  if yImaginary <> nil then yImaginary.Free;

  // remove memory pointed to by glTextureReference pointer
  if glTextureReference <> nil then
  begin
    glDeleteTextures(1,  self.glTextureReference) ;
    FreeMem( glTextureReference , 4 )
  end ;

  fft.Free ;

//  inherited Destroy;
end;


procedure TSpectraRanges.Free ;       // (DC : HDC;  RC : HGLRC)
begin
{  if GLListNumber > 0 then
  begin
    ActivateRenderingContext(DC,RC);
     glDeleteLists(GLListNumber,1) ; // remove OpenGL compiled list
    wglMakeCurrent(0,0);
  end ;  }

// if Self <> nil then
   Destroy;

end;

procedure  TSpectraRanges.SetSize(singleOrDouble: integer; numSpectra, numXCoords, complexMatIn : integer) ; 
begin
    xCoord.SetSizeTMat(singleOrDouble,1,numXCoords,1);
    yCoord.SetSizeTMat(singleOrDouble,numSpectra,numXCoords,1);
end;

// has to be called between ActivateRenderingContext(Form1.Canvas.Handle,RC); and  wglMakeCurrent(0,0);
procedure TSpectraRanges.ClearOpenGLData ;
begin
    glDeleteLists(self.GLListNumber,1) ;
    if glTextureReference <> nil then
    begin
      glDeleteTextures(1,  self.glTextureReference) ;
      FreeMem( glTextureReference , 4 )
    end ;

end ;


procedure TSpectraRanges.CopySpectraObject( sourceSpectra : TSpectraRanges )  ;
// Does not copy LineColor or GLlistnumber as they have to be unique and are chosen when object is created
var
  tStream1, tStream2 : TMemoryStream ;
begin
    self.xCoord.CopyMatrix( sourceSpectra.xCoord )  ;
    self.yCoord.CopyMatrix( sourceSpectra.yCoord )  ;
    if sourceSpectra.yImaginary <> nil then
    begin
      if self.yImaginary = nil then
      begin
         self.yImaginary := TMatrix.Create(self.yCoord.SDPrec div 4) ;
      end ;
      self.yImaginary.CopyMatrix( sourceSpectra.yImaginary ) ;
    end ;

//    newSpect.SGDataView :=  SGDataView ;  // points to a form that has a string grid so we can view the data in the TSpectraRange
    self.SGDataView := nil ;

    self.xString :=  sourceSpectra.xString  ;
    self.yString :=  sourceSpectra.yString  ;
    self.lineType := sourceSpectra.lineType ; // OpenGL line type

    self.fft.CopyFFTObject( sourceSpectra.fft ) ;     ;

    tStream1 := TMemoryStream.Create ;
    sourceSpectra.yRowLabels.SaveToStream(tStream1) ;
    self.yRowLabels.LoadFromStream(tStream1) ;
    tStream1.Free ;

    tStream2 := TMemoryStream.Create ;
    sourceSpectra.xColLabels.SaveToStream(tStream2) ;
    self.xColLabels.LoadFromStream(tStream2) ;
    tStream2.Free ;

    self.xPix                  :=  sourceSpectra.xPix       ;  // x anf y pixel dimensions
    self.yPix                  :=  sourceSpectra.yPix               ;

    self.frequencyImage        :=  sourceSpectra.frequencyImage      ;  // if True then:
    self.currentSlice          :=  sourceSpectra.currentSlice       ;  // Current X variable position for imaging (if needed - i.e. when IR imaging (frequencyImage=true) ) Use for storing FrequencySlider1.Frequency position
    self.nativeImage           :=  sourceSpectra.nativeImage        ;  // true if data is processed - scores; IR-pol angle, range or R value; // image created directly from first xPix * yPix variables and placed in image2DSpecR TSpectraObject

    self.xPixSpacing           :=  sourceSpectra.xPixSpacing         ;  // X pixel spacing if IR image
    self.yPixSpacing           :=  sourceSpectra.yPixSpacing         ;  // Y pixel spacing if IR image
    self.interleaved           :=  sourceSpectra.interleaved        ;  // = 1 if original data each position at one angle, 2 if data blocked each angle at each position
    self.numImagesOrAngles     :=  sourceSpectra.numImagesOrAngles  ;
    self.currentImageNumber    :=  sourceSpectra.currentImageNumber ;  // in multi (angle) images this is the current image at a cirtain angle


    // Display properties for OpenGL code
//    newSpect.LineColor := LineColor ;        // LineColor has to be unique and is chosen when object is created - do not copy
    self.GLListNumber := 0 ;  // GLlistnumber has to be unique and is chosen when object is created - do not copy

    self.XLow  :=   sourceSpectra.XLow        ;
    self.XHigh :=   sourceSpectra.XHigh       ;
    self.YLow  :=   sourceSpectra.YLow        ;
    self.YHigh :=   sourceSpectra.YHigh       ;  // range of data in X and Y directions

    self.columnLabel := sourceSpectra.columnLabel ;

end ;


// usefull for re-populating the 2D image ("image2DSpecR") after modification of the main data matrix
procedure TSpectraRanges.CopyDataTo2DSpecR  ;
var
  t1, t2 : integer ;
  s1 : single ;
  TempXY : array[0..1] of single ;
begin

      if self.interleaved = 2  then  // this is for re-arranged data from IR pol
      begin
        for t1 := 0 to self.yPix-1 do
        begin
          for t2 := 1 to self.xPix do
          begin
             //  self.Read_YrYi_Data(self.currentSlice,(((t1*self.Pix)+t2)-1)*(numImages),@TempXY,true) ;
             self.Read_YrYi_Data(self.currentSlice,(((t1*self.xPix)+t2)-1)*(self.numImagesOrAngles),@TempXY,true) ;
             self.image2DSpecR.Write_YrYi_Data(t2,t1+1,@TempXY,false) ;
          end ;
        end ;
        end
        else
        if self.interleaved = 1  then   // never will be in IR-pol data
        begin
          for t1 := 0 to self.yPix-1 do
          begin
           for t2 := 1 to self.xPix do
           begin
              self.Read_YrYi_Data(self.currentSlice,((t1*self.xPix)+t2),@TempXY,true) ;
              self.image2DSpecR.Write_YrYi_Data(t2,t1+1,@TempXY,false) ;
           end ;
        end ;
      end ;

end ;



function TSpectraRanges.ReturnTColorFromLineColor : TColor ;
var
  rb, gb, bb : TColor ;
  col : TColor ;
begin
    rb := round(LineColor[0] * 255) ;
    gb := round(LineColor[1] * 255) ;
    bb := round(LineColor[2] * 255) ;
    col := 0 ;
    asm
      MOV    EAX, col
      ADD    EAX, bb
      SHL    EAX,8
      ADD    EAX, gb
      SHL    EAX,8
      ADD    EAX, rb
      MOV    col , EAX
    end ;

    result := col ;
end ;


procedure TSpectraRanges.SetTGLColourData( LineColorIn : TGLLineColor ) ;
begin
   LineColor[0] := LineColorIn[0] ;
   LineColor[1] := LineColorIn[1] ;
   LineColor[2] := LineColorIn[2] ;
end ;


function  TSpectraRanges.ReturnRowColRangeString : string ;
begin
   result := '1-'+ inttostr(self.yCoord.numRows) +' : 1-' + inttostr(self.yCoord.numCols) ;
end ;


function  TSpectraRanges.ReturnIndexOfClosestXPosition(inPointer : pointer) : integer ;
var
  t1 : integer ;
  s0, s1, s2 : single ;
  d0, d1, d2 : double ;
begin
  result := 0 ;
  if xCoord.SDPrec = 4 then
  begin
     s0 := single(inPointer^) ;
     SeekFromBeginning(3,1,0) ;
     xCoord.F_Mdata.Read(s1,4) ;
     SeekFromBeginning(3,1,(xCoord.numCols*xCoord.SDPrec)-xCoord.SDPrec) ;
     xCoord.F_Mdata.Read(s2,4) ;
     if (s1 < s2)  then // go forwards through x data
     begin
       if (s0 > s1) then
       begin
         SeekFromBeginning(3,1,0) ;
         while (s1 < s0) and (result <= xCoord.numCols)  do
         begin
           xCoord.F_Mdata.Read(s1,4) ;
           inc(result) ;
         end ;
         if (result >= xCoord.numCols) then
         begin
            messagedlg('TSpectraRanges.ReturnClosestXPosition() error: Point is above x data range',mtInformation,[mbOK],0) ;
            result := 0 ;
            exit ;
         end ;
         s1 := abs(s1 - s0) ;
         xCoord.F_Mdata.Seek(-8,soFromCurrent)  ;
         xCoord.F_Mdata.Read(s2,4) ;
         s2 := abs(s2 - s0) ;
         if s2 < s1 then
           result := result - 1 ;
       end
       else
       messagedlg('TSpectraRanges.ReturnClosestXPosition() error: Point is below x data range',mtInformation,[mbOK],0) ;
     end
     else
     if (s1 > s2)  then   // go backwards through x data (first is bigger)
     begin
       if (s0 < s1) then
       begin
         SeekFromBeginning(3,1,0) ;
         while (s1 > s0) and (result <= xCoord.numCols) do
         begin
           xCoord.F_Mdata.Read(s1,4) ;
           inc(result) ;
         end ;
         if (result >= xCoord.numCols) then
         begin
            messagedlg('TSpectraRanges.ReturnClosestXPosition() error: Point is above x data range',mtInformation,[mbOK],0) ;
            result := 0 ;
            exit ;
         end ;
         s1 := abs(s1 - s0) ;
         xCoord.F_Mdata.Seek(-8,soFromCurrent) ;
         xCoord.F_Mdata.Read(s2,4) ;
         s2 := abs(s2 - s0) ;
         if s2 < s1 then
           result := result - 1 ;
       end
       else
       messagedlg('TSpectraRanges.ReturnClosestXPosition() error: Point is below x data range',mtInformation,[mbOK],0) ;
     end  ;
  end
  else
  if xCoord.SDPrec = 8 then
  begin
     d0 := double(inPointer^) ;
     SeekFromBeginning(3,1,0) ;
     xCoord.F_Mdata.Read(d1,8) ;
     SeekFromBeginning(3,1,(xCoord.numCols*xCoord.SDPrec)-xCoord.SDPrec) ;
     xCoord.F_Mdata.Read(d2,8) ;
     if (d1 < d2)  then // go forwards through x data
     begin
       if (d0 > d1) then
       begin
         SeekFromBeginning(3,1,0) ;
         while (s1 < s0) and (result <= xCoord.numCols)  do
         begin
           xCoord.F_Mdata.Read(d1,8) ;
           inc(result) ;
         end ;
         if (result >= xCoord.numCols) then
         begin
            messagedlg('TSpectraRanges.ReturnClosestXPosition() error: Point is above x data range',mtInformation,[mbOK],0) ;
            result := 0 ;
            exit ;
         end ;
         d1 := abs(d1 - d0) ;
         xCoord.F_Mdata.Seek(-16,soFromCurrent)  ;
         xCoord.F_Mdata.Read(d2,8) ;
         d2 := abs(d2 - d0) ;
         if d2 < d1 then
           result := result - 1 ;
       end
       else
       messagedlg('TSpectraRanges.ReturnClosestXPosition() error: Point is below x data range',mtInformation,[mbOK],0) ;
     end
     else
     if (d1 > d2)  then   // go backwards through x data (first is bigger)
     begin
       if (d0 < d2) then
       begin
         SeekFromBeginning(3,1,0) ;
         while (d1 > d0) and (result <= xCoord.numCols) do
         begin
           xCoord.F_Mdata.Read(d1,8) ;
           inc(result) ;
         end ;
         if (result >= xCoord.numCols) then
         begin
            messagedlg('TSpectraRanges.ReturnClosestXPosition() error: Point is above x data range',mtInformation,[mbOK],0) ;
            result := 0 ;
            exit ;
         end ;
         d1 := abs(d1 - d0) ;
         xCoord.F_Mdata.Seek(-16,soFromCurrent) ;
         xCoord.F_Mdata.Read(d2,8) ;
         d2 := abs(d2 - d0) ;
         if d2 < d1 then
           result := result - 1 ;
       end
       else
       messagedlg('TSpectraRanges.ReturnClosestXPosition() error: Point is below x data range',mtInformation,[mbOK],0) ;
     end  ;
      messagedlg('TSpectraRanges.ReturnClosestXPosition() error: Double precission function not implemented',mtInformation,[mbOK],0) ;
  end

end ;

procedure TSpectraRanges.SeekFromBeginning(XYBoth : integer; spectraNum: integer; offsetBytes: integer) ;
// XYBoth = 1 for X, 2 for Y real and Y imag, 3 for both.
// offsetBytes >= 0 then soFromBeginning
// else offsetBytes < 0 then soFromCurrent.
// spectraNum is 1 based
begin
   if offsetBytes >= 0 then // offset is positive => offset from beginning
   begin
     if XYBoth = 3 then
     begin
       self.xCoord.F_Mdata.Seek(offsetBytes,soFromBeginning) ;
       self.yCoord.F_Mdata.Seek(((spectraNum-1)*self.yCoord.numCols*self.yCoord.SDPrec) + offsetBytes,soFromBeginning) ;
       if self.yImaginary <> nil then
          self.yImaginary.F_Mdata.Seek(((spectraNum-1)*self.yCoord.numCols*self.yImaginary.SDPrec) + offsetBytes,soFromBeginning) ;
     end
     else if  XYBoth = 1 then  // just X data
       self.xCoord.F_Mdata.Seek(offsetBytes,soFromBeginning)
     else if XYBoth = 2 then   // just Y data
     begin
       self.yCoord.F_Mdata.Seek(((spectraNum-1)*self.yCoord.numCols*self.yCoord.SDPrec) + offsetBytes,soFromBeginning) ;
       if self.yImaginary <> nil then
          self.yImaginary.F_Mdata.Seek(((spectraNum-1)*self.yCoord.numCols*self.yImaginary.SDPrec) + offsetBytes,soFromBeginning)
     end
   else // offsetBytes is negative  => offset from current pos
   begin
     if XYBoth = 3 then
     begin
       self.xCoord.F_Mdata.Seek(offsetBytes,soFromCurrent) ;
       self.yCoord.F_Mdata.Seek(((spectraNum-1)*self.yCoord.numCols*self.yCoord.SDPrec) + offsetBytes,soFromCurrent) ;
       if self.yImaginary <> nil then
         self.yImaginary.F_Mdata.Seek(((spectraNum-1)*self.yCoord.numCols*self.yImaginary.SDPrec) + offsetBytes,soFromCurrent) ;
     end
     else if  XYBoth = 1 then  // just X data
       self.xCoord.F_Mdata.Seek(offsetBytes,soFromCurrent)
     else if XYBoth = 2 then   // just Y data
     begin
       self.yCoord.F_Mdata.Seek(((spectraNum-1)*self.yCoord.numCols*self.yCoord.SDPrec) + offsetBytes,soFromCurrent) ;
       if self.yImaginary <> nil then
         self.yImaginary.F_Mdata.Seek(((spectraNum-1)*self.yCoord.numCols*self.yImaginary.SDPrec) + offsetBytes,soFromCurrent) ;
     end ;
   end ;
   end ;
end ;


procedure TSpectraRanges.Read_XYrYi_Data(xyryiPos : integer; spectraNum: integer; returnArray : pointer; seekNeeded : boolean) ;
// return value is in input array 'returnArray' Calling procedure must determine precision of data to be read and allocate memory
// xyryiPos = (column) postion of data to read
// N.B.  returnArray values should always be initialised to zero (so that imaginary value is returned as zero even if imaginary matrix does not exist
var
  s1 : single ;
  d1 : double ;
begin
   if seekNeeded then
     self.SeekFromBeginning(3,spectraNum,(xyryiPos-1)*self.xCoord.SDPrec) ;

   self.xCoord.F_Mdata.Read(returnArray^,self.xCoord.SDPrec) ;
   returnArray := self.xCoord.MovePointer(returnArray,self.xCoord.SDPrec) ;
   self.yCoord.F_Mdata.Read(returnArray^,self.yCoord.SDPrec) ;
   if self.yImaginary <> nil then
   begin
     returnArray := self.xCoord.MovePointer(returnArray,self.yCoord.SDPrec) ;
     self.yImaginary.F_Mdata.Read(returnArray^,self.yImaginary.SDPrec)
   end ;

end ;


procedure TSpectraRanges.Transpose ;
var
  t1 : integer ;
  s1, s2 : single ;
begin
    if self.xyScatterPlot = false then
        begin
          self.yCoord.Transpose ;
          if  self.yImaginary <> nil then self.yImaginary.Transpose ;

          self.yCoord.meanCentred := false ;
          self.yCoord.colStandardized := false ;

          if self.SGDataView <> nil then
          begin
            self.SGDataView.Free ;
//            TSpectraRanges(Form4.StringGrid1.Objects[SG1_COL,selectedRowNum]).SGDataView := nil ;
            self.SGDataView := nil ;
          end ;

          //  rewrite the xCoord data to match number of columns
          self.xCoord.ClearData(self.yCoord.SDPrec div 4) ;
          self.xCoord.numRows := 1 ;
          self.xCoord.numCols  :=  self.yCoord.numCols ;
          self.xCoord.F_Mdata.SetSize(self.yCoord.SDPrec * self.xCoord.numCols ) ;
          self.xCoord.F_Mdata.Seek(0,sofrombeginning) ;
          if self.yCoord.numCols > 1 then
          begin
            if self.xHigh <> self.xLow then
              s1 :=  (self.xHigh - self.xLow)  / (self.yCoord.numCols-1)
            else
              s1 := 1 ;
          end
          else
            s1 := 1 ;
          for t1 := 0 to self.xCoord.numCols-1 do
          begin
            s2 := self.xLow + (s1 * t1) ;
            self.xCoord.F_Mdata.Write(s2,4) ;
          end ;
    end ;
end ;



procedure TSpectraRanges.RotateRight ;
var
  t1 : integer ;
  s1, s2 : single ;
begin
    if self.xyScatterPlot = false then
        begin
          self.yCoord.RotateRight ;
          if  self.yImaginary <> nil then self.yImaginary.RotateRight ;

          self.yCoord.meanCentred := false ;

          if self.SGDataView <> nil then
          begin
            self.SGDataView.Free ;
//            TSpectraRanges(Form4.StringGrid1.Objects[SG1_COL,selectedRowNum]).SGDataView := nil ;
            self.SGDataView := nil ;
          end ;

          //  rewrite the xCoord data to match number of columns
          self.xCoord.ClearData(self.yCoord.SDPrec div 4) ;
          self.xCoord.numRows := 1 ;
          self.xCoord.numCols  :=  self.yCoord.numCols ;
          self.xCoord.F_Mdata.SetSize(self.yCoord.SDPrec * self.xCoord.numCols ) ;
          self.xCoord.F_Mdata.Seek(0,sofrombeginning) ;
          if self.yCoord.numCols > 1 then
          begin
            if self.xHigh <> self.xLow then
              s1 :=  (self.xHigh - self.xLow)  / (self.yCoord.numCols-1)
            else
              s1 := 1 ;
          end
          else
            s1 := 1 ;
          for t1 := 0 to self.xCoord.numCols-1 do
          begin
            s2 := self.xLow + (s1 * t1) ;
            self.xCoord.F_Mdata.Write(s2,4) ;
          end ;
    end ;
end ;


procedure TSpectraRanges.Read_YrYi_Data(yryiPos : integer; spectraNum: integer; returnArray : pointer; seekNeeded : boolean) ;
// return value is in input array 'returnArray' Using procedure must determine precision of data to be read and allocate memory for returnArray
// xyryiPos = postion of data to read
// N.B. returnArray values should always be initialised to zero (so that imaginary value is returned as zero even if imaginary matrix does not exist
var
   t1 : integer ;
   s1 : single ;
   d1 : double ;
begin
   if seekNeeded then
     self.SeekFromBeginning(3,spectraNum,(yryiPos-1)*self.xCoord.SDPrec) ;

   self.yCoord.F_Mdata.Read(returnArray^,self.yCoord.SDPrec) ;
   if self.yImaginary <> nil then
   begin
     returnArray := self.xCoord.MovePointer(returnArray,self.yCoord.SDPrec) ;
     self.yImaginary.F_Mdata.Read(returnArray^,self.yImaginary.SDPrec)
   end ;
end ;


procedure TSpectraRanges.WriteExtend_XYrYi_Data(yryiPos : integer; spectraNum: integer; inputArray : pointer; seekNeeded : boolean) ;   // input value is in input array
var
   t1 : integer ;
begin
   self.xCoord.numCols := self.xCoord.numCols + 1 ;
   self.yCoord.numCols := self.yCoord.numCols + 1 ;
   self.xCoord.F_Mdata.SetSize(self.xCoord.F_Mdata.Size + self.xCoord.SDPrec);
   self.yCoord.F_Mdata.SetSize(self.yCoord.F_Mdata.Size + self.yCoord.SDPrec);


   if seekNeeded then
     self.SeekFromBeginning(3,spectraNum,(yryiPos-1)*self.xCoord.SDPrec) ;

   self.xCoord.F_Mdata.Write(inputArray^,self.yCoord.SDPrec) ;
   inputArray := self.xCoord.MovePointer(inputArray,self.yCoord.SDPrec) ;
   self.yCoord.F_Mdata.Write(inputArray^,self.yCoord.SDPrec) ;
   if self.yImaginary <> nil then
   begin
     inputArray := self.xCoord.MovePointer(inputArray,self.yCoord.SDPrec) ;
     self.yImaginary.F_Mdata.Write(inputArray^,self.yImaginary.SDPrec) ;
   end ;
end;


procedure TSpectraRanges.Write_YrYi_Data(yryiPos : integer; spectraNum: integer; inputArray : pointer; seekNeeded : boolean) ;   // input value is in input array
var
   t1 : integer ;
begin
   if seekNeeded then
     self.SeekFromBeginning(3,spectraNum,(yryiPos-1)*self.xCoord.SDPrec) ;

   self.yCoord.F_Mdata.Write(inputArray^,self.yCoord.SDPrec) ;
   if self.yImaginary <> nil then
   begin
     inputArray := self.xCoord.MovePointer(inputArray,self.yCoord.SDPrec) ;
     self.yImaginary.F_Mdata.Write(inputArray^,self.yImaginary.SDPrec) ;
   end ;
end ;


function  TSpectraRanges.AddData(xdata : double;  ydata : TMemoryStream) : integer ;
var
  t0, t1 : integer ;
  posClosest : integer ;
  s1, minDist_s : single ;
  d1, minDist_d : double ;
  tMatX, tMatY : TMatrix ;
begin

if self.xCoord.SDPrec= 4 then
begin
  minDist_s :=  Math.MaxSingle ;
  xCoord.F_Mdata.Seek(0,soFromBeginning) ;
  for t1 := 0 to xCoord.numCols -1 do
  begin
      xCoord.F_Mdata.Read(s1,xCoord.SDPrec) ;
      s1 := s1 - xdata ;
      if abs(s1) <= abs(minDist_s) then
      begin
        minDist_s := s1 ;
        posClosest := t1 ;
      end;
  end;
  tMatX := TMatrix.Create2(self.xCoord.SDPrec,1,self.xCoord.numCols+1) ;
  xCoord.F_Mdata.Seek(0,soFromBeginning) ;
  for t1 := 0 to tMatX.numCols -2 do
  begin

      if t1 = posClosest then
      begin
        if minDist_s >= 0 then
        begin
          // put new data first
          s1 :=  xdata ; // xdata is double so convert it to single first
          tMatX.F_Mdata.Write(s1,xCoord.SDPrec) ;
          // put original data secon
          self.xCoord.F_Mdata.Read(s1,xCoord.SDPrec) ;
         tMatX.F_Mdata.Write(s1,xCoord.SDPrec) ;
        end
        else
        begin
          // put original data first
          self.xCoord.F_Mdata.Read(s1,xCoord.SDPrec) ;
          tMatX.F_Mdata.Write(s1,xCoord.SDPrec) ;
          // then new data
          s1 :=  xdata ;  // xdata is double so convert it to single first
          tMatX.F_Mdata.Write(s1,xCoord.SDPrec) ;
        end;
      end
      else
      begin
        self.xCoord.F_Mdata.Read(s1,xCoord.SDPrec) ;
        tMatX.F_Mdata.Write(s1,xCoord.SDPrec) ;
      end;

  end;

  tMatY := TMatrix.Create2(self.xCoord.SDPrec,self.yCoord.numRows,self.xCoord.numCols+1) ;
  self.yCoord.F_Mdata.Seek(0,soFromBeginning) ;
  ydata.Seek(0,soFromBeginning) ;
  for t0 := 0 to self.yCoord.numRows - 1 do
  begin
    for t1 := 0 to tMatY.numCols -2 do
    begin
      if t1 = posClosest then
      begin
        if minDist_s >= 0 then // write before yCoord data
        begin
          ydata.Read(s1,yCoord.SDPrec) ; // put new data first
          tMatY.F_Mdata.Write(s1,yCoord.SDPrec) ;
          self.yCoord.F_Mdata.Read(s1,yCoord.SDPrec) ; // then put original data
          tMatY.F_Mdata.Write(s1,yCoord.SDPrec) ;
        end
        else //  minDist_s < 0   => new data is after the original data point
        begin
          self.yCoord.F_Mdata.Read(s1,yCoord.SDPrec) ;  // put original data
          tMatY.F_Mdata.Write(s1,yCoord.SDPrec) ;
          ydata.Read(s1,yCoord.SDPrec) ;    // put new data secon
          tMatY.F_Mdata.Write(s1,yCoord.SDPrec) ;
        end;
      end
      else  // just read the original data point
      begin
        self.yCoord.F_Mdata.Read(s1,yCoord.SDPrec) ;
        tMatY.F_Mdata.Write(s1,yCoord.SDPrec) ;
      end;
    end;
  end;

end
else
if self.xCoord.SDPrec= 8 then
begin
  minDist_d :=  Math.MaxDouble ;
  xCoord.F_Mdata.Seek(0,soFromBeginning) ;
  for t1 := 0 to xCoord.numCols -1 do
  begin
      xCoord.F_Mdata.Read(d1,xCoord.SDPrec) ;
      d1 := abs(d1 - xdata) ;
      if abs(d1) <= abs(minDist_d) then
      begin
        minDist_d := d1 ;
        posClosest := t1 ;
      end;
  end;
  tMatX := TMatrix.Create2(self.xCoord.SDPrec,1,self.xCoord.numCols+1) ;
  xCoord.F_Mdata.Seek(0,soFromBeginning) ;
  // for X data
  for t1 := 0 to tMatX.numCols -2 do
  begin
      if t1 = posClosest then
      begin
        if minDist_d >= 0 then
        begin
          // put new data first
          tMatX.F_Mdata.Write(xdata,xCoord.SDPrec) ;
          // put original data secon
          self.xCoord.F_Mdata.Read(d1,xCoord.SDPrec) ;
         tMatX.F_Mdata.Write(d1,xCoord.SDPrec) ;
        end
        else
        begin
          // put original data first
          self.xCoord.F_Mdata.Read(d1,xCoord.SDPrec) ;
          tMatX.F_Mdata.Write(d1,xCoord.SDPrec) ;
          // then new data
          tMatX.F_Mdata.Write(xdata,xCoord.SDPrec) ;
        end;
      end
      else
      begin
        self.xCoord.F_Mdata.Read(d1,xCoord.SDPrec) ;
        tMatX.F_Mdata.Write(d1,xCoord.SDPrec) ;
      end;
  end;

  tMatY := TMatrix.Create2(self.xCoord.SDPrec,self.yCoord.numRows,self.xCoord.numCols+1) ;
  self.yCoord.F_Mdata.Seek(0,soFromBeginning) ;
  ydata.Seek(0,soFromBeginning) ;
  // for Y data
  for t0 := 0 to self.yCoord.numRows - 1 do
  begin
    for t1 := 0 to tMatY.numCols -2 do
    begin
      if t1 = posClosest then
      begin
        if minDist_d >= 0 then // write before yCoord data (so put new data first)
        begin
          ydata.Read(d1,yCoord.SDPrec) ; // put new data first
          tMatY.F_Mdata.Write(d1,yCoord.SDPrec) ;
          self.yCoord.F_Mdata.Read(d1,yCoord.SDPrec) ; // then put original data
          tMatY.F_Mdata.Write(d1,yCoord.SDPrec) ;
        end
        else //  minDist_d < 0   => new data is after the original data point
        begin
          self.yCoord.F_Mdata.Read(d1,yCoord.SDPrec) ;  // put original data
          tMatY.F_Mdata.Write(d1,yCoord.SDPrec) ;
          ydata.Read(d1,yCoord.SDPrec) ;    // put new data secon
          tMatY.F_Mdata.Write(d1,yCoord.SDPrec) ;
        end;
      end
      else  // just read the original data point
      begin
        self.yCoord.F_Mdata.Read(d1,yCoord.SDPrec) ;
        tMatY.F_Mdata.Write(d1,yCoord.SDPrec) ;
      end;
    end;
  end;

end;

 self.xCoord.CopyMatrix(tMatX);
 self.yCoord.CopyMatrix(tMatY);
 tMatX.Free ;
 tMatY.Free ;
 self.SeekFromBeginning(3,1,0) ;
 result := posClosest ;

end;


function  TSpectraRanges.RemoveData(xdata : double) : integer ;
var
  t0, t1 : integer ;
  posClosest : integer ;
  s1, minDist_s : single ;
  d1, minDist_d : double ;
  tMatX, tMatY : TMatrix ;
begin

if xCoord.numCols > 1 then    // make sure we are not removing the last data point
begin
if self.xCoord.SDPrec= 4 then
begin
  minDist_s :=  Math.MaxSingle ;
  xCoord.F_Mdata.Seek(0,soFromBeginning) ;
  // find the position of the closest data point
  for t1 := 0 to xCoord.numCols -1 do
  begin
      xCoord.F_Mdata.Read(s1,xCoord.SDPrec) ;
      s1 := abs(s1 - xdata) ;
      if s1 < minDist_s then
      begin
        minDist_s := s1 ;
        posClosest := t1 ;
      end;
  end;
  tMatX := TMatrix.Create2(self.xCoord.SDPrec,1,self.xCoord.numCols-1) ;
  xCoord.F_Mdata.Seek(0,soFromBeginning) ;
  for t1 := 0 to tMatX.numCols do
  begin
      // read the dat point that is closest, but do not write it
      if t1 = posClosest then
      begin
        self.xCoord.F_Mdata.Read(s1,xCoord.SDPrec) ;
      end;
      // read and then write all the other data points
      self.xCoord.F_Mdata.Read(s1,xCoord.SDPrec) ;
      tMatX.F_Mdata.Write(s1,xCoord.SDPrec) ;
  end;

  tMatY := TMatrix.Create2(self.xCoord.SDPrec,self.yCoord.numRows,self.xCoord.numCols-1) ;
  self.yCoord.F_Mdata.Seek(0,soFromBeginning) ;
  for t0 := 0 to self.yCoord.numRows - 1 do     // for each row
  begin
    for t1 := 0 to tMatY.numCols do
    // read each column data point except the extra data point
    begin
      // read the dat point that is closest, but do not write it
      if t1 = posClosest then
      begin
        self.yCoord.F_Mdata.Read(s1,yCoord.SDPrec) ;
      end;
      // read and then write all the other data points
      self.yCoord.F_Mdata.Read(s1,yCoord.SDPrec) ;
      tMatY.F_Mdata.Write(s1,yCoord.SDPrec) ;
    end;
  end;

end
else
if self.xCoord.SDPrec= 8 then
begin
  minDist_d :=  Math.MaxSingle ;
  xCoord.F_Mdata.Seek(0,soFromBeginning) ;
  // find the position of the closest data point
  for t1 := 0 to xCoord.numCols -1 do
  begin
      xCoord.F_Mdata.Read(d1,xCoord.SDPrec) ;
      d1 := abs(d1 - xdata) ;
      if d1 < minDist_d then
      begin
        minDist_d := d1 ;
        posClosest := t1 ;
      end;
  end;
  tMatX := TMatrix.Create2(self.xCoord.SDPrec,1,self.xCoord.numCols-1) ;
  xCoord.F_Mdata.Seek(0,soFromBeginning) ;
  for t1 := 0 to tMatX.numCols do
  begin
      // read the dat point that is closest, but do not write it
      if t1 = posClosest then
      begin
        self.xCoord.F_Mdata.Read(d1,xCoord.SDPrec) ;
      end;
      // read and then write all the other data points
      self.xCoord.F_Mdata.Read(d1,xCoord.SDPrec) ;
      tMatX.F_Mdata.Write(d1,xCoord.SDPrec) ;
  end;

  tMatY := TMatrix.Create2(self.xCoord.SDPrec,self.yCoord.numRows,self.xCoord.numCols-1) ;
  for t0 := 0 to self.yCoord.numRows - 1 do     // for each row
  begin
    for t1 := 0 to tMatY.numCols do
    // read each column data point except the extra data point
    begin
      // read the dat point that is closest, but do not write it
      if t1 = posClosest then
      begin
        self.yCoord.F_Mdata.Read(d1,yCoord.SDPrec) ;
      end;
      // read and then write all the other data points
      self.yCoord.F_Mdata.Read(d1,yCoord.SDPrec) ;
      tMatY.F_Mdata.Write(d1,yCoord.SDPrec) ;
    end;
  end;


end;

 self.xCoord.CopyMatrix(tMatX);
 self.yCoord.CopyMatrix(tMatY);
 tMatX.Free ;
 tMatY.Free ;
 self.SeekFromBeginning(3,1,0) ;
end; // only if more than one point in spectrum

end;



function TSpectraRanges.DrawReal(draw : integer) :  boolean ;
begin
     if ((draw = 1) or (draw = 3)) and (xCoord.F_Mdata.Size > 0)   then
       Result := true
     else
       Result := false ;
end ;


function TSpectraRanges.DrawImaginary(draw : integer) :  boolean ;
begin
     if ((draw = 2) or (draw = 3)) and (xCoord.F_Mdata.Size > 0)   then
       Result := true
     else
       Result := false ;
end ;



procedure TSpectraRanges.SetUpGLPixelTransfer(P : PByteArray; redPre :single; redMin, redMax:integer; redPost, greenPre:single;  greenMin, greenMax:integer; greenPost, bluePre:single; blueMin, blueMax:integer; bluePost :single  )  ;
var
    t1, t2 : integer ;
    s1, s2 : single ;
    b1 : byte ;
    mapPointer : tMemoryStream ;
begin

    // each map is 512 values and go from 0..1
    mapPointer := TMemoryStream.Create ; // 512 32 bit floats
    mapPointer.SetSize(2048) ;
    mapPointer.Seek(0,soFromBeginning) ;

    if redMax = redMin then redMax := redMax + 1 ;
    if greenMax = greenMin then greenMax := greenMax + 1 ;
    if blueMax = blueMin then blueMax := blueMax + 1 ;
 //   glPixelStorei(GL_UNPACK_ALIGNMENT,4) ;
    glPixelTransferf(GL_MAP_COLOR,1) ;

    s1 := redPre ;
    for t1 := 1 to redMin-1 do
    begin
       mapPointer.Write(s1,4) ;
    end ;
    s1 := 0.0 ;
    for t1 := redMin to redMax do
    begin
       s1 := s1 + 1/(1*(redMax - redMin )) ;
       mapPointer.Write(s1,4) ;
    end ;
    s1 := redPost ;
    for t1 := 1 to (512 - redMax)  do
    begin
       mapPointer.Write(s1,4) ; ;
    end ;
    mapPointer.Seek(0,soFromBeginning) ;
    // ensure range is correct
    for t1 := 0 to 511 do
    begin
      mapPointer.Read(s1,4) ;
      if s1 > 1.0 then s1 := 1.0    
      else
      if s1< 0 then s1 := 0.0 ;
      mapPointer.seek(-4,soFromCurrent) ;
      mapPointer.Write(s1,4) ;
    end ;
    mapPointer.Seek(0,soFromBeginning) ;
    glPixelMapfv(GL_PIXEL_MAP_I_TO_R, 512, mapPointer.Memory) ;

    // this modifies the bitmap data that displays the color range used in the the 'color setup' tab sheet
    if P <> nil then
    begin
    for t1 := 0 to 511 do
    begin
      mapPointer.Read(s1,4) ;
      b1 := trunc ( s1 * 255) ;
      P[(t1*4)+2] := b1
    end ;
    mapPointer.Seek(0,soFromBeginning) ;
    end ;

    s1 := greenPre ;
    for t1 := 1 to greenMin-1 do
    begin
       mapPointer.Write(s1,4) ;
    end ;
    s1 := 0 ;
    for t1 := greenMin to greenMax do
    begin

       s1 := s1 + 1/(greenMax - greenMin ) ;
       mapPointer.Write(s1,4) ;
    end ;
    s1 := greenPost ;
    for t1 := 1 to (512 - greenMax)  do
    begin
       mapPointer.Write(s1,4) ; ;
    end ;

    mapPointer.Seek(0,soFromBeginning) ;
    for t1 := 0 to 511 do
    begin
      mapPointer.Read(s1,4) ;
      if s1 > 1.0 then s1 := 1.0 
      else
      if s1< 0 then s1 := 0.0 ; 
      mapPointer.seek(-4,soFromCurrent) ;
      mapPointer.Write(s1,4) ;
    end ;
    mapPointer.Seek(0,soFromBeginning) ;
    glPixelMapfv(GL_PIXEL_MAP_I_TO_G, 512, mapPointer.Memory) ;


     // this modifies the bitmap data that displays the color range used in the the 'color setup' tab sheet
    if P <> nil then
    begin
    for t1 := 0 to 511 do
    begin
      mapPointer.Read(s1,4) ;
      b1 := trunc (s1 * 255) ;
      P[(t1*4)+1] := b1
    end ;
    mapPointer.Seek(0,soFromBeginning) ;
    end ;

    s1 := bluePre ;
     for t1 := 1 to blueMin-1 do
    begin
       mapPointer.Write(s1,4) ;
    end ;
    s1 := 0 ;
    for t1 := blueMin to blueMax do
    begin
       s1 := s1 + 1/(blueMax - blueMin ) ;
       mapPointer.Write(s1,4) ;
    end ;
    s1 := bluePost ;
    for t1 := 1 to (512 - blueMax)  do
    begin
       mapPointer.Write(s1,4) ; ;
    end ;
    mapPointer.Seek(0,soFromBeginning) ;
    // ensure range is correct
    for t1 := 0 to 511 do
    begin
      mapPointer.Read(s1,4) ;
      if s1 > 1.0 then s1 := 1.0   
      else
      if s1 < 0 then s1 := 0.0 ;
      mapPointer.seek(-4,soFromCurrent) ;
      mapPointer.Write(s1,4) ;
    end ;
    mapPointer.Seek(0,soFromBeginning) ;
    glPixelMapfv(GL_PIXEL_MAP_I_TO_B, 512, mapPointer.Memory) ;


     // this modifies the bitmap data that displays the color range used in the the 'color setup' tab sheet
    if P <> nil then
    begin
    for t1 := 0 to 511 do
    begin
      mapPointer.Read(s1,4) ;
      b1 := trunc (s1 * 255) ;
      P[(t1*4)] := b1
    end ;
    mapPointer.Seek(0,soFromBeginning) ;
    end ;


    mapPointer.Free ;
end ;




procedure TSpectraRanges.SetUpTextureEnvironment(DC: HDC; RC: HGLRC) ;
var
    t1, t2 : integer ;
    s1, rangeY, offsetY : single ;
    tMem : TMemoryStream ;
    closestX, closestY : integer ;
    firstTimeThrough : boolean ;
    forcedMax, forcedMin : single ;
begin
//    ActivateRenderingContext(DC,RC); // make context drawable
    firstTimeThrough := false ;
    if self.glTextureReference = nil then
    begin
      SetUpGLPixelTransfer(nil, 0, 2,511,511,0,2,511,511,0,2,511,511) ;
      GetMem(glTextureReference,4) ;
      glGenTextures(1, self.glTextureReference) ;  // generates a texture name and places it in  glTextureReference
      firstTimeThrough := true ;
    end ;
    glBindTexture(GL_TEXTURE_2D, integer(glTextureReference)) ;

    if firstTimeThrough = true then
    begin
      glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER, GL_NEAREST) ;//GL_NEAREST, GL_LINEAR, GL_NEAREST_MIPMAP_NEAREST, GL_NEAREST_MIPMAP_LINEAR, GL_LINEAR_MIPMAP_NEAREST, GL_LINEAR_MIPMAP_LINEAR
      glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER, GL_NEAREST) ;//GL_NEAREST, GL_LINEAR
      glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_WRAP_S, GL_REPEAT) ;//GL_REPEAT, GL_CLAMP
      glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_WRAP_T, GL_REPEAT) ;//GL_REPEAT, GL_CLAMP
      glTexEnvf(GL_TEXTURE_ENV,GL_TEXTURE_ENV_MODE, GL_MODULATE) ; //GL_MODULATE, GL_BLEND, GL_REPLACE, GL_DECAL

      // create empty data that is closest power of two in each direction
      closestX := self.fft.ClosestPowofTwo(yCoord.numCols) ;
      closestY := self.fft.ClosestPowofTwo(yCoord.numRows) ;
    end ;
      tMem := TMemoryStream.Create ;
    if firstTimeThrough = true then
    begin
    // creat 'empty' texture if first time through for this image

      tMem.SetSize( closestX*closestY*self.yCoord.SDPrec) ;
      glTexImage2D(GL_TEXTURE_2D,0,4,closestX,closestY,0,GL_COLOR_INDEX,GL_FLOAT,tMem.Memory) ;
    end ;
    // resize memory to fit actual (scaled 0..511) data
    tMem.SetSize(self.yCoord.F_Mdata.Size) ;
    yCoord.F_Mdata.Seek(0,soFromBeginning) ;


    // Scale the data so it has a range of 0..511 for color index mapping conversion (see glPixelMapfv functions to define mapping
    if Form2.ImageMaxColorCB.Checked then
     forcedMax := strtofloat(Form2.ImageMaxColorValEB.Text)
    else
     forcedMax := self.YHigh ;

    if Form2.ImageMinColorCB.Checked then
     forcedMin := strtofloat(Form2.ImageMinColorValEB.Text)
    else
     forcedMin := self.YLow ;

    rangeY  := forcedMax -  forcedMin ;
    if rangeY = 0 then rangeY := 1 ;
    rangeY :=  511 / (rangeY ) ;
    for t1 := 1 to  (self.yCoord.F_Mdata.Size div yCoord.SDPrec) do
    begin
       self.yCoord.F_Mdata.Read(s1,yCoord.SDPrec) ;
       s1 := ((rangeY) * (s1 - forcedMin))   ;
       if s1 > 511 then s1 := 511.0 ;
      // s1 := 512 - s1 ;
       tMem.write(s1,yCoord.SDPrec) ;
    end ;
    tMem.Seek(0,soFromBeginning) ;


    // copy all of image data to botom LHS of texture
    glTexSubImage2D(GL_TEXTURE_2D, 0, 0,0, yCoord.numCols,yCoord.numRows,GL_COLOR_INDEX,GL_FLOAT,tMem.Memory) ;

     glFlush ;

//     wglMakeCurrent(0,0); // another way to release control of context

     tMem.Free ;

end ;


procedure TSpectraRanges.CreateGLList(rowRange: string; DC: HDC; RC: HGLRC ;  drawLine, graphType : integer) ;
// drawline is which data (real=1 or imaginary=2, or both=3) to draw
// graphType is what kind of line/point/2D graph to draw
var
  t1, t2, numSpectra, rowForDisplay : integer ;
  s1, s2 : single ;
  maxLineCol, repeatNum : integer ;
  TempXY : array[0..2] of glFloat ;
  tStr : string ;
  rowToDisplay, tempTMS : TMemoryStream ;
  tempLineCol : TGLLineColor ;
  closestX, closestY : integer ;
begin


 if (Form2.NoImageCB1.checked = false) then  // only create GLlist if it is wanted - useful when opening a lot of files
begin


try
  if (drawLine = 3) and (self.yImaginary <> nil) then repeatNum := 2
  else if ((drawLine = 2) and (self.yImaginary <> nil)) or (drawLine = 1) or (drawLine = 3) then repeatNum := 1
  else  repeatNum := 0 ;

  rowToDisplay := TMemoryStream.Create ;

  if trim(rowRange) = '1-' then
    rowRange := rowRange + inttostr(self.yCoord.numRows)
  else
  if trim(rowRange) = '' then
   rowRange := '1-' + inttostr(self.yCoord.numRows) ;

  numSpectra := self.yCoord.GetTotalRowsColsFromString(rowRange,rowToDisplay) ;  // rowToDisplay is a TMemoryStream ;
  rowToDisplay.Seek(0,soFromBeginning) ;

  if graphType <> 8 then
  self.lineType :=  graphType ; // record the type of OpenGL drawing used

  ActivateRenderingContext(DC,RC); // make context drawable
  glMatrixMode(GL_ModelView); // activate the transformation matrix


  glDeleteLists(GLListNumber,1) ;
  glNewList(GLListNumber, GL_COMPILE);

  tempTMS := TMemoryStream.Create ;


while (repeatNum >= 1) do
begin

  // swap the data being drawn from real to imaginary (swap back at end)
  if (drawLine = 2) and (self.yImaginary <> nil) then
  begin
    tempTMS.LoadFromStream(self.yCoord.F_Mdata) ;
    self.yCoord.F_Mdata.LoadFromStream(self.yImaginary.F_Mdata) ;
    tempLineCol[0] := self.LineColor[0] ; tempLineCol[1] := self.LineColor[1] ; tempLineCol[2] := self.LineColor[2] ;
    self.LineColor[0] := 0 ;
    self.LineColor[1] := 1 ;
  end
  else
  if (drawLine = 3) and (self.yImaginary <> nil) and (repeatNum = 1) then
  begin
    tempTMS.LoadFromStream(self.yCoord.F_Mdata) ;
    self.yCoord.F_Mdata.LoadFromStream(self.yImaginary.F_Mdata) ;
    tempLineCol[0] := self.LineColor[0] ; tempLineCol[1] := self.LineColor[1] ; tempLineCol[2] := self.LineColor[2] ;
    self.LineColor[0] := 0 ;
    self.LineColor[1] := 1 ;

 //   self.yCoord.SaveMatrixDataTxt('imaginary.txt','      ') ;
  end ;
  yCoord.F_Mdata.Seek(0,soFromBeginning) ;
  xCoord.F_Mdata.Seek(0,soFromBeginning) ;
  rowToDisplay.Seek(0,soFromBeginning) ;
//  if (self.yImaginary <> nil) then dec(repeatNum) ;

  if  graphType = 1 then // standard X-Y1...Yxx graph
  begin
    glColor3f(LineColor[0],LineColor[1],LineColor[2]) ;  // LineColorR[] are part of TSpectraRange data object
  {  if (DrawReal(drawLine) = true) then   //  GL_TRIANGLE_STRIP
    begin   }
      for t1 := 1 to numSpectra do    // for every spectrum in y data
      begin
        rowToDisplay.Read(rowForDisplay,4) ;
        yCoord.F_Mdata.Seek(yCoord.SDPrec*rowForDisplay*yCoord.numCols,soFromBeginning) ;
        glBegin(GL_LINE_STRIP) ;
          xCoord.F_Mdata.Seek(0,soFromBeginning) ;
          for t2 := 1 to yCoord.numCols do
          begin
            self.Read_XYrYi_Data(t2,t1,@TempXY,false);
            glVertex2f(TempXY[0],TempXY[1]) ;  // write x,y data to precompiled list
          end ;
        glEnd ; // end GL_LINE_STRIP
      end ;
    {end ; }
  end
  else
  if graphType = 2 then // standard X-Y1...Yxx graph - alternating colors i.e. red green red green...
  begin

    if (DrawReal(drawLine) = true) then
    begin
      for t1 := 1 to numSpectra do    // for every spectrum in y data
      begin
         if (t1 mod 2) <> 0 then
           glColor3f(LineColor[0],LineColor[1],LineColor[2])
         else
           glColor3f(LineColor[1],LineColor[0],LineColor[2]) ;
         glBegin(GL_LINE_STRIP) ;

          rowToDisplay.Read(rowForDisplay,4) ;
          yCoord.F_Mdata.Seek(yCoord.SDPrec*rowForDisplay*yCoord.numCols,soFromBeginning) ;
          xCoord.F_Mdata.Seek(0,soFromBeginning) ;
          for t2 := 1 to yCoord.numCols do
          begin
            self.Read_XYrYi_Data(t2,t1,@TempXY,false);
            glVertex2f(TempXY[0],TempXY[1]) ;  // write x,y data to precompiled list
          end ;
        glEnd ; // end GL_LINE_STRIP
      end ;
    end ;

  end
  else
  if  graphType = 3 then // standard X-Y1...Yxx 1D graph  line with spot on top (6 = spot with line on top)
  begin

    if (DrawReal(drawLine) = true) then
    begin
      for t1 := 1 to numSpectra do    // for every spectrum in y data
      begin
//         if (t1 mod 2) = 0 then
//         begin
           glColor3f(LineColor[0],LineColor[1],LineColor[2]) ;
           rowToDisplay.Read(rowForDisplay,4) ;
           yCoord.F_Mdata.Seek(yCoord.SDPrec*rowForDisplay*yCoord.numCols,soFromBeginning) ;
           glBegin(GL_LINE_STRIP) ;
             xCoord.F_Mdata.Seek(0,soFromBeginning) ;
             for t2 := 1 to yCoord.numCols do
             begin
               self.Read_XYrYi_Data(t2,t1,@TempXY,false);
               glVertex2f(TempXY[0],TempXY[1]) ;  // write x,y data to precompiled list
             end ;
           glEnd ; // end GL_LINE_STRIP
//         end ;
      end ;
      rowToDisplay.Seek(0,soFromBeginning) ;
      for t1 := 1 to numSpectra do    // for every spectrum in y data
      begin
//         if (t1 mod 2) <> 0 then
//         begin
           glColor3f(0.0,0.0,0.0)  ;
           glPointsize(3.0) ;
           glBegin(GL_POINTS) ;
             xCoord.F_Mdata.Seek(0,soFromBeginning) ;
             rowToDisplay.Read(rowForDisplay,4) ;
             yCoord.F_Mdata.Seek(yCoord.SDPrec*rowForDisplay*yCoord.numCols,soFromBeginning) ;
             for t2 := 1 to yCoord.numCols do
             begin
               self.Read_XYrYi_Data(t2,t1,@TempXY,false);
               glVertex2f(TempXY[0],TempXY[1]) ;  // write x,y data to precompiled list
             end ;
           glEnd ; // end GL_LINE_STRIP
//         end ;
       end ;
    end ;

    end
  else

  if  graphType = 4 then // SPOTS with LINES on top  at points
  begin

    if (DrawReal(drawLine) = true) then
    begin
      yCoord.F_Mdata.Seek(0,soFromBeginning) ;

      glColor3f(0.0,0.0,0.0) ;
      glPointsize(3.0) ;

      for t1 := 1 to numSpectra do    // for every spectrum in y data
      begin
        //   tStr := 'Position = ' + inttostr(t1) ;
             glBegin(GL_POINTS) ;
             rowToDisplay.Read(rowForDisplay,4) ;
             yCoord.F_Mdata.Seek(yCoord.SDPrec*rowForDisplay*yCoord.numCols,soFromBeginning) ;
             xCoord.F_Mdata.Seek(0,soFromBeginning) ;
             for t2 := 1 to yCoord.numCols do
             begin
               self.Read_XYrYi_Data(t2,t1,@TempXY,false);
               glVertex2f(TempXY[0],TempXY[1]) ;  // write x,y data to precompiled list
             end ;
             glEnd ; // end GL_POINTS
      end ;
      rowToDisplay.Seek(0,soFromBeginning) ;
      glColor3f(LineColor[0],LineColor[1],LineColor[2]) ;
      for t1 := 1 to numSpectra do    // for every spectrum in y data
      begin
        //   tStr := 'Position = ' + inttostr(t1) ;
             glBegin(GL_LINE_STRIP) ;
             rowToDisplay.Read(rowForDisplay,4) ;
             tStr := 'Position = ' + inttostr(rowForDisplay+2) ;
             yCoord.F_Mdata.Seek(yCoord.SDPrec*rowForDisplay*yCoord.numCols,soFromBeginning) ;
             xCoord.F_Mdata.Seek(0,soFromBeginning) ;
             for t2 := 1 to yCoord.numCols do
             begin
               self.Read_XYrYi_Data(t2,t1,@TempXY,false);
               glVertex2f(TempXY[0],TempXY[1]) ;  // write x,y data to precompiled list
             end ;
             glEnd ; // end GL_LINE_STRIP
      end ;
    end ;

  end

  else
  if  graphType = 5 then //  X-Y1...Yxx 1D graph each graph separated along X Axis
  begin
    if (DrawReal(drawLine) = true) then
    begin
      for t1 := 1 to numSpectra do    // for every spectrum in y data
      begin

           glColor3f(LineColor[0],LineColor[1],LineColor[2]) ;
           glBegin(GL_LINE_STRIP) ;
             rowToDisplay.Read(rowForDisplay,4) ;
             tStr := 'Position = ' + inttostr(rowForDisplay+2) ;
             yCoord.F_Mdata.Seek(yCoord.SDPrec*rowForDisplay*yCoord.numCols,soFromBeginning) ;
             xCoord.F_Mdata.Seek(0,soFromBeginning) ;
             for t2 := 1 to yCoord.numCols do
             begin
               self.Read_XYrYi_Data(t2,t1,@TempXY,false);
               TempXY[0] := TempXY[0] + ((t1-1) * (self.XHigh - self.XLow)) ;
               glVertex2f(TempXY[0],TempXY[1]) ;  // write x,y data to precompiled list
             end ;
            glEnd ; // end GL_LINE_STRIP
            glRasterPos2f((t1) * (self.XHigh - self.XLow), self.YLow+(0.2*(self.YHigh - self.YLow))) ;  // position of number value of X
            glListBase(1); // indicate the start of display lists for the glyphs.
            glCallLists(Length(tStr),GL_UNSIGNED_BYTE,@tStr[1]) ;
      end ;
    end ;

  end
  else
  if  graphType = 6 then //   TempXY[0] := TempXY[0] + ((t1-1) * 180) ;
  begin         // Scores (dots) + Fit to Scores (lines) - Separated in x axis

    if (DrawReal(drawLine) = true) then
    begin
      rowToDisplay.Read(rowForDisplay,4) ;
      for t1 := 0 to yCoord.numRows -1 do    // for every spectrum in y data
      begin
         if (t1 mod 2) = 0 then
         begin
             xCoord.F_Mdata.Seek(0,soFromBeginning) ;
             if t1 =  rowForDisplay then
             begin
               yCoord.F_Mdata.Seek(yCoord.SDPrec*rowForDisplay*yCoord.numCols,soFromBeginning) ;
               glColor3f(LineColor[0],LineColor[1],LineColor[2]) ;
               glBegin(GL_LINE_STRIP) ;
               for t2 := 1 to yCoord.numCols do
               begin
                 self.Read_XYrYi_Data(t2,t1,@TempXY,false);
                 TempXY[0] := TempXY[0] + ((t1) * (self.XHigh - self.XLow) ) ;
                 glVertex2f(TempXY[0],TempXY[1]) ;  // write x,y data to precompiled list
               end ;
              glEnd ; // end GL_LINE_STRIP
              rowToDisplay.Read(rowForDisplay,4) ;
              rowToDisplay.Read(rowForDisplay,4) ;
             end ;
        end ;
      end ;
      rowToDisplay.Seek(4,soFromBeginning) ;
      rowToDisplay.Read(rowForDisplay,4) ;
      rowForDisplay := rowForDisplay  ;
      for t1 := 0 to yCoord.numRows -1 do    // for every spectrum in y data
      begin
         if (t1 mod 2) <> 0 then
         begin
             xCoord.F_Mdata.Seek(0,soFromBeginning) ;
             if t1 =  rowForDisplay then
             begin
               yCoord.F_Mdata.Seek(yCoord.SDPrec*rowForDisplay*yCoord.numCols,soFromBeginning) ;
               glColor3f(0.0,0.0,0.0)  ;
               glPointsize(3.0) ;
               glBegin(GL_POINTS) ;

               for t2 := 1 to yCoord.numCols do
               begin
                 self.Read_XYrYi_Data(t2,t1,@TempXY,false);
                 TempXY[0] := TempXY[0] + ((t1-1) * (self.XHigh - self.XLow) ) ;
                 glVertex2f(TempXY[0],TempXY[1]) ;  // write x,y data to precompiled list
               end ;
               glEnd ; // end GL_LINE_STRIP
               rowToDisplay.Read(rowForDisplay,4) ;
               rowToDisplay.Read(rowForDisplay,4) ;
               rowForDisplay := rowForDisplay ;
             end ;

         end ;
       end ;
    end ;

  end

  else
  if  graphType = 7 then // 2D correlation surface code
  begin

     self.Correl2DSurface(2)  ;

  end
  else
  if  graphType = 8 then // 8 means plot 3 lines 1st and 3rd are dashed (stdev) and middle one is solid
  begin

    if (averageIsDisplayed = false) and (varianceIsDisplayed = false) then
    begin
      yCoord.F_Mdata.Seek(0,soFromBeginning) ;

      glColor3f(0.0,0.0,0.0) ;
      glPointsize(2.0) ;

      glBegin(GL_POINTS) ;
      xCoord.F_Mdata.Seek(0,soFromBeginning) ;
      for t2 := 1 to yCoord.numCols do
      begin
         self.Read_XYrYi_Data(t2,t1,@TempXY,false);
         glVertex2f(TempXY[0],TempXY[1]) ;  // write x,y data to precompiled list
      end ;
      glEnd ; // end GL_POINTS

      glColor3f(LineColor[0],LineColor[1],LineColor[2]) ;

      glBegin(GL_LINE_STRIP) ;
      xCoord.F_Mdata.Seek(0,soFromBeginning) ;
      for t2 := 1 to yCoord.numCols do
      begin
         self.Read_XYrYi_Data(t2,t1,@TempXY,false);
         glVertex2f(TempXY[0],TempXY[1]) ;  // write x,y data to precompiled list
      end ;
      glEnd ; // end GL_LINE_STRIP

      glColor3f(0.0,0.0,0.0) ;
      glBegin(GL_POINTS) ;
      xCoord.F_Mdata.Seek(0,soFromBeginning) ;
      for t2 := 1 to yCoord.numCols do
      begin
         self.Read_XYrYi_Data(t2,t1,@TempXY,false);
         glVertex2f(TempXY[0],TempXY[1]) ;  // write x,y data to precompiled list
      end ;
      glEnd ; // end GL_POINTS
    end
    else  // DISPLAY (AVERAGE +- STDEV)
    if (averageIsDisplayed = true) and (varianceIsDisplayed = false)  then // averageIsDisplayed = true
    begin
      if yCoord.F_MStdDev = nil then
      begin
        yCoord.Average ;
        yCoord.Stddev(true) ;
      end;
      if yCoord.F_MAverage = nil then yCoord.Average ;
      yCoord.F_MStdDev.Seek(0,soFromBeginning) ;
      yCoord.F_MAverage.Seek(0,soFromBeginning) ;

      glColor3f(0.0,0.0,0.0) ;
      glPointsize(2.0) ;

      glBegin(GL_POINTS) ;
      xCoord.F_Mdata.Seek(0,soFromBeginning) ;
      for t2 := 1 to yCoord.numCols do
      begin
         yCoord.F_MStdDev.Read(TempXY[1],yCoord.SDPrec) ;
         yCoord.F_MAverage.Read(TempXY[0],yCoord.SDPrec) ;
         TempXY[1] := TempXY[0] - TempXY[1] ;
         xCoord.F_Mdata.Read(TempXY[0],yCoord.SDPrec) ;
         glVertex2f(TempXY[0],TempXY[1]) ;  // write x,y data to precompiled list
      end ;
      glEnd ; // end GL_POINTS

      glColor3f(LineColor[0],LineColor[1],LineColor[2]) ;

      glBegin(GL_LINE_STRIP) ;
      xCoord.F_Mdata.Seek(0,soFromBeginning) ;
      yCoord.F_MAverage.Seek(0,soFromBeginning) ;
      for t2 := 1 to yCoord.numCols do
      begin
         xCoord.F_Mdata.Read(TempXY[0],yCoord.SDPrec) ;
         yCoord.F_MAverage.Read(TempXY[1],yCoord.SDPrec) ;
         glVertex2f(TempXY[0],TempXY[1]) ;  // write x,y data to precompiled list
      end ;
      glEnd ; // end GL_LINE_STRIP


      glColor3f(0.0,0.0,0.0) ;
      glBegin(GL_POINTS) ;
      yCoord.F_MStdDev.Seek(0,soFromBeginning) ;
      yCoord.F_MAverage.Seek(0,soFromBeginning) ;
      xCoord.F_Mdata.Seek(0,soFromBeginning) ;
      for t2 := 1 to yCoord.numCols do
      begin
         yCoord.F_MStdDev.Read(TempXY[1],yCoord.SDPrec) ;
         yCoord.F_MAverage.Read(TempXY[0],yCoord.SDPrec) ;
         TempXY[1] := TempXY[1] + TempXY[0] ;
         xCoord.F_Mdata.Read(TempXY[0],yCoord.SDPrec) ;

         glVertex2f(TempXY[0],TempXY[1]) ;  // write x,y data to precompiled list
      end ;
      glEnd ; // end GL_POINTS

      yCoord.F_MStdDev.Seek(0,soFromBeginning) ;
      yCoord.F_MAverage.Seek(0,soFromBeginning) ;
    end
    else  // DISPLAY VARIANCE
    if (averageIsDisplayed = false) and (varianceIsDisplayed = true)  then // averageIsDisplayed = true
    begin
      if yCoord.F_MVariance = nil then yCoord.Variance ;

      glColor3f(LineColor[0],LineColor[1],LineColor[2]) ;

      glBegin(GL_LINE_STRIP) ;
      yCoord.F_MVariance.Seek(0,soFromBeginning) ;
      xCoord.F_Mdata.Seek(0,soFromBeginning) ;
      for t2 := 1 to yCoord.numCols do
      begin
         xCoord.F_Mdata.Read(TempXY[0],yCoord.SDPrec) ;
         yCoord.F_MVariance.Read(TempXY[1],yCoord.SDPrec) ;
         glVertex2f(TempXY[0],TempXY[1]) ;  // write x,y data to precompiled list
      end ;
      glEnd ; // end GL_LINE_STRIP

      // Put dots over line
      glColor3f(0.0,0.0,0.0) ;
      glPointsize(2.0) ;
      yCoord.F_MVariance.Seek(0,soFromBeginning) ;
      xCoord.F_Mdata.Seek(0,soFromBeginning) ;
      glBegin(GL_POINTS) ;
      for t2 := 1 to yCoord.numCols do
      begin
         xCoord.F_Mdata.Read(TempXY[0],yCoord.SDPrec) ;
         yCoord.F_MVariance.Read(TempXY[1],yCoord.SDPrec) ;
         glVertex2f(TempXY[0],TempXY[1]) ;  // write x,y data to precompiled list
      end ;
      glEnd ; // end GL_POINTS

      yCoord.F_MStdDev.Seek(0,soFromBeginning) ;
      yCoord.F_MAverage.Seek(0,soFromBeginning) ;
      yCoord.F_MVariance.Seek(0,soFromBeginning) ;
    end ;
  end
  else
  if  graphType = 9 then // colour indexed bitmap
  begin
      // OpenGL texture mapping functions that do not need to be called every within a glList
      self.SetUpTextureEnvironment(DC, RC) ;

      glEnable(GL_TEXTURE_2D) ;
      glBindTexture(GL_TEXTURE_2D, integer(self.glTextureReference)) ;
      s1 := self.xPixSpacing * self.xPix ;
      s2 := self.yPixSpacing * self.yPix ;

      closestX := self.fft.ClosestPowofTwo(yCoord.numCols) ;
      closestY := self.fft.ClosestPowofTwo(yCoord.numRows) ;

      glBegin(GL_POLYGON);
        glTexCoord2f(0.0,0.0); glColor4f(1.0,1.0,1.0,1.0) ; glVertex3f(0.0,0.0,0.0) ;
        glTexCoord2f(yCoord.numCols/closestX,0.0); glColor4f(1.0,1.0,1.0,1.0) ; glVertex3f(s1,0.0,0.0) ;
        glTexCoord2f(yCoord.numCols/closestX,yCoord.numRows/closestY); glColor4f(1.0,1.0,1.0,1.0) ; glVertex3f(s1,s2,0.0) ;
        glTexCoord2f(0.0,yCoord.numRows/closestY); glColor4f(1.0,1.0,1.0,1.0) ; glVertex3f(0.0,s2,0.0) ;
      glEnd;

      glDisable(GL_TEXTURE_2D) ;

  end
  else
  if  graphType = 10 then // large dot only
  begin
    if (DrawReal(drawLine) = true) then
    begin
      yCoord.F_Mdata.Seek(0,soFromBeginning) ;

      glColor3f(0.0,0.0,0.0) ;
      glPointsize(3.0) ;

      glBegin(GL_LINE_STRIP) ;
        glVertex2f(self.xLow,self.xLow) ;  // write x,y data to precompiled list
        glVertex2f(self.xHigh,self.xHigh) ;  // write x,y data to precompiled list
      glEnd ; // end GL_LINE_STRIP


      for t1 := 1 to numSpectra do    // for every spectrum in y data
      begin
             glBegin(GL_POINTS) ;
             rowToDisplay.Read(rowForDisplay,4) ;
             yCoord.F_Mdata.Seek(yCoord.SDPrec*rowForDisplay*yCoord.numCols,soFromBeginning) ;
             xCoord.F_Mdata.Seek(0,soFromBeginning) ;
             for t2 := 1 to yCoord.numCols do
             begin
               self.Read_XYrYi_Data(t2,t1,@TempXY,false);
               glVertex2f(TempXY[0],TempXY[1]) ;  // write x,y data to precompiled list
             end ;
             glEnd ; // end GL_POINTS
      end ;
      rowToDisplay.Seek(0,soFromBeginning) ;
      glColor3f(LineColor[0],LineColor[1],LineColor[2]) ;
      end ;
  end
  else
  if  graphType = 11 then // small dot and number
  begin
    if (DrawReal(drawLine) = true) then
    begin
      yCoord.F_Mdata.Seek(0,soFromBeginning) ;

      glColor3f(0.0,0.0,0.0) ;
      glPointsize(2.0) ;

      glBegin(GL_LINE_STRIP) ;
        glVertex2f(self.xLow,self.xLow) ;  // write x,y data to precompiled list
        glVertex2f(self.xHigh,self.xHigh) ;  // write x,y data to precompiled list
      glEnd ; // end GL_LINE_STRIP


      for t1 := 1 to numSpectra do    // for every spectrum in y data
      begin
             rowToDisplay.Read(rowForDisplay,4) ;
             yCoord.F_Mdata.Seek(yCoord.SDPrec*rowForDisplay*yCoord.numCols,soFromBeginning) ;
             xCoord.F_Mdata.Seek(0,soFromBeginning) ;
             glBegin(GL_POINTS) ;
             for t2 := 1 to yCoord.numCols do
             begin
               self.Read_XYrYi_Data(t2,t1,@TempXY,false);
               glVertex2f(TempXY[0],TempXY[1]) ;  // write x,y data to precompiled list
             end ;
             glEnd ; // end GL_POINTS
      end ;
      for t1 := 1 to numSpectra do    // for every spectrum in y data
      begin
             rowToDisplay.Read(rowForDisplay,4) ;
             yCoord.F_Mdata.Seek(yCoord.SDPrec*rowForDisplay*yCoord.numCols,soFromBeginning) ;
             xCoord.F_Mdata.Seek(0,soFromBeginning) ;
             for t2 := 1 to yCoord.numCols do
             begin
               self.Read_XYrYi_Data(t2,t1,@TempXY,false);
               tStr := ' ' + inttostr(t2) ;
               glRasterPos2f(TempXY[0], TempXY[1]) ;  // position of number value of X
               glListBase(1); // indicate the start of display lists for the glyphs.
               glCallLists(Length(tStr),GL_UNSIGNED_BYTE,@tStr[1]) ;
             end ;
      end ;
      rowToDisplay.Seek(0,soFromBeginning) ;
      glColor3f(LineColor[0],LineColor[1],LineColor[2]) ;
      end ;
  end
  else
  if  graphType = 12 then // small dot and 50/50 color. ie first 50 variables are one color 2nd 50 are another
  begin
    if (DrawReal(drawLine) = true) then
    begin
      yCoord.F_Mdata.Seek(0,soFromBeginning) ;

      glColor3f(0.0,0.0,0.0) ;
      glPointsize(2.0) ;


      glBegin(GL_LINE_STRIP) ;
        glVertex2f(self.xLow,self.xLow) ;  // write x,y data to precompiled list
        glVertex2f(self.xHigh,self.xHigh) ;  // write x,y data to precompiled list
      glEnd ; // end GL_LINE_STRIP

      for t1 := 1 to numSpectra do    // for every spectrum in y data
      begin
             glBegin(GL_POINTS) ;
             rowToDisplay.Read(rowForDisplay,4) ;
             yCoord.F_Mdata.Seek(yCoord.SDPrec*rowForDisplay*yCoord.numCols,soFromBeginning) ;
             xCoord.F_Mdata.Seek(0,soFromBeginning) ;
             for t2 := 1 to yCoord.numCols do
             begin
               if (t2 < (yCoord.numCols div 2)) then  glColor3f(0.0,0.0,0.0)
               else glColor3f(1.0,0.0,0.0) ;
               self.Read_XYrYi_Data(t2,t1,@TempXY,false);
               glVertex2f(TempXY[0],TempXY[1]) ;  // write x,y data to precompiled list
             end ;
             glEnd ; // end GL_POINTS
      end ;
      rowToDisplay.Seek(0,soFromBeginning) ;
      glColor3f(LineColor[0],LineColor[1],LineColor[2]) ;
      end ;

  end
  else
  if  graphType = 13 then // dots red centre with black outline
  begin
    if (DrawReal(drawLine) = true) then
    begin
      yCoord.F_Mdata.Seek(0,soFromBeginning) ;

      glColor3f(0.0,0.0,0.0) ;
      glPointsize(5.0) ;

      for t1 := 1 to numSpectra do    // for every spectrum in y data
      begin
             glBegin(GL_POINTS) ;
             rowToDisplay.Read(rowForDisplay,4) ;
             yCoord.F_Mdata.Seek(yCoord.SDPrec*rowForDisplay*yCoord.numCols,soFromBeginning) ;
             xCoord.F_Mdata.Seek(0,soFromBeginning) ;
             for t2 := 1 to yCoord.numCols do
             begin
               self.Read_XYrYi_Data(t2,t1,@TempXY,false);
               glVertex2f(TempXY[0],TempXY[1]) ;  // write x,y data to precompiled list
             end ;
             glEnd ; // end GL_POINTS
      end ;
      rowToDisplay.Seek(0,soFromBeginning) ;

      yCoord.F_Mdata.Seek(0,soFromBeginning) ;
      glColor3f(1.0,0.0,0.0) ;
      glPointsize(3.0) ;

      for t1 := 1 to numSpectra do    // for every spectrum in y data
      begin
             glBegin(GL_POINTS) ;
             rowToDisplay.Read(rowForDisplay,4) ;
             yCoord.F_Mdata.Seek(yCoord.SDPrec*rowForDisplay*yCoord.numCols,soFromBeginning) ;
             xCoord.F_Mdata.Seek(0,soFromBeginning) ;
             for t2 := 1 to yCoord.numCols do
             begin
               self.Read_XYrYi_Data(t2,t1,@TempXY,false);
               glVertex2f(TempXY[0],TempXY[1]) ;  // write x,y data to precompiled list
             end ;
             glEnd ; // end GL_POINTS
      end ;
      rowToDisplay.Seek(0,soFromBeginning) ;
      yCoord.F_Mdata.Seek(0,soFromBeginning) ;
      glColor3f(LineColor[0],LineColor[1],LineColor[2]) ;
    end ;
  end
  else
  if  graphType = 14 then //  Ave+-stdev along x-axis
  begin
    if (DrawReal(drawLine) = true) then
    begin
      yCoord.F_Mdata.Seek(0,soFromBeginning) ;

      glColor3f(0.0,0.0,0.0) ;
      glPointsize(4.0) ;

       // rowToDisplay.Read(rowForDisplay,4) ;
        yCoord.F_Mdata.Seek(0,soFromBeginning) ;
        xCoord.F_Mdata.Seek(0,soFromBeginning) ;
        for t2 := 0 to (xCoord.numCols div 3)-1 do
        begin
            glColor3f(0.0,0.0,0.0) ;
            self.Read_XYrYi_Data((t2*3),1,@TempXY,false);
            // RHS vertical line (= -stddev position away from mean)
            s1 := TempXY[1] * 0.05  ;

            glBegin(GL_LINES) ;
              glVertex2f(TempXY[0],TempXY[1]+s1) ;  // write x,y data to precompiled list
              glVertex2f(TempXY[0],TempXY[1]-s1) ;

              s1 := TempXY[0]  ;  // RHS stdev x coord
              self.Read_XYrYi_Data((t2*3)+1,1,@TempXY,false);
              s2 := TempXY[0]  ; // this is central point (=Average)

              self.Read_XYrYi_Data((t2*3)+2,1,@TempXY,false);
              // horizontal line
              if (t2 mod 2) = 0 then
              begin
                glVertex2f(s1,TempXY[1]+(TempXY[1]*0.02) ) ;  // write x,y data to precompiled list
                glVertex2f(TempXY[0],TempXY[1]+(TempXY[1]*0.02)) ;
              end
              else
              begin
                glVertex2f(s1,TempXY[1]-(TempXY[1]*0.02)) ;  // write x,y data to precompiled list
                glVertex2f(TempXY[0],TempXY[1]-(TempXY[1]*0.02)) ;
              end;

              // LHS vertical line (= +stddev position away from mean)
              s1 := TempXY[1] * 0.05   ;
              glVertex2f(TempXY[0],TempXY[1]+s1) ;  // write x,y data to precompiled list
              glVertex2f(TempXY[0],TempXY[1]-s1) ;
            glEnd ; // end GL_LINE

            glColor3f(1.0,0.0,0.0) ;
            glBegin(GL_POINTS) ;
              if (t2 mod 2) = 0 then
              begin
                glVertex2f(s2,TempXY[1]+(TempXY[1]*0.02) ) ;  // write x,y data to precompiled list
              end
              else
              begin
                glVertex2f(s2,TempXY[1]-(TempXY[1]*0.02) ) ;
              end;
             glEnd ; // end GL_POINTS

        end ;

      rowToDisplay.Seek(0,soFromBeginning) ;
      glColor3f(LineColor[0],LineColor[1],LineColor[2]) ;
      end ;
  end ;


  if (drawLine = 2) and (self.yImaginary <> nil) then
  begin
    self.yCoord.F_Mdata.LoadFromStream(tempTMS) ;
    LineColor[0] := tempLineCol[0] ; LineColor[1] := tempLineCol[1] ; LineColor[2] := tempLineCol[2] ;
  end
  else
  if (drawLine = 3) and (self.yImaginary <> nil) and (repeatNum = 1) then
  begin
    self.yCoord.F_Mdata.LoadFromStream(tempTMS) ;
    LineColor[0] := tempLineCol[0] ; LineColor[1] := tempLineCol[1] ; LineColor[2] := tempLineCol[2] ;
  end ;

  dec(repeatNum)  ;
end ;

  glEndList() ;   // end SPECTRALIST[x]
finally
  glFlush ;
  wglMakeCurrent(0,0); // another way to release control of context
  rowToDisplay.Free ;
  tempTMS.free ;
end ;

 end ;  // if Form2.NoImageCB1.Checked = true then

end ;


procedure CopyRow(line : integer ; toStream :TMemoryStream; fromMat : TMatrix)   ;
var
  t1, t2 : integer ;
  s1 : single ;
  d1 : double ;
begin
  toStream.Seek(0,soFromBeginning) ;
  fromMat.F_Mdata.Seek((line-1) * fromMat.SDPrec * fromMat.numCols, soFromBeginning) ;

  if  fromMat.SDPrec = 4 then
  begin
    for t1 := 1 to fromMat.numCols do
    begin
      fromMat.F_Mdata.Read(s1,4) ;
      toStream.Write(s1,4) ;
    end ;
  end
  else
  if  fromMat.SDPrec = 8 then
  begin
    for t1 := 1 to fromMat.numCols do
    begin
      fromMat.F_Mdata.Read(d1,4) ;
      toStream.Write(d1,4) ;
    end ;
  end  ;

  toStream.Seek(0,soFromBeginning) ;
end ;


function TSpectraRanges.GetGLColor( height : single ; c1 : pointer ) : pointer ;
var
  colorRatio : single ;
  high, low : single ;

  forcedMax, forcedMin : single ;
begin

   if (Form2.ImageMaxColorCB.Checked) then
     forcedMax := strtofloat(Form2.ImageMaxColorValEB.Text)
   else
     forcedMax := self.YHigh ;

   if (Form2.ImageMinColorCB.Checked) then
     forcedMin := strtofloat(Form2.ImageMinColorValEB.Text)
   else
     forcedMin := self.YLow ;


   if (forcedMax > 0) and (forcedMin >= 0) then
   begin
      colorRatio := (forcedMax - forcedMin ) ;
      height := height - forcedMin ;
      if colorRatio <> 0 then
        colorRatio := height / colorRatio
      else
        colorRatio := 1 ;
   end
   else
   if (forcedMax > 0) and (forcedMin < 0) then
   begin
      if  abs(forcedMax) > abs(forcedMin) then
      begin
         colorRatio :=  abs(height / forcedMax) ;
      end
      else
      if abs(forcedMax) < abs(forcedMin) then
      begin
         colorRatio :=  abs(height / forcedMin) ;
      end ;
   end
   else
   if (forcedMax <= 0) and (forcedMin < 0) then
   begin
      colorRatio := (forcedMax - forcedMin ) ;
      height := height - forcedMin ;
      if colorRatio <> 0 then
        colorRatio := abs((height) / (colorRatio))
      else
        colorRatio := 1 ;
   end   ;



   // this is set for CSIRO corporate colour output
   if height > 0 then
    begin
        TSingle(c1^)[1] := (0) ;
        TSingle(c1^)[2] := colorRatio * (0.6) ;
        TSingle(c1^)[3] := colorRatio * (0.8) ;
    end
    else
    begin  // height is < 0
        TSingle(c1^)[1] := colorRatio * (0.745) ;
        TSingle(c1^)[2] := colorRatio * (0.839) ;
        TSingle(c1^)[3] := colorRatio * (0) ;
    end ;


    result := c1 ;

end ;


 // has to be called between  wglMakeCurrent(DC,RC); (DC = handle of canvas etc, RC is created with CreateRenderingContext() )
procedure TSpectraRanges.Correl2DSurface(aveData : integer )   ;
var
  t1, t2 : integer ;
  s1, s2, s3 : single ;
//  aveReduced : TSpectraRanges ;
  line_1, line_2, line_3, line_4 : TMemoryStream ;
  v_X, v_Y : TMemoryStream ;
  v0, v1, v2, v3, v4, v5, v6 : pointer ;
  tp1, tp2, tp3, tp4 : pointer ;
  n1, c1 : pointer ;

begin
try
  GetMem(n1,4*sizeof(single)) ; // for vertex normal
  GetMem(c1,4*sizeof(single)) ; // for vertex color
  GetMem(v0,3*sizeof(single)) ;
  GetMem(v1,3*sizeof(single)) ;
  GetMem(v2,3*sizeof(single)) ;
  GetMem(v3,3*sizeof(single)) ;
  GetMem(v4,3*sizeof(single)) ;
  GetMem(v5,3*sizeof(single)) ;
  GetMem(v6,3*sizeof(single)) ;


  line_1 := TMemoryStream.Create ;
  line_2 := TMemoryStream.Create ;
  line_3 := TMemoryStream.Create ;
  line_4 := TMemoryStream.Create ;
  v_X  := TMemoryStream.Create ;  // frequency 1  (x values)
  v_Y  := TMemoryStream.Create ;  // frequency 2  (y values)

  line_1.SetSize(self.yCoord.numCols * self.yCoord.SDPrec) ;
  line_2.SetSize(self.yCoord.numCols * self.yCoord.SDPrec) ;
  line_3.SetSize(self.yCoord.numCols * self.yCoord.SDPrec) ;
  line_4.SetSize(self.yCoord.numCols * self.yCoord.SDPrec) ;
  v_X.SetSize(self.yCoord.numCols * self.yCoord.SDPrec) ;
  v_Y.SetSize(self.yCoord.numCols * self.yCoord.SDPrec) ;  // XXXXX  was numCols  XXXX

  CopyRow(1, line_1, self.yCoord) ;
  CopyRow(2, line_2, self.yCoord) ;
  CopyRow(3, line_3, self.yCoord) ;
  CopyRow(4, line_4, self.yCoord) ;
  CopyRow(1, v_X, self.xCoord) ;  // (x values)
  CopyRow(1, v_Y, self.xCoord) ;  // (y values)  // fine for 1:1 pixel aspect ratio


//  glPolygonMode(  GL_FRONT_AND_BACK, GL_LINE  ) ; // GL_FRONT_AND_BACK,  GL_FILL     GL_LINE
//  glPolygonMode(  GL_BACK, GL_FILL  ) ;

  glDisable(GL_CULL_FACE) ;  // otherwise inside arrowheads are culled
//  glCullFace( GL_FRONT ) ;

//  glShadeModel(GL_SMOOTH) ;  // GL_FLAT   GL_SMOOTH
//  glEnable(GL_NORMALIZE) ;
  glEnable(GL_DEPTH_TEST) ;

   // FOR FIRST LINE AT EDGE OF IMAGE
    glBegin(GL_TRIANGLE_STRIP); //GL_TRIANGLE_STRIP ;
    for t1 := 1 to 1 do
    begin
      // V0
      v_X.Seek(0, soFromBeginning) ;
      v_X.Read(TSingle(v0^)[1],4) ;
      v_Y.Seek(0, soFromBeginning) ;
      v_Y.Read(TSingle(v0^)[2],4) ;
      line_1.Read(TSingle(v0^)[3],4) ;


      // read vertex from 12 o'clock (v1) until 6 pm (v4)
      //  V3
      v_X.Seek(0, soFromBeginning) ;
      v_X.Read(TSingle(v4^)[1],4) ;
      v_Y.Seek(4, soFromBeginning) ;
      v_Y.Read(TSingle(v4^)[2],4) ;
      line_2.Read(TSingle(v4^)[3],4) ;

      v_X.Read(TSingle(v3^)[1],4) ;
      v_Y.Seek(0, soFromBeginning) ;
      v_Y.Read(TSingle(v3^)[2],4) ;
      line_1.Read(TSingle(v3^)[3],4) ;

      GetGLColor(TSingle(v0^)[3], c1 )  ;
      glColor3fv( c1  );
      GetNormalAveragedS_V(v0, nil, nil, v3,v4, nil, nil, n1) ;
      glNormal3fv(n1) ;  // First points normal
      glVertex3fv(v0) ;  // first pointes vertex


      // V1 = V 0   &   V0 := V4     &   V2 = V3
      TSingle(v1^)[1] := TSingle(v0^)[1] ; TSingle(v1^)[2] := TSingle(v0^)[2]; TSingle(v1^)[3] := TSingle(v0^)[3] ;
      TSingle(v0^)[1] := TSingle(v4^)[1] ; TSingle(v0^)[2] := TSingle(v4^)[2]; TSingle(v0^)[3] := TSingle(v4^)[3] ;
      TSingle(v2^)[1] := TSingle(v3^)[1] ; TSingle(v2^)[2] := TSingle(v3^)[2]; TSingle(v2^)[3] := TSingle(v3^)[3] ;

      // V3
      v_X.Seek(4, soFromBeginning) ;
      v_X.Read(TSingle(v3^)[1],4) ;
      v_Y.Seek(4, soFromBeginning) ;
      v_Y.Read(TSingle(v3^)[2],4) ;
      line_2.Read(TSingle(v3^)[3],4) ;
      // V5
      v_X.Seek(0, soFromBeginning) ;
      v_X.Read(TSingle(v5^)[1],4) ;
      v_Y.Seek(8, soFromBeginning) ;
      v_Y.Read(TSingle(v5^)[2],4) ;
      line_3.Read(TSingle(v5^)[3],4) ;


      GetGLColor(TSingle(v0^)[3], c1 )  ;
      glColor3fv( c1  );
      GetNormalAveragedS_V(v0, v1, v2, v3,v4, nil, nil, n1) ;
      glNormal3fv(n1) ;  // First points normal
      glVertex3fv(v0) ;  // first pointes vertex


      for t2 := 2 to  self.yCoord.numCols do
      begin
        // center Vertex (v0)
        TSingle(v4^)[1] := TSingle(v3^)[1] ; TSingle(v4^)[2] := TSingle(v3^)[2]; TSingle(v4^)[3] := TSingle(v3^)[3] ;
        TSingle(v5^)[1] := TSingle(v0^)[1] ; TSingle(v5^)[2] := TSingle(v0^)[2]; TSingle(v5^)[3] := TSingle(v0^)[3] ;
        TSingle(v6^)[1] := TSingle(v1^)[1] ; TSingle(v6^)[2] := TSingle(v1^)[2]; TSingle(v6^)[3] := TSingle(v1^)[3] ;
        TSingle(v0^)[1] := TSingle(v2^)[1] ; TSingle(v0^)[2] := TSingle(v2^)[2]; TSingle(v0^)[3] := TSingle(v2^)[3] ;

        // V3
        v_X.Seek((t2)*self.yCoord.SDPrec, soFromBeginning) ;
        v_X.Read(TSingle(v3^)[1],4) ;
        v_Y.Seek((t1-1)*self.yCoord.SDPrec, soFromBeginning) ;
        v_Y.Read(TSingle(v3^)[2],4) ;
         line_1.Seek((t2)*self.yCoord.SDPrec,soFromBeginning) ;
        line_1.Read(TSingle(v3^)[3],4) ;


        GetGLColor(TSingle(v0^)[3], c1 )  ;
        glColor3fv( c1  );
        GetNormalAveragedS_V(v0, nil, nil, v3, v4, v5, v6, n1) ;
        glNormal3fv(n1) ;  // First points normal
        glVertex3fv( v0 ) ;  // first points vertex


        // Second vertex
        TSingle(v2^)[1] := TSingle(v3^)[1] ; TSingle(v2^)[2] := TSingle(v3^)[2]; TSingle(v2^)[3] := TSingle(v3^)[3] ;
        TSingle(v1^)[1] := TSingle(v0^)[1] ; TSingle(v1^)[2] := TSingle(v0^)[2]; TSingle(v1^)[3] := TSingle(v0^)[3] ;
        TSingle(v6^)[1] := TSingle(v5^)[1] ; TSingle(v6^)[2] := TSingle(v5^)[2]; TSingle(v6^)[3] := TSingle(v5^)[3] ;
        TSingle(v0^)[1] := TSingle(v4^)[1] ; TSingle(v0^)[2] := TSingle(v4^)[2]; TSingle(v0^)[3] := TSingle(v4^)[3] ;

        // V3
        v_X.Seek((t2)*self.yCoord.SDPrec, soFromBeginning) ;
        v_X.Read(TSingle(v3^)[1],4) ;
        v_Y.Seek((t1)*self.yCoord.SDPrec, soFromBeginning) ;
        v_Y.Read(TSingle(v3^)[2],4) ;
        line_2.Seek((t2)*self.yCoord.SDPrec,soFromBeginning) ;
        line_2.Read(TSingle(v3^)[3],4) ;
        // V4
        v_X.Seek((t2-1)*self.yCoord.SDPrec, soFromBeginning) ;
        v_X.Read(TSingle(v4^)[1],4) ;
        v_Y.Read(TSingle(v4^)[2],4) ;
        line_3.Seek((t2-1)*self.yCoord.SDPrec,soFromBeginning) ;
        line_3.Read(TSingle(v4^)[3],4) ;
        // V5
        v_X.Seek((t2-2)*self.yCoord.SDPrec, soFromBeginning) ;
        v_X.Read(TSingle(v5^)[1],4) ;
        v_Y.Seek((t1+1)*self.yCoord.SDPrec, soFromBeginning) ;
        v_Y.Read(TSingle(v5^)[2],4) ;
        line_3.Seek((t2-2)*self.yCoord.SDPrec,soFromBeginning) ;
        line_3.Read(TSingle(v5^)[3],4) ;


        GetGLColor(TSingle(v0^)[3], c1 )  ;
        TSingle(c1^)[3] := TSingle(c1^)[3] + 0.1 ;
        glColor3fv( c1  );
        GetNormalAveragedS_V(v0, v1, v2, v3, v4, v5, v6, n1) ;
        glNormal3fv(n1) ;  // First points normal
        glVertex3fv(v0) ;  // first pointes vertex

      end ;  // t2 loop

      glEnd ; //GL_TRIANGLE_STRIP ;

    end ;     // t1 loop (single loop)
  // END OF FIRST LINE AT EDGE OF IMAGE


  line_1.Seek(0, soFromBeginning) ;
  line_2.Seek(0, soFromBeginning) ;
  line_3.Seek(0, soFromBeginning) ;
  for t1 :=  2 to self.yCoord.numRows - 1 do  // get next line of XYZ points
  begin
    glBegin(GL_TRIANGLE_STRIP); //GL_TRIANGLE_STRIP ;

    // 1st vertex in TRIANGLE strip
    // get center Vertex (v0)
    //  V0
    v_X.Seek(0, soFromBeginning) ;
    v_X.Read(TSingle(v0^)[1],4) ;
    v_Y.Seek((t1-1)*self.yCoord.SDPrec, soFromBeginning) ;
    v_Y.Read(TSingle(v0^)[2],4) ;
    line_2.Read(TSingle(v0^)[3],4) ;

    // read vertex from 12 o'clock (v1) until 6 pm (v4)
    //  V1
    v_X.Seek(0, soFromBeginning) ;
    v_X.Read(TSingle(v1^)[1],4) ;
    v_Y.Seek((t1-2)*self.yCoord.SDPrec, soFromBeginning) ;
    v_Y.Read(TSingle(v1^)[2],4) ;
    line_1.Read(TSingle(v1^)[3],4) ;
    // V2
    v_X.Read(TSingle(v2^)[1],4) ;
    v_Y.Seek(-self.yCoord.SDPrec, soFromCurrent) ;
    v_Y.Read(TSingle(v2^)[2],4) ;
    line_1.Read(TSingle(v2^)[3],4) ;
    // V3
    v_X.Seek(4, soFromBeginning) ;
    v_X.Read(TSingle(v3^)[1],4) ;
    v_Y.Seek((t1-1)*self.yCoord.SDPrec, soFromBeginning) ;
    v_Y.Read(TSingle(v3^)[2],4) ;
    line_2.Read(TSingle(v3^)[3],4) ;
    // V4
    v_X.Seek(0, soFromBeginning) ;
    v_X.Read(TSingle(v4^)[1],4) ;
    v_Y.Seek((t1)*self.yCoord.SDPrec, soFromBeginning) ;
    v_Y.Read(TSingle(v4^)[2],4) ;
    line_3.Read(TSingle(v4^)[3],4) ;


    GetGLColor(TSingle(v0^)[3], c1 )  ;
    glColor3fv( c1  );
    GetNormalAveragedS_V(v0, v1, v2, v3, v4, nil, nil, n1) ;
    glNormal3fv(n1) ;  // First points normal
    glVertex3fv( v0 ) ;  // first pointes vertex


    // Second vertex in TRIANGLE strip
//    tp1 := v
    TSingle(v1^)[1] := TSingle(v0^)[1] ; TSingle(v1^)[2] := TSingle(v0^)[2]; TSingle(v1^)[3] := TSingle(v0^)[3] ;
    TSingle(v0^)[1] := TSingle(v4^)[1] ; TSingle(v0^)[2] := TSingle(v4^)[2]; TSingle(v0^)[3] := TSingle(v4^)[3] ;
    TSingle(v2^)[1] := TSingle(v3^)[1] ; TSingle(v2^)[2] := TSingle(v3^)[2]; TSingle(v2^)[3] := TSingle(v3^)[3] ;

    // V3
    v_X.Seek(4, soFromBeginning) ;
    v_X.Read(TSingle(v3^)[1],4) ;
    v_Y.Seek(t1*self.yCoord.SDPrec, soFromBeginning) ;
    v_Y.Read(TSingle(v3^)[2],4) ;
    line_3.Read(TSingle(v3^)[3],4) ;

    // V4
    v_X.Seek(0, soFromBeginning) ;
    v_X.Read(TSingle(v4^)[1],4) ;
    v_Y.Seek((t1+1)*self.yCoord.SDPrec, soFromBeginning) ;
    v_Y.Read(TSingle(v4^)[2],4) ;
    line_4.Read(TSingle(v4^)[3],4) ;


    GetGLColor(TSingle(v0^)[3], c1 )  ;
    glColor3fv( c1  );
    GetNormalAveragedS_V(v0, v1, v2, v3, v4, nil, nil, n1) ;
    glNormal3fv(n1) ;  // First points normal
    glVertex3fv(v0) ;  // first pointes vertex


    for t2 := 2 to  self.yCoord.numCols do
    begin
       // top vertex in TRIANGLE strip
       // center Vertex (v0)
       TSingle(v4^)[1] := TSingle(v3^)[1] ; TSingle(v4^)[2] := TSingle(v3^)[2]; TSingle(v4^)[3] := TSingle(v3^)[3] ;
       TSingle(v5^)[1] := TSingle(v0^)[1] ; TSingle(v5^)[2] := TSingle(v0^)[2]; TSingle(v5^)[3] := TSingle(v0^)[3] ;
       TSingle(v6^)[1] := TSingle(v1^)[1] ; TSingle(v6^)[2] := TSingle(v1^)[2]; TSingle(v6^)[3] := TSingle(v1^)[3] ;
       TSingle(v0^)[1] := TSingle(v2^)[1] ; TSingle(v0^)[2] := TSingle(v2^)[2]; TSingle(v0^)[3] := TSingle(v2^)[3] ;

       // V1
       v_X.Seek((t2-1)*self.yCoord.SDPrec, soFromBeginning) ;
       v_X.Read(TSingle(v1^)[1],4) ;
       v_Y.Seek((t1-2)*self.yCoord.SDPrec, soFromBeginning) ;
       v_Y.Read(TSingle(v1^)[2],4) ;
       line_1.Seek((t2-1)*self.yCoord.SDPrec,soFromBeginning) ;
       line_1.Read(TSingle(v1^)[3],4) ;
       // V2
       v_X.Read(TSingle(v2^)[1],4) ;
       v_Y.Seek((t1-2)*self.yCoord.SDPrec, soFromBeginning) ;
       v_Y.Read(TSingle(v2^)[2],4) ;
       line_1.Read(TSingle(v2^)[3],4) ;
       // V3
       v_X.Seek((t2)*self.yCoord.SDPrec, soFromBeginning) ;
       v_X.Read(TSingle(v3^)[1],4) ;
       v_Y.Seek((t1-1)*self.yCoord.SDPrec, soFromBeginning) ;
       v_Y.Read(TSingle(v3^)[2],4) ;
       line_2.Seek((t2)*self.yCoord.SDPrec,soFromBeginning) ;
       line_2.Read(TSingle(v3^)[3],4) ;


       GetGLColor(TSingle(v0^)[3], c1 )  ;
       glColor3fv( c1  );
       GetNormalAveragedS_V(v0, v1, v2, v3, v4, v5, v6, n1) ;
       glNormal3fv(n1) ;  // First points normal
       glVertex3fv( v0 ) ;  // first points vertex

       // Second vertex
       TSingle(v2^)[1] := TSingle(v3^)[1] ; TSingle(v2^)[2] := TSingle(v3^)[2]; TSingle(v2^)[3] := TSingle(v3^)[3] ;
       TSingle(v1^)[1] := TSingle(v0^)[1] ; TSingle(v1^)[2] := TSingle(v0^)[2]; TSingle(v1^)[3] := TSingle(v0^)[3] ;
       TSingle(v6^)[1] := TSingle(v5^)[1] ; TSingle(v6^)[2] := TSingle(v5^)[2]; TSingle(v6^)[3] := TSingle(v5^)[3] ;
       TSingle(v0^)[1] := TSingle(v4^)[1] ; TSingle(v0^)[2] := TSingle(v4^)[2]; TSingle(v0^)[3] := TSingle(v4^)[3] ;

      // V3
       v_X.Seek((t2)*self.yCoord.SDPrec, soFromBeginning) ;
       v_X.Read(TSingle(v3^)[1],4) ;
       v_Y.Seek((t1)*self.yCoord.SDPrec, soFromBeginning) ;
       v_Y.Read(TSingle(v3^)[2],4) ;
       line_3.Seek((t2)*self.yCoord.SDPrec,soFromBeginning) ;
       line_3.Read(TSingle(v3^)[3],4) ;
       // V4
       v_X.Seek((t2-1)*self.yCoord.SDPrec, soFromBeginning) ;
       v_X.Read(TSingle(v4^)[1],4) ;
       //v_Y.Seek((t1)*self.yCoord.SDPrec, soFromBeginning) ;
       v_Y.Read(TSingle(v4^)[2],4) ;
       line_4.Seek((t2-1)*self.yCoord.SDPrec,soFromBeginning) ;
       line_4.Read(TSingle(v4^)[3],4) ;
       // V5
       v_X.Seek((t2-2)*self.yCoord.SDPrec, soFromBeginning) ;
       v_X.Read(TSingle(v5^)[1],4) ;
       v_Y.Seek((t1+1)*self.yCoord.SDPrec, soFromBeginning) ;
       v_Y.Read(TSingle(v5^)[2],4) ;
       line_4.Seek((t2-2)*self.yCoord.SDPrec,soFromBeginning) ;
       line_4.Read(TSingle(v5^)[3],4) ;


       GetGLColor(TSingle(v0^)[3], c1 )  ;
       TSingle(c1^)[3] := TSingle(c1^)[3] + 0.1 ;
       glColor3fv( c1  );
       GetNormalAveragedS_V(v0, v1, v2, v3, v4, v5, v6, n1) ;
       glNormal3fv(n1) ;  // First points normal
       glVertex3fv(v0) ;  // first pointes vertex
    //   TSingle(v0^)[3] :=  TSingle(v0^)[3] / 100 ;
    end ;

    glEnd ; //GL_TRIANGLE_STRIP ;

    CopyRow(t1, line_1, self.yCoord) ;
    CopyRow(t1+1,   line_2, self.yCoord) ;
    CopyRow(t1+2, line_3, self.yCoord) ;
    CopyRow(t1+3, line_4, self.yCoord) ;

    line_1.Seek(0,soFromBeginning) ;
    line_2.Seek(0,soFromBeginning) ;
    line_3.Seek(0,soFromBeginning) ;
    line_4.Seek(0,soFromBeginning) ;


  end ;

  glDisable(GL_DEPTH_TEST) ;

finally
  line_1.Free ;
  line_2.Free ;
  line_3.Free ;
  line_4.Free ;
  v_X.Free ;
  v_Y.Free ;
//  aveReduced.Free ;
  FreeMem(n1) ;
  FreeMem(c1) ;
  FreeMem(v0) ;
  FreeMem(v1) ;
  FreeMem(v2) ;
  FreeMem(v3) ;
  FreeMem(v4) ;
  FreeMem(v5) ;
  FreeMem(v6) ;
end ;

end ;


function  TSpectraRanges.GetNormalS_V(v1, v2, v3: pointer ; normalize : boolean;  returnArray : pointer) : pointer ;
var
s1, s2 : array[1..3] of single ;
Length : double ;
begin

S1[1] := TSingle(V1^)[1]-TSingle(V2^)[1] ;
S1[2] := TSingle(V1^)[2]-TSingle(V2^)[2] ;
S1[3] := TSingle(V1^)[3]-TSingle(V2^)[3] ;  // convert 3 points into 2 vectors
S2[1] := TSingle(V2^)[1]-TSingle(V3^)[1] ;
S2[2] := TSingle(V2^)[2]-TSingle(V3^)[2] ;
S2[3] := TSingle(V2^)[3]-TSingle(V3^)[3] ;

TSingle(returnArray^)[1] := (S1[2]*S2[3])-(S1[3]*S2[2])   ;  // calculate cross product of the two vectors
TSingle(returnArray^)[2] := (S1[3]*S2[1])-(S1[1]*S2[3])   ;
TSingle(returnArray^)[3] := (S1[1]*S2[2])-(S1[2]*S2[1])   ;


If Normalize then
begin
  TSingle(returnArray^)[4] := sqrt( sqr(TSingle(returnArray^)[1]) +  sqr(TSingle(returnArray^)[2]) + sqr(TSingle(returnArray^)[3]) )   ;
  If TSingle(returnArray^)[4] <> 0 Then
  begin
    TSingle(returnArray^)[1] := TSingle(returnArray^)[1] / TSingle(returnArray^)[4] ;
    TSingle(returnArray^)[2] := TSingle(returnArray^)[2] / TSingle(returnArray^)[4] ;
    TSingle(returnArray^)[3] := TSingle(returnArray^)[3] / TSingle(returnArray^)[4] ;
    TSingle(returnArray^)[4] := TSingle(returnArray^)[4] / 2   // if area wanted divide total by 2
  end ;
end ;

 result := returnArray ;

end ;



procedure TSpectraRanges.GetNormalAveragedS_V(v0, v1, v2, v3, v4, v5, v6 : pointer ; retAr : pointer) ;
var
  n1 : pointer ;
begin
 try
  GetMem(n1,4*sizeof(single)) ;

  if (v1 <> nil) and (v2 <> nil) then
  begin
    n1 := GetNormalS_V(v0, v1,v2, false, n1) ;
    TSingle(retAr^)[1] := TSingle( n1^)[1] ;  TSingle(retAr^)[2] :=  TSingle(n1^)[2] ;  TSingle(retAr^)[3] :=  TSingle(n1^)[3] ;
  end ;
  if (v2 <> nil) and (v3 <> nil) then
  begin
    GetNormalS_V(v0, v2, v3, false,n1) ;
    TSingle(retAr^)[1] := TSingle(retAr^)[1] + TSingle( n1^)[1] ;  TSingle(retAr^)[2] := TSingle(retAr^)[2] +  TSingle(n1^)[2] ;  TSingle(retAr^)[3] := TSingle(retAr^)[3] +  TSingle(n1^)[3] ;
  end ;
  if (v3 <> nil) and (v4 <> nil) then
  begin
    GetNormalS_V(v0, v3, v4, false,n1) ;
    TSingle(retAr^)[1] := TSingle(retAr^)[1] + TSingle( n1^)[1] ;  TSingle(retAr^)[2] := TSingle(retAr^)[2] +  TSingle(n1^)[2] ;  TSingle(retAr^)[3] := TSingle(retAr^)[3] +  TSingle(n1^)[3] ;
   end ;

  if (v4 <> nil) and (v5 <> nil) then
  begin
    GetNormalS_V(v0, v4, v5, false,n1) ;
    TSingle(retAr^)[1] := TSingle(retAr^)[1] + TSingle( n1^)[1] ;  TSingle(retAr^)[2] := TSingle(retAr^)[2] +  TSingle(n1^)[2] ;  TSingle(retAr^)[3] := TSingle(retAr^)[3] +  TSingle(n1^)[3] ;
  end ;
  if (v5 <> nil) and (v6 <> nil) then
  begin
    GetNormalS_V(v0, v5, v6, false,n1) ;
    TSingle(retAr^)[1] := TSingle(retAr^)[1] + TSingle( n1^)[1] ;  TSingle(retAr^)[2] := TSingle(retAr^)[2] +  TSingle(n1^)[2] ;  TSingle(retAr^)[3] := TSingle(retAr^)[3] +  TSingle(n1^)[3] ;
  end ;
  if (v6 <> nil) and (v1 <> nil) then
  begin
    GetNormalS_V(v0, v1, v6, false,n1) ;
    TSingle(retAr^)[1] := TSingle(retAr^)[1] + TSingle( n1^)[1] ;  TSingle(retAr^)[2] := TSingle(retAr^)[2] +  TSingle(n1^)[2] ;  TSingle(retAr^)[3] := TSingle(retAr^)[3] +  TSingle(n1^)[3] ;
  end ;
  // determine length and the normalise
  TSingle(retAr^)[4] := sqrt( sqr(TSingle(retAr^)[1]) +  sqr(TSingle(retAr^)[2]) + sqr(TSingle(retAr^)[3]) )   ;
  If TSingle(retAr^)[4] <> 0 Then
  begin
    TSingle(retAr^)[1] := TSingle(retAr^)[1] / TSingle(retAr^)[4] ;
    TSingle(retAr^)[2] := TSingle(retAr^)[2] / TSingle(retAr^)[4] ;
    TSingle(retAr^)[3] := TSingle(retAr^)[3] / TSingle(retAr^)[4] ;
    TSingle(retAr^)[4] := TSingle(retAr^)[4] / 2   // if area wanted divide total by 2
  end ;
finally
  FreeMem(n1) ;
end ;

end ;    




{procedure TSpectraRanges.GetNormalS(v1, v2, v3: array of Single; normalize : boolean; var returnArray : array of Single) ;
var
s1, s2 : array[0..2] of single ;
Length : double ;
begin

S1[0] := V1[0]-V2[0] ;  S1[1] := V1[1]-V2[1] ; S1[2] := V1[2]-V2[2] ;  // convert 3 points into 2 vectors
S2[0] := V2[0]-V3[0] ;  S2[1] := V2[1]-V3[1] ; S2[2] := V2[2]-V3[2] ;

returnArray[0] := (S1[1]*S2[2])-(S1[2]*S2[1])   ;  // calculate cross product of the two vectors
returnArray[1] := (S1[2]*S2[0])-(S1[0]*S2[2])   ;
returnArray[2] := (S1[0]*S2[1])-(S1[1]*S2[0])   ;

returnArray[3] := sqrt( sqr(returnArray[0]) +  sqr(returnArray[1]) + sqr(returnArray[2]) )   ;

If Normalize then
begin
  If returnArray[0] <> 0 Then
  begin
    returnArray[0] := returnArray[0] / returnArray[3] ;
    returnArray[1] := returnArray[1] / returnArray[3] ;
    returnArray[2] := returnArray[2] / returnArray[3] ;
    returnArray[3] := returnArray[3] / 2   // if area wanted divide total by 2
  end ;
end ;
end ;    }


// finds max and min of both TMemoryStream x, y and imaginary data and sets XLow/Xhigh/YLow/YHigh to equal them
procedure TSpectraRanges.SetOpenGLXYRangeScatterPlot(draw : integer) ;
var
 t1, t2 : integer ;
 s1, s2 : single ;
 d1, d2 : double ;
 tempYMin, tempYMax : single ;
 maxMinValue : TMaxMin ; // this has to be disposed of at end of function
begin
  YHigh := Math.MinSingle ;
  YLow := Math.MaxSingle ;

  XHigh := -Math.MaxSingle ;
  XLow  := Math.MaxSingle ;

  // For X data
  self.xCoord.F_Mdata.Seek(0,soFromBeginning) ;
  if self.xCoord.SDPrec = 4 then
  begin
    for t1 := 0 to yCoord.numCols -1 do   // for each row
    begin
    self.xCoord.F_Mdata.Read(s1,4) ;
    if s1 <  XLow then
      self.XLow := s1 ;
      
    if s1 >  XHigh then
      self.XHigh := s1 ;
    end ;
  end
  else
  if self.xCoord.SDPrec = 8 then
  begin
    for t1 := 0 to yCoord.numCols -1 do   // for each row
    begin
    self.xCoord.F_Mdata.Read(d1,8) ;
    if d1 <  XLow then
      self.XLow := d1 ;
    if d1 >  XHigh then
      self.XHigh := d1 ;
    end ;
  end  ;
  self.xCoord.F_Mdata.Seek(0,soFromBeginning) ;

  // For Y data - Real Part
  for t1 := 0 to yCoord.numRows -1 do   // for each row
  begin
    maxMinValue := yCoord.GetMinAndMaxValAndPos(t1,0) ;

    tempYMin := single(maxMinValue.GetDataPointer(1)^) ;
    tempYMax := single(maxMinValue.GetDataPointer(2)^) ;
    if tempYMin <  YLow then
      self.YLow := tempYMin ;
    if tempYMax >  YHigh then
      self.YHigh := tempYMax ;
  end ;
  if maxMinValue <> nil then maxMinValue.Free ;

  // For Y data - Imaginary Part: if it exists
  if yImaginary <> nil then
  begin
    for t1 := 0 to yImaginary.numRows -1 do   // for each row
    begin
      maxMinValue := yImaginary.GetMinAndMaxValAndPos(t1,0) ;

      tempYMin := single(maxMinValue.GetDataPointer(1)^) ;
      tempYMax := single(maxMinValue.GetDataPointer(2)^) ;
      if tempYMin <  YLow then
        self.YLow := tempYMin ;
      if tempYMax >  YHigh then
        self.YHigh := tempYMax ;
    end ;

    if maxMinValue <> nil then maxMinValue.Free ;
  end ;

end ;


// This fills the xCoord TMatrix with data
procedure TSpectraRanges.FillXCoordData(startVal, increment: single; direction : integer) ;
// if 'direction' =  1 then standard fill forward in memory
// if 'direction' = -1 then fill backward in memory
var
   t1 : integer ;
   s1 : single  ;
   d1 : double  ;
begin
   if direction = 1  then
   begin
      self.xCoord.F_Mdata.Seek(0,soFromCurrent) ;
      if self.xCoord.SDPrec = 4 then
      begin
        s1 := startVal ;
        for t1 := 1 to self.yCoord.numCols do
        begin
          s1 := s1 + increment ;
          self.xCoord.F_Mdata.Write(s1,self.xCoord.SDPrec) ;
        end
      end
      else
      if self.xCoord.SDPrec = 8 then
      begin
        d1 := startVal ;
        for t1 := 1 to self.yCoord.numCols do
        begin
          d1 := d1 + increment ;
          self.xCoord.F_Mdata.Write(d1,self.xCoord.SDPrec) ;
        end
      end;
      self.xCoord.F_Mdata.Seek(0,soFromCurrent) ;
   end
   else
   if direction = -1  then
   begin
      self.xCoord.F_Mdata.Seek(-4,soFromEnd) ;
      if self.xCoord.SDPrec = 4 then
      begin
        s1 := startVal ;
        for t1 := 1 to self.yCoord.numCols do
        begin
          s1 := s1 + increment ;
          self.xCoord.F_Mdata.Write(s1,self.xCoord.SDPrec) ;
          if t1 <> self.yCoord.numCols then
            self.xCoord.F_Mdata.Seek(-(2)*self.xCoord.SDPrec,soFromCurrent) ;
        end
      end
      else
      if self.xCoord.SDPrec = 8 then
      begin
        d1 := startVal ;
        for t1 := 1 to self.yCoord.numCols do
        begin
          d1 := d1 + increment ;
          self.xCoord.F_Mdata.Write(d1,self.xCoord.SDPrec) ;
          if t1 <> self.yCoord.numCols then
            self.xCoord.F_Mdata.Seek(-(2)*self.xCoord.SDPrec,soFromCurrent) ;
        end
      end;
      self.xCoord.F_Mdata.Seek(0,soFromCurrent) ;
   end
end;



// finds max and min of both TMemoryStream x, y and imaginary data and sets XLow/Xhigh/YLow/YHigh to equal them
procedure TSpectraRanges.SetOpenGLXYRange(draw : integer) ;
var
 t1, t2 : integer ;
 s1, s2 : single ;
 d1, d2 : double ;
 tempYMin, tempYMax : single ;
 maxMinValue : TMaxMin ; // this has to be disposed of at end of function
begin


if (not xyScatterPlot) and (not varianceIsDisplayed)  then
begin
  YHigh := Math.MinSingle ;
  YLow  := Math.MaxSingle ;

  // For X data
  self.xCoord.F_Mdata.Seek(0,soFromBeginning) ;
  if self.xCoord.SDPrec = 4 then
  begin
     maxMinValue := xCoord.GetMinAndMaxValAndPos(0,0) ;

    tempYMin := single(maxMinValue.GetDataPointer(1)^) ;
    tempYMax := single(maxMinValue.GetDataPointer(2)^) ;
    self.XLow := tempYMin ;
    self.XHigh := tempYMax ;

    maxMinValue.Free ;
  end
  else  if self.xCoord.SDPrec = 8 then
  begin
     maxMinValue := xCoord.GetMinAndMaxValAndPos(0,0) ;

    tempYMin := single(maxMinValue.GetDataPointer(1)^) ;
    tempYMax := single(maxMinValue.GetDataPointer(2)^) ;
    self.XLow := tempYMin ;
    self.XHigh := tempYMax ;
    maxMinValue.Free ;
  end ;

  if XHigh = XLow then
  begin
       XHigh := XHigh + 1 ;
       XLow := XLow - 1 ;
  end;

  // For Y data - Real Part
  for t1 := 0 to yCoord.numRows -1 do   // for each row
  begin
    maxMinValue := yCoord.GetMinAndMaxValAndPos(t1,0) ;

    tempYMin := single(maxMinValue.GetDataPointer(1)^) ;
    tempYMax := single(maxMinValue.GetDataPointer(2)^) ;
    if tempYMin <  YLow then
      self.YLow := tempYMin ;
    if tempYMax >  YHigh then
      self.YHigh := tempYMax ;

      maxMinValue.Free ;
  end ;

//  if maxMinValue <> nil then maxMinValue.Free ;

  // For Y data - Imaginary Part: if it exists
{  if yImaginary <> nil then
  begin
    for t1 := 0 to yImaginary.numRows -1 do   // for each row
    begin
      maxMinValue := yImaginary.GetMinAndMaxValAndPos(t1,0) ;

      tempYMin := single(maxMinValue.GetDataPointer(1)^) ;
      tempYMax := single(maxMinValue.GetDataPointer(2)^) ;
      if tempYMin <  YLow then
        self.YLow := tempYMin ;
      if tempYMax >  YHigh then
        self.YHigh := tempYMax ;
    end ;
    if maxMinValue <> nil then maxMinValue.Free ;
  end ;  }
end
else   // data is an xy scatter plot
if  xyScatterPlot then
begin
   SetOpenGLXYRangeScatterPlot(draw) ;
end
else   // data is an xy scatter plot
if  varianceIsDisplayed then
begin
   SetOpenGLXYRangeVariance(draw) ;
end ;

    self.xCoord.F_Mdata.Seek(0,soFromBeginning) ;
    self.yCoord.F_Mdata.Seek(0,soFromBeginning) ;
end ;



// finds max and min of both TMemoryStream x, y and imaginary data and sets XLow/Xhigh/YLow/YHigh to equal them
procedure TSpectraRanges.SetOpenGLXYRangeVariance(draw : integer) ;
var
 t1, t2 : integer ;
 s1, s2 : single ;
 d1, d2 : double ;

begin
  YHigh := -Math.MaxSingle ;
  YLow := Math.MaxSingle ;

  XHigh := -Math.MaxSingle ;
  XLow  := Math.MaxSingle ;

  // For X data - Same as usual data
  self.xCoord.F_Mdata.Seek(0,soFromBeginning) ;
  if self.xCoord.SDPrec = 4 then
  begin
    self.xCoord.F_Mdata.Read(s1,4) ;
    self.xCoord.F_Mdata.Seek(-4,soFromEnd) ;
    self.xCoord.F_Mdata.Read(s2,4) ;
    if s1 < s2 then
    begin
       XLow := s1 ;
       XHigh := s2 ;
    end
    else
    begin
       XLow := s2 ;
       XHigh := s1 ;
    end ;
    if fft.FFTReverse = false then
      fft.firstXVal := XLow ;  // used by FFT code to locate original start of data.
  end
  else  if self.xCoord.SDPrec = 8 then
  begin
    self.xCoord.F_Mdata.Read(d1,8) ;
    self.xCoord.F_Mdata.Seek(-8,soFromEnd) ;
    self.xCoord.F_Mdata.Read(d2,8) ;
    if d1 < d2 then
    begin
       XLow := d1 ;
       XHigh := d2 ;
    end
    else
    begin
       XLow := d2 ;
       XHigh := d1 ;
    end ;
  end ;
  self.xCoord.F_Mdata.Seek(0,soFromBeginning) ;

  // For Y data - Use VARIANCE data
  self.yCoord.F_MVariance.Seek(0,soFromBeginning) ;
  for t1 := 0 to yCoord.numRows -1 do   // for each row
  begin
    if self.yCoord.SDPrec = 4 then
    begin
      self.yCoord.F_MVariance.Read(s1,4 ) ;
      d1 := s1 ;
    end
    else
    if self.yCoord.SDPrec = 8 then
    begin
      self.yCoord.F_MVariance.Read(d1,8 ) ;
    end ;
    if d1 <  YLow then
      self.YLow := d1 ;
    if d1 >  YHigh then
      self.YHigh := d1 ;

  end ;

  // For Y data - Imaginary Part: does not exist for Variance data

end ;




procedure TSpectraRanges.ShiftData(offSet : single) ;  // only need to shift x data
var
  t1 : integer ;
  s1 : single ;
  d1 : double ;
begin
    self.SeekFromBeginning(1,1,0) ;
    for t1 := 1 to xCoord.numCols do // for each x point
    begin
      if (self.xCoord.SDPrec = 4) then
      begin
         self.xCoord.F_Mdata.Read(s1,xCoord.SDPrec) ;
         s1 := s1 + offset ;
         self.xCoord.F_Mdata.Seek(-xCoord.SDPrec,soFromCurrent) ;
         self.xCoord.F_Mdata.Write(s1,xCoord.SDPrec) ;
      end
      else
      begin
         self.xCoord.F_Mdata.Read(d1,xCoord.SDPrec) ;
         d1 := d1 + offset ;
         self.xCoord.F_Mdata.Seek(-xCoord.SDPrec,soFromCurrent) ;
         self.xCoord.F_Mdata.Write(d1,xCoord.SDPrec) ;
      end ;
    end ;
    self.SeekFromBeginning(3,1,0) ;

end ;

procedure TSpectraRanges.DoMODISSOAPDataImport(filename : string; YStart,YFin, numBandsIn : integer)  ;
var
  t1,t2 : integer ;
  s1 : single ;
  d1, scale_d1 : double ;
  tMat : TMatrix ;
begin
    self.xCoord.LoadXMatrixDataFromMODISCSV(filename,YStart,YFin) ;
    // find the scale factor in the file and scale the y data
    if Form2.DendroFindScaleMODIS_CB.Checked then
    begin
//      self.Transpose ;
      scale_d1 := self.yCoord.FindScaleFromMODISCSV(filename) ;
      if scale_d1 <> 0.0 then
      begin
      self.yCoord.F_Mdata.Seek(0,soFromBeginning) ;
      if self.yCoord.SDPrec = 4 then
      begin
        for t1 := 0 to self.yCoord.numCols-1 do
        begin
          self.yCoord.F_Mdata.Read(s1,4) ;
          s1 := scale_d1 * s1 ;
          self.yCoord.F_Mdata.Seek(-4,soFromCurrent) ;
          self.yCoord.F_Mdata.Write(s1,4) ;
        end ;
      end
      else  // SDPrec = 8
      begin
        for t1 := 0 to self.yCoord.numCols-1 do
        begin
          self.yCoord.F_Mdata.Read(d1,8) ;
          d1 := scale_d1 * d1 ;
          self.yCoord.F_Mdata.Seek(-8,soFromCurrent) ;
          self.yCoord.F_Mdata.Write(d1,8) ;
        end ;
      end ; // SDPrec = 8
      end ; // scale_d1 <> 0.0
      end ;
      self.yCoord.F_Mdata.Seek(0,soFromBeginning) ;

      if numBandsIn > 1 then
      begin
         self.yCoord.numRows := (self.xCoord.numCols div numBandsIn)   ;
         self.yCoord.numCols :=  numBandsIn ;
         self.yCoord.Transpose ;
       //  self.xCoord.numRows :=  1  ;
       //  self.xCoord.numCols :=  numBandsIn ;
         tMat := TMatrix.Create(self.xCoord.SDPrec) ;
         tMat.CopyMatrix(self.xCoord);
         self.xCoord.ClearData(self.xCoord.SDPrec);
         self.xCoord.F_Mdata.SetSize(self.yCoord.numCols*self.yCoord.SDPrec);
         self.xCoord.numRows := 1 ;
         self.xCoord.numCols := self.yCoord.numCols ;
         t2 :=  (numBandsIn-1) * self.yCoord.SDPrec  ;  // this is the seek step value
         tMat.F_MData.Seek(0,soFromBeginning) ;
         if self.yCoord.SDPrec = 4 then
         begin
            for t1 := 0 to self.yCoord.numCols - 1 do
            begin
               tMat.F_Mdata.Read(s1,4) ;
               self.xCoord.F_Mdata.Write(s1,4) ;
               tMat.F_Mdata.Seek(t2,soFromCurrent) ;
            end;
         end
         else
         if self.yCoord.SDPrec = 8 then
         begin
            for t1 := 0 to self.yCoord.numCols - 1 do
            begin
               tMat.F_Mdata.Read(d1,8) ;
               self.xCoord.F_Mdata.Write(d1,8) ;
               tMat.F_Mdata.Seek(t2,soFromCurrent) ;
            end;
         end;
         tMat.Free ;
      end;
      

end;



function TSpectraRanges.LoadXYDataFile : integer ;
// interpret form data on 'file import' tab page
Var
  tStr1: String ;
  t1, t2, t3 : integer ;

  delimiter : string ;
  inRowsOrCols : boolean ;
  XDataRow, XStart, XFin, YStart, YFin, numMODISBands : integer ;

  firstXVal_, XstepVal : single  ;
  s1 : single ;
  d1, scale_d1 : double ;
begin

  try // get input data
  // interpret form data on 'file import' tab page
    if Form2.DataInColsRadButton.Checked then
      inRowsOrCols := true
    else  if Form2.DataInRowsRadButton.checked then
      inRowsOrCols := false ;

    XDataRow := strtoInt(Form2.XDataRowColEdit.Text) ;
    tStr1 := Form2.XRangeEditBox.text ;
    t1 := pos('-',tStr1) ;
    if t1 > 0 then
    begin
      XStart := strtoint(copy(tStr1,1,t1-1)) ;
      tStr1 :=  copy(tStr1,t1+1,Length(tStr1)-t1) ;
      tStr1 := trim(tStr1) ;
      if Length(tStr1) > 0 then
         XFin := strtoint(tStr1)
      else
        XFin := 0 ;
    end ;
    tStr1 := Form2.YDataRangeEdit.text ;
    t1 := pos('-',tStr1) ;
    if t1 > 0 then
    begin
      YStart := strtoint(copy(tStr1,1,t1-1)) ;
      tStr1 :=  copy(tStr1,t1+1,Length(tStr1)-t1) ;
      tStr1 := trim(tStr1) ;
      if Length(tStr1) > 0 then
         YFin := strtoint(tStr1)
      else
        YFin := 0 ;
    end ;
    delimiter :=  Form2.DelimiterEditBox.Text ;
    delimiter := trim(delimiter) ;
    if (lowercase(delimiter) = 'space') then
      delimiter := ' '
    else if lowercase(delimiter) = 'tab' then
      delimiter := #9
    else if (lowercase(delimiter) = ',') or (lowercase(delimiter) = 'comma') then
      delimiter := ',' ;
    if not((delimiter = ' ') or (delimiter = #9) or (delimiter = ',')) then
      delimiter := '' ;

    If Form2.CheckBox3.Checked Then   // if Calculate X values is true
    begin  // firstXVal, XstepVal
       firstXVal_ := strtofloat( Form2.Edit29.Text ) ;
       XstepVal  := strtofloat( Form2.Edit16.Text ) ;
    end
  except on Exception do
  begin
    messagedlg('TSpectraRanges.LoadXYDataFile() Error:'+#13+'Incorrect input parameter in File Import details' ,mtError,[mbOK],0) ;
    exit ;
  end ;
  end ;


  try
    // load Y data from file  - y data determines number of x data points
    if inRowsOrCols = true then // data in Rows
         self.yCoord.LoadMatrixDataFromTxtFile(self.xCoord.filename,YStart,YFin,XStart,XFin,delimiter)
    else
    begin
         self.yCoord.LoadMatrixDataFromTxtFile(self.xCoord.filename,XStart,XFin,YStart,YFin,delimiter) ;
         self.yCoord.Transpose ;
    end ;
    // now add X data - y data determines number of x data points
    If Form2.CheckBox3.Checked Then   // if Calculate X values is true
    begin
      if Form2.DendroMODISDataCB.Checked then   // if 'MODIS' satellite data
      begin
         self.yCoord.Transpose ;
         numMODISBands := strtoint( Form2.DendroMODISNumberOfBands.Text ) ;
         self.DoMODISSOAPDataImport(self.xCoord.filename,YStart,YFin, numMODISBands) ;
      end
      else
      begin
         // firstXVal_ := strtofloat( Form2.Edit29.Text ) ;
         // XstepVal  := strtofloat( Form2.Edit16.Text ) ;
         self.xCoord.ClearData(self.xCoord.SDPrec div 4) ;
         self.xCoord.numRows := 1 ;
         self.xCoord.numCols := self.yCoord.numCols ;   // y data determines number of x data points
         self.xCoord.F_Mdata.SetSize(self.xCoord.numCols*self.xCoord.SDPrec) ;
         self.xCoord.F_Mdata.Seek(0,soFromBeginning) ;
         for t1 := 0 to self.xCoord.numCols-1 do
         begin
            if self.xCoord.SDPrec = 4 then
            begin
              s1 := firstXVal_ + (t1*XstepVal);
              self.xCoord.F_Mdata.Write(s1,4) ;
            end
            else
            begin
              d1 := firstXVal_ + (t1*XstepVal) ;
              self.xCoord.F_Mdata.Write(d1,8) ;
            end ;

         end ;
         self.xCoord.F_Mdata.Seek(0,soFromBeginning) ;
      end;
    end
    else // load X data from file
    begin
       // LoadMatrixDataFromTxtFile(filenameIn : string ; startLineIn, endLineIn, startColIn, endColIn : integer; inDelimeter : string; rowOrCol: boolean) :  boolean ;
       if inRowsOrCols = true then // data in Rows
         self.xCoord.LoadMatrixDataFromTxtFile(self.xCoord.filename,XDataRow,{XDataRow}0,XStart,XFin,delimiter)
       else
       begin
         self.xCoord.LoadMatrixDataFromTxtFile(self.xCoord.filename,XStart,XFin,XDataRow,XDataRow,delimiter) ;
         self.xCoord.Transpose ;
       end ;

       if Form2.SetStartTo1stValue.checked then
       begin
          XstepVal  := strtofloat( Form2.Edit16.Text ) ;

          self.xCoord.F_Mdata.Seek(0,soFromBeginning) ;
          self.xCoord.F_Mdata.Read(firstXVal_,4) ;
          self.xCoord.F_Mdata.Seek(-4,soFromEnd) ;
          self.xCoord.F_Mdata.Read(s1,4) ;
          self.xCoord.F_Mdata.Seek(self.xCoord.SDPrec,soFromBeginning) ;
          if firstXVal_ < s1 then
          begin

            for t1 := 1 to self.xCoord.numCols-1 do
            begin
            if self.xCoord.SDPrec = 4 then
            begin
              s1 := firstXVal_ + (t1*XstepVal);
              self.xCoord.F_Mdata.Write(s1,4) ;
            end
            else
            begin
              d1 := firstXVal_ + (t1*XstepVal) ;
              self.xCoord.F_Mdata.Write(d1,8) ;
            end ;
            end ;
          end
          else  // firstXVal_ > s1
          begin
            for t1 := 1 to self.xCoord.numCols-1 do
            begin
            if self.xCoord.SDPrec = 4 then
            begin
              s1 := firstXVal_ - (t1*XstepVal);
              self.xCoord.F_Mdata.Write(s1,4) ;
            end
            else
            begin
              d1 := firstXVal_ - (t1*XstepVal) ;
              self.xCoord.F_Mdata.Write(d1,8) ;
            end ;
            end ;

          end ;
       end ;

    end ;

    self.xCoord.F_Mdata.Seek(0,soFromBeginning) ;
    self.yCoord.F_Mdata.Seek(0,soFromBeginning) ;

  except on Exception do
  begin
     messagedlg('TSpectraRanges.LoadXYDataFile() Error:'+#13+'Failed loading X data range' ,mtError,[mbOK],0) ;
     result := 0 ;
     exit ;
  end ;
  end ;


  // Create OpenGL display list

  result := self.yCoord.numRows  ;

end ;




// This puts data in 'spectra per column' format i.e each row is a wavelengths/variable.. this is excel friendly for spectral data
procedure TSpectraRanges.SaveSpectraDelimExcel(filenameOutput : String; delim : String) ;
var
  t1, t2 : integer ;
  List1 : TStringList ; // the file being created
  s1 : TGLRangeArray ;
  d1 : TGLRangeArrayD ;
  tempStr : string ;
begin
      if delim = ',' then
      begin
        filenameOutput := copy(filenameOutput,1,length(filenameOutput)-length(ExtractFileExt(filenameOutput))) ;
        filenameOutput := filenameOutput + '.csv' ;
      end
      else
      if (delim = #9) or (delim = ' ') then
      begin
        filenameOutput := copy(filenameOutput,1,length(filenameOutput)-length(ExtractFileExt(filenameOutput))) ;
        filenameOutput := filenameOutput + '.txt' ;
      end ;

      try
        List1 :=  TStringList.Create ;

        for t2 := 1 to self.xCoord.numCols  do  // t2 is the variable wanted
        begin
          if (xCoord.SDPrec = 4) then
          begin
            Read_XYrYi_Data(t2,1,@s1,true) ;   // read both X and Y data and write X and Y data

            if self.yImaginary <> nil then
              tempStr := FloatToStrF(s1[0],ffGeneral,7,5) + delim + FloatToStrF(s1[1],ffGeneral,7,5) + delim + FloatToStrF(s1[2],ffGeneral,7,5)
            else
              tempStr := FloatToStrF(s1[0],ffGeneral,7,5) + delim + FloatToStrF(s1[1],ffGeneral,7,5) ;

            for t1 := 2 to self.yCoord.numRows  do
            begin
              Read_YrYi_Data(t2,t1,@s1,true) ; // read only Y data and write only Y data for all other spectra

              if self.yImaginary <> nil then
                tempStr := tempStr + delim + FloatToStrF(s1[0],ffGeneral,7,5) + delim + FloatToStrF(s1[1],ffGeneral,7,5)
              else
               tempStr := tempStr + delim + FloatToStrF(s1[0],ffGeneral,7,5) ;

            end ;
          end
          else
          if (xCoord.SDPrec = 8) then
          begin
            Read_XYrYi_Data(t2,1,@d1,true) ;
            if self.yImaginary <> nil then
              tempStr := FloatToStrF(d1[0],ffGeneral,7,5) + delim + FloatToStrF(d1[1],ffGeneral,7,5) + delim + FloatToStrF(d1[2],ffGeneral,7,5)
            else
               tempStr := FloatToStrF(d1[0],ffGeneral,7,5) + delim + FloatToStrF(d1[1],ffGeneral,7,5)  ;
            for t1 := 2 to self.yCoord.numRows  do
            begin
              Read_YrYi_Data(t2,t1,@s1,true) ;
              if self.yImaginary <> nil then
                tempStr := tempStr + delim + FloatToStrF(d1[0],ffGeneral,7,5) + delim + FloatToStrF(d1[1],ffGeneral,7,5)
              else
                tempStr := tempStr + delim + FloatToStrF(d1[0],ffGeneral,7,5) ;
            end ;
          end ;

          List1.Add(tempStr) ;
        end ;

        List1.SaveToFile(filenameOutput) ;
      finally
        List1.Free();
      end ;
end ;



procedure TSpectraRanges.SaveSpectraRangeDataBinV3( filenameOutput : String ) ;
// version 4: has char values 'v4' as last data entries
// binary format : <DATA><variance data><average data><all X DATA><rowNum><colNum><meanCentred><colStandardized><SDPrec><"v4"> at end
// <variance data><average data> are only present if <colStandardized> and <meanCentred> are 'true'
var
  t1, t2 : int64 ;
  c1 : char ;
  s1, s2 : single ;
  d1, d2 : double ;
begin

	if (self <> nil) then
	begin

		t1 := (sizeof(int64)*4)+(2*sizeof(boolean))+ (sizeof(char)*2) ;

		// Can check that variance CMemoryStream is correct length for being complex - should not be a problem in template class version
		if ( (self.yCoord.complexMat=2) and ((self.yCoord.F_MVariance.Size = (self.yCoord.numRows * self.yCoord.numCols *self.yCoord.SDPrec) div 2))   ) then
		begin
		  self.yCoord.F_MVariance.Free();
		  self.yCoord.colStandardized := false ;
		end  ;
		if ( (self.yCoord.complexMat=2) and (self.yCoord.F_MAverage.Size = (self.yCoord.numRows * self.yCoord.numCols *self.yCoord.SDPrec div 2))   ) then
		begin
		  self.yCoord.F_MAverage.Free() ;
		  self.yCoord.meanCentred := false ;
		end  ;

		// Add the varince and average data to the end of the yCoord F_Mdata
    self.yCoord.F_Mdata.seek(0,soFromEnd) ;  // this is essential difference between C++ CSpectraRanges and Delphi TSpectraRanges
		self.yCoord.F_Mdata.CopyFrom( self.yCoord.F_MVariance, 0 ) ;  // ExtendFromStream always extends from start of streamIn
		self.yCoord.F_Mdata.CopyFrom(self.yCoord.F_MAverage, 0 ) ;
		self.yCoord.F_Mdata.CopyFrom(self.xCoord.F_Mdata, 0  ) ;   // the xcoord is never complex - not true in template style objects


		self.yCoord.F_Mdata.Seek(self.yCoord.F_Mdata.Size,soFromBeginning) ; // set to end of data
		self.yCoord.F_Mdata.SetSize(self.yCoord.F_Mdata.Size + t1) ;// extend data by t1 bytes
		// write new data to new data area
    t2 :=  self.yCoord.numRows ;
		self.yCoord.F_Mdata.Write(t2, sizeof(int64));
    t2 :=  self.yCoord.numCols ;
		self.yCoord.F_Mdata.Write(t2, sizeof(int64));
    // C/C++ has bool of 1 byte and Delphi has sizeof(boolean) = 1    (but sizeof(bool) = 4)
		self.yCoord.F_Mdata.Write(self.yCoord.meanCentred, sizeof(boolean));
		self.yCoord.F_Mdata.Write(self.yCoord.colStandardized, sizeof(boolean));
    t2 :=  self.yCoord.complexMat ;
		self.yCoord.F_Mdata.Write(t2, sizeof(int64));
    t2 :=  self.yCoord.SDPrec ;
		self.yCoord.F_Mdata.Write(t2, sizeof(int64));

		c1 := 'v';
		self.yCoord.F_Mdata.Write(&c1,sizeof(char)) ;
		c1 := '4' ;
		self.yCoord.F_Mdata.Write(&c1,sizeof(char)) ;

		// all the footer data has been added to the yCoord memory stream so save it to disk!
		self.yCoord.SaveMatrixDataRaw( filenameOutput ) ;

		// now chop off the footer of yCoord data as it is not really wanted
		t1 := t1 + self.xCoord.F_Mdata.Size  + self.yCoord.F_MVariance.Size  + self.yCoord.F_MAverage.Size ;
		self.yCoord.F_Mdata.SetSize(self.yCoord.F_Mdata.Size -  t1) ;
	end ;
end ;
{
procedure TSpectraRanges.SaveSpectraRangeDataBinV3( filenameOutput : String ) ;
// binary format :  <DATA><all X DATA><rowNum><colNum><meanCentred><colStandardized><SDPrec><'v3'> at end
var
  t1, t2 : integer ;
  c1 : char ;
  s1, s2 : single ;
  d1, d2 : double ;
begin

  t1 := (sizeof(integer)*3)+(2*sizeof(boolean))+ (sizeof(char)*2) ;

   self.yCoord.F_Mdata.SetSize(self.yCoord.F_Mdata.Size+ self.xCoord.F_Mdata.Size+ t1) ;
   self.yCoord.F_Mdata.Seek(-(t1 + self.xCoord.F_Mdata.Size),soFromEnd) ;
   self.xCoord.F_Mdata.Seek(0,soFromBeginning) ;
   if self.yCoord.SDPrec = 4 then
   begin
     for t2 := 0 to self.xCoord.numCols - 1 do
     begin
        self.xCoord.F_Mdata.Read(s1,4) ;
        self.yCoord.F_Mdata.Write(s1,sizeof(single)) ;
     end;
   end
   else
   if self.yCoord.SDPrec = 8 then
   begin
     for t2 := 0 to self.xCoord.numCols - 1 do
     begin
        self.xCoord.F_Mdata.Read(s1,4) ;
        self.yCoord.F_Mdata.Write(s1,sizeof(double)) ;
     end;
   end ;
   self.xCoord.F_Mdata.Seek(0,soFromBeginning) ;
   self.yCoord.F_Mdata.Write(self.yCoord.numRows, sizeof(integer));
   self.yCoord.F_Mdata.Write(self.yCoord.numCols, sizeof(integer));
   self.yCoord.F_Mdata.Write(self.yCoord.meanCentred, sizeof(boolean));
   self.yCoord.F_Mdata.Write(self.yCoord.colStandardized, sizeof(boolean));

   self.yCoord.F_Mdata.Write(self.yCoord.SDPrec, sizeof(integer));

   c1 := 'v' ;
   self.yCoord.F_Mdata.Write(c1,sizeof(char)) ;
   c1 := '3' ;
   self.yCoord.F_Mdata.Write(c1,sizeof(char)) ;
   self.yCoord.SaveMatrixDataRaw( filenameOutput ) ;

   self.yCoord.F_Mdata.SetSize(self.yCoord.F_Mdata.Size - self.xCoord.F_Mdata.Size - t1) ;

{
  // v3 code
  t1 := (sizeof(integer)*3)+(2*sizeof(boolean))+ (sizeof(char)*2) ;

   self.yCoord.F_Mdata.SetSize(self.yCoord.F_Mdata.Size+ self.xCoord.F_Mdata.Size+ t1) ;
   self.yCoord.F_Mdata.Seek(-(t1 + self.xCoord.F_Mdata.Size),soFromEnd) ;
   self.xCoord.F_Mdata.Seek(0,soFromBeginning) ;
   if self.yCoord.SDPrec = 4 then
   begin
     for t2 := 0 to self.xCoord.numCols - 1 do
     begin
        self.xCoord.F_Mdata.Read(s1,4) ;
        self.yCoord.F_Mdata.Write(s1,sizeof(single)) ;
     end;
   end
   else
   if self.yCoord.SDPrec = 8 then
   begin
     for t2 := 0 to self.xCoord.numCols - 1 do
     begin
        self.xCoord.F_Mdata.Read(s1,4) ;
        self.yCoord.F_Mdata.Write(s1,sizeof(double)) ;
     end;
   end ;
   self.xCoord.F_Mdata.Seek(0,soFromBeginning) ;
   self.yCoord.F_Mdata.Write(self.yCoord.numRows, sizeof(integer));
   self.yCoord.F_Mdata.Write(self.yCoord.numCols, sizeof(integer));
   self.yCoord.F_Mdata.Write(self.yCoord.meanCentred, sizeof(boolean));
   self.yCoord.F_Mdata.Write(self.yCoord.colStandardized, sizeof(boolean));

   self.yCoord.F_Mdata.Write(self.yCoord.SDPrec, sizeof(integer));

   c1 := 'v' ;
   self.yCoord.F_Mdata.Write(c1,sizeof(char)) ;
   c1 := '3' ;
   self.yCoord.F_Mdata.Write(c1,sizeof(char)) ;
   self.yCoord.SaveMatrixDataRaw( filenameOutput ) ;

   self.yCoord.F_Mdata.SetSize(self.yCoord.F_Mdata.Size - self.xCoord.F_Mdata.Size - t1) ;
end ;
      }

procedure TSpectraRanges.SaveSpectraRangeDataBinV2( filenameOutput : String ) ;
// binary format :  <DATA><rowNum><colNum><meanCentred><colStandardized><firstXCoord><lastXCoord><SDPrec><'v2'> at end
var
  t1 : integer ;
  c1 : char ;
  s1, s2 : single ;
  d1, d2 : double ;
begin
   if self.yCoord.SDPrec = 4 then
     t1 := (sizeof(integer)*3)+(2*sizeof(boolean))+ (sizeof(single)*2) + (sizeof(char)*2)
   else
   if self.yCoord.SDPrec = 8 then
     t1 := (sizeof(integer)*3)+(2*sizeof(boolean))+ (sizeof(double)*2) + (sizeof(char)*2)   ;

   self.yCoord.F_Mdata.SetSize(self.yCoord.F_Mdata.Size+ t1) ;
   self.yCoord.F_Mdata.Seek(-t1,soFromEnd) ;
   self.yCoord.F_Mdata.Write(self.yCoord.numRows, sizeof(integer));
   self.yCoord.F_Mdata.Write(self.yCoord.numCols, sizeof(integer));
   self.yCoord.F_Mdata.Write(self.yCoord.meanCentred, sizeof(boolean));
   self.yCoord.F_Mdata.Write(self.yCoord.colStandardized, sizeof(boolean));

   if self.yCoord.SDPrec = 4 then
   begin
     self.xCoord.F_Mdata.Seek(0,soFromBeginning) ;
     self.xCoord.F_Mdata.Read(s1,4) ;
     self.xCoord.F_Mdata.Seek(-4,soFromEnd) ;
     self.xCoord.F_Mdata.Read(s2,4) ;
     self.yCoord.F_Mdata.Write(s1,sizeof(single)) ;
     self.yCoord.F_Mdata.Write(s2,sizeof(single)) ;
   end
   else
   if self.yCoord.SDPrec = 8 then
   begin
     self.xCoord.F_Mdata.Seek(0,soFromBeginning) ;
     self.xCoord.F_Mdata.Read(d1,4) ;
     self.xCoord.F_Mdata.Seek(-4,soFromEnd) ;
     self.xCoord.F_Mdata.Read(d2,4) ;
     self.yCoord.F_Mdata.Write(d1,sizeof(double)) ;
     self.yCoord.F_Mdata.Write(d2,sizeof(double)) ;
   end ;

   self.yCoord.F_Mdata.Write(self.yCoord.SDPrec, sizeof(integer));

   c1 := 'v' ;
   self.yCoord.F_Mdata.Write(c1,sizeof(char)) ;
   c1 := '2' ;
   self.yCoord.F_Mdata.Write(c1,sizeof(char)) ;
   self.yCoord.SaveMatrixDataRaw( filenameOutput ) ;

   self.yCoord.F_Mdata.SetSize(self.yCoord.F_Mdata.Size - t1) ;
end ;



procedure TSpectraRanges.LoadRawData( filenameInput : String; numDataPoints, dataType : integer ) ;
// dataType : 1 = byte, 2 = 16 bit short, 3 = 32 bit float      (not used)
begin
   self.yCoord.LoadMatrixDataRawBinFile( filenameInput ) ;
end ;




procedure TSpectraRanges.LoadSpectraToTFileStreamBinV2( filenameInput : String ) ;
// binary format :  <DATA><rowNum><colNum><SDPrec><meanCentred><colStandardized><XHigh><XLow><'v2'> at end
// X data: interpolates between XHigh and XLow, colNum points
// Y data: reads in values directly from <DATA>
var
  t1 : integer ;
  c1_v, c1_2 : char ;
  s1, s2, s3 : single ;
  d1, d2, d3 : double ;
  space : double ;

begin
   srFileStrm := TFileStream.Create(filenameInput,fmOpenReadWrite) ;

   srFileStrm.Seek(-2,soFromEnd) ;
   srFileStrm.Read(c1_v,1) ;
   srFileStrm.Read(c1_2,1) ;

   if (c1_v = 'v') and (c1_2 = '2') then
   begin
     t1 := sizeof(integer) + (sizeof(char)*2)  ;  // to locate SDPrec value
     srFileStrm.Seek(-t1,soFromEnd) ;
     srFileStrm.Read(self.yCoord.SDPrec, sizeof(integer));

     if self.yCoord.SDPrec = 4 then
       t1 := (sizeof(integer)*3)+(2*sizeof(boolean))+ (sizeof(single)*2) + (sizeof(char)*2)   // size of <DATA><rowNum><colNum><meanCentred><colStandardized><XHigh><XLow><SDPrec><'v2'>
     else
     if self.yCoord.SDPrec = 8 then
       t1 := (sizeof(integer)*3)+(2*sizeof(boolean))+ (sizeof(double)*2) + (sizeof(char)*2) ;  // size of <DATA><rowNum><colNum><meanCentred><colStandardized><XHigh><XLow><SDPrec><'v2'>


     srFileStrm.Seek(-t1,soFromEnd) ;
     srFileStrm.Read(self.yCoord.numRows, sizeof(integer));
     srFileStrm.Read(self.yCoord.numCols, sizeof(integer));

     srFileStrm.Read(self.yCoord.meanCentred, sizeof(boolean));
     srFileStrm.Read(self.yCoord.colStandardized, sizeof(boolean));


      // set up xCoord TMatrix data
     self.xCoord.SDPrec  := self.yCoord.SDPrec ;
     self.xCoord.numRows := 1 ;
     self.xCoord.numCols := self.yCoord.numCols ;
     self.xCoord.F_Mdata.SetSize(self.xCoord.SDPrec* self.xCoord.numCols) ;
     self.xCoord.F_Mdata.Seek(0,soFromBeginning) ;

     if self.yCoord.SDPrec = 4 then
     begin
       srFileStrm.Read(s1,sizeof(single)) ;
       srFileStrm.Read(s2,sizeof(single)) ;
       if (self.yCoord.numCols-1) <> 0 then
         space := abs((s1 - s2)/ (self.yCoord.numCols-1))
       else
         space := 1 ;
       if s1 < s2 then
       begin
         for t1 := 0  to self.xCoord.numCols - 1 do
         begin
           d1 := s1 + (t1 * space) ;
           s3 := d1 ;
           self.xCoord.F_Mdata.Write(s3,4) ;
         end ;
       end
       else
       if s1 > s2 then
       begin
         for t1 := 0  to self.xCoord.numCols - 1 do
         begin
           d1 := s1 - (t1 * space) ;
           s3 := d1 ;
           self.xCoord.F_Mdata.Write(s3,4) ;
         end ;
       end ;
     end
     else
     if self.yCoord.SDPrec = 8 then
     begin
       srFileStrm.Read(d1,sizeof(double)) ;
       srFileStrm.Read(d2,sizeof(double)) ;
       space := abs((d1 - d2)/ (self.yCoord.numCols-1)) ;
       if d1 < d2 then
       begin
         for t1 := 0  to self.yCoord.numCols - 1 do
         begin
           d3 := d1 + (t1 * space) ;
           self.xCoord.F_Mdata.Write(d3,8) ;
         end ;
       end
       else
       if d1 > d2 then
       begin
         for t1 := 0  to self.yCoord.numCols - 1 do
         begin
           d3 := d1 - (t1 * space) ;
           self.xCoord.F_Mdata.Write(d3,8) ;
         end ;
       end ;
     end  ;
     // Create X data

     if self.yCoord.SDPrec = 4 then
       t1 := (sizeof(integer)*3)+(2*sizeof(boolean))+ (sizeof(single)*2) + (sizeof(char)*2)   // size of <DATA><rowNum><colNum><meanCentred><colStandardized><XHigh><XLow><SDPrec><'v2'>
     else
     if self.yCoord.SDPrec = 8 then
       t1 := (sizeof(integer)*3)+(2*sizeof(boolean))+ (sizeof(double)*2) + (sizeof(char)*2) ;  // size of <DATA><rowNum><colNum><meanCentred><colStandardized><XHigh><XLow><SDPrec><'v2'>

//     self.yCoord.F_Mdata.SetSize(self.yCoord.numCols*self.yCoord.numRows*self.yCoord.SDPrec) ;  // chop off end info data
     self.SeekFromBeginning(3,1,0) ;
     srFileStrm.Seek(0,soFromBeginning);
     //self.yCoord.F_Mdata.
//     tFileStrm.

   end
   else
   if  (c1_v <> 'v') then  // first binary file type -- assumed format : <DATA><rowNum><colNum><SDPrec><meanCentred><colStandardized>
   begin
      //self.yCoord.LoadMatrixDataFromBinFile( filenameInput ) ;  // xCoord data has to be calculated from 'import file' tab
      t1 := (sizeof(integer)*3)+(2*sizeof(boolean)) ;  // size of "numRows,numCols,SDPrec,meanCentred,colSandardized"
      //self.yCoord.F_Mdata.LoadFromFile(filenameIn) ;
      srFileStrm.Seek(-t1,soFromEnd) ;
      srFileStrm.Read(self.yCoord.numRows, sizeof(integer));
      srFileStrm.Read(self.yCoord.numCols, sizeof(integer));
      srFileStrm.Read(self.yCoord.SDPrec, sizeof(integer));
      srFileStrm.Read(self.yCoord.meanCentred, sizeof(boolean));
      srFileStrm.Read(self.yCoord.colStandardized, sizeof(boolean));
 //     tFileStrm.SetSize(self.yCoord.F_Mdata.Size- t1) ;
      self.xCoord.Filename := filenameInput ;
      self.SeekFromBeginning(3,1,0) ;
   end ;


end ;


procedure TSpectraRanges.AddBinFileEndingToTFileStrm(SDPrecIn : integer; numRowsIn, numColsIn : integer) ;
var
  t1 : integer ;
  c1 : char ;
  s1, s2 : single ;
  d1, d2 : double ;
  tMemStr : TMemoryStream ;
begin

   if srFileStrm = nil then
     exit ;
   
   tMemStr := TMemoryStream.Create ;

   if SDPrecIn = 4 then
     t1 := (sizeof(integer)*3)+(2*sizeof(boolean))+ (sizeof(single)*2) + (sizeof(char)*2)
   else
   if SDPrecIn = 8 then
     t1 := (sizeof(integer)*3)+(2*sizeof(boolean))+ (sizeof(double)*2) + (sizeof(char)*2)   ;

   tMemStr.SetSize(t1) ;
   tMemStr.Seek(0,soFromBeginning) ;
   tMemStr.Write(numRowsIn, sizeof(integer));
   tMemStr.Write(numColsIn, sizeof(integer));
   tMemStr.Write(self.yCoord.meanCentred , sizeof(boolean));
   tMemStr.Write(self.yCoord.colStandardized, sizeof(boolean));

   if SDPrecIn= 4 then
   begin
     self.xCoord.F_Mdata.Seek(0,soFromBeginning) ;
     self.xCoord.F_Mdata.Read(s1,4) ;
     self.xCoord.F_Mdata.Seek(-4,soFromEnd) ;
     self.xCoord.F_Mdata.Read(s2,4) ;
     tMemStr.Write(s1,sizeof(single)) ;
     tMemStr.Write(s2,sizeof(single)) ;
   end
   else
   if SDPrecIn = 8 then
   begin
     self.xCoord.F_Mdata.Seek(0,soFromBeginning) ;
     self.xCoord.F_Mdata.Read(d1,8) ;
     self.xCoord.F_Mdata.Seek(-8,soFromEnd) ;
     self.xCoord.F_Mdata.Read(d2,8) ;
     tMemStr.Write(d1,sizeof(double)) ;
     tMemStr.Write(d2,sizeof(double)) ;
   end ;

   tMemStr.Write(self.yCoord.SDPrec, sizeof(integer));

   c1 := 'v' ;
   tMemStr.Write(c1,sizeof(char)) ;
   c1 := '2' ;
   tMemStr.Write(c1,sizeof(char)) ;
   tMemStr.Seek(0,soFromBeginning) ;

   self.srFileStrm.CopyFrom(tMemStr,0) ;  // this places the data straight on disk. No need to save
   tMemStr.Free ;

end ;



procedure TSpectraRanges.LoadSpectraRangeDataBinV2( filenameInput : String ) ;
var
  t1, t2 : integer ;
  c1_v, c1_2 : char ;
  s1, s2, s3 : single ;
  d1, d2, d3 : double ;
  space : double ;
  i64 : int64 ;
begin
   self.yCoord.LoadMatrixDataRawBinFile( filenameInput ) ;
   self.yCoord.F_Mdata.Seek(-2,soFromEnd) ;
   self.yCoord.F_Mdata.Read(c1_v,1) ;
   self.yCoord.F_Mdata.Read(c1_2,1) ;

//   messagedlg('sizeof(boolean): ' + inttostr(sizeof(boolean)) ,mtError,[mbOK],0) ;
    if (c1_v = 'r') and (c1_2 = 'c') then   // x data is in file explicitly for each column
   begin
     t1 := (sizeof(int64)*2) + (sizeof(char)*2)  ;  // to locate complexMat and SDPrec value
     self.yCoord.F_Mdata.Seek(- t1,soFromEnd) ;
     self.yCoord.F_Mdata.Read(i64, sizeof(int64 ));
     self.yCoord.complexMat :=  i64 ;     // if == true then have to split F_Mdata into yImaginary
	   self.yCoord.F_Mdata.Read(i64, sizeof(int64 ));
     self.yCoord.SDPrec :=    i64 ;        // if SDPrec == 8 then F_Mdata is double precision

     // t1 = size of <DATA><variance><average><Xdata>  <rowNum64><colNum64><meanCentred><colStandardized><complexMat64><SDPrec64><'v4'>
     t1 := (sizeof(int64 )*4 )+(2*sizeof(char)) + (sizeof(char)*2)   ;      // was (sizeof(int64 )*4 )+(2*sizeof(bool)) + (sizeof(char)*2)   ;

     self.yCoord.F_Mdata.Seek(- t1,soFromEnd) ;
     self.yCoord.F_Mdata.Read(i64 , sizeof( int64));
     self.yCoord.numRows :=  i64 ;
     self.yCoord.F_Mdata.Read(i64, sizeof( int64));
     self.yCoord.numCols :=  i64 ;

     self.yCoord.F_Mdata.Read(self.yCoord.meanCentred, sizeof(char));
     self.yCoord.F_Mdata.Read(self.yCoord.colStandardized, sizeof(char));

      // set up xCoord TMatrix data
	 //  the xCoord can be complex
     self.xCoord.SDPrec  := self.yCoord.SDPrec ;
     self.xCoord.complexMat  := self.yCoord.complexMat ;
     self.xCoord.numRows := 1 ;
     self.xCoord.numCols := self.yCoord.numCols ;
     self.xCoord.F_Mdata.SetSize(self.xCoord.SDPrec * self.xCoord.numCols * self.xCoord.complexMat ) ;  // * self.yCoord.complexMat (the xCoord is never complex)
     self.xCoord.F_Mdata.Seek(0,soFromBeginning)  ;  //

     // Read xcoord data from the yCoord data that was read from disk file
	 // t1 = size of <DATA><variance><average>   <Xdata><rowNum><colNum><meanCentred><colStandardized><SDPrec><'v4'>
	 t1 := (self.yCoord.numCols * self.xCoord.SDPrec * self.xCoord.complexMat) + (sizeof(int64 )*4)+(2*sizeof(char)) + (sizeof(char)*2) ;   // * self.yCoord.complexMat (the xCoord is never complex)
	  // seek to strat of xdata
	 self.yCoord.F_Mdata.Seek(-t1,soFromEnd) ;
	 // Copy the xdata
	 self.xCoord.F_Mdata.CopyFrom(self.yCoord.F_Mdata,(self.xCoord.numCols *  self.xCoord.SDPrec *  self.xCoord.complexMat)) ;   // * self.yCoord.complexMat (the xCoord is never complex)
   if (self.yCoord.complexMat = 2) then
   begin
      self.xCoord.MakeUnComplex(nil);
   end;


	 if (self.yCoord.meanCentred) then
	 begin
		t1 := t1 + (self.yCoord.numCols * self.yCoord.SDPrec  * self.yCoord.complexMat) ;
		// seek to start of average data
		self.yCoord.F_Mdata.Seek(-t1,soFromEnd) ;
		// Copy the yCoord average data
		self.yCoord.F_MAverage.CopyFrom(self.yCoord.F_Mdata,(self.xCoord.numCols *  self.xCoord.SDPrec * self.yCoord.complexMat)) ;
	 end  ;
	 if (self.yCoord.colStandardized) then
	 begin
		t1 := t1 + (self.yCoord.numCols * self.yCoord.SDPrec * self.yCoord.complexMat) ;
		// seek to start of varience  data
		self.yCoord.F_Mdata.Seek(-t1,soFromEnd) ;
		// Copy the yCoord variance data
		self.yCoord.F_MVariance.CopyFrom(self.yCoord.F_Mdata,(self.xCoord.numCols *  self.xCoord.SDPrec * self.yCoord.complexMat)) ;
		// self.yCoord.Stddev( false ) ; this is done below after conversion to single prec.
	 end ;

   // this part is 'rc' specific
   // Get/convert the Y data offset value (predYdataYOffsetRegCoef) is placed directly past the matrix data
    t1 :=   self.yCoord.numRows * self.yCoord.numCols * self.yCoord.SDPrec  * self.yCoord.complexMat ;
    self.yCoord.F_Mdata.Seek(t1,soFromBeginning)  ;
    if self.yCoord.SDPrec = 8 then
    begin
         self.yCoord.F_Mdata.Read(d1,sizeof(double)) ;
         s1 := d1 ;
         predYdataYOffsetRegCoef[1] := s1 ;
         if self.yCoord.complexMat = 2 then
         begin
            self.yCoord.F_Mdata.Read(d1,sizeof(double)) ;
            s1 := d1 ;
            predYdataYOffsetRegCoef[2] := s1 ;
         end;
    end
    else
    if self.yCoord.SDPrec = 4 then
    begin
         self.yCoord.F_Mdata.Read(s1,sizeof(single)) ;
         predYdataYOffsetRegCoef[1] := s1 ;
         if self.yCoord.complexMat = 2 then
         begin
            self.yCoord.F_Mdata.Read(s1,sizeof(single)) ;
            predYdataYOffsetRegCoef[2] := s1 ;
         end;
    end;

     self.xCoord.F_Mdata.Seek(0,soFromBeginning)  ;
     self.yCoord.F_Mdata.Seek(0,soFromBeginning)  ;
	 // chop off end info data
     self.yCoord.F_Mdata.SetSize( t1) ;
     // split off imaginary part if dat is complex
     if self.yCoord.complexMat = 2 then
     begin
       if self.yImaginary = nil then
       begin
         self.yImaginary := TMatrix.Create2(self.yCoord.SDPrec,self.yCoord.numRows,self.yCoord.numCols) ;
       end ;
       self.yCoord.MakeUnComplex(self.yImaginary);
     end;
     self.SeekFromBeginning(3,1,0) ;

      // make into single precission if double
      // xCoord, yCoord and yImaginary
     if self.yCoord.SDPrec = 8 then
     begin
         self.yCoord.ConvertToSingle() ;
     end;
      if self.yImaginary <> nil then
      begin
        if self.yImaginary.SDPrec = 8 then
        begin
         self.yImaginary.ConvertToSingle() ;
        end;
      end;
     if self.xCoord.SDPrec = 8 then
     begin
         self.xCoord.ConvertToSingle() ;
     end;

     if (self.yCoord.colStandardized) then   // this has to be done here, after the conversion to single prec.
	   begin
	  	self.yCoord.Stddev( false ) ;
	   end ;


   end
   else
   if (c1_v = 'v') and (c1_2 = '4') then   // x data is in file explicitly for each column
   begin
     t1 := (sizeof(int64)*2) + (sizeof(char)*2)  ;  // to locate complexMat and SDPrec value
     self.yCoord.F_Mdata.Seek(- t1,soFromEnd) ;
     self.yCoord.F_Mdata.Read(i64, sizeof(int64 ));
     self.yCoord.complexMat :=  i64 ;     // if == true then have to split F_Mdata into yImaginary
	   self.yCoord.F_Mdata.Read(i64, sizeof(int64 ));
     self.yCoord.SDPrec :=    i64 ;        // if SDPrec == 8 then F_Mdata is double precision

     // t1 = size of <DATA><variance><average><Xdata>  <rowNum64><colNum64><meanCentred><colStandardized><complexMat64><SDPrec64><'v4'>
     t1 := (sizeof(int64 )*4 )+(2*sizeof(char)) + (sizeof(char)*2)   ;      // was (sizeof(int64 )*4 )+(2*sizeof(bool)) + (sizeof(char)*2)   ;

     self.yCoord.F_Mdata.Seek(- t1,soFromEnd) ;
     self.yCoord.F_Mdata.Read(i64 , sizeof( int64));
     self.yCoord.numRows :=  i64 ;
     self.yCoord.F_Mdata.Read(i64, sizeof( int64));
     self.yCoord.numCols :=  i64 ;

     self.yCoord.F_Mdata.Read(self.yCoord.meanCentred, sizeof(char));
     self.yCoord.F_Mdata.Read(self.yCoord.colStandardized, sizeof(char));

      // set up xCoord TMatrix data
	 //  the xCoord can be complex
     self.xCoord.SDPrec  := self.yCoord.SDPrec ;
     self.xCoord.complexMat  := self.yCoord.complexMat ;
     self.xCoord.numRows := 1 ;
     self.xCoord.numCols := self.yCoord.numCols ;
     self.xCoord.F_Mdata.SetSize(self.xCoord.SDPrec * self.xCoord.numCols * self.xCoord.complexMat ) ;  // * self.yCoord.complexMat (the xCoord is never complex)
     self.xCoord.F_Mdata.Seek(0,soFromBeginning)  ;  //

     // Read xcoord data from the yCoord data that was read from disk file
	 // t1 = size of <DATA><variance><average>   <Xdata><rowNum><colNum><meanCentred><colStandardized><SDPrec><'v4'>
	 t1 := (self.yCoord.numCols * self.xCoord.SDPrec * self.xCoord.complexMat) + (sizeof(int64 )*4)+(2*sizeof(char)) + (sizeof(char)*2) ;   // * self.yCoord.complexMat (the xCoord is never complex)
	  // seek to strat of xdata
	 self.yCoord.F_Mdata.Seek(-t1,soFromEnd) ;
	 // Copy the xdata
	 self.xCoord.F_Mdata.CopyFrom(self.yCoord.F_Mdata,(self.xCoord.numCols *  self.xCoord.SDPrec *  self.xCoord.complexMat)) ;   // * self.yCoord.complexMat (the xCoord is never complex)
   if (self.yCoord.complexMat = 2) then
   begin
      self.xCoord.MakeUnComplex(nil);
   end;


	 if (self.yCoord.meanCentred) then
	 begin
		t1 := t1 + (self.yCoord.numCols * self.yCoord.SDPrec  * self.yCoord.complexMat) ;
		// seek to start of average data
		self.yCoord.F_Mdata.Seek(-t1,soFromEnd) ;
		// Copy the yCoord average data
		self.yCoord.F_MAverage.CopyFrom(self.yCoord.F_Mdata,(self.xCoord.numCols *  self.xCoord.SDPrec * self.yCoord.complexMat)) ;
	 end  ;
	 if (self.yCoord.colStandardized) then
	 begin
		t1 := t1 + (self.yCoord.numCols * self.yCoord.SDPrec * self.yCoord.complexMat) ;
		// seek to start of varience  data
		self.yCoord.F_Mdata.Seek(-t1,soFromEnd) ;
		// Copy the yCoord variance data
		self.yCoord.F_MVariance.CopyFrom(self.yCoord.F_Mdata,(self.xCoord.numCols *  self.xCoord.SDPrec * self.yCoord.complexMat)) ;
		// self.yCoord.Stddev( false ) ; this is done below after conversion to single prec.
	 end ;

     self.xCoord.F_Mdata.Seek(0,soFromBeginning)  ;
	 // chop off end info data
     self.yCoord.F_Mdata.SetSize(self.yCoord.F_Mdata.Size - t1) ;
     // split off imaginary part if dat is complex
     if self.yCoord.complexMat = 2 then
     begin
       if self.yImaginary = nil then
       begin
         self.yImaginary := TMatrix.Create2(self.yCoord.SDPrec,self.yCoord.numRows,self.yCoord.numCols) ;
       end ;
       self.yCoord.MakeUnComplex(self.yImaginary);
     end;
     self.SeekFromBeginning(3,1,0) ;

      // make into single precission if double
      // xCoord, yCoord and yImaginary
     if self.yCoord.SDPrec = 8 then
     begin
         self.yCoord.ConvertToSingle() ;
     end;
      if self.yImaginary <> nil then
      begin
        if self.yImaginary.SDPrec = 8 then
        begin
         self.yImaginary.ConvertToSingle() ;
        end;
      end;
     if self.xCoord.SDPrec = 8 then
     begin
         self.xCoord.ConvertToSingle() ;
     end;

   if (self.yCoord.colStandardized) then   // this has to be done here, after the conversion to single prec.
	 begin
	  	self.yCoord.Stddev( false ) ;
	 end ;



   end
   else
   if (c1_v = 'v') and (c1_2 = '3') then   // x data is in file explicitly for each column
   begin
     t1 := sizeof(integer) + (sizeof(char)*2)  ;  // to locate SDPrec value
     self.yCoord.F_Mdata.Seek(-t1,soFromEnd) ;
     self.yCoord.F_Mdata.Read(self.yCoord.SDPrec, sizeof(integer));

     // t1 = size of <DATA><Xdata>  <rowNum><colNum><meanCentred><colStandardized><SDPrec><'v3'>
     t1 := (sizeof(integer)*3 )+(2*sizeof(boolean)) + (sizeof(char)*2)   ;

     self.yCoord.F_Mdata.Seek(-t1,soFromEnd) ;
     self.yCoord.F_Mdata.Read(self.yCoord.numRows, sizeof(integer));
     self.yCoord.F_Mdata.Read(self.yCoord.numCols, sizeof(integer));

     self.yCoord.F_Mdata.Read(self.yCoord.meanCentred, sizeof(boolean));
     self.yCoord.F_Mdata.Read(self.yCoord.colStandardized, sizeof(boolean));  // <SDPrec><'v2'>

      // t1 = size of <DATA>  <Xdata><rowNum><colNum><meanCentred><colStandardized><SDPrec><'v2'>
     t1 := (self.yCoord.numCols * self.yCoord.SDPrec) + (sizeof(integer)*3)+(2*sizeof(boolean)) + (sizeof(char)*2) ;
     self.yCoord.F_Mdata.Seek(-t1,soFromEnd) ;

      // set up xCoord TMatrix data
     self.xCoord.SDPrec  := self.yCoord.SDPrec ;
     self.xCoord.numRows := 1 ;
     self.xCoord.numCols := self.yCoord.numCols ;
     self.xCoord.F_Mdata.SetSize(self.xCoord.SDPrec* self.xCoord.numCols) ;
     self.xCoord.F_Mdata.Seek(0,soFromBeginning)  ;

     // read xcoord data from the yCoord data that was read from file
     if self.yCoord.SDPrec = 4 then
     begin
        for t2 := 0 to self.xCoord.numCols - 1 do
        begin
          self.yCoord.F_Mdata.Read(s1, 4) ;
          self.xCoord.F_Mdata.Write(s1,4) ;
        end;
     end
     else
     if self.yCoord.SDPrec = 8 then
     begin
        for t2 := 0 to self.xCoord.numCols - 1 do
        begin
          self.yCoord.F_Mdata.Read(d1, 8) ;
          self.xCoord.F_Mdata.Write(d1,8) ;
        end;
     end  ;
     // Create X data
      self.xCoord.F_Mdata.Seek(0,soFromBeginning)  ;

     t1 := (self.yCoord.numCols * self.yCoord.SDPrec) + (sizeof(integer)*3)+(2*sizeof(boolean)) + (sizeof(char)*2) ;

     self.yCoord.F_Mdata.SetSize(self.yCoord.F_Mdata.Size- t1) ;  // chop off end info data
     self.SeekFromBeginning(3,1,0) ;

   end
   else
   if (c1_v = 'v') and (c1_2 = '2') then  // binary format :  <DATA><rowNum><colNum><meanCentred><colStandardized><firstxCoord><lastxCoord><SDPrec><'v2'> at end
   begin
     t1 := sizeof(integer) + (sizeof(char)*2)  ;  // to locate SDPrec value
     self.yCoord.F_Mdata.Seek(-t1,soFromEnd) ;
     self.yCoord.F_Mdata.Read(self.yCoord.SDPrec, sizeof(integer));

     if self.yCoord.SDPrec = 4 then
       t1 := (sizeof(integer)*3)+(2*sizeof(boolean))+ (sizeof(single)*2) + (sizeof(char)*2)   // size of <DATA><rowNum><colNum><meanCentred><colStandardized><XHigh><XLow><SDPrec><'v2'>
     else
     if self.yCoord.SDPrec = 8 then
       t1 := (sizeof(integer)*3)+(2*sizeof(boolean))+ (sizeof(double)*2) + (sizeof(char)*2) ;  // size of <DATA><rowNum><colNum><meanCentred><colStandardized><XHigh><XLow><SDPrec><'v2'>


     self.yCoord.F_Mdata.Seek(-t1,soFromEnd) ;
     self.yCoord.F_Mdata.Read(self.yCoord.numRows, sizeof(integer));
     self.yCoord.F_Mdata.Read(self.yCoord.numCols, sizeof(integer));

     self.yCoord.F_Mdata.Read(self.yCoord.meanCentred, sizeof(boolean));
     self.yCoord.F_Mdata.Read(self.yCoord.colStandardized, sizeof(boolean));


      // set up xCoord TMatrix data
     self.xCoord.SDPrec  := self.yCoord.SDPrec ;
     self.xCoord.numRows := 1 ;
     self.xCoord.numCols := self.yCoord.numCols ;
     self.xCoord.F_Mdata.SetSize(self.xCoord.SDPrec* self.xCoord.numCols) ;
     self.xCoord.F_Mdata.Seek(0,soFromBeginning) ;

     if self.yCoord.SDPrec = 4 then
     begin
       self.yCoord.F_Mdata.Read(s1,sizeof(single)) ;
       self.yCoord.F_Mdata.Read(s2,sizeof(single)) ;
       if (self.yCoord.numCols-1) <> 0 then
         space := abs((s1 - s2)/ (self.yCoord.numCols-1))
       else
         space := 1 ;
       if s1 < s2 then
       begin
         for t1 := 0  to self.xCoord.numCols - 1 do
         begin
           d1 := s1 + (t1 * space) ;
           s3 := d1 ;
           self.xCoord.F_Mdata.Write(s3,4) ;
         end ;
       end
       else
       if s1 > s2 then
       begin
         for t1 := 0  to self.xCoord.numCols - 1 do
         begin
           d1 := s1 - (t1 * space) ;
           s3 := d1 ;
           self.xCoord.F_Mdata.Write(s3,4) ;
         end ;
       end ;
     end
     else
     if self.yCoord.SDPrec = 8 then
     begin
       self.yCoord.F_Mdata.Read(d1,sizeof(double)) ;
       self.yCoord.F_Mdata.Read(d2,sizeof(double)) ;
       space := abs((d1 - d2)/ (self.yCoord.numCols-1)) ;
       if d1 < d2 then
       begin
         for t1 := 0  to self.yCoord.numCols - 1 do
         begin
           d3 := d1 + (t1 * space) ;
           self.xCoord.F_Mdata.Write(d3,8) ;
         end ;
       end
       else
       if d1 > d2 then
       begin
         for t1 := 0  to self.yCoord.numCols - 1 do
         begin
           d3 := d1 - (t1 * space) ;
           self.xCoord.F_Mdata.Write(d3,8) ;
         end ;
       end ;
     end  ;
     // Create X data

     if self.yCoord.SDPrec = 4 then
       t1 := (sizeof(integer)*3)+(2*sizeof(boolean))+ (sizeof(single)*2) + (sizeof(char)*2)   // size of <DATA><rowNum><colNum><meanCentred><colStandardized><XHigh><XLow><SDPrec><'v2'>
     else
     if self.yCoord.SDPrec = 8 then
       t1 := (sizeof(integer)*3)+(2*sizeof(boolean))+ (sizeof(double)*2) + (sizeof(char)*2) ;  // size of <DATA><rowNum><colNum><meanCentred><colStandardized><XHigh><XLow><SDPrec><'v2'>

     self.yCoord.F_Mdata.SetSize(self.yCoord.F_Mdata.Size- t1) ;  // chop off end info data
     self.SeekFromBeginning(3,1,0) ;

   end
   else
   if  (c1_2 <> 'v') then  // first binary file type
   // assumed format : <DATA><rowNum><colNum><SDPrec><meanCentred><colStandardized><'v'>
   begin
      //self.yCoord.LoadMatrixDataFromBinFile( filenameInput ) ;  // xCoord data has to be calculated from 'import file' tab
      t1 := (sizeof(integer)*3)+(2*sizeof(boolean)) ;  // size of "numRows,numCols,SDPrec,meanCentred,colSandardized"
      //self.yCoord.F_Mdata.LoadFromFile(filenameIn) ;
      self.yCoord.F_Mdata.Seek(-t1,soFromEnd) ;
      self.yCoord.F_Mdata.Read(self.yCoord.numRows, sizeof(integer));
      self.yCoord.F_Mdata.Read(self.yCoord.numCols, sizeof(integer));
      self.yCoord.F_Mdata.Read(self.yCoord.SDPrec, sizeof(integer));
      self.yCoord.F_Mdata.Read(self.yCoord.meanCentred, sizeof(boolean));
      self.yCoord.F_Mdata.Read(self.yCoord.colStandardized, sizeof(boolean));
      self.yCoord.F_Mdata.SetSize(self.yCoord.F_Mdata.Size- t1) ;
      self.xCoord.Filename := filenameInput ;
      self.SeekFromBeginning(3,1,0) ;
   end ;


end ;




procedure TSpectraRanges.LoadSpectraRangeDataTIFF(Filename : String; dim1D_ifTrue : boolean);
begin



end;




procedure TSpectraRanges.SaveSpectraDelimited(filenameOutput : String; delim : String) ; // not excel friendly format (row major)
var
  t1, t2 : integer ;
  List1 : TStringList ;
  s1 : TGLRangeArray ;
  d1 : TGLRangeArrayD ;
  ts_x, ts_yr, ts_yi : string ;
begin
      if delim = ',' then
      begin
        filenameOutput := copy(filenameOutput,1,length(filenameOutput)-length(ExtractFileExt(filenameOutput))) ;
        filenameOutput := filenameOutput + '.csv' ;
      end
      else
      if (delim = #9) or (delim = ' ') then
      begin
        filenameOutput := copy(filenameOutput,1,length(filenameOutput)-length(ExtractFileExt(filenameOutput))) ;
        filenameOutput := filenameOutput + '.txt' ;
      end ;

      try
        List1 :=  TStringList.Create ;

        for t1 := 1 to self.yCoord.numRows  do // for each spectra
        begin

          SeekFromBeginning(3,t1,0) ;

          if (xCoord.SDPrec = 4) then
          begin
            for t2 := 1 to self.xCoord.numCols do   // for each variable
            begin
              if t1 = 1 then
              begin
                Read_XYrYi_Data(t2,t1,@s1,false) ;
                ts_x := ts_x + FloatToStrF(s1[0],ffGeneral,7,5) + delim  ; // x data
                ts_yr := ts_yr + FloatToStrF(s1[1],ffGeneral,7,5) + delim  ;
                if self.yImaginary <> nil then
                  ts_yi := ts_yi + FloatToStrF(s1[2],ffGeneral,7,5) + delim  ;
              end
              else
              begin
                Read_YrYi_Data(t2,t1,@s1,true) ;
                ts_yr := ts_yr + FloatToStrF(s1[0],ffGeneral,7,5) + delim  ;
                if self.yImaginary <> nil then
                  ts_yi := ts_yi + FloatToStrF(s1[1],ffGeneral,7,5) + delim  ;
              end ;
            end ;
          end
          else
          if (xCoord.SDPrec = 8) then
          begin
            for t2 := 1 to self.xCoord.numCols do   // for each variable
            begin
              if t1 = 1 then
              begin
                Read_XYrYi_Data(t2,t1,@d1,false) ;
                ts_x := ts_x + FloatToStrF(d1[0],ffGeneral,7,5) + delim  ; // x data
                ts_yr := ts_yr + FloatToStrF(d1[1],ffGeneral,7,5) + delim  ;
                if self.yImaginary <> nil then
                  ts_yi := ts_yi + FloatToStrF(d1[2],ffGeneral,7,5) + delim  ;
              end
              else
              begin
                Read_YrYi_Data(t2,t1,@d1,true) ;
                ts_yr := ts_yr + FloatToStrF(d1[0],ffGeneral,7,5) + delim  ;
                if self.yImaginary <> nil then
                  ts_yi := ts_yi + FloatToStrF(d1[1],ffGeneral,7,5) + delim  ;
              end ;
            end ;

          end ;


          if t1 = 1 then
            List1.Add(ts_x) ;
          List1.Add(ts_yr) ;
          if ts_yi <> '' then
            List1.Add(ts_yr) ;

          ts_x := '' ;
          ts_yr := '' ;
          ts_yi := '' ;
        end ;

        List1.SaveToFile(filenameOutput) ;
      finally
        List1.Free();
      end ;
end ;


procedure TSpectraRanges.AverageReduce(inputNumAves : integer;  rowOrCol: RowsOrCols) ;  // rows1orCols2 = 1 then average rows or rows1orCols2 = 2 = average cols
var
  tMat1 : TMatrix ;
begin

  if  rowOrCol = Rows then   // 2 = rows
  begin

    tMat1 := self.xCoord.AverageReduce(inputNumAves, rowOrCol) ;
    self.xCoord.CopyMatrix(tMat1) ;
    tMat1.Free ;

    tMat1 := self.yCoord.AverageReduce(inputNumAves, rowOrCol) ;
    self.yCoord.CopyMatrix(tMat1) ;
    tMat1.Free ;

  end
  else
  if  rowOrCol = Cols then   // 1 = columns
  begin
    tMat1 := self.yCoord.AverageReduce(inputNumAves, rowOrCol) ;
    self.yCoord.CopyMatrix(tMat1) ;
    tMat1.Free ;
  end ;

 // caption := 'Row ' + inttostr(SG1_ROW)+ ': '  + copy(stringGrid1.Cells[ SG1_COL , 0],1,length(stringGrid1.Cells[ SG1_COL , 0])-1) ; // + ExtractFilename(tSR1.xCoord.Filename) ;

  self.FillDataGrid(0, 0, '') ;

end ;


procedure TSpectraRanges.Reduce(inputNumAves : integer;  rowOrCol: RowsOrCols) ;  // rows1orCols2 = 1 then average rows or rows1orCols2 = 2 = average cols
var
  tMat1 : TMatrix ;
begin

  if  rowOrCol = Rows then   // 2 = rows
  begin

    tMat1 := self.xCoord.Reduce(inputNumAves, rowOrCol) ;
    self.xCoord.CopyMatrix(tMat1) ;
    tMat1.Free ;

    tMat1 := self.yCoord.Reduce(inputNumAves, rowOrCol) ;
    self.yCoord.CopyMatrix(tMat1) ;
    tMat1.Free ;

  end
  else
  if  rowOrCol = Cols then   // 1 = columns
  begin
    tMat1 := self.yCoord.Reduce(inputNumAves, rowOrCol) ;
    self.yCoord.CopyMatrix(tMat1) ;
    tMat1.Free ;
  end ;

 // caption := 'Row ' + inttostr(SG1_ROW)+ ': '  + copy(stringGrid1.Cells[ SG1_COL , 0],1,length(stringGrid1.Cells[ SG1_COL , 0])-1) ; // + ExtractFilename(tSR1.xCoord.Filename) ;

  self.FillDataGrid(0, 0, '') ;

end ;


procedure TSpectraRanges.FillDataGrid(SG1_ROW_in, SG1_COL_in: integer; caption : string) ;
var
  t1, t2 : integer ;
  p1 : pointer ;
begin
  if self.SGDataView <> nil then
  begin
    try
      GetMem(p1, self.xCoord.SDPrec) ; // get data storage for single or double data
      // StringGrid1.Objects[3,SG1_ROW] := SGDataView ; // Assign the new Form to the StringGrid1 object property (can now dispose of form if file is closed)
      // set size of string grid for view/modify/select of data array (yCoord)
      self.SGDataView.SG2.ColCount := self.yCoord.numCols + 2 ;
      self.SGDataView.SG2.RowCount := self.yCoord.numRows + 2 ;
      // create boolean flags of what row or column is selected
      self.SGDataView.flagsRow.SetSize(self.yCoord.numRows) ;
      self.SGDataView.flagsCol.SetSize(self.yCoord.numCols) ;

      self.SGDataView.SetAllFlagsRowCols(true, self.SGDataView.flagsRow) ;
      self.SGDataView.SetAllFlagsRowCols(true, self.SGDataView.flagsCol) ;
      self.SGDataView.RowStrTextTB.Text := '1-'+ inttostr(self.yCoord.numRows) ;  // set string text to correct range
      self.SGDataView.ColStrTextTB.Text := '1-'+ inttostr(self.yCoord.numCols) ;

      if caption <> '' then
      self.SGDataView.Caption :=     caption ;
      if  SG1_ROW_in <> 0 then
      self.SGDataView.ownersRow := SG1_ROW_in ;  // this is so the form can pass data back to the cell that points to it (in format: "rowrange:colrange" i.e. "1-30:20-1020")
      if  SG1_COL_in <> 0 then
      self.SGDataView.ownersCol := SG1_COL_in ;

      //*************** do stuff to place labels ****************//
      self.SeekFromBeginning(3,1,0) ;
      for t1 := 2 to self.SGDataView.SG2.ColCount do  // for first row
      begin
         // column labels in first row
         self.xCoord.F_Mdata.Read(p1^,self.xCoord.SDPrec) ;
         if self.xCoord.SDPrec = 4 then
           self.SGDataView.SG2.Cells[t1,0] :=  floattostrf(single(p1^),ffGeneral,5,3)
         else if self.xCoord.SDPrec = 8 then
           self.SGDataView.SG2.Cells[t1,0] :=  floattostrf(double(p1^),ffGeneral,5,3) ;
         // column numerical label in second row
         self.SGDataView.SG2.Cells[t1,1] :=  inttostr(t1-1) ;
      end ;
      self.SeekFromBeginning(3,1,0) ;
      // Row numeric labels are in second column
      for t1 := 2 to self.SGDataView.SG2.RowCount do
      begin
         self.SGDataView.SG2.Cells[1,t1] :=  inttostr(t1-1) ;
      end ;

      //*************** do stuff to place data in grid  ****************//
      for t1 := 2 to self.yCoord.numRows+1 do  // for each row (data rows)
      begin
        for t2 := 2 to self.yCoord.numCols+1 do  // for each column in the row (besides first)
        begin
           self.yCoord.F_Mdata.Read(p1^,self.yCoord.SDPrec) ;
           if self.yCoord.SDPrec = 4 then
             self.SGDataView.SG2.Cells[t2,t1] :=  floattostrf(single(p1^),ffGeneral,5,3)
           else if self.yCoord.SDPrec = 8 then
             self.SGDataView.SG2.Cells[t2,t1] :=  floattostrf(double(p1^),ffGeneral,5,3)
        end ;
      end ;

      self.SGDataView.SG2.Row := 0 ;
      self.SGDataView.SG2.Col := 0 ;

      if self.yCoord.numRows < 36 then
        self.SGDataView.Height :=  (((self.yCoord.numRows+2) * (self.SGDataView.SG2.DefaultRowHeight+1)) + 104)
      else
        self.SGDataView.Height :=  (((36+2) * (self.SGDataView.SG2.DefaultRowHeight+1)) + 104) ;

 //     self.SGDataView.Visible := true ; // view form with data and labels
 //     tSR1.SGDataView.SG2MouseDown(nil,mbLeft,[],1,1) ; // select top left cell (cell [1,1])

    finally
      FreeMem(p1) ;
    end ;
  end ;


end ;


end.
//*************************************************************************************//



