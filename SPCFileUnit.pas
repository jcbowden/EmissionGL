unit SPCFileUnit;

interface

uses  classes, Dialogs, Math, sysutils, TSpectraRangeObject  ;

{
Delphi 3 Version by Josh Bowden (jc.bowden@qut.edu.au) 23 April 2006.

//*************************************************************************
*   FILENAME:	spc.h
*   AUTHOR:	Steven Simonoff 11-25-90 (from spc.inc)
*   MRU:	5-6-97 (New X,Y types, fexper types, float ssftime, 4D data)
*
*	Contains the Spectrum Information Header structure definitions.
*	Based on zspchdr.inc from Lab Calc (tm).
*	Must #include <windows.h> before this file.
*
*   Copyright (C) 1986-1997 by Galactic Industries Corp.
*   All Rights Reserved.
***************************************************************************

* The following defines a trace header and file format.
* All floating values in SPC files are in the IEEE standard formats.

* There are two basic formats, new and old.  FVERSN flags the format and
* also serves as a check byte.	The new format has header values in the file
* exactly as they appear below.  The old format has slightly different file
* header formating which is translated as it is read into memory. New features
* like XY data and audit log information are not supported for the old format.

* The new format allows X,Y pairs data to be stored when the TXVALS flag is set.
* The main header is immediately followed by any array of fnpts 32-bit floating
* numbers giving the X values for all points in the file or subfiles.  Note
* that for multi files, there is normally a single X values array which applies
* to all subfiles.  The X values are followed by a subfile header and fixed
* point Y values array or, for multi files, by the subfiles which each consist
* of a subfile header followed by a fixed-point Y values array.  Note that
* the software may be somewhat slower when using X-values type files.

* Another X,Y mode allows for separate X arrays and differing numbers of
* points for each subfile.  This mode is normally used for Mass Spec Data.
* If the TXYXYS flag is set along with TXVALS, then each subfile has a
* separate X array which follows the subfile header and preceeds the Y array.
* An additional subnpts subfile header entry gives the number of X,Y values
* for the subfile (rather than the fnpts entry in the main header).  Under
* this mode, there may be a directory subfile pointers whose offset is
* stored in the fnpts main header entry.  This directory consists of an
* array of ssfstc structures, one for each of the subfiles.  Each ssfstc
* gives the byte file offset of the begining of the subfile (that is, of
* its subfile header) and also gives the Z value (subtime) for the subfile
* and is byte size.  This directory is normally saved at the end of the
* file after the last subfile.	If the fnpts entry is zero, then no directory
* is present and GRAMS/32 automatically creates one (by scanning through the
* subfiles) when the file is opened.  Otherwise, fnpts should be the byte
* offset into the file to the first ssfstc for the first subfile.  Note
* that when the directory is present, the subfiles may not be sequentially
* stored in the file.  This allows GRAMS/32 to add points to subfiles by
* moving them to the end of the file.

* Y values are represented as fixed-point signed fractions (which are similar
* to integers except that the binary point is above the most significant bit
* rather than below the least significant) scaled by a single exponent value.
* For example, 0x40000000 represents 0.25 and 0xC0000000 represents -0.25 and
* if the exponent is 2 then they represent 1 and -1 respectively.  Note that
* in the old 0x4D format, the two words in a 4-byte DP Y value are reversed.
* To convert the fixed Y values to floating point:
*	FloatY = (2^Exponent)*FractionY
* or:	FloatY = (2^Exponent)*IntegerY/(2^32)		  -if 32-bit values
* or:	FloatY = (2^Exponent)*IntegerY/(2^16)		  -if 16-bit values

* Optionally, the Y values on the disk may be 32-bit IEEE floating numbers.
* In this case the fexp value (or subexp value for multifile subfiles)
* must be set to 0x80 (-128 decimal).  Floating Y values are automatically
* converted to the fixed format when read into memory and are somewhat slower.
* GRAMS/32 never saves traces with floating Y values but can read them.

* Thus an SPC trace file normally has these components in the following order:
*	SPCHDR		Main header (512 bytes in new format, 224 or 256 in old)
*      [X Values]	Optional FNPTS 32-bit floating X values if TXVALS flag (= 128)
*	SUBHDR		Subfile Header for 1st subfile (32 bytes)
*	Y Values	FNPTS 32 or 16 bit fixed Y fractions scaled by exponent
*      [SUBHDR	]	Optional Subfile Header for 2nd subfile if TMULTI flag
*      [Y Values]	Optional FNPTS Y values for 2nd subfile if TMULTI flag
*	...		Additional subfiles if TMULTI flag (up to FNSUB total)
*      [Log Info]	Optional LOGSTC and log data if flogoff is non-zero

* However, files with the TXYXYS ftflgs flag set have these components:
*	SPCHDR		Main header (512 bytes in new format)
*	SUBHDR		Subfile Header for 1st subfile (32 bytes)
*	X Values	FNPTS 32-bit floating X values
*	Y Values	FNPTS 32 or 16 bit fixed Y fractions scaled by exponent
*      [SUBHDR	]	Subfile Header for 2nd subfile
*      [X Values]	FNPTS 32-bit floating X values for 2nd subfile
*      [Y Values]	FNPTS Y values for 2nd subfile
*	...		Additional subfiles (up to FNSUB total)
*      [Directory]	Optional FNSUB SSFSTC entries pointed to by FNPTS
*      [Log Info]	Optional LOGSTC and log data if flogoff is non-zero

* Note that the fxtype, fytype, and fztype default axis labels can be
* overridden with null-terminated strings at the end of fcmnt.	If the
* TALABS bit is set in ftflgs (or Z=ZTEXTL in old format), then the labels
* come from the fcatxt offset of the header.  The X, Y, and Z labels
* must each be zero-byte terminated and must occure in the stated (X,Y,Z)
* order.  If a label is only the terminating zero byte then the fxtype,
* fytype, or fztype (or Arbitrary Z) type label is used instead.  The
* labels may not exceed 20 characters each and all three must fit in 30 bytes.

* The fpost, fprocs, flevel, fsampin, ffactor, and fmethod offsets specify
* the desired post collect processing for the data.  Zero values are used
* for unspecified values causing default settings to be used.  See GRAMSDDE.INC
* Normally fpeakpt is zero to allow the centerburst to be automatically located.

* If flogoff is non-zero, then it is the byte offset in the SPC file to a
* block of memory reserved for logging changes and comments.  The beginning
* of this block holds a logstc structure which gives the size of the
* block and the offset to the log text.  The log text must be at the block's
* end.	The log text consists of lines, each ending with a carriage return
* and line feed.  After the final line's CR and LF must come a zero character
* (which must be the first in the text).  Log text requires V1.10 or later.
* The log is normally after the last subfile (or after the TXYXYS directory).

* The fwplanes allows a series of subfiles to be interpreted as a volume of
* data with ordinate Y values along three dimensions (X,Z,W).  Volume data is
* also known as 4D data since plots can have X, Z, W, and Y axes.  When
* fwplanes is non-zero, then groups of subfiles are interpreted as planes
* along a W axis.  The fwplanes value gives the number of planes (groups of
* subfiles) and must divide evenly into the total number of subfiles (fnsub).
* If the fwinc is non-zero, then the W axis values are evenly spaced beginning
* with subwlevel for the first subfile and incremented by fwinc after each
* group of fwplanes subfiles.  If fwinc is zero, then the planes may have
* non-evenly-spaced W axis values as given by the subwlevel for the first
* subfile in the plane's group.  However, the W axis values must be ordered so
* that the plane values always increase or decrease.  Also all subfiles in the
* plane should have the same subwlevel.  Equally-spaced W planes are recommended
* and some software may not handle fwinc=0.  The fwtype gives the W axis type.
***************************************************************************/      }



