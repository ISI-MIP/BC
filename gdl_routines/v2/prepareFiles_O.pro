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
IF (CONVERTWFD2IDL_SWITCH EQ 1) THEN BEGIN
;+++++ pressure +++++
; prepare files for the case of compressed WFD format
   IF (ps_computeCor EQ 1) THEN BEGIN
      IF (FORMAT_WFD EQ 0) THEN BEGIN
         YEAR_START=CONSTRUCTION_PERIOD_START
         YEAR_STOP=CONSTRUCTION_PERIOD_STOP
         inName=pathWFDchunk+filenameWFDchunkCompressed_ps
         outNameBase=pathWFD+WFDroot_ps+construction_period ; +month.dat
         prepareData,0,inName,outNameBase,'',vname_wfd_ps,YEAR_START,YEAR_STOP,month,NUMLANDPOINTS,land,multf_wfd_ps
      ENDIF
;
; compare files for the case of latlon format
      IF (FORMAT_WFD EQ 1) THEN BEGIN
         YEAR_START=CONSTRUCTION_PERIOD_START
         YEAR_STOP=CONSTRUCTION_PERIOD_STOP
         inName=pathWFDchunk+filenameWFDchunkLatlon_ps
         outNameBase=pathWFD+WFDroot_ps+construction_period ; +month.dat
         prepareData,1,inName,outNameBase,'',vname_wfd_ps,YEAR_START,YEAR_STOP,month,NUMLANDPOINTS,land,multf_wfd_ps
      ENDIF
;
; compare files for the case of finished idl files (do nothing whatsoever)
      IF (FORMAT_WFD EQ 2) THEN BEGIN
         print,'data is already prepared.'
      ENDIF
   ENDIF
;+++++ LW +++++
; prepare files for the case of compressed WFD format
   IF (LW_computeCor EQ 1) THEN BEGIN
      IF (FORMAT_WFD EQ 0) THEN BEGIN
         YEAR_START=CONSTRUCTION_PERIOD_START
         YEAR_STOP=CONSTRUCTION_PERIOD_STOP
         inName=pathWFDchunk+filenameWFDchunkCompressed_LW
         outNameBase=pathWFD+WFDroot_LW+construction_period ; +month.dat
         prepareData,0,inName,outNameBase,'',vname_wfd_LW,YEAR_START,YEAR_STOP,month,NUMLANDPOINTS,land,multf_wfd_LW
      ENDIF
;
; compare files for the case of latlon format
      IF (FORMAT_WFD EQ 1) THEN BEGIN
         YEAR_START=CONSTRUCTION_PERIOD_START
         YEAR_STOP=CONSTRUCTION_PERIOD_STOP
         inName=pathWFDchunk+filenameWFDchunkLatlon_LW
         outNameBase=pathWFD+WFDroot_LW+construction_period ; +month.dat
         prepareData,1,inName,outNameBase,'',vname_wfd_LW,YEAR_START,YEAR_STOP,month,NUMLANDPOINTS,land,multf_wfd_LW
      ENDIF
;
; compare files for the case of finished idl files (do nothing whatsoever)
      IF (FORMAT_WFD EQ 2) THEN BEGIN
         print,'data is already prepared.'
      ENDIF
   ENDIF
;+++++ SW +++++
; prepare files for the case of compressed WFD format
   IF (SW_computeCor EQ 1) THEN BEGIN
      IF (FORMAT_WFD EQ 0) THEN BEGIN
         YEAR_START=CONSTRUCTION_PERIOD_START
         YEAR_STOP=CONSTRUCTION_PERIOD_STOP
         inName=pathWFDchunk+filenameWFDchunkCompressed_SW
         outNameBase=pathWFD+WFDroot_SW+construction_period ; +month.dat
         prepareData,0,inName,outNameBase,'',vname_wfd_SW,YEAR_START,YEAR_STOP,month,NUMLANDPOINTS,land,multf_wfd_SW
      ENDIF
;
; compare files for the case of latlon format
      IF (FORMAT_WFD EQ 1) THEN BEGIN
         YEAR_START=CONSTRUCTION_PERIOD_START
         YEAR_STOP=CONSTRUCTION_PERIOD_STOP
         inName=pathWFDchunk+filenameWFDchunkLatlon_SW
         outNameBase=pathWFD+WFDroot_SW+construction_period ; +month.dat
         prepareData,1,inName,outNameBase,'',vname_wfd_SW,YEAR_START,YEAR_STOP,month,NUMLANDPOINTS,land,multf_wfd_SW
      ENDIF
