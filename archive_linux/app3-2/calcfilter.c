#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>
#include <errno.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <math.h>

float p_Fsamp;
float p_a0[8];
float p_a1[8];
float p_a2[8];
float p_b1[8];
float p_b2[8];

short a0, a1, a2, b1, b2;

int FilType = 0;
int OrderN = 2;

float p_AC;
float p_fc;
float Pi = 3.14159;
float PN2, PN1, PN0, PD2, PD1, PD0;
float SN2, SN1, SN0, SD2, SD1, SD0, SH;
float TN2, TN1, TN0, TD2, TD1, TD0, TH;
float FC1;
float fcp1;

void BasicFilCal();
void PreWarp();
void FreqTrans();
void SZTrans();

void allwrite(int fd, unsigned char *buf, int len);

int main(int argc, char *argv[]) {

  int fd;
  int address;
  unsigned char data[10];

  if (argc!=4) {
    fprintf(stderr, "Usage: %s filtype fs fC\n", argv[0]);
    exit(1);
  }
  
	p_Fsamp = atoi(argv[2]);
	p_fc = atoi(argv[3]); 
	p_AC = 3.0;

	FilType = atoi(argv[1]);

	BasicFilCal();
	PreWarp();
	FreqTrans();
	SZTrans();

  fprintf(stdout, "a0 = %f\n", p_a0[0]);
  fprintf(stdout, "a1 = %f\n", p_a1[0]);
  fprintf(stdout, "a2 = %f\n", p_a2[0]);
  fprintf(stdout, "b1 = %f\n", p_b1[0]);
  fprintf(stdout, "b2 = %f\n", p_b2[0]);

  a0 = (short)(p_a0[0] * pow(2, 14));
  a1 = (short)(p_a1[0] * pow(2, 14));
  a2 = (short)(p_a2[0] * pow(2, 14));
  b1 = (short)((-1) * p_b1[0] * pow(2, 14));
  b2 = (short)((-1) * p_b2[0] * pow(2, 14));

  fprintf(stdout, "a0 = %04X\n", a0);
  fprintf(stdout, "a1 = %04X\n", a1);
  fprintf(stdout, "a2 = %04X\n", a2);
  fprintf(stdout, "b1 = %04X\n", b1);
  fprintf(stdout, "b2 = %04X\n", b2);

  fd = open("/dev/xillybus_mem_8", O_WRONLY);

  address = 0;

  data[0] = (unsigned char)(a0 & 0xFF);
  data[1] = (unsigned char)((a0 >> 8) & 0xFF);
  data[2] = (unsigned char)(a1 & 0xFF);
  data[3] = (unsigned char)((a1 >> 8) & 0xFF);
  data[4] = (unsigned char)(a2 & 0xFF);
  data[5] = (unsigned char)((a2 >> 8) & 0xFF);
  data[6] = (unsigned char)(b1 & 0xFF);
  data[7] = (unsigned char)((b1 >> 8) & 0xFF);
  data[8] = (unsigned char)(b2 & 0xFF);
  data[9] = (unsigned char)((b2 >> 8) & 0xFF);

  if (lseek(fd, address, SEEK_SET) < 0) {
    perror("Failed to seek");
    exit(1);
  }
  allwrite(fd, data, 10);


  return 0;
}

void allwrite(int fd, unsigned char *buf, int len) {
  int sent = 0;
  int rc;

  while (sent < len) {
    rc = write(fd, buf + sent, len - sent);

    if ((rc < 0) && (errno == EINTR))
      continue;

    if (rc < 0) {
      perror("allwrite() failed to write");
      exit(1);
    }

    if (rc == 0) {
      fprintf(stderr, "Reached write EOF (?!)\n");
      exit(1);
    }

    sent += rc;
  }
}


//////////////////////////////////////////////
// Basic Analog LPF
void BasicFilCal() // Butterworth
{
	int i;
	float d0, bi, ai;
	float eps;

	eps = sqrt(pow(10.0, p_AC/10.0) - 1);
	d0 = pow(eps, (-1.0/OrderN));
	bi = d0 * d0;
	i = 1;
	ai = 2.0 * d0 * sin( i * Pi / (2.0 * OrderN) );

	if( OrderN == 1 ) {
		PN2 = 0.0; PN1 = 0.0; PN0 = d0;
		PD2 = 0.0; PD1 = 1.0; PD0 = d0;
	} else {
		PN2 = 0.0; PN1 = 0.0; PN0 = bi; 
		PD2 = 1.0; PD1 = ai; PD0 = bi;
	}
}	

//////////////////////////////////////////////
// Pre Warping
void PreWarp()
{
	float tmp_wc1;

	FC1 = p_fc;
	tmp_wc1 = (2.0 * p_Fsamp) * tan(2.0 * Pi * FC1 / (2.0 * p_Fsamp));
	fcp1 = tmp_wc1 / (2.0 * Pi);

}

//////////////////////////////////////////////
// Frequency Transformation
void FreqTrans()
{
	float wc1;

	wc1 = 2.0 * Pi * fcp1;

	if( FilType == 0 ) { // LPF
		if( OrderN == 1 ) {
			SH  = PD0 * wc1;
			SN2 = 0.0; SN1 = 0.0; SN0 = 1.0;
			SD2 = 0.0; SD1 = 1.0; SD0 = PD0 * wc1;
		} else {
			SH  = PD0 * wc1 * wc1;
			SN2 = 0.0; SN1 = 0.0; SN0 = 1.0;
			SD2 = 1.0; SD1 = PD1 * wc1; SD0 = PD0 * wc1 * wc1;
		}
	} else if( FilType == 1 ) { // HPF
		if( OrderN == 1 ) {
			SH  = 1.0;
			SN2 = 0.0; SN1 = 1.0; SN0 = 0.0;
			SD2 = 0.0; SD1 = 1.0; SD0 = wc1 / PD0;
		} else {
			SH  = 1.0;
			SN2 = 1.0; SN1 = 0.0; SN0 = 0.0;
			SD2 = 1.0; SD1 = PD1 * wc1 / PD0; SD0 = wc1 * wc1 / PD0;
		}
	}
}

//////////////////////////////////////////////
// s-z Transformation
void SZTrans()
{
	double alpha, beta, gg;
	int i;
	for (i = 0; i < 8; i++) {
		p_a0[i]=1.0; p_a1[i]=0.0; p_a2[i]=0.0; p_b1[i]=0.0; p_b2[i]=0.0;
	}

	alpha = 2.0 * p_Fsamp;

	if( FilType == 0 || FilType == 1 ) {
		if( OrderN == 1 ) {
			gg = 1.0 / (SD0 + alpha);
			p_a0[0] = (SN1 * alpha + SN0) * SH * gg;
			p_a1[0] = (SN0 - SN1 * alpha) * SH * gg;
			p_a2[0] = 0.0 * SH;
			p_b1[0] = (SD0 - alpha) / (SD0 + alpha);
			p_b2[0] = 0.0;
		} else {
			beta = SN2 * alpha * alpha;
			gg  = 1.0 / (alpha * alpha + SD1 * alpha + SD0);
			p_a0[0] = (beta + SN1 * alpha + SN0) * SH * gg;
			p_a1[0] = 2.0 * (SN0 - beta) * SH * gg;
			p_a2[0] = (beta - SN1 * alpha + SN0) * SH * gg;
			p_b1[0] = 2.0 * gg * (SD0 - alpha * alpha);
			p_b2[0] = gg * (alpha * alpha - SD1 * alpha + SD0);
		}
	}
}