type
  SPCHDR  = packed record
      ftflgs : BYTE ;	              // Flag bits defined below */
      fversn : BYTE;	                // 0x4B (=75) => new LSB 1st, 0x4C (=76) => new MSB 1st, 0x4D=> old format */
      fexper : BYTE;	                // Instrument technique code (see below) */
      fexp   : BYTE; 	              // Fraction scaling exponent integer (80h=>float) */
      fnpts  : integer ;	            // Integer number of points (or TXYXYS directory position) */
      ffirst : double;	              // Floating X coordinate of first point */
      flast  : double;	              // Floating X coordinate of last point */
      fnsub  : integer ;	            // Integer number of subfiles (1 if not TMULTI) */
      fxtype : BYTE;	                // Type of X axis units (see definitions below) */
      fytype : BYTE;	                // Type of Y axis units (see definitions below) */
      fztype : BYTE;	                // Type of Z axis units (see definitions below) */
      fpost  : BYTE;	                // Posting disposition (see GRAMSDDE.H) */
      fdate  : integer ;	            // Date/Time LSB: min=6b,hour=5b,day=5b,month=4b,year=12b */
      fres   : array[0..8] of char;	      // Resolution description text (null terminated) */
      fsource : array[0..8] of char;	  // Source instrument description text (null terminated) */
      fpeakpt : Word	;	                // Peak point number for interferograms (0=not known) */
      fspare : array[0..7] of single;	  // Used for Array Basic storage */
      fcmnt  : array[0..129]of char;	    // Null terminated comment ASCII text string */
      fcatxt : array[0..29]of char;	    // X,Y,Z axis label strings if ftflgs=TALABS */
      flogoff : integer ;	          // File offset to log block or 0 (see above) */
      fmods : integer ;	            // File Modification Flags (see below: 1=A,2=B,4=C,8=D..) */
      fprocs : BYTE;	                // Processing code (see GRAMSDDE.H) */
      flevel : BYTE;	                // Calibration level plus one (1 = not calibration data) */
      fsampin : Word	;	              // Sub-method sample injection number (1 = first or only ) */
      ffactor : single;	            // Floating data multiplier concentration factor (IEEE-32) */
      fmethod : array[0..47] of char;	  // Method/program/data filename w/extensions comma list */
      fzinc : single;	              // Z subfile increment (0 = use 1st subnext-subfirst) */
      fwplanes : integer ;	          // Number of planes for 4D with W dimension (0=normal) */
      fwinc : single;	              // W plane increment (only if fwplanes is not 0) */
      fwtype : BYTE ;	              // Type of W axis units (see definitions below) */
      freserv : array[0..186] of char;  // Reserved (must be set to zero) */
end ;

const
  SPCHSZ =  512  ; //  sizeof(SPCHDR)	; // Size of spectrum header for disk file (512 bytes) */

