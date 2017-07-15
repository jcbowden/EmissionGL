program EmGL1;

{%TogetherDiagram 'ModelSupport_EmGL1\default.txaPackage'}
{%TogetherDiagram 'ModelSupport_EmGL1\FileInfo\default.txaPackage'}
{%TogetherDiagram 'ModelSupport_EmGL1\TMatrixObject\default.txaPackage'}
{%TogetherDiagram 'ModelSupport_EmGL1\TSpectraRangeObject\default.txaPackage'}
{%TogetherDiagram 'ModelSupport_EmGL1\ColorsEM\default.txaPackage'}
{%TogetherDiagram 'ModelSupport_EmGL1\FFTUnit\default.txaPackage'}
{%TogetherDiagram 'ModelSupport_EmGL1\TAutoProjectEVectsUnit\default.txaPackage'}
{%TogetherDiagram 'ModelSupport_EmGL1\TBatch\default.txaPackage'}
{%TogetherDiagram 'ModelSupport_EmGL1\PLMProcessThread\default.txaPackage'}
{%TogetherDiagram 'ModelSupport_EmGL1\emissionGL\default.txaPackage'}
{%TogetherDiagram 'ModelSupport_EmGL1\TPreprocessUnit\default.txaPackage'}
{%TogetherDiagram 'ModelSupport_EmGL1\TStringListExtUnit\default.txaPackage'}
{%TogetherDiagram 'ModelSupport_EmGL1\TPCABatchObject\default.txaPackage'}
{%TogetherDiagram 'ModelSupport_EmGL1\PLSResultsObjects\default.txaPackage'}
{%TogetherDiagram 'ModelSupport_EmGL1\batchEdit\default.txaPackage'}
{%TogetherDiagram 'ModelSupport_EmGL1\TPCRPredictBatchUnit\default.txaPackage'}
{%TogetherDiagram 'ModelSupport_EmGL1\T2DCorrelObject\default.txaPackage'}
{%TogetherDiagram 'ModelSupport_EmGL1\TMathBatchUnit\default.txaPackage'}
{%TogetherDiagram 'ModelSupport_EmGL1\BatchFileDlg\default.txaPackage'}
{%TogetherDiagram 'ModelSupport_EmGL1\TRotateFactorsUnit\default.txaPackage'}
{%TogetherDiagram 'ModelSupport_EmGL1\PCResultsObjects\default.txaPackage'}
{%TogetherDiagram 'ModelSupport_EmGL1\OpenGL\default.txaPackage'}
{%TogetherDiagram 'ModelSupport_EmGL1\TAreaRatioUnit\default.txaPackage'}
{%TogetherDiagram 'ModelSupport_EmGL1\TBatchBasicFunctions\default.txaPackage'}
{%TogetherDiagram 'ModelSupport_EmGL1\AtlusBLASLAPACLibrary\default.txaPackage'}
{%TogetherDiagram 'ModelSupport_EmGL1\TIRPolAnalysisObject2\default.txaPackage'}
{%TogetherDiagram 'ModelSupport_EmGL1\EmGL1\default.txaPackage'}
{%TogetherDiagram 'ModelSupport_EmGL1\TDichroicRatioUnit\default.txaPackage'}
{%TogetherDiagram 'ModelSupport_EmGL1\TPLMAnalysisUnit1\default.txaPackage'}
{%TogetherDiagram 'ModelSupport_EmGL1\TVarAndCoVarOperations\default.txaPackage'}
{%TogetherDiagram 'ModelSupport_EmGL1\PCAResultsObject\default.txaPackage'}
{%TogetherDiagram 'ModelSupport_EmGL1\StringGridDataViewer\default.txaPackage'}
{%TogetherDiagram 'ModelSupport_EmGL1\TPLSYPredictTestBatchUnit\default.txaPackage'}
{%TogetherDiagram 'ModelSupport_EmGL1\TMatrixOperations\default.txaPackage'}
{%TogetherDiagram 'ModelSupport_EmGL1\SPCFileUnit\default.txaPackage'}
{%TogetherDiagram 'ModelSupport_EmGL1\TRotateToFitScoresUnit\default.txaPackage'}
{%TogetherDiagram 'ModelSupport_EmGL1\TPLSPredictBatchUnit\default.txaPackage'}
{%TogetherDiagram 'ModelSupport_EmGL1\default.txvpck'}
{%TogetherDiagram 'ModelSupport_EmGL1\AtlusBLASLAPACLibrary\default.txvpck'}
{%TogetherDiagram 'ModelSupport_EmGL1\EmGL1\default.txvpck'}
{%TogetherDiagram 'ModelSupport_EmGL1\OpenGL\default.txvpck'}
{%TogetherDiagram 'ModelSupport_EmGL1\TMatrixObject\default.txvpck'}
{%TogetherDiagram 'ModelSupport_EmGL1\FileInfo\default.txvpck'}
{%TogetherDiagram 'ModelSupport_EmGL1\TTiffReadWriteUnit\default.txaPackage'}
{%TogetherDiagram 'ModelSupport_EmGL1\TASMTimerUnit\default.txaPackage'}

