;;THIS GDL FILE CONTAINS SEVERAL DEFINITIONS REQUIRED FOR THE
;;CONSTRUCTION OF THE MONTHLY BIAS CORRECTION COEFFICIENTS.
;;
;; WORK BLOCK LEADER: S. HAGEMANN
;;
;
;
close,2
; produce a control file to track progress, name can be changed.

spawn,'mkdir -p logfiles/'
openw,2,'logfiles/logfile_for_USER_SPECIFIED_DATA_'+BC_runnumber+'.txt'
;
; specify the months to be bias corrected
month=['01','02','03','04','05','06','07','08','09','10','11','12']
;
; measurement cutoff for precipitation measurements (mm)
; This is now set to the case of the WATCH forcing data (WFD) where
; measurements less than 1.0mm are assumed to be noise.
precip_cutoff = 0.1
;______________________________________________________________
;______________________________________________________________
; INFORMATION FOR THE APPLICATION OF THE BC FACTORS
;
; define a switch to specify whether the months of the construction
; period have to be extracted
; from a large 10-year(+2months) file or if separate files already
; exist (0->no processing, 1->processing)
SWITCH_EXTRACT_MONTHS_2=1
;
; should the original model data be converted to an idl format first?
; (0 -> don't convert, 1 -> convert)
CONVERTMODEL2IDL_SWITCH_2=1
;
construction_period = CONSTRUCTION_PERIOD_START+'_'+CONSTRUCTION_PERIOD_STOP
derivation_period   = DERIVATION_PERIOD_START+'_'+DERIVATION_PERIOD_STOP
application_period  = APPLICATION_PERIOD_START+'_'+APPLICATION_PERIOD_STOP
;
IF (FORMAT_WFD NE 2) THEN CONVERTWFD2IDL_SWITCH=1 ELSE CONVERTWFD2IDL_SWITCH=0
;
; should original data be converted to ncdf for comparison?
CONVERT_ORG_DATA=1
;
;
; the multfactors for Tmin and Tmax are assumed to be the same as for
; T mean.
multf_wfd_Tmin   = multf_wfd_T
multf_wfd_Tmax   = multf_wfd_T
;
multf_model_Tmin = multf_model_T
multf_model_Tmax = multf_model_T
;
; pathmodel is the path to the model data
; model data should be provided in the same format as the WFD, hence
; in a format where only land points are stored in a 1D array of NUMLANDPOINTS
; data points.
;;pathmodel=pathdat+'modelData/'
pathmodel     =  pathdat+BC_runnumber+'/'+'BC_data/'
;
; pathWFD is the path to the WATCH forcing data.
;pathWFD       =  pathdat+BC_runnumber+'/'+'WFD_idl/'
pathWFD       =  pathdat+'/'+'WFD_IDL/'
;
; pathFinalData is the path to the final corrected output data
pathFinalData =  pathdat+BC_runnumber+'/'+'finalOutputData/'
;
; filename for the chunk in latlon format (this would likely be a huge
; file of more than 10GB for 40 yrs!)
filenameWFDchunkCompressed      =  filename_WFD_Ptot
filenameWFDchunkCompressed_T    =  filename_WFD_T
filenameWFDchunkCompressed_Tmin =  filename_WFD_Tmin
filenameWFDchunkCompressed_Tmax =  filename_WFD_Tmax
filenameWFDchunkCompressed_SW   =  filename_WFD_SW
filenameWFDchunkCompressed_LW   =  filename_WFD_LW
filenameWFDchunkCompressed_huss =  filename_WFD_huss
filenameWFDchunkCompressed_wind =  filename_WFD_wind
filenameWFDchunkCompressed_ps   =  filename_WFD_ps
;;
filenameWFDchunkLatlon          =  filename_WFD_Ptot
filenameWFDchunkLatlon_T        =  filename_WFD_T
filenameWFDchunkLatlon_Tmin     =  filename_WFD_Tmin
filenameWFDchunkLatlon_Tmax     =  filename_WFD_Tmax
filenameWFDchunkLatlon_SW       =  filename_WFD_SW
filenameWFDchunkLatlon_LW       =  filename_WFD_LW
filenameWFDchunkLatlon_huss     =  filename_WFD_huss
filenameWFDchunkLatlon_wind     =  filename_WFD_wind
filenameWFDchunkLatlon_ps       =  filename_WFD_ps
;
; path for the MODEL DATA chunks
pathMODELchunk=pathmodelorg
pathWFDchunk=pathWFDorg
;

run=runToCorrect
;
; construction filename for the chunk in compressed format (a file of ~3GB for 40 yrs)
filenameMODELCONSTRUCTIONchunkCompressed      = filename_model_const_Ptot
filenameMODELCONSTRUCTIONchunkCompressed_PRSN = filename_model_const_Psnow
filenameMODELCONSTRUCTIONchunkCompressed_T    = filename_model_const_T
filenameMODELCONSTRUCTIONchunkCompressed_Tmin = filename_model_const_Tmin
filenameMODELCONSTRUCTIONchunkCompressed_Tmax = filename_model_const_Tmax
filenameMODELCONSTRUCTIONchunkCompressed_SW   = filename_model_const_SW
filenameMODELCONSTRUCTIONchunkCompressed_LW   = filename_model_const_LW
filenameMODELCONSTRUCTIONchunkCompressed_huss = filename_model_const_huss
filenameMODELCONSTRUCTIONchunkCompressed_U    = filename_model_const_U
filenameMODELCONSTRUCTIONchunkCompressed_V    = filename_model_const_V
filenameMODELCONSTRUCTIONchunkCompressed_ps   = filename_model_const_ps
filenameMODELCONSTRUCTIONchunkCompressed_rhs  = filename_model_const_rhs
;
; construction filename for the chunk in latlon format (this would likely be a huge
; file of more than 10GB for 40 yrs!)
filenameMODELCONSTRUCTIONchunkLatlon          = filename_model_const_Ptot
filenameMODELCONSTRUCTIONchunkLatlon_PRSN     = filename_model_const_Psnow
filenameMODELCONSTRUCTIONchunkLatlon_T        = filename_model_const_T
filenameMODELCONSTRUCTIONchunkLatlon_Tmin     = filename_model_const_Tmin
filenameMODELCONSTRUCTIONchunkLatlon_Tmax     = filename_model_const_Tmax
filenameMODELCONSTRUCTIONchunkLatlon_SW       = filename_model_const_SW
filenameMODELCONSTRUCTIONchunkLatlon_LW       = filename_model_const_LW
filenameMODELCONSTRUCTIONchunkLatlon_huss     = filename_model_const_huss
filenameMODELCONSTRUCTIONchunkLatlon_U        = filename_model_const_U
filenameMODELCONSTRUCTIONchunkLatlon_V        = filename_model_const_V
filenameMODELCONSTRUCTIONchunkLatlon_ps       = filename_model_const_ps
filenameMODELCONSTRUCTIONchunkLatlon_rhs      = filename_model_const_rhs
;
; application filename for the chunk in compressed format (a file of ~3GB for 40 yrs)
filenameMODELAPPLICATIONchunkCompressed      = filename_model_appl_Ptot
filenameMODELAPPLICATIONchunkCompressed_PRSN = filename_model_appl_Psnow
filenameMODELAPPLICATIONchunkCompressed_T    = filename_model_appl_T
filenameMODELAPPLICATIONchunkCompressed_Tmin = filename_model_appl_Tmin
filenameMODELAPPLICATIONchunkCompressed_Tmax = filename_model_appl_Tmax
filenameMODELAPPLICATIONchunkCompressed_SW   = filename_model_appl_SW
filenameMODELAPPLICATIONchunkCompressed_LW   = filename_model_appl_LW
filenameMODELAPPLICATIONchunkCompressed_huss = filename_model_appl_huss
filenameMODELAPPLICATIONchunkCompressed_U    = filename_model_appl_U
filenameMODELAPPLICATIONchunkCompressed_V    = filename_model_appl_V
filenameMODELAPPLICATIONchunkCompressed_ps   = filename_model_appl_ps
filenameMODELAPPLICATIONchunkCompressed_rhs  = filename_model_appl_rhs
;
; application filename for the chunk in latlon format (this would likely be a huge
; file of more than 10GB for 40 yrs!)
filenameMODELAPPLICATIONchunkLatlon          = filename_model_appl_Ptot
filenameMODELAPPLICATIONchunkLatlon_PRSN     = filename_model_appl_Psnow
filenameMODELAPPLICATIONchunkLatlon_T        = filename_model_appl_T
filenameMODELAPPLICATIONchunkLatlon_Tmin     = filename_model_appl_Tmin
filenameMODELAPPLICATIONchunkLatlon_Tmax     = filename_model_appl_Tmax
filenameMODELAPPLICATIONchunkLatlon_SW       = filename_model_appl_SW
filenameMODELAPPLICATIONchunkLatlon_LW       = filename_model_appl_LW
filenameMODELAPPLICATIONchunkLatlon_huss     = filename_model_appl_huss
filenameMODELAPPLICATIONchunkLatlon_U        = filename_model_appl_U
filenameMODELAPPLICATIONchunkLatlon_V        = filename_model_appl_V
filenameMODELAPPLICATIONchunkLatlon_ps       = filename_model_appl_ps
filenameMODELAPPLICATIONchunkLatlon_rhs      = filename_model_appl_rhs
;
; the root of the file names used for the WFD.
WFDroot        =  'wfd_pr_GPCC_'
WFDroot_T      =  'wfd_T_'
WFDroot_Tmin   =  'wfd_Tmin_'
WFDroot_Tmax   =  'wfd_Tmax_'
WFDroot_SW     =  'wfd_sw_'
WFDroot_LW     =  'wfd_lw_'
WFDroot_huss   =  'wfd_huss_'
WFDroot_wind   =  'wfd_wind_'
WFDroot_ps     =  'wfd_ps_'
;
; the root of the file names used for the MODEL data.
MODELroot      =  'precip_'
MODELroot_PRSN =  'prsn_'
MODELroot_T    =  'T_'
MODELroot_Tmin =  'Tmin_'
MODELroot_Tmax =  'Tmax_'
MODELroot_SW   =  'sw_'
MODELroot_LW   =  'lw_'
MODELroot_huss =  'huss_'
MODELroot_U    =  'U_'
MODELroot_V    =  'V_'
MODELroot_ps   =  'ps_'
MODELroot_rhs  =  'rhs_'
;
; should the original model data be converted to an idl format first?
; (0 -> don't convert, 1 -> convert)
IF (FORMAT_CORRECTION NE 2) THEN CONVERTMODEL2IDL_SWITCH_1=1 ELSE CONVERTMODEL2IDL_SWITCH_1=0
IF (FORMAT_APPLICATION NE 2) THEN CONVERTMODEL2IDL_SWITCH_2=1 ELSE CONVERTMODEL2IDL_SWITCH_2=0
;
; the program assumes that an output directory exists at the location
; outputdir. This directory is used to store the bias correction factors.
outputdir=pathdat+BC_runnumber+'/'+'factors/'
spawn,'mkdir -p '+outputdir
spawn,'mkdir -p '+pathWFD
spawn,'mkdir -p '+pathmodel
spawn,'mkdir -p '+pathFinalData
;
;open the WFD land point file
id=NCDF_OPEN(pathdat+'WFD/WFD-land-lat-long-z.nc')
NCDF_VARGET,id,'land',land
NCDF_VARGET,id,'Latitude',lat
NCDF_VARGET,id,'Longitude',lon
NCDF_CLOSE,id
NUMLANDPOINTS=n_elements(land)
;
; get the original WFD information on the lat-lon coordinates
;;id1=NCDF_OPEN(pathWFDorg+'Snowf_daily_WFD_GPCC_199602.nc')
id1=NCDF_OPEN(pathdat+'WFD/WFDcoords.nc')
NCDF_VARGET,id1,'nav_lon',navlon
NCDF_VARGET,id1,'nav_lat',navlat
nxx=n_elements(navlat(*,1))
nyy=n_elements(navlat(1,*))
NCDF_CLOSE,id1
;
;

; !! log output only for P and T correction so far
;______________________________________________________________________________
printf,2,''
printf,2,'----------------------------------------------------------------'
printf,2,''
printf,2,'This file contains information on the user specified data for the bias statistical correction.'
printf,2,''
printf,2,'(0) GENERAL INFORMATION:'
printf,2,''
printf,2,'tasks to complete:'
IF (T_CORRECT EQ 1) THEN printf,2,'The user is performing a temperature bias correction.'
IF (P_CORRECT EQ 1) THEN printf,2,'The user is performing a precipitation bias correction.'
IF (T_prepare EQ 1) THEN printf,2,'- T input data should be prepared.'
IF (P_prepare EQ 1) THEN printf,2,'- P input data should be prepared.'
IF (T_computeCor EQ 1) THEN printf,2,'- T correction factors should be computed.'
IF (P_computeCor EQ 1) THEN printf,2,'- P correction factors should be computed.'
IF (T_apply EQ 1) THEN printf,2,'- T cor. factors should be applied.'
IF (P_apply EQ 1) THEN printf,2,'- P cor. factors should be applied.'
IF (writeoutput EQ 1) THEN printf,2,'- Output should be written as NETCDF.'
;
printf,2,''
printf,2,'general file and data path: '+pathdat
printf,2,''
printf,2,'(*) WATCH FORCING DATA FILES:'
IF (FORMAT_WFD EQ 0) THEN BEGIN
   printf,2,'TOTAL PRECIP:     '+pathWFDchunk+filenameWFDchunkCompressed
   printf,2,'MEAN TEMPERATURE: '+pathWFDchunk+filenameWFDchunkCompressed_T
   printf,2,'MIN TEMPERATURE:  '+pathWFDchunk+filenameWFDchunkCompressed_Tmin
   printf,2,'MAX TEMPERATURE:  '+pathWFDchunk+filenameWFDchunkCompressed_Tmax
ENDIF
IF (FORMAT_WFD EQ 1) THEN BEGIN
   printf,2,'TOTAL PRECIP:     '+pathWFDchunk+filenameWFDchunkLatlon
   printf,2,'MEAN TEMPERATURE: '+pathWFDchunk+filenameWFDchunkLatlon_T
   printf,2,'MIN TEMPERATURE:  '+pathWFDchunk+filenameWFDchunkLatlon_Tmin
   printf,2,'MAX TEMPERATURE:  '+pathWFDchunk+filenameWFDchunkLatlon_Tmax
ENDIF
IF (FORMAT_WFD EQ 2) THEN printf,2,'PATH: '+pathWFD
printf,2,'FORMAT WFD: ',FORMAT_WFD,' (0=compressed, 1=latlon, 2=idl saved)'
printf,2,''
IF (FORMAT_CORRECTION EQ 0) THEN BEGIN
   printf,2,'(*) MODEL DATA FILES (CONSTRUCTION):'
   printf,2,'TOTAL PRECIP:     '+pathmodelorg+filenameMODELCONSTRUCTIONchunkCompressed
;    printf,2,'PRECIP SNOW:      '+pathmodelorg+filenameMODELCONSTRUCTIONchunkCompressed_PRSN
   printf,2,'MEAN TEMPERATURE: '+pathmodelorg+filenameMODELCONSTRUCTIONchunkCompressed_T
   printf,2,'MIN TEMPERATURE:  '+pathmodelorg+filenameMODELCONSTRUCTIONchunkCompressed_Tmin
   printf,2,'MAX TEMPERATURE:  '+pathmodelorg+filenameMODELCONSTRUCTIONchunkCompressed_Tmax
ENDIF
IF (FORMAT_CORRECTION EQ 1) THEN BEGIN
   printf,2,'(*) MODEL DATA FILES (CONSTRUCTION):'
   printf,2,'TOTAL PRECIP:     '+pathmodelorg+filenameMODELCONSTRUCTIONchunkLatlon
;    printf,2,'PRECIP SNOW:      '+pathmodelorg+filenameMODELCONSTRUCTIONchunkLatlon_PRSN
   printf,2,'MEAN TEMPERUTURE: '+pathmodelorg+filenameMODELCONSTRUCTIONchunkLatlon_T
   printf,2,'MIN TEMPERATURE:  '+pathmodelorg+filenameMODELCONSTRUCTIONchunkLatlon_Tmin
   printf,2,'MAX TEMPERATURE:  '+pathmodelorg+filenameMODELCONSTRUCTIONchunkLatlon_Tmax
ENDIF
IF (FORMAT_CORRECTION EQ 2) THEN printf,2,'PATH: '+pathmodel
;
printf,2,''
IF (FORMAT_APPLICATION EQ 0) THEN BEGIN
   printf,2,'(*) MODEL DATA FILES (APPLICATION):'
   printf,2,'TOTAL PRECIP:     '+pathmodelorg+filenameMODELAPPLICATIONchunkCompressed
   printf,2,'PRECIP SNOW:      '+pathmodelorg+filenameMODELAPPLICATIONchunkCompressed_PRSN
   printf,2,'MEAN TEMPERATURe: '+pathmodelorg+filenameMODELAPPLICATIONchunkCompressed_T
   printf,2,'MIN TEMPERATURE:  '+pathmodelorg+filenameMODELAPPLICATIONchunkCompressed_Tmin
   printf,2,'MAX TEMPERATURE:  '+pathmodelorg+filenameMODELAPPLICATIONchunkCompressed_Tmax
ENDIF
IF (FORMAT_APPLICATION EQ 1) THEN BEGIN
   printf,2,'(*) MODEL DATA FILES (APPLICATION):'
   printf,2,'TOTAL PRECIP:     '+pathmodelorg+filenameMODELAPPLICATIONchunkLatlon
   printf,2,'PRECIP SNOW:      '+pathmodelorg+filenameMODELAPPLICATIONchunkLatlon_PRSN
   printf,2,'MEAN TEMPERATURE: '+pathmodelorg+filenameMODELAPPLICATIONchunkLatlon_T
   printf,2,'MIN TEMPERATURE:  '+pathmodelorg+filenameMODELAPPLICATIONchunkLatlon_Tmin
   printf,2,'MAX TEMPERATURE:  '+pathmodelorg+filenameMODELAPPLICATIONchunkLatlon_Tmax
ENDIF
IF (FORMAT_APPLICATION EQ 2) THEN printf,2,'PATH: '+pathmodel
printf,2,''
printf,2,'FORMAT MODEL CORRECTION:  ',FORMAT_CORRECTION,' (0=compressed, 1=latlon, 2=idl saved)'
printf,2,'FORMAT MODEL APPLICATION: ',FORMAT_APPLICATION,' (0=compressed, 1=latlon, 2=idl saved)'
;
printf,2,''
printf,2,'(*) Time periods'
printf,2,'CONSTRUCTION PERIOD: '+CONSTRUCTION_PERIOD_START+' - ' + CONSTRUCTION_PERIOD_STOP
printf,2,'DERIVATION PERIOD:   '+DERIVATION_PERIOD_START+  ' - ' + DERIVATION_PERIOD_STOP
printf,2,'APPLICATION PERIOD:  '+APPLICATION_PERIOD_START+ ' - ' + APPLICATION_PERIOD_STOP
printf,2,''
printf,2,'(*) Output'
printf,2,'Output directory for correction coefficients: '+outputdir
IF (OUTPUT_DATAFORMAT_2D EQ 1) THEN printf,2,'Output to lat lon NETCDF files in directory: '+ pathmodel
IF (OUTPUT_DATAFORMAT_1D EQ 1) THEN printf,2,'Output to compressed NETCDF files in directory: '+ pathmodel
IF (OUTPUT_DATAFORMAT_1D EQ 0 AND OUTPUT_DATAFORMAT_2D EQ 0) THEN printf,2,'No netcdf output to be written. Only idl saved files will be available.'
IF (OUTPUT_DATAFORMAT_1D EQ 0 OR OUTPUT_DATAFORMAT_2D EQ 0) THEN printf,2,'Final output for bias corrected time series written to: '+pathFinalData+' .'
printf,2,''
printf,2,'-----------------------------------------------------------------'
printf,2,''
close,2
;______________________________________________________________
;
END
