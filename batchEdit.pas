unit batchEdit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, OpenGL, Forms, Dialogs,
  StdCtrls, Menus, TVarAndCoVarOperations, TMatrixObject, TSpectraRangeObject, ExtCtrls,
  TBatch, TPCABatchObject, TIRPolAnalysisObject2, TBatchBasicFunctions, T2DCorrelObject,
  TAreaRatioUnit, TMathBatchUnit, TPLMAnalysisUnit1, TDichroicRatioUnit, TPLSPredictBatchUnit,
  TPCRPredictBatchUnit, TPLSYPredictTestBatchUnit, TAutoProjectEVectsUnit, TRotateFactorsUnit,
  TMatrixOperations, TRotateToFitScoresUnit, ShellAPI, TASMTimerUnit  ;
type
  TForm3 = class(TForm)
    BatchMemo1: TMemo;
    MainMenu1: TMainMenu;
    File1: TMenuItem;
    Sa1: TMenuItem;
    SaveAs1: TMenuItem;
    Open1: TMenuItem;
    CloseWindow1: TMenuItem;
    SetData1: TMenuItem;
    pcstofit1: TMenuItem;
    xvarrange1: TMenuItem;
    autoexclude1: TMenuItem;
    excludeiter1: TMenuItem;
    meancentre1: TMenuItem;
    columnstandardise1: TMenuItem;
    Panel1: TPanel;
    PCRun: TButton;
    Panel2: TPanel;
    normalisedepth1: TMenuItem;
    normalisedoutput1: TMenuItem;
    pixelspacing1: TMenuItem;
    bonetosurface1: TMenuItem;
    posornegativesection1: TMenuItem;
    posorneg1: TMenuItem;
    AnalysisTemplates1: TMenuItem;
    TemplateAreaRatio2: TMenuItem;
    TemplateExtractandSave2: TMenuItem;
    TemplatePCA2: TMenuItem;
    TemplatePCAReconstruct2: TMenuItem;
    TemplatePCR2: TMenuItem;
    TemplatePLS1: TMenuItem;
    TemplateIRpol2: TMenuItem;
    Template2Dcorrelation2: TMenuItem;
    TempltePLMangle1: TMenuItem;
    TemplateDichroicRatio1: TMenuItem;
    Clear1: TMenuItem;
    TemplatePLSPCRVerify1: TMenuItem;
    Templatemultiplyandsubtract1: TMenuItem;
    TemplateMatrixsubtract1: TMenuItem;
    TemplateMultiplyMatrices1: TMenuItem;
    TemplateVectoraddsubtract1: TMenuItem;
    TemplateAutoSubtractFator1: TMenuItem;
    TemplateRotate2Fators1: TMenuItem;
    TemplateVectormultiplydivide1: TMenuItem;
    TemplateRotateandfitScores1: TMenuItem;
    procedure BatchMemo1Change(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Open1Click(Sender: TObject);
    procedure Sa1Click(Sender: TObject);
    procedure SaveAs1Click(Sender: TObject);
    procedure CloseWindow1Click(Sender: TObject);
    procedure ResultsFile1Click(Sender: TObject);
    procedure OpenResults1Click(Sender: TObject);
    procedure pcstofit1Click(Sender: TObject);
    procedure xvarrange1Click(Sender: TObject);
    procedure autoexclude1Click(Sender: TObject);
    procedure excludeiter1Click(Sender: TObject);
    procedure meancentre1Click(Sender: TObject);
    procedure columnstandardise1Click(Sender: TObject);
    procedure Run1Click(Sender: TObject);
//    procedure TemplateExtractandSave1Click(Sender: TObject);
//    procedure TemplatePCA1Click(Sender: TObject);
//    procedure TemplatePCR1Click(Sender: TObject);
//    procedure TemplatePLS1Click(Sender: TObject);
//    procedure TemplateIRpol1Click(Sender: TObject);
    procedure normalisedepth1Click(Sender: TObject);
    procedure normalisedoutput1Click(Sender: TObject);
    procedure pixelspacing1Click(Sender: TObject);
    procedure bonetosurface1Click(Sender: TObject);
//    procedure TemplateInvert1Click(Sender: TObject);
 //   procedure Template2Dcorrelation1Click(Sender: TObject);
 //   procedure TemplateAreaRatio1Click(Sender: TObject);
    procedure posornegativesection1Click(Sender: TObject);
    procedure posorneg1Click(Sender: TObject);
    procedure TemplateAreaRatio2Click(Sender: TObject);
    procedure TemplatePCAReconstruct2Click(Sender: TObject);
    procedure Template2Dcorrelation2Click(Sender: TObject);
    procedure TemplateIRpol2Click(Sender: TObject);
    procedure TemplatePLS1Click(Sender: TObject);
    procedure TemplateInvert2Click(Sender: TObject);
    procedure TemplatePCR2Click(Sender: TObject);
    procedure TemplatePCA2Click(Sender: TObject);
    procedure TemplateExtractandSave2Click(Sender: TObject);
    procedure TemplateMaths1Click(Sender: TObject);
    procedure TempltePLMangle1Click(Sender: TObject);
    procedure TemplateDichroicRatio1Click(Sender: TObject);
    procedure Clear1Click(Sender: TObject);
    procedure TemplatePLSPCRVerify1Click(Sender: TObject);
    procedure Templatemultiplyandsubtract1Click(Sender: TObject);
    procedure TemplateMatrixsubtract1Click(Sender: TObject);
    procedure TemplateMultiplyMatrices1Click(Sender: TObject);
    procedure TemplateVectoraddsubtract1Click(Sender: TObject);
    procedure TemplateAutoSubtractFator1Click(Sender: TObject);
    procedure FormDragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    procedure BatchMemo1DragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    procedure FormActivate(Sender: TObject);
    procedure TemplateRotate2Fators1Click(Sender: TObject);
    procedure TemplateVectormultiplydivide1Click(Sender: TObject);
    procedure TemplateRotateandfitScores1Click(Sender: TObject);
 

  private
    { Private declarations }
  public

    resulsFile : string ;
    procedure wmDropFiles(var Msg: TWMDropFiles); message WM_DROPFILES;

    function ReturnLineColor(IntensityListIn : TStringList; numBlankLines : integer) : TGLLineColor ;  // numBlankLines is 1 if line not sdded to string grid yet or 2 if line added

    procedure CreateStringGridRowAndObjects2( correlObj          : T2DCorrelation   ) ;
    function  CreateStringGridRowAndObjects3                                           : TGLLineColor ;
    procedure CreateStringGridRowAndObjects4( objectForCellRow1  : TPLMAnalysis     ) ;
    function  CreateStringGridRowAndObjects5( objectForCellRow1  : TDichroicRatio   )  : TGLLineColor ;
    procedure CreateStringGridRowAndObjects6( objectForCellRow1  : TPLSYPredictBatch) ;
    procedure CreateStringGridRowAndObjects7( objectForCellRow1  : TPCRYPredictBatch) ;
    procedure CreateStringGridRowAndObjects8( objectForCellRow1  : TSpectraRanges   ) ;


    procedure RemoveRow( messasge : string ) ;   // remove row code if errr in creaing data
    function  SetupallXDataAs1D_or_2D(numImages : integer ; allXDataIn : TSpectraRanges ; tSr : TSpectraRanges) : boolean  ;
    function  SetupNativeMatrixAs1D_or_2D( scoresSpectra : TSpectraRanges ; tSr : TSpectraRanges) : boolean  ;   // a native 2D matrix is a single block of 2D intensity values (z axis (colour) values)

    procedure FreeStringGridSpectraRanges(col, row : integer );

    function AddOrSub(initialLineNum : integer; addorsubtract : integer) : integer ;
    // MultAndSub(): multiplies a data matrix by a vector to return the scores of the vectore on the data matrix and the residuals
    function MultAndSub(initialLineNum : integer) : integer ;  // returns the line number of the batch file
    // MatrixMultiply(): does a ordinary matrix multiplication between to matricies where the #cols of 1st = #row 2nd
    function MatrixMultiply(initialLineNum : integer) : integer ;  // returns the line number of the batch file
    // VectorAddOrSub(): Entry wise addition or subtraction of vector elements from each row of a matrix
    function VectorAddOrSub(initialLineNum : integer; addorsubtract : integer; vectorPrefactor : single) : integer ;  // returns the line number of the batch file
    // VectorMultiplyOrDivide(): Entrywise multiply or divide of vector elements with each row of a matrix
    function VectorMultiplyOrDivide(initialLineNum : integer; addorsubtract : integer; vectorPrefactor : single; y_row : string) : integer ;  // returns the line number of the batch file

    { Public declarations }
  end;

var
  Form3: TForm3;

implementation

Uses EmissionGL, FileInfo, ColorsEM, BatchFileDlg, AtlusBLASLAPACLibrary ;

{$R *.DFM}

procedure TForm3.BatchMemo1Change(Sender: TObject);
var
  t1 : integer ;
begin


  if  Form4.StringGrid1.Objects[2,Form4.StringGrid1.Selection.Top] is TSpectraRanges then
  begin
      TSpectraRanges(Form4.StringGrid1.Objects[2,Form4.StringGrid1.Selection.Top]).batchList.textModified := true ;
  end ;


end;

procedure TForm3.FormCreate(Sender: TObject);
begin
// textModified := false ;
end;

procedure TForm3.Open1Click(Sender: TObject);
begin

  if  Form4.StringGrid1.Objects[2,Form4.StringGrid1.Selection.Top] is TSpectraRanges then
  begin
    if TSpectraRanges(Form4.StringGrid1.Objects[2,Form4.StringGrid1.Selection.Top]).batchList.textModified then
    begin
      Case  messagedlg('File is modified, Save?' ,mtinformation,[mbOK, mbCancel],0) of
      idOK:
        begin
          SaveAs1Click(Sender) ;
          TSpectraRanges(Form4.StringGrid1.Objects[2,Form4.StringGrid1.Selection.Top]).batchList.textModified := false ;
        end ;
      end ;
    end ;
  end ;

  Form4.OpenDialog1.Filter := 'batch files (*.bat)|*.bat|text (*.csv, *.txt, *.asc *.bat)|*.txt;*.csv;*.asc;*.bat|all files (*.*)|*.*'    ;
  Form4.OpenDialog1.Title := 'Load batch file' ;
  Form4.OpenDialog1.DefaultExt := '*.bat' ;
  Form4.OpenDialog1.filename := '*.bat' ;

  With Form4.OpenDialog1 do
  begin
    If Execute Then
    begin
      TSpectraRanges(Form4.StringGrid1.Objects[2,Form4.StringGrid1.Selection.Top]).batchList.LoadFromFile(filename)  ;
      TSpectraRanges(Form4.StringGrid1.Objects[2,Form4.StringGrid1.Selection.Top]).batchList.filename :=  extractfilename(filename) ;
      Form3.BatchMemo1.Lines :=  TSpectraRanges(Form4.StringGrid1.Objects[2,Form4.StringGrid1.Selection.Top]).batchList ;
      filename :=  Form4.OpenDialog1.filename ;
      Form3.Caption := extractFileName(filename) ;
      TSpectraRanges(Form4.StringGrid1.Objects[2,Form4.StringGrid1.Selection.Top]).batchList.textModified := false ;
      //SetCurrentDir(ExtractFilePath(filename));
      Form4.SaveDialog1.InitialDir :=  ExtractFilePath(Form4.OpenDialog1.filename) ;
      Form4.OpenDialog1.InitialDir :=  ExtractFilePath(Form4.OpenDialog1.filename) ;
    end ;
  end ;

end;

procedure TForm3.Sa1Click(Sender: TObject);
begin
   if TSpectraRanges(Form4.StringGrid1.Objects[2,Form4.StringGrid1.Selection.Top]).batchList.textModified then
   begin
     TSpectraRanges(Form4.StringGrid1.Objects[2,Form4.StringGrid1.Selection.Top]).batchList.textModified := false ;
     BatchMemo1.Lines.SaveToFile(TSpectraRanges(Form4.StringGrid1.Objects[2,Form4.StringGrid1.Selection.Top]).batchList.filename) ;
   end ;
end;

procedure TForm3.SaveAs1Click(Sender: TObject);
begin
  Form4.SaveDialog1.Title := 'Save batch file' ;
  Form4.SaveDialog1.Filter := 'batch files (*.bat)| *.bat|text (*.csv, *.txt, *.asc *.bat)|*.txt;*.csv;*.asc;*.bat|all files (*.*)|*.*'     ;
  Form4.SaveDialog1.filename := TSpectraRanges(Form4.StringGrid1.Objects[2,Form4.StringGrid1.Selection.Top]).batchList.filename ;
  Form4.SaveDialog1.DefaultExt := '*.bat' ;

  If Form4.SaveDialog1.Execute Then
  begin
      BatchMemo1.Lines.SaveToFile(Form4.SaveDialog1.filename) ;
      TSpectraRanges(Form4.StringGrid1.Objects[2,Form4.StringGrid1.Selection.Top]).batchList.filename :=  extractfilename(Form4.SaveDialog1.filename) ;
      TSpectraRanges(Form4.StringGrid1.Objects[2,Form4.StringGrid1.Selection.Top]).batchList.textModified := false ;
      Form3.Caption := extractFileName(Form4.SaveDialog1.filename) ;
      //SetCurrentDir(ExtractFilePath(Form4.SaveDialog1.filename));
      Form4.SaveDialog1.InitialDir :=  ExtractFilePath(Form4.OpenDialog1.filename) ;
      Form4.OpenDialog1.InitialDir :=  ExtractFilePath(Form4.OpenDialog1.filename) ;
  end  ;
end;

procedure TForm3.CloseWindow1Click(Sender: TObject);
begin
  Form1.Visible := False ;
end;

procedure TForm3.ResultsFile1Click(Sender: TObject);
var
  tFilename : string ;
begin
  tFilename := TSpectraRanges(Form4.StringGrid1.Objects[2,Form4.StringGrid1.Selection.Top]).batchList.filename ;
  Form4.SaveDialog1.Filter := 'results files (*.res)|*.res|text (*.csv, *.txt, *.asc *.bat)|*.txt;*.csv;*.asc;*.bat|all files (*.*)|*.*'    ;
  Form4.SaveDialog1.Title := 'Batch results file' ;
  Form4.SaveDialog1.DefaultExt := '*.bat' ;
  Form4.SaveDialog1.filename := copy(tFilename,1, pos(ExtractFileExt(tFilename),tFilename)-1) ;  // remove the file extension
  If Form4.SaveDialog1.Execute Then
  begin
    if fileExists(Form4.SaveDialog1.filename + '.res') then
    begin
      Case  messagedlg('Results File: '+ extractFilename(Form4.SaveDialog1.filename)+ #13 +'already exists, overwrite?' ,mtinformation,[mbOK, mbCancel],0) of
      idOK:
         begin
           resulsFile :=  Form4.SaveDialog1.filename + '.res'
         end ;
      end ;
    end
    else
    begin
      resulsFile :=  Form4.SaveDialog1.filename + '.res'
    end ;
  end  ;
end;









procedure TForm3.OpenResults1Click(Sender: TObject);
begin
    if FileExists(resulsFile) then
    begin


    end ;
end;

procedure TForm3.pcstofit1Click(Sender: TObject);
begin
BatchFileModDlg.Label1.Caption := 'pcs to fit =' ;
BatchFileModDlg.Edit1.Text := '1-' ;
BatchFileModDlg.Visible := true ;

end;

procedure TForm3.xvarrange1Click(Sender: TObject);
begin
BatchFileModDlg.Label1.Caption := 'x var range =' ;
BatchFileModDlg.Edit1.Text := '' ;
BatchFileModDlg.Visible := true ;
end;

procedure TForm3.autoexclude1Click(Sender: TObject);
begin
BatchFileModDlg.Label1.Caption := 'autoexclude =' ;
BatchFileModDlg.Edit1.Text := '0.0' ;
BatchFileModDlg.Visible := true ;
end;

procedure TForm3.excludeiter1Click(Sender: TObject);
begin
BatchFileModDlg.Label1.Caption := 'exclude from pcs =' ;
BatchFileModDlg.Edit1.Text := '1' ;
BatchFileModDlg.Visible := true ;
end;

procedure TForm3.meancentre1Click(Sender: TObject);
begin
BatchFileModDlg.Label1.Caption := 'mean centre =' ;
BatchFileModDlg.Edit1.Text := 'true' ;
BatchFileModDlg.Visible := true ;
end;

procedure TForm3.columnstandardise1Click(Sender: TObject);
begin
BatchFileModDlg.Label1.Caption := 'column standardise =' ;
BatchFileModDlg.Edit1.Text := 'false' ;
BatchFileModDlg.Visible := true ;
end;

procedure TForm3.normalisedepth1Click(Sender: TObject);
begin
  BatchFileModDlg.Label1.Caption := 'normalise depth = ' ;
  BatchFileModDlg.Edit1.Text := 'true' ;
  BatchFileModDlg.Visible := true ;
end;


procedure TForm3.FreeStringGridSpectraRanges(col, row : integer );
begin
    if Form4.StringGrid1.Objects[col , row] is TSpectraRanges then
    begin
      ActivateRenderingContext(Form1.Canvas.Handle,RC);
        TSpectraRanges(Form4.StringGrid1.Objects[col , row]).ClearOpenGLData; // remove OpenGL compiled list
        glFlush ;
      wglMakeCurrent(0,0);
      TSpectraRanges(Form4.StringGrid1.Objects[col , row]).Free ;
      Form4.StringGrid1.Objects[ col ,  row] := nil ;
      Form4.StringGrid1.Cells[ col ,  row] := ''  ;
    end ;
end ;


{
'type = vector add or subtract') ;
'operation = add  // subtract') ;
'prefactor = 1.0  // scales vector data') ;
'// Input:   x data (vector or matrix) and y data (vector - same size)') ;
'// Output:  x.rows +/- (y*prefactor)') ;       }
function  TForm3.VectorAddOrSub(initialLineNum : integer; addorsubtract : integer; vectorPrefactor : single) : integer ;  // returns the line number of the batch file
// does not add a line to string grid... adds result to next cell to right
var
  xData, yData, resultData, vectorData : TSpectraRanges ;
  mo : TMatrixOps ;
  passOrFail : integer ; // return value from  AddVectToMatrixRows function
begin
    try
      result := initialLineNum + 1 ;


      xData      := TSpectraRanges(Form4.StringGrid1.Objects[2,Form4.StringGrid1.Row]) ;  // this is a matrix
      yData      := TSpectraRanges(Form4.StringGrid1.Objects[3,Form4.StringGrid1.Row]) ;  // this is a vector

      resultData := TSpectraRanges.Create(xData.yCoord.SDPrec div 4, xData.yCoord.numRows, xData.yCoord.numCols, @xData.LineColor) ;
      resultData.CopySpectraObject(xData) ;   // copy input data
      vectorData  := TSpectraRanges.Create(yData.yCoord.SDPrec div 4, yData.yCoord.numRows, yData.yCoord.numCols, @yData.LineColor) ;
      vectorData.CopySpectraObject(yData) ;   // copy input data

      if addorsubtract = 0 then addorsubtract := 1 ;

      vectorPrefactor := vectorPrefactor * addorsubtract ;

      if (vectorPrefactor <> 1.0) then
          vectorData.yCoord.MultiplyByScalar(vectorPrefactor) ;

      vectorData.yCoord.F_Mdata.Seek(0,soFromBeginning) ;
      if resultData.yCoord.AddVectToMatrixRows(vectorData.yCoord.F_Mdata) = 1 then
      begin

        if Form4.StringGrid1.Objects[4,Form4.StringGrid1.Row] <> nil then
          FreeStringGridSpectraRanges( 4,Form4.StringGrid1.Row ) ;

        Form4.StringGrid1.Objects[4,Form4.StringGrid1.Row] := resultData ;  // assign object to the cell
        resultData.GLListNumber := Form4.GetLowestListNumber ;                     // get openGL list number
        SetupallXDataAs1D_or_2D(1, resultData , xData) ;                           // create GL objects in 1D or 2D
        Form4.StringGrid1.Cells[4,Form4.StringGrid1.Row] := '1-'+ inttostr(xData.yCoord.numRows) +' : 1-' + inttostr(xData.yCoord.numCols) ;
        resultData.xString := xData.xString ;
        resultData.yString := xData.yString  ;
        if xData.fft.dt <> 0 then
          resultData.fft.CopyFFTObject(xData.fft) ;
      end  // do vector addition to each line of matrix
      else
      begin
         resultData.Free ;
         messagedlg('could not add the vector to each row of matrix. Perhaps vector is wrong size',mtError,[mbOK],0) ;
      end ;

      vectorData.Free ;
    except

    end ;
end ;



{
'type = vector multiply or divide') ;
'operation = divide  // multiply') ;
'prefactor = 1.0  // scales vector data') ;
'y row = y.1      // 1st row of y matrix is used as vector
'// Input:   x data (vector or matrix) and y data (vector - same size)') ;
'// Output:  x.rows +/- (y*prefactor)') ;
'// i.e. each column of each row of x is multiplied/divided
'// by corresponding column of y vector }
function  TForm3.VectorMultiplyOrDivide(initialLineNum : integer; addorsubtract : integer; vectorPrefactor : single; y_row : string) : integer ;  // returns the line number of the batch file
// does not add a line to string grid... adds result to next cell to right
// y_row string: allways has 'y.xxx' format, so need to remove first 'y.' part then convert to integer
var
  y_row_wanted : string ;
  xData, yData, resultData, vectorData : TSpectraRanges ;
  mo : TMatrixOps ;
  DivZeroError : integer ; // return value from  AddVectToMatrixRows function
begin
    try
      result := initialLineNum + 1 ;

      // determine which y row is wanted
      // y_row string: allways has 'y.xxx' format, so need to remove first 'y.' part then convert to integer
      y_row_wanted := trim(copy(y_row,3,length(y_row)-2)) ;


      xData      := TSpectraRanges(Form4.StringGrid1.Objects[2,Form4.StringGrid1.Row]) ;  // this is a matrix
      if xData = nil then exit ;
      yData      := TSpectraRanges(Form4.StringGrid1.Objects[3,Form4.StringGrid1.Row]) ;  // this is a vector
      if yData = nil then exit ;

      if xData.xCoord.numCols <>  yData.xCoord.numCols then
      begin
         messagedlg('Vector length mismatch. Could not divide/multiply vector to each row of matrix.',mtError,[mbOK],0) ;
         exit ;
      end ;

      resultData := TSpectraRanges.Create(xData.yCoord.SDPrec div 4, xData.yCoord.numRows, xData.yCoord.numCols, @xData.LineColor) ;
      resultData.CopySpectraObject(xData) ;   // copy input data
      vectorData  := TSpectraRanges.Create(yData.yCoord.SDPrec div 4, yData.yCoord.numRows, yData.yCoord.numCols, @yData.LineColor) ;
      vectorData.CopySpectraObject(yData) ;   // copy input data
      if  strtoint(y_row_wanted) > 1 then     // first row of Y data not wanted so get the row wanted
      begin
        vectorData.yCoord.ClearData(vectorData.yCoord.SDPrec div 4) ;
        vectorData.yCoord.FetchDataFromTMatrix(y_row_wanted,'1-'+inttostr(vectorData.yCoord.numCols),yData.yCoord) ;
      end ;

      if addorsubtract = 0 then addorsubtract := 1 ;

      if (vectorPrefactor <> 1.0) then
          vectorData.yCoord.MultiplyByScalar(vectorPrefactor) ; 

      vectorData.yCoord.F_Mdata.Seek(0,soFromBeginning) ;
      if addorSubtract = 1  then  // multiply
        resultData.yCoord.MultiplyMatrixByVect(vectorData.yCoord.F_Mdata)
      else
      if addorSubtract = -1  then  // divide
      begin
        DivZeroError := resultData.yCoord.DivideMatrixByVect (vectorData.yCoord.F_Mdata) ;   // returns 1 on EZeroDivide error, otherwise 0
        if DivZeroError = 1 then
          messagedlg('Y Vector contains a zero, cannot perform division',mtError,[mbOK],0) ;
      end ;

      if DivZeroError <> 1 then
      begin
        // create the new results data TSpectraRange OpenGl object and grid information for GUI
        if Form4.StringGrid1.Objects[4,Form4.StringGrid1.Row] <> nil then
          FreeStringGridSpectraRanges( 4,Form4.StringGrid1.Row ) ;
        Form4.StringGrid1.Objects[4,Form4.StringGrid1.Row] := resultData ;  // assign object to the cell
        resultData.GLListNumber := Form4.GetLowestListNumber ;                     // get openGL list number
        SetupallXDataAs1D_or_2D(1, resultData , xData) ;                           // create GL objects in 1D or 2D
        Form4.StringGrid1.Cells[4,Form4.StringGrid1.Row] := '1-'+ inttostr(xData.yCoord.numRows) +' : 1-' + inttostr(xData.yCoord.numCols) ;
        resultData.xString := xData.xString ;
        resultData.yString := xData.yString  ;
        if xData.fft.dt <> 0 then
          resultData.fft.CopyFFTObject(xData.fft) ;
      end
      else
      begin
        resultData.Free ;
      end ;


      vectorData.Free ;
    except

    end ;
end ;




//  '  type = add or subtract'
//  '  opperation = add  // subtract'
//  '// Input:   x data and y data (same size)'
//  '// Output:  x +/- y'
function  TForm3.AddOrSub(initialLineNum : integer; addorsubtract : integer) : integer ;   // returns the line number of the batch file
// does not add a line to string grid... ads result to next cell to right
var
  xData, yData, resultData : TSpectraRanges ;
  mo : TMatrixOps ;
begin
    try
      result := initialLineNum + 1 ;

      xData      := TSpectraRanges(Form4.StringGrid1.Objects[2,Form4.StringGrid1.Row]) ;
      yData      := TSpectraRanges(Form4.StringGrid1.Objects[3,Form4.StringGrid1.Row]) ;
      resultData := TSpectraRanges.Create(xData.yCoord.SDPrec div 4, xData.yCoord.numRows, xData.yCoord.numCols, @xData.LineColor) ;
      resultData.CopySpectraObject(xData) ;

      if addorsubtract = 0 then addorsubtract := 1 ;

      resultData.yCoord.AddOrSubtractMatrix(ydata.yCoord, addorsubtract) ;

      if Form4.StringGrid1.Objects[4,Form4.StringGrid1.Row] <> nil then
          FreeStringGridSpectraRanges( 4,Form4.StringGrid1.Row ) ;

      Form4.StringGrid1.Objects[4,Form4.StringGrid1.Row] := resultData ;  // assign object to the cell
      resultData.GLListNumber := Form4.GetLowestListNumber ;                     // get openGL list number
      SetupallXDataAs1D_or_2D(1, resultData , xData) ;                           // create GL objects in 1D or 2D
      Form4.StringGrid1.Cells[4,Form4.StringGrid1.Row] := '1-'+ inttostr(xData.yCoord.numRows) +' : 1-' + inttostr(xData.yCoord.numCols) ;
      resultData.xString := xData.xString ;
      resultData.yString := xData.yString  ;
      if xData.fft.dt <> 0 then
        resultData.fft.CopyFFTObject(xData.fft) ;
    except

    end ;
