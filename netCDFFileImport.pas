unit netCDFFileImport;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, TSpectraRangeObject, netCDFUnit, StdCtrls, ExtCtrls, CheckLst,
  ComCtrls;


type
  TVarObject = class(TObject)
  public
      name  : array [0..255] of char ;
      varid : integer ;
      length : cardinal ;
      dimlen : array [0..15] of cardinal ;
      vardatatype : nc_type ;
      ndims    : integer ;
      dimids  : array [0..15] of integer ;
      natts   : integer ;
      hasrec  : boolean ;
    constructor Create ; // lc is pointer to TGLLineColor GLFloat array
    destructor  Destroy;
 end ;

// this is the form object class
type
  TNetCDFForm = class(TForm)
    StatusLabel: TLabel;
    Panel2: TPanel;
    VarCheckListBox1: TCheckListBox;
    Splitter1: TSplitter;
    DimensionCheckListBox1: TCheckListBox;
    Panel1: TPanel;
    Button1: TButton;
    Label1: TLabel;
    ProgressBar1netCDF: TProgressBar;
    NaNsubEdit1: TEdit;
    Label2: TLabel;
    FileLabel: TLabel;
    DirLabel: TLabel;
    procedure VarCheckListBox1ClickCheck(Sender: TObject);
    procedure Button1Click(Sender: TObject);

  private
    { Private declarations }
    procedure testStatus(statusIn : integer) ;

  public
    { Public declarations }
    procedure SetUpnetCDFForm(Sender: TObject; filename : string);
    function  nc_typetostr(typeIn: nc_type) : string  ;
    function  nc_typetoint(typeIn: nc_type) : integer ;
    function  nc_returnXCoordNumber(vars : TVarObject) : integer ;
    procedure checkfloatdata(tSRIn : TSpectraRanges; nansubIn : single ) ;
    procedure checkdoubledata(tSRIn : TSpectraRanges; nansubIn : double ) ;
    function  MovePointer(tp : pointer; amount : integer ) : pointer;
  end;

type PTDimStruct  = ^TDimStruct;
      TDimStruct =  record
      dimid   : integer ;
      length  : cardinal ; // size_t
      name    : array [0..255] of char ;
end;

type  PTVarStruct = ^TVarStruct;
      TVarStruct =  record
      name  : array [0..255] of char ;
      varid : integer ;
      length : cardinal ;  // the total number of items of type nc_type in the variable
      dimlen : array [0..15] of cardinal ;
      vardatatype : nc_type ;
      ndims    : integer ;
      dimids  : array [0..15] of integer ;
      natts   : integer ;
      hasrec  : boolean ;
end;


var
  NetCDFForm: TNetCDFForm;
  currentFilename : string ;  // current netCDF filename to extract data from
  status : integer ;
  dims    : array of  TDimStruct ;
  ncid1 : integer ; // this is the netCDF file handle returned in nc_open()
  ndims : integer ;  // size of the dims array
  nvars : integer ;
  recid : integer ;
  //vars    : array of  TVarStruct ;


implementation

uses FileInfo, ColorsEM, emissionGL ;

constructor TVarObject.Create ;  // need SDPrec
begin
   inherited Create ;
end ;


destructor  TVarObject.Destroy; // override;
begin
  inherited Destroy ;
end ;

{$R *.dfm}

procedure TNetCDFForm.SetUpnetCDFForm(Sender: TObject; filename : string );
var
t1, t2  : integer ;
vars    : TVarObject ;

