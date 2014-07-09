;;THIS IDL FILE CONVERTS A BIAS CORRECTED IDL SAVED FILE TO A LATLON
;;NETCDF FILE OR COMPRESSED WFD NETCDF FILE.
;;
;; WORK BLOCK LEADER: S. HAGEMANN
;;
;;
;;
;;
;; FILENAME: idl2latlon_v1.pro
;; AUTHORS:  C. PIANI AND J. O. HAERTER
;; DATE:     NOVEMBER 18, 2009
;; PROJECT:  EU WATCH PROJECT
;; REQUIRES: definitions.pro, definitions_internal.pro, create1dNCDF.pro, createNCDF_v2.pro
;;
;;
;; __________________________________________________________________
;;
;;
;
IF (OUTPUT_DATAFORMAT_2D EQ 1 OR OUTPUT_DATAFORMAT_1D EQ 1) THEN BEGIN
;

   IF (T_Correct EQ 1 and P_Correct EQ 1) THEN types=['pr_BCed_','T_BCed_']
   IF (T_Correct EQ 1 and P_Correct EQ 0) THEN types=['T_BCed_']
   IF (T_Correct EQ 0 and P_Correct EQ 1) THEN types=['pr_BCed_']

   IF (vname_model_prsn EQ '' AND vname_model_Tmin ne '' AND vname_model_Tmax ne '') THEN BEGIN
      IF (T_Correct EQ 1 and P_Correct EQ 1) THEN types=['pr_BCed_','T_BCed_','Tmax_BCed_','Tmin_BCed_']
      IF (T_Correct EQ 1 and P_Correct EQ 0) THEN types=['T_BCed_','Tmax_BCed_','Tmin_BCed_']
      IF (T_Correct EQ 0 and P_Correct EQ 1) THEN types=['pr_BCed_']
   ENDIF
   IF (vname_model_prsn ne '' AND vname_model_Tmin EQ '' AND vname_model_Tmax EQ '') THEN BEGIN
      IF (T_Correct EQ 1 and P_Correct EQ 1) THEN types=['pr_BCed_','pr_PRSN_BCed_','T_BCed_']
      IF (T_Correct EQ 1 and P_Correct EQ 0) THEN types=['T_BCed_']
      IF (T_Correct EQ 0 and P_Correct EQ 1) THEN types=['pr_BCed_','pr_PRSN_BCed_']
   ENDIF
   IF (vname_model_prsn ne '' AND vname_model_Tmin ne '' AND vname_model_Tmax ne '') THEN BEGIN
      IF (T_Correct EQ 1 and P_Correct EQ 1) THEN types=['pr_BCed_','pr_PRSN_BCed_','T_BCed_','Tmax_BCed_','Tmin_BCed_']
      IF (T_Correct EQ 1 and P_Correct EQ 0) THEN types=['T_BCed_','Tmax_BCed_','Tmin_BCed_']
      IF (T_Correct EQ 0 and P_Correct EQ 1) THEN types=['pr_BCed_','pr_PRSN_BCed_']
   ENDIF


; types=['pr_PRSN_BCed_']

;
;
;the main loop over the types to be output
   FOR typ=0,(n_elements(types)-1) DO BEGIN
; the main loop over all months
      FOR mon=0,(n_elements(month)-1) DO BEGIN
         monread=12
; model data has now been read and the 2d array is set to zero.
;*******************************************************************
; loading the data for the model data to be corrected.
         pfile=pathmodel+types(typ)+derivation_period+'_'+application_period+'_'+month(mon)+'_'+run+'test.dat'

; specify the output file containing the netcdf data.
         outfile=pathmodel+types(typ)+derivation_period+'_'+application_period+'_'+month(mon)+'_'+run+'test.nc'

; specify the output file containing the compressed netcdf data.
         outfileCompressed=pathmodel+'COMPRESSED_'+types(typ)+derivation_period+'_'+application_period+'_'+month(mon)+'_'+run+'test.nc'

         print,'test outfile for existence : '+outfile
         test = FILE_TEST(outfile)
         IF (test) THEN BEGIN
            print,'already present. continue...'
            CONTINUE
         ENDIF ELSE BEGIN

            cmrestore,pfile
;if (mon ne monread) THEN BEGIN
;  print,'error restoring',pfile
;  stop
;ENDIF
;
            print,'done restoring corrected data: '+derivation_period+'-> '+application_period+'.'
