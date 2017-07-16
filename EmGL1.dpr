program EmGL1;



uses
  Forms,
  classes,
  emissionGL in 'emissionGL.pas' {Form1},
  ColorsEM in 'ColorsEM.pas' {Form2},
  OpenGL in 'OpenGL.pas',
  FileInfo in 'FileInfo.pas' {Form4},
  batchEdit in 'batchEdit.pas' {Form3},
  BatchFileDlg in 'BatchFileDlg.pas' {BatchFileModDlg},
  TSpectraRangeObject in 'TSpectraRangeObject.pas',
  StringGridDataViewer in 'StringGridDataViewer.pas' {SGDataView},
  FFTUnit in 'FFTUnit.pas',
  TIRPolAnalysisObject2 in 'TIRPolAnalysisObject2.pas',
  TBatchBasicFunctions in 'TBatchBasicFunctions.pas',
  TMatrixOperations in 'TMatrixOperations.pas',
  T2DCorrelObject in 'T2DCorrelObject.pas',
  TStringListExtUnit in 'TStringListExtUnit.pas',
  TAreaRatioUnit in 'TAreaRatioUnit.pas',
  SPCFileUnit in 'SPCFileUnit.pas',
  TMathBatchUnit in 'TMathBatchUnit.pas',
  TPLMAnalysisUnit1 in 'TPLMAnalysisUnit1.pas',
  TDichroicRatioUnit in 'TDichroicRatioUnit.pas',
  TPreprocessUnit in 'TPreprocessUnit.pas',
  TVarAndCoVarOperations in 'TVarAndCoVarOperations.pas',
  TAutoProjectEVectsUnit in 'TAutoProjectEVectsUnit.pas',
  TRotateFactorsUnit in 'TRotateFactorsUnit.pas',
  TRotateToFitScoresUnit in 'TRotateToFitScoresUnit.pas',
  TASMTimerUnit in 'TASMTimerUnit.pas',
  TTiffReadWriteUnit in 'TTiffReadWriteUnit.pas',
  BLASLAPACKfreePas in 'BLASLAPACKfreePas.pas',
  TMatrixObject in 'TMatrixObject.pas',
  TMaxMinObject in 'TMaxMinObject.pas',
  fftw_interface in 'fftw_interface.pas',
  TPassBatchFileToExecutableUnit in 'TPassBatchFileToExecutableUnit.pas';

{$R *.RES}

// N.B. To enable this feature, add the /3GB switch to the Boot.ini file
const IMAGE_FILE_LARGE_ADDRESS_AWARE = $0020;
{$SetPEFlags IMAGE_FILE_LARGE_ADDRESS_AWARE}

// if you have trouble here then check that LAPACK.dll, BLAS.dll etc are present
begin
  Application.Initialize;
  Application.CreateForm(TForm4, Form4);
  // FileInfo
  Application.CreateForm(TForm2, Form2);    // colorsEM
  Application.CreateForm(TForm1, Form1);    // emissionGL
  Application.CreateForm(TForm3, Form3);
  Application.CreateForm(TBatchFileModDlg, BatchFileModDlg);
  Application.Run;

 end.