;
; compare files for the case of finished idl files (do nothing whatsoever)
      IF (FORMAT_WFD EQ 2) THEN BEGIN
         print,'data is already prepared.'
      ENDIF
   ENDIF
;+++++ huss +++++
; prepare files for the case of compressed WFD format
   IF (huss_computeCor EQ 1) THEN BEGIN
      IF (FORMAT_WFD EQ 0) THEN BEGIN
         YEAR_START=CONSTRUCTION_PERIOD_START
         YEAR_STOP=CONSTRUCTION_PERIOD_STOP
         inName=pathWFDchunk+filenameWFDchunkCompressed_huss
         outNameBase=pathWFD+WFDroot_huss+construction_period ; +month.dat
         prepareData,0,inName,outNameBase,'',vname_wfd_huss,YEAR_START,YEAR_STOP,month,NUMLANDPOINTS,land,multf_wfd_huss
      ENDIF
;
; compare files for the case of latlon format
      IF (FORMAT_WFD EQ 1) THEN BEGIN
         YEAR_START=CONSTRUCTION_PERIOD_START
         YEAR_STOP=CONSTRUCTION_PERIOD_STOP
         inName=pathWFDchunk+filenameWFDchunkLatlon_huss
         outNameBase=pathWFD+WFDroot_huss+construction_period ; +month.dat
         prepareData,1,inName,outNameBase,'',vname_wfd_huss,YEAR_START,YEAR_STOP,month,NUMLANDPOINTS,land,multf_wfd_huss
      ENDIF
;
; compare files for the case of finished idl files (do nothing whatsoever)
      IF (FORMAT_WFD EQ 2) THEN BEGIN
         print,'data is already prepared.'
      ENDIF
   ENDIF
;+++++ wind +++++
; prepare files for the case of compressed WFD format
   IF (wind_computeCor EQ 1) THEN BEGIN
      IF (FORMAT_WFD EQ 0) THEN BEGIN
         YEAR_START=CONSTRUCTION_PERIOD_START
         YEAR_STOP=CONSTRUCTION_PERIOD_STOP
         inName=pathWFDchunk+filenameWFDchunkCompressed_wind
         outNameBase=pathWFD+WFDroot_wind+construction_period ; +month.dat
         prepareData,0,inName,outNameBase,'',vname_wfd_wind,YEAR_START,YEAR_STOP,month,NUMLANDPOINTS,land,multf_wfd_wind
      ENDIF
;
; compare files for the case of latlon format
      IF (FORMAT_WFD EQ 1) THEN BEGIN
         YEAR_START=CONSTRUCTION_PERIOD_START
         YEAR_STOP=CONSTRUCTION_PERIOD_STOP
         inName=pathWFDchunk+filenameWFDchunkLatlon_wind
         outNameBase=pathWFD+WFDroot_wind+construction_period ; +month.dat
         prepareData,1,inName,outNameBase,'',vname_wfd_wind,YEAR_START,YEAR_STOP,month,NUMLANDPOINTS,land,multf_wfd_wind
      ENDIF
;
; compare files for the case of finished idl files (do nothing whatsoever)
      IF (FORMAT_WFD EQ 2) THEN BEGIN
         print,'data is already prepared.'
      ENDIF
   ENDIF
ENDIF
;
IF (CONVERTMODEL2IDL_SWITCH_1 EQ 1) THEN BEGIN
;+++++ pressure +++++
; prepare files for the case of compressed WFD format
   IF (ps_computeCor EQ 1) THEN BEGIN
      IF (FORMAT_CORRECTION EQ 0) THEN BEGIN
         YEAR_START=CONSTRUCTION_PERIOD_START
         YEAR_STOP=CONSTRUCTION_PERIOD_STOP
         inName=pathMODELchunk+filenameMODELCONSTRUCTIONchunkCompressed_ps
         outNameBase=pathmodel+MODELroot_ps+construction_period ; +month.dat
         prepareData,0,inName,outNameBase,runToCorrect+'_',vname_model_ps,YEAR_START,YEAR_STOP,month,NUMLANDPOINTS,land,multf_model_ps
      ENDIF
