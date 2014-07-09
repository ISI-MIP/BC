#include <stdlib.h>
#include <stdio.h>
#include <netcdf.h>
#include <string.h>
#include <math.h>
#include "swap.h"

#define BASEYEAR 1860

#define ERRCODE 2
#define ERR(e) {printf("Error: %s\n", nc_strerror(e)); exit(ERRCODE);}

int main(int argc, char *argv[]) {

size_t start[3],count[3],time_offset,source_offset;
int ncid_read,ncid_write,retval;
float *data, *time;
int firstyear,year,ndays,y,i,nvals,len;

if(argc!=5)
{
  fprintf(stderr, "Use:\n%s source_netcdffile target_netcdffile firstyear_in_source year_to_write \n", argv[0]);
  exit(-1);
}

firstyear=atoi(argv[3]);
year=atoi(argv[4]);

/*open netCDF file for writing */
if ((retval = nc_open(argv[2], NC_WRITE, &ncid_write)))
  ERR(retval);

/*open source netCDF file*/
if ((retval = nc_open(argv[1], NC_NOWRITE, &ncid_read)))
  ERR(retval);


fprintf(stdout,"Write year %d from %s to %s.\n",year,argv[1],argv[2]);

/* calculate offsets */
time_offset=0.5;
for(y=BASEYEAR;y<year;y++)
{
  if(y%4==0 && (y%100!=0 || y%400==0))
    time_offset+=366;
  else
    time_offset+=365;
}

source_offset=0;
for(y=firstyear;y<year;y++)
{
  if(y%4==0 && (y%100!=0 || y%400==0))
    source_offset+=366;
  else
    source_offset+=365;
}

ndays= y%4==0 && (y%100!=0 || y%400==0) ? 366 : 365;

start[0]=source_offset;
start[1]=0;
start[2]=0;

count[0]=ndays;
count[1]=360;
count[2]=720;

len=720*360*ndays;

data=(float *)malloc(len*sizeof(float));
if(data==NULL)
{
    fprintf(stderr,"Error: Could not allocate memory!\n");
    exit(99);
}
time=(float *)malloc(ndays*sizeof(float));
if(time==NULL)
{
    fprintf(stderr,"Error: Could not allocate memory!\n");
    exit(99);
}


if((retval = nc_get_vars_float(ncid_read, 1, start, count, NULL, data)))
  ERR(retval);

if ((retval = nc_close(ncid_read)))
  ERR(retval);

nvals=0;
for(i=0;i<len;i++)
{
  if(data[i]<=-9998)
    data[i]=1e20;
  else
    nvals++;
}

start[0]=0;
if((retval = nc_put_vars_float(ncid_write, 3, start, count, NULL, data)))
  ERR(retval);

for(i=0;i<ndays;i++)
  time[i]=time_offset+i;

if((retval = nc_put_vars_float(ncid_write, 2, &start[0], &count[0], NULL, time)))
  ERR(retval);

if ((retval = nc_close(ncid_write)))
  ERR(retval);

if(nvals%ndays!=0)
  fprintf(stdout,"WARNING! Number of cells not equal in all time steps!\n");
else
  fprintf(stdout,"Data for %d days and %d cells successfully written to NetCDF file %s!\n",ndays,nvals/ndays,argv[2]);

free(data);
free(time);

return 0;
}
