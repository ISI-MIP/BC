#ISI-MIP Bias Correction Code

## General notes
This is the code base used in *ISI-MIP Fast Track* and *ISI-MIP2* to produce bias corrected GCM input data for participation impact modelling groups. The code base hosted here, esp. the IDL/GDL scripts are a modification of the original code based on algorithm used in WATCH project (by Piani and Hearter).

Reference for orignal code:
Piani, C., Weedon, G. P., Best, M., Gomes, S. M., Viterbo, P., Hagemann, S., and Haerter, J. O.: Statistical bias correction of global simulated daily precipitation and temperature for the application of hydrological models, J. Hydrol., 395, 199–215, doi:10.1016/j.jhydrol.2010.10.024, 2010.

Reference for extended code developed at PIK:
Hempel, S., Frieler, K., Warszawski, L., Schewe, J., and Piontek, F.: A trend-preserving bias correction – the ISI-MIP approach, Earth Syst. Dynam., 4, 219-236, doi:10.5194/esd-4-219-2013, 2013.

## Short manual
Main script is *BC_Skript.sh* and intended to bias correct the temperature (mean, min and max), precipitation (total and snowfall), wind (eastward, northward and total), radiation (longwave down and shortwave down) and surface pressure of selected CMIP5 GCMs to WATCH Forcing Data level. If you use the script you have to correct the variables in a row, parallel is not possible as the some of the definition files will be overwritten or deleted after a calculation has finished. Relative humidity (rhs) was added but only supports a rewrite along with calender interpolation (no bias correction here).

**Important:** This code environment heavily relies on specific hard and software prerequisites. Most of the GDL scripts require a large amount of available RAM. At PIK the scripts ran successfully on 26GB RAM Linux compute nodes with IBM LoadLeveler job scheduling. Executing the scipts on nodes equiped with less RAM or shared memory usage with other users/jobs regularly failed. Moreover the following software utilities are needed (links and hints at page bottom):

- GDL/IDL (GNU Data Language)
- CDO (Climate Data Operators)
- LoadLeveler calls may be replaced with usual shell scripts calls

To run the script use, e.g., `./BC_Skript.sh 'T' 'rcp2p6' 'yes' 'HadGEM2-ES'`

Possible input arguments
- $1 ... vars: P, T, lw, sw, ps, wind, rhs
- $2 ... rcps: rcp2p6 rcp4p5 rcp6p0 rcp8p5
- $3 ... full: yes, no
- $4 ... GCM: HadGEM2-ES, IPSL-CM5A-LR, GFDL-ESM2M, MIROC-ESM-CHEM, NorESM1-M, CNRM-CM5

Basic configuration is saved in **exports**.

Actual routines for factor/offset generation and application are saved under gdl_routines/vX/, where X referes to different versions, e.g. v2 was used in Hempel et al. Generic routines valid for both versions reside under gdl_routines/generic.

Current setup expects GCM and WATCH input on 0.5° gridded netCDF data in the folders specified in *exports*

###GDL
- http://sourceforge.net/projects/gnudatalanguage/
- gdl is prepackaged in many Linux distributions
- otherwise compile from source with cmake command:
```
cmake .. \
    -DCMAKE_INSTALL_PREFIX=/home/buechner/tools \
    -DHDFDIR=/home/buechner/tools/hdf4 \
    -DUDUNITS=ON \
    -DUDUNITSDIR=/home/buechner/tools \
    -DGSLDIR=/iplex/01/2011/isimip/lib/ \
    -DWXWIDGETS=OFF \
    -DMAGICK=OFF \
    -DGRAPHICSMAGICK=OFF \
    -DEIGEN3=OFF \
    -DPSLIB=OFF \
    -DPLPLOTDIR=/home/buechner/tools \
    -DOLDPLPLOT=OFF
```
###CDO
- https://code.zmaw.de/projects/cdo
- cdo packages from Linux distributions often don't support compressed netCDF4 format, which is used by the repack script during the last step of the procedure
- to compile cdo from source make sure HDF5, ZLIB and netCDF4 libraries are present on your system