;
; compare files for the case of latlon format
      IF (FORMAT_CORRECTION EQ 1) THEN BEGIN
         YEAR_START=CONSTRUCTION_PERIOD_START
         YEAR_STOP=CONSTRUCTION_PERIOD_STOP
         inName=pathMODELchunk+filenameMODELCONSTRUCTIONchunkLatlon_ps
         outNameBase=pathmodel+MODELroot_ps+construction_period ; +month.dat
         prepareData,1,inName,outNameBase,runToCorrect+'_',vname_model_ps,YEAR_START,YEAR_STOP,month,NUMLANDPOINTS,land,multf_model_ps
      ENDIF
;
; compare files for the case of finished idl files (do nothing whatsoever)
      IF (FORMAT_CORRECTION EQ 2) THEN BEGIN
         print,'data is already prepared.'
      ENDIF
                                ;+++++ begin interpolate to standard calendar +++++
      YEAR_START=CONSTRUCTION_PERIOD_START
      YEAR_STOP=CONSTRUCTION_PERIOD_STOP
      outNameBase=pathmodel+MODELroot_ps+construction_period ; +month.dat
      adapt_calendar, CALENDAR, outNameBase, runToCorrect, month, YEAR_START, YEAR_STOP
                                ;+++++ end interpolate to standard calendar +++++
   ENDIF
;+++++ LW +++++
; prepare files for the case of compressed WFD format
   IF (LW_computeCor EQ 1) THEN BEGIN
      IF (FORMAT_CORRECTION EQ 0) THEN BEGIN
         YEAR_START=CONSTRUCTION_PERIOD_START
         YEAR_STOP=CONSTRUCTION_PERIOD_STOP
         inName=pathMODELchunk+filenameMODELCONSTRUCTIONchunkCompressed_LW
         outNameBase=pathmodel+MODELroot_LW+construction_period ; +month.dat
         prepareData,0,inName,outNameBase,runToCorrect+'_',vname_model_LW,YEAR_START,YEAR_STOP,month,NUMLANDPOINTS,land,multf_model_LW
      ENDIF
;
; compare files for the case of latlon format
      IF (FORMAT_CORRECTION EQ 1) THEN BEGIN
         YEAR_START=CONSTRUCTION_PERIOD_START
         YEAR_STOP=CONSTRUCTION_PERIOD_STOP
         inName=pathMODELchunk+filenameMODELCONSTRUCTIONchunkLatlon_LW
         outNameBase=pathmodel+MODELroot_LW+construction_period ; +month.dat
         prepareData,1,inName,outNameBase,runToCorrect+'_',vname_model_LW,YEAR_START,YEAR_STOP,month,NUMLANDPOINTS,land,multf_model_LW
      ENDIF
;
; compare files for the case of finished idl files (do nothing whatsoever)
      IF (FORMAT_CORRECTION EQ 2) THEN BEGIN
         print,'data is already prepared.'
      ENDIF
                                ;+++++ begin interpolate to standard calendar +++++
      YEAR_START=CONSTRUCTION_PERIOD_START
      YEAR_STOP=CONSTRUCTION_PERIOD_STOP
      outNameBase=pathmodel+MODELroot_LW+construction_period ; +month.dat
      adapt_calendar, CALENDAR, outNameBase, runToCorrect, month, YEAR_START, YEAR_STOP
                                ;+++++ end interpolate to standard calendar +++++
   ENDIF
;+++++ SW +++++
; prepare files for the case of compressed WFD format
   IF (SW_computeCor EQ 1) THEN BEGIN
      IF (FORMAT_CORRECTION EQ 0) THEN BEGIN
         YEAR_START=CONSTRUCTION_PERIOD_START
         YEAR_STOP=CONSTRUCTION_PERIOD_STOP
         inName=pathMODELchunk+filenameMODELCONSTRUCTIONchunkCompressed_SW
         outNameBase=pathmodel+MODELroot_SW+construction_period ; +month.dat
         prepareData,0,inName,outNameBase,runToCorrect+'_',vname_model_SW,YEAR_START,YEAR_STOP,month,NUMLANDPOINTS,land,multf_model_SW
      ENDIF