uses
  Forms,
  classes,
  emissionGL in 'emissionGL.pas' {Form1},
  ColorsEM in 'ColorsEM.pas' {Form2},
  OpenGL in 'OpenGL.pas',
  FileInfo in 'FileInfo.pas' {Form4},
  AtlusBLASLAPACLibrary in 'AtlusBLASLAPACLibrary.pas',
  PCAResultsObject in 'PCAResultsObject.pas',
  TMatrixObject in 'TMatrixObject.pas',
  PCResultsObjects in 'PCResultsObjects.pas',
  batchEdit in 'batchEdit.pas' {Form3},
  BatchFileDlg in 'BatchFileDlg.pas' {BatchFileModDlg},
  TSpectraRangeObject in 'TSpectraRangeObject.pas',
  StringGridDataViewer in 'StringGridDataViewer.pas' {SGDataView},
  FFTUnit in 'FFTUnit.pas',
  TIRPolAnalysisObject2 in 'TIRPolAnalysisObject2.pas',
  TPCABatchObject in 'TPCABatchObject.pas',
  TBatch in 'TBatch.pas',
  TBatchBasicFunctions in 'TBatchBasicFunctions.pas',
  TMatrixOperations in 'TMatrixOperations.pas',
  T2DCorrelObject in 'T2DCorrelObject.pas',
  TStringListExtUnit in 'TStringListExtUnit.pas',
  TAreaRatioUnit in 'TAreaRatioUnit.pas',
  SPCFileUnit in 'SPCFileUnit.pas',
  TMathBatchUnit in 'TMathBatchUnit.pas',
  TPLMAnalysisUnit1 in 'TPLMAnalysisUnit1.pas',
  PLMProcessThread in 'PLMProcessThread.pas',
  TDichroicRatioUnit in 'TDichroicRatioUnit.pas',
  TPreprocessUnit in 'TPreprocessUnit.pas',
  TPCRPredictBatchUnit in 'TPCRPredictBatchUnit.pas',
  PLSResultsObjects in 'PLSResultsObjects.pas',
  TVarAndCoVarOperations in 'TVarAndCoVarOperations.pas',
  TPLSPredictBatchUnit in 'TPLSPredictBatchUnit.pas',
  TPLSYPredictTestBatchUnit in 'TPLSYPredictTestBatchUnit.pas',
  TAutoProjectEVectsUnit in 'TAutoProjectEVectsUnit.pas',
  TRotateFactorsUnit in 'TRotateFactorsUnit.pas',
  TRotateToFitScoresUnit in 'TRotateToFitScoresUnit.pas',
  TASMTimerUnit in 'TASMTimerUnit.pas',
  TTiffReadWriteUnit in 'TTiffReadWriteUnit.pas';

//  Colorsemission in 'ColorsEmission.pas' {Form3};

{$R *.RES}

// N.B. To enable this feature, add the /3GB switch to the Boot.ini file
const IMAGE_FILE_LARGE_ADDRESS_AWARE = $0020;
{$SetPEFlags IMAGE_FILE_LARGE_ADDRESS_AWARE}


begin

  Application.Initialize;
  Application.CreateForm(TForm4, Form4);
  Application.CreateForm(TForm2, Form2);
  Application.CreateForm(TForm1, Form1);
  Application.CreateForm(TForm3, Form3);
  Application.CreateForm(TBatchFileModDlg, BatchFileModDlg);
  Application.Run;

 end.


