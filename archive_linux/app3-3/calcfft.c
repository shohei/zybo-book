#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>
#include <errno.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <math.h>

#define FFTN 2048

short a0, a1, a2, b1, b2;

void FftCal(float *iW, float *oR, float *oI, float *oP);
void TxtLoad(char *fn, float *iW);
void TxtSave(char *fn, float *iW);

int main(int argc, char *argv[]) {

  float InWave[FFTN];
  float RealSpec[FFTN];
  float ImagSpec[FFTN];
  float PwrSpec[FFTN];

        TxtLoad("outwave.txt", InWave);

        FftCal(InWave, RealSpec, ImagSpec, PwrSpec);

        TxtSave("fft.txt", PwrSpec);

  return 0;
}

void FftCal(float *iW, float *oR, float *oI, float *oP)
{
        short N = FFTN; 
        short P; 
        short N_2 = N/2;
        short i,j,k,kp,m,h;
        float w1, w2;
        float s1,s2;
        float t1,t2;
        float tri[FFTN];
        float fReal[FFTN], fImag[FFTN];

        // 2^P=N, Nが2048のときPは11
        i = N; P = 0;
        while (i != 1) {
                i = i / 2;
                P++;
        }

        // 実数部には時間軸波形を入れる。虚数部はゼロで埋める。
        for (i = 0; i < N; i++) {
                fReal[i] = iW[i]; fImag[i] = 0;
        }

        // 三角関数
	for ( i = 0; i < N_2; i++ ) {
		tri[i] = cos( 2 * i * M_PI / N );
		tri[i + N_2] = (-1.0) * sin( 2 * i * M_PI / N );
	}

        // ビット逆順ソート
        j = 0;
        for ( i = 0; i <= N-2; i++ ) {
                if (i < j) {
                        t1 = fReal[j]; fReal[j] = fReal[i]; fReal[i] = t1;
                        t2 = fImag[j]; fImag[j] = fImag[i]; fImag[i] = t2;
                }
                k = N_2;
                while (k <= j) {
                        j = j - k; k = k/2;
                }
                j = j + k;
        }

        // バタフライ演算
        for ( i = 1; i <= P; i++ ) {
                m = pow(2, i);
                h = m/2;
                for ( j = 0; j < h; j++ ) {
                        w1 = tri[j*(N/m)];
                        w2 = tri[j*(N/m) + N_2];
                        for( k = j; k < N; k+=m ) {
                                kp = k + h;
                                s1 = fReal[kp] * w1 - fImag[kp] * w2;
                                s2 = fReal[kp] * w2 + fImag[kp] * w1;
                                t1 = fReal[k] + s1; fReal[kp] = fReal[k] - s1; fReal[k] = t1;
                                t2 = fImag[k] + s2; fImag[kp] = fImag[k] - s2; fImag[k] = t2;
                        }
                }
        }

        // 実数部、虚数部、パワースペクトルを返す
        for ( i = 0; i < N; i++ ) {
                oR[i] = fReal[i];
                oI[i] = fImag[i];
                oP[i] = fReal[i] * fReal[i] + fImag[i] * fImag[i];
    //            printf( "%d\n", oP[i] );
        }
}

void TxtLoad(char *fn, float *iW)
{
  int count = 0;
  char charline[40];
  FILE *fp;

  fp = fopen( fn, "r" );
  if( fp == NULL ){
    printf( "%s cannot be opened.\n", fn );
    exit(1);
  } 

  fseek( fp, 0L, SEEK_SET );
  while( fgets(charline, 40, fp) != NULL ) {
    iW[count] = atof(charline);
    printf( "%d  %f\n", count, iW[count] );
    count++;

    if(count == FFTN) {
      break;
    }
  } 
  fclose( fp );
}

void TxtSave(char *fn, float *iW)
{
  int i;
  char charline[40];
  FILE *fp;

  fp = fopen( fn, "w" );
  if( fp == NULL ){
    printf( "%s cannot be opened.\n", fn );
    exit(1);
  } 

  fseek( fp, 0L, SEEK_SET );
  for( i = 0; i < FFTN; i++) {
    sprintf(charline, "%f\n", iW[i]);
    fputs(charline, fp);
//    printf( "%d\n", iW[i] );
  } 
  fclose( fp );
}