begin
    currentFilename :=  filename ;
    self.Caption :=  'netCDF file import:'  ;
    status := nc_open(PAnsiChar(AnsiString(currentFilename)),NC_NOWRITE, pinteger(@ncid1)) ;
    self.testStatus(status);


    dims := nil ;  // reset the dimensions array
    status := nc_inq_ndims(ncid1, pinteger(@ndims)) ;
    self.testStatus(status);
    setlength(dims,ndims) ;

    for t1 := 0 to ndims - 1 do
    begin
      status := nc_inq_dim(ncid1, t1, dims[t1].name, pcardinal(@(dims[t1].length))) ;
      //DimensionCheckListBox1.AddItem(string(dims[t1].name) +' '+ inttostr(dims[t1].length),nil);
      self.testStatus(status);
    end;


    VarCheckListBox1.Clear ; // reset the vars variable data that is attached to each line of the TCheckBoxList
    status := nc_inq_nvars(ncid1, pinteger(@nvars)) ;
    self.testStatus(status);
   // setlength(vars,nvars) ;

    status := nc_inq_unlimdim(ncid1, pinteger(@recid)) ;
    self.testStatus(status);
    for t1 := 0 to nvars - 1 do
    begin
        vars := TVarObject.Create()  ;
        status := nc_inq_var(ncid1,t1,vars.name,pnc_type(@(vars.vardatatype)),pinteger(@(vars.ndims)),pinteger(@(vars.dimids)),pinteger(@(vars.natts))) ;
        self.testStatus(status);
        //vars.varid := t1 ;
        status := nc_inq_varid (ncid1, vars.name, pinteger(@(vars.varid)));
        self.testStatus(status);
        vars.length := 1 ;
        VarCheckListBox1.AddItem(string(vars.name) +' '+ self.nc_typetostr(vars.vardatatype),vars);
        for t2 := 0 to vars.ndims - 1 do
        begin
            status :=  nc_inq_dimlen(ncid1,vars.dimids[t2],pcardinal(@(vars.dimlen[t2]))) ;
            self.testStatus(status);
          //  VarCheckListBox1.AddItem('dimension ' + inttostr(t2)+ '= '+ inttostr(integer(vars.dimlen[t2])) ,nil);
            vars.length :=  vars.length * vars.dimlen[t2] ; // the complete size of the data (in nc_type units)
        end;
        if (dims[vars.dimids[0]].name = 'record' ) then
        begin
          vars.hasrec := true  // dimids0] ;
        end
        else
          vars.hasrec := false ;
    end;



    nc_close(ncid1) ;
end;


procedure TNetCDFForm.testStatus(statusIn : integer) ;
begin
      if statusIn <> 0 then
      begin
        StatusLabel.Caption := StatusLabel.Caption + ' Error: ' + string(nc_strerror(statusIn)) ;
        // should exit here
      end;
end ;


procedure TNetCDFForm.VarCheckListBox1ClickCheck(Sender: TObject);
var
vars : TVarObject ;
t2, t1 : integer ;
begin

    DimensionCheckListBox1.Clear ;
    for t1 := 0 to VarCheckListBox1.Count - 1 do
    begin
        if VarCheckListBox1.Checked[t1] then
        begin
            vars := TVarObject(VarCheckListBox1.Items.Objects[ t1 ]) ;
            DimensionCheckListBox1.AddItem(vars.name , nil);
            for t2 := 0 to vars.ndims - 1 do
            begin
                DimensionCheckListBox1.AddItem('dimension ' + inttostr(t2)+ '= '+ inttostr(integer(vars.dimlen[t2]) ) ,nil);
               // vars.length :=  vars.length * vars.dimlen[t2] ; // the complete size of the data (in nc_type units)
            end;
            DimensionCheckListBox1.AddItem('data length = ' + inttostr(vars.length*nc_typetoint(vars.vardatatype)) +' bytes' , nil) ;
          //VarCheckListBox1.AddItem('dimension ' + inttostr(t2)+ '= '+ inttostr(integer(vars[t1].dimlen[t2])) ,nil);
          end ;
    end ;
end;



procedure TNetCDFForm.Button1Click(Sender: TObject);
var
tSR : TSpectraRanges ;
vars : TVarObject ;
t1, t2 : integer ;
numdatasets : integer ;
 XorYMatrixData, rowNumber, initialRowNum : integer ;
 start : array [0..15] of integer ;
 count : array [0..15] of integer ;
 p1 : pointer ;
