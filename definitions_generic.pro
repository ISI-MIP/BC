;; THIS GDL FILE CONTAINS SEVERAL DEFINITIONS REQUIRED FOR THE
;; CONSTRUCTION OF THE MONTHLY BIAS CORRECTION COEFFICIENTS AND THEIR
;; APPLICATION.
;;
;; copy this to filename definitions.pro
;; and run the shell scripts
;;
;; trend-preserving statistical bias correction method
;; PROJECT: ISI-MIP
;;
;; algorithm is based on
;; AUTHORS:  C. PIANI AND J. O. HAERTER
;; DATE:     NOVEMBER 17, 2009
;; PROJECT:  EU WATCH PROJECT
;;
;; ___________________________________________________________
;
; Enter some user specified run number so you can distinguish your
; runs.

;
;; ___________________________________________________________
;; select which calendar is used in the model: 0 ... standard calendar; 1 ... 365-days calendar; 2 ... 360-days calendar
CALENDAR = 3
IF (modelname eq 'HadGEM2-ES') THEN CALENDAR = 2
IF (modelname eq 'IPSL-CM5A-LR') THEN CALENDAR = 1
IF (modelname eq 'MIROC-ESM-CHEM') THEN CALENDAR = 0
IF (modelname eq 'GFDL-ESM2M') THEN CALENDAR = 1
IF (modelname eq 'NorESM1-M') THEN CALENDAR = 1
IF (modelname eq 'CanESM2') THEN CALENDAR = 1
IF (modelname eq 'CCSM4') THEN CALENDAR = 1
IF (modelname eq 'CNRM-CM5') THEN CALENDAR = 1

IF (CALENDAR eq 3) then begin
   print,'calendar for the GCM not selected'
   stop
ENDIF

;______________________________________________________________
; INFORMATION FOR THE PERIODS OF CONSTRUCTION, DERIVATION, AND
; APPLICATION OF THE BIAS CORRECTION.
;
; Please enter year in the format 'YYYY'. The STOP date is 12-31 of
; the STOP year. Example: START=1960 and STOP=1969 means 01-01-1960
; until 12-31-1969.
;
; Specify the period over which BC-parameters are to be determined.
; The construction period is the period where the BC factors are
; derived.
CONSTRUCTION_PERIOD_START  =  '1960'
CONSTRUCTION_PERIOD_STOP   =  '1999'
;
; Specify the period where correction factors were derived.
; This will take the exisiting BC factors from the memory for the
; given period and apply them to the application period.
DERIVATION_PERIOD_START    =  CONSTRUCTION_PERIOD_START
DERIVATION_PERIOD_STOP     =  CONSTRUCTION_PERIOD_STOP
;
;
;_______________________________________________________________
;
; COMMON INFORMATION FOR CONSTRUCTION OF BC AND ITS APPLICATION
;
; Specify which corrections are planned to be performed.
;
; Which type of correction is the user interested in? (1=Yes, 0=No)
T_correct          =  0         ; temperature
P_correct          =  0         ; precipitation
SW_correct          =  0        ; short wave radiation
LW_correct          =  0        ; long wave radiation
huss_correct        =  0        ; specific humidity
wind_correct        =  0        ; wind
ps_correct          =  0        ; surface pressure
rhs_correct         =  0        ; relative humidity
;
; Do you want to correct dependend variables tasmin, tasmax and prsn? (1=Yes, 0=No)
T_dep              =  0
P_dep              =  0
;
; Do the data need to be converted to IDL format. (1=Yes, 0=No)
T_prepare          =  0         ; prepare files for temperature correction
P_prepare          =  0         ; prepare files for precipitation correction
SW_prepare         =  0         ; prepare files for short wave radiation correction
LW_prepare         =  0         ; prepare files for long wave radiation correction
huss_prepare       =  0         ; prepare files for specific humidity correction
wind_prepare       =  0         ; prepare files for wind
ps_prepare         =  0         ; prepare files for surface pressure correction
rhs_prepare        =  0         ; prepare files for relative humidity correctionrelative humidity
;
; Does the user want bias correction coefficients to be computed?  (1=Yes, 0=No)
T_computeCor       =  0         ; temperature
P_computeCor       =  0         ; precipitation
SW_computeCor      =  0         ; short wave radiation
LW_computeCor      =  0         ; long wave radiation
huss_computeCor    =  0         ; specific humidity
wind_computeCor    =  0         ; meridional
ps_computeCor      =  0         ; surface pressure
rhs_computeCor     =  0         ; relative humidity
;
; Should the coefficients be applied?  (1=Yes, 0=No)
T_apply            =  0         ; apply temperature correction
P_apply            =  0         ; apply precipitation correction
SW_apply           =  0         ; apply short wave radiation correction
LW_apply           =  0         ; apply long wave radiation correction
huss_apply         =  0         ; apply specific humidity correction
wind_apply         =  0         ; apply wind correction
ps_apply           =  0         ; apply surface pressure correction
rhs_apply          =  0         ; apply relative humidity correction
;

