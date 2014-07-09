;;THIS IDL FILE CONTAINS SEVERAL DEFINITIONS REQUIRED FOR THE
;;CONSTRUCTION OF THE MONTHLY BIAS CORRECTION COEFFICIENTS.
;;
;; requires: definitions.pro, ncdf2idl.pro, prepareData.pro, adapt_calendar.pro, count_processed
;;
;; This files prepares original WFD and model data for temperature. The user can
;; specify in definitions.pro which format the original data is
;; in. Possible formats are (FORMAT=0) compressed WFD format as a 1d NETCDF
;; file, (FORMAT=1) latlon NETCDF files on a 1/2 degree grid and (FORMAT=2) idl
;; saved files (.dat) in the correct format for exactly the years of
;; interest. In the case of (2) the user must make sure that the
;; correct time-period is stored and that the variables for
;; T, Tmin, and Tmax are all named 'idldata'. E.g. for 5 January months from 1961
;; to 1965 the user must then supply a file with 5x31=155 timesteps
;; of 67420 space points each, hence idldata(67420,155).
;; ___________________________________________________________
;;
;
;
;
; COMMON INFORMATION FOR CONSTRUCTION OF BC AND ITS APPLICATION
;
; define a switch to specify the format of the WFD (0->COMPRESSED WFD
; format, 1->LATLON NETCDF, 2->IDL .dat files by month for the correct
; correction period)
;;FORMAT_WFD=0
;
; define a switch to specify the format of the model data for the
; correction period (0->COMPRESSED WFD
; format, 1->LATLON NETCDF, 2->IDL .dat files by month for the correct
; correction period)
;;FORMAT_CORRECTION=1
;
; define a switch to specify the format of the model data for the
; application period (0->COMPRESSED WFD
; format, 1->LATLON NETCDF, 2->IDL .dat files by month for the correct
; correction period)
;;FORMAT_APPLICATION=1
;
;CONVERTWFD2IDL_SWITCH=1
IF (CONVERTWFD2IDL_SWITCH EQ 1) THEN BEGIN
; prepare files for the case of compressed WFD format
   IF (T_computeCor EQ 1) THEN BEGIN
      IF (FORMAT_WFD EQ 0) THEN BEGIN
         YEAR_START=CONSTRUCTION_PERIOD_START
         YEAR_STOP=CONSTRUCTION_PERIOD_STOP
         inName=pathWFDchunk+filenameWFDchunkCompressed_T
         outNameBase=pathWFD+WFDroot_T+construction_period ; +month.dat
         prepareData,0,inName,outNameBase,'',vname_wfd_T,YEAR_START,YEAR_STOP,month,NUMLANDPOINTS,land,multf_wfd_T
;
         inName=pathWFDchunk+filenameWFDchunkCompressed_Tmin
         outNameBase=pathWFD+WFDroot_Tmin+construction_period ; +month.dat
         prepareData,0,inName,outNameBase,'',vname_wfd_Tmin,YEAR_START,YEAR_STOP,month,NUMLANDPOINTS,land,multf_wfd_Tmin
;
         inName=pathWFDchunk+filenameWFDchunkCompressed_Tmax
         outNameBase=pathWFD+WFDroot_Tmax+construction_period ; +month.dat
         prepareData,0,inName,outNameBase,'',vname_wfd_Tmax,YEAR_START,YEAR_STOP,month,NUMLANDPOINTS,land,multf_wfd_Tmax
      ENDIF
;
; prepare files for the case of latlon format
      IF (FORMAT_WFD EQ 1) THEN BEGIN
         YEAR_START=CONSTRUCTION_PERIOD_START
         YEAR_STOP=CONSTRUCTION_PERIOD_STOP
         inName=pathWFDchunk+filenameWFDchunkLatlon_T
         outNameBase=pathWFD+WFDroot_T+construction_period ; +month.dat
         prepareData,1,inName,outNameBase,'',vname_wfd_T,YEAR_START,YEAR_STOP,month,NUMLANDPOINTS,land,multf_wfd_T
;
         inName=pathWFDchunk+filenameWFDchunkLatlon_Tmin
         outNameBase=pathWFD+WFDroot_Tmin+construction_period ; +month.dat
         prepareData,1,inName,outNameBase,'',vname_wfd_Tmin,YEAR_START,YEAR_STOP,month,NUMLANDPOINTS,land,multf_wfd_Tmin
;
         inName=pathWFDchunk+filenameWFDchunkLatlon_Tmax
         outNameBase=pathWFD+WFDroot_Tmax+construction_period ; +month.dat
         prepareData,1,inName,outNameBase,'',vname_wfd_Tmax,YEAR_START,YEAR_STOP,month,NUMLANDPOINTS,land,multf_wfd_Tmax
      ENDIF