{
//*************************************************************************
* THIS IS THE OLD FORMAT HEADER
* In the old 0x4D format, fnpts is floating point rather than a DP integer,
* ffirst and flast are 32-bit floating point rather than 64-bit, and fnsub
* fmethod, and fextra do not exist.  (Note that in the new formats, the
* fcmnt text may extend into the fcatxt and fextra areas if the TALABS flag
* is not set.  However, any text beyond the first 130 bytes may be
* ignored in future versions if fextra is used for other purposes.)
* Also, in the old format, the date and time are stored differently.
* Note that the new format header has 512 bytes while old format headers
* have 256 bytes and in memory all headers use 288 bytes.  Also, the
* new header does not include the first subfile header but the old does.
* The following constants define the offsets in the old format header:

* Finally, the old format 32-bit Y values have the two words reversed from
* the Intel least-significant-word-first order.  Within each word, the
* least significant byte comes first, but the most significant word is first.
***************************************************************************/  }

type
  OSPCHDR  = packed record
     oftflgs : BYTE;
     oversn : BYTE;	         // 0x4D rather than 0x4C or 0x4B */
     oexp : Word	;		         // Word rather than byte */
     onpts : single ; 	       // Floating number of points */
     ofirst : single ;	       // Floating X coordinate of first pnt (SP rather than DP) */
     olast : single ; 	       // Floating X coordinate of last point (SP rather than DP) */
     oxtype : BYTE;	         // Type of X units */
     oytype : BYTE;	         // Type of Y units */
     oyear : Word	; 	       // Year collected (0=no date/time) - MSB 4 bits are Z type */
     omonth : BYTE;	         // Month collected (1=Jan) */
     oday : BYTE;		         // Day of month (1=1st) */
     ohour : BYTE; 	         // Hour of day (13=1PM) */
     ominute : BYTE;	         // Minute of hour */
     ores : array[0..7] of char;	  // Resolution text (null terminated unless 8 bytes used) */
     opeakpt : Word	;
     onscans : Word	;
     ospare : array[0..6] of single ;
     ocmnt : array[0..129] of char;
     ocatxt : array[0..29] of char;
     osubh1 : array[0..31] of char;	// Header for first (or main) subfile included in main header */
end ;

{
//*************************************************************************
* This structure defines the subfile headers that preceed each trace in a
* multi-type file.  Note that for evenly-spaced files, subtime and subnext are
* optional (and ignored) for all but the first subfile.  The (subnext-subtime)
* for the first subfile determines the Z spacing for all evenly-spaced subfiles.
* For ordered and random multi files, subnext is normally set to match subtime.
* However, for all types, the subindx must be correct for all subfiles.
* This header must must always be present even if there is only one subfile.
* However, if TMULTI is not set, then the subexp is ignored in favor of fexp.
* Normally, subflgs and subnois are set to zero and are used internally.
***************************************************************************/    }
const
 SUBCHGD = 1	;// Subflgs bit if subfile changed */
 SUBNOPT = 8	;// Subflgs bit if peak table file should not be used */
 SUBMODF = 128	;// Subflgs bit if subfile modified by arithmetic */


type
  SUBHDR  = packed record   // size is 32 bytes
     subflgs : BYTE;	// Flags as defined above (set to zero) */
     subexp :  BYTE ;	// Exponent for sub-file's Y values (80h=>float) - Only use if multifile */
     subindx : WORD;	// Integer index number of trace subfile (0=first) */
     subtime : single;	// Floating time for trace (Z axis corrdinate) */
     subnext : single;	// Floating time for next trace (May be same as beg) */
     subnois : single;	// Floating peak pick noise level if high byte nonzero (set to zero) */
     subnpts : integer;	// Integer number of subfile points for TXYXYS type */
     subscan: integer ;	// Integer number of co-added scans or 0 (for collect) */
     subwlevel : single;	// Floating W axis value (if fwplanes non-zero) */
     subresv: array[0..3] of char;	// Reserved area (must be set to zero) */
end ;

const
  SPCSUBHSZ =  32  ; //  sizeof(SPCHDR)	; // Size of spectrum header for disk file (512 bytes) */


//  #define FSNOIS fsubh1+subnois+3 // Byte which is non-zero if subnois valid */

// This structure defines the entries in the XY subfile directory. */
// Its size is guaranteed to be 12 bytes long. */
type
  SSFSTC  = packed record
    ssfposn : integer;	// disk file position of beginning of subfile (subhdr)*/
    ssfsize : integer;	// byte size of subfile (subhdr+X+Y) */
    ssftime : integer;	// floating Z time of subfile (subtime) */
end ;


// This structure defines the header at the beginning of a flogoff block. */
// The logsizd should be large enough to hold the text and its ending zero. */
// The logsizm is normally set to be a multiple of 4096 and must be */
// greater than logsizd.  It is normally set to the next larger multiple. */
// The logdsks section is a binary block which is not read into memory. */
type
  LOGSTC  = packed record   // log block header format */
    logsizd : integer;	// byte size of disk block */
    logsizm : integer;	// byte size of memory block */
    logtxto : integer;	// byte offset to text */
    logbins : integer;	// byte size of binary area (immediately after logstc) */
    logdsks : integer;	// byte size of disk area (immediately after logbins) */
    logspar : array[0..43] of char;	// reserved (must be zero) */
end ; 