; Which type of correction is the user interested in? (1=Yes, 0=No)
IF (varidx EQ 'T') THEN T_correct          =  1 ; temperature
IF (varidx EQ 'P') THEN P_correct          =  1 ; precipitation
IF (varidx EQ 'SW') THEN SW_correct        =  1 ; short wave radiation
IF (varidx EQ 'LW') THEN LW_correct        =  1 ; long wave radiation
IF (varidx EQ 'huss') THEN huss_correct    =  1 ; specific humidity
IF (varidx EQ 'wind') THEN wind_correct    =  1 ; wind
IF (varidx EQ 'ps') THEN ps_correct        =  1 ; surface pressure
IF (varidx EQ 'rhs') THEN rhs_correct      =  1 ; relative humidity
;
; Do you want to correct dependend variables tasmin, tasmax and prsn? (1=Yes, 0=No)
IF (varidx EQ 'T') THEN T_dep              =  1
IF (varidx EQ 'P') THEN P_dep              =  1
;
; Do the data need to be converted to IDL format. (1=Yes, 0=No)
IF (varidx EQ 'T') THEN T_prepare          =  1 ; prepare files for temperature correction
IF (varidx EQ 'P') THEN P_prepare          =  1 ; prepare files for precipitation correction
IF (varidx EQ 'SW') THEN SW_prepare        =  1 ; prepare files for short wave radiation correction
IF (varidx EQ 'LW') THEN LW_prepare        =  1 ; prepare files for long wave radiation correction
IF (varidx EQ 'huss') THEN huss_prepare    =  1 ; prepare files for specific humidity correction
IF (varidx EQ 'wind') THEN wind_prepare    =  1 ; prepare files for wind
IF (varidx EQ 'ps') THEN ps_prepare        =  1 ; prepare files for surface pressure correction
IF (varidx EQ 'rhs') THEN rhs_prepare      =  1 ; prepare files for relative humidity correction
;
if ( only_apply EQ 0 ) then begin
; Does the user want bias correction coefficients to be computed?  (1=Yes, 0=No)
   IF (varidx EQ 'T') THEN T_computeCor       =  1 ; temperature
   IF (varidx EQ 'P') THEN P_computeCor       =  1 ; precipitation
   IF (varidx EQ 'SW') THEN SW_computeCor     =  1 ; short wave radiation
   IF (varidx EQ 'LW') THEN LW_computeCor     =  1 ; long wave radiation
   IF (varidx EQ 'huss') THEN huss_computeCor =  1 ; specific humidity
   IF (varidx EQ 'wind') THEN wind_computeCor =  1 ; meridional
   IF (varidx EQ 'ps') THEN ps_computeCor     =  1 ; surface pressure
   IF (varidx EQ 'rhs') THEN rhs_computeCor   =  0 ; relative humidity
;
endif
; Should the coefficients be applied?  (1=Yes, 0=No)
IF (varidx EQ 'T') THEN T_apply            =  1 ; apply temperature correction
IF (varidx EQ 'P') THEN P_apply            =  1 ; apply precipitation correction
IF (varidx EQ 'SW') THEN SW_apply          =  1 ; apply short wave radiation correction
IF (varidx EQ 'LW') THEN LW_apply          =  1 ; apply long wave radiation correction
IF (varidx EQ 'huss') THEN huss_apply      =  1 ; apply specific humidity correction
IF (varidx EQ 'wind') THEN wind_apply      =  1 ; apply wind correction
IF (varidx EQ 'ps') THEN ps_apply          =  1 ; apply surface pressure correction
IF (varidx EQ 'rhs') THEN rhs_apply        =  1 ; apply relative humidity correction
;

