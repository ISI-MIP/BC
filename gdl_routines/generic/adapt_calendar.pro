PRO adapt_calendar, switcher, outNameBase, runToCorrect, month, year_1, year_2

  monread=12

  IF (switcher EQ 0) THEN BEGIN ; standard calendar used
     print,'standard calendar already used'
  ENDIF

  IF (switcher EQ 1) THEN BEGIN ; calendar 365-days used
     print,'calendar 365-days used, interpolate to standard calendar'

; ++++++++++++++++++ only February needs to be changed +++++++++++++++++++
; adays = 0
; for y=0,(nyear-1) do begin
;   nd=julday(month(1)+1,1,yr+y)-julday(month(1),1,yr+y)
;   IF (nd eq 29) THEN BEGIN
;   adays=adays+1
;   ENDIF
; endfor

  ENDIF


  IF (switcher EQ 2) THEN BEGIN ; calendar 360-days used
     print,'calendar 360-days used, interpolate to standard calendar'


  ENDIF


;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;++++++++++++++++++++++++++++++++++++ adapt calendar +++++++++++++++++++++++
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


  IF (switcher EQ 1) THEN BEGIN ; calendar 365-days used

     yr=year_1
     nyear=1L*(year_2)-1L*(year_1)+1
     l_standard = intarr(12)
     for mon=0,(n_elements(month)-1) do begin
        nds=0
        for y=0,(nyear-1) do begin
           IF ( month(mon) EQ 12 ) THEN BEGIN
              nds=31+nds
           ENDIF ELSE BEGIN
              nds=julday(month(mon)+1,1,yr+y)-julday(month(mon),1,yr+y)+nds
           ENDELSE
        endfor
        l_standard(mon)=nds
     endfor
                                ; print, l_standard

     mon = 1                    ; February


     idldata = 0
     idldata_p = 0
     idldata_c = 0

                                ;++++++++++ restore files for March and February ++++++++++

     outF_p=outNameBase+'_'+month(mon+1)+'_'+runToCorrect+'_test.dat'
     cmrestore, outF_p

     if ((mon+1) ne monread) then begin
        print,'error restoring',outF_p
        stop
     endif

     idldata_p = idldata
                                ; print, n_elements(idldata(0,*))

     outF=outNameBase+'_'+month(mon)+'_'+runToCorrect+'_test.dat'

     print, outF

     cmrestore, outF

     if (mon ne monread) then begin
        print,'error restoring',outF
        stop
     endif

     idldata_c = idldata

                                ; print, n_elements(idldata(0,*))

     n = n_elements(idldata_c(*,0))

                                ;++++++++++ initialize new data array with number of days according to standard calendar

     idldata=fltarr(n,l_standard(mon))

                                ;++++++++++ insert days, February 29th as linear interpolation of February 28th and March 1st

     iday = 0
     iday_2 = 0
     for y=0,(nyear-1) do begin
        IF ( month(mon) EQ 12 ) THEN BEGIN
           nd=31
        ENDIF ELSE BEGIN
           nd=julday(month(mon)+1,1,yr+y)-julday(month(mon),1,yr+y)
        ENDELSE
                                ; print, iday,(iday+nd-2),iday+nd-1,iday_2,(iday_2+nd-2)

        IF (nd eq 28) THEN BEGIN
           idldata(*,iday:(iday+nd-1)) = idldata_c(*,iday_2:(iday_2+nd-1))
           iday = iday+nd
           iday_2 = iday_2+nd
        ENDIF

        IF (nd eq 29) THEN BEGIN
           idldata(*,iday:(iday+nd-2)) = idldata_c(*,iday_2:(iday_2+nd-2))
           idldata(*,iday+nd-1) = 0.5*(idldata_c(*,(iday_2+nd-2)) + idldata_p(*,(y*31.0)))
           iday = iday+nd
           iday_2 = iday_2+nd-1
        ENDIF

     endfor

     print,' minimum original',min(idldata_c),' maximum original',max(idldata_c)
     print,' minimum standard',min(idldata),' maximum standard',max(idldata)

     cmsave,idldata,monread,filename=outF

  ENDIF




  IF (switcher EQ 2) THEN BEGIN ; calendar 360-days used

     yr=year_1
     nyear=1L*(year_2)-1L*(year_1)+1
     l_standard = intarr(12)
     for mon=0,(n_elements(month)-1) do begin
        nds=0
        for y=0,(nyear-1) do begin
           IF ( month(mon) EQ 12 ) THEN BEGIN
              nds=31+nds
           ENDIF ELSE BEGIN
              nds=julday(month(mon)+1,1,yr+y)-julday(month(mon),1,yr+y)+nds
           ENDELSE
        endfor
        l_standard(mon)=nds
     endfor


     ml31 = [0,4,6,7,9,11]      ; Jan, May, Jul, Aug, Oct, Dec

     for mon=0,(n_elements(ml31)-1) do begin

        idldata = 0
        idldata_c = 0

                                ;++++++++++ restore files for month with 31 days in standard calendar ++++++++++

        outF=outNameBase+'_'+month(ml31(mon))+'_'+runToCorrect+'_test.dat'

        print, outF

        cmrestore, outF
        if (ml31(mon) ne monread) then begin
           print,'error restoring',outF
        endif

        idldata_c = idldata

        n = n_elements(idldata_c(*,0))

        print, n

                                ;++++++++++ initialize new data array with number of days according to standard calendar

        idldata=fltarr(n,l_standard(ml31(mon)))

        iday = 0
        iday_2 = 0
        for y=0,(nyear-1) do begin
           nd=31

           idldata(*,iday:(iday+nd-2)) = idldata_c(*,iday_2:(iday_2+nd-2))
           idldata(*,iday+nd-1) = idldata_c(*,(iday_2+nd-2))
           idldata(*,(iday+nd-2)) = 0.5*(idldata(*,(iday+nd-3))+idldata(*,(iday+nd-1)))
           iday = iday+nd
           iday_2 = iday_2+nd-1

        endfor

        print,' minimum original',min(idldata_c),' maximum original',max(idldata_c)
        print,' minimum standard',min(idldata),' maximum standard',max(idldata)

        cmsave, idldata,monread,filename=outF

     endfor


                                ;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

     mon = 2                    ; Mar