// Possible settings for fxtype, fztype, fwtype. */
// XEV and XDIODE - XMETERS are new and not supported by all software. */
const
 XARB	= 0	;// Arbitrary */
 XWAVEN	= 1	;// Wavenumber (cm-1) */
 XUMETR	= 2	;// Micrometers (um) */
 XNMETR	= 3	;// Nanometers (nm) */
 XSECS	= 4	;// Seconds */
 XMINUTS = 5	;// Minutes */
 XHERTZ	= 6	;// Hertz (Hz) */
 XKHERTZ = 7	;// Kilohertz (KHz) */
 XMHERTZ = 8	;// Megahertz (MHz) */
 XMUNITS = 9	;// Mass (M/z) */
 XPPM	= 10	;// Parts per million (PPM) */
 XDAYS	= 11	;// Days */
 XYEARS	= 12 ;	// Years */
 XRAMANS = 13 ;	// Raman Shift (cm-1) */

 XEV	= 14	;// eV */
 ZTEXTL	= 15 ;	// XYZ text labels in fcatxt (old 0x4D version only) */
 XDIODE	= 16 ;	// Diode Number */
 XCHANL	= 17 ;	// Channel */
 XDEGRS	= 18 ;	// Degrees */
 XDEGRF	= 19 ;	// Temperature (F) */
 XDEGRC	= 20 ;	// Temperature (C) */
 XDEGRK	= 21 ;	// Temperature (K) */
 XPOINT	= 22 ;	// Data Points */
 XMSEC	= 23 ;	// Milliseconds (mSec) */
 XUSEC	= 24 ;	// Microseconds (uSec) */
 XNSEC	= 25 ;	// Nanoseconds (nSec) */
 XGHERTZ = 26 ;	// Gigahertz (GHz) */
 XCM	= 27 ; // Centimeters (cm) */
 XMETERS = 28 ;	// Meters (m) */
 XMMETR	= 29 ;	// Millimeters (mm) */
 XHOURS	= 30 ;	// Hours */

 XDBLIGM = 255	; // Double interferogram (no display labels) */

// Possible settings for fytype.  (The first 127 have positive peaks.) */
// YINTENS - YDEGRK and YEMISN are new and not supported by all software. */
 YARB	= 0	; // Arbitrary Intensity */
 YIGRAM	= 1	;// Interferogram */
 YABSRB	= 2	;// Absorbance */
 YKMONK	= 3	;// Kubelka-Monk */
 YCOUNT	= 4	;// Counts */
 YVOLTS	= 5	;// Volts */
 YDEGRS	= 6	;// Degrees */
 YAMPS	= 7	;// Milliamps */
 YMETERS = 8	;// Millimeters */
 YMVOLTS = 9	;// Millivolts */
 YLOGDR	= 10 ;	// Log(1/R) */
 YPERCNT = 11	;// Percent */

 YINTENS = 12 ;	// Intensity */
 YRELINT = 13 ;	// Relative Intensity */
 YENERGY = 14 ;	// Energy */
 YDECBL	= 16 ;	// Decibel */
 YDEGRF	= 19 ;	// Temperature (F) */
 YDEGRC	= 20 ;	// Temperature (C) */
 YDEGRK	= 21 ;	// Temperature (K) */
 YINDRF	= 22 ;	// Index of Refraction [N] */
 YEXTCF	= 23 ;	// Extinction Coeff. [K] */
 YREAL	= 24 ;	// Real */
 YIMAG	= 25 ;	// Imaginary */
 YCMPLX	= 26 ;	// Complex */

 YTRANS	= 128	;// Transmission (ALL HIGHER MUST HAVE VALLEYS!) */
 YREFLEC = 129	;// Reflectance */
 YVALLEY = 130	;// Arbitrary or Single Beam with Valley Peaks */
 YEMISN	= 131	;// Emission */


// Possible bit FTFLGS flag byte settings. */
// Note that TRANDM and TORDRD are mutually exclusive. */
// Code depends on TXVALS being the sign bit.  TXYXYS must be 0 if TXVALS=0. */
// In old software without the fexper code, TCGRAM specifies a chromatogram. */
 TSPREC	= 1	;// Single precision (16 bit) Y data if set. */
 TCGRAM	= 2	;// Enables fexper in older software (CGM if fexper=0) */
 TMULTI	= 4	;// Multiple traces format (set if more than one subfile) */
 TRANDM	= 8	;// If TMULTI and TRANDM=1 then arbitrary time (Z) values */
 TORDRD	= 16 ;	// If TMULTI abd TORDRD=1 then ordered but uneven subtimes */
 TALABS	= 32 ;	// Set if should use fcatxt axis labels, not fxtype etc.  */
 TXYXYS	= 64 ;	// If TXVALS and multifile, then each subfile has own X's */
 TXVALS	= 128	; // Floating X value array preceeds Y's  (New format only) */



// FMODS spectral modifications flag setting conventions: */
//  "A" (2^01) = Averaging (from multiple source traces) */
//  "B" (2^02) = Baseline correction or offset functions */
//  "C" (2^03) = Interferogram to spectrum Computation */
//  "D" (2^04) = Derivative (or integrate) functions */
//  "E" (2^06) = Resolution Enhancement functions (such as deconvolution) */
//  "I" (2^09) = Interpolation functions */
//  "N" (2^14) = Noise reduction smoothing */
//  "O" (2^15) = Other functions (add, subtract, noise, etc.) */
//  "S" (2^19) = Spectral Subtraction */
//  "T" (2^20) = Truncation (only a portion of original X axis remains) */
//  "W" (2^23) = When collected (date and time information) has been modified */
//  "X" (2^24) = X units conversions or X shifting */
//  "Y" (2^25) = Y units conversions (transmission->absorbance, etc.) */
//  "Z" (2^26) = Zap functions (features removed or modified) */