begin
   numdatasets := 0 ;

  if Form2.RBXData.Checked then
  begin
     XorYMatrixData := 2  ;  // load X Data in column 2 (=3)
     rowNumber :=  Form4.StringGrid1.RowCount -1 ;
  end
  else  if Form2.RBYData.Checked then
  begin
     XorYMatrixData := 3  ;  // load X Data in column 2 (=3)
     rowNumber :=  SG1_ROW ;
  end ;

 // initialRowNum :=  rowNumber ;

  // re-open the file
  status := nc_open(PAnsiChar(AnsiString(currentFilename)),NC_NOWRITE, pinteger(@ncid1)) ;
  self.testStatus(status);

   // count the number of data sets wanted :
   for t1 := 0 to VarCheckListBox1.Count - 1 do
    begin
        if VarCheckListBox1.Checked[t1] then
        begin
             ProgressBar1netCDF.Position := 0 ;

            vars := TVarObject(VarCheckListBox1.Items.Objects[ t1 ]) ;
            if  XorYMatrixData = 2 then
              Form4.DoStuffWithStringGrid(currentFilename+ ' ' + string(vars.name),XorYMatrixData,1,0, true, rowNumber)
            else
              Form4.DoStuffWithStringGrid(currentFilename+ ' ' + string(vars.name),XorYMatrixData,1,0, false, rowNumber) ;

            tSR := TSpectraRanges(Form4.StringGrid1.Objects[XorYMatrixData,rowNumber]) ; // this is the new spectra range

            if vars.ndims > 1 then
            begin                                                                      // nc_returnXCoordNumber(vars)
                tSR.yCoord.SetSizeTMat(nc_typetoint(vars.vardatatype),vars.dimlen[0], nc_returnXCoordNumber(vars),1);  // this is the full data size - need to add each record to it
                 tSR.xCoord.SetSizeTMat(nc_typetoint(vars.vardatatype),1, nc_returnXCoordNumber(vars) ,1);  // this is the full data size - need to add each record to it
                                                                             // nc_returnXCoordNumber(vars)
                count[0] := 1 ;
                for t2 := 0 to vars.ndims - 1 do
                  start[t2] := 0 ;    // fill the start positions
                for t2 := 1 to vars.ndims - 1 do
                  count[t2] :=  vars.dimlen[t2] ;


               p1 := tSR.yCoord.F_Mdata.Memory ;

               if vars.hasrec then
               begin
                 ProgressBar1netCDF.Min := 0 ;
                 ProgressBar1netCDF.Max :=  (vars.dimlen[0]);
                 ProgressBar1netCDF.Step := 1 ;

                 for t2 := 0 to vars.dimlen[0] - 1 do  // dimlen[0] is the first dimension which has record type (i.e. possibly is not continuous on disk)
                 begin
                   start[0] := t2 ;   // fill each record in order
                   StatusLabel.Caption := 'Step ' + inttostr(t2+1) + ' of ' + inttostr(vars.dimlen[0]) ;
                   ProgressBar1netCDF.StepIt()  ;
                   case  vars.vardatatype of
                    NC_FLOAT:  // single precision floating point number
                    begin
                      status := nc_get_vara_float(ncid1, vars.varid, pinteger(@(start[0])), pinteger(@(count[0])),MovePointer(p1, t2 *( nc_returnXCoordNumber(vars) * nc_typetoint(vars.vardatatype)))) ;   // ( nc_returnXCoordNumber(vars) * nc_typetoint(vars.vardatatype))
                      self.testStatus(status);
                    end ;
                    NC_DOUBLE: // double precision floating point number
                    begin
                     status := nc_get_vara_double(ncid1, vars.varid, pinteger(@start[0]), pinteger(@(count[0])),MovePointer(tSR.yCoord.F_Mdata.Memory,(t2 * nc_returnXCoordNumber(vars) * nc_typetoint(vars.vardatatype)))) ;
                     self.testStatus(status);
                    end ;
                   end ;
                  end;  // end t2 for loop
               end
               else    // does not have records
               begin   // read in one shot
                   count[0] :=  vars.dimlen[0] ;
                   StatusLabel.Caption := 'Step ' + inttostr(t2+1) + ' of ' + inttostr(vars.dimlen[0]) ;
                   ProgressBar1netCDF.StepIt()  ;
                   case  vars.vardatatype of
                    NC_FLOAT:  // single precision floating point number
                    begin
                      status := nc_get_vara_float(ncid1, vars.varid, pinteger(@(start[0])), pinteger(@(count[0])),MovePointer(p1, t2 *( nc_returnXCoordNumber(vars) * nc_typetoint(vars.vardatatype)))) ;   // ( nc_returnXCoordNumber(vars) * nc_typetoint(vars.vardatatype))
                      self.testStatus(status);
                    end ;
                    NC_DOUBLE: // double precision floating point number
                    begin
                     status := nc_get_vara_double(ncid1, vars.varid, pinteger(@start[0]), pinteger(@(count[0])),MovePointer(tSR.yCoord.F_Mdata.Memory,(t2 * nc_returnXCoordNumber(vars) * nc_typetoint(vars.vardatatype)))) ;
                     self.testStatus(status);
                    end ;
                   end ;
               end;
            end
            else if vars.ndims = 1 then
            begin
                   tSR.yCoord.SetSizeTMat(nc_typetoint(vars.vardatatype),1, vars.dimlen[0],1);  // this is the full data size - need to add each record to it
                   tSR.xCoord.SetSizeTMat(nc_typetoint(vars.vardatatype),1, vars.dimlen[0] ,1);  // this is the full data size - need to add each record to it
                   start[0] := 0 ;    // fill the start positions
                   count[0] :=  vars.dimlen[0] ;

                  case  vars.vardatatype of
                   NC_FLOAT:  // single precision floating point number
                   begin
                      status := nc_get_vara_float(ncid1, vars.varid, pinteger(@start[0]), pinteger(@(count[0])),tSR.yCoord.F_Mdata.Memory) ;
                      self.testStatus(status);
                   end ;
                   NC_DOUBLE: // double precision floating point number
                   begin
                     status := nc_get_vara_double(ncid1, vars.varid, pinteger(@start[0]), pinteger(@(count[0])),tSR.yCoord.F_Mdata.Memory) ;
                     self.testStatus(status);
                   end ;
                   end ;
            end;

            // check for valid data and change to float
            case  vars.vardatatype of
                NC_FLOAT:  // single precision floating point number
                   begin
                      StatusLabel.Caption := 'Checking for NAN/INF' ;
                      self.checkfloatdata(tSR,strtofloat(self.NaNsubEdit1.Text)) ; // needed as netCDF files can contain NaNs for missing data areas
                      StatusLabel.Caption := 'Returned from checking for NAN/INF' ;
                   end ;
                NC_DOUBLE: // double precision floating point number
                   begin
                      StatusLabel.Caption := 'Checking for NAN/INF' ;
                      self.checkdoubledata(tSR,strtofloat(self.NaNsubEdit1.Text)) ; // needed as netCDF files can contain NaNs for missing data areas
                      tSR.yCoord.ConvertToSingle() ;
                      StatusLabel.Caption := 'Returned from checking for NAN/INF' ;
                   end ;
            end ;

                                                              
            //tSR.yCoord.CopyMemStrmToSingle()
            tSR.xCoord.FillMatrixData(0, tSR.yCoord.numCols);
            tSR.xCoord.ConvertToSingle() ;

             StatusLabel.Caption := 'Choosing display type' ;
             statusLabel.Refresh ;
             Form4.ChooseDisplayType(tSR) ;
             StatusLabel.Caption := 'Creating OpenGL data' ;
             tSR.CreateGLList('1-',Form1.Canvas.Handle, RC, Form2.GetWhichLineToDisplay(), 1) ;
             tSR.SetOpenGLXYRange(Form2.GetWhichLineToDisplay()) ; // finds max and min values in xy data
             if Form4.CheckBox7.Checked = false then  // keep current perspective = false
                Form1.UpdateViewRange() ; // updates  OrthoVarXMax, OrthoVarXMin, OrthoVarYMax, OrthoVarYMin. Used when XY data is modified
              Form4.PlaceDataRangeOrValueInGridTextBox(XorYMatrixData,rowNumber, TSpectraRanges(Form4.StringGrid1.Objects[XorYMatrixData,rowNumber]) ) ;

             StatusLabel.Caption := 'Done' ;

             tSR.xString := currentFilename + ' ' + string(vars.name) ;
             rowNumber :=  rowNumber + 1 ;
             ProgressBar1netCDF.Position := 0 ;

        end;
    end;

    nc_close(ncid1) ;
