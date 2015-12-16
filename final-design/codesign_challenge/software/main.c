#include "system.h"
#include <stdio.h>
#include <stdlib.h>
#include <io.h>
#include "sys/alt_timestamp.h"

#define SCREENSIZE 512
#define SCREENBYTES (SCREENSIZE * SCREENSIZE / 8)
#define NUMCIRCLES 50

unsigned dx[NUMCIRCLES];
unsigned dy[NUMCIRCLES];
unsigned dr[NUMCIRCLES];

unsigned *screen = (unsigned *) PIXELMEMORY_BASE;

void clearscreen() {
  unsigned i;
  for (i=0; i<SCREENBYTES; i++)
    screen[i] = 0;
}

unsigned checkscreen() {
  unsigned i, v = 0;
  for (i=0; i<SCREENBYTES; i++)
    v += screen[i];
  return v;
}

void driverdata() {
  unsigned i;
  for (i=0; i<NUMCIRCLES; i++) {
    dr[i] = rand() % (SCREENSIZE/2);
    dx[i] = dr[i] + rand() % (SCREENSIZE - 2*dr[i]);
    dy[i] = dr[i] + rand() % (SCREENSIZE - 2*dr[i]);
  }
}

void setpixel(unsigned x, unsigned y) {
  unsigned bytenum = (y * SCREENSIZE + x)/8;
  unsigned bitnum  = x % 8;

  if (x > (SCREENSIZE-1))
    return;
  if (y > (SCREENSIZE-1))
    return;
  
  screen[bytenum] |= (1 << bitnum);
}

unsigned getpixel(unsigned x, unsigned y) {
  unsigned bytenum = (y * SCREENSIZE + x)/8;
  unsigned bitnum  = x % 8;

  if (x > (SCREENSIZE-1))
    return 0;
  if (y > (SCREENSIZE-1))
    return 0;
  
  if (screen[bytenum] & (1 << bitnum))
    return 1;
  else
    return 0;
}

void printscreen() {
  unsigned x, y;
  for (x=0; x<SCREENSIZE; x++) {
    for (y=0; y<SCREENSIZE; y++) {
      if (getpixel(x,y))
	printf("*");
      else
	printf(".");
    }
    printf("\n");
  }
}

void plotcircle(unsigned cx,
		unsigned cy,
		unsigned r) {
  int x, y;
  int xp;

  x   = r;
  y   = 0;
  xp  = 1 - (int) r;
  while (x >= y) {
    setpixel(cx + x, cy + y);
    setpixel(cx + x, cy - y);
    setpixel(cx - x, cy + y);
    setpixel(cx - x, cy - y);
    setpixel(cx + y, cy + x);
    setpixel(cx + y, cy - x);
    setpixel(cx - y, cy + x);
    setpixel(cx - y, cy - x);
    y   = y + 1;
    if (xp < 0)
      xp += (2*y + 1);
    else {
      x = x - 1;
      xp += 2*(y-x) + 1;
    }
  }
}

void showgreen(unsigned v) {
	unsigned n = IORD(PIO_2_BASE,0);	
	unsigned n2 = (0x3FFFF & n) | ((v & 0x1FF) << 18);
	IOWR(PIO_2_BASE, 0, n2);	
}

void showred(unsigned v) {
	unsigned n = IORD(PIO_2_BASE, 0);	
	unsigned n2 = (0x7FC0000 & n) | (v & 0x3FFFF);
	IOWR(PIO_2_BASE, 0, n2);	
}

void clearhex() {
    IOWR(PIO_0_BASE, 0, 0xFFFFFFFF);	
	IOWR(PIO_1_BASE, 0, 0xFFFFFFFF);	
}

// REFERENCE CASE
void plotallcircles_ref() {
  unsigned i;
  for (i=0; i<NUMCIRCLES; i++)
    plotcircle(dx[i],dy[i],dr[i]);
}

#define PIX_BUSY (*(volatile unsigned *)0x300000)
#define PIX_WSTART (*(volatile unsigned *)0x300010)
#define NOP asm("nop\nnop\nnop\nnop\nnop\nnop\nnop\nnop\nnop\nnop\nnop\nnop\nnop\nnop\nnop\nnop\nnop\nnop\nnop\nnop\nnop\nnop\nnop\n")

// ACCELERATED CASE
#define plotallcircles_hw() \
    /* write start */  \
    PIX_WSTART = (unsigned)dx; \
    /* stage a delay to line up with first while loop iteration*/  \
    NOP;NOP;NOP;NOP;NOP;NOP;NOP;NOP;NOP;NOP;NOP;NOP;NOP;NOP;NOP;NOP;NOP;NOP;NOP;NOP;NOP;NOP; \
    NOP;NOP;NOP;NOP;NOP;NOP;NOP;NOP;NOP;NOP;NOP;NOP;NOP;NOP;NOP;NOP; \
    asm("nop"); \
    asm("nop"); \
    /* Wait for finish */ \
    while(PIX_BUSY);


int main() {
  unsigned n1;

  alt_timestamp_start();

  // generate test code
  driverdata();

  // reference case
  clearscreen();

  n1 = alt_timestamp();
  plotallcircles_ref();
  n1 = alt_timestamp()-n1;

  printf("Reference Plotting time is  %d\n", (unsigned) n1);
  printf("Reference Checksum is       %d\n", checkscreen());

  // accelerated case
  clearscreen();

  n1 = alt_timestamp();
  plotallcircles_hw();
  n1 = alt_timestamp()-n1;

  printf("Accelerated Plotting time is  %d\n", (unsigned) n1);
  printf("Accelerated Checksum is       %d\n", checkscreen());

  return 0;
}