// Instrument Technique fexper settings */
// In older software, the TCGRAM in ftflgs must be set if fexper is non-zero. */
// A general chromatogram is specified by a zero fexper when TCGRAM is set. */
 SPCGEN	= 0 ;	   // General SPC (could be anything) */
 SPCGC	= 1	;      // Gas Chromatogram */
 SPCCGM	= 2	;    // General Chromatogram (same as SPCGEN with TCGRAM) */
 SPCHPLC = 3	;    // HPLC Chromatogram */
 SPCFTIR = 4	;    // FT-IR, FT-NIR, FT-Raman Spectrum or Igram (Can also be used for scanning IR.) */
 SPCNIR	= 5 ;    // NIR Spectrum (Usually multi-spectral data sets for calibration.) */
 SPCUV	= 7	;      // UV-VIS Spectrum (Can be used for single scanning UV-VIS-NIR.) */
 SPCXRY	= 8	;    // X-ray Diffraction Spectrum */
 SPCMS	= 9	;      // Mass Spectrum  (Can be single, GC-MS, Continuum, Centroid or TOF.) */
 SPCNMR	= 10 ;   // NMR Spectrum or FID */
 SPCRMN	= 11 ;	 // Raman Spectrum (Usually Diode Array, CCD, etc. use SPCFTIR for FT-Raman.) */
 SPCFLR	= 12 ;   // Fluorescence Spectrum */
 SPCATM	= 13 ;   // Atomic Spectrum */
 SPCDAD	= 14 ;	// Chromatography Diode Array Spectra */


type
  ReadWriteSPC  = class(TObject)
  public
     newHeader : SPCHDR ;
     oldHeader : OSPCHDR ;
     currentSubHdr : SUBHDR ;

     FlagsNumBits :integer ;     // 1
     FlagsMulti : boolean ;      // 4
     FlagsTimeArb : boolean ;    // 8
     FlagsTimeOrd : boolean ;    // 16
     FlagsOwnX  : boolean ;      // 64
     FlagsXpreceedsY : boolean ; // 128

//     fileData : TMemoryStream ;
     headerTypeNew : boolean ; // if true then use newHeader (IF 0x4B=> new LSB 1st, 0x4C=> new MSB 1st, 0x4D=> old format)
     ydataFormatFloat : boolean ;

     constructor Create  ;  // 
     destructor  Destroy; // override;
     procedure   Free ;

     function  ReadSPCDataIntoSpectraRange(filename : string ; SpectObj : TSpectraRanges ) : integer   ;  // returns number of sub spectra read or 0 if failed
     function  WriteSPCDataFromSpectraRange(filename : string ; SpectObj : TSpectraRanges ) : integer   ; // returns number of sub spectra written or 0 if failed
     procedure ClearHeader ;
end ;


implementation

//****************************************************************************//
//************          ReadWriteSPC  File object              ***************//
//****************************************************************************//
//****************************************************************************//

constructor ReadWriteSPC.Create ;
begin
  // fileData := TMemoryStream.Create ;
//   newHeader := SPCHDR.Create ;
   inherited Create ;
end ;


destructor  ReadWriteSPC.Destroy; // override;
begin
//  fileData.Free ;
//  newHeader.Free ;
  inherited Destroy ;
end ;


procedure ReadWriteSPC.Free;
begin
 if Self <> nil then Destroy;
end;

procedure ReadWriteSPC.ClearHeader ;
var
  t1 : integer  ;
  Present: TDateTime;
  year_w, month_w, day_w : word ;
  year, month, day : integer ;
  Hour_w, Min_w, Sec_w, MSec_w : word ;
  Hour, Min, Sec, MSec : integer ;