;
;
            IF (types(typ) EQ 'pr_BCed_') THEN BEGIN
               l=n_elements(pr_c(0,*))
               datarr=pr_c
               header=['precip','mm/s','total precipitation','total model precipitation']
               DELVAR,pr_c
            ENDIF
            IF (types(typ) EQ 'pr_PRSN_BCed_') THEN BEGIN
               l=n_elements(pr_c_snow(0,*))
               datarr=pr_c_snow
               header=['snow','mm/s','snow precipitation','model snow precipitation']
               DELVAR,pr_c_snow
            ENDIF
            IF (types(typ) EQ 'T_BCed_') THEN BEGIN
               l=n_elements(tas_c(0,*))
               datarr=tas_c
               header=['temp2','Kelvin','mean daily temperature','model temperature']
               DELVAR,tas_c
            ENDIF
            IF (types(typ) EQ 'Tmin_BCed_') THEN BEGIN
               l=n_elements(tmin_c(0,*))
               datarr=tmin_c
               header=['Tmin','Kelvin','min. daily temperature','model min. temperature']
               DELVAR,tmin_c
            ENDIF
            IF (types(typ) EQ 'Tmax_BCed_') THEN BEGIN
               l=n_elements(tmax_c(0,*))
               datarr=tmax_c
               header=['Tmax','Kelvin','max. daily temperature','model max. temperature']
               DELVAR,tmax_c
            ENDIF
;
            print,'done restoring idl data: '+pfile
;******************************************************************
; the total number of days to be written to netcdf format.
            ndays=n_elements(datarr(1,*))

            print, 'ndays = ', ndays

; The data array required for passing the data to the createNCDF subroutine.
            data = FLTARR(ndays,nyy,nxx) ;FLTARR(ndays,360,720)
            data = data*0.0-9999.0

; total number of land points.
            nlandpoints=n_elements(datarr(*,1))

; some conversion to lat-lon coordinates
            lon0=-179.75
            lat0=89.75
            FOR i=0L,NUMLANDPOINTS-1 DO BEGIN
               nlon=(lon(i)-lon0)/0.5
               nlat=(lat0-lat(i))/0.5
               FOR t=0,ndays-1 DO BEGIN
                  data(t,nlat,nlon)=datarr(i,t)
               ENDFOR
            ENDFOR
;
; write data to a 2D netcdf file.
            IF (OUTPUT_DATAFORMAT_2D EQ 1) THEN BEGIN
               print,createNCDF_v2(nxx,nyy,APPLICATION_PERIOD_START,1L*(APPLICATION_PERIOD_STOP)-1L*(APPLICATION_PERIOD_START)+1,month(1L*mon),ndays,data,outfile,header)
            ENDIF
;
; write the data to the compressed WFD format.
            IF (OUTPUT_DATAFORMAT_1D EQ 1) THEN BEGIN
               print,create1dNCDF(NUMLANDPOINTS,nxx,nyy,navlon,navlat,APPLICATION_PERIOD_START,1L*(APPLICATION_PERIOD_STOP)-1L*(APPLICATION_PERIOD_START)+1,month(1L*mon),ndays,datarr,outfileCompressed,header)
            ENDIF
;
         ENDELSE
      ENDFOR                    ; MONTH FOR LOOP ENDS
;
      IF (n_elements(month) EQ 12) THEN BEGIN
         print,'merge monthly data...'
         IF (OUTPUT_DATAFORMAT_2D EQ 1) THEN BEGIN
            outfileFinal=pathFinalData+types(typ)+derivation_period+'_'+application_period+'_'+run+'test.nc'
            print,'test outfileFinal for existence : '+outfileFinal
            test = FILE_TEST(outfileFinal)
            IF (test) THEN BEGIN
               print,outfileFinal+' already present. continue...'
            ENDIF ELSE BEGIN
               print,' not present. merge monthly files...'
               outfileAll=pathmodel+types(typ)+derivation_period+'_'+application_period+'_'+month+'_'+run+'test.nc'
               spawn,'cdo -O mergetime '+outfileAll(0)+' '+outfileAll(1)+' '+outfileAll(2)+' '+outfileAll(3)+' '+outfileAll(4)+' '+outfileAll(5)+' '+outfileAll(6)+' '+outfileAll(7)+' '+outfileAll(8)+' '+outfileAll(9)+' '+outfileAll(10)+' '+outfileAll(11)+' '+outfileFinal
            ENDELSE
         ENDIF
;
         IF (OUTPUT_DATAFORMAT_1D EQ 1) THEN BEGIN
            outfileFinal=pathFinalData+'COMPRESSED_'+types(typ)+derivation_period+'_'+application_period+'_'+run+'test.nc'
            print,'test outfileFinal for existence : '+outfileFinal
            test = FILE_TEST(outfileFinal)
            IF (test) THEN BEGIN
               print,outfileFinal+' already present. continue...'
            ENDIF ELSE BEGIN
               print,' not present. merge monthly files...'
               outfileAll=pathmodel+'COMPRESSED_'+types(typ)+derivation_period+'_'+application_period+'_'+month+'_'+run+'test.nc'
               spawn,'cdo -O mergetime '+outfileAll(0)+' '+outfileAll(1)+' '+outfileAll(2)+' '+outfileAll(3)+' '+outfileAll(4)+' '+outfileAll(5)+' '+outfileAll(6)+' '+outfileAll(7)+' '+outfileAll(8)+' '+outfileAll(9)+' '+outfileAll(10)+' '+outfileAll(11)+' '+outfileFinal
            ENDELSE
         ENDIF
      ENDIF
   ENDFOR                       ; TYPES FOR LOOP ENDS
ENDIF                           ; END OF PRIMARY IF LOOP
END                             ; PROGRAM ENDS.