end ;



function  TForm3.MultAndSub(initialLineNum : integer) : integer ; // returns the line number of the batch file
// multiplies a data matrix by a vector to return the scores of the vectore on the data matrix and the residuals
var
  origX, copyX, tEVects, tEVectsCopy, tScores, tResiduals : TSpectraRanges ;
  mo : TMatrixOps ;
  MKLalpha : single ;
  MKLEVects, MKLscores, MKLdata : pointer ;
  MKLtint, MKLlda : integer ;
  tmat : TMatrix ;

  // for subtraction of offset.
  t1 : integer ;
  ave, s1 : single ;

begin
    try
      result := initialLineNum + 1 ;
      mo    := TMatrixOps.Create ;

      origX      := TSpectraRanges(Form4.StringGrid1.Objects[2,Form4.StringGrid1.Row]) ;
      tEVects    := TSpectraRanges(Form4.StringGrid1.Objects[3,Form4.StringGrid1.Row]) ;
      Form4.StringGrid1.Cells[1,Form4.StringGrid1.RowCount-1] :=  Form4.StringGrid1.Cells[1,Form4.StringGrid1.Row] ;

      copyX := TSpectraRanges.Create(origX.yCoord.SDPrec div 4, origX.yCoord.numRows, origX.yCoord.numCols, @origX.LineColor) ;
      copyX.CopySpectraObject(origX) ;
      copyX.GLListNumber := Form4.GetLowestListNumber ;

      CreateStringGridRowAndObjects8( copyX ) ;  // creates new string grid line and gets new spectra line colour
      SetupallXDataAs1D_or_2D(1, copyX , copyX) ;
      Form4.StringGrid1.Cells[2,Form4.StringGrid1.RowCount-2] := '1-'+ inttostr(copyX.yCoord.numRows) +' : 1-' + inttostr(copyX.yCoord.numCols) ;

      tEVectsCopy := TSpectraRanges.Create(origX.yCoord.SDPrec div 4, origX.yCoord.numRows, origX.yCoord.numCols, @origX.LineColor) ;
      tEVectsCopy.CopySpectraObject(tEVects) ;
      tEVectsCopy.GLListNumber := Form4.GetLowestListNumber ;


      // create scores by projection of EVects onto original data
      tScores := TSpectraRanges.Create(copyX.yCoord.SDPrec div 4, copyX.yCoord.numRows, 1, @copyX.LineColor) ;
      tScores.yCoord.Free ;
      tScores.yCoord := mo.MultiplyMatrixByMatrix(copyX.yCoord,tEVects.yCoord,false,true,1.0,false) ;


      // copy original data so we can subtract the scores x EVects
      tResiduals := TSpectraRanges.Create(copyX.yCoord.SDPrec div 4, copyX.yCoord.numRows, copyX.yCoord.numCols, @copyX.LineColor) ;
      tResiduals.CopySpectraObject(copyX) ;

      // use BLAS level 2 routine - subtract reconstructed data from original data
      MKLEVects   := tEVects.yCoord.F_Mdata.Memory ;
      MKLscores   := tScores.yCoord.F_Mdata.Memory ;
      MKLdata     := tResiduals.yCoord.F_Mdata.Memory ;
      MKLlda      := tResiduals.yCoord.numCols  ;
      MKLtint     :=  1 ;
      MKLalpha    := -1.0 ;
      // sger: a := alpha * x * y’ + a
      sger (copyX.yCoord.numCols , copyX.yCoord.numRows, MKLalpha, MKLEVects, MKLtint, MKLscores , MKLtint, MKLdata, MKLlda) ;

      mo.Free ;

      Form4.StringGrid1.Objects[3,Form4.StringGrid1.RowCount-2] := tEVectsCopy ;
      SetupallXDataAs1D_or_2D(1, tEVectsCopy , copyX) ;
      Form4.StringGrid1.Cells[3,Form4.StringGrid1.RowCount-2] := '1-'+ inttostr(tEVectsCopy.yCoord.numRows) +' : 1-' + inttostr(tEVectsCopy.yCoord.numCols) ;

      // tScores is the scores spectra
      tScores.Transpose ;

      Form4.StringGrid1.Objects[4,Form4.StringGrid1.RowCount-2] := tScores ;
      tScores.GLListNumber := Form4.GetLowestListNumber ;
      tScores.SetOpenGLXYRange(Form2.GetWhichLineToDisplay()) ;
      tScores.CreateGLList('1-',Form1.Canvas.Handle, RC, Form2.GetWhichLineToDisplay(),  1)   ;
      tScores.XHigh :=  tScores.XHigh * tScores.yCoord.numRows  ; // show all length of scores
      Form4.StringGrid1.Cells[4,Form4.StringGrid1.RowCount-2] := '1-'+ inttostr(tScores.yCoord.numRows) +' : 1-' + inttostr(tScores.yCoord.numCols) ;
      tScores.xString := 'Sample Number' ;
      tScores.yString := 'Score' ;

      // tResiduals is the 'residuals' matrix
      Form4.StringGrid1.Objects[5,Form4.StringGrid1.RowCount-2] := tResiduals ;
      tResiduals.GLListNumber := Form4.GetLowestListNumber ;
      if copyX.frequencyImage then
        tResiduals.frequencyImage := true ;
      SetupallXDataAs1D_or_2D(1, tResiduals , copyX) ;
      Form4.StringGrid1.Cells[5,Form4.StringGrid1.RowCount-2] := '1-'+ inttostr(tResiduals.yCoord.numRows) +' : 1-' + inttostr(tResiduals.yCoord.numCols) ;
      tResiduals.xString := copyX.xString ;
      tResiduals.yString := copyX.yString  ;
      if copyX.fft.dt <> 0 then
        tResiduals.fft.CopyFFTObject(copyX.fft) ;

    except
      mo.Free ;
    end ;
end ;




function  TForm3.MatrixMultiply(initialLineNum : integer) : integer ;
var
  m1, m2, tResult : TSpectraRanges ;
  mo : TMatrixOps ;
begin
    // this is a test code for compensation of other components present1
    try
      result := initialLineNum + 1 ;
      mo    := TMatrixOps.Create ;

      m1      := TSpectraRanges(Form4.StringGrid1.Objects[2,Form4.StringGrid1.Row]) ;
      m2      := TSpectraRanges(Form4.StringGrid1.Objects[3,Form4.StringGrid1.Row]) ;

      // create scores by projection of EVects onto original data
      tResult := TSpectraRanges.Create(m1.yCoord.SDPrec div 4, 1, m2.yCoord.numCols, @m1.LineColor) ;
      tResult.yCoord.Free ;
      tResult.yCoord := mo.MultiplyMatrixByMatrix(m1.yCoord,m2.yCoord,false,false,1.0,false) ;
      tResult.xCoord.CopyMatrix( m2.xCoord ) ;

      // add to column 3 (4) of TStringGrid
      Form4.StringGrid1.Objects[4,Form4.StringGrid1.Row] := tResult ;
      tResult.GLListNumber := Form4.GetLowestListNumber ;

      tResult.SetOpenGLXYRange(Form2.GetWhichLineToDisplay()) ;
      tResult.zHigh :=  0 ;
      tResult.zLow :=   0  ;
      if (tResult.lineType > MAXDISPLAYTYPEFORSPECTRA) or (tResult.lineType < 1)  then tResult.lineType := 1 ;  //
      tResult.CreateGLList('1-',Form1.Canvas.Handle, RC, Form2.GetWhichLineToDisplay(),  tResult.lineType )   ;
      Form4.StringGrid1.Cells[4,Form4.StringGrid1.Row] := '1-'+ inttostr(tResult.yCoord.numRows) +' : 1-' + inttostr(tResult.yCoord.numCols) ;
      tResult.xString := m2.xString ;
      tResult.yString := m1.yString  ;

    except
      mo.Free ;
    end ;
end ;





procedure TForm3.Run1Click(Sender: TObject);
var
   lineNum : integer ;
   lineNumStr : string ;
   t1, t2, iter : integer ;
   s1, s2 : single ;
//   tReg : TRegression ;
   tStrList : TStringList ;
   tstr1, tstr2, tFilename  : string ;
   // variables for batch processing
   resBool : boolean ;

   tIRPol : TIRPolAnalysis2 ;
   tPLM   : TPLMAnalysis ;
   tPCA   : TPCABatch ;
   tPLS   : TPLSYPredictBatch ;
   tPCR   : TPCRYPredictBatch ;
   tYPredict : TPLSYPredictTestBatch ;
   t2DCorrel : T2DCorrelation ;
   tPeakRatio :  TAreaRatio ;
   tDichroicRatioObj : TDichroicRatio ;
   tAutoProject : TAutoProjectEVects ;
   tRotateVect  : TRotateFactor3D ;
   tRotateFitScores  : TRotateToFitScores ;
 //  tPCRRes : TPCResults ;

   colArray : TGLLineColor ;
   tSR, tSR2, tSR3 : TSpectraRanges ;
   bB : TBatchBasics ;
   xRange : string ;

// For Regeneration Code
   PCStr : string ;
   meanCentreBool : boolean ;

   selectNextCellBool  : boolean ;
   AddOrSubtractOperation : integer ;
   VectorPrefactor : single ;
   initialLineNum, finalLineNum : integer ;

   tTimer : TASMTimer ;