; Should output data be converted to a NETCDF format?  (1=Yes, 0=No)
writeoutput        =  1         ; write output files
;
; Define a switch to specify the format of the WFD, the model data for
; the correction period and model data for the application period
; (0->COMPRESSED WFD format, 1->LATLON NETCDF, 2->IDL .dat files by
; month for the correct correction period)
FORMAT_WFD         =  1
FORMAT_CORRECTION  =  1
FORMAT_APPLICATION =  1
;
; If the format is 0 or 1 a name is required for the WFD variable in the
; netcdf file (the variable name as it appears when using 'cdo infov <filename>')
vname_wfd          =  'pr'   ;  'Snowf'   ; total daily precip
vname_wfd_T        =  'tas'    ;  'Tair'    ; daily mean temperature
vname_wfd_Tmin     =  'tasmin'    ;  'Tmin'    ; daily min temperature
vname_wfd_Tmax     =  'tasmax'    ;  'Tmax'    ; daily max temperature
vname_wfd_SW       =  'rsds' ;  short wave radiation
vname_wfd_LW       =  'rlds' ;  long wave radiation
vname_wfd_huss     =  'huss'  ;  specific humidity
vname_wfd_wind     =  'wind'   ;  wind
vname_wfd_ps       =  'ps'  ;  surface pressure
;
; If the format is 0 or 1 a name is required for the model variable in the
; netcdf file of model data (the variable name as it appears when using 'cdo infov <filename>')
vname_model        =  'pr'      ;  'prc'     ; total daily precip
;vname_model_pr     =  'pr'      ;  'prc'     ; total daily precip
vname_model_prsn   =  'prsn'    ;  'prsn'    ; total daily snowfall
vname_model_T      =  'tas'     ;  daily mean temperature
vname_model_Tmin   =  'tasmin'  ;  'tasmin'     ;  'tasmin'  ; daily min temperature
vname_model_Tmax   =  'tasmax'  ;  'tasmax'     ;  'tasmax'  ; daily max temperature
vname_model_SW     =  'rsds' ;  short wave radiation
vname_model_LW     =  'rlds' ;  long wave radiation
vname_model_huss   =  'huss' ;  specific humidity
vname_model_U      =  'uas'  ;  meridional wind
vname_model_V      =  'vas'  ;  zonal wind
vname_model_ps     =  'ps'   ;  surface pressure
vname_model_rhs    =  'rhs'  ;  specific

IF(P_dep eq 0) THEN BEGIN
   vname_model_prsn   =  ''
ENDIF
IF(T_dep eq 0) THEN BEGIN
   vname_model_Tmin   =  ''
   vname_model_Tmax   =  ''
ENDIF

