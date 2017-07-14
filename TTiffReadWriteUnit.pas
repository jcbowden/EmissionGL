unit TTiffReadWriteUnit;

interface

uses  Classes, Dialogs, SysUtils  ;


type
TTiffReadWrite = class
  public

    byteOrder : integer ; // if 0 then do not change if 1 the reverse (using TMatrix.ReverseByteOrder)
    datatype  : integer ;

    ImageWidth : integer ;  // tag=256
    ImageLength: Integer ;  // tag = 257
    BitsPerSample:Integer ; // tag= 258
    Compression : Integer ; // tag = 259  (available values 1 (none) or 32773 (packbits)
    PhotometricInterp : Integer ; //tag=262 (0 or 1)
    StripOffsets: Integer;  // tag=273
    StripOffsetFieldDataType : Integer ;
    NumberOfStrips : Integer ;
    SamplesPerPixel : Integer ; // tag=277  - indicates the number of components to each pixel (ie greyscale = 1 RGB = 3)
    RowsPerStrip: Integer ; // tag= 278
    StripByteCounts:Integer ; //tag= 279
    XResolution: single ; // tag=282  (rational)
    YResolution: single ; // tag=283  (rational)
    ResolutionUnit : Integer; // tag=296 (short)

    inputTiff                  : TMemoryStream ;
    arrayOfStripOffsets        : TMemoryStream ;
    arrayOfStripByteCounts     : TMemoryStream ;

    constructor Create;
    constructor Create2(FilenameIn : String);
    destructor  Destroy; override; // found in implementation part below
    procedure   Free ;

    procedure   ReadTiffInfo(FilenameTiff : String) ;  // this reads up to ImageFileDirectory position and all header info
    procedure   CopyData(outputStr : TMemoryStream; SDPrec : integer) ; // SDPrec = 4 for single 8 for double
  private
    procedure   ReverseByteOrder( p1 : PByteArray ; size : integer) ;
end;


implementation



constructor TTiffReadWrite.Create ;
begin
   inputTiff := TMemoryStream.Create ;
end;

constructor TTiffReadWrite.Create2(FilenameIn : String) ;
begin
   inputTiff := TMemoryStream.Create ;
   ReadTiffInfo(FilenameIn)  ;
end;


destructor TTiffReadWrite.Destroy;
begin
   if inputTiff <> nil then
     inputTiff.Free ;
   if arrayOfStripOffsets <> nil then
     arrayOfStripOffsets.Free ;
   if arrayOfStripByteCounts <> nil then
     arrayOfStripByteCounts.Free ;
end;


procedure TTiffReadWrite.Free ;
begin

 if Self <> nil then
   Destroy;

end;


procedure TTiffReadWrite.ReverseByteOrder( p1 : PByteArray ; size : integer) ;
var
  b1, b2, b3, b4 : byte ;
begin
  if size = 4 then
  begin
      b1 := p1[3]  ;
      b2 := p1[2] ;
      b3 := p1[1] ;
      b4 := p1[0] ;
      p1[0] := b1 ;
      p1[1] := b2 ;
      p1[2] := b3 ;
      p1[3] := b4 ;
  end
  else
  if size = 2 then
  begin
      b1 := p1[1]  ;
      b2 := p1[0]  ;
      p1[0] := b1 ;
      p1[1] := b2 ;
  end ;
end ;

{$T-}
procedure   TTiffReadWrite.ReadTiffInfo(FilenameTiff : String) ;  // this reads up to ImageFileDirectory position and all header info
// SDPrec = 4 for single precision  = 8 for double
var
  b1                         : byte ;
  t1                         : integer ;  // loop counters
  s1                         : single ;
  d1                         : double ;
  so, bc                     : integer ;  // stripoffset and bytecount of data in tiff file
  offsetShort                : word ;
  offset                     : integer ;
  numDirEntries              : word ;
  fieldTag , fieldDataType   : word ;
  numberOfVals, valInt       : integer ;
  typeofPointer1, typeofPointer2 : integer ;

begin
    inputTiff.LoadFromFile(FilenameTiff);
    inputTiff.Read(b1,1) ;
    if b1 = 73 then // is intel 'II' file type
      byteOrder := 0
    else if b1 = 77 then // is mac 'MM' file type
      byteOrder := 1 ;

    inputTiff.Seek(4,soFromBeginning)  ;
    inputTiff.Read(offset,4) ;
    if byteOrder = 1 then ReverseByteOrder(@offset,4) ;
    inputTiff.Seek(offset,soFromBeginning)  ;

    // read number of directory entries - individual Integer type value
    inputTiff.Read(numDirEntries,2) ;
    if byteOrder = 1 then ReverseByteOrder(@numDirEntries,2) ;