begin
   try
     bB  := TBatchBasics.Create ;
     resBool := false ; // result of EVect data file from batch file entry 'data file'
     tTimer := TASMTimer.Create(0) ;

     tStrList := TStringList.Create ;
     tStrList.AddStrings( BatchMemo1.Lines ) ; // Copy what is in memo1 into a temporary text list

     lineNum := 0 ;
     lineNumStr := '' ;
     iter := 0 ;
     initialLineNum := 0;
     while lineNum <=  tStrList.Count-1 do   // Iterate through every line in the memo text
     begin
       inc(iter) ;  // used for code error messages
       tstr1 := bB.GetStringFromStrList(tStrList, lineNum) ;
       trim(tstr1) ;

       while tstr1 = '' do  // ignore empty strings
       begin
         inc(lineNum) ;
         if lineNum > tStrList.Count then exit ;
         tstr1 := tStrList.Strings[lineNum] ;
       end ;

       initialLineNum := lineNum ;

       if bB.LeftSideOfEqual(tstr1) = 'type' then
       begin
          if (bB.RightSideOfEqual(tstr1) = 'irpol') then
          begin // IR polarisation method - PCA + fit sine function
              tSR := TSpectraRanges(Form4.StringGrid1.Objects[2,Form4.StringGrid1.Row]) ;

              tIRPol := TIRPolAnalysis2.Create(tSR.xCoord.SDPrec div 4) ;   // this has to be freed on deletion of row or close of appliction
              lineNum := tIRPol.GetIRPolBatchArguments(lineNum, iter, tStrList) ;

              // ******** ALLWAYS CREATE NEW ROW IN STRING GRID  ********
              // GET CURRENT INTENSITY VALUE AND RED/GREEN/BLUE VALUE
              tIRPol.allXData.LineColor := ReturnLineColor(IntensityList, 1) ;
              tIRPol.allXData.GLListNumber := Form4.GetLowestListNumber ;

              // **** this rearranges original data in interleaved format to 'blocked' format  ****
              if not tIRPol.GetAllXData(tIRPol.interleaved, tSR ) then
              begin
                 tIRPol.Free ;
                 RemoveRow('Function TIRPolAnalysis2.GetAllXData() failed during data processing. Line number: '+inttostr(lineNum)) ;
                 exit ;
              end ;
              // **** do PCA of angle data at multiple positions - store results in tIRPol object ****
              colArray :=  TSpectraRanges(Form4.StringGrid1.Objects[2,Form4.StringGrid1.RowCount-2]).LineColor ;
             // tIRPol.ProcessIRPolData(  @colArray ) ;
              if  (tIRPol.ProcessIRPolData(  @colArray ) = false) then
              begin
                 tIRPol.Free ;
                 RemoveRow('Function tIRPol.ProcessIRPolData() failed during data processing. Line number: '+inttostr(lineNum)) ;
                 exit ;
              end ;

               // *** THESE ARE THE RESULTS  ***  Graph them and add to stringgrid1
              tIRPol.allXData.interleaved := 2 ;
               // create new line and objects in StringGrid using CreateStringGridRowAndObjects
              Form4.StringGrid1.RowCount := Form4.StringGrid1.RowCount + 1 ;  // add extra line to stringgrid1 ;
              Form4.StringGrid1.Objects[1,Form4.StringGrid1.RowCount-2]  :=  tIRPol ; // Create spectra object
              Form4.StringGrid1.Objects[2,Form4.StringGrid1.RowCount-2]  :=  tIRPol.allXData ;
              SetupallXDataAs1D_or_2D(tIRPol.numAngles, tIRPol.allXData , tSR) ;
              Form4.StringGrid1.Cells[2,Form4.StringGrid1.RowCount-2] := '1-'+ inttostr(tIRPol.allXData.yCoord.numRows) +' : 1-' + inttostr(tIRPol.allXData.yCoord.numCols) ;

              Form4.StringGrid1.Objects[5,Form4.StringGrid1.RowCount-2] := tIRPol.scoresSpectra ;
              tIRPol.scoresSpectra.GLListNumber := Form4.GetLowestListNumber ;
              tIRPol.scoresSpectra.SetOpenGLXYRange(Form2.GetWhichLineToDisplay()) ;
              tIRPol.scoresSpectra.CreateGLList('1-',Form1.Canvas.Handle, RC, Form2.GetWhichLineToDisplay(),  6)   ;
              tIRPol.scoresSpectra.XHigh :=  tIRPol.scoresSpectra.XHigh * tIRPol.scoresSpectra.yCoord.numRows  ; // show all length of scores
              Form4.StringGrid1.Cells[5,Form4.StringGrid1.RowCount-2] := '1-'+ inttostr(tIRPol.scoresSpectra.yCoord.numRows) +' : 1-' + inttostr(tIRPol.scoresSpectra.yCoord.numCols) ;
              tIRPol.scoresSpectra.xString := 'Sample Number' ;
              tIRPol.scoresSpectra.yString := 'Score' ;
   //           tIRPol.allXData.numImagesOrAngles      :=  tIRPol.numAngles ;
   //           tIRPol.scoresSpectra.numImagesOrAngles :=  tIRPol.numAngles ;

              Form4.StringGrid1.Objects[6,Form4.StringGrid1.RowCount-2] := tIRPol.eigenVSpectra ;
              tIRPol.eigenVSpectra.GLListNumber := Form4.GetLowestListNumber ;
              tIRPol.eigenVSpectra.SetOpenGLXYRange(Form2.GetWhichLineToDisplay());
              tIRPol.eigenVSpectra.CreateGLList('1-',Form1.Canvas.Handle, RC, Form2.GetWhichLineToDisplay(), 5)   ;
              Form4.StringGrid1.Cells[6,Form4.StringGrid1.RowCount-2] := '1-'+ inttostr(tIRPol.eigenVSpectra.yCoord.numRows) +' : 1-' + inttostr(tIRPol.eigenVSpectra.yCoord.numCols) ;
              tIRPol.eigenVSpectra.xString := tIRPol.allXData.xString ;
              tIRPol.eigenVSpectra.yString := tIRPol.allXData.yString  ;


              Form4.StringGrid1.Objects[9,Form4.StringGrid1.RowCount-2] := tIRPol.offsetPlot ;
              tIRPol.offsetPlot.GLListNumber := Form4.GetLowestListNumber ;
              tIRPol.offsetPlot.SeekFromBeginning(3,1,0) ;
              tIRPol.offsetPlot.SetOpenGLXYRange(Form2.GetWhichLineToDisplay());
             // tIRPol.integratedAbs.yCoord.AddScalar (- tIRPol.integratedAbs.yLow ) ;  // normalise data
              tIRPol.offsetPlot.yCoord.DivideByScalar( tIRPol.offsetPlot.yHigh -  tIRPol.offsetPlot.yLow ) ;
              tIRPol.offsetPlot.SetOpenGLXYRange(Form2.GetWhichLineToDisplay());
              if tIRPol.allXData.frequencyImage then
                tIRPol.offsetPlot.nativeImage := true ;
              SetupNativeMatrixAs1D_or_2D( tIRPol.offsetPlot, tSR ) ;
              Form4.StringGrid1.Cells[9,Form4.StringGrid1.RowCount-2] := '1-'+ inttostr(tIRPol.offsetPlot.yCoord.numRows) +' : 1-' + inttostr(tIRPol.offsetPlot.yCoord.numCols) ;
              tIRPol.offsetPlot.xString := 'Sample Position' ;
              tIRPol.offsetPlot.yString := '' ;


              Form4.StringGrid1.Objects[10,Form4.StringGrid1.RowCount-2] := tIRPol.anglePlot ;
              tIRPol.anglePlot.GLListNumber := Form4.GetLowestListNumber ;
              tIRPol.anglePlot.SetOpenGLXYRange(Form2.GetWhichLineToDisplay());
              if tIRPol.allXData.frequencyImage then
                tIRPol.anglePlot.nativeImage := true ;
              SetupNativeMatrixAs1D_or_2D( tIRPol.anglePlot, tSr ) ;
              Form4.StringGrid1.Cells[10,Form4.StringGrid1.RowCount-2] := '1-'+ inttostr(tIRPol.anglePlot.yCoord.numRows) +' : 1-' + inttostr(tIRPol.anglePlot.yCoord.numCols) ;
              tIRPol.anglePlot.xString := 'Sample Position' ;
              tIRPol.anglePlot.yString := 'Angle' ;

              Form4.StringGrid1.Objects[11,Form4.StringGrid1.RowCount-2] := tIRPol.rangePlot ;
              tIRPol.rangePlot.GLListNumber := Form4.GetLowestListNumber ;
              tIRPol.rangePlot.SetOpenGLXYRange(Form2.GetWhichLineToDisplay());
              if tIRPol.allXData.frequencyImage then
                tIRPol.rangePlot.nativeImage := true ;
              SetupNativeMatrixAs1D_or_2D( tIRPol.rangePlot, tSr ) ;
              Form4.StringGrid1.Cells[11,Form4.StringGrid1.RowCount-2] := '1-'+ inttostr(tIRPol.rangePlot.yCoord.numRows) +' : 1-' + inttostr(tIRPol.rangePlot.yCoord.numCols) ;
              tIRPol.rangePlot.xString := 'Sample Position' ;
              tIRPol.rangePlot.yString := '' ;

              Form4.StringGrid1.Objects[12,Form4.StringGrid1.RowCount-2] := tIRPol.RPlot ;    // RPlot is the 'Pearsons R' value for goodness of fit, max value = 1
              tIRPol.RPlot.GLListNumber := Form4.GetLowestListNumber ;
              tIRPol.RPlot.SetOpenGLXYRange(Form2.GetWhichLineToDisplay());
              if tIRPol.allXData.frequencyImage then
                tIRPol.RPlot.nativeImage := true ;
              SetupNativeMatrixAs1D_or_2D( tIRPol.RPlot, tSr ) ;
              Form4.StringGrid1.Cells[12,Form4.StringGrid1.RowCount-2] := '1-'+ inttostr(tIRPol.RPlot.yCoord.numRows) +' : 1-' + inttostr(tIRPol.RPlot.yCoord.numCols) ;
              tIRPol.RPlot.xString := 'Sample Position' ;
              tIRPol.RPlot.yString := 'R^2' ;

              TSpectraRanges(Form4.StringGrid1.Objects[2,Form4.StringGrid1.RowCount-2]).columnLabel  := 'X data'     ;   // PCR
              TSpectraRanges(Form4.StringGrid1.Objects[5,Form4.StringGrid1.RowCount-2]).columnLabel  := 'scores/pos'   ;
              TSpectraRanges(Form4.StringGrid1.Objects[6,Form4.StringGrid1.RowCount-2]).columnLabel  := 'EVects/pos:' ;    // plot of variance spanned by each PC
              TSpectraRanges(Form4.StringGrid1.Objects[9,Form4.StringGrid1.RowCount-2]).columnLabel  := 'offsets'   ;    // regression residual y data for each PC added. Good for outlier detection.
              TSpectraRanges(Form4.StringGrid1.Objects[10,Form4.StringGrid1.RowCount-2]).columnLabel := 'angle vs pos'    ;    // plot of measured vs predicted for set of PC's specified
              TSpectraRanges(Form4.StringGrid1.Objects[11,Form4.StringGrid1.RowCount-2]).columnLabel := 'range vs pos'     ;    // PCR specific
              TSpectraRanges(Form4.StringGrid1.Objects[12,Form4.StringGrid1.RowCount-2]).columnLabel := 'r vs pos' ;    // result of regression. Plot of Variables vs Absorbance for number of PC's specified




              Form4.StringGrid1.Cells[1,Form4.StringGrid1.RowCount-2] := ExtractFileName(tIRPol.allXData.XCoord.Filename) ;      // plot of measured vs predicted for number of PC's specified

              // add batch file text to created data
              tSR := TSpectraRanges(Form4.StringGrid1.Objects[2,Form4.StringGrid1.RowCount-2]) ;
              tSR.batchList.Add('// from line: '+inttostr(Form4.StringGrid1.Row)) ;
              for t1 :=  initialLineNum to lineNum-1 do
              begin
                 tSR.batchList.Add(bB.GetStringFromStrList(tStrList, t1)) ;
              end ;
          end
          else
          if (bB.RightSideOfEqual(tstr1) = 'plm stack') then
          begin // PLM fit sine^2(2 heta) to all pixels in a stack
              tSR := TSpectraRanges(Form4.StringGrid1.Objects[2,Form4.StringGrid1.Row]) ;

              tPLM := TPLMAnalysis.Create(tSR.xCoord.SDPrec div 4) ;   // this has to be freed on deletion of row or close of appliction
              lineNum := tPLM.GetPLMBatchArguments(lineNum, iter, tStrList) ;

              // ******** ALLWAYS CREATE NEW ROW IN STRING GRID  ********
              // create new line and objects in StringGrid using CreateStringGridRowAndObjects
              CreateStringGridRowAndObjects4( tPLM ) ;
              // **** this rearranges original data in interleaved format to 'blocked' format  ****
              if not tPLM.GetAllXData( tSR ) then
              begin
                 tPLM.Free ;
                 RemoveRow('Function TPLMAnalysis.GetAllXData() failed during data processing. Line number: '+inttostr(lineNum)) ;
                 exit ;
              end ;

              colArray :=  TSpectraRanges(Form4.StringGrid1.Objects[2,Form4.StringGrid1.RowCount-2]).LineColor ;

              if  (tPLM.ProcessPLMStackData(  @colArray ) = false) then
              begin
                 tPLM.Free ;
                 RemoveRow('Function tPLM.ProcessPLMStackData() failed during data processing. Line number: '+inttostr(lineNum)) ;
                 exit ;
              end ;

              tPLM.allXData.interleaved := 2 ;

              // *** THESE ARE THE RESULTS  ***  Graph them and add to stringgrid1
              SetupNativeMatrixAs1D_or_2D( tPLM.allXData, tSr ) ;
              Form4.StringGrid1.Cells[2,Form4.StringGrid1.RowCount-2] := '1-'+ inttostr(tPLM.allXData.yCoord.numRows) +' : 1-' + inttostr(tPLM.allXData.yCoord.numCols) ;

              Form4.StringGrid1.Objects[9,Form4.StringGrid1.RowCount-2] := tPLM.offsetPlot ;
              tPLM.offsetPlot.GLListNumber := Form4.GetLowestListNumber ;
              tPLM.offsetPlot.SetOpenGLXYRange(Form2.GetWhichLineToDisplay());
                tPLM.offsetPlot.nativeImage := true ;
              SetupNativeMatrixAs1D_or_2D( tPLM.offsetPlot, tSr ) ;
              Form4.StringGrid1.Cells[9,Form4.StringGrid1.RowCount-2] := '1-'+ inttostr(tPLM.offsetPlot.yCoord.numRows) +' : 1-' + inttostr(tPLM.offsetPlot.yCoord.numCols) ;
              tPLM.offsetPlot.xString := 'Sample Position' ;
              tPLM.offsetPlot.yString := 'Angle' ;

              Form4.StringGrid1.Objects[10,Form4.StringGrid1.RowCount-2] := tPLM.anglePlot ;
              tPLM.anglePlot.GLListNumber := Form4.GetLowestListNumber ;
              tPLM.anglePlot.SetOpenGLXYRange(Form2.GetWhichLineToDisplay());
                tPLM.anglePlot.nativeImage := true ;
              SetupNativeMatrixAs1D_or_2D( tPLM.anglePlot, tSr ) ;
              Form4.StringGrid1.Cells[10,Form4.StringGrid1.RowCount-2] := '1-'+ inttostr(tPLM.anglePlot.yCoord.numRows) +' : 1-' + inttostr(tPLM.anglePlot.yCoord.numCols) ;
              tPLM.anglePlot.xString := 'Sample Position' ;
              tPLM.anglePlot.yString := 'Angle' ;

              Form4.StringGrid1.Objects[11,Form4.StringGrid1.RowCount-2] := tPLM.rangePlot ;
              tPLM.rangePlot.GLListNumber := Form4.GetLowestListNumber ;
              tPLM.rangePlot.SetOpenGLXYRange(Form2.GetWhichLineToDisplay());
                tPLM.rangePlot.nativeImage := true ;
              SetupNativeMatrixAs1D_or_2D( tPLM.rangePlot, tSr ) ;
              Form4.StringGrid1.Cells[11,Form4.StringGrid1.RowCount-2] := '1-'+ inttostr(tPLM.rangePlot.yCoord.numRows) +' : 1-' + inttostr(tPLM.rangePlot.yCoord.numCols) ;
              tPLM.rangePlot.xString := 'Sample Position' ;
              tPLM.rangePlot.yString := 'Range' ;

              Form4.StringGrid1.Objects[12,Form4.StringGrid1.RowCount-2] := tPLM.RPlot ;    // RPlot is the 'Pearsons R' value for goodness of fit, max value = 1
              tPLM.RPlot.GLListNumber := Form4.GetLowestListNumber ;
              tPLM.RPlot.SetOpenGLXYRange(Form2.GetWhichLineToDisplay());
                tPLM.RPlot.nativeImage := true ;
              SetupNativeMatrixAs1D_or_2D( tPLM.RPlot, tSr ) ;
              Form4.StringGrid1.Cells[12,Form4.StringGrid1.RowCount-2] := '1-'+ inttostr(tPLM.RPlot.yCoord.numRows) +' : 1-' + inttostr(tPLM.RPlot.yCoord.numCols) ;
              tPLM.RPlot.xString := 'Sample Position' ;
              tPLM.RPlot.yString := 'Pearsons R' ;

              TSpectraRanges(Form4.StringGrid1.Objects[9,Form4.StringGrid1.RowCount-2]).columnLabel  := 'offset vs pos:'   ;    // regression residual y data for each PC added. Good for outlier detection.
              TSpectraRanges(Form4.StringGrid1.Objects[10,Form4.StringGrid1.RowCount-2]).columnLabel := 'angles vs pos:'    ;    // plot of measured vs predicted for set of PC's specified
              TSpectraRanges(Form4.StringGrid1.Objects[11,Form4.StringGrid1.RowCount-2]).columnLabel := 'range vs pos'     ;    // PCR specific
              TSpectraRanges(Form4.StringGrid1.Objects[12,Form4.StringGrid1.RowCount-2]).columnLabel := 'R vs pos' ;    // result of regression. Plot of Variables vs Absorbance for number of PC's specified

              Form4.StringGrid1.Cells[1,Form4.StringGrid1.RowCount-2] := ExtractFileName(tPLM.allXData.XCoord.Filename) ;      // plot of measured vs predicted for number of PC's specified

               // add batch file text to created data
              tSR := TSpectraRanges(Form4.StringGrid1.Objects[2,Form4.StringGrid1.RowCount-2]) ;
              for t1 :=  initialLineNum to lineNum -1 do
              begin
                 tSR.batchList.Add(bB.GetStringFromStrList(tStrList, t1)) ;
              end ;

              if tPLM.autosave = true then
              begin
                 tFilename := extractFilePath(tSR.xCoord.Filename) ;

                 if trim(tFilename) = '' then
                   tFilename := GetCurrentDir ;

                 if (copy(tFilename,length(tFilename),1) <> '\') then
                   tFilename := tFilename + '\' ;

                 tFilename :=  tFilename + copy(tPLM.resultsFileName,1,pos(extractfileext(tPLM.resultsfilename),tPLM.resultsFileName)-1) ;

                 tPLM.anglePlot.SaveSpectraRangeDataBinV2(tFilename + '_angles_n45_p45.bin' ) ;
                 tPLM.rangePlot.SaveSpectraRangeDataBinV2(tFilename + '_range_raw.bin' ) ;
                 tPLM.offsetPlot.SaveSpectraRangeDataBinV2(tFilename + '_offsets.bin' ) ;
                 tPLM.RPlot.SaveSpectraRangeDataBinV2(tFilename + '_rsqrd.bin' ) ;
              end ;

          end
          else
          if (bB.RightSideOfEqual(tstr1) = 'plm angle convert') then
          begin
             tSR  := TSpectraRanges(Form4.StringGrid1.Objects[2,Form4.StringGrid1.Row]) ;  // this is the angle data
             tSR2 := TSpectraRanges(Form4.StringGrid1.Objects[3,Form4.StringGrid1.Row]) ;  // this is subtracted images of (analyser minus a small angle) - (analyser plus a small angle) with Quater wave plate at 90 degrees to sample

             if  (tSR.yCoord.numRows <> tSR2.yCoord.numRows) and  (tSR.yCoord.numCols <> tSR2.yCoord.numCols) then
             begin
                messagedlg('The angle image and direction image are not the same dimensions, have to exit',mtError,[mbOK],0) ;
                exit ;
             end ;

             tSR2.yCoord.F_Mdata.Seek(0,soFromBeginning) ;
             tSR.yCoord.F_Mdata.Seek(0,soFromBeginning) ;
             for t1 := 1 to tSR.yCoord.numRows  do
             begin
               for t2 :=  1 to tSR.yCoord.numCols do
               begin
                   tSR.yCoord.F_Mdata.Read(s1,4) ;
                   tSR2.yCoord.F_Mdata.Read(s2,4) ;


                   if s2 <= 0 then
                   begin
                     if s1 < 0 then s1 := s1 + 180 ;
                   end
                   else
                   if s2 > 0 then
                   begin
                     s1 := s1 + 90 ;
                   end ;
                   // between 0 and 90   // just .* -1 then .+ 180
                  { if s1 > 90 then
                     s1 := 180 - s1 ;  }

                   tSR.yCoord.F_Mdata.Seek(-4,soFromCurrent) ;
                   tSR.yCoord.F_Mdata.Write(s1,4) ;
               end ;

             end ;
             SetupNativeMatrixAs1D_or_2D( tSR, tSR ) ;
             inc(lineNum) ;

          end
          else if (bB.RightSideOfEqual(tstr1) = 'area ratio') then
          begin
              tSR := TSpectraRanges(Form4.StringGrid1.Objects[2,Form4.StringGrid1.Row]) ;  // this is the selected row

              tPeakRatio := TAreaRatio.Create(tSR.xCoord.SDPrec div 4) ;   // this has to be freed on deletion of row or close of appliction
              lineNum := tPeakRatio.GetAreaRatioBatchArguments(lineNum, iter, tStrList) ;

              // ******** ALLWAYS CREATE NEW ROW IN STRING GRID  ********
              // create new line and objects in StringGrid using CreateStringGridRowAndObjects
              colArray := CreateStringGridRowAndObjects3 ;

              if  (tPeakRatio.ProcessAreaRatioData( tSR, @colArray ) = false) then
              begin
                 tPeakRatio.Free ;
                 RemoveRow('Function tPeakRatio.ProcessAreaRatioData() failed during data processing. Line number: '+inttostr(lineNum)) ;
                 exit ;
              end ;

              // copy the allXData results to a new TSpectraRange and  then delete the  TAreaRatio object
              tSR := TSpectraRanges.Create(tPeakRatio.allXData.xCoord.SDPrec div 4,tPeakRatio.allXData.yCoord.numRows,tPeakRatio.allXData.yCoord.numCols, @tPeakRatio.allXData.LineColor)  ; // Create spectra object

              tSR.CopySpectraObject(tPeakRatio.allXData) ; // this will copy the axes labels
              tSR.GLListNumber := Form4.GetLowestListNumber ;
              if TSpectraRanges(Form4.StringGrid1.Objects[2,Form4.StringGrid1.Row]).frequencyImage then
                tSR.nativeImage := true ;
              SetupNativeMatrixAs1D_or_2D( tSR, TSpectraRanges(Form4.StringGrid1.Objects[2,Form4.StringGrid1.Row])  ) ;

              tPeakRatio.Free ;

              Form4.StringGrid1.Objects[2,Form4.StringGrid1.RowCount-2]  :=  tSR ;
              tSR.xString := 'Sample Position' ;
              tSR.yString := 'Area Ratio' ;

              Form4.StringGrid1.Cells[2,Form4.StringGrid1.RowCount-2] := '1-'+ inttostr(tSR.yCoord.numRows) +' : 1-' + inttostr(tSR.yCoord.numCols) ;
              Form4.StringGrid1.Cells[1,Form4.StringGrid1.RowCount-2] := ExtractFileName(tSR.XCoord.Filename) ;

               // add batch file text to created data
              tSR := TSpectraRanges(Form4.StringGrid1.Objects[2,Form4.StringGrid1.RowCount-2]) ;
              tSR.batchList.Add('// from line: '+inttostr(Form4.StringGrid1.Row)) ;
              for t1 :=  initialLineNum to lineNum -1 do
              begin
                 tSR.batchList.Add(bB.GetStringFromStrList(tStrList, t1)) ;
              end ;
          end

          else if (bB.RightSideOfEqual(tstr1) = 'dichroic ratio') then
          begin
              tSR := TSpectraRanges(Form4.StringGrid1.Objects[2,Form4.StringGrid1.Row]) ;  // this is the selected row

              tDichroicRatioObj := TDichroicRatio.Create(tSR.xCoord.SDPrec div 4) ;   // this has to be freed on deletion of row or close of appliction
              lineNum := tDichroicRatioObj.GetDichroicRatioBatchArguments(lineNum, iter, tStrList) ;

              tDichroicRatioObj.GetAllXData(tSR) ;

              // ******** ALLWAYS CREATE NEW ROW IN STRING GRID  ********
              // create new line and objects in StringGrid using CreateStringGridRowAndObjects
              colArray := CreateStringGridRowAndObjects5( tDichroicRatioObj ) ;

              if  (tDichroicRatioObj.ProcessDichroicRatioData( tSR, @colArray ) = false) then
              begin
                 tDichroicRatioObj.Free ;
                 RemoveRow('Function ProcessDichroicRatioData() failed during data processing. Line number: '+inttostr(lineNum)) ;
                 exit ;
              end ;

              // *** THESE ARE THE RESULTS  ***  Add graph them and add to stringgrid1
              //  tDichroicRatioObj.allXData.interleaved := 1 ;
              SetupallXDataAs1D_or_2D(1, tDichroicRatioObj.allXData , tSR) ;
              Form4.StringGrid1.Cells[2,Form4.StringGrid1.RowCount-2] := tDichroicRatioObj.allXData.ReturnRowColRangeString ;
              if tSR.fft.dt <> 0 then
                    tDichroicRatioObj.allXData.fft.CopyFFTObject(tSR.fft) ;

              Form4.StringGrid1.Objects[5,Form4.StringGrid1.RowCount-2] := tDichroicRatioObj.ratioData ;

              tDichroicRatioObj.ratioData.GLListNumber := Form4.GetLowestListNumber ;
              if tSR.frequencyImage then
                tDichroicRatioObj.ratioData.frequencyImage := true ;
              SetupNativeMatrixAs1D_or_2D( tDichroicRatioObj.ratioData, tSr ) ;
              Form4.StringGrid1.Cells[5,Form4.StringGrid1.RowCount-2] := tDichroicRatioObj.ratioData.ReturnRowColRangeString ;
              tDichroicRatioObj.ratioData.xString := 'wavelength' ;
              tDichroicRatioObj.ratioData.yString := 'ratio' ;

               // add batch file text to created data
              tSR := TSpectraRanges(Form4.StringGrid1.Objects[2,Form4.StringGrid1.RowCount-2]) ;
              tSR.batchList.Add('// from line: '+inttostr(Form4.StringGrid1.Row)) ;
              for t1 :=  initialLineNum to lineNum -1  do
              begin
                 tSR.batchList.Add(bB.GetStringFromStrList(tStrList, t1)) ;
              end ;

          end

          else if (bB.RightSideOfEqual(tstr1) = 'math') then     //   type = MATH
          begin
             // define row for operations:
             //  ROW := R-2  or R+1
             //  Scalar Operations  + - * / ') ;
             //  C1 := C1  + 0.15           ') ;
             //  Per Spectra/Point Operations .+ .- .* ./ ') ;
             //  C1 := C1 ./ C2         // C2 is a scalar for each spectra (or point) in C1      ') ;
             //  Row/Col Operations + .- .* ') ;
             //  C1 := C1 + C2[1,1-1736]    ') ;
             //  Matrix Operations * = multiply .T = transpose, .inv = inverse, ') ;
             //  C3 := C1 * C2              ') ;
             //  Inbuilt functions ') ;
             //  C1 := C1.integrate(650-4000) .-  C1.baseline(1900-2400) // ') ;
             repeat
               inc(lineNum) ;
               tstr1 := bB.GetStringFromStrList(tStrList, lineNum) ;
             until (trim(tstr1) <> '') or (linenum > tStrList.Count)  ;

             while  (pos(':=',tstr1) > 0)  do
             begin




               repeat
                 inc(lineNum) ;
                 tstr1 := bB.GetStringFromStrList(tStrList, lineNum) ;
               until (trim(tstr1) <> '') or (linenum > tStrList.Count)  ;
             end ;

          end


          else if (bB.RightSideOfEqual(tstr1) = 'multiply and subtract') then     //   type = multiply and subtract
          begin
            lineNum :=  MultAndSub(lineNum) ; // function defined above
            repeat
                 inc(lineNum) ;
                 tstr1 := bB.GetStringFromStrList(tStrList, lineNum) ;
            until (trim(tstr1) <> '') or (linenum > tStrList.Count)  ;
          end
          else if (bB.RightSideOfEqual(tstr1) = 'matrix multiply') then     //   type = matrix multiply
          begin
            lineNum :=  MatrixMultiply(lineNum) ; // function defined above
            repeat
                 inc(lineNum) ;
                 tstr1 := bB.GetStringFromStrList(tStrList, lineNum) ;
            until (trim(tstr1) <> '') or (linenum > tStrList.Count)  ;
          end


          else if (bB.RightSideOfEqual(tstr1) = 'rotate factors') then     //      type = Rotate Factors
          begin


              tSR := TSpectraRanges(Form4.StringGrid1.Objects[2,Form4.StringGrid1.Row]) ;

              tRotateVect  := TRotateFactor3D.Create(tSR.xCoord.SDPrec div 4) ;// .Create(tSR.xCoord.SDPrec div 4) ;   // this has to be released on deletion of row or close of appliction

              lineNumStr := tRotateVect.GetBatchArguments(lineNum, iter, tStrList) ;
              if pos(',',lineNumStr) > 0 then
              begin
                 tRotateVect.Free ;
                 Form4.StatusBar1.Panels[1].Text :=  'Error in Batch File. Line number: ' + lineNumStr ;
                 exit ;
              end
              else
              lineNum := strtoint( lineNumStr ) ;

              // get reference factor to fit rotated data to (if needed)
              if tRotateVect.fitToFactorBool then
              begin
                // get the factor
                If Form4.StringGrid1.Objects[3 ,Form4.StringGrid1.Row] is  TSpectraRanges  then
                  tRotateVect.GetFactorToFitSpectra( TSpectraRanges(Form4.StringGrid1.Objects[3 ,Form4.StringGrid1.Row])  )
                else
                begin
                  tRotateVect.Free ;
                  Form4.StatusBar1.Panels[1].Text :=  'Factor to fit should be in column 3!' ;
                  exit ;
                end ;
                // fit the factor
                lineNumStr := tRotateVect.FitRotationBatchFile( tSR ) ;
              end
              else
              begin
                lineNumStr := tRotateVect.SurveyRotationBatchFile( tSR ) ;
                if  (lineNumStr <> '' ) then
                begin
                 tRotateVect.Free ;
                 Form4.StatusBar1.Panels[1].Text :=  'Function ProcessRotationBatchFile() failed during data processing. '+ inttostr(lineNum) ;
                 exit ;
                end ;
              end ;


              // add extra line to stringgrid1 ;
              Form4.StringGrid1.RowCount := Form4.StringGrid1.RowCount + 1 ;

              // add the object to the string grid
              Form4.StringGrid1.Objects[1,Form4.StringGrid1.RowCount-2] := tRotateVect ;

              // *** THESE ARE THE RESULTS  ***  Graph and add to stringgrid1
              colArray := ReturnLineColor(IntensityList, 2);
              tSR2 := TSpectraRanges.Create(tSR.yCoord.SDPrec div 4, 0,0, @colArray ) ;
              tSR2.CopySpectraObject(tSR) ;
              tSR2.yCoord.CopyMatrix(tRotateVect.originalVectors) ;
              Form4.StringGrid1.Objects[2,Form4.StringGrid1.RowCount-2] := tSR2 ;
              tSR2.GLListNumber := Form4.GetLowestListNumber ;
              SetupallXDataAs1D_or_2D(1, tSR2 , tSR) ;
              Form4.StringGrid1.Cells[2,Form4.StringGrid1.RowCount-2] := '1-'+ inttostr(tRotateVect.RotatedPC1.yCoord.numRows) +' : 1-' + inttostr(tRotateVect.RotatedPC1.yCoord.numCols) ;
              if tSR.fft.dt <> 0 then
                    tRotateVect.RotatedPC1.fft.CopyFFTObject(tSR.fft) ;

              Form4.StringGrid1.Objects[4,Form4.StringGrid1.RowCount-2] := tRotateVect.RotatedPC1;
              tRotateVect.RotatedPC1.GLListNumber := Form4.GetLowestListNumber ;
              tRotateVect.RotatedPC1.SetOpenGLXYRange(Form2.GetWhichLineToDisplay());
              tRotateVect.RotatedPC1.CreateGLList('1-',Form1.Canvas.Handle, RC, Form2.GetWhichLineToDisplay(), 1)   ;
              Form4.StringGrid1.Cells[4,Form4.StringGrid1.RowCount-2] := tRotateVect.RotatedPC1.ReturnRowColRangeString ;
              tRotateVect.RotatedPC1.xString := tSR2.xString ;
              tRotateVect.RotatedPC1.yString := tSR2.yString  ;
              if tSR.fft.dt <> 0 then
                    tRotateVect.RotatedPC1.fft.CopyFFTObject(tSR.fft) ;

              Form4.StringGrid1.Objects[5,Form4.StringGrid1.RowCount-2] := tRotateVect.RotatedPC2;
              tRotateVect.RotatedPC2.GLListNumber := Form4.GetLowestListNumber ;
              tRotateVect.RotatedPC2.SetOpenGLXYRange(Form2.GetWhichLineToDisplay());
              tRotateVect.RotatedPC2.CreateGLList('1-',Form1.Canvas.Handle, RC, Form2.GetWhichLineToDisplay(), 1)   ;
              Form4.StringGrid1.Cells[5,Form4.StringGrid1.RowCount-2] := tRotateVect.RotatedPC2.ReturnRowColRangeString ;
              tRotateVect.RotatedPC2.xString := tSR2.xString ;
              tRotateVect.RotatedPC2.yString := tSR2.yString  ;
              if tSR.fft.dt <> 0 then
                    tRotateVect.RotatedPC2.fft.CopyFFTObject(tSR.fft) ;

              Form4.StringGrid1.Objects[6,Form4.StringGrid1.RowCount-2] := tRotateVect.RotatedPC3;
              tRotateVect.RotatedPC3.GLListNumber := Form4.GetLowestListNumber ;
              tRotateVect.RotatedPC3.SetOpenGLXYRange(Form2.GetWhichLineToDisplay());
              tRotateVect.RotatedPC3.CreateGLList('1-',Form1.Canvas.Handle, RC, Form2.GetWhichLineToDisplay(), 1)   ;
              Form4.StringGrid1.Cells[6,Form4.StringGrid1.RowCount-2] := tRotateVect.RotatedPC3.ReturnRowColRangeString ;
              tRotateVect.RotatedPC3.xString := tSR2.xString ;
              tRotateVect.RotatedPC3.yString := tSR2.yString  ;
              if tSR.fft.dt <> 0 then
                    tRotateVect.RotatedPC3.fft.CopyFFTObject(tSR.fft) ;

              Form4.StringGrid1.Objects[7,Form4.StringGrid1.RowCount-2] := tRotateVect.combinedRotatedXYZ;
              tRotateVect.combinedRotatedXYZ.GLListNumber := Form4.GetLowestListNumber ;
              tRotateVect.combinedRotatedXYZ.SetOpenGLXYRange(Form2.GetWhichLineToDisplay());
              tRotateVect.combinedRotatedXYZ.CreateGLList('1-',Form1.Canvas.Handle, RC, Form2.GetWhichLineToDisplay(), 1)   ;
              Form4.StringGrid1.Cells[7,Form4.StringGrid1.RowCount-2] := tRotateVect.combinedRotatedXYZ.ReturnRowColRangeString ;
              tRotateVect.combinedRotatedXYZ.xString := tSR2.xString ;
              tRotateVect.combinedRotatedXYZ.yString := tSR2.yString  ;
              if tSR.fft.dt <> 0 then
                    tRotateVect.combinedRotatedXYZ.fft.CopyFFTObject(tSR.fft) ;

              if tRotateVect.fitToFactorBool then
                Form4.StringGrid1.Cells[8,Form4.StringGrid1.RowCount-2]  := floattostrf(tRotateVect.Angle_min,ffGeneral,7,6)        ;

        
              TSpectraRanges(Form4.StringGrid1.Objects[4,Form4.StringGrid1.RowCount-2]).columnLabel  := 'PCx'     ;
              TSpectraRanges(Form4.StringGrid1.Objects[5,Form4.StringGrid1.RowCount-2]).columnLabel  := 'PCy'   ;
              TSpectraRanges(Form4.StringGrid1.Objects[6,Form4.StringGrid1.RowCount-2]).columnLabel  := 'PCz' ;
              TSpectraRanges(Form4.StringGrid1.Objects[7,Form4.StringGrid1.RowCount-2]).columnLabel  := 'PCxyz'   ;



              Form4.StringGrid1.Cells[1,Form4.StringGrid1.RowCount-2] := ExtractFileName(tSR2.XCoord.Filename) ;
              tSR2 := nil ;

               // add batch file text to created data
              tSR := TSpectraRanges(Form4.StringGrid1.Objects[2,Form4.StringGrid1.RowCount-2]) ;
              tSR.batchList.Add('// from line: '+inttostr(Form4.StringGrid1.Row)) ;
              for t1 :=  initialLineNum to lineNum-1   do
              begin
                 tSR.batchList.Add(bB.GetStringFromStrList(tStrList, t1)) ;
              end ;


          end
          else if (bB.RightSideOfEqual(tstr1) = 'rotate factors to fit scores') then     //      type = Rotate Factors To Fit Scores
            begin

              If (Form4.StringGrid1.Objects[2 ,Form4.StringGrid1.Row] is  TSpectraRanges) and (Form4.StringGrid1.Objects[3 ,Form4.StringGrid1.Row] is  TSpectraRanges) and (Form4.StringGrid1.Objects[4 ,Form4.StringGrid1.Row] is  TSpectraRanges) then
              begin
                 tSR := TSpectraRanges(Form4.StringGrid1.Objects[2,Form4.StringGrid1.Row])  ;  // original data
                 tSR2 := TSpectraRanges(Form4.StringGrid1.Objects[3,Form4.StringGrid1.Row]) ;  // unrotated eigenvectors
                 tSR3 := TSpectraRanges(Form4.StringGrid1.Objects[4,Form4.StringGrid1.Row]) ;  // Scores to fit
              end
              else
                 exit ;


              tRotateFitScores  := TRotateToFitScores.Create(tSR.xCoord.SDPrec div 4) ;// .Create(tSR.xCoord.SDPrec div 4) ;   // this has to be released on deletion of row or close of appliction

              lineNumStr := tRotateFitScores.GetBatchArguments(lineNum, iter, tStrList) ;
              if pos(',',lineNumStr) > 0 then
              begin
                 tRotateFitScores.Free ;
                 Form4.StatusBar1.Panels[1].Text :=  'Error in Batch File. Line number: '+ lineNumStr ;
                 exit ;
              end
              else
              lineNum := strtoint( lineNumStr ) ;

              // get reference factor to fit rotated data to
              tRotateFitScores.GetAllDataSpectra(tSR, tSR2, tSR3)  ;  //
              // fit the factor
              lineNumStr := tRotateFitScores.FitRotationScoresBatchFile ;


              // ***************  set up string grid with data  **********************
              // add extra line to stringgrid1 ;
              Form4.StringGrid1.RowCount := Form4.StringGrid1.RowCount + 1 ;

              // add the object to the string grid
              Form4.StringGrid1.Objects[1,Form4.StringGrid1.RowCount -2] := tRotateFitScores ;
              // this will be the new spectra line color
              tRotateFitScores.AllXData.LineColor := ReturnLineColor(IntensityList, 2);


              // *** THESE ARE THE RESULTS  ***  Graph and add to stringgrid1
              tRotateFitScores.allXData.interleaved := 1 ;
              tRotateFitScores.allXData.GLListNumber := Form4.GetLowestListNumber ;
              Form4.StringGrid1.Objects[2,Form4.StringGrid1.RowCount-2] :=  tRotateFitScores.allXData ;
              SetupallXDataAs1D_or_2D(1, tRotateFitScores.allXData , tSR) ;
              Form4.StringGrid1.Cells[2,Form4.StringGrid1.RowCount-2] := tRotateFitScores.allXData.ReturnRowColRangeString ;
              if tSR.fft.dt <> 0 then
                    tPCR.allXData.fft.CopyFFTObject(tSR.fft) ;


              Form4.StringGrid1.Objects[3,Form4.StringGrid1.RowCount-2] :=  tRotateFitScores.origEVectSpectra ;
              tRotateFitScores.origEVectSpectra.SetTGLColourData( tRotateFitScores.AllXData.LineColor ) ;
              tRotateFitScores.origEVectSpectra.GLListNumber := Form4.GetLowestListNumber ;
              if tSR.frequencyImage then
                tRotateFitScores.origEVectSpectra.nativeImage := true ;
              SetupNativeMatrixAs1D_or_2D( tRotateFitScores.origEVectSpectra, tSR ) ;
  //            tRotateFitScores.origEVectSpectra.CreateGLList('1-',Form1.Canvas.Handle, RC, Form2.GetWhichLineToDisplay(), 1)   ;
              Form4.StringGrid1.Cells[3,Form4.StringGrid1.RowCount-2] := tRotateFitScores.origEVectSpectra.ReturnRowColRangeString ;
              if tSR.fft.dt <> 0 then
                    tRotateFitScores.origEVectSpectra.fft.CopyFFTObject(tSR.fft) ;


              Form4.StringGrid1.Objects[4,Form4.StringGrid1.RowCount-2] :=  tRotateFitScores.scoresNew ;
              tRotateFitScores.scoresNew.SetTGLColourData( tRotateFitScores.AllXData.LineColor ) ;
              tRotateFitScores.scoresNew.GLListNumber := Form4.GetLowestListNumber ;
              if tSR.frequencyImage then
                tRotateFitScores.scoresNew .nativeImage := true ;
              SetupNativeMatrixAs1D_or_2D( tRotateFitScores.scoresNew, tSR ) ;
//              tRotateFitScores.scoresNew.CreateGLList('1-',Form1.Canvas.Handle, RC, Form2.GetWhichLineToDisplay(), 1)   ;
              Form4.StringGrid1.Cells[4,Form4.StringGrid1.RowCount-2] := tRotateFitScores.scoresNew.ReturnRowColRangeString ;
              if tSR.fft.dt <> 0 then
                    tRotateFitScores.scoresNew.fft.CopyFFTObject(tSR.fft) ;

              Form4.StringGrid1.Objects[5,Form4.StringGrid1.RowCount-2] :=  tRotateFitScores.rotatedVectSpectra ;
              tRotateFitScores.rotatedVectSpectra.SetTGLColourData( tRotateFitScores.AllXData.LineColor ) ;
              tRotateFitScores.rotatedVectSpectra.GLListNumber := Form4.GetLowestListNumber ;
              if tSR.frequencyImage then
                tRotateFitScores.rotatedVectSpectra.nativeImage := true ;
              SetupNativeMatrixAs1D_or_2D( tRotateFitScores.rotatedVectSpectra, tSR ) ;
//              tRotateFitScores.rotatedVectSpectra.CreateGLList('1-',Form1.Canvas.Handle, RC, Form2.GetWhichLineToDisplay(), 1)   ;
              Form4.StringGrid1.Cells[5,Form4.StringGrid1.RowCount-2] := tRotateFitScores.rotatedVectSpectra.ReturnRowColRangeString ;
              if tSR.fft.dt <> 0 then
                    tRotateFitScores.rotatedVectSpectra.fft.CopyFFTObject(tSR.fft) ;


              Form4.StringGrid1.Objects[7,Form4.StringGrid1.RowCount-2] :=  tRotateFitScores.ResidualXData ;
              tRotateFitScores.ResidualXData.SetTGLColourData( tRotateFitScores.AllXData.LineColor ) ;
              tRotateFitScores.ResidualXData.GLListNumber := Form4.GetLowestListNumber ;
              if tSR.frequencyImage then
                tRotateFitScores.ResidualXData.nativeImage := true ;
              SetupNativeMatrixAs1D_or_2D( tRotateFitScores.ResidualXData, tSr ) ;
//              tRotateFitScores.ResidualXData.CreateGLList('1-',Form1.Canvas.Handle, RC, Form2.GetWhichLineToDisplay(), 1)   ;
              Form4.StringGrid1.Cells[7,Form4.StringGrid1.RowCount-2] := tRotateFitScores.ResidualXData.ReturnRowColRangeString ;
              if tSR.fft.dt <> 0 then
                    tRotateFitScores.ResidualXData.fft.CopyFFTObject(tSR.fft) ;

               Form4.StringGrid1.Cells[8,Form4.StringGrid1.RowCount-2] :=  floattoStrF(tRotateFitScores.Angle_min,ffGeneral,7,5) ;

              TSpectraRanges(Form4.StringGrid1.Objects[2,Form4.StringGrid1.RowCount-2]).columnLabel  := 'X data'     ;   // PCR
              TSpectraRanges(Form4.StringGrid1.Objects[3,Form4.StringGrid1.RowCount-2]).columnLabel  := 'orig EVect'   ;
              TSpectraRanges(Form4.StringGrid1.Objects[4,Form4.StringGrid1.RowCount-2]).columnLabel  := 'scores'     ;   // PCR
              TSpectraRanges(Form4.StringGrid1.Objects[5,Form4.StringGrid1.RowCount-2]).columnLabel  := 'rot. Vect'   ;
              TSpectraRanges(Form4.StringGrid1.Objects[7,Form4.StringGrid1.RowCount-2]).columnLabel  := 'x resid.'   ;    // residual data left after subtraction of desired PC range of eigenvectors.

              Form4.StringGrid1.Cells[1,Form4.StringGrid1.RowCount-2] := ExtractFileName(tSR2.XCoord.Filename) ;
              tSR  := nil ;
              tSR2 := nil ;
              tSR3 := nil ;
              
               // add batch file text to created data
              tSR := TSpectraRanges(Form4.StringGrid1.Objects[2,Form4.StringGrid1.RowCount-2]) ;
              tSR.batchList.Add('// from line: '+inttostr(Form4.StringGrid1.Row)) ;
              for t1 :=  initialLineNum to lineNum-1   do
              begin
                 tSR.batchList.Add(bB.GetStringFromStrList(tStrList, t1)) ;
              end ;


          end
          else if (bB.RightSideOfEqual(tstr1) = 'add or subtract') then     //   type = add or subtract
          begin
            repeat
                 inc(lineNum) ;
                 tstr1 := bB.GetStringFromStrList(tStrList, lineNum) ;
            until (trim(tstr1) <> '') or (linenum > tStrList.Count)  ;
            if bB.LeftSideOfEqual(tstr1) = 'operation' then
              if bB.RightSideOfEqual(tstr1) = 'add' then
                AddOrSubtractOperation := 1
              else
                AddOrSubtractOperation := -1 ; //  = +1 or -1

            lineNum :=  AddOrSub(lineNum, AddOrSubtractOperation) ;

            repeat
                 inc(lineNum) ;
                 tstr1 := bB.GetStringFromStrList(tStrList, lineNum) ;
            until (trim(tstr1) <> '') or (linenum > tStrList.Count)  ;
          end
          else if (bB.RightSideOfEqual(tstr1) = 'vector add or subtract') then     //   type = vector add or subtract
          begin
            repeat
                 inc(lineNum) ;
                 tstr1 := bB.GetStringFromStrList(tStrList, lineNum) ;
            until (trim(tstr1) <> '') or (linenum > tStrList.Count)  ;
            if bB.LeftSideOfEqual(tstr1) = 'operation' then
              if bB.RightSideOfEqual(tstr1) = 'add' then
                AddOrSubtractOperation := 1
              else
                AddOrSubtractOperation := -1 ; //  = +1 or -1
            repeat
                 inc(lineNum) ;
                 tstr1 := bB.GetStringFromStrList(tStrList, lineNum) ;
            until (trim(tstr1) <> '') or (linenum > tStrList.Count)  ;
            if bB.LeftSideOfEqual(tstr1) = 'prefactor' then
                vectorPrefactor := strtoFloat(bB.RightSideOfEqual(tstr1)) ;

            // this function does the vector add/subtract
            lineNum :=  VectorAddOrSub(lineNum, AddOrSubtractOperation, vectorPrefactor) ;

            repeat
                 inc(lineNum) ;
                 tstr1 := bB.GetStringFromStrList(tStrList, lineNum) ;
            until (trim(tstr1) <> '') or (linenum > tStrList.Count)  ;
          end
          else if (bB.RightSideOfEqual(tstr1) = 'vector multiply or divide') then     //   type = vector add or subtract
          begin


            repeat
                 inc(lineNum) ;
                 tstr1 := bB.GetStringFromStrList(tStrList, lineNum) ;
            until (trim(tstr1) <> '') or (linenum > tStrList.Count)  ;
            if bB.LeftSideOfEqual(tstr1) = 'operation' then
              if bB.RightSideOfEqual(tstr1) = 'multiply' then
                AddOrSubtractOperation := 1
              else
                AddOrSubtractOperation := -1 ; //  = +1 (= multiply) or -1 (= divide)

            repeat
                 inc(lineNum) ;
                 tstr1 := bB.GetStringFromStrList(tStrList, lineNum) ;
            until (trim(tstr1) <> '') or (linenum > tStrList.Count)  ;
            if bB.LeftSideOfEqual(tstr1) = 'prefactor' then
                vectorPrefactor := strtoFloat(bB.RightSideOfEqual(tstr1)) ;

            repeat
                 inc(lineNum) ;
                 tstr1 := bB.GetStringFromStrList(tStrList, lineNum) ;
            until (trim(tstr1) <> '') or (linenum > tStrList.Count)  ;
            if bB.LeftSideOfEqual(tstr1) = 'y row' then
                tstr2 := bB.RightSideOfEqual(tstr1) ;

            // this function does the multiply/divide
            lineNum :=  VectorMultiplyOrDivide(lineNum, AddOrSubtractOperation, vectorPrefactor, tstr2) ;

            // this tidys up the remaining lines
            repeat
                 inc(lineNum) ;
                 tstr1 := bB.GetStringFromStrList(tStrList, lineNum) ;
            until (trim(tstr1) <> '') or (linenum > tStrList.Count)  ;


          end

          else if (bB.RightSideOfEqual(tstr1) = 'pcr') then
          begin
             try
              // This is the X data (Y data is specified in batch file as "YinXData = true" or "YinXData = false"
              tSR  := TSpectraRanges(Form4.StringGrid1.Objects[2,Form4.StringGrid1.Row]) ;

              // Create PCR batch file processing object
              tPCR := TPCRYPredictBatch.Create(tSR.xCoord.SDPrec div 4) ;   // this has to be released on deletion of row or close of appliction

              lineNumStr := tPCR.GetBatchArguments(lineNum, iter, tStrList) ;
              if pos(',',lineNumStr) > 0 then
              begin
                 tPCR.Free ;
                 exit ;
              end
              else
              lineNum := strtoint( lineNumStr ) ;

              if tPCR.YinXData = true then
                tSR2 := tSR
              else
                tSR2 := TSpectraRanges(Form4.StringGrid1.Objects[3,Form4.StringGrid1.Row]) ;


              // ******** CREATE NEW ROW IN STRING GRID  ********
              // create new line and objects in StringGrid using CreateStringGridRowAndObjects
              // this creates LineColour
              CreateStringGridRowAndObjects7( tPCR ) ;

              // This gets the data from the X an Y data column spectra and does all the processing of the batch file
              // and creation of a model with desired number of PCs included
              tTimer.setTimeDifSecUpdateT1 ;
              tStr1 := tPCR.ProcessPCRBatchFile(tSR,tSR2) ;
              if  length(tStr1 ) > 0 then
              begin
                 messagedlg('Function ProcessPLSBatchFile() failed. Line :'+inttostr(lineNum) + ' Error: '+ tStr1 ,mtError,[mbOK],0) ;
                 tPCR.Free ;
                 Form4.StatusBar1.Panels[1].Text := 'Function ProcessPLSBatchFile() failed. Line :'+inttostr(lineNum) + ' Error: '+ tStr1 ;
                 exit ;
              end ;
              tTimer.setTimeDifSec ;
              Form4.StatusBar1.Panels[1].Text := 'processing time: ' + floattostrf(tTimer.getRecordedTime,ffGeneral,5,4) ;

              // *** THESE ARE THE RESULTS  ***  Graph and add to stringgrid1
              tPCR.allXData.interleaved := 1 ;
              tPCR.allXData.GLListNumber := Form4.GetLowestListNumber ;

              Form4.StringGrid1.Objects[1,Form4.StringGrid1.RowCount-2]  :=  tPCR ;

              Form4.StringGrid1.Objects[2,Form4.StringGrid1.RowCount-2] :=  tPCR.allXData ;
              SetupallXDataAs1D_or_2D(1, tPCR.allXData , tSR) ;
              Form4.StringGrid1.Cells[2,Form4.StringGrid1.RowCount-2] := tPCR.allXData.ReturnRowColRangeString ;
              if tSR.fft.dt <> 0 then
                    tPCR.allXData.fft.CopyFFTObject(tSR.fft) ;

              tPCR.allYData.interleaved := 1 ;
              tPCR.allYData.GLListNumber := Form4.GetLowestListNumber ;
              tPCR.allYData.lineType := 10 ;
              SetupallXDataAs1D_or_2D(1, tPCR.allYData , tSR2) ;  // may need to use  SetupNativeMatrixAs1D_or_2D
              Form4.StringGrid1.Objects[3,Form4.StringGrid1.RowCount-2] :=  tPCR.allYData ;
              Form4.StringGrid1.Cells[3,Form4.StringGrid1.RowCount-2] := tPCR.allYData.ReturnRowColRangeString ;
              // this may not be needed
              if tSR2.fft.dt <> 0 then
                    tPCR.allYData.fft.CopyFFTObject(tSR2.fft) ;

              Form4.StringGrid1.Objects[4,Form4.StringGrid1.RowCount-2] := tPCR.scoresSpectra ;
              tPCR.scoresSpectra.yCoord.Transpose ;
              tPCR.scoresSpectra.GLListNumber := Form4.GetLowestListNumber ;
              if tSR.frequencyImage then
                tPCR.scoresSpectra.nativeImage := true ;
              SetupNativeMatrixAs1D_or_2D( tPCR.scoresSpectra, tSr ) ;
              Form4.StringGrid1.Cells[4,Form4.StringGrid1.RowCount-2] := tPCR.scoresSpectra.ReturnRowColRangeString ;
              tPCR.scoresSpectra.xString := 'Sample Number' ;
              tPCR.scoresSpectra.yString := 'Score' ;
              tPCR.scoresSpectra.numImagesOrAngles := tPCR.numPCs ;


              Form4.StringGrid1.Objects[5,Form4.StringGrid1.RowCount-2] := tPCR.eigenVSpectra ;
              tPCR.eigenVSpectra.GLListNumber := Form4.GetLowestListNumber ;
              tPCR.eigenVSpectra.SetOpenGLXYRange(Form2.GetWhichLineToDisplay());
              tPCR.eigenVSpectra.CreateGLList('1-',Form1.Canvas.Handle, RC, Form2.GetWhichLineToDisplay(), 1)   ;
              Form4.StringGrid1.Cells[5,Form4.StringGrid1.RowCount-2] := tPCR.eigenVSpectra.ReturnRowColRangeString ;
              tPCR.eigenVSpectra.xString := tPCR.allXData.xString ;
              tPCR.eigenVSpectra.yString := tPCR.allXData.yString  ;
              if tSR.fft.dt <> 0 then
                    tPCR.eigenVSpectra.fft.CopyFFTObject(tSR.fft) ;

              Form4.StringGrid1.Objects[6,Form4.StringGrid1.RowCount-2] := tPCR.eigenValSpectra ;
              tPCR.eigenValSpectra.GLListNumber := Form4.GetLowestListNumber ;
              tPCR.eigenValSpectra.SetOpenGLXYRange(Form2.GetWhichLineToDisplay());
              tPCR.eigenValSpectra.CreateGLList('1-',Form1.Canvas.Handle, RC, Form2.GetWhichLineToDisplay(), 4)   ;   // 4 = lines with dots
              tPCR.eigenValSpectra.YLow :=  0 ;
              Form4.StringGrid1.Cells[6,Form4.StringGrid1.RowCount-2] := tPCR.eigenValSpectra.ReturnRowColRangeString ;
              tPCR.eigenValSpectra.xString := 'PC Number' ;
              tPCR.eigenValSpectra.yString := 'Variance' ;

{              Form4.StringGrid1.Objects[7,Form4.StringGrid1.RowCount-2] := tPCR.XresidualsSpectra ;
              tPCR.XresidualsSpectra.GLListNumber := Form4.GetLowestListNumber ;
              if tSR.frequencyImage then
                tPCR.XresidualsSpectra.frequencyImage := true ;
              SetupallXDataAs1D_or_2D(1, tPCR.XresidualsSpectra , tSR) ;
              Form4.StringGrid1.Cells[7,Form4.StringGrid1.RowCount-2] := tPCR.XresidualsSpectra.ReturnRowColRangeString ;
              tPCR.XresidualsSpectra.xString := tPCR.allXData.xString ;
              tPCR.XresidualsSpectra.yString := tPCR.allXData.yString  ;
              if tSR.fft.dt <> 0 then
                    tPCR.XresidualsSpectra.fft.CopyFFTObject(tSR.fft) ;

              Form4.StringGrid1.Objects[8,Form4.StringGrid1.RowCount-2] := tPCR.regenSpectra ;
              tPCR.regenSpectra.GLListNumber := Form4.GetLowestListNumber ;
              if tSR.frequencyImage then
                tPCR.regenSpectra.frequencyImage := true ;
              SetupallXDataAs1D_or_2D(1, tPCR.regenSpectra , tSR) ;
              Form4.StringGrid1.Cells[8,Form4.StringGrid1.RowCount-2] := tPCR.regenSpectra.ReturnRowColRangeString ;
              tPCR.regenSpectra.xString := tPCR.allXData.xString ;
              tPCR.regenSpectra.yString := tPCR.allXData.yString  ;
              if tSR.fft.dt <> 0 then
                    tPCR.regenSpectra.fft.CopyFFTObject(tSR.fft) ;
}

              //  y residuals
              Form4.StringGrid1.Objects[9,Form4.StringGrid1.RowCount-2] := tPCR.YresidualsSpectra ;
              tPCR.YresidualsSpectra.GLListNumber := Form4.GetLowestListNumber ;
              if tSR.frequencyImage then
                tPCR.YresidualsSpectra.nativeImage := true ; // 1 image for each PC
              SetupNativeMatrixAs1D_or_2D( tPCR.YresidualsSpectra, tSr ) ;
              Form4.StringGrid1.Cells[9,Form4.StringGrid1.RowCount-2] := tPCR.YresidualsSpectra.ReturnRowColRangeString ;
              tPCR.YresidualsSpectra.xString := 'PC number' ;
              tPCR.YresidualsSpectra.yString := 'Y Residual'  ;
              if tSR.fft.dt <> 0 then
                    tPCR.YresidualsSpectra.fft.CopyFFTObject(tSR.fft) ;


              // this is a scatter type plot      
              Form4.StringGrid1.Objects[10,Form4.StringGrid1.RowCount-2] := tPCR.predictedYPCR ;
 //             tPCR.predYPLSSpectra.lineType := 4 ;
              tPCR.predictedYPCR.xyScatterPlot := true ;
              tPCR.predictedYPCR.GLListNumber := Form4.GetLowestListNumber ;
              tPCR.predictedYPCR.SetOpenGLXYRangeScatterPlot(Form2.GetWhichLineToDisplay());
              tPCR.predictedYPCR.CreateGLList('1-',Form1.Canvas.Handle, RC, Form2.GetWhichLineToDisplay(), 10)   ;
              Form4.StringGrid1.Cells[10,Form4.StringGrid1.RowCount-2] := tPCR.predictedYPCR.ReturnRowColRangeString ;
              tPCR.predictedYPCR.xString := 'Known Y' ;
              tPCR.predictedYPCR.yString := 'Predicted Y'  ;
              if tSR.fft.dt <> 0 then
                    tPCR.predictedYPCR.fft.CopyFFTObject(tSR.fft) ;


              Form4.StringGrid1.Objects[11,Form4.StringGrid1.RowCount-2] := tPCR.modelPCRSpectra ;
              tPCR.modelPCRSpectra.GLListNumber := Form4.GetLowestListNumber ;
              tPCR.modelPCRSpectra.SetOpenGLXYRange(Form2.GetWhichLineToDisplay());
              tPCR.modelPCRSpectra.CreateGLList('1-',Form1.Canvas.Handle, RC, Form2.GetWhichLineToDisplay(), 1)   ;
              Form4.StringGrid1.Cells[11,Form4.StringGrid1.RowCount-2] := tPCR.modelPCRSpectra.ReturnRowColRangeString ;
              tPCR.modelPCRSpectra.xString := tPCR.allXData.xString ;
              tPCR.modelPCRSpectra.yString := 'PCR Model'  ;
              if tSR.fft.dt <> 0 then
                    tPCR.modelPCRSpectra.fft.CopyFFTObject(tSR.fft) ;     


              Form4.StringGrid1.Objects[12,Form4.StringGrid1.RowCount-2] := tPCR.regresCoefSpectra ;
              tPCR.regresCoefSpectra.GLListNumber := Form4.GetLowestListNumber ;
              tPCR.regresCoefSpectra.SetOpenGLXYRange(Form2.GetWhichLineToDisplay());
              tPCR.regresCoefSpectra.CreateGLList('1-',Form1.Canvas.Handle, RC, Form2.GetWhichLineToDisplay(), 1)   ;
              Form4.StringGrid1.Cells[12,Form4.StringGrid1.RowCount-2] := tPCR.regresCoefSpectra.ReturnRowColRangeString ;
              tPCR.regresCoefSpectra.xString := tPCR.allXData.xString ;
              tPCR.regresCoefSpectra.yString := 'variable coefficients'  ;
              if tSR.fft.dt <> 0 then
                    tPCR.regresCoefSpectra.fft.CopyFFTObject(tSR.fft) ;


              Form4.StringGrid1.Objects[13,Form4.StringGrid1.RowCount-2] := tPCR.R_sqrd_PCR ;
              tPCR.R_sqrd_PCR.GLListNumber := Form4.GetLowestListNumber ;
              tPCR.R_sqrd_PCR.SetOpenGLXYRange(Form2.GetWhichLineToDisplay());
              Form4.StringGrid1.Cells[13,Form4.StringGrid1.RowCount-2] := '1' +' : 1-' + inttostr(tPCR.R_sqrd_PCR.yCoord.numCols) ;
              tPCR.R_sqrd_PCR.CreateGLList('1-',Form1.Canvas.Handle, RC, Form2.GetWhichLineToDisplay(), 3)   ;
              tPCR.R_sqrd_PCR.xString :=  'PC number' ;
              tPCR.R_sqrd_PCR.yString := 'R^2'  ;
              if tSR.fft.dt <> 0 then
                    tPCR.R_sqrd_PCR.fft.CopyFFTObject(tSR.fft) ;
              tPCR.R_sqrd_PCR.yLow := 0.0 ;
              tPCR.R_sqrd_PCR.yHigh := 1.0 ;

              TSpectraRanges(Form4.StringGrid1.Objects[4,Form4.StringGrid1.RowCount-2]).columnLabel  := 'scores'     ;   // PCR
              TSpectraRanges(Form4.StringGrid1.Objects[5,Form4.StringGrid1.RowCount-2]).columnLabel  := 'eignevects'   ;
              TSpectraRanges(Form4.StringGrid1.Objects[6,Form4.StringGrid1.RowCount-2]).columnLabel  := 'eigenvals:' ;    // plot of variance spanned by each PC
              TSpectraRanges(Form4.StringGrid1.Objects[7,Form4.StringGrid1.RowCount-2]).columnLabel  := 'x resid.'   ;    // residual data left after subtraction of desired PC range of eigenvectors.
              TSpectraRanges(Form4.StringGrid1.Objects[8,Form4.StringGrid1.RowCount-2]).columnLabel  := 'x regen. '  ;    // regenerated data from desired set of PCs  specified
              TSpectraRanges(Form4.StringGrid1.Objects[9,Form4.StringGrid1.RowCount-2]).columnLabel  := 'y resid.'   ;    // regression residual y data for each PC added. Good for outlier detection.
              TSpectraRanges(Form4.StringGrid1.Objects[10,Form4.StringGrid1.RowCount-2]).columnLabel := 'y pred.'    ;    // plot of measured vs predicted for set of PC's specified
              TSpectraRanges(Form4.StringGrid1.Objects[11,Form4.StringGrid1.RowCount-2]).columnLabel := 'model:'     ;    // PCR specific
              TSpectraRanges(Form4.StringGrid1.Objects[12,Form4.StringGrid1.RowCount-2]).columnLabel := 'reg. coef.' ;    // result of regression. Plot of Variables vs Absorbance for number of PC's specified
              TSpectraRanges(Form4.StringGrid1.Objects[13,Form4.StringGrid1.RowCount-2]).columnLabel := 'R^2'        ;    // Single value of R value for regression. If IR-pol then plot of position vs R value OR if 2D then

              Form4.StringGrid1.Cells[1,Form4.StringGrid1.RowCount-2] := ExtractFileName(tPCR.allXData.XCoord.Filename) ;

               // add batch file text to created data
              tSR := TSpectraRanges(Form4.StringGrid1.Objects[2,Form4.StringGrid1.RowCount-2]) ;
              tSR.batchList.Add('// from line: '+inttostr(Form4.StringGrid1.Row)) ;
              tSR.batchList.Add('//processing time: ' + floattostrf(tTimer.getRecordedTime,ffGeneral,5,4) + ' / ' + floattostrf(tTimer.returnCPUSpeedGHz,ffGeneral,5,4) + 'GHz') ;
             
              for t1 :=  initialLineNum to lineNum-1   do
              begin
                 tSR.batchList.Add(bB.GetStringFromStrList(tStrList, t1)) ;
              end ;
            except
              RemoveRow('PCR code encountered a problem') ;
            end ;
          end
          else if  (bB.RightSideOfEqual(tstr1) = 'pls1') then
          begin
            try
              // This is the X data (Y data is specified in batch file as "YinXData = true" or "YinXData = false"
              tSR  := TSpectraRanges(Form4.StringGrid1.Objects[2,Form4.StringGrid1.Row]) ;

              // Create PLS batch file processing object
              tPLS := TPLSYPredictBatch.Create(tSR.xCoord.SDPrec div 4) ;   // this has to be released on deletion of row or close of appliction

              lineNumStr := tPLS.GetBatchArguments(lineNum, iter, tStrList) ;
              if pos(',',lineNumStr) > 0 then
              begin
                 tPLS.Free ;
                 exit ;
              end
              else
              lineNum := strtoint( lineNumStr ) ;

              if tPLS.YinXData = true then
                tSR2 := tSR
              else
                tSR2 := TSpectraRanges(Form4.StringGrid1.Objects[3,Form4.StringGrid1.Row]) ;


              // ******** CREATE NEW ROW IN STRING GRID  ********
              // create new line and objects in StringGrid using CreateStringGridRowAndObjects
              // this creates LineColour
              CreateStringGridRowAndObjects6( tPLS ) ;

              // This gets the data from the X an Y data column spectra and does all the processing of the batch file
              // and creation of a model with desired number of PCs included
              tTimer.setTimeDifSecUpdateT1 ;
              tStr1 := tPLS.ProcessPLSBatchFile(tSR,tSR2) ;
              if  length(tStr1 ) > 0 then
              begin
                 messagedlg('Function ProcessPLSBatchFile() failed. Line :'+inttostr(lineNum) + ' Error: '+ tStr1 ,mtError,[mbOK],0) ;
                 tPLS.Free ;
               //  RemoveRow('Function ProcessPLSBatchFile() failed. Line :'+inttostr(lineNum) + ' Error: '+ tSr1) ;
                 exit ;
              end ;
              tTimer.setTimeDifSec ;
              Form4.StatusBar1.Panels[1].Text := 'processing time: ' + floattostrf(tTimer.getRecordedTime,ffGeneral,5,4) ;

              // *** THESE ARE THE RESULTS  ***  Graph and add to stringgrid1
              tPLS.allXData.interleaved := 1 ;
              tPLS.allXData.GLListNumber := Form4.GetLowestListNumber ;

              Form4.StringGrid1.Objects[1,Form4.StringGrid1.RowCount-2]  :=  tPLS ;

              Form4.StringGrid1.Objects[2,Form4.StringGrid1.RowCount-2] :=  tPLS.allXData ;
              SetupallXDataAs1D_or_2D(1, tPLS.allXData , tSR) ;
              Form4.StringGrid1.Cells[2,Form4.StringGrid1.RowCount-2] := tPLS.allXData.ReturnRowColRangeString ;
              if tSR.fft.dt <> 0 then
                    tPLS.allXData.fft.CopyFFTObject(tSR.fft) ;

              tPLS.allYData.interleaved := 1 ;
              tPLS.allYData.GLListNumber := Form4.GetLowestListNumber ;
              tPLS.allYData.lineType := 10 ;
              SetupallXDataAs1D_or_2D(1, tPLS.allYData , tSR2) ;  // may need to use  SetupNativeMatrixAs1D_or_2D
              Form4.StringGrid1.Objects[3,Form4.StringGrid1.RowCount-2] :=  tPLS.allYData ;
              Form4.StringGrid1.Cells[3,Form4.StringGrid1.RowCount-2] := tPLS.allYData.ReturnRowColRangeString ;
              // this may not be needed
              if tSR2.fft.dt <> 0 then
                    tPLS.allYData.fft.CopyFFTObject(tSR2.fft) ;

              Form4.StringGrid1.Objects[4,Form4.StringGrid1.RowCount-2] := tPLS.scoresSpectra ;
              tPLS.scoresSpectra.yCoord.Transpose ;
              tPLS.scoresSpectra.GLListNumber := Form4.GetLowestListNumber ;
              if tSR.frequencyImage then
                tPLS.scoresSpectra.nativeImage := true ;
              SetupNativeMatrixAs1D_or_2D( tPLS.scoresSpectra, tSr ) ;
              Form4.StringGrid1.Cells[4,Form4.StringGrid1.RowCount-2] := tPLS.scoresSpectra.ReturnRowColRangeString ;
              tPLS.scoresSpectra.xString := 'Sample Number' ;
              tPLS.scoresSpectra.yString := 'Score' ;
              tPLS.scoresSpectra.numImagesOrAngles := tPLS.numPCs ;


              Form4.StringGrid1.Objects[5,Form4.StringGrid1.RowCount-2] := tPLS.eigenVSpectra ;
              tPLS.eigenVSpectra.GLListNumber := Form4.GetLowestListNumber ;
              tPLS.eigenVSpectra.SetOpenGLXYRange(Form2.GetWhichLineToDisplay());
              tPLS.eigenVSpectra.CreateGLList('1-',Form1.Canvas.Handle, RC, Form2.GetWhichLineToDisplay(), 1)   ;
              Form4.StringGrid1.Cells[5,Form4.StringGrid1.RowCount-2] := tPLS.eigenVSpectra.ReturnRowColRangeString ;
              tPLS.eigenVSpectra.xString := tPLS.allXData.xString ;
              tPLS.eigenVSpectra.yString := tPLS.allXData.yString  ;
              if tSR.fft.dt <> 0 then
                    tPLS.eigenVSpectra.fft.CopyFFTObject(tSR.fft) ;

              Form4.StringGrid1.Objects[6,Form4.StringGrid1.RowCount-2] := tPLS.eigenValSpectra ;
              tPLS.eigenValSpectra.GLListNumber := Form4.GetLowestListNumber ;
              tPLS.eigenValSpectra.SetOpenGLXYRange(Form2.GetWhichLineToDisplay());
              tPLS.eigenValSpectra.CreateGLList('1-',Form1.Canvas.Handle, RC, Form2.GetWhichLineToDisplay(), 4)   ;   // 4 = lines with dots
              tPLS.eigenValSpectra.YLow :=  0 ;
              Form4.StringGrid1.Cells[6,Form4.StringGrid1.RowCount-2] := tPLS.eigenValSpectra.ReturnRowColRangeString ;
              tPLS.eigenValSpectra.xString := 'PC Number' ;
              tPLS.eigenValSpectra.yString := 'Variance' ;

    {          Form4.StringGrid1.Objects[7,Form4.StringGrid1.RowCount-2] := tPLS.XresidualsSpectra ;
              tPLS.XresidualsSpectra.GLListNumber := Form4.GetLowestListNumber ;
              if tSR.frequencyImage then
                tPLS.XresidualsSpectra.frequencyImage := true ;
              SetupallXDataAs1D_or_2D(1, tPLS.XresidualsSpectra , tSR) ;
              Form4.StringGrid1.Cells[7,Form4.StringGrid1.RowCount-2] := tPLS.XresidualsSpectra.ReturnRowColRangeString ;
              tPLS.XresidualsSpectra.xString := tPLS.allXData.xString ;
              tPLS.XresidualsSpectra.yString := tPLS.allXData.yString  ;
              if tSR.fft.dt <> 0 then
                    tPLS.XresidualsSpectra.fft.CopyFFTObject(tSR.fft) ;

              Form4.StringGrid1.Objects[8,Form4.StringGrid1.RowCount-2] := tPLS.regenSpectra ;
              tPLS.regenSpectra.GLListNumber := Form4.GetLowestListNumber ;
              if tSR.frequencyImage then
                tPLS.regenSpectra.frequencyImage := true ;
              SetupallXDataAs1D_or_2D(1, tPLS.regenSpectra , tSR) ;
              Form4.StringGrid1.Cells[8,Form4.StringGrid1.RowCount-2] := tPLS.regenSpectra.ReturnRowColRangeString ;
              tPLS.regenSpectra.xString := tPLS.allXData.xString ;
              tPLS.regenSpectra.yString := tPLS.allXData.yString  ;
              if tSR.fft.dt <> 0 then
                    tPLS.regenSpectra.fft.CopyFFTObject(tSR.fft) ;      }


              //  y residuals
              Form4.StringGrid1.Objects[9,Form4.StringGrid1.RowCount-2] := tPLS.YresidualsSpectra ;
              tPLS.YresidualsSpectra.GLListNumber := Form4.GetLowestListNumber ;
              if tSR.frequencyImage then
                tPLS.YresidualsSpectra.nativeImage := true ; // 1 image for each PC
              SetupNativeMatrixAs1D_or_2D( tPLS.YresidualsSpectra, tSr ) ;
              Form4.StringGrid1.Cells[9,Form4.StringGrid1.RowCount-2] := tPLS.YresidualsSpectra.ReturnRowColRangeString ;
              tPLS.YresidualsSpectra.xString := 'PC number' ;
              tPLS.YresidualsSpectra.yString := 'Y Residual'  ;
              if tSR.fft.dt <> 0 then
                    tPLS.YresidualsSpectra.fft.CopyFFTObject(tSR.fft) ;


              // this is a scatter type plot      
              Form4.StringGrid1.Objects[10,Form4.StringGrid1.RowCount-2] := tPLS.predYPLSSpectra ;
 //             tPLS.predYPLSSpectra.lineType := 4 ;
              tPLS.predYPLSSpectra.xyScatterPlot := true ;
              tPLS.predYPLSSpectra.GLListNumber := Form4.GetLowestListNumber ;
              tPLS.predYPLSSpectra.SetOpenGLXYRangeScatterPlot(Form2.GetWhichLineToDisplay());
              tPLS.predYPLSSpectra.CreateGLList('1-',Form1.Canvas.Handle, RC, Form2.GetWhichLineToDisplay(), 10)   ;
              Form4.StringGrid1.Cells[10,Form4.StringGrid1.RowCount-2] := tPLS.predYPLSSpectra.ReturnRowColRangeString ;
              tPLS.predYPLSSpectra.xString := 'Known Y' ;
              tPLS.predYPLSSpectra.yString := 'Predicted Y'  ;
              if tSR.fft.dt <> 0 then
                    tPLS.predYPLSSpectra.fft.CopyFFTObject(tSR.fft) ;


              Form4.StringGrid1.Objects[11,Form4.StringGrid1.RowCount-2] := tPLS.weightsSpectra ;
              tPLS.weightsSpectra.GLListNumber := Form4.GetLowestListNumber ;
              tPLS.weightsSpectra.SetOpenGLXYRange(Form2.GetWhichLineToDisplay());
              tPLS.weightsSpectra.CreateGLList('1-',Form1.Canvas.Handle, RC, Form2.GetWhichLineToDisplay(), 1)   ;
              Form4.StringGrid1.Cells[11,Form4.StringGrid1.RowCount-2] := tPLS.weightsSpectra.ReturnRowColRangeString ;
              tPLS.weightsSpectra.xString := tPLS.allXData.xString ;
              tPLS.weightsSpectra.yString := 'X weight'  ;
              if tSR.fft.dt <> 0 then
                    tPLS.weightsSpectra.fft.CopyFFTObject(tSR.fft) ;


              Form4.StringGrid1.Objects[12,Form4.StringGrid1.RowCount-2] := tPLS.regresCoefSpectra ;
              tPLS.regresCoefSpectra.GLListNumber := Form4.GetLowestListNumber ;
              tPLS.regresCoefSpectra.SetOpenGLXYRange(Form2.GetWhichLineToDisplay());
              tPLS.regresCoefSpectra.CreateGLList('1-',Form1.Canvas.Handle, RC, Form2.GetWhichLineToDisplay(), 1)   ;
              Form4.StringGrid1.Cells[12,Form4.StringGrid1.RowCount-2] := tPLS.regresCoefSpectra.ReturnRowColRangeString ;
              tPLS.regresCoefSpectra.xString := tPLS.allXData.xString ;
              tPLS.regresCoefSpectra.yString := 'variable coefficients'  ;
              if tSR.fft.dt <> 0 then
                    tPLS.weightsSpectra.fft.CopyFFTObject(tSR.fft) ;


              Form4.StringGrid1.Objects[13,Form4.StringGrid1.RowCount-2] := tPLS.R_sqrd_PLS ;
              tPLS.R_sqrd_PLS.GLListNumber := Form4.GetLowestListNumber ;
              tPLS.R_sqrd_PLS.SetOpenGLXYRange(Form2.GetWhichLineToDisplay());
              Form4.StringGrid1.Cells[13,Form4.StringGrid1.RowCount-2] := '1' +' : 1-' + inttostr(tPLS.R_sqrd_PLS.yCoord.numCols) ;
              tPLS.R_sqrd_PLS.CreateGLList('1-',Form1.Canvas.Handle, RC, Form2.GetWhichLineToDisplay(), 3)   ;
              tPLS.R_sqrd_PLS.xString :=  'PC number' ;
              tPLS.R_sqrd_PLS.yString := 'R^2'  ;
              if tSR.fft.dt <> 0 then
                    tPLS.R_sqrd_PLS.fft.CopyFFTObject(tSR.fft) ;
              tPLS.R_sqrd_PLS.yLow := 0.0 ;
              tPLS.R_sqrd_PLS.yHigh := 1.0 ;


              TSpectraRanges(Form4.StringGrid1.Objects[2,Form4.StringGrid1.RowCount-2]).columnLabel  := 'X data'     ;   // PCR
              TSpectraRanges(Form4.StringGrid1.Objects[3,Form4.StringGrid1.RowCount-2]).columnLabel  := 'Y data'   ;
              TSpectraRanges(Form4.StringGrid1.Objects[4,Form4.StringGrid1.RowCount-2]).columnLabel  := 'scores'     ;   // PCR
              TSpectraRanges(Form4.StringGrid1.Objects[5,Form4.StringGrid1.RowCount-2]).columnLabel  := 'eignevects'   ;
              TSpectraRanges(Form4.StringGrid1.Objects[6,Form4.StringGrid1.RowCount-2]).columnLabel  := 'eigenvals:' ;    // plot of variance spanned by each PC
            //  TSpectraRanges(Form4.StringGrid1.Objects[7,Form4.StringGrid1.RowCount-2]).columnLabel  := 'x resid.'   ;    // residual data left after subtraction of desired PC range of eigenvectors.
            //  TSpectraRanges(Form4.StringGrid1.Objects[8,Form4.StringGrid1.RowCount-2]).columnLabel  := 'x regen. '  ;    // regenerated data from desired set of PCs  specified
              TSpectraRanges(Form4.StringGrid1.Objects[9,Form4.StringGrid1.RowCount-2]).columnLabel  := 'y resid.'   ;    // regression residual y data for each PC added. Good for outlier detection.
              TSpectraRanges(Form4.StringGrid1.Objects[10,Form4.StringGrid1.RowCount-2]).columnLabel := 'y pred.'    ;    // plot of measured vs predicted for set of PC's specified
              TSpectraRanges(Form4.StringGrid1.Objects[11,Form4.StringGrid1.RowCount-2]).columnLabel := 'weights:'     ;    // PCR specific
              TSpectraRanges(Form4.StringGrid1.Objects[12,Form4.StringGrid1.RowCount-2]).columnLabel := 'reg. coef.' ;    // result of regression. Plot of Variables vs Absorbance for number of PC's specified
              TSpectraRanges(Form4.StringGrid1.Objects[13,Form4.StringGrid1.RowCount-2]).columnLabel := 'R^2'     ;


              Form4.StringGrid1.Cells[1,Form4.StringGrid1.RowCount-2] := ExtractFileName(tPLS.allXData.XCoord.Filename) ;

               // add batch file text to created data
              tSR := TSpectraRanges(Form4.StringGrid1.Objects[2,Form4.StringGrid1.RowCount-2]) ;
              tSR.batchList.Add('// from line: '+inttostr(Form4.StringGrid1.Row)) ;
              tSR.batchList.Add('//processing time: ' + floattostrf(tTimer.getRecordedTime,ffGeneral,5,4) + ' / ' + floattostrf(tTimer.returnCPUSpeedGHz,ffGeneral,5,4) + 'GHz') ;

              for t1 :=  initialLineNum to lineNum-1   do
              begin
                 tSR.batchList.Add(bB.GetStringFromStrList(tStrList, t1)) ;
              end ;
            except
              RemoveRow('PLS1 code encountered a problem') ;
            end ;
          end
          else if  (bB.RightSideOfEqual(tstr1) = 'predict y') then
          begin
             try
               // This is the X data (Y data is specified in batch file as "YinXData = true" or "YinXData = false"
               tSR  := TSpectraRanges(Form4.StringGrid1.Objects[2,Form4.StringGrid1.Row]) ;

               // Create PLS batch file processing object
               tYPredict := TPLSYPredictTestBatch.Create(tSR.yCoord.SDPrec div 4) ;   // this has to be released on deletion of row or close of appliction

               lineNumStr := tYPredict.GetBatchArguments(lineNum, iter, tStrList) ;
               if pos(',',lineNumStr) > 0 then
               begin
                 tYPredict.Free ;
                 exit ;
               end
               else
               lineNum := strtoint( lineNumStr ) ;

               // this is the source of the Y data
               if tYPredict.YinXData = true then
                 tSR2 := tSR   // Y data is in X data matrix
               else
                 tSR2 := TSpectraRanges(Form4.StringGrid1.Objects[3,Form4.StringGrid1.Row]) ; // this is Y data

                // this is the regression coeficients
                tSR3  := TSpectraRanges(Form4.StringGrid1.Objects[4,Form4.StringGrid1.Row]) ; // these are regression coeficients

               // This gets the data from the X an Y data column spectra and does all the processing of the batch file
               // and creation of a model with desired number of PCs included
               tTimer.setTimeDifSecUpdateT1 ;
               tStr1 := tYPredict.TestModelData(tSR,tSR2, tSR3) ; // this does the processing
               if  length(tStr1 ) > 0 then
               begin
                 messagedlg('Function TestModelData() failed. Line :'+inttostr(lineNum) + ' Error: '+ tStr1 ,mtError,[mbOK],0) ;
                 tYPredict.Free ;
               //  RemoveRow('Function ProcessPLSBatchFile() failed. Line :'+inttostr(lineNum) + ' Error: '+ tSr1) ;
                 exit ;
               end ;
               tTimer.setTimeDifSec ;
               Form4.StatusBar1.Panels[1].Text := 'processing time: ' + floattostrf(tTimer.getRecordedTime,ffGeneral,5,4) ;


              tYPredict.allXData.interleaved := 1 ;
              tYPredict.allXData.GLListNumber := Form4.GetLowestListNumber ;

              Form4.StringGrid1.Objects[1,Form4.StringGrid1.RowCount-2]  :=  tYPredict ;

              Form4.StringGrid1.Objects[5,Form4.StringGrid1.Row] :=  tYPredict.allXData ;
              SetupallXDataAs1D_or_2D(1, tYPredict.allXData , tSR) ;
              Form4.StringGrid1.Cells[5,Form4.StringGrid1.Row] := tYPredict.allXData.ReturnRowColRangeString ;
              if tSR.fft.dt <> 0 then
                    tYPredict.allXData.fft.CopyFFTObject(tSR.fft) ;

              if tYPredict.YDataExists then
              begin
                tYPredict.allYData.interleaved := 1 ;
                tYPredict.allYData.GLListNumber := Form4.GetLowestListNumber ;
                tYPredict.allYData.lineType := 10 ;
                SetupallXDataAs1D_or_2D(1, tYPredict.allYData , tSR2) ;  // may need to use  SetupNativeMatrixAs1D_or_2D
                Form4.StringGrid1.Objects[6,Form4.StringGrid1.Row] :=  tYPredict.allYData ;
                Form4.StringGrid1.Cells[6,Form4.StringGrid1.Row] := tYPredict.allYData.ReturnRowColRangeString ;
                // this may not be needed
                if tSR2.fft.dt <> 0 then
                    tYPredict.allYData.fft.CopyFFTObject(tSR2.fft) ;

                 //  y residuals
                Form4.StringGrid1.Objects[9,Form4.StringGrid1.Row] := tYPredict.YresidualsSpectra ;
                tYPredict.YresidualsSpectra.GLListNumber := Form4.GetLowestListNumber ;
                if tSR.frequencyImage then
                  tYPredict.YresidualsSpectra.nativeImage := true ; // 1 image for each PC
                SetupNativeMatrixAs1D_or_2D( tYPredict.YresidualsSpectra, tSr ) ;
                Form4.StringGrid1.Cells[9,Form4.StringGrid1.Row] := tYPredict.YresidualsSpectra.ReturnRowColRangeString ;
                tYPredict.YresidualsSpectra.xString := 'PC number' ;
                tYPredict.YresidualsSpectra.yString := 'Y Residual'  ;
                if tSR.fft.dt <> 0 then
                    tYPredict.YresidualsSpectra.fft.CopyFFTObject(tSR.fft) ;
               end ;

              // this is a scatter type plot      
              Form4.StringGrid1.Objects[10,Form4.StringGrid1.Row] := tYPredict.predYSpectra ;
 //             tPLS.predYPLSSpectra.lineType := 4 ;
              tYPredict.predYSpectra.xyScatterPlot := true ;
              tYPredict.predYSpectra.GLListNumber := Form4.GetLowestListNumber ;
              tYPredict.predYSpectra.SetOpenGLXYRangeScatterPlot(Form2.GetWhichLineToDisplay());
              tYPredict.predYSpectra.CreateGLList('1-',Form1.Canvas.Handle, RC, Form2.GetWhichLineToDisplay(), 10)   ;
              Form4.StringGrid1.Cells[10,Form4.StringGrid1.Row] := tYPredict.predYSpectra.ReturnRowColRangeString ;
              tYPredict.predYSpectra.xString := 'Known Y' ;
              tYPredict.predYSpectra.yString := 'Predicted Y'  ;
              if tSR.fft.dt <> 0 then
                    tYPredict.predYSpectra.fft.CopyFFTObject(tSR.fft) ;

              if tYPredict.YDataExists then
              begin
                Form4.StringGrid1.Objects[13,Form4.StringGrid1.Row] := tYPredict.R_sqrd ;
                tYPredict.R_sqrd.GLListNumber := Form4.GetLowestListNumber ;
                tYPredict.R_sqrd.SetOpenGLXYRange(Form2.GetWhichLineToDisplay());
                Form4.StringGrid1.Cells[13,Form4.StringGrid1.Row] := tYPredict.R_sqrd.ReturnRowColRangeString ;
                tYPredict.R_sqrd.CreateGLList('1-',Form1.Canvas.Handle, RC, Form2.GetWhichLineToDisplay(), 3)   ;
                tYPredict.R_sqrd.xString :=  'PC number' ;
                tYPredict.R_sqrd.yString := 'R^2'  ;
                if tSR.fft.dt <> 0 then
                    tYPredict.R_sqrd.fft.CopyFFTObject(tSR.fft) ;
                tYPredict.R_sqrd.yLow := 0.0 ;
                tYPredict.R_sqrd.yHigh := 1.0 ;

                Form4.StringGrid1.Objects[12,Form4.StringGrid1.Row] := tYPredict.SEPSpectra ;
                tYPredict.SEPSpectra.GLListNumber := Form4.GetLowestListNumber ;
                tYPredict.SEPSpectra.SetOpenGLXYRange(Form2.GetWhichLineToDisplay());
                Form4.StringGrid1.Cells[12,Form4.StringGrid1.Row] := tYPredict.SEPSpectra.ReturnRowColRangeString ;
                tYPredict.SEPSpectra.CreateGLList('1-',Form1.Canvas.Handle, RC, Form2.GetWhichLineToDisplay(), 3)   ;
                tYPredict.SEPSpectra.xString :=  'PC number' ;
                tYPredict.SEPSpectra.yString := 'SEP'  ;
                if tSR.fft.dt <> 0 then
                    tYPredict.R_sqrd.fft.CopyFFTObject(tSR.fft) ;

                // N.B. this function does not create a new line, so use 'RowCount-1' not 'RowCount-2'
                TSpectraRanges(Form4.StringGrid1.Objects[4,Form4.StringGrid1.RowCount-1]).columnLabel  := 'reg. coef.'     ;   // PCR
                TSpectraRanges(Form4.StringGrid1.Objects[5,Form4.StringGrid1.RowCount-1]).columnLabel  := 'x data'   ;
                TSpectraRanges(Form4.StringGrid1.Objects[6,Form4.StringGrid1.RowCount-1]).columnLabel  := 'y data' ;
                //TSpectraRanges(Form4.StringGrid1.Objects[7,Form4.StringGrid1.RowCount-2]).columnLabel  := 'x resid.'   ;
                //TSpectraRanges(Form4.StringGrid1.Objects[8,Form4.StringGrid1.RowCount-2]).columnLabel  := 'x regen. '  ;    // regenerated data from desired set of PCs  specified
                TSpectraRanges(Form4.StringGrid1.Objects[9,Form4.StringGrid1.RowCount-1]).columnLabel  := 'y resid.'   ;    // regression residual y data for each PC added. Good for outlier detection.
                TSpectraRanges(Form4.StringGrid1.Objects[10,Form4.StringGrid1.RowCount-1]).columnLabel := 'y pred.'    ;    // plot of measured vs predicted for set of PC's specified
                //TSpectraRanges(Form4.StringGrid1.Objects[11,Form4.StringGrid1.RowCount-2]).columnLabel := 'weights:'     ;    // PCR specific
                //TSpectraRanges(Form4.StringGrid1.Objects[12,Form4.StringGrid1.RowCount-2]).columnLabel := 'reg. coef.' ;    // result of regression. Plot of Variables vs Absorbance for number of PC's specified
                TSpectraRanges(Form4.StringGrid1.Objects[13,Form4.StringGrid1.RowCount-1]).columnLabel := 'R^2'
              end
              else
              begin
                TSpectraRanges(Form4.StringGrid1.Objects[4,Form4.StringGrid1.RowCount-1]).columnLabel  := 'reg. coef.'     ;   // PCR
                TSpectraRanges(Form4.StringGrid1.Objects[5,Form4.StringGrid1.RowCount-1]).columnLabel  := 'x data'   ;
                TSpectraRanges(Form4.StringGrid1.Objects[6,Form4.StringGrid1.RowCount-1]).columnLabel  := 'y data' ;
              end;
             except
             begin
               // RemoveRow('PLS1 code encountered a problem') ;
               Form4.StatusBar1.Panels[0].Text :=  'Predict Y data code encountered a problem' ;
             end ;
             end ;
          end 
          else if  (bB.RightSideOfEqual(tstr1) = 'pca') then
          begin
              tSR := TSpectraRanges(Form4.StringGrid1.Objects[2,Form4.StringGrid1.Row]) ;

              tPCA := TPCABatch.Create(tSR.xCoord.SDPrec div 4) ;   // this has to be released on deletion of row or close of appliction

              lineNumStr := tPCA.GetPCABatchArguments(lineNum, iter, tStrList) ;
              if pos(',',lineNumStr) > 0 then
              begin
                 tPCA.Free ;
                 exit ;
              end
              else
              lineNum := strtoint( lineNumStr ) ;

              if not tPCA.GetAllXData(tPCA.interleaved, tSR ) then
              begin
                 tPCA.Free ;
               //  RemoveRow('Function TPCABatch.GetAllXData() failed during data processing. Line number: '+inttostr(lineNum)) ;
                 exit ;
              end ;

               // GET CURRENT INTENSITY VALUE AND RED/GREEN/BLUE VALUE
              tPCA.allXData.LineColor := ReturnLineColor(IntensityList,1) ;   //  ReturnLineColor is dependent upon the number of lines in the string grid
              colArray :=  tPCA.allXData.LineColor ;

              tTimer.setTimeDifSecUpdateT1 ;
              if  (tPCA.ProcessPCAData( @colArray ) = false) then
              begin
                 tPCA.Free ;
              //   RemoveRow('Function tPCA.ProcessPCAData() failed during data processing. Line number: '+inttostr(lineNum)) ;
                 exit ;
              end ;
              tTimer.setTimeDifSec ;
              Form4.StatusBar1.Panels[1].Text := 'processing time: ' + floattostrf(tTimer.getRecordedTime,ffGeneral,5,4) + ' / ' + floattostrf(tTimer.returnCPUSpeedGHz,ffGeneral,5,4) + 'GHz' ;


              // ******** CREATE NEW ROW IN STRING GRID  ********
              // create new line and objects in StringGrid using CreateStringGridRowAndObjects
              Form4.StringGrid1.RowCount := Form4.StringGrid1.RowCount + 1 ;  // add extra line to stringgrid1 ;

              Form4.StringGrid1.Objects[1,Form4.StringGrid1.RowCount-2]  :=  tPCA ; // Create spectra object
              Form4.StringGrid1.Objects[2,Form4.StringGrid1.RowCount-2]  :=  tPCA.allXData ;
              // *** THESE ARE THE RESULTS  ***  Graph and add to stringgrid1
              tPCA.allXData.interleaved := 1 ;
              tPCA.allXData.GLListNumber := Form4.GetLowestListNumber ;
              SetupallXDataAs1D_or_2D(1, tPCA.allXData , tSR) ;    // creates GLList calls: SetOpenGLXYRange() & CreateGLList()
              Form4.StringGrid1.Cells[2,Form4.StringGrid1.RowCount-2] := tPCA.allXData.ReturnRowColRangeString ;
              if tSR.fft.dt <> 0 then
                    tPCA.allXData.fft.CopyFFTObject(tSR.fft) ;

              Form4.StringGrid1.Objects[4,Form4.StringGrid1.RowCount-2] := tPCA.scoresSpectra ;
              tPCA.scoresSpectra.yCoord.Transpose ;
              tPCA.scoresSpectra.GLListNumber := Form4.GetLowestListNumber ;
              if tSR.frequencyImage then
                tPCA.scoresSpectra.nativeImage := true ;
              SetupNativeMatrixAs1D_or_2D( tPCA.scoresSpectra, tSr ) ;
              Form4.StringGrid1.Cells[4,Form4.StringGrid1.RowCount-2] := tPCA.scoresSpectra.ReturnRowColRangeString ;
              tPCA.scoresSpectra.xString := 'Sample Number' ;
              tPCA.scoresSpectra.yString := 'Score' ;
              tPCA.scoresSpectra.numImagesOrAngles := tPCA.numPCs ;


              Form4.StringGrid1.Objects[5,Form4.StringGrid1.RowCount-2] := tPCA.eigenVSpectra ;
              tPCA.eigenVSpectra.GLListNumber := Form4.GetLowestListNumber ;
              tPCA.eigenVSpectra.SetOpenGLXYRange(Form2.GetWhichLineToDisplay());
              tPCA.eigenVSpectra.CreateGLList('1-',Form1.Canvas.Handle, RC, Form2.GetWhichLineToDisplay(), 1)   ;
              Form4.StringGrid1.Cells[5,Form4.StringGrid1.RowCount-2] := tPCA.eigenVSpectra.ReturnRowColRangeString ;
              tPCA.eigenVSpectra.xString := tPCA.allXData.xString ;
              tPCA.eigenVSpectra.yString := tPCA.allXData.yString  ;
              if tSR.fft.dt <> 0 then
                    tPCA.eigenVSpectra.fft.CopyFFTObject(tSR.fft) ;

              Form4.StringGrid1.Objects[6,Form4.StringGrid1.RowCount-2] := tPCA.eigenValSpectra ;
              tPCA.eigenValSpectra.GLListNumber := Form4.GetLowestListNumber ;
              tPCA.eigenValSpectra.SetOpenGLXYRange(Form2.GetWhichLineToDisplay());
              tPCA.eigenValSpectra.CreateGLList('1-',Form1.Canvas.Handle, RC, Form2.GetWhichLineToDisplay(), 4)   ;   // 4 = lines with dots
              tPCA.eigenValSpectra.YLow :=  0 ;
              Form4.StringGrid1.Cells[6,Form4.StringGrid1.RowCount-2] := tPCA.eigenValSpectra.ReturnRowColRangeString ;
              tPCA.eigenValSpectra.xString := 'PC Number' ;
              tPCA.eigenValSpectra.yString := 'Variance' ;

              Form4.StringGrid1.Objects[7,Form4.StringGrid1.RowCount-2] := tPCA.XresidualsSpectra ;
              tPCA.XresidualsSpectra.GLListNumber := Form4.GetLowestListNumber ;
              if tSR.frequencyImage then
                tPCA.XresidualsSpectra.frequencyImage := true ;
              SetupallXDataAs1D_or_2D(1, tPCA.XresidualsSpectra , tSR) ;
              Form4.StringGrid1.Cells[7,Form4.StringGrid1.RowCount-2] := tPCA.XresidualsSpectra.ReturnRowColRangeString ;
              tPCA.XresidualsSpectra.xString := tPCA.allXData.xString ;
              tPCA.XresidualsSpectra.yString := tPCA.allXData.yString  ;
              if tSR.fft.dt <> 0 then
                    tPCA.XresidualsSpectra.fft.CopyFFTObject(tSR.fft) ;

              Form4.StringGrid1.Objects[8,Form4.StringGrid1.RowCount-2] := tPCA.regenSpectra ;
              tPCA.regenSpectra.GLListNumber := Form4.GetLowestListNumber ;
              if tSR.frequencyImage then
                tPCA.regenSpectra.frequencyImage := true ;
              SetupallXDataAs1D_or_2D(1, tPCA.regenSpectra , tSR) ;
              Form4.StringGrid1.Cells[8,Form4.StringGrid1.RowCount-2] := tPCA.regenSpectra.ReturnRowColRangeString ;
              tPCA.regenSpectra.xString := tPCA.allXData.xString ;
              tPCA.regenSpectra.yString := tPCA.allXData.yString  ;
              if tSR.fft.dt <> 0 then
                    tPCA.regenSpectra.fft.CopyFFTObject(tSR.fft) ;


              // create and return the EVects vectors ( = eigenvectors * sqrt(scores * scores') )
              tSR2 := TSpectraRanges.Create(tSR.yCoord.SDPrec div 4, 1,1,nil) ;
              tSR2.CopySpectraObject(tPCA.eigenVSpectra) ;
              tSR2.yCoord.ClearData(tSR2.yCoord.SDPrec div 4) ;
              tSR2.yCoord  := tPCA.tPCAnalysis.ReturnVectorLoadings ; ;
              Form4.StringGrid1.Objects[9,Form4.StringGrid1.RowCount-2] :=  tSR2 ;
              tSR2.GLListNumber := Form4.GetLowestListNumber ;
              tSR2.SetOpenGLXYRange(Form2.GetWhichLineToDisplay());
              tSR2.CreateGLList('1-',Form1.Canvas.Handle, RC, Form2.GetWhichLineToDisplay(), 1)   ;
              Form4.StringGrid1.Cells[9,Form4.StringGrid1.RowCount-2] := tSR2.ReturnRowColRangeString ;
              tSR2.xString := tPCA.allXData.xString ;
              tSR2.yString := tPCA.allXData.yString  ;
              if tSR.fft.dt <> 0 then
                    tSR2.fft.CopyFFTObject(tSR.fft) ;

              TSpectraRanges(Form4.StringGrid1.Objects[2,Form4.StringGrid1.RowCount-2]).columnLabel  := 'X data'     ;
              TSpectraRanges(Form4.StringGrid1.Objects[4,Form4.StringGrid1.RowCount-2]).columnLabel  := 'scores'     ;   // PCR
              TSpectraRanges(Form4.StringGrid1.Objects[5,Form4.StringGrid1.RowCount-2]).columnLabel  := 'eignevects'   ;
              TSpectraRanges(Form4.StringGrid1.Objects[6,Form4.StringGrid1.RowCount-2]).columnLabel  := 'eigenvals:' ;    // plot of variance spanned by each PC
              TSpectraRanges(Form4.StringGrid1.Objects[7,Form4.StringGrid1.RowCount-2]).columnLabel  := 'x resid.'   ;    // residual data left after subtraction of desired PC range of eigenvectors.
              TSpectraRanges(Form4.StringGrid1.Objects[8,Form4.StringGrid1.RowCount-2]).columnLabel  := 'x regen. '  ;    // regenerated data from desired set of PCs  specified
              TSpectraRanges(Form4.StringGrid1.Objects[9,Form4.StringGrid1.RowCount-2]).columnLabel  := 'loadings'   ;    // regression residual y data for each PC added. Good for outlier detection.
              //TSpectraRanges(Form4.StringGrid1.Objects[10,Form4.StringGrid1.RowCount-2]).columnLabel := 'y pred.'    ;    // plot of measured vs predicted for set of PC's specified
              //TSpectraRanges(Form4.StringGrid1.Objects[11,Form4.StringGrid1.RowCount-2]).columnLabel := 'weights:'     ;    // PCR specific
              //TSpectraRanges(Form4.StringGrid1.Objects[12,Form4.StringGrid1.RowCount-2]).columnLabel := 'reg. coef.' ;    // result of regression. Plot of Variables vs Absorbance for number of PC's specified
              //TSpectraRanges(Form4.StringGrid1.Objects[13,Form4.StringGrid1.RowCount-2]).columnLabel := 'R^2'


              Form4.StringGrid1.Cells[1,Form4.StringGrid1.RowCount-2] := ExtractFileName(tPCA.allXData.XCoord.Filename) ;

               // add batch file text to created data
              tSR := TSpectraRanges(Form4.StringGrid1.Objects[2,Form4.StringGrid1.RowCount-2]) ;
              tSR.batchList.Add('// from line: '+inttostr(Form4.StringGrid1.Row)) ;
              tSR.batchList.Add('//processing time: ' + floattostrf(tTimer.getRecordedTime,ffGeneral,5,4) + ' / ' + floattostrf(tTimer.returnCPUSpeedGHz,ffGeneral,5,4) + 'GHz') ;
              for t1 :=  initialLineNum to lineNum-1   do
              begin
                 tSR.batchList.Add(bB.GetStringFromStrList(tStrList, t1)) ;
              end ;
          end
          else if  (bB.RightSideOfEqual(tstr1) = 'auto project evects') then
          begin
              tSR  := TSpectraRanges(Form4.StringGrid1.Objects[2,Form4.StringGrid1.Row]) ;
              tSR2 := TSpectraRanges(Form4.StringGrid1.Objects[3,Form4.StringGrid1.Row]) ;

              tAutoProject := TAutoProjectEVects.Create(tSR.xCoord.SDPrec div 4) ;   // this has to be released on deletion of row or close of appliction

              lineNumStr := tAutoProject.GetPCABatchArguments(lineNum, iter, tStrList) ;
              if pos(',',lineNumStr) > 0 then
              begin
                 tAutoProject.Free ;
                 exit ;
              end
              else
              lineNum := strtoint( lineNumStr ) ;

              if not tAutoProject.GetAllXData(tAutoProject.interleaved, tSR ) then
              begin
                 tAutoProject.Free ;
                 RemoveRow('Function tAutoProject.GetAllXData() failed during data processing. Line number: '+inttostr(lineNum)) ;
                 exit ;
              end ;
              if not tAutoProject.GetFactorData(tAutoProject.interleaved, tSR2 ) then
              begin
                 tAutoProject.Free ;
                 RemoveRow('Function tAutoProject.GetFactorData() failed during data processing. Line number: '+inttostr(lineNum)) ;
                 exit ;
              end ;
              //  ****

               // GET CURRENT INTENSITY VALUE AND RED/GREEN/BLUE VALUE
              tAutoProject.allXData.LineColor := ReturnLineColor(IntensityList,1) ;
              colArray :=  tAutoProject.allXData.LineColor ;

              if  (tAutoProject.ProcessData( @colArray ) = false) then
              begin
                 tAutoProject.Free ;
                 RemoveRow('Function tAutoProject.ProcessPCAData() failed during data processing. Line number: '+inttostr(lineNum)) ;
                 exit ;
              end ;

              // ******** CREATE NEW ROW IN STRING GRID  ********
              // create new line and objects in StringGrid using CreateStringGridRowAndObjects
              Form4.StringGrid1.RowCount := Form4.StringGrid1.RowCount + 1 ;  // add extra line to stringgrid1 ;

              // *** THESE ARE THE floating point RESULTS  ***  add to stringgrid1
               // minimumSS_PCsvsFactor : single ;
               Form4.StringGrid1.Cells[9,Form4.StringGrid1.RowCount-2]  := floattostrf(tAutoProject.minimumSS_PCsvsFactor,ffGeneral,7,6) ;
               /// vectorPrefactor  : single ;
               Form4.StringGrid1.Cells[10,Form4.StringGrid1.RowCount-2]  := floattostrf(tAutoProject.vectorPrefactor,ffGeneral,7,6) ;


              // *** THESE ARE THE TSpectraRanges RESULTS  ***  Graph and add to stringgrid1
              Form4.StringGrid1.Objects[1,Form4.StringGrid1.RowCount-2]  :=  tAutoProject ; // Create spectra object
              Form4.StringGrid1.Objects[2,Form4.StringGrid1.RowCount-2]  :=  tAutoProject.allXData ;
              tAutoProject.allXData.interleaved := 1 ;
              tAutoProject.allXData.GLListNumber := Form4.GetLowestListNumber ;
              SetupallXDataAs1D_or_2D(1, tAutoProject.allXData , tSR) ;   // calls: SetOpenGLXYRange() & CreateGLList()
              Form4.StringGrid1.Cells[2,Form4.StringGrid1.RowCount-2] := tAutoProject.allXData.ReturnRowColRangeString ;
              if tSR.fft.dt <> 0 then
                    tAutoProject.allXData.fft.CopyFFTObject(tSR.fft) ;


              Form4.StringGrid1.Objects[3,Form4.StringGrid1.RowCount-2] := tAutoProject.MinimisedPCs ;
              tAutoProject.MinimisedPCs.GLListNumber := Form4.GetLowestListNumber ;
              if tSR.frequencyImage then
                tAutoProject.MinimisedPCs.nativeImage := true ;
              SetupNativeMatrixAs1D_or_2D( tAutoProject.MinimisedPCs, tSr ) ;
              Form4.StringGrid1.Cells[3,Form4.StringGrid1.RowCount-2] := tAutoProject.MinimisedPCs.ReturnRowColRangeString ;
              tAutoProject.MinimisedPCs.xString := 'Sample Number' ;
              tAutoProject.MinimisedPCs.yString := 'Score' ;
              tAutoProject.MinimisedPCs.numImagesOrAngles := tAutoProject.numPCs ;



              Form4.StringGrid1.Objects[4,Form4.StringGrid1.RowCount-2] := tAutoProject.scoresSpectra ;
              tAutoProject.scoresSpectra.yCoord.Transpose ;
              tAutoProject.scoresSpectra.GLListNumber := Form4.GetLowestListNumber ;
              if tSR.frequencyImage then
                tAutoProject.scoresSpectra.nativeImage := true ;
              SetupNativeMatrixAs1D_or_2D( tAutoProject.scoresSpectra, tSr ) ;
              Form4.StringGrid1.Cells[4,Form4.StringGrid1.RowCount-2] := tAutoProject.scoresSpectra.ReturnRowColRangeString ;
              tAutoProject.scoresSpectra.xString := 'Sample Number' ;
              tAutoProject.scoresSpectra.yString := 'Score' ;
              tAutoProject.scoresSpectra.numImagesOrAngles := tAutoProject.numPCs ;


              Form4.StringGrid1.Objects[5,Form4.StringGrid1.RowCount-2] := tAutoProject.eigenVSpectra ;
              tAutoProject.eigenVSpectra.GLListNumber := Form4.GetLowestListNumber ;
              tAutoProject.eigenVSpectra.SetOpenGLXYRange(Form2.GetWhichLineToDisplay());
              tAutoProject.eigenVSpectra.CreateGLList('1-',Form1.Canvas.Handle, RC, Form2.GetWhichLineToDisplay(), 1)   ;
              Form4.StringGrid1.Cells[5,Form4.StringGrid1.RowCount-2] := tAutoProject.eigenVSpectra.ReturnRowColRangeString ;
              tAutoProject.eigenVSpectra.xString := tAutoProject.allXData.xString ;
              tAutoProject.eigenVSpectra.yString := tAutoProject.allXData.yString  ;
              if tSR.fft.dt <> 0 then
                    tAutoProject.eigenVSpectra.fft.CopyFFTObject(tSR.fft) ;

              Form4.StringGrid1.Objects[6,Form4.StringGrid1.RowCount-2] := tAutoProject.eigenValSpectra ;
              tAutoProject.eigenValSpectra.GLListNumber := Form4.GetLowestListNumber ;
              tAutoProject.eigenValSpectra.SetOpenGLXYRange(Form2.GetWhichLineToDisplay());
              tAutoProject.eigenValSpectra.CreateGLList('1-',Form1.Canvas.Handle, RC, Form2.GetWhichLineToDisplay(), 4)   ;   // 4 = lines with dots
              tAutoProject.eigenValSpectra.YLow :=  0 ;
              Form4.StringGrid1.Cells[6,Form4.StringGrid1.RowCount-2] := tAutoProject.eigenValSpectra.ReturnRowColRangeString ;
              tAutoProject.eigenValSpectra.xString := 'PC Number' ;
              tAutoProject.eigenValSpectra.yString := 'Variance' ;

              Form4.StringGrid1.Objects[7,Form4.StringGrid1.RowCount-2] := tAutoProject.XresidualsSpectra ;
              tAutoProject.XresidualsSpectra.GLListNumber := Form4.GetLowestListNumber ;
              if tSR.frequencyImage then
                tAutoProject.XresidualsSpectra.frequencyImage := true ;
              SetupallXDataAs1D_or_2D(1, tAutoProject.XresidualsSpectra , tSR) ;
              Form4.StringGrid1.Cells[7,Form4.StringGrid1.RowCount-2] := tAutoProject.XresidualsSpectra.ReturnRowColRangeString ;
              tAutoProject.XresidualsSpectra.xString := tAutoProject.allXData.xString ;
              tAutoProject.XresidualsSpectra.yString := tAutoProject.allXData.yString  ;
              if tSR.fft.dt <> 0 then
                    tAutoProject.XresidualsSpectra.fft.CopyFFTObject(tSR.fft) ;

              Form4.StringGrid1.Objects[8,Form4.StringGrid1.RowCount-2] := tAutoProject.regenSpectra ;
              tAutoProject.regenSpectra.GLListNumber := Form4.GetLowestListNumber ;
              if tSR.frequencyImage then
                tAutoProject.regenSpectra.frequencyImage := true ;
              SetupallXDataAs1D_or_2D(1, tAutoProject.regenSpectra , tSR) ;
              Form4.StringGrid1.Cells[8,Form4.StringGrid1.RowCount-2] := tAutoProject.regenSpectra.ReturnRowColRangeString ;
              tAutoProject.regenSpectra.xString := tAutoProject.allXData.xString ;
              tAutoProject.regenSpectra.yString := tAutoProject.allXData.yString  ;
              if tSR.fft.dt <> 0 then
                    tAutoProject.regenSpectra.fft.CopyFFTObject(tSR.fft) ;

              TSpectraRanges(Form4.StringGrid1.Objects[2,Form4.StringGrid1.RowCount-2]).columnLabel  := 'X data'     ;   // PCR
              TSpectraRanges(Form4.StringGrid1.Objects[3,Form4.StringGrid1.RowCount-2]).columnLabel  := 'min. PCs'   ;
              TSpectraRanges(Form4.StringGrid1.Objects[4,Form4.StringGrid1.RowCount-2]).columnLabel  := 'scores'     ;   // PCR
              TSpectraRanges(Form4.StringGrid1.Objects[5,Form4.StringGrid1.RowCount-2]).columnLabel  := 'eignevects'   ;
              TSpectraRanges(Form4.StringGrid1.Objects[6,Form4.StringGrid1.RowCount-2]).columnLabel  := 'eigenvals:' ;    // plot of variance spanned by each PC
              TSpectraRanges(Form4.StringGrid1.Objects[7,Form4.StringGrid1.RowCount-2]).columnLabel  := 'x resid.'   ;    // residual data left after subtraction of desired PC range of eigenvectors.
              TSpectraRanges(Form4.StringGrid1.Objects[8,Form4.StringGrid1.RowCount-2]).columnLabel  := 'x regen. '  ;    // regenerated data from desired set of PCs  specified




              Form4.StringGrid1.Cells[1,Form4.StringGrid1.RowCount-2] := ExtractFileName(tAutoProject.allXData.XCoord.Filename) ;

               // add batch file text to created data
              tSR := TSpectraRanges(Form4.StringGrid1.Objects[2,Form4.StringGrid1.RowCount-2]) ;
              tSR.batchList.Add('// from line: '+inttostr(Form4.StringGrid1.Row)) ;
              for t1 :=  initialLineNum to lineNum-1   do
              begin
                 tSR.batchList.Add(bB.GetStringFromStrList(tStrList, t1)) ;
              end ;
          end
          else
          if (bB.RightSideOfEqual(tstr1) = 'correl2d') then
          begin
              tSR := TSpectraRanges(Form4.StringGrid1.Objects[2,Form4.StringGrid1.Row]) ;

              t2DCorrel := T2DCorrelation.Create(tSR.xCoord.SDPrec div 4)  ;   // this has to be freed on deletion of row or close of appliction
              lineNum := t2DCorrel.Get2DCorrelBatchArguments(lineNum, iter, tStrList) ;

              // ******** ALLWAYS CREATE NEW ROW IN STRING GRID  ********
              // create new line and objects in StringGrid using CreateStringGridRowAndObjects
              CreateStringGridRowAndObjects2( t2DCorrel ) ;

              colArray :=  TSpectraRanges(Form4.StringGrid1.Objects[2,Form4.StringGrid1.RowCount-2]).LineColor ;

              if  (t2DCorrel.GetAllXData( tSR ) = false ) then
              begin
                t2DCorrel.Free ;
                 RemoveRow('Function T2DCorrelation.GetAllXData() failed during data processing. Line number: '+inttostr(lineNum)) ;
                 exit ;
              end ;
              // **** do 2D IR correlation - store results in t2DCorrel object ****
              if  (t2DCorrel.Process2DCorrelData( @colArray ) = false) then
              begin
              //   t2DCorrel.Free ;
              //   RemoveRow('Function T2DCorrelation.GetAllXData() failed during data processing. Line number: '+inttostr(lineNum)) ;
              //   exit ;
              end ;

              // *** THESE ARE THE RESULTS  ***  Add graph them and add to stringgrid1
              t2DCorrel.allXData.SetOpenGLXYRange(Form2.GetWhichLineToDisplay()) ;
              t2DCorrel.allXData.CreateGLList('1-',Form1.Canvas.Handle, RC, Form2.GetWhichLineToDisplay(),  1)   ;
              Form4.StringGrid1.Cells[2,Form4.StringGrid1.RowCount-2] := '1-'+ inttostr(t2DCorrel.allXData.yCoord.numRows) +' : 1-' + inttostr(t2DCorrel.allXData.yCoord.numCols) ;

              Form4.StringGrid1.Objects[5,Form4.StringGrid1.RowCount-2] := t2DCorrel.wwSynchronous ;
              t2DCorrel.wwSynchronous.GLListNumber := Form4.GetLowestListNumber ;
              t2DCorrel.wwSynchronous.SetOpenGLXYRange(Form2.GetWhichLineToDisplay()) ;
              t2DCorrel.wwSynchronous.CreateGLList('1-',Form1.Canvas.Handle, RC, Form2.GetWhichLineToDisplay(),  9)   ;
              t2DCorrel.wwSynchronous.YHigh := t2DCorrel.wwSynchronous.XHigh ;
              t2DCorrel.wwSynchronous.YLow  := t2DCorrel.wwSynchronous.XLow  ;
              Form4.StringGrid1.Cells[5,Form4.StringGrid1.RowCount-2] := '1-'+ inttostr(t2DCorrel.wwSynchronous.yCoord.numRows) +' : 1-' + inttostr(t2DCorrel.wwSynchronous.yCoord.numCols) ;
              t2DCorrel.wwSynchronous.xString := t2DCorrel.allXData.xString ;
              t2DCorrel.wwSynchronous.yString := t2DCorrel.allXData.xString ;

              Form4.StringGrid1.Objects[6,Form4.StringGrid1.RowCount-2] := t2DCorrel.wwAsynchronous ;
              t2DCorrel.wwAsynchronous.GLListNumber := Form4.GetLowestListNumber ;
              t2DCorrel.wwAsynchronous.SetOpenGLXYRange(Form2.GetWhichLineToDisplay()) ;
              t2DCorrel.wwAsynchronous.CreateGLList('1-',Form1.Canvas.Handle, RC, Form2.GetWhichLineToDisplay(),  9)   ;
              t2DCorrel.wwAsynchronous.YHigh := t2DCorrel.wwAsynchronous.XHigh ;
              t2DCorrel.wwAsynchronous.YLow  := t2DCorrel.wwAsynchronous.XLow  ;
              Form4.StringGrid1.Cells[6,Form4.StringGrid1.RowCount-2] := '1-'+ inttostr(t2DCorrel.wwAsynchronous.yCoord.numRows) +' : 1-' + inttostr(t2DCorrel.wwAsynchronous.yCoord.numCols) ;
              t2DCorrel.wwAsynchronous.xString := t2DCorrel.allXData.xString ;
              t2DCorrel.wwAsynchronous.yString := t2DCorrel.allXData.xString ;

               Form4.StringGrid1.Objects[7,Form4.StringGrid1.RowCount-2] := t2DCorrel.ssSynchronous ;
              t2DCorrel.ssSynchronous.GLListNumber := Form4.GetLowestListNumber ;
              t2DCorrel.ssSynchronous.SetOpenGLXYRange(Form2.GetWhichLineToDisplay()) ;
              t2DCorrel.ssSynchronous.CreateGLList('1-',Form1.Canvas.Handle, RC, Form2.GetWhichLineToDisplay(),  1)   ;
              Form4.StringGrid1.Cells[7,Form4.StringGrid1.RowCount-2] := '1-'+ inttostr(t2DCorrel.ssSynchronous.yCoord.numRows) +' : 1-' + inttostr(t2DCorrel.ssSynchronous.yCoord.numCols) ;
              t2DCorrel.ssSynchronous.xString := 'Sample' ;
              t2DCorrel.ssSynchronous.yString := 'Sample' ;

               Form4.StringGrid1.Objects[8,Form4.StringGrid1.RowCount-2] := t2DCorrel.ssAsynchronous ;
              t2DCorrel.ssAsynchronous.GLListNumber := Form4.GetLowestListNumber ;
              t2DCorrel.ssAsynchronous.SetOpenGLXYRange(Form2.GetWhichLineToDisplay()) ;
              t2DCorrel.ssAsynchronous.CreateGLList('1-',Form1.Canvas.Handle, RC, Form2.GetWhichLineToDisplay(),  1)   ;
              Form4.StringGrid1.Cells[8,Form4.StringGrid1.RowCount-2] := '1-'+ inttostr(t2DCorrel.ssAsynchronous.yCoord.numRows) +' : 1-' + inttostr(t2DCorrel.ssAsynchronous.yCoord.numCols) ;
              t2DCorrel.ssAsynchronous.xString := 'Sample' ;
              t2DCorrel.ssAsynchronous.yString := 'Sample' ;

              TSpectraRanges(Form4.StringGrid1.Objects[4,Form4.StringGrid1.RowCount-2]).columnLabel  := 'scores'     ;   // PCR
              TSpectraRanges(Form4.StringGrid1.Objects[5,Form4.StringGrid1.RowCount-2]).columnLabel  := 'wwSynchronous'   ;
              TSpectraRanges(Form4.StringGrid1.Objects[6,Form4.StringGrid1.RowCount-2]).columnLabel  := 'wwAsynchronous:' ;    // plot of variance spanned by each PC
              TSpectraRanges(Form4.StringGrid1.Objects[7,Form4.StringGrid1.RowCount-2]).columnLabel  := 'ssSynchronous.'   ;    // residual data left after subtraction of desired PC range of eigenvectors.
              TSpectraRanges(Form4.StringGrid1.Objects[8,Form4.StringGrid1.RowCount-2]).columnLabel  := 'ssAsynchronous '  ;    // regenerated data from desired set of PCs  specified



              Form4.StringGrid1.Cells[1,Form4.StringGrid1.RowCount-2] := ExtractFileName(t2DCorrel.allXData.XCoord.Filename) ;      // plot of measured vs predicted for number of PC's specified

               // add batch file text to created data
              tSR := TSpectraRanges(Form4.StringGrid1.Objects[2,Form4.StringGrid1.RowCount-2]) ;
              tSR.batchList.Add('// from line: '+inttostr(Form4.StringGrid1.Row)) ;
              for t1 :=  initialLineNum to lineNum -1  do
              begin
                 tSR.batchList.Add(bB.GetStringFromStrList(tStrList, t1)) ;
              end ;
           end
           else
           if (bB.RightSideOfEqual(tstr1) = 'regen from pcs') then
           begin
              if Form4.StringGrid1.Objects[1,Form4.StringGrid1.Row] is TBatchMVA then
              begin
                  // ********************** load number of PCs to regenerate data from ******************************************
                  repeat
                    inc(lineNum) ;
                    tstr1 := bB.GetStringFromStrList(tStrList, lineNum) ;
                  until (trim(tstr1) <> '') or (linenum > tStrList.Count)  ;
                  if bB.LeftSideOfEqual(tstr1) = 'pcs for regeneration' then
                    PCStr :=  bB.RightSideOfEqual(tstr1) ;
                  // ********************** Mean Centre ******************************************
                  repeat
                    inc(lineNum) ;
                    tstr1 := bB.GetStringFromStrList(tStrList, lineNum) ;
                  until (trim(tstr1) <> '') or (linenum > tStrList.Count)  ;
                  if bB.LeftSideOfEqual(tstr1) = 'mean centred' then
                  begin
                    if bB.RightSideOfEqual(tstr1) = 'true'  then
                       meanCentreBool := true
                    else
                       meanCentreBool :=  false ;
                  end ;



                  if Form4.StringGrid1.Objects[1,Form4.StringGrid1.Row] is TPCABatch then
                  begin
                    tPCA := TPCABatch(Form4.StringGrid1.Objects[1,Form4.StringGrid1.Row]) ;
                    tPCA.tPCAnalysis.RegenerateData( PCStr ,'1-'+inttostr(tPCA.tPCAnalysis.EVects.numCols),meanCentreBool,tPCA.tPCAnalysis.XResiduals.F_MAverage)  ;
                    tPCA.tPCAnalysis.CalcResidualData( meanCentreBool ) ;

                    tPCA.regenSpectra.yCoord.CopyMatrix(tPCA.tPCAnalysis.RegenMatrix)  ;
                   if tPCA.regenSpectra.frequencyImage then
                      tPCA.regenSpectra.frequencyImage := true ;
                   SetupallXDataAs1D_or_2D(1, tPCA.regenSpectra , tPCA.regenSpectra) ;
                   tPCA.regenSpectra.xString := tPCA.allXData.xString ;
                   tPCA.regenSpectra.yString := tPCA.allXData.yString  ;

                   tPCA.XresidualsSpectra.yCoord.CopyMatrix(tPCA.tPCAnalysis.XResiduals )  ;
                   if tPCA.XresidualsSpectra.frequencyImage then
                     tPCA.XresidualsSpectra.frequencyImage := true ;
                   SetupallXDataAs1D_or_2D(1, tPCA.XresidualsSpectra , tPCA.XresidualsSpectra) ;
                   tPCA.XresidualsSpectra.xString := tPCA.allXData.xString ;
                   tPCA.XresidualsSpectra.yString := tPCA.allXData.yString  ;
                 end
                 else
                 if Form4.StringGrid1.Objects[1,Form4.StringGrid1.Row] is TPLSYPredictBatch then
                 begin
                    tPLS := TPLSYPredictBatch(Form4.StringGrid1.Objects[1,Form4.StringGrid1.Row]) ;
                    tPLS.PLSResultsObject.RegenerateData( PCStr ,'1-'+inttostr(tPLS.PLSResultsObject.XEVects.numCols),meanCentreBool,tPLS.PLSResultsObject.XResiduals.F_MAverage)  ;
                    tPLS.PLSResultsObject.CalcResidualData( meanCentreBool ) ;

                    tPLS.regenSpectra.yCoord.CopyMatrix(tPLS.PLSResultsObject.XRegenMatrix)  ;
                   if tPLS.regenSpectra.frequencyImage then
                      tPLS.regenSpectra.frequencyImage := true ;
                   SetupallXDataAs1D_or_2D(1, tPLS.regenSpectra , tPLS.regenSpectra) ;
                   tPLS.regenSpectra.xString := tPLS.allXData.xString ;
                   tPLS.regenSpectra.yString := tPLS.allXData.yString  ;

                   tPLS.XresidualsSpectra.yCoord.CopyMatrix(tPLS.PLSResultsObject.XResiduals )  ;
                   if tPLS.XresidualsSpectra.frequencyImage then
                     tPLS.XresidualsSpectra.frequencyImage := true ;
                   SetupallXDataAs1D_or_2D(1, tPLS.XresidualsSpectra , tPLS.XresidualsSpectra) ;
                   tPLS.XresidualsSpectra.xString := tPLS.allXData.xString ;
                   tPLS.XresidualsSpectra.yString := tPLS.allXData.yString  ;
                 end
                 else
                 if Form4.StringGrid1.Objects[1,Form4.StringGrid1.Row] is TPCRYPredictBatch then
                 begin

                 end ;

              end
              else
              begin
                 lineNum := lineNum + 1 ;


              end ;
           end
           else
           begin
            lineNum := lineNum + 1 ;

           end ;
       end
       else
       if trim(lowerCase(tstr1)) = 'next' then
       begin
          selectNextCellBool := true ;
          Form4.StringGrid1.Row :=  Form4.StringGrid1.Row + 1 ;
         // Form4.StringGrid1Click(  nil ) ;
          Form4.StringGrid1.OnSelectCell(Form3,2,Form4.StringGrid1.Row,selectNextCellBool) ;

          tStrList.Clear ;
          tStrList.AddStrings( BatchMemo1.Lines ) ; // Copy what is in memo1 into a temporary text list
          lineNum := 0 ;
          iter := 0 ;
       end
       else  // the text is not recognised as any particular directive
       begin
          lineNum := lineNum + 1 ;
       end ;
     end ;
  finally
   tTimer.Free ;
   bB.Free ;
   tStrList.Free ;
  end ;
end;






function TForm3.SetupNativeMatrixAs1D_or_2D( scoresSpectra : TSpectraRanges ; tSR : TSpectraRanges) : boolean  ;
var
  t1, t2 : integer ;
  s1 : single ;
  TempXY : array[0..1] of single ;
begin

  if scoresSpectra.nativeImage then
  begin
     // Most commonly used to read in scores data from image PCA etc, where each spectra has a score for each PC along a single row
     scoresSpectra.xPix       := tSR.xPix       ;
     scoresSpectra.yPix       := tSR.yPix       ;
     scoresSpectra.xPixSpacing := tSR.xPixSpacing ;
     scoresSpectra.yPixSpacing := tSR.yPixSpacing ;
     scoresSpectra.interleaved := 1 ;

     if  scoresSpectra.image2DSpecR = nil then
     begin
       scoresSpectra.image2DSpecR := TSpectraRanges.Create(tSR.yCoord.SDPrec div 4,scoresSpectra.yPix,scoresSpectra.xPix,@tSR.LineColor) ;
       scoresSpectra.image2DSpecR.GLListNumber :=  scoresSpectra.GLListNumber ;
     end ;
       scoresSpectra.currentSlice :=  1 ;

     // create xCoord data
     scoresSpectra.image2DSpecR.xCoord.F_Mdata.Seek(0,soFromBeginning) ;
     for t1 := 0 to scoresSpectra.xPix -1 do
     begin
       s1 :=  t1 * scoresSpectra.xPixSpacing ;
       scoresSpectra.image2DSpecR.xCoord.F_Mdata.Write(s1,4) ;
     end ;

//     imageOffset := 1 ;

     scoresSpectra.image2DSpecR.xPix       := tSR.xPix       ;
     scoresSpectra.image2DSpecR.yPix       := tSR.yPix       ;
     scoresSpectra.image2DSpecR.xPixSpacing := tSR.xPixSpacing ;
     scoresSpectra.image2DSpecR.yPixSpacing := tSR.yPixSpacing ;

     scoresSpectra.image2DSpecR.yCoord.F_Mdata.Seek(0,soFromBeginning) ;
     scoresSpectra.yCoord.F_Mdata.Seek(0,soFromBeginning) ;
     // select data from main spectra (single wavelength)
     for t1 := 1 to (scoresSpectra.yPix*scoresSpectra.xPix) do
     begin
         scoresSpectra.Read_YrYi_Data(t1,1,@TempXY,false) ;
         scoresSpectra.image2DSpecR.Write_YrYi_Data(t1,1,@TempXY,false) ;
     end ;

     scoresSpectra.image2DSpecR.SetOpenGLXYRange(Form2.GetWhichLineToDisplay()) ;
     scoresSpectra.XHigh :=  scoresSpectra.image2DSpecR.XHigh + scoresSpectra.xPixSpacing ;// scoresSpectra.image2DSpecR.XHigh ;
     scoresSpectra.XLow :=  scoresSpectra.image2DSpecR.XLow ;
     scoresSpectra.YHigh :=  (scoresSpectra.yPix) * scoresSpectra.yPixSpacing  ;    // need to spread the image out in the Y direction as much as in X direction
     scoresSpectra.YLow :=  0 ;
//     if not Form2.NoImageCB1.Checked then   // if this CB is not checked then creat the GLlist display image of data
       scoresSpectra.image2DSpecR.CreateGLList('1-',Form1.Canvas.Handle, RC, Form2.GetWhichLineToDisplay(), 9) ;
     // SpectObj.YHigh & SpectObj.YLow should be saved to optimise contrast in the 2D image   Solution: they are stored in SpectObj.image2DSpecR.YHigh and YLow
  end
  else
  begin
     scoresSpectra.SetOpenGLXYRange(Form2.GetWhichLineToDisplay()) ;
     scoresSpectra.CreateGLList('1-',Form1.Canvas.Handle, RC, Form2.GetWhichLineToDisplay(),  4)   ;  //
  end ;
  result := true ;

end ;

function TForm3.SetupallXDataAs1D_or_2D(numImages : integer ; allXDataIn : TSpectraRanges ; tSr : TSpectraRanges) : boolean  ;
var
  t1, t2 : integer ;
  s1 : single ;
  TempXY : array[0..1] of single ;
begin
              result := false ;
              if (tSR.xPix > 1) and  (tSR.yPix > 1)  then  // original data is 2D data
              begin
                allXDataIn.xPix :=  tSR.xPix ;
                allXDataIn.yPix :=  tSR.yPix ;
                allXDataIn.xPixSpacing :=  tSR.xPixSpacing ;
                allXDataIn.yPixSpacing :=  tSR.yPixSpacing ;
                allXDataIn.numImagesOrAngles :=   numImages;   // numImages = IRPol.numAngles or = NumPCs if TPCABatch

                allXDataIn.image2DSpecR := TSpectraRanges.Create(allXDataIn.yCoord.SDPrec div 4,allXDataIn.yPix,allXDataIn.xPix,@allXDataIn.LineColor) ;
                allXDataIn.image2DSpecR.GLListNumber :=  allXDataIn.GLListNumber ;

                allXDataIn.currentSlice :=   allXDataIn.yCoord.numCols div 2 ;  ;
                Form2.FrequencySlider1.Max :=  allXDataIn.yCoord.numCols ;
                Form2.FrequencySlider1.Position :=  allXDataIn.currentSlice ;

                // create xCoord data
                allXDataIn.image2DSpecR.xCoord.F_Mdata.Seek(0,soFromBeginning) ;
                for t1 := 0 to allXDataIn.xPix -1 do
                begin
                  s1 :=  t1 * allXDataIn.xPixSpacing ;
                  allXDataIn.image2DSpecR.xCoord.F_Mdata.Write(s1,4) ;
                end ;

                // select data from main spectra (single wavelength or native 2D image block)
                allXDataIn.CopyDataTo2DSpecR ;

                allXDataIn.image2DSpecR.SetOpenGLXYRange(Form2.GetWhichLineToDisplay()) ;
                allXDataIn.xHigh :=  allXDataIn.image2DSpecR.XHigh + allXDataIn.xPixSpacing ;// was: allXDataIn.image2DSpecR.xHigh ; - not wide enough
                allXDataIn.xLow  :=  allXDataIn.image2DSpecR.xLow ;

                allXDataIn.zHigh :=  allXDataIn.image2DSpecR.yHigh  ;
                allXDataIn.zLow :=   allXDataIn.image2DSpecR.yLow  ;

                allXDataIn.yHigh :=  (allXDataIn.yPix) * allXDataIn.yPixSpacing  ;    // need to spread the image out in the Y direction as much as in X direction
                allXDataIn.yLow  :=  0 ;                                       // SpectObj.YHigh & SpectObj.YLow should be saved to optimise contrast in the 2D image   Solution: they are stored in SpectObj.image2DSpecR.YHigh and YLow

                allXDataIn.image2DSpecR.xPix := allXDataIn.xPix  ;
                allXDataIn.image2DSpecR.yPix := allXDataIn.yPix  ;
                allXDataIn.image2DSpecR.xPixSpacing := allXDataIn.xPixSpacing ;
                allXDataIn.image2DSpecR.yPixSpacing := allXDataIn.yPixSpacing ;


                allXDataIn.image2DSpecR.CreateGLList('1-',Form1.Canvas.Handle, RC, Form2.GetWhichLineToDisplay(), 9) ;


                // Get Max, Min and current frequency (x coordinate values)
                allXDataIn.xCoord.F_Mdata.Seek(0,soFromBeginning) ;
                allXDataIn.xCoord.F_Mdata.Read(s1,4) ;
                Form2.Label47.Caption := floattostrF(s1,ffGeneral,5,3 ) ;  // Max
                allXDataIn.xCoord.F_Mdata.Seek(-4,soFromEnd) ;
                allXDataIn.xCoord.F_Mdata.Read(s1,4) ;
                Form2.Label48.Caption := floattostrF(s1,ffGeneral,5,3 ) ; // Min
                allXDataIn.xCoord.F_Mdata.Seek((allXDataIn.xCoord.SDPrec * allXDataIn.currentSlice )-allXDataIn.xCoord.SDPrec,soFromBeginning) ;
                allXDataIn.xCoord.F_Mdata.Read(s1,4) ;
                Form2.imageSliceValEB.Text  := floattostrF(s1,ffGeneral,5,3 ) ;
                allXDataIn.frequencyImage := true ;
              end
              else
              begin
                allXDataIn.SetOpenGLXYRange(Form2.GetWhichLineToDisplay()) ;
                allXDataIn.zHigh :=  0 ;
                allXDataIn.zLow :=   0  ;
                if (allXDataIn.lineType > MAXDISPLAYTYPEFORSPECTRA) or (allXDataIn.lineType < 1)  then allXDataIn.lineType := 1 ;  //
                allXDataIn.CreateGLList('1-',Form1.Canvas.Handle, RC, Form2.GetWhichLineToDisplay(),  allXDataIn.lineType )   ;
              end ;
              result := true ;

end ;



procedure TForm3.RemoveRow( messasge : string ) ;
var
  lineNum : integer ;
begin
  lineNum := Form4.StringGrid1.RowCount-2 ;
  // Remove objects
  Form4.StringGrid1.Objects[1,lineNum]   :=  nil ;
  Form4.StringGrid1.Objects[2,lineNum]   :=  nil ;
  Form4.StringGrid1.Objects[3,lineNum]   :=  nil ;
  Form4.StringGrid1.Objects[4,lineNum]   :=  nil ;
  Form4.StringGrid1.Objects[5,lineNum]   :=  nil ;
  Form4.StringGrid1.Objects[6,lineNum]   :=  nil ;
  Form4.StringGrid1.Objects[7,lineNum]   :=  nil ;
  Form4.StringGrid1.Objects[8,lineNum]   :=  nil ;
  Form4.StringGrid1.Objects[9,lineNum]   :=  nil ;
  Form4.StringGrid1.Objects[10,lineNum]  :=  nil ;
  Form4.StringGrid1.Objects[11,lineNum]  :=  nil ;
  Form4.StringGrid1.Objects[12,lineNum]  :=  nil ;
  Form4.StringGrid1.Objects[13,lineNum]  :=  nil ;
  // Remove strings from cells
  Form4.StringGrid1.Cells[1,lineNum]   :=  '' ;
  Form4.StringGrid1.Cells[2,lineNum]   :=  '' ;
  Form4.StringGrid1.Cells[3,lineNum]   :=  '' ;
  Form4.StringGrid1.Cells[4,lineNum]   :=  '' ;
  Form4.StringGrid1.Cells[5,lineNum]   :=  '' ;
  Form4.StringGrid1.Cells[6,lineNum]   :=  '' ;
  Form4.StringGrid1.Cells[7,lineNum]   :=  '' ;
  Form4.StringGrid1.Cells[8,lineNum]   :=  '' ;
  Form4.StringGrid1.Cells[9,lineNum]   :=  '' ;
  Form4.StringGrid1.Cells[10,lineNum]  :=  '' ;
  Form4.StringGrid1.Cells[11,lineNum]  :=  '' ;
  Form4.StringGrid1.Cells[12,lineNum]  :=  '' ;
  Form4.StringGrid1.Cells[13,lineNum]  :=  '' ;

  Form4.StringGrid1.RowCount := Form4.StringGrid1.RowCount - 1 ;  // remove line from stringgrid1 ;
  Form4.StatusBar1.Panels[0].Text :=  messasge ;
  //messagedlg(messasge ,mtError,[mbOK],0) ;
end ;



function TForm3.ReturnLineColor(IntensityListIn : TStringList; numBlankLines : integer  ) : TGLLineColor ;
var
      t1, stringNum : integer ;
      tStr : string ;
begin
     // loop through colours availale
     stringNum := Form4.StringGrid1.RowCount - numBlankLines  ;  // -1 if called beore addLineToStringGrid or -2 if called after
     while  stringNum >= IntensityList.Count do
       stringNum :=  stringNum - IntensityList.Count ;

    // IntensityListIn is a list of strings of format  "0.0 1.0 0.5 n"
    // stringNum is the current string of interest
    // Returns a red:green:blue floating point array
    try
        tStr := IntensityListIn.Strings[stringNum] ;
        tStr := TrimLeft(copy(tStr,Pos(' ',tStr)+1,Length(tStr))) ;
       // tStr := TrimLeft(tStr) ;
        t1 := Pos(' ', tStr) ;
        result[0] := StrToFloat(copy(tStr,1,t1-1)) ;
        tStr := copy(tStr,t1+1,Length(tStr)) ;
        tStr := TrimLeft(tStr) ;
        t1 := Pos(' ', tStr) ;
        result[1] := StrToFloat(copy(tStr,1,t1-1)) ;
        tStr := copy(tStr,t1+1,Length(tStr)) ;
        tStr := TrimLeft(tStr) ;
        t1 := Pos(' ', tStr) ;
        result[2] := StrToFloat(copy(tStr,1,t1-1)) ;
   except
   on eConvertError do
   begin
      result[0] := 0.0 ;
      result[1] := 0.0 ;
      result[2] := 0.0 ;
   end ;
   end ;
end ;



procedure TForm3.CreateStringGridRowAndObjects8(objectForCellRow1 : TSpectraRanges) ;
// SGRowIn is the row the analysis was described in
// Used when new line has to be produced...
//       i.e. 1/ When not all samples are being used from the source matrix (X Data column)
var
  stringNum, t1 : integer ;
   tStr : string ;
begin
  With Form4.StringGrid1 Do
    begin
        Form4.StringGrid1.RowCount := Form4.StringGrid1.RowCount + 1 ;  // add extra line to stringgrid1 ;

        objectForCellRow1.LineColor := ReturnLineColor(IntensityList, 2)  ;
        Objects[2,Form4.StringGrid1.RowCount-2]  :=  objectForCellRow1 ;
    end ;
end ;



procedure TForm3.CreateStringGridRowAndObjects7(objectForCellRow1 : TPCRYPredictBatch) ;
// SGRowIn is the row the analysis was described in
// Used when new line has to be produced...
//       i.e. 1/ When not all samples are being used from the source matrix (X Data column)
var
  stringNum, t1 : integer ;
   tStr : string ;
begin
  With Form4.StringGrid1 Do
    begin
        Form4.StringGrid1.RowCount := Form4.StringGrid1.RowCount + 1 ;  // add extra line to stringgrid1 ;

        // copy line colour to PLS batch object
        objectForCellRow1.LineColor := ReturnLineColor(IntensityList, 2)  ;

        Objects[1,Form4.StringGrid1.RowCount-2]  :=  objectForCellRow1 ; // Create spectra object
        Objects[2,Form4.StringGrid1.RowCount-2]  :=  objectForCellRow1.allXData ;
        Objects[3,Form4.StringGrid1.RowCount-2]  :=  objectForCellRow1.allYData ;
    end ;
end ;


procedure TForm3.CreateStringGridRowAndObjects6(objectForCellRow1 : TPLSYPredictBatch) ;
// SGRowIn is the row the analysis was described in
// Used when new line has to be produced...
//       i.e. 1/ When not all samples are being used from the source matrix (X Data column)
var
  stringNum, t1 : integer ;
   tStr : string ;
begin
  With Form4.StringGrid1 Do
    begin
        Form4.StringGrid1.RowCount := Form4.StringGrid1.RowCount + 1 ;  // add extra line to stringgrid1 ;

        objectForCellRow1.LineColor := ReturnLineColor(IntensityList, 2)  ;

        Objects[1,Form4.StringGrid1.RowCount-2]  :=  objectForCellRow1 ; // Create spectra object
        Objects[2,Form4.StringGrid1.RowCount-2]  :=  objectForCellRow1.allXData ;
        Objects[3,Form4.StringGrid1.RowCount-2]  :=  objectForCellRow1.allYData ;
    end ;
end ;



function TForm3.CreateStringGridRowAndObjects5( objectForCellRow1 : TDichroicRatio ) : TGLLineColor ;
var
  stringNum, t1 : integer ;
   LineColor : TGLLineColor ;
   tStr : string ;
begin
  With Form4.StringGrid1 Do
    begin
        Form4.StringGrid1.RowCount := Form4.StringGrid1.RowCount + 1 ;  // add extra line to stringgrid1 ;

        objectForCellRow1.allXData.GLListNumber := Form4.GetLowestListNumber ; // gets lowest GLListNumber
        objectForCellRow1.allXData.LineColor := ReturnLineColor(IntensityList, 2)  ;

        Objects[1,Form4.StringGrid1.RowCount-2]  :=  objectForCellRow1 ; // Create spectra object
        Objects[2,Form4.StringGrid1.RowCount-2]  :=  objectForCellRow1.allXData ;

    end ;
end ;


procedure TForm3.CreateStringGridRowAndObjects4(objectForCellRow1 : TPLMAnalysis) ;
// SGRowIn is the row the analysis was described in
// Used when new line has to be produced...
//       i.e. 1/ When not all samples are being used from the source matrix (X Data column)
//            2/ When TRegression object has already been produced in row where all samples are used from source X Data
var
  stringNum, t1 : integer ;
   LineColor : TGLLineColor ;
   tStr : string ;
begin
  With Form4.StringGrid1 Do
    begin
        Form4.StringGrid1.RowCount := Form4.StringGrid1.RowCount + 1 ;  // add extra line to stringgrid1 ;

        // GET CURRENT INTENSITY VALUE AND RED/GREEN/BLUE VALUE
        objectForCellRow1.allXData.LineColor := ReturnLineColor(IntensityList, 2)  ; ;

        t1 := Form4.GetLowestListNumber ; // gets lowest GLListNumber
        objectForCellRow1.allXData.GLListNumber := t1 ;

        Objects[1,Form4.StringGrid1.RowCount-2]  :=  objectForCellRow1 ; // Create spectra object
        Objects[2,Form4.StringGrid1.RowCount-2]  :=  objectForCellRow1.allXData ;
    end ;
end ;


function TForm3.CreateStringGridRowAndObjects3( ) : TGLLineColor ;
var
  stringNum, t1 : integer ;
   LineColor : TGLLineColor ;
   tStr : string ;
begin
  With Form4.StringGrid1 Do
    begin
        Form4.StringGrid1.RowCount := Form4.StringGrid1.RowCount + 1 ;  // add extra line to stringgrid1 ;

        // GET CURRENT INTENSITY VALUE AND RED/GREEN/BLUE VALUE
        result := ReturnLineColor(IntensityList, 2)   ;
    end ;
end ;

procedure TForm3.CreateStringGridRowAndObjects2( correlObj : T2DCorrelation ) ;
var
  stringNum, t1 : integer ;
   LineColor : TGLLineColor ;
   tStr : string ;
begin
  With Form4.StringGrid1 Do
    begin
        Form4.StringGrid1.RowCount := Form4.StringGrid1.RowCount + 1 ;  // add extra line to stringgrid1 ;

        // GET CURRENT INTENSITY VALUE AND RED/GREEN/BLUE VALUE
        correlObj.allXData.LineColor := ReturnLineColor(IntensityList, 2)  ; ;

        t1 := Form4.GetLowestListNumber ; // gets lowest GLListNumber
        correlObj.allXData.GLListNumber := t1 ;

        Objects[1,Form4.StringGrid1.RowCount-2]  :=  correlObj ; // Create spectra object
        Objects[2,Form4.StringGrid1.RowCount-2]  :=  correlObj.allXData ;
    end ;
end ;




procedure TForm3.normalisedoutput1Click(Sender: TObject);
begin
BatchFileModDlg.Label1.Caption := 'normalised output =' ;
BatchFileModDlg.Edit1.Text := 'true' ;
BatchFileModDlg.Visible := true ;
end;

procedure TForm3.pixelspacing1Click(Sender: TObject);
begin
BatchFileModDlg.Label1.Caption := 'pixel spacing =' ;
BatchFileModDlg.Edit1.Text := '75' ;
BatchFileModDlg.Visible := true ;
end;

procedure TForm3.bonetosurface1Click(Sender: TObject);
begin
BatchFileModDlg.Label1.Caption := 'bone to surface =' ;
BatchFileModDlg.Edit1.Text := 'true' ;
BatchFileModDlg.Visible := true ;
end;



procedure TForm3.posornegativesection1Click(Sender: TObject);
begin  
  BatchFileModDlg.Label1.Caption := 'pos or neg range =' ;
  BatchFileModDlg.Edit1.Text := '1200-1260 cm-1' ;
  BatchFileModDlg.Visible := true ;
end;

procedure TForm3.posorneg1Click(Sender: TObject);
begin
  BatchFileModDlg.Label1.Caption := 'positive or negative =' ;
  BatchFileModDlg.Edit1.Text := 'negative' ;
  BatchFileModDlg.Visible := true ;
end;

procedure TForm3.TemplateAreaRatio2Click(Sender: TObject);
begin
   BatchMemo1.Lines.Add('type = AREA RATIO  // ratios two band areas (peak1 / peak2)') ;
   BatchMemo1.Lines.Add('sample range = 1-') ;
   BatchMemo1.Lines.Add('number of x positions = 17') ;
   BatchMemo1.Lines.Add('number of y positions = 1') ;
   BatchMemo1.Lines.Add('peak1 range = 1620-1690 cm-1  // can be variable number or value found in x coordinate (space essential between value and units) ') ;
   BatchMemo1.Lines.Add('peak2 range = 1520-1580 cm-1  // can be variable number or value found in x coordinate (space essential between value and units) ') ;
   BatchMemo1.Lines.Add('pixel spacing x = 75  // distance between pixels') ;
   BatchMemo1.Lines.Add('pixel spacing y = 75  // distance between pixels') ;
   BatchMemo1.Lines.Add('bone to surface = true  // distance between pixels') ;
   BatchMemo1.Lines.Add('actual depth = 0  // depth in mm') ;
   BatchMemo1.Lines.Add('normalise depth = false  // 1') ;
   BatchMemo1.Lines.Add('results file = area_ratio.out') ;
   BatchMemo1.Lines.Add('') ;
end;

procedure TForm3.TemplatePCAReconstruct2Click(Sender: TObject);
begin
   BatchMemo1.Lines.Add('type = REGEN FROM PCS  // regenerate data from desired PCs') ;
   BatchMemo1.Lines.Add('pcs for regeneration = 1-2') ;
   BatchMemo1.Lines.Add('mean centred  = true') ;  //
   BatchMemo1.Lines.Add('') ;
end;

procedure TForm3.Template2Dcorrelation2Click(Sender: TObject);
begin
   BatchMemo1.Lines.Add('type = correl2D') ;
   BatchMemo1.Lines.Add('sample range = 1-') ;
   BatchMemo1.Lines.Add('x var range = 1050-1790 cm-1 ') ;
   BatchMemo1.Lines.Add('standardize var covar = false') ;  //
   BatchMemo1.Lines.Add('mean centre = true') ;  //
   BatchMemo1.Lines.Add('column standardise = false') ;  //
   BatchMemo1.Lines.Add('results file = 2D_correlation.out') ;
   BatchMemo1.Lines.Add('') ;
end;

procedure TForm3.TemplateIRpol2Click(Sender: TObject);
begin
   BatchMemo1.Lines.Add('type = IRPOL  // Does PCA on each analysis point then fits cos^2 to scores') ;
   BatchMemo1.Lines.Add('number of x positions = 17') ;
   BatchMemo1.Lines.Add('number of y positions = 1') ;
   BatchMemo1.Lines.Add('interleaved = 1  // (or 2)') ;
   BatchMemo1.Lines.Add('start row = 1') ;
   BatchMemo1.Lines.Add('pcs to fit = 1-2') ;
   BatchMemo1.Lines.Add('x var range = 800-1800 cm-1  // can be variable number or value found in x coordinate (space essential between value and units) ') ;
   BatchMemo1.Lines.Add('num angle = 13') ;
   BatchMemo1.Lines.Add('angles = 0,15,30,45,60,75,90,105,120,135,150,165,180') ;
   BatchMemo1.Lines.Add('pos or neg range = 1200-1260 cm-1  // can be variable number or value found in x coordinate (space essential between value and units) ') ;
   BatchMemo1.Lines.Add('positive or negative = negative') ;
   BatchMemo1.Lines.Add('autoexclude = 0.0   // 0.75 ') ;
   BatchMemo1.Lines.Add('exclude from PCs = 0  // 1') ;
   BatchMemo1.Lines.Add('pixel spacing = 75  // distance between pixels') ;
   BatchMemo1.Lines.Add('bone to surface = true  // distance between pixels') ;
   BatchMemo1.Lines.Add('actual depth = 0  // depth in mm') ;
   BatchMemo1.Lines.Add('normalise depth = false  // 1') ;
   BatchMemo1.Lines.Add('mean centre = true') ;
   BatchMemo1.Lines.Add('column standardise = false') ;
   BatchMemo1.Lines.Add('normalised output = false') ;
   BatchMemo1.Lines.Add('results file = IR_pol.out') ;
   BatchMemo1.Lines.Add('') ;
end;

procedure TForm3.TemplatePLS1Click(Sender: TObject);
begin
   BatchMemo1.Lines.Add('type = PLS1') ;
//   BatchMemo1.Lines.Add('start row = 1') ;
   BatchMemo1.Lines.Add('// input x and y data') ;
   BatchMemo1.Lines.Add('x sample range = 1-10     // (ROWS)') ;    // can select subset using this
   BatchMemo1.Lines.Add('x var range = 2-520       // (COLS)') ;
   BatchMemo1.Lines.Add('y in x data = true') ;
   BatchMemo1.Lines.Add('y sample range = 1-10     // (ROWS)') ;    // can select subset using this
   BatchMemo1.Lines.Add('y var range = 1-1         // (COLS)') ;
   BatchMemo1.Lines.Add('number of PCs = 1-20') ;
   BatchMemo1.Lines.Add('// pre-processing') ;  //
   BatchMemo1.Lines.Add('mean centre = true') ;  //
   BatchMemo1.Lines.Add('column standardise = false') ;  //
   BatchMemo1.Lines.Add('smooth =   // average,15  // fourier,15,50,remove complex  // %,power') ;  //
   BatchMemo1.Lines.Add('derivative =   // fourier,2,remove complex,true,1 // inputs: "diff type: 1st 2nd deriv etc: true = Hanning Window: 1 2 3 etc = zero fill"  N.B. type=fourier only available;') ;
   BatchMemo1.Lines.Add('// EVects output') ;
   BatchMemo1.Lines.Add('positive or negative =  ') ;
   BatchMemo1.Lines.Add('autoexclude =     // 0.75 ') ;
   BatchMemo1.Lines.Add('normalised output = true') ;
   BatchMemo1.Lines.Add('results file = PLS.out') ;
   BatchMemo1.Lines.Add('') ;

{
type = PLS
// input x and y data
x sample range = 1-686     // (ROWS)
x var range = 2-520        // (COLS)
y in x data = true
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
end;

procedure TForm3.TemplateInvert2Click(Sender: TObject);
begin
   BatchMemo1.Lines.Add('type = invert') ;
   BatchMemo1.Lines.Add('x var range = 800-1800 cm-1  // can be variable number or value found in x coordinate (space essential between value and units) ') ;
   BatchMemo1.Lines.Add('positive or negative = negative') ;
   BatchMemo1.Lines.Add('') ;
end;

procedure TForm3.TemplatePCR2Click(Sender: TObject);
begin
   BatchMemo1.Lines.Add('type = PCR') ;
//   BatchMemo1.Lines.Add('start row = 1') ;
   BatchMemo1.Lines.Add('// input x and y data') ;
   BatchMemo1.Lines.Add('x sample range = 1-10     // (ROWS)') ;    // can select subset using this
   BatchMemo1.Lines.Add('x var range = 2-520       // (COLS)') ;
   BatchMemo1.Lines.Add('y in x data = true') ;
   BatchMemo1.Lines.Add('y sample range = 1-10     // (ROWS)') ;    // can select subset using this
   BatchMemo1.Lines.Add('y var range = 1-1         // (COLS)') ;
   BatchMemo1.Lines.Add('number of PCs = 1-20') ;
   BatchMemo1.Lines.Add('// pre-processing') ;  //
   BatchMemo1.Lines.Add('mean centre = true') ;  //
   BatchMemo1.Lines.Add('column standardise = false') ;  //
   BatchMemo1.Lines.Add('smooth =   // average,15  // fourier,15,50,remove complex  // %,power') ;  //
   BatchMemo1.Lines.Add('derivative =   // fourier,2,remove complex,true,1 // inputs: "diff type: 1st 2nd deriv etc: true = Hanning Window: 1 2 3 etc = zero fill"  N.B. type=fourier only available;') ;
   BatchMemo1.Lines.Add('// EVects output - none of these are used') ;
   BatchMemo1.Lines.Add('positive or negative =  ') ;
   BatchMemo1.Lines.Add('autoexclude =     // 0.75 ') ;
   BatchMemo1.Lines.Add('normalised output = true') ;
   BatchMemo1.Lines.Add('results file = PCR.out') ;
   BatchMemo1.Lines.Add('') ;
end;

procedure TForm3.TemplatePCA2Click(Sender: TObject);
begin
   BatchMemo1.Lines.Add('type = PCA') ;
   BatchMemo1.Lines.Add('sample range = 1-  // can select subset using this') ; // can select subset using this
   BatchMemo1.Lines.Add('x var range = 1-') ;
   BatchMemo1.Lines.Add('number of PCs = 1-6') ;
   BatchMemo1.Lines.Add('pos or neg range = 1200-1260 cm-1  // can be variable number or value found in x coordinate (space essential between value and units) ') ;
   BatchMemo1.Lines.Add('positive or negative = negative') ;
   BatchMemo1.Lines.Add('autoexclude = 0.0') ;
   BatchMemo1.Lines.Add('exclude from PCs = 0') ;
 {
   BatchMemo1.Lines.Add('normalise to peak = area  // or height, leave blank for none') ;
   BatchMemo1.Lines.Add('peak =  1620-1660 cm-1') ;
 }
   BatchMemo1.Lines.Add('mean centre = true') ;  //
   BatchMemo1.Lines.Add('column standardise = false') ;  //
   BatchMemo1.Lines.Add('normalised output = true') ;
   BatchMemo1.Lines.Add('results file = PCA.out') ;
end;

procedure TForm3.TemplateExtractandSave2Click(Sender: TObject);
begin
   BatchMemo1.Lines.Add('type = extract') ;
   BatchMemo1.Lines.Add('number of x positions = xx') ;
   BatchMemo1.Lines.Add('number of y positions = xx') ;
   BatchMemo1.Lines.Add('num angles = xx') ;
   BatchMemo1.Lines.Add('x position wanted = 1-') ;
   BatchMemo1.Lines.Add('y position wanted = 1-') ;
   BatchMemo1.Lines.Add('start row = 1') ;
   BatchMemo1.Lines.Add('num samples = 1') ;
   BatchMemo1.Lines.Add('x var range = 1-') ;
   BatchMemo1.Lines.Add('mean centre = true') ;  //
   BatchMemo1.Lines.Add('column standardise = false') ;  //
   BatchMemo1.Lines.Add('') ;
end;

procedure TForm3.TemplateMaths1Click(Sender: TObject);
begin
   BatchMemo1.Lines.Add('type = MATH') ;
   BatchMemo1.Lines.Add('//  Scalar Operations  + - * / ') ;
   BatchMemo1.Lines.Add('//  C1 := C1  + 0.15           ') ;
   BatchMemo1.Lines.Add('//  Per Spectra/Point Operations .+ .- .* ./ ') ;
   BatchMemo1.Lines.Add('//  C1 := C1 ./ C2         // C2 is a scalar for each spectra (or point) in C1      ') ;
   BatchMemo1.Lines.Add('//  Row/Col Operations + .- .* ') ;
   BatchMemo1.Lines.Add('//  C1 := C1 + C2[1,1-1736]    ') ;
   BatchMemo1.Lines.Add('//  Matrix Operations * = multiply .T = transpose, .inv = inverse, ') ;
   BatchMemo1.Lines.Add('//  C3 := C1 * C2              ') ;
   BatchMemo1.Lines.Add('//  Inbuilt functions ') ;
   BatchMemo1.Lines.Add('//  C1 := C1.integrate(650-4000) .-  C1.baseline(1900-2400) // ') ;
   BatchMemo1.Lines.Add('') ;
end;

procedure TForm3.TempltePLMangle1Click(Sender: TObject);
begin
  BatchMemo1.Lines.Add('type = PLM STACK  // ') ;
  BatchMemo1.Lines.Add('// OR type = PLM ANGLE CONVERT  // 0-45 angle converted to 0-90') ;
  BatchMemo1.Lines.Add('// need 0-45 angle data (col1) and ') ;
  BatchMemo1.Lines.Add('// subtracted analyser at -x degrees -minus analyser +x degrees (col2)') ;
  BatchMemo1.Lines.Add('number of x positions = 640      // numX ') ;
  BatchMemo1.Lines.Add('number of y positions = 480      // numY ') ;
  BatchMemo1.Lines.Add('//num angle = 19') ;
  BatchMemo1.Lines.Add('//angles = -45,-30,-15,0.0,15,30,45 // uncomment if needed') ;
  BatchMemo1.Lines.Add('//angles = 0.0,15,30,45,60,75,90 // uncomment if needed') ;
  BatchMemo1.Lines.Add('//angles = -45,-40,-35,-30,-25,-20,-15,-10,-5,-0.0,5,10,15,20,25,30,35,40,45  ') ;
  BatchMemo1.Lines.Add('pixel spacing = 1.3587  // distance between pixels ') ;
  BatchMemo1.Lines.Add('bone to surface = true  //  ') ;
  BatchMemo1.Lines.Add('actual depth = 0  // depth in mm  ') ;
  BatchMemo1.Lines.Add('normalise depth = false  // 1 ') ;
  BatchMemo1.Lines.Add('autosave = true  // 1 ') ;
  BatchMemo1.Lines.Add('results file = PLM_angles.out') ;
  BatchMemo1.Lines.Add('') ;
end;

procedure TForm3.TemplateDichroicRatio1Click(Sender: TObject);
begin
  BatchMemo1.Lines.Add('type = DICHROIC RATIO  // ratios two band areas (peak1 / peak2)') ;
  BatchMemo1.Lines.Add('sample range = 1-34  ') ;
  BatchMemo1.Lines.Add('x var range = 1-') ;
  BatchMemo1.Lines.Add('number of x positions = 17') ;  // output wil be 17
  BatchMemo1.Lines.Add('number of y positions = 1') ;
  BatchMemo1.Lines.Add('interleaved = false') ;
  BatchMemo1.Lines.Add('pixel spacing x = 75  // distance between pixels') ;
  BatchMemo1.Lines.Add('pixel spacing y = 75  // distance between pixels') ;
  BatchMemo1.Lines.Add('bone to surface = true  // distance between pixels') ;
  BatchMemo1.Lines.Add('actual depth = 0  // depth in mm') ;
  BatchMemo1.Lines.Add('normalise depth = false  // 1') ;
  BatchMemo1.Lines.Add('results file = dichroic_ratio.out') ;
  BatchMemo1.Lines.Add('') ;

end;

procedure TForm3.Clear1Click(Sender: TObject);
begin
   BatchMemo1.Clear ;
end;



procedure TForm3.TemplatePLSPCRVerify1Click(Sender: TObject);
begin
    BatchMemo1.Lines.Add('type = PREDICT Y') ;
    BatchMemo1.Lines.Add('// X column: new x data; Y column: Y reference data; Then regression coefficients ') ;
//   BatchMemo1.Lines.Add('start row = 1') ;
   BatchMemo1.Lines.Add('// input x and y data') ;
   BatchMemo1.Lines.Add('x sample range = 1-10     // (ROWS)') ;    // can select subset using this
   BatchMemo1.Lines.Add('x var range = 2-520       // (COLS)') ;
   BatchMemo1.Lines.Add('y in x data = true') ;
   BatchMemo1.Lines.Add('y sample range = 1-10     // (ROWS)') ;    // can select subset using this
   BatchMemo1.Lines.Add('y var range = 1-1         // (COLS)') ;

   BatchMemo1.Lines.Add('// pre-processing') ;  //
   BatchMemo1.Lines.Add('mean centre = true') ;  //
   BatchMemo1.Lines.Add('column standardise = false') ;  //
   BatchMemo1.Lines.Add('smooth =   // average,15  // fourier,15,50,remove complex  // %,power') ;  //
   BatchMemo1.Lines.Add('derivative =   // fourier,2,remove complex,true,1 // inputs: "diff type: 1st 2nd deriv etc: true = Hanning Window: 1 2 3 etc = zero fill"  N.B. type=fourier only available;') ;

   BatchMemo1.Lines.Add('results file = PLS.out') ;
   BatchMemo1.Lines.Add('') ;

end;

procedure TForm3.Templatemultiplyandsubtract1Click(Sender: TObject);
begin
  BatchMemo1.Lines.Add('type = multiply and subtract') ;
  BatchMemo1.Lines.Add('// Input:   x data and EVects vector ') ;
  BatchMemo1.Lines.Add('// Output:  scores and residuals') ;
  BatchMemo1.Lines.Add('') ;
end;

procedure TForm3.TemplateMatrixsubtract1Click(Sender: TObject);
begin
  BatchMemo1.Lines.Add('type = add or subtract') ;
  BatchMemo1.Lines.Add('operation = add  // subtract') ;
  BatchMemo1.Lines.Add('// Input:   x data and y data (same size)') ;
  BatchMemo1.Lines.Add('// Output:  x +/- y') ;
  BatchMemo1.Lines.Add('') ;
end;

procedure TForm3.TemplateMultiplyMatrices1Click(Sender: TObject);
begin
  BatchMemo1.Lines.Add('type = matrix multiply') ; // matrix multiply
  BatchMemo1.Lines.Add('// Input:   two matricies ') ;
  BatchMemo1.Lines.Add('// Output:  the product of the two matricies') ;
  BatchMemo1.Lines.Add('') ;
end;

procedure TForm3.TemplateVectoraddsubtract1Click(Sender: TObject);
begin
  BatchMemo1.Lines.Add('type = vector add or subtract') ;
  BatchMemo1.Lines.Add('operation = add  // subtract') ;
  BatchMemo1.Lines.Add('prefactor = 1.0  // scales vector data') ;
  BatchMemo1.Lines.Add('// Input:   x data (vector or matrix) and y data (vector - same size)') ;
  BatchMemo1.Lines.Add('// Output:  x.rows +/- (y*prefactor)') ;
  BatchMemo1.Lines.Add('') ;
end;

procedure TForm3.TemplateVectormultiplydivide1Click(Sender: TObject);
begin
  BatchMemo1.Lines.Add('type = vector multiply or divide') ;
  BatchMemo1.Lines.Add('operation = divide  // multiply') ;
  BatchMemo1.Lines.Add('prefactor = 1.0  // scales vector data') ;
  BatchMemo1.Lines.Add('y row = y.1      // 1st row of y matrix is used as vector') ;
  BatchMemo1.Lines.Add('// Input:   x data (vector or matrix) and y data (vector - same size)') ;
  BatchMemo1.Lines.Add('// Output:  x.rows * / (y*prefactor)') ;
  BatchMemo1.Lines.Add('// i.e. each column of each row of x is multiplied/divided') ;
  BatchMemo1.Lines.Add('// by corresponding column of y vector') ;
  BatchMemo1.Lines.Add('') ;
end;



procedure TForm3.TemplateAutoSubtractFator1Click(Sender: TObject);
begin
   BatchMemo1.Lines.Add('type = Auto Project EVects') ;
   BatchMemo1.Lines.Add('sample range = 1-') ;
   BatchMemo1.Lines.Add('x var range = 1-') ;
   BatchMemo1.Lines.Add('target factor sample row = 1') ;   // sore in  factorSampleRowStr
   BatchMemo1.Lines.Add('target factor var range  = 1-') ;  // store in factorVarStr
   BatchMemo1.Lines.Add('project target factor only  = true // false // if true then do not fit PCs to factor') ;  // store in factorVarStr
   BatchMemo1.Lines.Add('number of PCs = 1-2') ;
   BatchMemo1.Lines.Add('PCs for factor match = 1-2') ;  // store in 'factorPCs'
   BatchMemo1.Lines.Add('mean centre = false') ;  //
   BatchMemo1.Lines.Add('column standardise = false') ;  //
   BatchMemo1.Lines.Add('normalised output = true') ;
   BatchMemo1.Lines.Add('results file = output_filename.out') ;
   BatchMemo1.Lines.Add('') ;
end;



procedure TForm3.FormDragOver(Sender, Source: TObject; X, Y: Integer;
  State: TDragState; var Accept: Boolean);
begin
  If Sender is TDragObject Then Accept := True ;
end;

procedure TForm3.BatchMemo1DragOver(Sender, Source: TObject; X, Y: Integer;
  State: TDragState; var Accept: Boolean);
begin
  If Sender is TDragObject Then Accept := True ;
end;


procedure TForm3.wmDropFiles(var Msg: TWMDropFiles); //message WM_DROPFILES;
var
  count, tint : integer ;
  CFileName      : array[0..MAX_PATH] of Char;
  strList : TStringList ;
  TempStr : String ;
begin
  try
    strList := TStringList.Create;

    count :=  DragQueryFile(Msg.Drop, $FFFFFFFF, CFileName, MAX_PATH) ;
    if count > 0 then
    begin
      for tint := 0 to count-1 do   // create list of each filename dropped
      begin
        DragQueryFile(Msg.Drop, tint, CFileName, MAX_PATH) ;
        TempStr :=  Format('%s', [CFilename]) ;
        strList.Add(TempStr) ;
      end ;
      if (extractfileExt(strList.Strings[0]) = '.txt') or (extractfileExt(strList.Strings[0]) = '.bat') then
      begin
        BatchMemo1.Clear ;   // drag and drop opening  // load each file dropped
        BatchMemo1.Lines.LoadFromFile(strList.Strings[0]) ;
      end ;
    end;
  finally
    if (extractfileExt(strList.Strings[0]) = '.txt') or (extractfileExt(strList.Strings[0]) = '.bat') then
    begin
      Msg.Result := 0;
      DragFinish(Msg.Drop);
      ChDir(ExtractFileDir(strList.Strings[0]))  ;
      Form4.OpenDialog1.InitialDir := ExtractFileDir(strList.Strings[0]) ;
      Form4.SaveDialog1.InitialDir := ExtractFileDir(strList.Strings[0]) ;
    end ;
      strList.Free ;
      Form1.Refresh;
  end;
end;



procedure TForm3.FormActivate(Sender: TObject);
begin
  DragAcceptFiles(Handle, True);
end;

procedure TForm3.TemplateRotate2Fators1Click(Sender: TObject);
begin
   BatchMemo1.Lines.Add('// Either does a survey rotation of eigenvectors between desired angles') ;
   BatchMemo1.Lines.Add('// or if fit to factor = true then rotates eigenvector by desired angle to') ;
   BatchMemo1.Lines.Add('// get a best fit with a reference evect in the Y column') ;
   BatchMemo1.Lines.Add('// Need evects in X column and reference evect in Y (if needed)') ;
   BatchMemo1.Lines.Add('type = Rotate Factors') ;
   BatchMemo1.Lines.Add('PCs to rotate = 1-3') ;   // in order: X Y Z'
   BatchMemo1.Lines.Add('anglePC1 = 0  // = x axis') ;
   BatchMemo1.Lines.Add('anglePC2 = 0  // = y axis') ;
   BatchMemo1.Lines.Add('anglePC3 = 5  // = z axis. If only 2 PCs then rotate around this axis') ;
   BatchMemo1.Lines.Add('range PC1 = 0-0') ;
   BatchMemo1.Lines.Add('range PC2 = 0-0') ;
   BatchMemo1.Lines.Add('range PC3 = 0-180') ;
   BatchMemo1.Lines.Add('fit to factor = false // if true then searches for angle to rotate to fit to y data') ;
   BatchMemo1.Lines.Add('factor to fit = 1     // rotate PC1 to fit vector in Y column') ;
   BatchMemo1.Lines.Add('') ;
end;



procedure TForm3.TemplateRotateandfitScores1Click(Sender: TObject);
begin
   BatchMemo1.Lines.Add('// Need original data in X column, Evectors in Y') ;
   BatchMemo1.Lines.Add('// and a section of scores to try to fit in Z column') ;
   BatchMemo1.Lines.Add('// Rotates 2 eigenvectors selected and projects') ;
   BatchMemo1.Lines.Add('// one on original data to obtain scores') ;
   BatchMemo1.Lines.Add('// Rotates EVects so as to minimis fit between the') ;
   BatchMemo1.Lines.Add('// projected scores and the reference scores in the Z column') ;
   BatchMemo1.Lines.Add('type = Rotate Factors To Fit Scores') ;
   BatchMemo1.Lines.Add('PCs to rotate = 1-3') ;   // in order: X Y Z'
   BatchMemo1.Lines.Add('initial angle = 0.0') ;
   BatchMemo1.Lines.Add('angle step = 0.5') ;
   BatchMemo1.Lines.Add('Score to fit = 1        // rotate PC1 to fit vector in Y column - Probably has to be 1 anyway') ;
   BatchMemo1.Lines.Add('Score range to fit = 1-  // select specific scores') ;   // in order: X Y Z'
   BatchMemo1.Lines.Add('Score reference range to fit = 1-  // Y column data to select') ;   // in order: X Y Z'

   BatchMemo1.Lines.Add('') ;
end;

end.
