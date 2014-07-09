;; ISI-MIP bias correction code, based on algorithm used in WATCH
;; project (by Piani and Hearter)
;;
;;THIS IDL FILE CONTAINS THE PROCEDURES REQUIRED
;;FOR THE APPLICATION OF THE CORRECTED TIME SERIES
;;
;; requires: definitions.pro, definitions_internal.pro, functions.pro
;;
; Applies interpolated monthly bias correction factors for temperature
; to the given application period.
;______________________________________________________________
;
close,3

monread=12

mr_thresh = 10.                 ;
abs_thresh = 400./86400.        ;

exponent_cut = 1e32   ; exponent T0 allowed for full exponential fit ; for full linear fit T0 is set to 1e33 ; in WATCH rules this was 50

dorestore=1

if(dorestore) then begin
   openw,3,'log_apply_P_cor.txt'

                                ;
                                ; restore the current month correction factors
   restorefile1 = outputdir+'pr_cor_'+derivation_period+'_'+month(mon)+'_'+run+'_test.dat'
   cmrestore,restorefile1
   if( mon ne monread) then begin
      print,'error restoring',restorefile1
      stop
   endif

                                ;
   A0=a_pr
   B0=b_pr
   T0=tau_pr
   X00=x0_pr
   rat0=meanratio
   s0_e=s_e                     ; threshold dry days
   s0_e2=s_e2                   ; threshold outlier
   s0_m=s_m                     ; threshold dry months
                                ;

   s0_e(where(s0_e lt 0))=0.0
   s0_m(where(s0_m lt 0))=0.0


   print,'done restoring BC params: pr_cor_'+derivation_period+'_'+month(mon) ;*********
                                ;*******************************************************************
                                ; loading the data for the model data to be corrected.
   pfile=pathmodel+MODELroot+application_period+'_'+month(mon)+'_'+run+'_test.dat'
   print,'restoring ' + pfile
   cmrestore,pfile
   if (mon ne monread) then begin
      print,'error restoring',pfile
      stop
   endif
                                ;
   l=n_elements(idldata(0,*))
   pr_c=idldata
   pr_total=idldata
                                ;

   pr_c_prsn=idldata*0.0
   IF (vname_model_prsn ne '') THEN BEGIN
                                ; loading the data for the model snowfall data, this is important so
                                ; that the original snow/total_precip ratio can be preserved.
      pfile=pathmodel+MODELroot_PRSN+application_period+'_'+month(mon)+'_'+run+'_test.dat'
      print,'restoring ' + pfile
      monread=12
      cmrestore,pfile
      if ( mon ne monread ) then begin
         print,'error restoring',pfile
         stop
      endif
                                ;
      pr_c_prsn=idldata
   ENDIF
                                ;
                                ; below 0.001 mm/d we do not attempt to separate snow and rain as this
                                ; is rediculous. Also, we need to avoid producing singularities.
                                ;threshold=0.001/86400.0

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;;;; initialize snowratio ;;;;;;;;;;
  ;;;; used to correct snow ;;;;;;;;;;
  ;;;; based on total precip ;;;;;;;;;
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
   snow_total_ratio=pr_c*0.0

                                ;
   print,'done restoring model: '+pfile

                                ;******************************************************************
   print,'Checking consistency of input data ...'
   IF (min(pr_c) LT -1e-10 OR min(pr_c_prsn) LT -1e-10) THEN BEGIN
      print,'Model has negative precipitation: Exiting.'
      STOP
   ENDIF
                                ;

endif

meanthismonth_e = 0.0*meanratio
meanthismonth_c = 0.0*meanratio
meanthismonth_wet = 0.0*meanratio
s_dry = 0.0*meanratio
mr = 0.0*meanratio

                                ;
yr=APPLICATION_PERIOD_START
nyear=1L*(APPLICATION_PERIOD_STOP)-1L*(APPLICATION_PERIOD_START)+1
ind     = 0                     ; a counter for the days
ind_mon = 0
                                ;
                                ; assign the time values.