;
; compare files for the case of latlon format
      IF (FORMAT_CORRECTION EQ 1) THEN BEGIN
         YEAR_START=CONSTRUCTION_PERIOD_START
         YEAR_STOP=CONSTRUCTION_PERIOD_STOP
         inName=pathMODELchunk+filenameMODELCONSTRUCTIONchunkLatlon_SW
         outNameBase=pathmodel+MODELroot_SW+construction_period ; +month.dat
         prepareData,1,inName,outNameBase,runToCorrect+'_',vname_model_SW,YEAR_START,YEAR_STOP,month,NUMLANDPOINTS,land,multf_model_SW
      ENDIF
;
; compare files for the case of finished idl files (do nothing whatsoever)
      IF (FORMAT_CORRECTION EQ 2) THEN BEGIN
         print,'data is already prepared.'
      ENDIF
                                ;+++++ begin interpolate to standard calendar +++++
      YEAR_START=CONSTRUCTION_PERIOD_START
      YEAR_STOP=CONSTRUCTION_PERIOD_STOP
      outNameBase=pathmodel+MODELroot_SW+construction_period ; +month.dat
      adapt_calendar, CALENDAR, outNameBase, runToCorrect, month, YEAR_START, YEAR_STOP
                                ;+++++ end interpolate to standard calendar +++++
   ENDIF
;+++++ huss +++++
; prepare files for the case of compressed WFD format
   IF (huss_computeCor EQ 1) THEN BEGIN
      IF (FORMAT_CORRECTION EQ 0) THEN BEGIN
         YEAR_START=CONSTRUCTION_PERIOD_START
         YEAR_STOP=CONSTRUCTION_PERIOD_STOP
         inName=pathMODELchunk+filenameMODELCONSTRUCTIONchunkCompressed_huss
         outNameBase=pathmodel+MODELroot_huss+construction_period ; +month.dat
         prepareData,0,inName,outNameBase,runToCorrect+'_',vname_model_huss,YEAR_START,YEAR_STOP,month,NUMLANDPOINTS,land,multf_model_huss
      ENDIF
;
; compare files for the case of latlon format
      IF (FORMAT_CORRECTION EQ 1) THEN BEGIN
         YEAR_START=CONSTRUCTION_PERIOD_START
         YEAR_STOP=CONSTRUCTION_PERIOD_STOP
         inName=pathMODELchunk+filenameMODELCONSTRUCTIONchunkLatlon_huss
         outNameBase=pathmodel+MODELroot_huss+construction_period ; +month.dat
         prepareData,1,inName,outNameBase,runToCorrect+'_',vname_model_huss,YEAR_START,YEAR_STOP,month,NUMLANDPOINTS,land,multf_model_huss
      ENDIF
;
; compare files for the case of finished idl files (do nothing whatsoever)
      IF (FORMAT_CORRECTION EQ 2) THEN BEGIN
         print,'data is already prepared.'
      ENDIF
                                ;+++++ begin interpolate to standard calendar +++++
      YEAR_START=CONSTRUCTION_PERIOD_START
      YEAR_STOP=CONSTRUCTION_PERIOD_STOP
      outNameBase=pathmodel+MODELroot_huss+construction_period ; +month.dat
      adapt_calendar, CALENDAR, outNameBase, runToCorrect, month, YEAR_START, YEAR_STOP
                                ;+++++ end interpolate to standard calendar +++++
   ENDIF
;+++++ U +++++
; prepare files for the case of compressed WFD format
   IF (wind_computeCor EQ 1) THEN BEGIN
      IF (FORMAT_CORRECTION EQ 0) THEN BEGIN
         YEAR_START=CONSTRUCTION_PERIOD_START
         YEAR_STOP=CONSTRUCTION_PERIOD_STOP
         inName=pathMODELchunk+filenameMODELCONSTRUCTIONchunkCompressed_U
         outNameBase=pathmodel+MODELroot_U+construction_period ; +month.dat
         prepareData,0,inName,outNameBase,runToCorrect+'_',vname_model_U,YEAR_START,YEAR_STOP,month,NUMLANDPOINTS,land,multf_model_wind
      ENDIF
;
; compare files for the case of latlon format
      IF (FORMAT_CORRECTION EQ 1) THEN BEGIN
         YEAR_START=CONSTRUCTION_PERIOD_START
         YEAR_STOP=CONSTRUCTION_PERIOD_STOP
         inName=pathMODELchunk+filenameMODELCONSTRUCTIONchunkLatlon_U
         outNameBase=pathmodel+MODELroot_U+construction_period ; +month.dat
         prepareData,1,inName,outNameBase,runToCorrect+'_',vname_model_U,YEAR_START,YEAR_STOP,month,NUMLANDPOINTS,land,multf_model_wind
      ENDIF
