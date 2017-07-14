unit TBatch;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, TBatchBasicFunctions,
  TVarAndCoVarOperations,  TMatrixObject, TSpectraRangeObject, PCAResultsObject ;

type
  TBatchMVA  = class
  public
     resultsFileName : string;
     PCsString : string;
     firstSpectra : integer ;  // not needed in PCA, PCR, PLS... it is first value in sampleRange

     XsampleRange : string ;  //  not needed in IR-pol
     xVarRange : string ; // variable range or filled in by ConvertValueStringToPosString()
     xVarRangeIsPositon : boolean ;

     normalisedEVects, meanCentre, colStd : boolean ;

     // interleaved = 2 then this is IR-pol format, where each polarisation angle spectra at an individual pixel is one after another
     // interleaved = 1 this is standard interleaved format with image in large block (i.e. 32x32 spectra, followed by another 32x32 etc at each angle )
     interleaved : integer ;

     autoExclude : single;     // used in IR-pol analysis but not PCA as yet.
     excludePCsStr : string;   // used in IR-pol analysis but not PCA as yet.

     bB : TBatchBasics ;  // functions like : LeftSideOfEqual() etc

     allXData            :  TSpectraRanges ;            // for display in column #2
     scoresSpectra       :  TSpectraRanges ;       //  for display in column #4. Created in ProcessPCAData() or ProcessIRPolData() functions as need to get sizes from input data
     eigenVSpectra       :  TSpectraRanges ;     // for display in column #5. Created in ProcessPCAData() or ProcessIRPolData() functions

     eigenValSpectra     :  TSpectraRanges ;  // for display in column #6
     XresidualsSpectra   :  TSpectraRanges ;  // for display in column #7. Created in ProcessPCAData()  function as need to get sizes from input data
     regenSpectra        :  TSpectraRanges ;  // for display in column #8

     constructor Create  ;  // need SDPrec for TRegression object
     destructor  Destroy ; // override;
     procedure   Free    ;

     // Retrieves all samples needed (numX x numY x numAngles) within variable range wanted and place them in new TMatrix in 'block' format ready for PCA
     // sourceMatrix is either interleaved (interleavedOrBlocked =1) or block structure (interleavedOrBlocked =2)
     function  GetAllXData( interleavedOrBlocked : integer;  sourceSpecRange : TSpectraRanges ) : boolean ; virtual ;
     //     function  PreProcessData( )  : boolean ; virtual  ;
  private
end;


implementation


constructor TBatchMVA.Create ;  // need SDPrec for TRegression object
begin

   bB := TBatchBasics.Create ;

end ;


destructor  TBatchMVA.Destroy; // override;
begin

   if allXData           <> nil then  allXData.Free ;
   if scoresSpectra      <> nil then  scoresSpectra.Free ;
   if eigenVSpectra      <> nil then  eigenVSpectra.Free ;

   if eigenValSpectra    <> nil then  eigenValSpectra.Free ;
   if  XresidualsSpectra <> nil then  XresidualsSpectra.Free ;
   if  regenSpectra      <> nil then  regenSpectra.Free ;

   bB.Free ;               // TBatchBasics
end ;

procedure TBatchMVA.Free;
begin
 if Self <> nil then Destroy;
end;     



function  TBatchMVA.GetAllXData( interleavedOrBlocked : integer;  sourceSpecRange : TSpectraRanges ) : boolean ;   	 // retrieve all samples needed (numX x numY x numAngles) within variable range wanted and place them in new TMatrix in 'block' format ready for PCA
begin
   // have to override this to make it usefull
end ;



end.