FOR y=0,nyear-1 DO BEGIN
   IF ( month(mon) EQ 12 ) THEN BEGIN
      nd=31
   ENDIF ELSE BEGIN
      nd=julday(month(mon)+1,1,yr+y)-julday(month(mon),1,yr+y)
   ENDELSE
   daysthismonth = ind+findgen(nd)

   print,y

   for iday=0,nd-1 do begin
      pr_e_day=reform(pr_total(*,ind))*86400.0

;      d=-0.5+(iday*1.0/nd)
                                ;
                                ; Weighting factors for the previous month (dm1), the current month
                                ; (d0) and the following month (dp1) are evaluated, such that for the
                                ; first (last) day of the month the correction factors of the previous
                                ; (following) month are equally weighted , i.e. dm1=d0=0.5
                                ; (dp1=d0=0.5), and for the days in the middle of the month d0=1,
                                ; dp1=dm1=0.
                                ;
;        dm1=(abs(d)-d)*0.5
;        d0=1-abs(d)
;        dp1=(d+abs(d))*0.5

                                ;START space LOOP over all land points
      for i=0L,NUMLANDPOINTS-1 do begin
         n=i
         ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                                ; interpolation of the mean ratio
                                ; between the different months
                                ; mr(n) = ratm1(n)*dm1  +  rat0(n)*d0 +  ratp1(n)*dp1
                                ; No interpolation!!!
         mr(n) = rat0(n)
                                ; truncate mean ratio to not blow up
                                ; values or avoid models from getting
                                ; wetter in the future if model and
                                ; observations diviate a lot in the
                                ; construction period
         if(mr(n) gt mr_thresh) then begin
            mr(n) = mr_thresh
         endif
         if(mr(n) lt 1.0/mr_thresh) then begin
            mr(n) = 1.0/mr_thresh
         endif
         ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
         ;;; do some calculations only at each first day of a month
         ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
         if (iday eq 0) then begin
                                ; wd_threshold indicates if a wet
                                ; month has no wet days and thus has
                                ; to be classified as dry although not
                                ; required by the monthly mean
                                ; threshold
            wd_threshold = 0
                                ; meanthismonth_e(n) is the monthly
                                ; mean of the uncorrected data used
                                ; for the classification into wet and
                                ; dry months
            meanthismonth_e(n) = mean(pr_total(n,daysthismonth)*86400.0)

           ;;;;;;;;;;;;; estimate amount of rain in dry days to be added
           ;;;;;;;;;;;;; at each wet day to preserve the monthly mean
            pr_thismonth = pr_total(n,daysthismonth)*86400.0 ; days of the current month
            w_wet = where(pr_thismonth gt s0_e(n))           ; indices of wet days of the current month
            if(n_elements(w_wet) eq 1) then begin
               if(w_wet eq -1) then begin       ;;;; no wet days ;;;
                  if(meanthismonth_e(n) gt s0_m(n)) then begin
                     print,'year ', y, ' grid ',n ,'warning: wet month, but no wet days left'
                     wd_threshold = 1
                                ;              stop
                  endif
                  l_wet = 0.0                            ; number of wet days
                  w_dry = where(pr_thismonth le s0_e(n)) ; indices of dry days of the current month
                  s_dry(n) = 0.0                         ; precipitation in dry days
                  meanthismonth_wet(n) = 0.0             ; mean of wet days
               endif
               if(w_wet gt -1) then begin                     ;;;; one wet day ;;;
                  l_wet = n_elements(w_wet)                   ; number of wet days
                  w_dry = where(pr_thismonth le s0_e(n))      ; indices of dry days of the current month
                  s_dry(n) = total(pr_thismonth(w_dry))/l_wet ; precipitation in dry days
                  meanthismonth_wet(n) = pr_thismonth(w_wet)  ; mean of wet days
               endif
            endif
            if(n_elements(w_wet) gt 1) then begin     ;;;; mutual wet days ;;;
               l_wet = n_elements(w_wet)              ; number of wet days
               w_dry = where(pr_thismonth le s0_e(n)) ; indices of dry days of the current month
               if(n_elements(w_dry) eq 1) then begin
                  if(w_dry eq -1) then begin                   ; no dry days
                     s_dry(n) = 0.0                            ; precipitation in dry days
                     meanthismonth_wet(n) = meanthismonth_e(n) ; mean of wet days
                  endif
                  if(w_dry gt -1) then begin                          ; one dry days
                     s_dry(n) = total(pr_thismonth(w_dry))/l_wet      ; precipitation in dry days
                     meanthismonth_wet(n) = mean(pr_thismonth(w_wet)) ; mean of wet days
                  endif
               endif
               if(n_elements(w_dry) gt 1) then begin               ; mutual dry days
                  s_dry(n) = total(pr_thismonth(w_dry))/l_wet      ; precipitation in dry days
                  meanthismonth_wet(n) = mean(pr_thismonth(w_wet)) ; mean of wet days
               endif
            endif
           ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
           ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
         endif

         ;;; calculate part of precipitation that is snow
         if (pr_e_day(n) gt s0_e(n)) then snow_total_ratio(n,ind) = (1.0*pr_c_prsn(n,ind))/(1.0*pr_total(n,ind))


                                ;***************************************
                                ; dry month
                                ;***************************************
                                ; if the monthly mean is below the
                                ; threshold for dry months estimated
                                ; from the 40 year longterm mean OR
                                ; all days are below the threshold for
                                ; dry days estimated from the 40 year
                                ; longterm mean

         if ((meanthismonth_e(n) le s0_m(n)) or (wd_threshold eq 1)) then begin
           ;;; do correction at each last day of a month
            if (iday eq (nd-1)) then begin
                                ;meanthismonth_c(n) = mean(pr_total(n,daysthismonth)*86400.0)
               pr_c(n,daysthismonth) = (pr_total(n,daysthismonth))*mr(n)
                                ; truncate unphysically high values
               overthresh = where(pr_c(n,daysthismonth) gt abs_thresh)
               if(overthresh(0) ne -1) then pr_c(n,daysthismonth(overthresh)) = abs_thresh
            endif
         endif

                                ;***************************************
                                ; wet month
                                ;***************************************

         if ((meanthismonth_e(n) gt s0_m(n)) and (wd_threshold ne 1)) then begin

         ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
         ;;;; set precipitation of dry days to zero and distribute the
         ;;;; contained rainfall to the other days
         ;;;; i.e. shifting the whole distribution (including the threshold for
         ;;;; outlier)
         ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

                                ;***************************************
                                ; set dry days
                                ;***************************************
            if (pr_e_day(n) le s0_e(n)) then p_c = 0

                                ;***************************************
                                ; correct wet days
                                ;***************************************
            if (pr_e_day(n) gt s0_e(n)) then begin
             ;;; normalise wet day (plus redistributed rain) by the
             ;;; mean over the wet months
               P=(pr_e_day(n)+s_dry(n))/(meanthismonth_wet(n)+s_dry(n))
                                ; linear fit
               IF (T0(n) EQ 1e33) THEN p_c=P*B0(n)+A0(n)
                                ; full exponential fit
               IF (T0(n) LT exponent_cut) THEN BEGIN
                  IF (P GE X00(n)) THEN p_c=( A0(n) + B0(n) * (P-X00(n)) ) * (   1-exp(  -(P-X00(n))/T0(n)  )  )
                  IF (P LT X00(n)) THEN p_c=0.0
                  IF (P LT 0) THEN print,3,'P = ',P
               ENDIF
               IF (T0(n) NE 1e33 && T0(n) GE exponent_cut) THEN BEGIN
                  print,'exponent to extreme'
                  STOP
               ENDIF


               if ( ( (T0(n) EQ 1e33) and (B0(n) EQ 1) and (A0(n) EQ 0) ) NE 1 ) then begin
                                ; avoid too extreme variability
                  if (p_c lt (extremes[n,0]-0.25*(extremes[n,1]-extremes[n,0]))) then p_c = extremes[n,0]-0.25*(extremes[n,1]-extremes[n,0])
                  if (p_c gt (extremes[n,1]+0.25*(extremes[n,1]-extremes[n,0]))) then p_c = extremes[n,1]+0.25*(extremes[n,1]-extremes[n,0])
               endif

               p_c=0.5*(p_c+abs(p_c)) ; this is putting all negative values to 0
            endif

                                ;**************************************************************
                                ; Now need to add all the info back in
                                ;**************************************************************
                                ;at the last day of the month
                                ;calculate monthly mean of the new
                                ;monthy precipitation and scale the
                                ;new precipitation to preserve the trend
            pr_c(n,ind)= p_c
            if (iday eq (nd-1)) then begin
               pr_thismonth = pr_total(n,daysthismonth)*86400.0 ; uncorrected days of the current month
               w_wet = where(pr_thismonth gt s0_e(n))           ; indices of the former wet days

               p_rd = pr_c(n,daysthismonth) ; corrected days of the current month
               p_rd2 = p_rd

             ;;; ensure that the monthly mean of the normalised data
             ;;; over the former wet days is still 1 after application of
             ;;; the transfer function
             ;;; additive (iteratively) if needed
             ;;; upto a precision of 1e-6

