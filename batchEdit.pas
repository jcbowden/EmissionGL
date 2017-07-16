unit batchEdit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, OpenGL, Forms, Dialogs,
  StdCtrls, Menus, TVarAndCoVarOperations, TMatrixObject, ExtCtrls, TSpectraRangeObject,
  TBatch, TPCABatchObject, TIRPolAnalysisObject2, TBatchBasicFunctions, T2DCorrelObject,
  TAreaRatioUnit, TMathBatchUnit, TPLMAnalysisUnit1, TDichroicRatioUnit, TPLSPredictBatchUnit,
  TPCRPredictBatchUnit, TPLSYPredictTestBatchUnit, TAutoProjectEVectsUnit, TRotateFactorsUnit,
  TMatrixOperations, TRotateToFitScoresUnit, ShellAPI, TASMTimerUnit, SPCFileUnit  ;
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
    emplateMatrixcorrelation1: TMenuItem;
    emplateLeverage1: TMenuItem;
    TemplateILSClick: TMenuItem;
    emplateConcatenate1: TMenuItem;
    SetExecutable2: TMenuItem;
    emplateSaveRows1: TMenuItem;
    MatrixFunctions1: TMenuItem;
    RegressionFunctions1: TMenuItem;
    MicroscopyFunctions1: TMenuItem;
    emplateInterleaveSpectra1: TMenuItem;
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
    procedure emplateMatrixcorrelation1Click(Sender: TObject);
    procedure emplateLeverage1Click(Sender: TObject);
    procedure TemplateILSClickClick(Sender: TObject);
    procedure emplateConcatenate1Click(Sender: TObject);
    procedure SetExecutable2Click(Sender: TObject);
    procedure emplateSaveRows1Click(Sender: TObject);
    procedure emplateInterleaveSpectra1Click(Sender: TObject);
 

  private
    { Private declarations }
  public

    resulsFile : string ;
    procedure wmDropFiles(var Msg: TWMDropFiles); message WM_DROPFILES;

    function ReturnLineColor(IntensityListIn : TStringList; numBlankLines : integer) : TGLLineColor ;  // numBlankLines is 1 if line not sdded to string grid yet or 2 if line added


    function CreateStringGridRowAndObjects8(  ) : TGLLineColor ;


    procedure RemoveRow( messasge : string ) ;   // remove row code if errr in creaing data
    function  SetupallXDataAs1D_or_2D(numImages : integer ; allXDataIn : TSpectraRanges ; tSr : TSpectraRanges) : boolean  ;
    function  SetupNativeMatrixAs1D_or_2D( scoresSpectra : TSpectraRanges ; tSr : TSpectraRanges) : boolean  ;   // a native 2D matrix is a single block of 2D intensity values (z axis (colour) values)

    procedure FreeStringGridSpectraRanges(col, row : integer );

    function AddOrSub(initialLineNum : integer; addorsubtract : integer) : integer ;
    // MultAndSub(): multiplies a data matrix by a vector to return the scores of the vectore on the data matrix and the residuals
    function MultAndSub(initialLineNum : integer) : integer ;  // returns the line number of the batch file
    // MatrixMultiply(): does a ordinary matrix multiplication between to matricies where the #cols of 1st = #row 2nd
    function MatrixMultiply(initialLineNum : integer) : integer ;  // returns the line number of the batch file
    // CorrelateMatrix(): Calculates correlations between elements of matricies where the #cols of 1st = #row 2nd
    function CorrelateMatrix(initialLineNum : integer) : integer ;  // returns the line number of the batch file
    // Leverage(): Calculates the Leverage of samples
    // L(diagonal) = X [ X<T> X ]^-1 X
    function Leverage(initialLineNum : integer) : integer ;  // returns the line number of the batch file

    // VectorAddOrSub(): Entry wise addition or subtraction of vector elements from each row of a matrix
    function VectorAddOrSub(initialLineNum : integer; addorsubtract : integer; vectorPrefactor : single) : integer ;  // returns the line number of the batch file
    // VectorMultiplyOrDivide(): Entrywise multiply or divide of vector elements with each row of a matrix
    function VectorMultiplyOrDivide(initialLineNum : integer; addorsubtract : integer; vectorPrefactor : single; y_row : string) : integer ;  // returns the line number of the batch file

    function SaveRowsAsFilenames(initialLineNumIn : integer; tStrListIn: TStringList; tSRIn : TSpectraRanges) : integer ;
    function InterleaveSpectraRanges(initialLineNumIn: integer; tStrListIn: TStringList) : integer ; // interleaves spectra withinn selected TSpectraRanges by row
    { Public declarations }
  end;

var
  Form3: TForm3;

implementation

Uses EmissionGL, FileInfo, ColorsEM, BatchFileDlg, BLASLAPACKfreePas, TPassBatchFileToExecutableUnit ;

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
      if Form4.StringGrid1.Objects[2,Form4.StringGrid1.Selection.Top] is TSpectraRanges then
      begin
        TSpectraRanges(Form4.StringGrid1.Objects[2,Form4.StringGrid1.Selection.Top]).batchList.LoadFromFile(filename)  ;
        TSpectraRanges(Form4.StringGrid1.Objects[2,Form4.StringGrid1.Selection.Top]).batchList.filename :=  extractfilename(filename) ;
        Form3.BatchMemo1.Lines :=  TSpectraRanges(Form4.StringGrid1.Objects[2,Form4.StringGrid1.Selection.Top]).batchList ;
        TSpectraRanges(Form4.StringGrid1.Objects[2,Form4.StringGrid1.Selection.Top]).batchList.textModified := false ;
      end
      else
      begin
        Form3.BatchMemo1.Lines.LoadFromFile(filename) ;
      end;
      filename :=  Form4.OpenDialog1.filename ;
      Form3.Caption := extractFileName(filename) ;

      //SetCurrentDir(ExtractFilePath(filename));
      Form4.SaveDialog1.InitialDir :=  ExtractFilePath(Form4.OpenDialog1.filename) ;
      Form4.OpenDialog1.InitialDir :=  ExtractFilePath(Form4.OpenDialog1.filename) ;
    end ;
  end ;

end;

procedure TForm3.Sa1Click(Sender: TObject);
begin
   if Form4.StringGrid1.Objects[2,Form4.StringGrid1.Selection.Top] is TSpectraRanges then
   begin
   if TSpectraRanges(Form4.StringGrid1.Objects[2,Form4.StringGrid1.Selection.Top]).batchList.textModified then
   begin
     TSpectraRanges(Form4.StringGrid1.Objects[2,Form4.StringGrid1.Selection.Top]).batchList.textModified := false ;
     BatchMemo1.Lines.SaveToFile(TSpectraRanges(Form4.StringGrid1.Objects[2,Form4.StringGrid1.Selection.Top]).batchList.filename) ;
   end ;
   end
   else
   begin
     SaveAs1Click(Sender)  ;
   end;
end;

procedure TForm3.SaveAs1Click(Sender: TObject);
begin
  Form4.SaveDialog1.Title := 'Save batch file' ;
  Form4.SaveDialog1.Filter := 'batch files (*.bat)| *.bat|text (*.csv, *.txt, *.asc *.bat)|*.txt;*.csv;*.asc;*.bat|all files (*.*)|*.*'     ;
  if Form4.StringGrid1.Objects[2,Form4.StringGrid1.Selection.Top] is TSpectraRanges  then
    Form4.SaveDialog1.filename := TSpectraRanges(Form4.StringGrid1.Objects[2,Form4.StringGrid1.Selection.Top]).batchList.filename ;
  Form4.SaveDialog1.DefaultExt := '*.bat' ;

  If Form4.SaveDialog1.Execute Then
  begin
      BatchMemo1.Lines.SaveToFile(Form4.SaveDialog1.filename) ;
      if Form4.StringGrid1.Objects[2,Form4.StringGrid1.Selection.Top] is TSpectraRanges then
      begin
        TSpectraRanges(Form4.StringGrid1.Objects[2,Form4.StringGrid1.Selection.Top]).batchList.filename :=  extractfilename(Form4.SaveDialog1.filename) ;
        TSpectraRanges(Form4.StringGrid1.Objects[2,Form4.StringGrid1.Selection.Top]).batchList.textModified := false ;
      end;
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

procedure TForm3.emplateConcatenate1Click(Sender: TObject);
begin
   BatchMemo1.Lines.Add('type = CONCAT') ;
   BatchMemo1.Lines.Add('//Enter directories to search and file extension ') ;
   BatchMemo1.Lines.Add('// if input directory =...\* then all dir in current dir will be searched') ;
   BatchMemo1.Lines.Add('// if input directory = empty then current dir will be searched') ;
   BatchMemo1.Lines.Add('input directory =    // this is also the output directory') ;
   BatchMemo1.Lines.Add('file extension = .tif  // include the .') ;  //
   BatchMemo1.Lines.Add('// 2,ave or 4,skip,flat,trans,vnorm  - this is down sampling of TIFF image') ;
   BatchMemo1.Lines.Add('// ave: indicates average 2d data, number indicates by how many points'  ) ;
   BatchMemo1.Lines.Add('// skip: indicates skip 2d data, number indicates by how many points'  ) ;
   BatchMemo1.Lines.Add('// i.e. 64x64 -> 4,skip = 16x16'  ) ;
   BatchMemo1.Lines.Add('// flat: indicates use the average of the column data as the final data (after downsampling)' ) ;
   BatchMemo1.Lines.Add('// trans: indicates to transpose the tiff file data before averaging'  ) ;
   BatchMemo1.Lines.Add('reformat tif = 4,skip  // reduces tiff size by 4 in each direction by skipping data') ;
   BatchMemo1.Lines.Add('output filename = concat_files.bin  // ') ;
   BatchMemo1.Lines.Add('') ;
