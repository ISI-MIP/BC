PRO prepareData, switcher, inFile, outFile, runToCorrect, varnm, year_1, year_2, month, numlp,land,multf
; switcher determines the file type of the original data,
; (0=compressed WFD; 1=latlon)
; inFile is file name of original file
; outFile is file name of output file
; varnm is the name of the variable to be read, e.g. 'aprl', 'temp2',
; 't2min'
; year_1 is the start year, year_2 is the stop year of the data to be
; read
; month is the month to select
; multf is an optional multfactor that can convert rain e.g. from mm/s to mm/d
; numl is the number of land points
;
;multf=1.0

  CP0 = 0

  date1=year_1+'-01-01'
  date2=year_2+'-12-31'

  dummy='dummy_'+varnm
  dummy1='dummy1_'+varnm

  print,'cdo selyear,'+year_1+'/'+year_2+' '+inFile+' '+dummy
  spawn,'cdo selyear,'+year_1+'/'+year_2+' '+inFile+' '+dummy,result,EXIT_STATUS

  count_processed,EXIT_STATUS,CP0 ; check in cdo output if variable was processed

  IF (CP0 EQ 0) THEN BEGIN

     print,'cdo failed'
     exit

  ENDIF

  IF (CP0 NE 0) THEN BEGIN

                                ; convert a compressed wfd file for the period year_1 to year_2 to 12
                                ; idl saved files for the same period for all months of the year. get
                                ; the original data from inFile and store the final data in outFile.
                                ; dummy now has a chunk for data for the period from date1 to date2

     FOR mon=0,(n_elements(month)-1) DO BEGIN
                                ;spawn,'cdo selmon,'+month(mon)+' dummy_'+varnm' dummy1_'+varnm,result

        CP = 0
        counter = 0
        WHILE (CP EQ 0 AND counter LT 10) DO BEGIN

           print,'cdo -f nc selmon,'+month(mon)+' '+dummy+' '+dummy1
           spawn,'cdo -f nc selmon,'+month(mon)+' '+dummy+' '+dummy1,result1,EXIT_STATUS1

           print,result1
           print,'repeated ', counter, ' times'
           count_processed,EXIT_STATUS1,CP ; check in cdo output if variable was processed

           counter = counter + 1

        ENDWHILE

        IF (CP EQ 0) THEN BEGIN

           print,'cdo failed'
           exit

        ENDIF

        IF (CP NE 0) THEN BEGIN

           outF=outFile+'_'+month(mon)+'_'+runToCorrect+'test.dat'
           IF (switcher EQ 0) THEN BEGIN ; the file comes as a compressed netcdf
              print,ncdf2idl(dummy1,outF,1,varnm,multf,numlp,land,mon)
           ENDIF

           IF (switcher EQ 1) THEN BEGIN ; the file comes as a lat lon netcdf
              print,ncdf2idl(dummy1,outF,0,varnm,multf,numlp,land,mon)
           ENDIF

        ENDIF

        spawn,'rm '+dummy1

     ENDFOR

  ENDIF
  spawn,'rm '+dummy

end