;
   ENDIF
ENDIF
;
;CONVERTMODEL2IDL_SWITCH_1=0
IF (CONVERTMODEL2IDL_SWITCH_1 EQ 1) THEN BEGIN
; prepare files for the case of compressed WFD format
   IF (T_computeCor EQ 1) THEN BEGIN
      IF (FORMAT_CORRECTION EQ 0) THEN BEGIN
         YEAR_START=CONSTRUCTION_PERIOD_START
         YEAR_STOP=CONSTRUCTION_PERIOD_STOP
         inName=pathMODELchunk+filenameMODELCONSTRUCTIONchunkCompressed_T
         outNameBase=pathmodel+MODELroot_T+construction_period ; +month.dat
         prepareData,0,inName,outNameBase,runToCorrect+'_',vname_model_T,YEAR_START,YEAR_STOP,month,NUMLANDPOINTS,land,multf_model_T
;
         IF (vname_model_Tmin ne '') THEN BEGIN
            inName=pathMODELchunk+filenameMODELCONSTRUCTIONchunkCompressed_Tmin
            outNameBase=pathmodel+MODELroot_Tmin+construction_period ;+month.dat
            prepareData,0,inName,outNameBase,runToCorrect+'_',vname_model_Tmin,YEAR_START,YEAR_STOP,month,NUMLANDPOINTS,land,multf_model_Tmin
         ENDIF
;
         IF (vname_model_Tmax ne '') THEN BEGIN
            inName=pathMODELchunk+filenameMODELCONSTRUCTIONchunkCompressed_Tmax
            outNameBase=pathmodel+MODELroot_Tmax+construction_period ;+month.dat
            prepareData,0,inName,outNameBase,runToCorrect+'_',vname_model_Tmax,YEAR_START,YEAR_STOP,month,NUMLANDPOINTS,land,multf_model_Tmax
         ENDIF
      ENDIF
;
; prepare files for the case of latlon format
      IF (FORMAT_CORRECTION EQ 1) THEN BEGIN
         YEAR_START=CONSTRUCTION_PERIOD_START
         YEAR_STOP=CONSTRUCTION_PERIOD_STOP
         inName=pathMODELchunk+filenameMODELCONSTRUCTIONchunkLatlon_T
         outNameBase=pathmodel+MODELroot_T+construction_period ; +month.dat
         prepareData,1,inName,outNameBase,runToCorrect+'_',vname_model_T,YEAR_START,YEAR_STOP,month,NUMLANDPOINTS,land,multf_model_T
;
         IF (vname_model_Tmin ne '') THEN BEGIN
            inName=pathMODELchunk+filenameMODELCONSTRUCTIONchunkLatlon_Tmin
            outNameBase=pathmodel+MODELroot_Tmin+construction_period ;+month.dat
            prepareData,1,inName,outNameBase,runToCorrect+'_',vname_model_Tmin,YEAR_START,YEAR_STOP,month,NUMLANDPOINTS,land,multf_model_Tmin
         ENDIF
;
         IF (vname_model_Tmax ne '') THEN BEGIN
            inName=pathMODELchunk+filenameMODELCONSTRUCTIONchunkLatlon_Tmax
            outNameBase=pathmodel+MODELroot_Tmax+construction_period ;+month.dat
            prepareData,1,inName,outNameBase,runToCorrect+'_',vname_model_Tmax,YEAR_START,YEAR_STOP,month,NUMLANDPOINTS,land,multf_model_Tmax
         ENDIF
      ENDIF
;

;+++++++++++++++++++++++++++++++++++++ begin interpolate to standard calendar ++++++++++++++++++++++++
      YEAR_START=CONSTRUCTION_PERIOD_START
      YEAR_STOP=CONSTRUCTION_PERIOD_STOP
      outNameBase=pathmodel+MODELroot_T+construction_period ; +month.dat
      adapt_calendar, CALENDAR, outNameBase, runToCorrect, month, YEAR_START, YEAR_STOP
      IF (vname_model_Tmin ne '') THEN BEGIN
         outNameBase=pathmodel+MODELroot_Tmin+construction_period ; +month.dat
         adapt_calendar, CALENDAR, outNameBase, runToCorrect, month, YEAR_START, YEAR_STOP
      ENDIF
      IF (vname_model_Tmax ne '') THEN BEGIN
         outNameBase=pathmodel+MODELroot_Tmax+construction_period ; +month.dat
         adapt_calendar, CALENDAR, outNameBase, runToCorrect, month, YEAR_START, YEAR_STOP
      ENDIF
;+++++++++++++++++++++++++++++++++++++ end interpolate to standard calendar ++++++++++++++++++++++++


   ENDIF