;
; A multiplication factor for the wfd and model data to convert to
; units of mm/s (for precip) and Kelvin (for temperature).
multf_wfd          =  1.0
multf_wfd_T        =  1.0
multf_wfd_SW       =  1.0
multf_wfd_LW       =  1.0
multf_wfd_huss     =  1.0
multf_wfd_wind     =  1.0
multf_wfd_ps       =  1.0
multf_wfd_rhs      =  1.0
multf_model        =  1.0
multf_model_T      =  1.0
multf_model_SW     =  1.0
multf_model_LW     =  1.0
multf_model_huss   =  1.0
multf_model_wind   =  1.0
multf_model_ps     =  1.0
multf_model_rhs    =  1.0
;
;! paths are now imported at the beginning
;______________________________________________________________
; Directory paths and file names
;______________________________________________________________
;
; pathdat is the general working directory (include final '/')
;pathdat               =  '/iplex/01/2011/isimip/data/BC_ISIMIP2/'
;
; Path for the original model data (include final '/')
;pathmodelorg          =   '/iplex/01/2011/isimip/inputdata_unbced/'+modelname+'/'
;
; Path for the original WFD data (include final '/')
;pathWFDorg            =  '/iplex/01/2011/isimip/data/BC_ISIMIP2/WFD/'
;
; Filename for the WFD in NETCDF format (a file of ~3-10GB for 40 yrs)
filename_WFD_Ptot     =  'pr_gpcc_watch_1958-2001.nc4'
filename_WFD_T        =  'tas_watch_1958-2001.nc4'
filename_WFD_Tmin     =  'tasmin_watch_1958-2001.nc4'
filename_WFD_Tmax     =  'tasmax_watch_1958-2001.nc4'
filename_WFD_SW       =  'rsds_watch_1958-2001.nc4'
filename_WFD_LW       =  'rlds_watch_1958-2001.nc4'
filename_WFD_huss     =  'hus_watch_1958-2001.nc4'
filename_WFD_wind     =  'wind_watch_1958-2001.nc4'
filename_WFD_ps       =  'ps_watch_1958-2001.nc4'
; Specify the run number if there are different versions of the model
; run, i.e. different initial conditions.
runToCorrect=''
; Construction filename for the model data in NETCDF format (a file of ~3GB for 40 yrs)
filename_model_const_Ptot   = modelname+'_historical_'+ensemble+'_pr_19600101-19991231_halfdeg.nc4'
filename_model_const_Psnow  = modelname+'_historical_'+ensemble+'_prsn_19600101-19991231_halfdeg.nc4'
filename_model_const_T      = modelname+'_historical_'+ensemble+'_tas_19600101-19991231_halfdeg.nc4'
filename_model_const_Tmin   = modelname+'_historical_'+ensemble+'_tasmin_19600101-19991231_halfdeg.nc4'
filename_model_const_Tmax   = modelname+'_historical_'+ensemble+'_tasmax_19600101-19991231_halfdeg.nc4'
filename_model_const_SW     = modelname+'_historical_'+ensemble+'_rsds_19600101-19991231_halfdeg.nc4'
filename_model_const_LW     = modelname+'_historical_'+ensemble+'_rlds_19600101-19991231_halfdeg.nc4'
filename_model_const_huss   = modelname+'_historical_'+ensemble+'_huss_19600101-19991231_halfdeg.nc4'
filename_model_const_U      = modelname+'_historical_'+ensemble+'_uas_19600101-19991231_halfdeg.nc4'
filename_model_const_V      = modelname+'_historical_'+ensemble+'_vas_19600101-19991231_halfdeg.nc4'
filename_model_const_ps     = modelname+'_historical_'+ensemble+'_ps_19600101-19991231_halfdeg.nc4'
filename_model_const_rhs    = modelname+'_historical_'+ensemble+'_rhs_19600101-19991231_halfdeg.nc4'
;
; Application filename for the model data in NETCDF format (a file of ~3GB for 40 yrs)