end;

{$J-} // Initialized constants are constants - not initialized variables
// thanks to http://www.efg2.com/Lab/Mathematics/NaN.htm for the following
// as testing for exceptions was really slow
FUNCTION SpecialSingle (s:single): boolean;
//returns true if s is Infinity, NAN or Indeterminate
//4byte IEEE: msb[31] = signbit, bits[23-30] exponent,
//bits[0..22] mantissa
//exponent of all 1s = Infinity, NAN or Indeterminate
CONST kSpecialExponent = 255 shl 23;
VAR
  Overlay: LongInt ABSOLUTE s;
BEGIN
  IF ((Overlay AND kSpecialExponent) = kSpecialExponent) THEN
    RESULT := true
  ELSE
    RESULT := false;
END;
 {$J+} // Initialized constants are constants - not initialized variables


procedure TNetCDFForm.checkfloatdata( tSRIn : TSpectraRanges ; nansubIn : single ) ; // checks for NANs in the netCDF file and replaces them with -1.0
var
t1, t2 : integer ;
p1 : psingle ;
s1 : single ;
begin
    p1 := psingle(tSRIn.yCoord.F_Mdata.Memory) ;
    for t1 := 0 to tSRIn.yCoord.numRows - 1 do
    begin
      for t2 := 0 to tSRIn.yCoord.numCols - 1 do
      begin
           s1 := p1^ ;
          if SpecialSingle(s1) then
             p1^ := nansubIn;

          p1 := psingle(MovePointer(p1, 4)) ;
      end;
    end;