; print,'March'

     idldata = 0
     idldata_m = 0
     idldata_c = 0

                                ;++++++++++ restore files ++++++++++

     outF_m=outNameBase+'_'+month(mon-1)+'_'+runToCorrect+'_test.dat' ; February
     cmrestore, outF_m

     if ((mon-1) ne monread) then begin
        print,'error restoring',outF_m
        stop
     endif

     idldata_m = idldata
                                ; print, n_elements(idldata(0,*))

     outF=outNameBase+'_'+month(mon)+'_'+runToCorrect+'_test.dat'

     print, outF_m, ' and ', outF

     cmrestore, outF
     if (mon ne monread) then begin
        print,'error restoring',outF
        stop
     endif

     idldata_c = idldata

                                ; print, n_elements(idldata(0,*))

     n = n_elements(idldata_c(*,0))

     print, n

                                ;++++++++++ initialize new data array with number of days according to standard calendar

     idldata=fltarr(n,l_standard(mon))

                                ;++++++++++ take Feb 30th as Mar 1th and shift entries accordingly
     iday = 0
     iday_2 = 0
     nd=31
     for y=0,(nyear-1) do begin

        idldata(*,iday+1:(iday+nd-1)) = idldata_c(*,iday_2:(iday_2+nd-2))
        idldata(*,iday) = idldata_m(*,((y+1)*30.0)-1)
        iday = iday+nd
        iday_2 = iday_2+nd-1

     endfor

     print,' minimum original',min(idldata_c),' maximum original',max(idldata_c)
     print,' minimum standard',min(idldata),' maximum standard',max(idldata)

     cmsave, idldata,monread, filename=outF

                                ;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

     mon = 1                    ; Feb

     idldata = 0
     idldata_c = 0

                                ;++++++++++ restore files ++++++++++

     outF=outNameBase+'_'+month(mon)+'_'+runToCorrect+'_test.dat'

     print, outF

     cmrestore, outF
     if (mon ne monread) then begin
        print,'error restoring',outF
        stop
     endif

     idldata_c = idldata

                                ; print, n_elements(idldata(0,*))

     n = n_elements(idldata_c(*,0))

     print, n

                                ;++++++++++ initialize new data array with number of days according to standard calendar

     idldata=fltarr(n,l_standard(mon))

                                ;++++++++++ join Feb 29th and Feb 28th if there is no 29th

     iday = 0
     iday_2 = 0
     for y=0,(nyear-1) do begin
        IF ( month(mon) EQ 12 ) THEN BEGIN
           nd=31
        ENDIF ELSE BEGIN
           nd=julday(month(mon)+1,1,yr+y)-julday(month(mon),1,yr+y)
        ENDELSE
                                ; print, iday,(iday+nd-2),iday+nd-1,iday_2,(iday_2+nd-2)

        IF (nd eq 28) THEN BEGIN

           idldata(*,iday:(iday+nd-2)) = idldata_c(*,iday_2:(iday_2+nd-2))
           idldata(*,(iday+nd-1)) =  0.5*(idldata_c(*,(iday_2+nd-1))+idldata_c(*,(iday_2+nd)))

           iday = iday+nd
           iday_2 = iday_2+nd+2

        ENDIF

        IF (nd eq 29) THEN BEGIN

           idldata(*,iday:(iday+nd-1)) = idldata_c(*,iday_2:(iday_2+nd-1))

           iday = iday+nd
           iday_2 = iday_2+nd+1

        ENDIF

     endfor

     print,' minimum original',min(idldata_c),' maximum original',max(idldata_c)
     print,' minimum standard',min(idldata),' maximum standard',max(idldata)

     cmsave, idldata,monread, filename=outF


  ENDIF


end