;
; compare files for the case of finished idl files (do nothing whatsoever)
      IF (FORMAT_CORRECTION EQ 2) THEN BEGIN
         print,'data is already prepared.'
      ENDIF
                                ;+++++ begin interpolate to standard calendar +++++
      YEAR_START=CONSTRUCTION_PERIOD_START
      YEAR_STOP=CONSTRUCTION_PERIOD_STOP
      outNameBase=pathmodel+MODELroot_U+construction_period ; +month.dat
      adapt_calendar, CALENDAR, outNameBase, runToCorrect, month, YEAR_START, YEAR_STOP
                                ;+++++ end interpolate to standard calendar +++++
   ENDIF
;+++++ V +++++
; prepare files for the case of compressed WFD format
   IF (wind_computeCor EQ 1) THEN BEGIN
      IF (FORMAT_CORRECTION EQ 0) THEN BEGIN
         YEAR_START=CONSTRUCTION_PERIOD_START
         YEAR_STOP=CONSTRUCTION_PERIOD_STOP
         inName=pathMODELchunk+filenameMODELCONSTRUCTIONchunkCompressed_V
         outNameBase=pathmodel+MODELroot_V+construction_period ; +month.dat
         prepareData,0,inName,outNameBase,runToCorrect+'_',vname_model_V,YEAR_START,YEAR_STOP,month,NUMLANDPOINTS,land,multf_model_wind
      ENDIF
;
; compare files for the case of latlon format
      IF (FORMAT_CORRECTION EQ 1) THEN BEGIN
         YEAR_START=CONSTRUCTION_PERIOD_START
         YEAR_STOP=CONSTRUCTION_PERIOD_STOP
         inName=pathMODELchunk+filenameMODELCONSTRUCTIONchunkLatlon_V
         outNameBase=pathmodel+MODELroot_V+construction_period ; +month.dat
         prepareData,1,inName,outNameBase,runToCorrect+'_',vname_model_V,YEAR_START,YEAR_STOP,month,NUMLANDPOINTS,land,multf_model_wind
      ENDIF
;
; compare files for the case of finished idl files (do nothing whatsoever)
      IF (FORMAT_CORRECTION EQ 2) THEN BEGIN
         print,'data is already prepared.'
      ENDIF
                                ;+++++ begin interpolate to standard calendar +++++
      YEAR_START=CONSTRUCTION_PERIOD_START
      YEAR_STOP=CONSTRUCTION_PERIOD_STOP
      outNameBase=pathmodel+MODELroot_V+construction_period ; +month.dat
      adapt_calendar, CALENDAR, outNameBase, runToCorrect, month, YEAR_START, YEAR_STOP
                                ;+++++ end interpolate to standard calendar +++++
   ENDIF
ENDIF
;
;
IF (CONVERTMODEL2IDL_SWITCH_2 EQ 1) THEN BEGIN
;+++++ pressure +++++
; prepare files for the case of compressed WFD format
   IF (ps_apply EQ 1) THEN BEGIN
      IF (FORMAT_APPLICATION EQ 0) THEN BEGIN
         YEAR_START=APPLICATION_PERIOD_START
         YEAR_STOP=APPLICATION_PERIOD_STOP
         inName=pathMODELchunk+filenameMODELAPPLICATIONchunkCompressed_ps
         outNameBase=pathmodel+MODELroot_ps+application_period ; +month.dat
         prepareData,0,inName,outNameBase,runToCorrect+'_',vname_model_ps,YEAR_START,YEAR_STOP,month,NUMLANDPOINTS,land,multf_model_ps
      ENDIF
;
; compare files for the case of latlon format
      IF (FORMAT_APPLICATION EQ 1) THEN BEGIN
         YEAR_START=APPLICATION_PERIOD_START
         YEAR_STOP=APPLICATION_PERIOD_STOP
         inName=pathMODELchunk+filenameMODELAPPLICATIONchunkLatlon_ps
         outNameBase=pathmodel+MODELroot_ps+application_period ; +month.dat
         prepareData,1,inName,outNameBase,runToCorrect+'_',vname_model_ps,YEAR_START,YEAR_STOP,month,NUMLANDPOINTS,land,multf_model_ps
      ENDIF