end;

{$J-} // Initialized constants are constants - not initialized variables
// thanks to http://www.efg2.com/Lab/Mathematics/NaN.htm for the following
// as testing for exceptions was really slow
FUNCTION SpecialDouble(s:double): boolean;
//returns true if s is Infinity, NAN or Indeterminate
//8byte IEEE: msb[63] = signbit, bits[52-62] exponent,
//bits[0..51] mantissa
//exponent of all 1s = Infinity, NAN or Indeterminate
CONST kSpecialExponentDbl = 2047 shl 52;
VAR
  Overlay: Int64 ABSOLUTE s;
BEGIN
  //IF ((Overlay AND kSpecialExponentDbl) = kSpecialExponentDbl) THEN
  IF ((Overlay AND $7FF0000000000000) =  $7FF0000000000000) then
    RESULT := true
  ELSE
    RESULT := false;
END;
{$J+} // Initialized constants are constants - not initialized variables


procedure TNetCDFForm.checkdoubledata( tSRIn : TSpectraRanges ; nansubIn : double ) ; // checks for NANs in the netCDF file and replaces them with -1.0
var
t1, t2 : integer ;
p1 : pdouble ;
d1 : double ;
begin
    p1 := pdouble(tSRIn.yCoord.F_Mdata.Memory) ;
    for t1 := 0 to tSRIn.yCoord.numRows - 1 do
    begin
      for t2 := 0 to tSRIn.yCoord.numCols - 1 do
      begin
           d1 := p1^ ;
          if SpecialDouble(d1) then
             p1^ := nansubIn;

          p1 := pdouble(MovePointer(p1, 8)) ;
      end;
    end;
end;


function TNetCDFForm.MovePointer(tp : pointer; amount : integer ) : pointer;
begin
   asm  // 32bit
     MOV     EAX,tp
     MOV     EDX,amount
     ADD     EAX,EDX
     MOV     @Result,EAX
   end;
end ;

 function TNetCDFForm.nc_returnXCoordNumber(vars : TVarObject) : integer ;
 var
  t1 : integer ;
begin
      result := 1 ;

      for t1 := 1 to vars.ndims - 1 do
      begin
        result := result * vars.dimlen[t1] ;
      end;

end;


function TNetCDFForm.nc_typetostr(typeIn: nc_type) : string ;
begin
     case  typeIn of
     NC_NAT :
     begin
     result := 'NC_NaN' ;
     end ;
     NC_BYTE:   // signed 1 byte integer
     begin
         result := 'NC_BYTE' ;
     end ;
    NC_CHAR:   // ISO/ASCII character
    begin
        result := 'NC_CHAR' ;
    end ;
    NC_SHORT:  // signed 2 byte integer
    begin
         result := 'NC_SHORT' ;
    end ;
    NC_INT:   // signed 4 byte integer
    begin
         result := 'NC_INT' ;
    end ;
    NC_FLOAT:  // single precision floating point number
    begin
         result := 'NC_FLOAT' ;
    end ;
    NC_DOUBLE: // double precision floating point number
    begin
         result := 'NC_DOUBLE' ;
    end ;
    end ;

end ;


function TNetCDFForm.nc_typetoint(typeIn: nc_type) : integer ;
begin
     case  typeIn of
     NC_NAT :
     begin
     result := 0 ;
     end ;
     NC_BYTE:   // signed 1 byte integer
     begin
         result := 1 ;
     end ;
    NC_CHAR:   // ISO/ASCII character
    begin
        result := 1 ;
    end ;
    NC_SHORT:  // signed 2 byte integer
    begin
         result := 2 ;
    end ;
    NC_INT:   // signed 4 byte integer
    begin
         result := 4 ;
    end ;
    NC_FLOAT:  // single precision floating point number
    begin
         result := 4 ;
    end ;
    NC_DOUBLE: // double precision floating point number
    begin
         result := 8 ;
    end ;
    end ;

end ;

end.