//    messagedlg('number of directory entries='+inttostr(numDirEntries),mtInformation,[mbOK],0) ;

    for t1 := 1 to numDirEntries do
    begin
      inputTiff.Read(fieldTag,2) ;
      inputTiff.Read(fieldDataType,2) ;
      inputTiff.Read(numberOfVals,4) ;
      inputTiff.Read(valInt,4) ;
      if byteOrder = 1 then
      begin
        ReverseByteOrder(@fieldTag,2) ;
        ReverseByteOrder(@fieldDataType,2) ;
        ReverseByteOrder(@numberOfVals,4) ;
        if fieldDataType = 3 then
          ReverseByteOrder(@valInt,2)
        else
        if fieldDataType = 4 then
          ReverseByteOrder(@valInt,4) ;
      end ;
      case fieldTag of
          256:  ImageWidth := valInt ;
          257:  ImageLength:= valInt ;  // tag =257
          258:  BitsPerSample:= valInt ; // tag= 258 should equal 8 or 16  or 32 (for single float)
          259:  Compression:= valInt ; // tag = 259  (available values 1 (none) or 32773 (packbits)
          262:  PhotometricInterp := valInt ; //tag=262 (0 or 1)
          273:  begin
                  StripOffsets:= valInt;  // tag =273
                  if fieldDataType = 3 then typeofPointer1 := 2
                  else if fieldDataType = 4 then typeofPointer1 := 4 ;
                  NumberOfStrips := numberOfVals ;
                end;
          277:  SamplesPerPixel := valInt ;  // tag =277
          278:  RowsPerStrip:= valInt ; // tag= 278
          279:  begin
                  StripByteCounts:= valInt ; //tag=  279
                  if fieldDataType = 3 then typeofPointer2 := 2
                  else if fieldDataType = 4 then typeofPointer2 := 4 ;
                  if NumberOfStrips=1 then
                  begin
                    if StripByteCounts <> ((BitsPerSample/8)*ImageWidth*ImageLength ) then
                      StripByteCounts :=  (BitsPerSample div 8)*ImageWidth*ImageLength ;
                  end;
                end;
          282:  XResolution:= valInt ; // tag= 282 (rational)
          283:  YResolution:= valInt ; // tag= 283 (rational)
          296:  ResolutionUnit := valInt ; // tag= 296 (short) (1 = none, 2 = inch, 3 = cm)
      end;
    end;

    // exit if data is compressed or samples per pixel is > 1 (i.e. picture not greyscale)
    if (Compression > 1) or (SamplesPerPixel > 1) then
    begin
      inputTiff.Free ;
      exit ;
    end;

      arrayOfStripOffsets        := TMemoryStream.Create ;
      arrayOfStripByteCounts     := TMemoryStream.Create ;
      arrayOfStripOffsets.SetSize(NumberofStrips*4);    // the code below forces all pointers to 32 bit integers
      arrayOfStripByteCounts.SetSize(NumberofStrips*4); // the code below forces all size data to 32 bit integers

      if NumberofStrips > 1  then  // =>  StripOffsets points to a list of pointers to the data
      begin
      inputTiff.Seek(StripOffsets,soFromBeginning)  ;  // go to position of first pointer to data
      for t1 := 1 to NumberOfStrips do // for input of all arrayOfStripOffsets  data
      begin
        if typeofPointer1 = 2 then
        begin
          offsetShort := 0 ;
          inputTiff.Read(offsetShort,typeofPointer1) ;  // i'm not sure if reading in 2 bytes into a 4 byte integer will work
          offset := offsetShort ;
          arrayOfStripOffsets.Write(offset,4) ;  ;  // go to strip t1
        end;
        if typeofPointer1 = 4 then
        begin
          inputTiff.Read(offset,typeofPointer1) ;  // i'm not sure if reading in 2 bytes into a 4 byte integer will work
          arrayOfStripOffsets.Write(offset,typeofPointer1) ;  ;  // go to strip t1
        end;
      end;
      for t1 := 1 to NumberOfStrips do  // for input of all arrayOfStripByteCounts  data
      begin
         if typeofPointer2 = 2 then
        begin
          inputTiff.Read(offsetShort,typeofPointer2) ;  // i'm not sure if reading in 2 bytes into a 4 byte integer will work
          offset := offsetShort ;
          arrayOfStripByteCounts.Write(offset,4) ;  ;  // go to strip t1
        end;
        if typeofPointer2 = 4 then
        begin
          inputTiff.Read(offset,typeofPointer2) ;  //
          arrayOfStripByteCounts.Write(offset,typeofPointer2) ;  ;  // go to strip t1
        end;
      end;
      end
      else
      if NumberofStrips = 1  then   // pointer to data is in original structure
      begin
         arrayOfStripOffsets.Write(StripOffsets,4) ;
         arrayOfStripByteCounts.Write(StripByteCounts,4)
      end;

      // these now contain the pointer data to the strips that contain the data
      arrayOfStripOffsets.Seek(0,soFromBeginning) ;
      arrayOfStripByteCounts.Seek(0,soFromBeginning) ;