begin
      newHeader.ftflgs := 0 ;	              // Flag bits defined below */
      newHeader.fversn := 75;	                // 0x4B (=75) => new LSB 1st, 0x4C (=76) => new MSB 1st, 0x4D=> old format */
      newHeader.fexper := $04;	                // Instrument technique code = 04 = FTIR (see above) */
      newHeader.fexp   := $80; 	              // Fraction scaling exponent integer (80h=>float) */
      newHeader.fnpts  := 0 ;	            // Integer number of points (or TXYXYS directory position) */
      newHeader.ffirst := 0.0;	              // Floating X coordinate of first point */
      newHeader.flast  := 0.0;	              // Floating X coordinate of last point */
      newHeader.fnsub  := 0 ;	            // Integer number of subfiles (1 if not TMULTI) */
      newHeader.fxtype := 0;	                // Type of X axis units (see definitions above) */
      newHeader.fytype := 0;	                // Type of Y axis units (see definitions above) */
      newHeader.fztype := 0;	                // Type of Z axis units (see definitions above) */
      newHeader.fpost  := 0;	                // Posting disposition (see GRAMSDDE.H) */

      Present:= Now;
      DecodeDate(Present, Year_w, Month_w, Day_w);
      DecodeTime(Present, Hour_w, Min_w, Sec_w, MSec_w);

      year := Year_w ;
      month := Month_w ;
      day := day_w ;
      Hour := Hour_w ;
      Min := Min_w ;

      year  := year shl 20  ;
      month := month shl 16  ;
      day   := day shl 11 ;
      Hour  := Hour shl 6 ;


      newHeader.fdate  :=  year +  month + day + Hour + Min  ;// Date/Time LSB: min=6b,hour=5b,day=5b,month=4b,year=12b */


      for t1 := 0 to 8 do newHeader.fres[t1] := #0 ;	    // Resolution description text (null terminated) */
      for t1 := 0 to 8 do newHeader.fsource[t1] := #0 ;	  // Source instrument description text (null terminated) */
      newHeader.fpeakpt := 0	;	                // Peak point number for interferograms (0=not known) */
      for t1 := 0 to 7 do newHeader.fspare[t1] := 0 	 ; // Used for Array Basic storage */
      for t1 := 0 to 129 do newHeader.fcmnt[t1] := #0 ;	    // Null terminated comment ASCII text string */
      for t1 := 0 to 29 do newHeader.fcatxt[t1] := #0 ;	    // X,Y,Z axis label strings if ftflgs=TALABS */
      newHeader.flogoff := 0 ;	          // File offset to log block or 0 (see above) */
      newHeader.fmods := 0 ;	            // File Modification Flags (see below: 1=A,2=B,4=C,8=D..) */
      newHeader.fprocs := 0;	                // Processing code (see GRAMSDDE.H) */
      newHeader.flevel := 0;	                // Calibration level plus one (1 = not calibration data) */
      newHeader.fsampin := 0	;	              // Sub-method sample injection number (1 = first or only ) */
      newHeader.ffactor := 0;	            // Floating data multiplier concentration factor (IEEE-32) */
      for t1 := 0 to 47 do newHeader.fmethod[t1] := #0 ;	  // Method/program/data filename w/extensions comma list */
      newHeader.fzinc := 0;	              // Z subfile increment (0 = use 1st subnext-subfirst) */
      newHeader.fwplanes := 0 ;	          // Number of planes for 4D with W dimension (0=normal) */
      newHeader.fwinc := 0;	              // W plane increment (only if fwplanes is not 0) */
      newHeader.fwtype := 0 ;	              // Type of W axis units (see definitions below) */
      for t1 := 0 to 186 do newHeader.freserv[t1] := #0 ;  // Reserved (must be set to zero) */



      currentSubHdr.subflgs := 0  ;	// Flags as defined above (set to zero) */
      currentSubHdr.subexp  := $80  ;	// Exponent for sub-file's Y values (80h=>float) - Only use if multifile */
      currentSubHdr.subindx := 0 ;	// Integer index number of trace subfile (0=first) */
      currentSubHdr.subtime := 0 ;	// Floating time for trace (Z axis corrdinate) */
      currentSubHdr.subnext := 0 ;	// Floating time for next trace (May be same as beg) */
      currentSubHdr.subnois := 0 ;	// Floating peak pick noise level if high byte nonzero (set to zero) */
      currentSubHdr.subnpts := 0 ;	// Integer number of subfile points for TXYXYS type */
      currentSubHdr.subscan := 0  ;	// Integer number of co-added scans or 0 (for collect) */
      currentSubHdr.subwlevel := 0 ;	// Floating W axis value (if fwplanes non-zero) */
      for t1 := 0 to 3 do currentSubHdr.subresv := #0 ;	// Reserved area (must be set to zero) */
end ;


function  ReadWriteSPC.ReadSPCDataIntoSpectraRange(filename : string ; SpectObj : TSpectraRanges ) : integer   ;
var
  t1, t2, t3, t4, y_int_format: integer ;
  w3 : word ;
  s1, inc_s : single ;
  format, b1 : byte ;
  fileData : TMemoryStream ;
