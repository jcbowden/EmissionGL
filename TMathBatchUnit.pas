unit TMathBatchUnit;

interface

uses  classes, SysUtils, grids, TMatrixObject, TSpectraRangeObject,
      TBatchBasicFunctions, TMatrixOperations  ;

type
  TMathBatch  = class
  public
     LHarg, RHarg : TMatrix  ;
     Answer       : TSpectraRanges ;
     posRAnswer, posCAnswer : integer ;   // R(ow) and C(olumn) position in string grid to place answer
     mo           : TMatrixOps ;
     bb           : TBatchBasics ;

     sg           : TStringGrid ;
     zeroLine     : integer ;    //  this is the line of the StringGrid that cells are referenced from (the 'zero' line)
     lineString   : string ;


     constructor Create ;
     destructor  Destroy; override;
     procedure   Free ;

     procedure   DoCalc(inputString : string; sgIn : TStringGrid )  ;

  private
     // these can only be called from DoCalc
     procedure   GetArguments ;
     procedure   DoOperation  ;
end;

implementation

constructor TMathBatch.Create ;
begin
   bb.Create ;
   mo.Create ;
end ;

destructor TMathBatch.Destroy ;
begin
   LHarg.Free ;
   RHarg.Free ;
   Answer.Free;
   mo.Free    ;
   bb.free
end ;

procedure TMathBatch.Free;
begin
 if Self <> nil then Destroy;
end;

procedure   TMathBatch.DoCalc(inputString : string; sgIn : TStringGrid )  ;
var
  exeLine : integer ;
begin
   self.lineString := inputString ;
   self.sg := sgIn ;
   self.GetArguments ;
   self.DoOperation ;

end ;

procedure   TMathBatch.GetArguments  ;
var
   t1, t2 : integer ;
   RArg1, CArg1, RArg2, CArg2 : integer ;
   str1 : string ;
begin
   pos('R',lineString) ;

end ;



procedure   TMathBatch.DoOperation  ;
var
   t1, t2 : integer ;
   RArg1, CArg1, RArg2, CArg2 : integer ;
   str1 : string ;
begin
   pos('.x',lineString) ;

end ;




end.
 