ENDIF
;
;
;CONVERTMODEL2IDL_SWITCH_2=0
IF (CONVERTMODEL2IDL_SWITCH_2 EQ 1) THEN BEGIN
; prepare files for the case of compressed WFD format
   IF (T_apply EQ 1) THEN BEGIN
      IF (FORMAT_APPLICATION EQ 0) THEN BEGIN
         YEAR_START=APPLICATION_PERIOD_START
         YEAR_STOP=APPLICATION_PERIOD_STOP
         inName=pathMODELchunk+filenameMODELAPPLICATIONchunkCompressed_T
         outNameBase=pathmodel+MODELroot_T+application_period ; +month.dat
         prepareData,0,inName,outNameBase,runToCorrect+'_',vname_model_T,YEAR_START,YEAR_STOP,month,NUMLANDPOINTS,land,multf_model_T
;
         IF (vname_model_Tmin ne '') THEN BEGIN
            inName=pathMODELchunk+filenameMODELAPPLICATIONchunkCompressed_Tmin
            outNameBase=pathmodel+MODELroot_Tmin+application_period ; +month.dat
            prepareData,0,inName,outNameBase,runToCorrect+'_',vname_model_Tmin,YEAR_START,YEAR_STOP,month,NUMLANDPOINTS,land,multf_model_Tmin
         ENDIF
;
         IF (vname_model_Tmax ne '') THEN BEGIN
            inName=pathMODELchunk+filenameMODELAPPLICATIONchunkCompressed_Tmax
            outNameBase=pathmodel+MODELroot_Tmax+application_period ; +month.dat
            prepareData,0,inName,outNameBase,runToCorrect+'_',vname_model_Tmax,YEAR_START,YEAR_STOP,month,NUMLANDPOINTS,land,multf_model_Tmax
         ENDIF
      ENDIF
;
; compare files for the case of latlon format
      IF (FORMAT_APPLICATION EQ 1) THEN BEGIN
         YEAR_START=APPLICATION_PERIOD_START
         YEAR_STOP=APPLICATION_PERIOD_STOP
         inName=pathMODELchunk+filenameMODELAPPLICATIONchunkLatlon_T
         outNameBase=pathmodel+MODELroot_T+application_period ; +month.dat
         prepareData,1,inName,outNameBase,runToCorrect+'_',vname_model_T,YEAR_START,YEAR_STOP,month,NUMLANDPOINTS,land,multf_model_T
;
         IF (vname_model_Tmin ne '') THEN BEGIN
            inName=pathMODELchunk+filenameMODELAPPLICATIONchunkLatlon_Tmin
            outNameBase=pathmodel+MODELroot_Tmin+application_period ; +month.dat
            prepareData,1,inName,outNameBase,runToCorrect+'_',vname_model_Tmin,YEAR_START,YEAR_STOP,month,NUMLANDPOINTS,land,multf_model_Tmin
         ENDIF
;
         IF (vname_model_Tmax ne '') THEN BEGIN
            inName=pathMODELchunk+filenameMODELAPPLICATIONchunkLatlon_Tmax
            outNameBase=pathmodel+MODELroot_Tmax+application_period ; +month.dat
            prepareData,1,inName,outNameBase,runToCorrect+'_',vname_model_Tmax,YEAR_START,YEAR_STOP,month,NUMLANDPOINTS,land,multf_model_Tmax
         ENDIF
      ENDIF
;
; compare files for the case of finished idl files (do nothing whatsoever)
      IF (FORMAT_APPLICATION EQ 2) THEN BEGIN
         print,'data is already prepared.'
      ENDIF

;+++++++++++++++++++++++++++++++++++++ begin interpolate to standard calendar ++++++++++++++++++++++++
      YEAR_START=APPLICATION_PERIOD_START
      YEAR_STOP=APPLICATION_PERIOD_STOP
      outNameBase=pathmodel+MODELroot_T+application_period ; +month.dat
      adapt_calendar, CALENDAR, outNameBase, runToCorrect, month, YEAR_START, YEAR_STOP
      IF (vname_model_Tmin ne '') THEN BEGIN
         outNameBase=pathmodel+MODELroot_Tmin+application_period ; +month.dat
         adapt_calendar, CALENDAR, outNameBase, runToCorrect, month, YEAR_START, YEAR_STOP
      ENDIF
      IF (vname_model_Tmax ne '') THEN BEGIN
         outNameBase=pathmodel+MODELroot_Tmax+application_period ; +month.dat
         adapt_calendar, CALENDAR, outNameBase, runToCorrect, month, YEAR_START, YEAR_STOP
      ENDIF
;+++++++++++++++++++++++++++++++++++++ end interpolate to standard calendar ++++++++++++++++++++++++

   ENDIF
ENDIF
END
