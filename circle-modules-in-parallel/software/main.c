#include "system.h"
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <io.h>
#include "sys/alt_timestamp.h"

#define SCREENSIZE 512
#define SCREENBYTES (SCREENSIZE * SCREENSIZE / 8)
#define NUMCIRCLES 50

#define DEBUG 0
#define TEST 0
#define LIMIT 202
#define ITERATIONS 3
#define ITERATIONS_START 2

unsigned dx[NUMCIRCLES];
unsigned dy[NUMCIRCLES];
unsigned dr[NUMCIRCLES];

unsigned char *screen = (unsigned char *) PIXELMEMORY_BASE;

uint32_t *screen_mm = (uint32_t *) MMPIX_0_BASE;

void clearscreen() {
    unsigned i;
    for (i=0; i<SCREENBYTES; i++)
    {
        screen[i] = 0;
    }
}
void clearscreen_hw() {
    unsigned i;
    for (i=0; i<SCREENBYTES*8; i++)
    {
        screen_mm[i] = 0;
    }
}
unsigned checkscreen() {
    unsigned i, v = 0;
    for (i=0; i<SCREENBYTES; i++)
        v += screen[i];
    return v;
}
unsigned checkscreen_hw() {
    unsigned i, v = 0;
    for (i=0; i<SCREENBYTES*8; i++)
        v += screen_mm[i];
    return v;
}

int getpixel_bs(int x,int y)
{
    x = x - dx[0];
    y = y - dy[0];
    return (x*x + y*y == dr[0] * dr[0] ? 1 : 0);
}

unsigned checkscreen_bs() {
    unsigned i, v = 0;
    for (i=0; i<SCREENBYTES*8; i++)
    {
        unsigned y = (i >> 9) & 0x1ff;
        unsigned x = (i) & 0x1ff;
        int p = getpixel_bs(x,y);
        p = p << (i&0x7);
        v += p;
    }
    return v;
}