end ;

{$T+}

procedure   TTiffReadWrite.CopyData(outputStr : TMemoryStream; SDPrec : integer) ; // SDPrec = 4 for single 8 for double
// data is saved only if it is a factor of ScaleFactor
var
   b1                         : byte ;
   t1, t2                     : integer ;  // loop counters
   s1                         : single ;
   d1                         : double ;
   so, bc                     : integer ;  // stripoffset and bytecount of data in tiff file
   offsetShort                : word ;

begin
   
      // this reads in the Strip offset pointers and how long the strips are (StripByteCount)
      // This is where we can get the data Yay!
      outputStr.SetSize((ImageWidth*Imagelength*SDPrec)) ; // SDPrec indicates Single (4 byte) or Double (8 byte) precision
      for t1 := 1 to NumberOfStrips do // for input of all arrayOfStripOffsets  data
      begin
        arrayOfStripOffsets.Read(so,4) ;        // read pointer to data strip
        arrayOfStripByteCounts.Read(bc,4)  ;    // read how many bytes in data strip
        inputTiff.Seek(so,soFromBeginning) ;    // seek to position in tiff file

        // read the actual data and convert to single or double precision and store in  resultDataSD
        if SDPrec = 4 then  // if we want single precision data
        begin
        if BitsPerSample = 8 then
        begin
          for t2 := 1 to bc  do  // for each byte in the strip
          begin
             inputTiff.Read(b1,1) ;
             s1 := b1 ;
             outputStr.Write(s1,SDPrec) ;
          end;
        end
        else
        if BitsPerSample = 16 then
        begin
          for t2 := 1 to (bc div 2)  do   // for each word in the strip
          begin
             inputTiff.Read(offsetShort,2) ;
             if self.byteOrder = 1 then
               self.ReverseByteOrder(PByteArray(@offsetShort),2) ;
             s1 := offsetShort ;
             outputStr.Write(s1,SDPrec) ;
          end
        end
        else
        if BitsPerSample = 32 then  // float data
        begin
          for t2 := 1 to (bc div 4)  do   // for each float in the strip
          begin
             inputTiff.Read(s1,4) ;
             if self.byteOrder = 1 then
               ReverseByteOrder(PByteArray(@s1),4) ;
             //s1 := offsetShort ;
             outputStr.Write(s1,SDPrec) ;
          end;
        end;
        end
        else
        if SDPrec = 8 then   // if we want double precision output data
        begin
        if BitsPerSample = 8 then               // read the actual data
        begin
          for t2 := 1 to bc  do  // for each byte in the strip
          begin
             inputTiff.Read(b1,1) ;
             d1 := b1 ;
             outputStr.Write(d1,SDPrec) ;
          end;
        end
        else
        if BitsPerSample = 16 then
        begin
          for t2 := 1 to (bc div 2)  do   // for each word in the strip
          begin
             inputTiff.Read(offsetShort,2) ;
             if self.byteOrder = 1 then
               ReverseByteOrder(PByteArray(@offsetShort),2) ;
             d1 := offsetShort ;
             outputStr.Write(d1,SDPrec) ;
          end;
        end
        else
        if BitsPerSample = 32 then  // float data
        begin
          for t2 := 1 to (bc div 4)  do   // for each float in the strip
          begin
             inputTiff.Read(s1,4) ;
             if self.byteOrder = 1 then
               ReverseByteOrder(PByteArray(@s1),4) ;
             d1 := s1 ;
             outputStr.Write(d1,SDPrec) ;
          end;
        end;
        end;
        
      end;





end ;

end.
