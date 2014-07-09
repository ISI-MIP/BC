;;
;
IF (OUTPUT_DATAFORMAT_2D EQ 1 OR OUTPUT_DATAFORMAT_1D EQ 1) THEN BEGIN
;


   r2c = [ps_Correct, SW_Correct, LW_Correct, huss_Correct, wind_correct, wind_correct, wind_correct, rhs_correct]

   types_tmp = ['ps_BCed_','sw_BCed_','lw_BCed_','huss_BCed_','U_BCed_','V_BCed_','wind_BCed_','rhs']

   wc = where(r2c eq 1)

   types = types_tmp(wc)

;types = ['ps_BCed_','SW_BCed_','LW_BCed_','huss_BCed_','U_BCed_','V_BCed_']

   monread = 12
;
;the main loop over the types to be output
   for typ=0,(n_elements(types)-1) do begin
; the main loop over all months
      for mon=0,(n_elements(month)-1) do begin
; model data has now been read and the 2d array is set to zero.
;*******************************************************************
; loading the data for the model data to be corrected.
         IF (types(typ) eq 'rhs') THEN BEGIN
            derivation_period=''
            TAG='_'
         ENDIF ELSE BEGIN
            TAG=''
         ENDELSE
         pfile=pathmodel+types(typ)+derivation_period+'_'+application_period+'_'+month(mon)+'_'+run+tag+'test.dat'
                                ; specify the output file containing the netcdf data.
         outfile=pathmodel+types(typ)+derivation_period+'_'+application_period+'_'+month(mon)+'_'+run+'test.nc'
                                ; specify the output file containing the compressed netcdf data.
         outfileCompressed=pathmodel+'COMPRESSED_'+types(typ)+derivation_period+'_'+application_period+'_'+month(mon)+'_'+run+'test.nc'
         print,'test outfile for existence : '+outfile
         test = FILE_TEST(outfile)
         IF (test) THEN BEGIN
            print,'...already present. continue...'
            CONTINUE
         ENDIF ELSE BEGIN
            cmrestore,pfile
            if (mon ne monread) then begin
               print,'error restoring', pfile
               stop
            endif
;
            print,'done restoring corrected data: '+derivation_period+'-> '+application_period+'.'
;
;
            if (types(typ) eq 'ps_BCed_') then begin
               l=n_elements(pr_c(0,*))
               datarr=pr_c
               header=['pres','Pa','surface pressure','model surface pressure']
            endif
            if (types(typ) eq 'sw_BCed_') then begin
               l=n_elements(pr_c(0,*))
               datarr=pr_c
               header=['rsds','W/m^2','surface downwelling shortwave radiation','model surface downwelling shortwave radiation']
            endif
            if (types(typ) eq 'lw_BCed_') then begin
               l=n_elements(pr_c(0,*))
               datarr=pr_c
               header=['rlds','W/m^2','surface downwelling longwave radiation','model surface downwelling longwave radiation']
            endif
            if (types(typ) eq 'huss_BCed_') then begin
               l=n_elements(pr_c(0,*))
               datarr=pr_c
               header=['huss','1','specific humidity','model specific humidity']
            endif
            if (types(typ) eq 'U_BCed_') then begin
               l=n_elements(pr_c(0,*))
               datarr=pr_c
               header=['U','m/s','Eastwards wind speed','model eastwards wind speedy']
            endif
            if (types(typ) eq 'V_BCed_') then begin
               l=n_elements(pr_c(0,*))
               datarr=pr_c
               header=['V','m/s','Northwards wind speed','model northwards wind speedy']
            endif
            if (types(typ) eq 'wind_BCed_') then begin
               l=n_elements(pr_c(0,*))
               datarr=pr_c
               header=['wind','m/s','Total horizontal wind speed','model horizontal wind speedy']
            endif
            if (types(typ) eq 'rhs') then begin
               l=n_elements(idldata(0,*))
               datarr=idldata
               header=['rhs','%','Near-Surface Relative Humidity','model relative humidity']
            endif
            DELVAR, pr_c, idldata
;
            print,'done restoring idl data: '+pfile
;******************************************************************
; the total number of days to be written to netcdf format.
            ndays=n_elements(datarr(1,*))

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
;
      endfor                    ; MONTH FOR LOOP ENDS
;
      if (n_elements(month) eq 12) then begin
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
      endif
;
   endfor                       ; TYPES FOR LOOP ENDS
endif                           ; END OF PRIMARY IF LOOP
end                             ; PROGRAM ENDS.