;
; compare files for the case of finished idl files (do nothing whatsoever)
      IF (FORMAT_APPLICATION EQ 2) THEN BEGIN
         print,'data is already prepared.'
      ENDIF
                                ;+++++ begin interpolate to standard calendar +++++
      YEAR_START=APPLICATION_PERIOD_START
      YEAR_STOP=APPLICATION_PERIOD_STOP
      outNameBase=pathmodel+MODELroot_ps+application_period ; +month.dat
      adapt_calendar, CALENDAR, outNameBase, runToCorrect, month, YEAR_START, YEAR_STOP
                                ;+++++ end interpolate to standard calendar +++++
   ENDIF
;+++++ LW +++++
; prepare files for the case of compressed WFD format
   IF (LW_apply EQ 1) THEN BEGIN
      IF (FORMAT_APPLICATION EQ 0) THEN BEGIN
         YEAR_START=APPLICATION_PERIOD_START
         YEAR_STOP=APPLICATION_PERIOD_STOP
         inName=pathMODELchunk+filenameMODELAPPLICATIONchunkCompressed_LW
         outNameBase=pathmodel+MODELroot_LW+application_period ; +month.dat
         prepareData,0,inName,outNameBase,runToCorrect+'_',vname_model_LW,YEAR_START,YEAR_STOP,month,NUMLANDPOINTS,land,multf_model_LW
      ENDIF
;
; compare files for the case of latlon format
      IF (FORMAT_APPLICATION EQ 1) THEN BEGIN
         YEAR_START=APPLICATION_PERIOD_START
         YEAR_STOP=APPLICATION_PERIOD_STOP
         inName=pathMODELchunk+filenameMODELAPPLICATIONchunkLatlon_LW
         outNameBase=pathmodel+MODELroot_LW+application_period ; +month.dat
         prepareData,1,inName,outNameBase,runToCorrect+'_',vname_model_LW,YEAR_START,YEAR_STOP,month,NUMLANDPOINTS,land,multf_model_LW
      ENDIF
;
; compare files for the case of finished idl files (do nothing whatsoever)
      IF (FORMAT_APPLICATION EQ 2) THEN BEGIN
         print,'data is already prepared.'
      ENDIF
                                ;+++++ begin interpolate to standard calendar +++++
      YEAR_START=APPLICATION_PERIOD_START
      YEAR_STOP=APPLICATION_PERIOD_STOP
      outNameBase=pathmodel+MODELroot_LW+application_period ; +month.dat
      adapt_calendar, CALENDAR, outNameBase, runToCorrect, month, YEAR_START, YEAR_STOP
                                ;+++++ end interpolate to standard calendar +++++
   ENDIF
;+++++ SW +++++
; prepare files for the case of compressed WFD format
   IF (SW_apply EQ 1) THEN BEGIN
      IF (FORMAT_APPLICATION EQ 0) THEN BEGIN
         YEAR_START=APPLICATION_PERIOD_START
         YEAR_STOP=APPLICATION_PERIOD_STOP
         inName=pathMODELchunk+filenameMODELAPPLICATIONchunkCompressed_SW
         outNameBase=pathmodel+MODELroot_SW+application_period ; +month.dat
         prepareData,0,inName,outNameBase,runToCorrect+'_',vname_model_SW,YEAR_START,YEAR_STOP,month,NUMLANDPOINTS,land,multf_model_SW
      ENDIF
;
; compare files for the case of latlon format
      IF (FORMAT_APPLICATION EQ 1) THEN BEGIN
         YEAR_START=APPLICATION_PERIOD_START
         YEAR_STOP=APPLICATION_PERIOD_STOP
         inName=pathMODELchunk+filenameMODELAPPLICATIONchunkLatlon_SW
         outNameBase=pathmodel+MODELroot_SW+application_period ; +month.dat
         prepareData,1,inName,outNameBase,runToCorrect+'_',vname_model_SW,YEAR_START,YEAR_STOP,month,NUMLANDPOINTS,land,multf_model_SW
      ENDIF