IF ( (APPLICATION_PERIOD_START ne '2000') and (APPLICATION_PERIOD_STOP ne '2099') ) THEN BEGIN

   filename_model_appl_Ptot    = modelname+'_'+runidx+'_'+ensemble+'_pr_'+APPLICATION_PERIOD_START+'0101-'+APPLICATION_PERIOD_STOP+'1231_halfdeg.nc4'

   filename_model_appl_Psnow   = modelname+'_'+runidx+'_'+ensemble+'_prsn_'+APPLICATION_PERIOD_START+'0101-'+APPLICATION_PERIOD_STOP+'1231_halfdeg.nc4'

   filename_model_appl_T       = modelname+'_'+runidx+'_'+ensemble+'_tas_'+APPLICATION_PERIOD_START+'0101-'+APPLICATION_PERIOD_STOP+'1231_halfdeg.nc4'

   filename_model_appl_Tmin    = modelname+'_'+runidx+'_'+ensemble+'_tasmin_'+APPLICATION_PERIOD_START+'0101-'+APPLICATION_PERIOD_STOP+'1231_halfdeg.nc4'

   filename_model_appl_Tmax    = modelname+'_'+runidx+'_'+ensemble+'_tasmax_'+APPLICATION_PERIOD_START+'0101-'+APPLICATION_PERIOD_STOP+'1231_halfdeg.nc4'

   filename_model_appl_SW      = modelname+'_'+runidx+'_'+ensemble+'_rsds_'+APPLICATION_PERIOD_START+'0101-'+APPLICATION_PERIOD_STOP+'1231_halfdeg.nc4'

   filename_model_appl_LW      = modelname+'_'+runidx+'_'+ensemble+'_rlds_'+APPLICATION_PERIOD_START+'0101-'+APPLICATION_PERIOD_STOP+'1231_halfdeg.nc4'

   filename_model_appl_huss    = modelname+'_'+runidx+'_'+ensemble+'_huss_'+APPLICATION_PERIOD_START+'0101-'+APPLICATION_PERIOD_STOP+'1231_halfdeg.nc4'

   filename_model_appl_U       = modelname+'_'+runidx+'_'+ensemble+'_uas_'+APPLICATION_PERIOD_START+'0101-'+APPLICATION_PERIOD_STOP+'1231_halfdeg.nc4'

   filename_model_appl_V       = modelname+'_'+runidx+'_'+ensemble+'_vas_'+APPLICATION_PERIOD_START+'0101-'+APPLICATION_PERIOD_STOP+'1231_halfdeg.nc4'

   filename_model_appl_ps      = modelname+'_'+runidx+'_'+ensemble+'_ps_'+APPLICATION_PERIOD_START+'0101-'+APPLICATION_PERIOD_STOP+'1231_halfdeg.nc4'

   filename_model_appl_rhs     = modelname+'_'+runidx+'_'+ensemble+'_rhs_'+APPLICATION_PERIOD_START+'0101-'+APPLICATION_PERIOD_STOP+'1231_halfdeg.nc4'
ENDIF
IF ( (APPLICATION_PERIOD_START eq '2000') or (APPLICATION_PERIOD_STOP eq '2099') ) THEN BEGIN

   filename_model_appl_Ptot    = modelname+'_'+runidx+'_'+ensemble+'_pr_20000101-20991231_halfdeg.nc4'

   filename_model_appl_Psnow   = modelname+'_'+runidx+'_'+ensemble+'_prsn_20000101-20991231_halfdeg.nc4'

   filename_model_appl_T       = modelname+'_'+runidx+'_'+ensemble+'_tas_20000101-20991231_halfdeg.nc4'

   filename_model_appl_Tmin    = modelname+'_'+runidx+'_'+ensemble+'_tasmin_20000101-20991231_halfdeg.nc4'

   filename_model_appl_Tmax    = modelname+'_'+runidx+'_'+ensemble+'_tasmax_20000101-20991231_halfdeg.nc4'

   filename_model_appl_SW      = modelname+'_'+runidx+'_'+ensemble+'_rsds_20000101-20991231_halfdeg.nc4'

   filename_model_appl_LW      = modelname+'_'+runidx+'_'+ensemble+'_rlds_20000101-20991231_halfdeg.nc4'

   filename_model_appl_huss    = modelname+'_'+runidx+'_'+ensemble+'_huss_20000101-20991231_halfdeg.nc4'

   filename_model_appl_U       = modelname+'_'+runidx+'_'+ensemble+'_uas_20000101-20991231_halfdeg.nc4'

   filename_model_appl_V       = modelname+'_'+runidx+'_'+ensemble+'_vas_20000101-20991231_halfdeg.nc4'

   filename_model_appl_ps      = modelname+'_'+runidx+'_'+ensemble+'_ps_20000101-20991231_halfdeg.nc4'

   filename_model_appl_rhs     = modelname+'_'+runidx+'_'+ensemble+'_rhs_20000101-20991231_halfdeg.nc4'

ENDIF



;_______________________________________________________________
;
; Specify a data format for the final output: 0=NO, 1=YES, Both on or
; both off are also possible.
OUTPUT_DATAFORMAT_1D = 0
OUTPUT_DATAFORMAT_2D = 1
END
;
; INFORMATION COMPLETE?
; Thank you for entering all information! Please save this file. Then
; check your information by running './makeLogFile' and opening the
; logfile "logfile_for_USER_SPECIFIED_DATA_'+<BC_runnumber>+'.txt".
;
; You should then be ready to run the bias correction by executing
; './run_bias_correction' in your main working directory.
;_______________________________________________________________
;_______________________________________________________________