begin
   result := 0 ;
   try
     fileData := TMemoryStream.Create ;
     fileData.LoadFromFile(filename) ;
     fileData.Seek(1,soFromBeginning) ;
     fileData.Read(format,1) ;
     fileData.Seek(0,soFromBeginning) ;

     if format = $4D then  // 0x4D = 77
     begin
      headerTypeNew := false ;
      MessageDlg('Old SPC file format not supported' +#13+ ' SPC file read will not be completed' ,mtError, [mbOK], 0) ;
      exit ;
     end
     else
     begin
      headerTypeNew := true ;
      fileData.Read(newHeader,512) ;
     end ;

     if newHeader.fnsub = 0 then  // ensure number of sub files is set to a useful value
       newHeader.fnsub := 1 ;


{
* Thus an SPC trace file normally has these components in the following order:
*	SPCHDR		Main header (512 bytes in new format, 224 or 256 in old)
*      [X Values]	Optional FNPTS 32-bit floating X values if TXVALS flag (= 128)
*	SUBHDR		Subfile Header for 1st subfile (32 bytes)
*	Y Values	FNPTS 32 or 16 bit fixed Y fractions scaled by exponent
*      [SUBHDR	]	Optional Subfile Header for 2nd subfile if TMULTI flag
*      [Y Values]	Optional FNPTS Y values for 2nd subfile if TMULTI flag
*	...		Additional subfiles if TMULTI flag (up to FNSUB total)
*      [Log Info]	Optional LOGSTC and log data if flogoff is non-zero

* However, files with the TXYXYS (64) ftflgs flag set have these components:
*	SPCHDR		Main header (512 bytes in new format)
*	SUBHDR		Subfile Header for 1st subfile (32 bytes)
*	X Values	FNPTS 32-bit floating X values
*	Y Values	FNPTS 32 or 16 bit fixed Y fractions scaled by exponent
*      [SUBHDR	]	Subfile Header for 2nd subfile
*      [X Values]	FNPTS 32-bit floating X values for 2nd subfile
*      [Y Values]	FNPTS Y values for 2nd subfile
*	...		Additional subfiles (up to FNSUB total)
*      [Directory]	Optional FNSUB SSFSTC entries pointed to by FNPTS
*      [Log Info]	Optional LOGSTC and log data if flogoff is non-zero }


     if  (newHeader.ftflgs and 1) = 1 then
      FlagsNumBits := 16
     else
      FlagsNumBits := 32 ;

     if  (newHeader.ftflgs and 4) = 4 then  FlagsMulti := true            // MULTI-FILE !!!
     else FlagsMulti := false ;


     if  (newHeader.ftflgs and 8) = 8 then  FlagsTimeArb := true         // NOT USED - Z is unordered
     else FlagsTimeArb := false ;

     if  (newHeader.ftflgs and 16) = 16 then  FlagsTimeOrd := true       //  Z value read from each Sub-header structure   (subindx (0 based) and subtime)
     else FlagsTimeOrd := false ;

     if  (newHeader.ftflgs and 64) = 64 then  FlagsOwnX := true           // X values preceed each Y subfile.
     else FlagsOwnX := false ;

     if  (newHeader.ftflgs and 128) = 128 then
     begin
       FlagsXpreceedsY := true   ;// Non-even X values => X values preceed each Y subfile. (do not calculate X values)
       if FlagsMulti then
       begin
         MessageDlg('This function does not read in multifiles with varying X data spacing' +#13+ ' SPC file read will not be completed' ,mtError, [mbOK], 0) ;
         exit ;
       end ;
     end
     else
        FlagsXpreceedsY := false ;


     // set up xCoord TMatrix data
     SpectObj.xCoord.SDPrec  := 4 ;
     SpectObj.xCoord.numRows := 1 ;
     SpectObj.xCoord.numCols := newHeader.fnpts ;
     SpectObj.xCoord.F_Mdata.SetSize(SpectObj.xCoord.SDPrec* SpectObj.xCoord.numCols) ;
     SpectObj.xCoord.F_Mdata.Seek(0,soFromBeginning) ;

     if not FlagsOwnX then
     begin
       // create x data from  (flast - ffirst)/ (fnpts -1)
       inc_s :=   (newHeader.flast - newHeader.ffirst)/ (newHeader.fnpts -1) ;
       for t1 := 0 to newHeader.fnpts-1 do
       begin
         s1 := newHeader.ffirst + (inc_s * t1) ;
         SpectObj.xCoord.F_Mdata.Write(s1,4) ;
       end ;
     end ;


     SpectObj.yCoord.SDPrec  := 4 ;
     SpectObj.yCoord.numRows := newHeader.fnsub ;
     SpectObj.yCoord.numCols := newHeader.fnpts ;
     SpectObj.yCoord.F_Mdata.SetSize(SpectObj.xCoord.SDPrec* SpectObj.yCoord.numRows * SpectObj.xCoord.numCols) ;
     SpectObj.yCoord.F_Mdata.Seek(0,soFromBeginning) ;



    if  (newHeader.ftflgs = 0) then  // only a single Y data file
    begin

    //  fileData.Read(currentSubHdr,32) ;

      if newHeader.fexp = $80 then
        ydataFormatFloat := true
      else
        ydataFormatFloat := false ;

      // READ SUB HEADER
      fileData.Read(currentSubHdr,32) ;

      for t2 := 0 to newHeader.fnpts-1 do  // for each point
      begin

        if  ydataFormatFloat then
        begin
            fileData.Read(s1,4) ;
            try
              if s1 > 10.0 then s1 := 10 ;
            except  on  EInvalidOp  do
              s1 := 0 ;
            end ;
            SpectObj.yCoord.F_Mdata.Write(s1,4) ;
          end

        else
        begin

            if FlagsNumBits = 32 then
            begin
               fileData.Read(t3,4) ;
               if newHeader.fexp > 128 then  t4 := newHeader.fexp -256
               else t4 := newHeader.fexp ;
               s1 := (power(2,(t4)) * t3 )/ (power(2,32)) ;
               SpectObj.yCoord.F_Mdata.Write(s1,4) ;
            end
            else
            if FlagsNumBits = 16 then
            begin
               fileData.Read(w3,2) ;
               if newHeader.fexp > 128 then  t4 := newHeader.fexp -256
               else t4 := newHeader.fexp ;
               s1 :=(power(2,(t4)) * w3) / (power(2,16)) ;
               SpectObj.yCoord.F_Mdata.Write(s1,4) ;
            end  ;
            
        end ;  // float else not float format
      end ; // for each point

    end
    else
    begin
      if newHeader.fexp = $80 then
       ydataFormatFloat := true
      else
       ydataFormatFloat := false ;


       for t1 := 1 to newHeader.fnsub do  // for each sub file
       begin
        if FlagsXpreceedsY then // this will only be executed once as newHeader.fnsub = 1 if FlagsXpreceedsY is true due to above code   (if  (newHeader.ftflgs and 128) = 128 then)
        begin  // read first X array of floating points
         for t2 := 0 to newHeader.fnpts-1 do
         begin
           fileData.Read(s1,4) ;
           SpectObj.xCoord.F_Mdata.Write(s1,4) ;
         end ;
        end ;


        // READ SUB HEADER
       fileData.Read(currentSubHdr,32) ;
       if currentSubHdr.subexp = $80 then
         ydataFormatFloat := true
       else
         ydataFormatFloat := false ;

        for t2 := 0 to newHeader.fnpts-1 do  // for each point
        begin

          if  ydataFormatFloat then
          begin
            fileData.Read(s1,4) ;
            try
              if s1 > 10.0 then s1 := 10 ;
            except  on  EInvalidOp  do
              s1 := 0 ;
            end ;
            SpectObj.yCoord.F_Mdata.Write(s1,4) ;
          end

          else
          begin

            if FlagsNumBits = 32 then
            begin
               fileData.Read(t3,4) ;
               if currentSubHdr.subexp > 128 then  t4 := currentSubHdr.subexp -256
               else t4 := currentSubHdr.subexp ;
               s1 := (power(2,t4) * t3 )/ (power(2,32)) ;
               SpectObj.yCoord.F_Mdata.Write(s1,4) ;
            end
            else
            if FlagsNumBits = 16 then
            begin
               fileData.Read(w3,2) ;
               if currentSubHdr.subexp > 128 then  t4 := currentSubHdr.subexp -256
               else t4 := currentSubHdr.subexp ;
               s1 :=(power(2,t4 ) * w3) / (power(2,16)) ;
               SpectObj.yCoord.F_Mdata.Write(s1,4) ;
            end  ;

          end ;
        end ;
     end ;
    end ;  // (newHeader.ftflgs <> 0)

    SpectObj.SeekFromBeginning(3,1,0) ;
    result := newHeader.fnsub ;

  finally
     fileData.Free ;
  end ;

end ;


function  ReadWriteSPC.WriteSPCDataFromSpectraRange(filename : string ; SpectObj : TSpectraRanges ) : integer   ; // returns number of sub spectra written or 0 if failed
var
  t1, t2 : integer ;
  s1 : single ;
  d1 : double ;
  spcFile : TMemoryStream ;
  firstx_s : single ;
  firstx_d : double ;
  orderLowToHigh : boolean ;
begin
  result := 0 ;
  Self.ClearHeader ;

  if SpectObj.yCoord.numRows > 1 then
    newHeader.ftflgs := $04 ;    // = 4 = multifile

  newHeader.fnpts  := SpectObj.xCoord.numCols ;	              // Integer number of points (or TXYXYS directory position) */

  // check the order of the y data (low to high or high to low)
  SpectObj.xCoord.F_Mdata.Seek(0,soFromBeginning) ;
  if SpectObj.xCoord.SDPrec = 4 then  SpectObj.xCoord.F_Mdata.Read(firstx_s,4)
  else
  if SpectObj.xCoord.SDPrec = 8 then
  begin
    SpectObj.xCoord.F_Mdata.Read(firstx_d,8) ;
    firstx_s := firstx_d ;
  end ;
  if firstx_s > SpectObj.XLow then
      orderLowToHigh := false
  else
      orderLowToHigh := true   ;
  SpectObj.xCoord.F_Mdata.Seek(0,soFromBeginning) ;

  newHeader.ffirst := SpectObj.XLow ;	              // Floating X coordinate of first point */
  newHeader.flast  := SpectObj.XHigh ;	              // Floating X coordinate of last point */
  newHeader.fnsub  := SpectObj.yCoord.numRows ;	              // Integer number of subfiles (1 if not TMULTI) */
  newHeader.fxtype := XWAVEN;	                // Type of X axis units (see definitions above) */
  newHeader.fytype := YABSRB;	                // Type of Y axis units (see definitions above) */
  newHeader.fztype := 0;	                // Type of Z axis units (see definitions above) */

  try
  spcFile := TMemoryStream.Create ;
  spcFile.SetSize(SPCHSZ + (newHeader.fnsub*SPCSUBHSZ) + (newHeader.fnsub* SpectObj.xCoord.numCols * sizeof(single) ) ) ;
  spcFile.Write(newHeader, SPCHSZ) ;

  SpectObj.SeekFromBeginning(3,1,0) ;

  for t1 := 0 to newHeader.fnsub-1 do
  begin
   currentSubHdr.subindx := word(t1) ;	// Integer index number of trace subfile (0=first) */
   currentSubHdr.subtime := t1 ;	// Floating time for trace (Z axis corrdinate) */

   spcFile.Write(currentSubHdr, SPCSUBHSZ) ;

   if orderLowToHigh then
   begin
   if  SpectObj.yCoord.SDPrec = 4 then
   begin
     for t2 := 1 to SpectObj.yCoord.numCols  do
     begin
       SpectObj.yCoord.F_Mdata.Read(s1,SpectObj.yCoord.SDPrec) ;
       spcFile.Write(s1, SpectObj.yCoord.SDPrec) ;
     end ;
   end
   else
   if  SpectObj.yCoord.SDPrec = 8 then
   begin
     for t2 := 1 to SpectObj.yCoord.numCols  do
     begin
       SpectObj.yCoord.F_Mdata.Read(d1,8) ;
       s1 := d1 ;
       spcFile.Write(s1, SpectObj.yCoord.SDPrec) ;
     end ;
   end ;
   end
   else
   if orderLowToHigh = false then
   begin
   if  SpectObj.yCoord.SDPrec = 4 then
   begin
     for t2 := SpectObj.yCoord.numCols -1 downto 0  do
     begin
       SpectObj.yCoord.F_Mdata.Seek((t1*SpectObj.yCoord.numCols*SpectObj.yCoord.SDPrec)+(t2*SpectObj.yCoord.SDPrec),soFromBeginning) ;
       SpectObj.yCoord.F_Mdata.Read(s1,SpectObj.yCoord.SDPrec) ;
       spcFile.Write(s1, 4) ;
     end ;
   end
   else
   if  SpectObj.yCoord.SDPrec = 8 then
   begin
     for t2 := 1 to SpectObj.yCoord.numCols  do
     begin
       SpectObj.yCoord.F_Mdata.Seek((t1*SpectObj.yCoord.numCols*SpectObj.yCoord.SDPrec)+(t2*SpectObj.yCoord.SDPrec),soFromBeginning) ;
       SpectObj.yCoord.F_Mdata.Read(d1,SpectObj.yCoord.SDPrec) ;
       s1 := d1 ;
       spcFile.Write(s1, 4) ;
     end ;
   end ;
   end ;


  end ;

  spcFile.SaveToFile( filename ) ;
  finally
  spcFile.Free ;
  end ;

  result :=  newHeader.fnsub ;

end ;





end.