void driverdata(int k) {
#if DEBUG
    //printf("rand(k==%d)\n",k);
#endif
    unsigned i;
    int j;
    for (j=0; j<k; j++)
        rand();
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

#if DEBUG
    printf("setting bit at (%u, %u) (%u)\n",x,y,(1 << bitnum));
#endif

    screen[bytenum] |= (1 << bitnum);
}
void setpixel_hw(unsigned x, unsigned y) {
    unsigned bytenum = (y * SCREENSIZE + x)/8;

    if (x > (SCREENSIZE-1))
        return;
    if (y > (SCREENSIZE-1))
        return;

    screen_mm[bytenum] = (1);
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


unsigned getpixel_hw(unsigned x, unsigned y) {
    unsigned bytenum = (y * SCREENSIZE + x);

    if (x > (SCREENSIZE-1))
        return 0;
    if (y > (SCREENSIZE-1))
        return 0;
    return screen_mm[bytenum];
}

void printscreen_bs() {
    unsigned x, y;
    for (x=0; x<SCREENSIZE/2; x++) {
        for (y=0; y<SCREENSIZE; y++) {
            if (getpixel_bs(x,y))
                printf("*");
            else
                printf(".");
        }
        printf("\n");
    }
}

void printscreen() {
    unsigned x, y;
    for (x=0; x<SCREENSIZE/2; x++) {
        for (y=0; y<SCREENSIZE; y++) {
            if (getpixel(x,y))
                printf("*");
            else
                printf(".");
        }
        printf("\n");
    }
}


#define ANSI_COLOR_RED     "\x1b[31m"
#define ANSI_COLOR_GREEN   "\x1b[32m"
#define ANSI_COLOR_YELLOW  "\x1b[33m"
#define ANSI_COLOR_BLUE    "\x1b[34m"
#define ANSI_COLOR_MAGENTA "\x1b[35m"
#define ANSI_COLOR_CYAN    "\x1b[36m"
#define ANSI_COLOR_RESET   "\x1b[0m"

void printscreen_hw() {
    unsigned x, y;
    for (x=0; x<SCREENSIZE/2; x++) {
        for (y=0; y<SCREENSIZE; y++) {
            int p1 = getpixel(x,y);
            int p2 = getpixel_hw(x,y);
            if (p1 && p2 )
                printf(ANSI_COLOR_GREEN"*"ANSI_COLOR_RESET);
            else if (p1 || p2)
                printf(ANSI_COLOR_RED"*"ANSI_COLOR_RESET);
            else
                printf(".");

        }
        printf("\n");
    }
}

void printscreen_sm() {
    static long int wrongs=0;
    static long int total=0;
    char buf[625];
    memset(buf,0, sizeof buf);
    unsigned x, y;
    int wrong  = 0;
    for (x=0; x<25; x++) {
        for (y=0; y<25; y++) {
            int p1 = getpixel(x,y);
            int p2 = getpixel_hw(x,y);
            if (!!p1 ^ !!p2)
            {
                wrong = 1;
            }
            if (p1) buf[x*25+y]++;
            if (p2) buf[x*25+y]++;
        }
    }
    total = total + 1;
    if (wrong)
    {
        wrongs++;
        for (x=0; x<25; x++) {
            for (y=0; y<25; y++) {
                int p1 = buf[x*25+y];
                if (p1 == 2 )
                    printf(ANSI_COLOR_GREEN"*"ANSI_COLOR_RESET);
                else if (p1 == 1)
                    printf(ANSI_COLOR_RED"*"ANSI_COLOR_RESET);
                else 
                    printf(".");

            }
            printf("\n");
        }   
    }
    if (total % 100 == 0)printf("wrong/total == %d/%d \n",wrongs,total);
}

void plotcircle_test(unsigned cx,
        unsigned cy,
        unsigned r) {
    int x, y;
    int xp;

    x   = r;
    y   = 0;
    xp  = 1 - (int) r;
    int i = 0;
    while (x >= y) {
        // 1
        setpixel_hw(cx + x, cy + y);

        // 8
        setpixel_hw(cx + x, cy - y);
        // 
        setpixel_hw(cx - x, cy + y);
        // 5
        setpixel_hw(cx - x, cy - y);
        // 3
        setpixel_hw(cx + y, cy + x);
        // 7
        setpixel_hw(cx + y, cy - x);
        // 3
        setpixel_hw(cx - y, cy + x);
        // 6
        setpixel_hw(cx - y, cy - x);
        y   = y + 1;
        if (xp < 0)
            xp += (2*y + 1);
        else {
            x = x - 1;
            xp += 2*(y-x) + 1;
        }
        ++i;
        if (i>=LIMIT)
        {
            printf("limit reached\n");
            break;
        }
    }
    //printf("ran through %d iterations\n",i);
}

void plotcircle(unsigned cx,
        unsigned cy,
        unsigned r) {
    int x, y;
    int xp;

    x   = r;
    y   = 0;
    xp  = 1 - (int) r;
    int i = 0;
    while (x >= y) {
        // 1
        setpixel(cx + x, cy + y);

        // 8
        setpixel(cx + x, cy - y);
        // 
        setpixel(cx - x, cy + y);
        // 5
        setpixel(cx - x, cy - y);
        // 3
        setpixel(cx + y, cy + x);
        // 7
        setpixel(cx + y, cy - x);
        // 3
        setpixel(cx - y, cy + x);
        // 6
        setpixel(cx - y, cy - x);
        y   = y + 1;
        if (xp < 0)
            xp += (2*y + 1);
        else {
            x = x - 1;
            xp += 2*(y-x) + 1;
        }
        ++i;
        if (i>=LIMIT)
        {
            printf("limit reached\n");
            break;
        }
    }
    //printf("ran through %d iterations\n",i);
}

#define SET_RADIUS(c,x,y,r) (screen_mm[0] = (((c&0x3f)<<26)|((r&0xff)<<18)|(((y)&0x1ff)<<9)|((x)&0x1ff)))
#define SET_PIXELS(c,i,x,y) (screen_mm[i] = (((c&0x3f)<<26)|(y&0x1ff)<<9)|(x&0x1ff))

void plotcircle_hw(int circle, unsigned cx,
        unsigned cy,
        unsigned r) {
    SET_RADIUS(circle,cx,cy,r);
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

// ACCELERATED CASE
void plotallcircles_hw() {
    unsigned i;
    for (i=0; i<NUMCIRCLES; i++)
    {
        plotcircle_hw((i % 10) + 1,dx[i],dy[i],dr[i]);
    }
//    return;
//    for (i=0; i < 100; i++)
//        asm("nop");
}

void print_mm(unsigned x , unsigned y)
{

    printf("screen_mm (%u,%u) == %u\n",x,y,getpixel_hw(x,y));
}

void test(int k, int cx, int cy, int x, int y)
{
    SET_RADIUS(0,cx,cy,55);
    SET_PIXELS(0,0,x,y);
    

    getpixel_hw(163, 105);
    getpixel_hw(73, 105);
    getpixel_hw(118, 150);
    getpixel_hw(118, 60);
    getpixel_hw(118, 105);  // error
    //print_mm(118, 105);
    //return;
    //printf("cx: %d    cy: %d \n",cx,cy);
    //printf("    x: %d    y: %d \n",x,y);
    //print_mm(352, 236);
    //print_mm(356, 236);
    //print_mm(348, 236);
    //print_mm(352, 240);
    //print_mm(352, 232);
    printf("errors:?\n");
    for (x=0; x<512; x++)
        for (y=0; y<512; y++)
            if(getpixel_hw(x,y)!=0)
                print_mm(x,y);
}
unsigned checkscreen_both() {
    int x,y;void setpixel(unsigned x, unsigned y) {
    unsigned bytenum = (y * SCREENSIZE + x)/8;
    unsigned bitnum  = x % 8;

    if (x > (SCREENSIZE-1))
        return;
    if (y > (SCREENSIZE-1))
        return;

#if DEBUG
    printf("setting bit at (%u, %u) (%u)\n",x,y,(1 << bitnum));
#endif

    screen[bytenum] |= (1 << bitnum);
}


    int r1,r2;
    for(x=0; x < 20; x++)
        for(y=0; y <20; y++)
        {
            r1 = getpixel(x,y);
            r2 = getpixel_hw(x,y);
            if (!!r1 != !!r2)
            {
                printf("SF(%d,%d) == %d  but HW(%d,%d) == %d\n",x,y,r1,x,y,r2);
            }
        }
    return 0;
}

int main() {
    
#if TEST
    //screen_mm[0] = 1;
    //printf("screen_mm[0] = %d\n", screen_mm[0]);
    //return 0;
    printf("checking:\n");
        //clearscreen_hw();

    dx[0] = 10;
    dy[0] = 10;
    dr[0] = 8;
    /*
    plotallcircles_hw();
    int l;
    for(l=0; l < 10; l++)
        asm("nop");
    getpixel_hw(18,10);
    printf("1: %d\n",getpixel_hw(18,10));
    clearscreen_hw();
    //screen_mm[(10 * SCREENSIZE + 18)] = 0;
    getpixel_hw(18,10);
    printf("2: %d\n",getpixel_hw(18,10));

    printf("hw\n");
    int r1 = checkscreen_hw();
    printf("chksum = %d\n", r1);

    plotallcircles_ref();
    printf("sf\n");
    int r2 = checkscreen();
    if(r1 != r2)
    {
        printf(" FAIL!  ref: %d    hw: %d\n",r2,r1);
        //printscreen_bs();
    }
    else
    {

        printf(" Correct!  %d\n",r1);
        //break;
    }
    */
    //return 0;
    //screen_mm[0] = 0;
    plotallcircles_hw();
    // plotcircle_test(dx[0],dy[0],dr[0]);
    plotallcircles_ref();
    getpixel_hw(18,10);
    getpixel_hw(18,10);
    getpixel_hw(18,10);
    printf("done\n");

    while(1) printscreen_sm();

    // clearscreen();
    //test(1,118,105,45,1);
    return 0;
#endif
    int k = 1;
        alt_timestamp_start();
    int offset = 0;
    printf("\n--- running tests --- \n");
    for(k=0; k<ITERATIONS_START; k++)
        driverdata(k);
    for (k=ITERATIONS_START+offset; k<ITERATIONS+offset; k++)
    {
        unsigned n1;
        // generate test code
        driverdata(k);
        printf("r == %d\n",dr[0]);

        //printf("\n\n");


        // reference case
        clearscreen();
        n1 = alt_timestamp();
        plotallcircles_ref();
        n1 = alt_timestamp()-n1;
        float reft = (float) n1;
        
        int refchksum = checkscreen();
        //printf("Reference Plotting time is  %d\n", (unsigned) n1);
        //printf("Reference Checksum is       %d\n", checkscreen());
        clearscreen_hw();
        //screen_mm[0] = 0;

        // accelerated case
        //clearscreen_hw();
        n1 = alt_timestamp();
        plotallcircles_hw();
        n1 = alt_timestamp()-n1;
        float hwt = (float) n1;

        int hwchksum = checkscreen_hw();


        //printf("Accelerated Plotting time is  %d\n", (unsigned) n1);
        //printf("Accelerated Checksum is       %d\n", checkscreen_hw());

        if(refchksum != hwchksum)
        {
            printf("%d FAIL!  ref: %d    hw: %d\n",k,refchksum, hwchksum);
            //checkscreen_both();
            //printscreen_hw();
        }
        else
        {

            printf("k %d Correct!  %d\n",k,hwchksum);
            printf("    %dx speedup\n", (int)(reft/hwt));
            //break;
        }
        //printf("    circle cx: %d   cy: %d    r: %d\n",dx[0],dy[0],dr[0]);
    }
    printf("done\n");
    return 0;
}