;
; compare files for the case of finished idl files (do nothing whatsoever)
      IF (FORMAT_APPLICATION EQ 2) THEN BEGIN
         print,'data is already prepared.'
      ENDIF
                                ;+++++ begin interpolate to standard calendar +++++
      YEAR_START=APPLICATION_PERIOD_START
      YEAR_STOP=APPLICATION_PERIOD_STOP
      outNameBase=pathmodel+MODELroot_SW+application_period ; +month.dat
      adapt_calendar, CALENDAR, outNameBase, runToCorrect, month, YEAR_START, YEAR_STOP
                                ;+++++ end interpolate to standard calendar +++++
   ENDIF
;+++++ huss +++++
; prepare files for the case of compressed WFD format
   IF (huss_apply EQ 1) THEN BEGIN
      IF (FORMAT_APPLICATION EQ 0) THEN BEGIN
         YEAR_START=APPLICATION_PERIOD_START
         YEAR_STOP=APPLICATION_PERIOD_STOP
         inName=pathMODELchunk+filenameMODELAPPLICATIONchunkCompressed_huss
         outNameBase=pathmodel+MODELroot_huss+application_period ; +month.dat
         prepareData,0,inName,outNameBase,runToCorrect+'_',vname_model_huss,YEAR_START,YEAR_STOP,month,NUMLANDPOINTS,land,multf_model_huss
      ENDIF
;
; compare files for the case of latlon format
      IF (FORMAT_APPLICATION EQ 1) THEN BEGIN
         YEAR_START=APPLICATION_PERIOD_START
         YEAR_STOP=APPLICATION_PERIOD_STOP
         inName=pathMODELchunk+filenameMODELAPPLICATIONchunkLatlon_huss
         outNameBase=pathmodel+MODELroot_huss+application_period ; +month.dat
         prepareData,1,inName,outNameBase,runToCorrect+'_',vname_model_huss,YEAR_START,YEAR_STOP,month,NUMLANDPOINTS,land,multf_model_huss
      ENDIF
;
; compare files for the case of finished idl files (do nothing whatsoever)
      IF (FORMAT_APPLICATION EQ 2) THEN BEGIN
         print,'data is already prepared.'
      ENDIF
                                ;+++++ begin interpolate to standard calendar +++++
      YEAR_START=APPLICATION_PERIOD_START
      YEAR_STOP=APPLICATION_PERIOD_STOP
      outNameBase=pathmodel+MODELroot_huss+application_period ; +month.dat
      adapt_calendar, CALENDAR, outNameBase, runToCorrect, month, YEAR_START, YEAR_STOP
                                ;+++++ end interpolate to standard calendar +++++
   ENDIF
;+++++ U +++++
; prepare files for the case of compressed WFD format
   IF (wind_apply EQ 1) THEN BEGIN
      IF (FORMAT_APPLICATION EQ 0) THEN BEGIN
         YEAR_START=APPLICATION_PERIOD_START
         YEAR_STOP=APPLICATION_PERIOD_STOP
         inName=pathMODELchunk+filenameMODELAPPLICATIONchunkCompressed_U
         outNameBase=pathmodel+MODELroot_U+application_period ; +month.dat
         prepareData,0,inName,outNameBase,runToCorrect+'_',vname_model_U,YEAR_START,YEAR_STOP,month,NUMLANDPOINTS,land,multf_model_wind
      ENDIF
;
; compare files for the case of latlon format
      IF (FORMAT_APPLICATION EQ 1) THEN BEGIN
         YEAR_START=APPLICATION_PERIOD_START
         YEAR_STOP=APPLICATION_PERIOD_STOP
         inName=pathMODELchunk+filenameMODELAPPLICATIONchunkLatlon_U
         outNameBase=pathmodel+MODELroot_U+application_period ; +month.dat
         prepareData,1,inName,outNameBase,runToCorrect+'_',vname_model_U,YEAR_START,YEAR_STOP,month,NUMLANDPOINTS,land,multf_model_wind
      ENDIF
;
; compare files for the case of finished idl files (do nothing whatsoever)
      IF (FORMAT_APPLICATION EQ 2) THEN BEGIN
         print,'data is already prepared.'
      ENDIF
                                ;+++++ begin interpolate to standard calendar +++++
      YEAR_START=APPLICATION_PERIOD_START
      YEAR_STOP=APPLICATION_PERIOD_STOP
      outNameBase=pathmodel+MODELroot_U+application_period ; +month.dat
      adapt_calendar, CALENDAR, outNameBase, runToCorrect, month, YEAR_START, YEAR_STOP
                                ;+++++ end interpolate to standard calendar +++++
   ENDIF