end;

procedure TForm3.emplateInterleaveSpectra1Click(Sender: TObject);
begin
   BatchMemo1.Lines.Add('type = interleave') ;
   BatchMemo1.Lines.Add('// this function squences through the selected rows, in order specified by the pre-colon value') ;
   BatchMemo1.Lines.Add('// and copies the row ranges as specified in the post-colon range ') ;
   BatchMemo1.Lines.Add('order and row ranges =') ;
   BatchMemo1.Lines.Add('1:1-') ;
   BatchMemo1.Lines.Add('2:6-') ;
   BatchMemo1.Lines.Add('3:6-') ;
   BatchMemo1.Lines.Add('4:6-') ; //   column range
   BatchMemo1.Lines.Add('column range = 1-1555') ;
   BatchMemo1.Lines.Add('filename = _interleaved.bin') ;  //
   BatchMemo1.Lines.Add('') ;
end;

procedure TForm3.emplateLeverage1Click(Sender: TObject);
begin
  BatchMemo1.Lines.Add('type = leverage') ; // matrix multiply
  BatchMemo1.Lines.Add('// Input:   single matrix of X data (samples in rows) ') ;
  BatchMemo1.Lines.Add('// Output:  the leverage matrix  L ') ;
  BatchMemo1.Lines.Add('// L = X [ X<t> X ]^-1 X<t>') ;
  BatchMemo1.Lines.Add('') ;
end;

procedure TForm3.emplateMatrixcorrelation1Click(Sender: TObject);
begin
  BatchMemo1.Lines.Add('type = matrix correlation') ; // matrix multiply
  BatchMemo1.Lines.Add('// Input:   two matricies (# cols of first = # rows of second) ') ;
  BatchMemo1.Lines.Add('// Output:  the cross correlation matrix') ;
  BatchMemo1.Lines.Add('') ;
end;