;;; two ways to ensure the mean is preserved
;;; version 1 - multiplicative
               p_rd2[w_wet] = p_rd[w_wet]/mean(p_rd[w_wet])
;;; version 2 - additive itatively
;             it = 0
;             while ((abs(1-mean(p_rd[w_wet])) gt 1e-6) AND (it lt 1500)) do begin
;               it = it + 1
;               m2 = 1-mean(p_rd[w_wet])
;               ww = where((p_rd[w_wet]+m2) ge 0)
;               tmp = w_wet[ww]
;               p_rd[tmp] = p_rd[tmp]+m2
;             endwhile
;             p_rd2[w_wet] = p_rd[w_wet]
;             if((abs(1-mean(p_rd[w_wet])) gt 1e-6)) then print,'year ', y , ' grid ', n ,'iteration',it,'mean',mean(p_rd[w_wet])



             ;;; calculate the full monthly mean after the correction
             ;;; if it is below the threshold for dry months do only
             ;;; the dry month correction
               meanthismonth_c(n) = mean(p_rd2*(meanthismonth_wet(n)+s_dry(n)))
               if (meanthismonth_c(n) le s0_m(n)) then pr_c(n,daysthismonth) = pr_total(n,daysthismonth)*mr(n)
               if (meanthismonth_c(n) gt s0_m(n)) then begin
                  pr_c(n,daysthismonth) = p_rd2*(meanthismonth_wet(n)+s_dry(n))*mr(n)/86400.0
               endif
                                ; truncate unphysically high values
               overthresh = where(pr_c(n,daysthismonth) gt abs_thresh)
               if(overthresh(0) ne -1) then pr_c(n,daysthismonth(overthresh)) = abs_thresh
            endif
         endif

      endfor
                                ;
                                ;print,'ind ',ind
      ind=ind+1
   endfor
ENDFOR


; printing information on the period completed.
print,'BC complete: construction decade ', derivation_period, ', application period: ', application_period, ', month ',month(mon)
;
pr_c_snow=snow_total_ratio*pr_c
;
; saving the corrected timeseries in the pathmodel folder
cmsave,filename=pathmodel+'pr_BCed_'+derivation_period+'_'+application_period+'_'+month(mon)+'_'+run+'test.dat',pr_c,monread
;
IF (vname_model_prsn ne '') THEN BEGIN
                                ; saving the corrected timeseries in the pathmodel folder
   cmsave,filename=pathmodel+'pr_PRSN_BCed_'+derivation_period+'_'+application_period+'_'+month(mon)+'_'+run+'test.dat',pr_c_snow,monread
                                ;
ENDIF

close,3
end