;+++++ V +++++
; prepare files for the case of compressed WFD format
   IF (wind_apply EQ 1) THEN BEGIN
      IF (FORMAT_APPLICATION EQ 0) THEN BEGIN
         YEAR_START=APPLICATION_PERIOD_START
         YEAR_STOP=APPLICATION_PERIOD_STOP
         inName=pathMODELchunk+filenameMODELAPPLICATIONchunkCompressed_V
         outNameBase=pathmodel+MODELroot_V+application_period ; +month.dat
         prepareData,0,inName,outNameBase,runToCorrect+'_',vname_model_V,YEAR_START,YEAR_STOP,month,NUMLANDPOINTS,land,multf_model_wind
      ENDIF
;
; compare files for the case of latlon format
      IF (FORMAT_APPLICATION EQ 1) THEN BEGIN
         YEAR_START=APPLICATION_PERIOD_START
         YEAR_STOP=APPLICATION_PERIOD_STOP
         inName=pathMODELchunk+filenameMODELAPPLICATIONchunkLatlon_V
         outNameBase=pathmodel+MODELroot_V+application_period ; +month.dat
         prepareData,1,inName,outNameBase,runToCorrect+'_',vname_model_V,YEAR_START,YEAR_STOP,month,NUMLANDPOINTS,land,multf_model_wind
      ENDIF
;
; compare files for the case of finished idl files (do nothing whatsoever)
      IF (FORMAT_APPLICATION EQ 2) THEN BEGIN
         print,'data is already prepared.'
      ENDIF
                                ;+++++ begin interpolate to standard calendar +++++
      YEAR_START=APPLICATION_PERIOD_START
      YEAR_STOP=APPLICATION_PERIOD_STOP
      outNameBase=pathmodel+MODELroot_V+application_period ; +month.dat
      adapt_calendar, CALENDAR, outNameBase, runToCorrect, month, YEAR_START, YEAR_STOP
                                ;+++++ end interpolate to standard calendar +++++
   ENDIF

; prepare files for the case of compressed WFD format
   IF (rhs_apply EQ 1) THEN BEGIN
      IF (FORMAT_APPLICATION EQ 0) THEN BEGIN
         YEAR_START=APPLICATION_PERIOD_START
         YEAR_STOP=APPLICATION_PERIOD_STOP

         inName=pathMODELchunk+filenameMODELAPPLICATIONchunkCompressed_rhs
         outNameBase=pathmodel+MODELroot_rhs+application_period ; +month.dat
         prepareData,0,inName,outNameBase,runToCorrect+'_',vname_model_rhs,YEAR_START,YEAR_STOP,month,NUMLANDPOINTS,land,multf_model_rhs
      ENDIF
;
; compare files for the case of latlon format
      IF (FORMAT_APPLICATION EQ 1) THEN BEGIN
         YEAR_START=APPLICATION_PERIOD_START
         YEAR_STOP=APPLICATION_PERIOD_STOP

         inName=pathMODELchunk+filenameMODELAPPLICATIONchunkLatlon_rhs
         outNameBase=pathmodel+MODELroot_rhs+application_period ; +month.dat
         prepareData,1,inName,outNameBase,runToCorrect+'_',vname_model_rhs,YEAR_START,YEAR_STOP,month,NUMLANDPOINTS,land,multf_model_rhs
      ENDIF
;
; compare files for the case of finished idl files (do nothing whatsoever)
      IF (FORMAT_APPLICATION EQ 2) THEN BEGIN
         print,'data is already prepared.'
      ENDIF
                                ;+++++++++++++++++++++++++++++++++++++ begin interpolate to standard calendar ++++++++++++++++++++++++
      YEAR_START=APPLICATION_PERIOD_START
      YEAR_STOP=APPLICATION_PERIOD_STOP
      outNameBase=pathmodel+MODELroot_rhs+application_period ; +month.dat
      adapt_calendar, CALENDAR, outNameBase, runToCorrect, month, YEAR_START, YEAR_STOP

   ENDIF
                                ;+++++++++++++++++++++++++++++++++++++ end interpolate to standard calendar ++++++++++++++++++++++++
ENDIF
END
