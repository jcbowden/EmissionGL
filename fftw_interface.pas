{--------------------------------------------------------------}
{ Delphi interface to the FFTW library -- FFTW Version 3.0.1.  }
{ Note that this interface is incomplete. Additional function  }
{ interface entries may be added in an anologous manner, see   }
{ fftw  for more details.                  }
{                                                              }
{ Last modified 22/DEC/03                                      }
{ Written by Mark G. Beckett (g.beckett@epcc.ed.ac.uk          }
{--------------------------------------------------------------}

unit fftw_interface;

interface
 {EPCC (MGB) - Note that the FFTW memory allocation routines can not be used
  for data arrays, because the DLL is allocated a separate heap that is not
  accessible from the Delphi runtime environment.}
 function fftwf_malloc(n : Integer) : Pointer; cdecl;

 procedure fftwf_free(p : Pointer); cdecl;

 function fftwf_plan_dft_1d(n : Integer; inData : PSingle; outData : PSingle; sign : Integer; flags : Longword) : Pointer; cdecl;

 function fftwf_plan_dft_r2c_1d(n : Integer; inData : PSingle; outData : PSingle; flags : Longword) : Pointer; cdecl;

 function fftwf_plan_dft_r2c_3d(nx : Integer; ny : Integer; nz : Integer; inData : PSingle; outData : PSingle; flags : Longword) : Pointer; cdecl;

 function fftwf_plan_dft_c2r_3d(nx : Integer; ny : Integer; nz : Integer; inData : PSingle; outData : PSingle; flags : Longword) : Pointer; cdecl;

 function fftwf_plan_dft_c2r_1d(n : Integer; inData : PSingle; outData : PSingle; flags : Longword) : Pointer; cdecl;

 procedure fftwf_destroy_plan(plan : Pointer); cdecl;

 procedure fftwf_execute(plan : Pointer); cdecl;

const
{EPCC (MGB) - FFTW documented constants, taken from "api/fftw3.h". Comments
 to the right of the definitions are transcribed from the original header
 file.}

 FFTW_FORWARD        = -1;
 FFTW_BACKWARD        = 1;

 FFTW_MEASURE         = 0;
 FFTW_DESTROY_INPUT   = 1;   {1U << 0}
 FFTW_UNALIGNED       = 2;   {1U << 1}
 FFTW_CONSERVE_MEMORY = 4;   {1U << 2}
 FFTW_EXHAUSTIVE      = 8;   {1U << 3} {NO_EXHAUSTIVE is default }
 FFTW_PRESERVE_INPUT  = 16;  {1U << 4} {cancels FFTW_DESTROY_INPUT}
 FFTW_PATIENT         = 32;  {1U << 5} {IMPATIENT is default }
 FFTW_ESTIMATE        = 64;  {1U << 6}

{FFTW undocumented constants have not been defined in this implementation.
 They are not required for typical usage of the library.}
CONST
  FFTWdll_single = 'libfftw3f-3.dll';


implementation

uses
  SysUtils;
  function fftwf_malloc(n : Integer): Pointer; cdecl; external FFTWdll_single;
  procedure fftwf_free(p : Pointer);  cdecl; external FFTWdll_single;
  {Commented prototypes are taken from FFTW library. }

  // NB r2c = real to complex
  //    c2r = complex to real

  {fftw_plan fftwf_plan_dft_1d)(int n, C *in, C *out, int sign, unsigned flags)}
  function fftwf_plan_dft_1d(n : Integer; inData : PSingle; outData : PSingle; sign : Integer; flags : Longword) : Pointer; cdecl; external FFTWdll_single;

  { fftw_plan fftwf_plan_dft_r2c_1d(int n, float *in,  fftw_complex *out, unsigned flags);}
  function fftwf_plan_dft_r2c_1d(n : Integer;  inData : PSingle; outData : PSingle; flags : Longword) : Pointer; cdecl; external FFTWdll_single;

  {fftw_plan fftwf_plan_dft_r2c_3d(int nx, int ny, int nz, R *in, C *out, unsigned flags)}
  function fftwf_plan_dft_r2c_3d(nx : Integer; ny : Integer; nz : Integer; inData : PSingle; outData : PSingle; flags : Longword) : Pointer;   cdecl; external FFTWdll_single;

  {fftw_plan fftwf_plan_dft_c2r_1d(int n, C *in, R *out, unsigned flags)}
  function fftwf_plan_dft_c2r_1d(n : Integer; inData : PSingle; outData : PSingle; flags : Longword) : Pointer;   cdecl; external FFTWdll_single;

  {fftw_plan fftwf_plan_dft_c2r_3d(int nx, int ny, int nz, C *in, R *out, unsigned flags)}
  function fftwf_plan_dft_c2r_3d(nx : Integer; ny : Integer; nz : Integer;   inData : PSingle; outData : PSingle; flags : Longword) : Pointer;  cdecl; external FFTWdll_single;

   {void fftwf_destroy_plan(fftw_plan p)}
   procedure fftwf_destroy_plan(plan : Pointer);  cdecl; external FFTWdll_single;

   {void fftwf_execute(const fftw_plan p)}
   procedure fftwf_execute(plan : Pointer);   cdecl; external FFTWdll_single;

end.


{ example usage:

 program fftw_example;
    uses
      SysUtils,
      fftw_interface in 'fftw_interface.pas';
    var
      // The in and out pointers can be equal, indicating an in-place transform
      // Data type is c array (row major) real (in[i][0]) and imaginary (in[i][1])
      // Data in the in/out arrays is overwritten during FFTW_MEASURE planning,
      // so such planning should be done before the input is initialized by the user.
      in, out : Array of Single;
      plan : Pointer;

      // If you want to transform a different array of the same size,
      // you can create a new plan with fftw_plan_dft_1d and FFTW automatically reuses
      // the information from the previous plan, if possible.
      // (Alternatively, with the “guru” interface you can apply a given plan to a
      // different array, if you are careful. See FFTW Reference.)

    begin
      ...
      SetLength(in, N);
      SetLength(out, N);
      plan := _fftwf_plan_dft_1d(dataLength, @in[0], @out[0],  FFTW_FORWARD, FFTW_ESTIMATE);
      ...
      _fftwf_execute(plan);
      ...
      _fftwf_destroy_plan(plan);
    end.




 }