procedure TForm3.emplateSaveRows1Click(Sender: TObject);
begin
  BatchMemo1.Lines.Add('type = SAVE ROWS') ; // matrix multiply
  BatchMemo1.Lines.Add('// saves each row of a file as a different name ') ;
  BatchMemo1.Lines.Add('// as set in list below') ;
  BatchMemo1.Lines.Add('file type  =  .bin') ;
  BatchMemo1.Lines.Add('prefix = abc_') ;
  BatchMemo1.Lines.Add('postfix = ') ;
  BatchMemo1.Lines.Add('directory = C:\') ;
  BatchMemo1.Lines.Add('// filenames are the conjunction of prefix+filename+postfix+file type') ;
  BatchMemo1.Lines.Add('// The numbers before the file names indicates the row range ') ;
  BatchMemo1.Lines.Add('// and the column range to be saving. Format:  rows:cols filename') ;
  BatchMemo1.Lines.Add('file names =') ;
  BatchMemo1.Lines.Add('1:1- density_aveyear') ;
  BatchMemo1.Lines.Add('2:1- raddiam_aveyear') ;
  BatchMemo1.Lines.Add('3:1- tandiam_aveyear') ;
  BatchMemo1.Lines.Add('4:1- coarsness_aveyear') ;
  BatchMemo1.Lines.Add('5:1- cellpop_aveyear') ;
  BatchMemo1.Lines.Add('6:1-  rayangle_aveyear') ;
  BatchMemo1.Lines.Add('7:1- isopynic_aveyear') ;
  BatchMemo1.Lines.Add('8:1- MFA_aveyear') ;
  BatchMemo1.Lines.Add('9:1- diffintens_aveyear') ;
  BatchMemo1.Lines.Add('10:1- MOE_aveyear') ;
  BatchMemo1.Lines.Add('11:1- wallthickness_aveyear') ;
  BatchMemo1.Lines.Add('12:1- specificsurface_aveyear') ;
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
        if xData.fft.dtime  <> 0 then
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
      if xData.yImaginary <> nil then xData.yCoord.MakeComplex(xData.yImaginary);
      yData      := TSpectraRanges(Form4.StringGrid1.Objects[3,Form4.StringGrid1.Row]) ;  // this is a vector
      if yData = nil then exit ;
      if yData.yImaginary <> nil then yData.yCoord.MakeComplex(yData.yImaginary);

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

      // This does the multiply or divide operation
      vectorData.yCoord.F_Mdata.Seek(0,soFromBeginning) ;
      if addorSubtract = 1  then  // multiply
        resultData.yCoord.MultiplyMatrixByVect(vectorData.yCoord)
      else
      if addorSubtract = -1  then  // divide
      begin
        DivZeroError := resultData.yCoord.DivideMatrixByVect (vectorData.yCoord) ;   // returns 1 on EZeroDivide error, otherwise 0
        if DivZeroError = 1 then
          messagedlg('Y Vector contains a zero, cannot perform division',mtError,[mbOK],0) ;
      end ;

      if xData.yImaginary <> nil then xData.yCoord.MakeUnComplex(xData.yImaginary);
      if yData.yImaginary <> nil then yData.yCoord.MakeUnComplex(yData.yImaginary);


      // create the new results data TSpectraRange OpenGl object and grid information for GUI
      if DivZeroError <> 1 then
      begin
        if Form4.StringGrid1.Objects[4,Form4.StringGrid1.Row] <> nil then
          FreeStringGridSpectraRanges( 4,Form4.StringGrid1.Row ) ;
        Form4.StringGrid1.Objects[4,Form4.StringGrid1.Row] := resultData ;  // assign object to the cell
        resultData.GLListNumber := Form4.GetLowestListNumber ;                     // get openGL list number
        SetupallXDataAs1D_or_2D(1, resultData , xData) ;                           // create GL objects in 1D or 2D
        Form4.StringGrid1.Cells[4,Form4.StringGrid1.Row] := '1-'+ inttostr(xData.yCoord.numRows) +' : 1-' + inttostr(xData.yCoord.numCols) ;
        resultData.xString := xData.xString ;
        resultData.yString := xData.yString  ;
        if xData.fft.dtime <> 0 then
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
      if xData.fft.dtime <> 0 then
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

      copyX.LineColor:= CreateStringGridRowAndObjects8( ) ;  // creates new string grid line and gets new spectra line colour
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
      if copyX.fft.dtime <> 0 then
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
    try
      result := initialLineNum + 1 ;
      mo    := TMatrixOps.Create ;

      m1      := TSpectraRanges(Form4.StringGrid1.Objects[2,Form4.StringGrid1.Row]) ;
      m2      := TSpectraRanges(Form4.StringGrid1.Objects[3,Form4.StringGrid1.Row]) ;


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


// CorrelateMatrix(): Calculates correlations between elements of matricies where the #cols of 1st = #row 2nd
function TForm3.CorrelateMatrix(initialLineNum : integer) : integer ;  // returns the line number of the batch file
var
  m1, m2, tResult : TSpectraRanges ;
  vcv : TVarAndCoVarFunctions ;
  t1 : integer ;
  s1 : single  ;
  d1 : double  ;
begin
    // this is a test code for compensation of other components present1
    try
      result := initialLineNum + 1 ;
      vcv    := TVarAndCoVarFunctions.Create ;

      m1      := TSpectraRanges(Form4.StringGrid1.Objects[2,Form4.StringGrid1.Row]) ;
      m2      := TSpectraRanges(Form4.StringGrid1.Objects[3,Form4.StringGrid1.Row]) ;

      // create scores by projection of EVects onto original data
      tResult := TSpectraRanges.Create(m1.yCoord.SDPrec div 4, 1, m2.yCoord.numRows, @m1.LineColor) ;
      tResult.yCoord.Free ;
      tResult.yCoord := vcv.GetSampleVarCovarOfTwoMatrix( m1.yCoord, m2.yCoord ) ;

      // Set up xcoord data
      tResult.FillXCoordData(1,1,1);

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

    finally
      vcv.Free ;
    end ;
end ;


// Leverage(): Calculates the Leverage of samples
// L(diagonal) = X [ X<t> X ]^-1 X<t>
// L is numRows by numRows in size
function TForm3.Leverage(initialLineNum : integer) : integer ;  // returns the line number of the batch file
var
  tMemStr : TMemoryStream ;
  m2, m3 : TMatrix ;
  tSR1, tResult : TSpectraRanges   ;
  vcv : TVarAndCoVarFunctions      ;
  mo  : TMatrixOps  ;
  t1  : integer ;
  s1  : single  ;
  d1  : double  ;
begin
    // this is a test code for compensation of other components present1
    try
      result := initialLineNum + 1 ;
      vcv    := TVarAndCoVarFunctions.Create ;
      mo     := TMatrixOps.Create  ;

      tSR1      := TSpectraRanges(Form4.StringGrid1.Objects[2,Form4.StringGrid1.Row]) ;
      m2 := mo.MultiplyMatrixByMatrix(tSR1.yCoord,tSR1.yCoord,true,false,1.0,false)  ;
      mo.MatrixInverseSymmetric(m2) ;
      m3 := mo.MultiplyMatrixByMatrix(tSR1.yCoord,m2,false,false,1.0,false) ;
      m2.Free ;
      m2 := mo.MultiplyMatrixByMatrix(m3,tSR1.yCoord,false,true,1.0,false)  ;
      m3.Free ;
      tMemStr := m2.GetDiagonal(m2) ;
      m2.Free ;

      tResult := TSpectraRanges.Create(tSR1.yCoord.SDPrec div 4, 1, tSR1.yCoord.numRows, @tSR1.LineColor) ;
      tResult.yCoord.F_Mdata.Free ;
      tResult.yCoord.F_Mdata := tMemStr ;

      tResult.FillXCoordData(1,1,1);   // startVal, increment: single; direction : forward (1) or backward (-1) through memory

      // add to column 2 (3) of TStringGrid
      Form4.StringGrid1.Objects[3,Form4.StringGrid1.Row] := tResult ;
      tResult.GLListNumber := Form4.GetLowestListNumber ;
      tResult.SetOpenGLXYRange(Form2.GetWhichLineToDisplay()) ;
      tResult.zHigh :=  0 ;
      tResult.zLow :=   0  ;
      if (tResult.lineType > MAXDISPLAYTYPEFORSPECTRA) or (tResult.lineType < 1)  then tResult.lineType := 1 ;  //
      tResult.CreateGLList('1-',Form1.Canvas.Handle, RC, Form2.GetWhichLineToDisplay(),  tResult.lineType )   ;
      Form4.StringGrid1.Cells[3,Form4.StringGrid1.Row] := '1-'+ inttostr(tResult.yCoord.numRows) +' : 1-' + inttostr(tResult.yCoord.numCols) ;
      tResult.xString := tSR1.xString ;
      tResult.yString := tSR1.yString  ;

    finally
    begin
      vcv.Free ;
      mo.Free ;
    end;
    end ;
end ;


{
type = SAVE ROWS
// saves each row of a file as a different name
// as set in list below
file type  =  .bin
prefix = abc_
postfix =
directory = pwd
file names =
1:1- density_aveyear
2:1- raddiam_aveyear
3:1- tandiam_aveyear
4:1- coarsness_aveyear
5:1- cellpop_aveyear
6:1- rayangle_aveyear
7:1- isopynic_aveyear
8:1- MFA_aveyear
9:1- diffintens_aveyear
10:1- MOE_aveyear
11:1- wallthickness_aveyear
12:1- specificsurface_aveyear
}
function TForm3.SaveRowsAsFilenames(initialLineNumIn : integer; tStrListIn: TStringList; tSRIn : TSpectraRanges) : integer ;
var
  t1 : integer ;
  linenum : integer ;
  fileExt, prefix, postfix, saveToDir, nameStr, tstr1 : string ;
  rowRange, colRange : string ;
  nameList : TStringList ;
  savetSR : TSpectraRanges ;
  saveSPC  : ReadWriteSPC   ; // used to write a spc file to disk
  bB : TBatchbasics ;
  currentPos, increment : integer ;
begin
   bB  := TBatchBasics.Create ;

  nameList := TStringList.Create ;
  linenum:= initialLineNumIn ;

   repeat
     inc(lineNum) ;
     tstr1 := bB.GetStringFromStrList(tStrListIn, lineNum) ;
   until (trim(tstr1) <> '') or (lineNum > tStrListIn.Count)  ;
   if bB.LeftSideOfEqual(tstr1) = 'file type' then
     fileExt :=  bB.RightSideOfEqual(tstr1) ;
   repeat
     inc(lineNum) ;
     tstr1 := bB.GetStringFromStrList(tStrListIn, lineNum) ;
   until (trim(tstr1) <> '') or (lineNum > tStrListIn.Count)  ;
   if bB.LeftSideOfEqual(tstr1) = 'prefix' then
     prefix :=  bB.RightSideOfEqual(tstr1) ;

   repeat
     inc(lineNum) ;
     tstr1 := bB.GetStringFromStrList(tStrListIn, lineNum) ;
   until (trim(tstr1) <> '') or (lineNum > tStrListIn.Count)  ;
   if bB.LeftSideOfEqual(tstr1) = 'postfix' then
     postfix :=  bB.RightSideOfEqual(tstr1) ;

   repeat
     inc(lineNum) ;
     tstr1 := bB.GetStringFromStrList(tStrListIn, lineNum) ;
   until (trim(tstr1) <> '') or (lineNum > tStrListIn.Count)  ;
   if bB.LeftSideOfEqual(tstr1) = 'directory' then
     saveToDir :=  bB.RightSideOfEqual(tstr1) ;
   if   pos('pwd',(lowercase(saveToDir))) <> 0   then
   begin
      saveToDir := trim(saveToDir) ;
      if length(saveToDir)>3 then
      begin
        tstr1 := copy(saveToDir,3,length(saveToDir)-3) ;
        saveToDir :=  GetCurrentDir() + tstr1 ;
      end
      else
        saveToDir :=  GetCurrentDir() ;
   end;
   if copy(saveToDir,length(saveToDir)-1,1)<>'\' then  // add the backslash
     saveToDir := saveToDir + '\' ;
   

  repeat
     inc(lineNum) ;
     tstr1 := bB.GetStringFromStrList(tStrListIn, lineNum) ;
   until (trim(tstr1) <> '') or (lineNum > tStrListIn.Count)  ;
   if bB.LeftSideOfEqual(tstr1) = 'file names' then
   begin
      inc(lineNum) ;
      tstr1 := bB.GetStringFromStrList(tStrListIn, lineNum) ;
      while (trim(tstr1) <> '') and (lineNum < tStrListIn.Count) and (bB.LeftSideOfEqual(tstr1)<>'type') do
      begin
       nameList.Add(tstr1) ;
       inc(lineNum) ;
       tstr1 := bB.GetStringFromStrList(tStrListIn, lineNum) ;
      end;
   end;

   currentPos := 0 ;
   rowRange := copy( nameList.Strings[0],1,pos(':',nameList.Strings[0])-1 ) ;
   if pos('-',rowRange) > 0 then
   if length(rowRange) > pos('-',rowRange) then
     increment := strtoint(copy(rowRange,pos('-',rowRange)+1,length(rowRange)-pos('-',rowRange))) ;
   increment := increment  ;

   colRange := '1-' + inttostr(tSRIn.yCoord.numCols) ;
   for t1 := 0 to nameList.Count - 1 do
   begin
     savetSR := TSpectraRanges.Create(tSRIn.yCoord.SDPrec,1,tSRIn.yCoord.numCols,nil) ;

     rowRange := copy( nameList.Strings[t1],1,pos(':',nameList.Strings[t1])-1 ) ;
     if length(trim(rowRange)) = 0 then
     begin
       rowRange := inttostr(currentPos+1) + '-' + inttostr(currentpos+increment) ;
     end;
     currentPos := currentPos +  increment ;

     colRange := copy( nameList.Strings[t1],pos(':',nameList.Strings[t1])+1,pos(' ',nameList.Strings[t1])-pos(':',nameList.Strings[t1])) ;
     nameStr  := copy( nameList.Strings[t1],pos(' ',nameList.Strings[t1])+1, length(nameList.Strings[t1]) - pos(' ',nameList.Strings[t1])+1) ;
     nameStr  := saveToDir+ prefix + nameStr + postfix + fileExt ;  // fully qualified file name


     savetSR.yCoord.FetchDataFromTMatrix(rowRange,colRange,tSRIn.yCoord) ;
     savetSR.xCoord.FetchDataFromTMatrix('1',colRange,tSRIn.xCoord) ;

     try
     if pos('csv', fileExt) > 0 then
        savetSR.SaveSpectraDelimExcel(nameStr, ',')
     else if pos('txt', fileExt) > 0 then
        savetSR.SaveSpectraDelimExcel(nameStr, ' ')
     else if pos('bin', fileExt) > 0 then
        savetSR.SaveSpectraRangeDataBinV3(nameStr)
     else if pos('spc', fileExt) > 0 then
     begin
       saveSPC  := ReadWriteSPC.Create ;
       saveSPC.WriteSPCDataFromSpectraRange(nameStr, savetSR) ;
       saveSPC.Free ;
     end
     else if pos('raw', fileExt) > 0 then
     begin
       savetSR.YCoord.ReverseByteOrder ;
       savetSR.YCoord.F_Mdata.SaveToFile(nameStr) ;
     end ;
     finally
        Form4.StatusBar1.Panels[1].Text := 'Saved file: ' +  nameStr ;
        Form4.StatusBar1.Refresh ;
     end;

     savetSR.Free ;
   end;

  result := lineNum ;
  bB.Free ;
  nameList.Free ;
end;

//'type = interleave'
//'order and row ranges ='
//'1:1-'
//'2:6-'
//'3:6-'
//'4:6-'
// 'column range = 1-'
//'filename = _interleaved.bin'
// This function squences through the selected rows, in order specified by the pre-colon value
// and copies the row ranges as specified in the post-colon range
function TForm3.InterleaveSpectraRanges(initialLineNumIn: integer; tStrListIn: TStringList) : integer ;
var
  t1 : integer ;
  linenum, selectedRowNum, numColsFromRange, numRowsInteger, selectedSRInt : integer ;
  nameStr, tstr1 : string ;
  rowRange, colRange : string ;
  orderList, rangeList : TStringList ;
  interleavedSR, currentSR : TSpectraRanges ;
  bB : TBatchbasics ;
  colsMS : TMemoryStream ;
  fetchedRowTM : TMatrix ;
begin
   bB  := TBatchBasics.Create ;

  orderList := TStringList.Create ;
  rangeList := TStringList.Create ;
  linenum:= initialLineNumIn ;

   repeat
     inc(lineNum) ;
     tstr1 := bB.GetStringFromStrList(tStrListIn, lineNum) ;
   until (trim(tstr1) <> '') or (lineNum > tStrListIn.Count)  ;
   if bB.LeftSideOfEqual(tstr1) = 'order and row ranges' then
   begin
      inc(lineNum) ;
      tstr1 := bB.GetStringFromStrList(tStrListIn, lineNum) ;
      while (trim(tstr1) <> '') and (lineNum < tStrListIn.Count) and (bB.LeftSideOfEqual(tstr1)<>'column range') do
      begin
       orderList.Add(copy(tstr1,1,pos(':',tstr1)-1)) ;  // this is the order in the GUI string grid that data should go in
       rangeList.Add(copy(tstr1,pos(':',tstr1)+1,length(tstr1)-pos(':',tstr1)));
       inc(lineNum) ;
       tstr1 := bB.GetStringFromStrList(tStrListIn, lineNum) ;
      end;
   end;

   colRange :=  bB.RightSideOfEqual(tstr1) ;
   if trim(colRange) = '' then
   begin
    result := lineNum ;
    messagedlg('column range value is not specified.',mtError,[mbOK],0) ;
    exit ;
   end;
   
   repeat
     inc(lineNum) ;
     tstr1 := bB.GetStringFromStrList(tStrListIn, lineNum) ;
   until (trim(tstr1) <> '') or (lineNum > tStrListIn.Count)  ;
   if bB.LeftSideOfEqual(tstr1) = 'filename' then
   nameStr :=  bB.RightSideOfEqual(tstr1) ;

   SelectStrLst.SortListNumeric ;
   selectedRowNum := StrToInt(SelectStrLst.Strings[strtoint(orderList.Strings[0])-1]) ;
   currentSR := TSpectraRanges(Form4.StringGrid1.Objects[Form4.StringGrid1.Col,selectedRowNum]) ;
   // we should check that all spectra are same precission, and same yCoord.numCols length
   if copy(colRange,length(colRange)-1,1) = '-' then
       colRange := colRange +  inttostr(currentSR.yCoord.numCols) ;

   // determine the number of columns in each spectra
   colsMS := TMemoryStream.Create ;
   numColsFromRange := currentSR.xCoord.GetTotalRowsColsFromString(colRange, colsMS) ;
   colsMS.Free ;
   // new tSR to place data into
   interleavedSR := TSpectraRanges.Create(currentSR.yCoord.SDPrec,0,0,nil) ;


   // determine the number of rows to be added per SpectraRange selected
   colsMS := TMemoryStream.Create ;
   rowRange := rangeList.Strings[0] ;
   if pos('-',trim(rowRange)) = length(trim(rowRange)) then       // sampleRange string is open ended (e.g. '12-')
    rowRange := rowRange + inttostr(currentSR.yCoord.numRows) ;
   numRowsInteger := currentSR.xCoord.GetTotalRowsColsFromString(rowRange, colsMS) ;
   colsMS.Free ;

   // Now numRowsInteger is determined then make sure ranges are single integers that represent
   // the strating rows to merge. These values will be incremented after each row is extracted and merged
   // in the final merged SR
   for t1 := 0 to rangeList.Count - 1 do
   begin
     rowRange := rangeList.Strings[t1] ;
     if pos('-',trim(rowRange)) > 0 then       // sampleRange string is open ended (e.g. '12-')
       rowRange := copy(rowRange,1,pos('-',trim(rowRange))-1) ;
     rangeList.Strings[t1] := rowRange ;
   end;

   // copy the xCoord data
   fetchedRowTM := TMatrix.Create(currentSR.yCoord.SDPrec) ;
   fetchedRowTM.FetchDataFromTMatrix('1',colRange,currentSR.xCoord) ;
   interleavedSR.xCoord.CopyMatrix(fetchedRowTM);

   // extract each row alternately from the list of SpectraRanges and add to the interleaved version
   for t1 := 0 to (orderList.Count * numRowsInteger) - 1 do
   begin
     selectedSRInt  := strtoint(orderList.Strings[t1 mod orderList.Count])-1 ; // subtract 1 as Strings[] are in 0 referenced order
     selectedRowNum := StrToInt(SelectStrLst.Strings[selectedSRInt]) ;
     rowRange       := rangeList.Strings[t1 mod orderList.Count] ;    // this should be a single integer
     currentSR      := TSpectraRanges(Form4.StringGrid1.Objects[Form4.StringGrid1.Col,selectedRowNum]) ;

     fetchedRowTM.FetchDataFromTMatrix(rowRange,colRange,currentSR.yCoord) ;
     interleavedSR.yCoord.AddRowToEndOfData(fetchedRowTM,1,numColsFromRange);

     rowRange := inttostr( strtoint(rowRange) + 1 );   // increment the row to be inserted next time around
     if strtoint(rowRange) > currentSR.yCoord.numRows then
       break ;
     
     rangeList.Strings[t1 mod orderList.Count] := rowRange ;
   end;

   fetchedRowTM.Free ;
   bB.Free ;
   orderList.Free ;
   rangeList.Free ;
   result := lineNum ;

   selectedRowNum := StrToInt(SelectStrLst.Strings[0]) ;
   Form4.StringGrid1.Objects[3,selectedRowNum] := interleavedSR ;
   interleavedSR.GLListNumber := Form4.GetLowestListNumber ;
   interleavedSR.SetOpenGLXYRange(Form2.GetWhichLineToDisplay()) ;
   interleavedSR.zHigh :=  0 ;
   interleavedSR.zLow :=   0  ;
   if (interleavedSR.lineType > MAXDISPLAYTYPEFORSPECTRA) or (interleavedSR.lineType < 1)  then interleavedSR.lineType := 1 ;  //
   interleavedSR.CreateGLList('1-',Form1.Canvas.Handle, RC, Form2.GetWhichLineToDisplay(),  interleavedSR.lineType )   ;
   Form4.StringGrid1.Cells[3,selectedRowNum] := '1-'+ inttostr(interleavedSR.yCoord.numRows) +' : 1-' + inttostr(interleavedSR.yCoord.numCols) ;
   interleavedSR.xString := currentSR.xString ;
   interleavedSR.yString := currentSR.yString  ;


end;




procedure TForm3.Run1Click(Sender: TObject);
var
   lineNum : integer ;
   lineNumStr : string ;
   t1, t2, iter : integer ;
   s1, s2 : single ;

   tStrList : TStringList ;
   tstr1, tstr2, tFilename  : string ;
   // variables for batch processing
   resBool : boolean ;

   bFE    : TPassBatchFileToExecutable ;

   tIRPol : TIRPolAnalysis2 ;
   tPLM   : TPLMAnalysis ;
   tYPredict : TPLSYPredictTestBatch ;
   t2DCorrel : T2DCorrelation ;
   tPeakRatio :  TAreaRatio ;
   tDichroicRatioObj : TDichroicRatio ;
   tAutoProject : TAutoProjectEVects ;
   tRotateVect  : TRotateFactor3D ;
   tRotateFitScores  : TRotateToFitScores ;

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
              colArray := CreateStringGridRowAndObjects8();
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
          else if (bB.RightSideOfEqual(tstr1) = 'save rows') then
          begin
              // this saves specified rows as a specified file name and file type to a specified directory
              // this is the selected col and row
              tSR := TSpectraRanges(Form4.StringGrid1.Objects[Form4.StringGrid1.Col,Form4.StringGrid1.Row]) ;
              inc(lineNum) ;
              lineNum := SaveRowsAsFilenames(lineNum, tStrList, tSR) ;

              for t1 :=  initialLineNum to lineNum -1 do
              begin
                 tSR.batchList.Add(bB.GetStringFromStrList(tStrList, t1)) ;
              end ;
              repeat
                 inc(lineNum) ;
                 tstr1 := bB.GetStringFromStrList(tStrList, lineNum) ;
              until (trim(tstr1) <> '') or (linenum > tStrList.Count)  ;
          end
          else if (bB.RightSideOfEqual(tstr1) = 'interleave') then
          begin
              BatchMemo1.Lines.Add('type = interleave') ;
              // this function squences through the selected rows, in order specified by the pre-colon value
              // and copies the row ranges as specified in the post-colon range
              tSR := TSpectraRanges(Form4.StringGrid1.Objects[Form4.StringGrid1.Col,Form4.StringGrid1.Row]) ;
              inc(lineNum) ;
              lineNum := InterleaveSpectraRanges(lineNum, tStrList) ;

              for t1 :=  initialLineNum to lineNum -1 do
              begin
                 tSR.batchList.Add(bB.GetStringFromStrList(tStrList, t1)) ;
              end ;
              repeat
                 inc(lineNum) ;
                 tstr1 := bB.GetStringFromStrList(tStrList, lineNum) ;
              until (trim(tstr1) <> '') or (linenum > tStrList.Count)  ;
          end
          else if (bB.RightSideOfEqual(tstr1) = 'area ratio') then
          begin
              tSR := TSpectraRanges(Form4.StringGrid1.Objects[2,Form4.StringGrid1.Row]) ;  // this is the selected row

              tPeakRatio := TAreaRatio.Create(tSR.xCoord.SDPrec div 4) ;   // this has to be freed on deletion of row or close of appliction
              lineNum := tPeakRatio.GetAreaRatioBatchArguments(lineNum, iter, tStrList) ;

              // ******** CREATE NEW ROW IN STRING GRID  ********
              // create new line and objects in StringGrid using CreateStringGridRowAndObjects
              colArray := CreateStringGridRowAndObjects8() ;

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
              colArray := CreateStringGridRowAndObjects8( ) ;

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
              if tSR.fft.dtime  <> 0 then
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
          else if (bB.RightSideOfEqual(tstr1) = 'matrix correlation') then     //   type = matrix
          begin
            lineNum :=  CorrelateMatrix(lineNum) ; // function defined above
            repeat
                 inc(lineNum) ;
                 tstr1 := bB.GetStringFromStrList(tStrList, lineNum) ;
            until (trim(tstr1) <> '') or (linenum > tStrList.Count)  ;

          end
          else if (bB.RightSideOfEqual(tstr1) = 'leverage') then     //   type = matrix
          begin
            lineNum :=  Leverage(lineNum) ; // function defined above
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
              if tSR.fft.dtime  <> 0 then
                    tRotateVect.RotatedPC1.fft.CopyFFTObject(tSR.fft) ;

              Form4.StringGrid1.Objects[4,Form4.StringGrid1.RowCount-2] := tRotateVect.RotatedPC1;
              tRotateVect.RotatedPC1.GLListNumber := Form4.GetLowestListNumber ;
              tRotateVect.RotatedPC1.SetOpenGLXYRange(Form2.GetWhichLineToDisplay());
              tRotateVect.RotatedPC1.CreateGLList('1-',Form1.Canvas.Handle, RC, Form2.GetWhichLineToDisplay(), 1)   ;
              Form4.StringGrid1.Cells[4,Form4.StringGrid1.RowCount-2] := tRotateVect.RotatedPC1.ReturnRowColRangeString ;
              tRotateVect.RotatedPC1.xString := tSR2.xString ;
              tRotateVect.RotatedPC1.yString := tSR2.yString  ;
              if tSR.fft.dtime  <> 0 then
                    tRotateVect.RotatedPC1.fft.CopyFFTObject(tSR.fft) ;

              Form4.StringGrid1.Objects[5,Form4.StringGrid1.RowCount-2] := tRotateVect.RotatedPC2;
              tRotateVect.RotatedPC2.GLListNumber := Form4.GetLowestListNumber ;
              tRotateVect.RotatedPC2.SetOpenGLXYRange(Form2.GetWhichLineToDisplay());
              tRotateVect.RotatedPC2.CreateGLList('1-',Form1.Canvas.Handle, RC, Form2.GetWhichLineToDisplay(), 1)   ;
              Form4.StringGrid1.Cells[5,Form4.StringGrid1.RowCount-2] := tRotateVect.RotatedPC2.ReturnRowColRangeString ;
              tRotateVect.RotatedPC2.xString := tSR2.xString ;
              tRotateVect.RotatedPC2.yString := tSR2.yString  ;
              if tSR.fft.dtime  <> 0 then
                    tRotateVect.RotatedPC2.fft.CopyFFTObject(tSR.fft) ;

              Form4.StringGrid1.Objects[6,Form4.StringGrid1.RowCount-2] := tRotateVect.RotatedPC3;
              tRotateVect.RotatedPC3.GLListNumber := Form4.GetLowestListNumber ;
              tRotateVect.RotatedPC3.SetOpenGLXYRange(Form2.GetWhichLineToDisplay());
              tRotateVect.RotatedPC3.CreateGLList('1-',Form1.Canvas.Handle, RC, Form2.GetWhichLineToDisplay(), 1)   ;
              Form4.StringGrid1.Cells[6,Form4.StringGrid1.RowCount-2] := tRotateVect.RotatedPC3.ReturnRowColRangeString ;
              tRotateVect.RotatedPC3.xString := tSR2.xString ;
              tRotateVect.RotatedPC3.yString := tSR2.yString  ;
              if tSR.fft.dtime  <> 0 then
                    tRotateVect.RotatedPC3.fft.CopyFFTObject(tSR.fft) ;

              Form4.StringGrid1.Objects[7,Form4.StringGrid1.RowCount-2] := tRotateVect.combinedRotatedXYZ;
              tRotateVect.combinedRotatedXYZ.GLListNumber := Form4.GetLowestListNumber ;
              tRotateVect.combinedRotatedXYZ.SetOpenGLXYRange(Form2.GetWhichLineToDisplay());
              tRotateVect.combinedRotatedXYZ.CreateGLList('1-',Form1.Canvas.Handle, RC, Form2.GetWhichLineToDisplay(), 1)   ;
              Form4.StringGrid1.Cells[7,Form4.StringGrid1.RowCount-2] := tRotateVect.combinedRotatedXYZ.ReturnRowColRangeString ;
              tRotateVect.combinedRotatedXYZ.xString := tSR2.xString ;
              tRotateVect.combinedRotatedXYZ.yString := tSR2.yString  ;
              if tSR.fft.dtime  <> 0 then
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
              if tSR.fft.dtime  <> 0 then
                    tRotateFitScores.allXData.fft.CopyFFTObject(tSR.fft) ;


              Form4.StringGrid1.Objects[3,Form4.StringGrid1.RowCount-2] :=  tRotateFitScores.origEVectSpectra ;
              tRotateFitScores.origEVectSpectra.SetTGLColourData( tRotateFitScores.AllXData.LineColor ) ;
              tRotateFitScores.origEVectSpectra.GLListNumber := Form4.GetLowestListNumber ;
              if tSR.frequencyImage then
                tRotateFitScores.origEVectSpectra.nativeImage := true ;
              SetupNativeMatrixAs1D_or_2D( tRotateFitScores.origEVectSpectra, tSR ) ;
  //            tRotateFitScores.origEVectSpectra.CreateGLList('1-',Form1.Canvas.Handle, RC, Form2.GetWhichLineToDisplay(), 1)   ;
              Form4.StringGrid1.Cells[3,Form4.StringGrid1.RowCount-2] := tRotateFitScores.origEVectSpectra.ReturnRowColRangeString ;
              if tSR.fft.dtime  <> 0 then
                    tRotateFitScores.origEVectSpectra.fft.CopyFFTObject(tSR.fft) ;


              Form4.StringGrid1.Objects[4,Form4.StringGrid1.RowCount-2] :=  tRotateFitScores.scoresNew ;
              tRotateFitScores.scoresNew.SetTGLColourData( tRotateFitScores.AllXData.LineColor ) ;
              tRotateFitScores.scoresNew.GLListNumber := Form4.GetLowestListNumber ;
              if tSR.frequencyImage then
                tRotateFitScores.scoresNew .nativeImage := true ;
              SetupNativeMatrixAs1D_or_2D( tRotateFitScores.scoresNew, tSR ) ;
//              tRotateFitScores.scoresNew.CreateGLList('1-',Form1.Canvas.Handle, RC, Form2.GetWhichLineToDisplay(), 1)   ;
              Form4.StringGrid1.Cells[4,Form4.StringGrid1.RowCount-2] := tRotateFitScores.scoresNew.ReturnRowColRangeString ;
              if tSR.fft.dtime  <> 0 then
                    tRotateFitScores.scoresNew.fft.CopyFFTObject(tSR.fft) ;

              Form4.StringGrid1.Objects[5,Form4.StringGrid1.RowCount-2] :=  tRotateFitScores.rotatedVectSpectra ;
              tRotateFitScores.rotatedVectSpectra.SetTGLColourData( tRotateFitScores.AllXData.LineColor ) ;
              tRotateFitScores.rotatedVectSpectra.GLListNumber := Form4.GetLowestListNumber ;
              if tSR.frequencyImage then
                tRotateFitScores.rotatedVectSpectra.nativeImage := true ;
              SetupNativeMatrixAs1D_or_2D( tRotateFitScores.rotatedVectSpectra, tSR ) ;
//              tRotateFitScores.rotatedVectSpectra.CreateGLList('1-',Form1.Canvas.Handle, RC, Form2.GetWhichLineToDisplay(), 1)   ;
              Form4.StringGrid1.Cells[5,Form4.StringGrid1.RowCount-2] := tRotateFitScores.rotatedVectSpectra.ReturnRowColRangeString ;
              if tSR.fft.dtime  <> 0 then
                    tRotateFitScores.rotatedVectSpectra.fft.CopyFFTObject(tSR.fft) ;


              Form4.StringGrid1.Objects[7,Form4.StringGrid1.RowCount-2] :=  tRotateFitScores.ResidualXData ;
              tRotateFitScores.ResidualXData.SetTGLColourData( tRotateFitScores.AllXData.LineColor ) ;
              tRotateFitScores.ResidualXData.GLListNumber := Form4.GetLowestListNumber ;
              if tSR.frequencyImage then
                tRotateFitScores.ResidualXData.nativeImage := true ;
              SetupNativeMatrixAs1D_or_2D( tRotateFitScores.ResidualXData, tSr ) ;
//              tRotateFitScores.ResidualXData.CreateGLList('1-',Form1.Canvas.Handle, RC, Form2.GetWhichLineToDisplay(), 1)   ;
              Form4.StringGrid1.Cells[7,Form4.StringGrid1.RowCount-2] := tRotateFitScores.ResidualXData.ReturnRowColRangeString ;
              if tSR.fft.dtime  <> 0 then
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


          // 1/ input part
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

            // 2/ this function does the multiply/divide
            lineNum :=  VectorMultiplyOrDivide(lineNum, AddOrSubtractOperation, vectorPrefactor, tstr2) ;

            // 3/ this tidys up the remaining lines
            repeat
                 inc(lineNum) ;
                 tstr1 := bB.GetStringFromStrList(tStrList, lineNum) ;
            until (trim(tstr1) <> '') or (linenum > tStrList.Count)  ;


          end

          else if (bB.RightSideOfEqual(tstr1) = 'pcr') then
          begin
             try

              // ******** CREATE NEW ROW IN STRING GRID  ********
              // create new line and objects in StringGrid using CreateStringGridRowAndObjects
              // this creates LineColour
              colArray := CreateStringGridRowAndObjects8( ) ;
              bFE := TPassBatchFileToExecutable.Create( Form2.MVA_executable ) ; // MVA_executable is external executable path and name
              bFE.lineCol :=  colArray ;
              tstr2 :=  bFE.ReadBatchSection(tStrList,lineNum) ; // returns current line number in tStrList batch file
              if pos(',', tstr2) <> 0 then                       // or returns line number + ',' + errorstring
              begin
               // error occured (as ',' was found in return value :
               // remove added row from StringGrid1
                bFE.Free ;
                RemoveRow('PCR code error, line '+tstr2 ) ;
                lineNum := strtoint(copy(tstr2,1,pos(',',tstr2)-1)) ;

                tstr1 := bB.GetStringFromStrList(tStrList,lineNum) ;
                while (bB.LeftSideOfEqual(tstr1) <> 'type')  and (lineNum <= tStrList.Count)  do
                begin
                  inc(lineNum) ;
                  tstr1 := bB.GetStringFromStrList(tStrList,lineNum) ;
                end;
              end
              else
              begin
                Form4.StringGrid1.Cells[1,Form4.StringGrid1.RowCount-2]  := 'PID: PCR' + bFE.batchFilename ;
                Form4.StringGrid1.Objects[1,Form4.StringGrid1.RowCount-2]  := bFE ;
                lineNum := strtoint(copy(tstr2,1,length(tstr2))) ;
              end;


            except
            begin
              RemoveRow('PCR code encountered a problem') ;
              bFE.Free ;
            end;
            end ;
          end
          else if  (bB.RightSideOfEqual(tstr1) = 'pls1') then
          begin
             try

              // ******** CREATE NEW ROW IN STRING GRID  ********
              // create new line and objects in StringGrid using CreateStringGridRowAndObjects
              // this creates LineColour
              colArray := CreateStringGridRowAndObjects8( ) ;
              bFE := TPassBatchFileToExecutable.Create( Form2.MVA_executable ) ; // MVA_executable is external executable path and name
              bFE.lineCol :=  colArray ;
              tstr2 :=  bFE.ReadBatchSection(tStrList,lineNum) ; // returns current line number in tStrList batch file
              if pos(',', tstr2) <> 0 then                       // or returns line number + ',' + errorstring
              begin
               // error occured (as ',' was found in return value :
               // remove added row from StringGrid1
                bFE.Free ;
                RemoveRow('PLS code encountered a problem '+tstr2 ) ;
                lineNum := strtoint(copy(tstr2,1,pos(',',tstr2)-1)) ;

                tstr1 := bB.GetStringFromStrList(tStrList,lineNum) ;
                while (bB.LeftSideOfEqual(tstr1) <> 'type')  and (lineNum <= tStrList.Count)  do
                begin
                  inc(lineNum) ;
                  tstr1 := bB.GetStringFromStrList(tStrList,lineNum) ;
                end;
              end
              else
              begin
                Form4.StringGrid1.Cells[1,Form4.StringGrid1.RowCount-2]  := 'PID: PLS' + bFE.batchFilename ;
                Form4.StringGrid1.Objects[1,Form4.StringGrid1.RowCount-2]  := bFE ;
                lineNum := strtoint(copy(tstr2,1,length(tstr2))) ;
              end;


            except
            begin
              RemoveRow('PLS code encountered a problem') ;
              bFE.Free ;
            end;
            end ;
          end
          else if  (bB.RightSideOfEqual(tstr1) = 'ils') then
          begin
             try

              // ******** CREATE NEW ROW IN STRING GRID  ********
              // create new line and objects in StringGrid using CreateStringGridRowAndObjects
              // this creates LineColour
              colArray := CreateStringGridRowAndObjects8( ) ;
              bFE := TPassBatchFileToExecutable.Create( Form2.MVA_executable ) ; // MVA_executable is external executable path and name
              bFE.lineCol :=  colArray ;
              tstr2 :=  bFE.ReadBatchSection(tStrList,lineNum) ; // returns current line number in tStrList batch file
              if pos(',', tstr2) <> 0 then                       // or returns line number + ',' + errorstring
              begin
               // error occured (as ',' was found in return value :
               // remove added row from StringGrid1
                bFE.Free ;
                RemoveRow('ILS code encountered a problem '+tstr2 ) ;
                lineNum := strtoint(copy(tstr2,1,pos(',',tstr2)-1)) ;

                tstr1 := bB.GetStringFromStrList(tStrList,lineNum) ;
                while (bB.LeftSideOfEqual(tstr1) <> 'type')  and (lineNum <= tStrList.Count)  do
                begin
                  inc(lineNum) ;
                  tstr1 := bB.GetStringFromStrList(tStrList,lineNum) ;
                end;
              end
              else
              begin
                Form4.StringGrid1.Cells[1,Form4.StringGrid1.RowCount-2]  := 'PID: ILS' + bFE.batchFilename ;
                Form4.StringGrid1.Objects[1,Form4.StringGrid1.RowCount-2]  := bFE ;
                lineNum := strtoint(copy(tstr2,1,length(tstr2))) ;
              end;

            except
            begin
              RemoveRow('ILS code encountered a problem') ;
              bFE.Free ;
            end;
            end ;
          end
          else if  (bB.RightSideOfEqual(tstr1) = 'predict y') then
          begin
             try

              // ******** CREATE NEW ROW IN STRING GRID  ********
              // create new line and objects in StringGrid using CreateStringGridRowAndObjects
              // this creates LineColour
              colArray := CreateStringGridRowAndObjects8( ) ;
              bFE := TPassBatchFileToExecutable.Create( Form2.MVA_executable ) ; // MVA_executable is external executable path and name
              bFE.lineCol :=  colArray ;
              tstr2 :=  bFE.ReadBatchSection(tStrList,lineNum) ; // returns current line number in tStrList batch file
              if pos(',', tstr2) <> 0 then                       // or returns line number + ',' + errorstring
              begin
               // error occured (as ',' was found in return value :
               // remove added row from StringGrid1
                bFE.Free ;
                RemoveRow('Predict Y code encountered a problem '+tstr2 ) ;
                lineNum := strtoint(copy(tstr2,1,pos(',',tstr2)-1)) ;

                tstr1 := bB.GetStringFromStrList(tStrList,lineNum) ;
                while (bB.LeftSideOfEqual(tstr1) <> 'type')  and (lineNum <= tStrList.Count)  do
                begin
                  inc(lineNum) ;
                  tstr1 := bB.GetStringFromStrList(tStrList,lineNum) ;
                end;
              end
              else
              begin
                Form4.StringGrid1.Cells[1,Form4.StringGrid1.RowCount-2]  := 'PID: Predict Y' + bFE.batchFilename ;
                Form4.StringGrid1.Objects[1,Form4.StringGrid1.RowCount-2]  := bFE ;
                lineNum := strtoint(copy(tstr2,1,length(tstr2))) ;
              end;


            except
            begin
              RemoveRow('Predict Y code encountered a problem') ;
              bFE.Free ;
            end;
            end ;
          end
          else if  (bB.RightSideOfEqual(tstr1) = 'pca') then
          begin
             try
              // ******** CREATE NEW ROW IN STRING GRID  ********
              // create new line and objects in StringGrid using CreateStringGridRowAndObjects
              // this creates LineColour
              colArray := CreateStringGridRowAndObjects8( ) ;
              bFE := TPassBatchFileToExecutable.Create( Form2.MVA_executable ) ; // MVA_executable is external executable path and name
              bFE.lineCol :=  colArray ;
              tstr2 :=  bFE.ReadBatchSection(tStrList,lineNum) ; // returns current line number in tStrList batch file
              if pos(',', tstr2) <> 0 then                       // or returns line number + ',' + errorstring
              begin
               // error occured (as ',' was found in return value :
               // remove added row from StringGrid1
                bFE.Free ;
                RemoveRow('PCA code encountered a problem '+tstr2 ) ;
                lineNum := strtoint(copy(tstr2,1,pos(',',tstr2)-1)) ;

                tstr1 := bB.GetStringFromStrList(tStrList,lineNum) ;
                while (bB.LeftSideOfEqual(tstr1) <> 'type')  and (lineNum <= tStrList.Count)  do
                begin
                  inc(lineNum) ;
                  tstr1 := bB.GetStringFromStrList(tStrList,lineNum) ;
                end;
              end
              else
              begin
                Form4.StringGrid1.Cells[1,Form4.StringGrid1.RowCount-2]  := 'PID: PCA' + bFE.batchFilename ;
                Form4.StringGrid1.Objects[1,Form4.StringGrid1.RowCount-2]  := bFE ;
                lineNum := strtoint(copy(tstr2,1,length(tstr2))) ;
              end;


            except
            begin
              RemoveRow('PCA code encountered a problem') ;
              bFE.Free ;
            end;
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
              if tSR.fft.dtime  <> 0 then
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
              if tSR.fft.dtime  <> 0 then
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
              if tSR.fft.dtime  <> 0 then
                    tAutoProject.XresidualsSpectra.fft.CopyFFTObject(tSR.fft) ;

              Form4.StringGrid1.Objects[8,Form4.StringGrid1.RowCount-2] := tAutoProject.regenSpectra ;
              tAutoProject.regenSpectra.GLListNumber := Form4.GetLowestListNumber ;
              if tSR.frequencyImage then
                tAutoProject.regenSpectra.frequencyImage := true ;
              SetupallXDataAs1D_or_2D(1, tAutoProject.regenSpectra , tSR) ;
              Form4.StringGrid1.Cells[8,Form4.StringGrid1.RowCount-2] := tAutoProject.regenSpectra.ReturnRowColRangeString ;
              tAutoProject.regenSpectra.xString := tAutoProject.allXData.xString ;
              tAutoProject.regenSpectra.yString := tAutoProject.allXData.yString  ;
              if tSR.fft.dtime  <> 0 then
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
              colArray := CreateStringGridRowAndObjects8(  ) ;

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

procedure TForm3.SetExecutable2Click(Sender: TObject);
var
  presentDir : string ;
begin
  Form4.OpenDialog1.Filter := 'exe files (*.exe)|all files (*.*)|*.*'    ;
  Form4.OpenDialog1.Title := 'Load exe file' ;
  Form4.OpenDialog1.DefaultExt := '*.exe' ;
  Form4.OpenDialog1.filename := '*.exe' ;

  With Form4.OpenDialog1 do
  begin
    Form4.OpenDialog1.FileName :=  Form2.MVA_executable ;
    GetDir(0,presentDir) ;
    if DirectoryExists(ExtractFilePath(Form2.MVA_executable)) then
       ChDir( ExtractFilePath(Form2.MVA_executable) ) ;
    
    if Execute Then
    begin
       Form2.MVA_executable := filename ;
    end ;

    ChDir(presentDir) ; // change back to original directory
  end ;
end;

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
  if Form4.StringGrid1.Objects[1,lineNum] is TSpectraRanges then
    TSpectraRanges(Form4.StringGrid1.Objects[1,lineNum]).Free ;
  if Form4.StringGrid1.Objects[2,lineNum] is TSpectraRanges then
    TSpectraRanges(Form4.StringGrid1.Objects[2,lineNum]).Free ;
  if Form4.StringGrid1.Objects[3,lineNum] is TSpectraRanges then
    TSpectraRanges(Form4.StringGrid1.Objects[3,lineNum]).Free ;
  if Form4.StringGrid1.Objects[4,lineNum] is TSpectraRanges then
    TSpectraRanges(Form4.StringGrid1.Objects[4,lineNum]).Free ;
  if Form4.StringGrid1.Objects[5,lineNum] is TSpectraRanges then
    TSpectraRanges(Form4.StringGrid1.Objects[5,lineNum]).Free ;
  if Form4.StringGrid1.Objects[6,lineNum] is TSpectraRanges then
    TSpectraRanges(Form4.StringGrid1.Objects[6,lineNum]).Free ;
  if Form4.StringGrid1.Objects[7,lineNum] is TSpectraRanges then
    TSpectraRanges(Form4.StringGrid1.Objects[7,lineNum]).Free ;
  if Form4.StringGrid1.Objects[8,lineNum] is TSpectraRanges then
    TSpectraRanges(Form4.StringGrid1.Objects[8,lineNum]).Free ;
  if Form4.StringGrid1.Objects[9,lineNum] is TSpectraRanges then
    TSpectraRanges(Form4.StringGrid1.Objects[9,lineNum]).Free ;
  if Form4.StringGrid1.Objects[10,lineNum] is TSpectraRanges then
    TSpectraRanges(Form4.StringGrid1.Objects[10,lineNum]).Free ;
  if Form4.StringGrid1.Objects[11,lineNum] is TSpectraRanges then
    TSpectraRanges(Form4.StringGrid1.Objects[11,lineNum]).Free ;
  if Form4.StringGrid1.Objects[12,lineNum] is TSpectraRanges then
    TSpectraRanges(Form4.StringGrid1.Objects[12,lineNum]).Free ;
  if Form4.StringGrid1.Objects[13,lineNum] is TSpectraRanges then
    TSpectraRanges(Form4.StringGrid1.Objects[13,lineNum]).Free ;

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
  Form4.StatusBar1.Panels[1].Text :=  messasge ;
  Form4.StatusBar1.Hint := messasge ;
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



function TForm3.CreateStringGridRowAndObjects8() : TGLLineColor ;
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
        result := ReturnLineColor(IntensityList, 2)  ;
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
   BatchMemo1.Lines.Add('type = PLS1  // edit choice to PLS1 *OR* PCR') ;
   BatchMemo1.Lines.Add('batch filename = analysis.bat') ;
   BatchMemo1.Lines.Add('// input x and y data') ;

   BatchMemo1.Lines.Add('x data file = x.bin') ;
   BatchMemo1.Lines.Add('y data file = y.bin') ;

   BatchMemo1.Lines.Add('x sample range = 1-      // (ROWS)') ;    // can select subset using this
   BatchMemo1.Lines.Add('x var range = 1-65536   // (COLS)') ;
   BatchMemo1.Lines.Add('y in x data = false') ;
   BatchMemo1.Lines.Add('y sample range = 1-     // (ROWS)') ;    // can select subset using this
   BatchMemo1.Lines.Add('y var range = 1-1       // (COLS)') ;
   BatchMemo1.Lines.Add('number of PCs = 1-20') ;
   BatchMemo1.Lines.Add('// pre-processing') ;  //
   BatchMemo1.Lines.Add('mean centre = true') ;  //
   BatchMemo1.Lines.Add('column standardise = false') ;  //
   BatchMemo1.Lines.Add('smooth =   // average,15  // fourier,15,50,remove complex  // %,power') ;  //
   BatchMemo1.Lines.Add('derivative =   // fourier,2,remove complex,true,1 // inputs: "diff type: 1st 2nd deriv etc: true = Hanning Window: 1 2 3 etc = zero fill"  N.B. type=fourier only available;') ;
   BatchMemo1.Lines.Add('normalise x =  // "vn,pre" OR "vn,post" OR "" pre indicates vector normalise before mean centering ') ;
   BatchMemo1.Lines.Add('// EVects output - none of these are used') ;
   BatchMemo1.Lines.Add('positive or negative =  ') ;
   BatchMemo1.Lines.Add('autoexclude =     // 0.75 ') ;
   BatchMemo1.Lines.Add('normalised output = true') ;
   BatchMemo1.Lines.Add('results file = pls1_results.out') ;
   BatchMemo1.Lines.Add('') ;


end;

procedure TForm3.TemplateILSClickClick(Sender: TObject);
begin
   BatchMemo1.Lines.Add('type = ILS // inverse least squares') ;
   BatchMemo1.Lines.Add('batch filename = analysis.bat') ;
   BatchMemo1.Lines.Add('// input (optional)x, y and scores/evectors') ;
   BatchMemo1.Lines.Add('// if x is input then data type = evectors') ;
   BatchMemo1.Lines.Add('// if x is omitted then data type = scores') ;
   BatchMemo1.Lines.Add('x data file  = x.bin') ;
   BatchMemo1.Lines.Add('y data file  = y.bin') ;
   BatchMemo1.Lines.Add('scores file  = scores.bin') ;
   BatchMemo1.Lines.Add('evects file  = evects.bin') ;
   BatchMemo1.Lines.Add('SEP X file   =    // validation data (for SEP) for bootstrap') ;
   BatchMemo1.Lines.Add('SEP Y file   =    // validation data (for SEP) for bootstrap') ;
   BatchMemo1.Lines.Add('bootstrap stats =    // SEC (if original x data present) or SEP (if test data present) or empty for no') ;
   BatchMemo1.Lines.Add('bootstrap iters =    // the number of iterations to go through in the bootstrap procedure') ;
   BatchMemo1.Lines.Add('random seed     = 100 //  if = 0 then calls system.randomize()') ;
   BatchMemo1.Lines.Add('individual pcs = true    // if true, model is made with each PC individually otherwise collectively') ;
//   BatchMemo1.Lines.Add('deflate x = false     // true for PLS data ') ;  
   BatchMemo1.Lines.Add('x sample range = 1-     // (ROWS)') ;    // can select subset using this
   BatchMemo1.Lines.Add('x var range = 1-65536   // (COLS)') ;
   BatchMemo1.Lines.Add('y in x data = false') ;
   BatchMemo1.Lines.Add('y sample range = 1-     // (ROWS)') ;    // can select subset using this
   BatchMemo1.Lines.Add('y var range = 1-1       // (COLS)') ;
   BatchMemo1.Lines.Add('// if bootstrap stats =  SEP then these need to be specified') ;
   BatchMemo1.Lines.Add('SEP x sample range = 1-        // (ROWS)') ;
   BatchMemo1.Lines.Add('SEP x var range    = 1-65536   // (COLS)') ;
   BatchMemo1.Lines.Add('SEP y sample range = 1-        // (ROWS)') ;
   BatchMemo1.Lines.Add('SEP y var range    = 6-6       // (COLS)') ;
   BatchMemo1.Lines.Add('number of PCs = 1-20    // has to be <= evects.rows or scores.cols. Selected range used to make regression model') ;
   BatchMemo1.Lines.Add('// pre-processing') ;  //
   BatchMemo1.Lines.Add('mean centre = true') ;  //
   BatchMemo1.Lines.Add('column standardise = false') ;  //
   BatchMemo1.Lines.Add('smooth =   // average,15  // fourier,15,50,remove complex  // %,power') ;  //
   BatchMemo1.Lines.Add('derivative =   // fourier,2,remove complex,true,1 // inputs: "diff type: 1st 2nd deriv etc: true = Hanning Window: 1 2 3 etc = zero fill"  N.B. type=fourier only available;') ;
   BatchMemo1.Lines.Add('normalise x =  // "vn,pre" OR "vn,post" OR "" pre indicates vector normalise before mean centering ') ;

   BatchMemo1.Lines.Add('// EVects output - none of these are used') ;
   BatchMemo1.Lines.Add('positive or negative =  ') ;
   BatchMemo1.Lines.Add('autoexclude =     // 0.75 ') ;
   BatchMemo1.Lines.Add('normalised output = true') ;
   BatchMemo1.Lines.Add('results file = pls1_results2.out') ;
   BatchMemo1.Lines.Add('') ;
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
   BatchMemo1.Lines.Add('type = PCR  // edit choice to PLS1 *OR* PCR') ;
   BatchMemo1.Lines.Add('batch filename = analysis.bat') ;
   BatchMemo1.Lines.Add('// input x and y data') ;

   BatchMemo1.Lines.Add('x data file = x.bin') ;
   BatchMemo1.Lines.Add('y data file = y.bin') ;

   BatchMemo1.Lines.Add('x sample range = 1-      // (ROWS)') ;    // can select subset using this
   BatchMemo1.Lines.Add('x var range = 1-65536   // (COLS)') ;
   BatchMemo1.Lines.Add('y in x data = false') ;
   BatchMemo1.Lines.Add('y sample range = 1-     // (ROWS)') ;    // can select subset using this
   BatchMemo1.Lines.Add('y var range = 1-1       // (COLS)') ;
   BatchMemo1.Lines.Add('number of PCs = 1-20') ;
   BatchMemo1.Lines.Add('// pre-processing') ;  //
   BatchMemo1.Lines.Add('mean centre = true') ;  //
   BatchMemo1.Lines.Add('column standardise = false') ;  //
   BatchMemo1.Lines.Add('smooth =   // average,15  // fourier,15,50,remove complex  // %,power') ;  //
   BatchMemo1.Lines.Add('derivative =   // fourier,2,remove complex,true,1 // inputs: "diff type: 1st 2nd deriv etc: true = Hanning Window: 1 2 3 etc = zero fill"  N.B. type=fourier only available;') ;
   BatchMemo1.Lines.Add('normalise x =  // "vn,pre" OR "vn,post" OR "" pre indicates vector normalise before mean centering ') ;
   BatchMemo1.Lines.Add('// EVects output - none of these are used') ;
   BatchMemo1.Lines.Add('positive or negative =  ') ;
   BatchMemo1.Lines.Add('autoexclude =     // 0.75 ') ;
   BatchMemo1.Lines.Add('normalised output = false  // false is best - true is not implemented') ;
   BatchMemo1.Lines.Add('results file = pcr_results.out') ;
   BatchMemo1.Lines.Add('') ;
end;

procedure TForm3.TemplatePCA2Click(Sender: TObject);
begin
   BatchMemo1.Lines.Add('type = PCA') ;
   BatchMemo1.Lines.Add('batch filename = analysis.bat') ;
   BatchMemo1.Lines.Add('x data file = x.bin') ;
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
   BatchMemo1.Lines.Add('smooth =   // average,15  // fourier,15,50,remove complex  // %,power') ;  //
   BatchMemo1.Lines.Add('derivative =   // fourier,2,remove complex,true,1 // inputs: "diff type: 1st 2nd deriv etc: true = Hanning Window: 1 2 3 etc = zero fill"  N.B. type=fourier only available;') ;
   BatchMemo1.Lines.Add('normalise x =  // "vn,pre" OR "vn,post" OR "" pre indicates vector normalise before mean centering ') ;

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
   BatchMemo1.Lines.Add('batch filename = analysis.bat') ;
   BatchMemo1.Lines.Add('// X column: new x data; Y column: Y reference data; Then regression coefficients ') ;
   BatchMemo1.Lines.Add('// input x and y data') ;
   BatchMemo1.Lines.Add('x data file = x.bin') ;
   BatchMemo1.Lines.Add('y data file = y.bin') ;
   BatchMemo1.Lines.Add('reg coef file = regcoef.bin') ;
   BatchMemo1.Lines.Add('x sample range = 1-      // (ROWS)') ;    // can select subset using this
   BatchMemo1.Lines.Add('x var range = 1-65536    // (COLS)') ;
   BatchMemo1.Lines.Add('y in x data = false') ;
   BatchMemo1.Lines.Add('y sample range = 1-      // (ROWS)') ;    // can select subset using this
   BatchMemo1.Lines.Add('y var range = 1-1        // (COLS)') ;
   BatchMemo1.Lines.Add('// pre-processing') ;
   BatchMemo1.Lines.Add('mean centre = true') ;
   BatchMemo1.Lines.Add('column standardise = false') ;
   BatchMemo1.Lines.Add('smooth =   // average,15  // fourier,15,50,remove complex  // %,power') ;
   BatchMemo1.Lines.Add('derivative =   // fourier,2,remove complex,true,1 // inputs: "diff type: 1st 2nd deriv etc: true = Hanning Window: 1 2 3 etc = zero fill"  N.B. type=fourier only available;') ;
   BatchMemo1.Lines.Add('normalise x = // "vn,pre" OR "vn,post" OR "" pre indicates vector normalise before mean centering ') ;

   BatchMemo1.Lines.Add('results file = prediction_results.out') ;
   BatchMemo1.Lines.Add('') ;

{    BatchMemo1.Lines.Add('type = PREDICT Y') ;
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
   BatchMemo1.Lines.Add('') ;    }

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
  BatchMemo1.Lines.Add('operation = subtract  // add') ;
  BatchMemo1.Lines.Add('// Input:   x data and y data matricies (same size)') ;
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
  BatchMemo1.Lines.Add('operation = multiply   // divide') ;
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
