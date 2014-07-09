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
monread=12
;
close,3
; the main loop over all the months

                                ;
monm1=mon-1
if (monm1 eq -1) then monm1=11
monp1=mon+1
if (monp1 eq 12) then monp1=0
                                ;
                                ;
                                ; restoring three months of correction factors. This is necessary so
                                ; the correction factors can be interpolated from day to day.
                                ;
                                ; restore the previous month correction factors
restorefile1 = outputdir+'tas_cor_'+derivation_period+'_'+month(monm1)+'_'+runToCorrect+'_test.dat'
cmrestore,restorefile1
if (monm1 ne monread) then begin
   print,'error restoring',restorefile1
   stop
endif
Am1=a_tas
                                ;afm1=a_tf
adm1=a_td
                                ;
                                ; restore the current month correction factors
restorefile2 = outputdir+'tas_cor_'+derivation_period+'_'+month(mon)+'_'+runToCorrect+'_test.dat'
cmrestore,restorefile2
if (mon ne monread) then begin
   print,'error restoring',restorefile2
   stop
endif
A=a_tas
                                ;af=a_tf
ad=a_td
                                ;
                                ; restore the following month correction factors
restorefile3 = outputdir+'tas_cor_'+derivation_period+'_'+month(monp1)+'_'+runToCorrect+'_test.dat'
cmrestore,restorefile3
if (monp1 ne monread) then begin
   print,'error restoring',restorefile3
   stop
endif
Ap1=a_tas
                                ;afp1=a_tf
adp1=a_td
                                ;
print,'done restoring BC params: tas_cor_'+derivation_period+'_'+month(mon) ;*********
                                ;*******************************************************************
                                ; loading the data for the model data to be corrected.
pfile=pathmodel+MODELroot_T+application_period+'_'+month(mon)+'_'+run+'_test.dat'
print,'restoring ' + pfile
cmrestore,pfile
if (mon ne monread) then begin
   print,'error restoring',pfile
   stop
endif
tas_e=idldata
l=n_elements(tas_e(0,*))
                                ;
                                ;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
                                ;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
IF (vname_model_Tmin ne '') THEN BEGIN
   pfile=pathmodel+MODELroot_Tmin+application_period+'_'+month(mon)+'_'+run+'_test.dat'
   print,'restoring ' + pfile
   monread = 12
   cmrestore,pfile
   if (mon ne monread) then begin
      print,'error restoring',pfile
      stop
   endif
   tmin_e=idldata
   l=n_elements(tmin_e(0,*))
ENDIF
                                ;
                                ;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
                                ;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
IF (vname_model_Tmax ne '') THEN BEGIN
   pfile=pathmodel+MODELroot_Tmax+application_period+'_'+month(mon)+'_'+run+'_test.dat'
   print,'restoring ' + pfile
   monread = 12
   cmrestore,pfile
   if (mon ne monread) then begin
      print,'error restoring',pfile
      stop
   endif
   tmax_e=idldata
   l=n_elements(tmax_e(0,*))
ENDIF
                                ;
                                ;
tas_c=tas_e
                                ;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
                                ;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
IF (vname_model_Tmin ne '' AND vname_model_Tmax ne '') THEN BEGIN
   tmin_c=tmin_e
   tmax_c=tmax_e
ENDIF
                                ;
print,'done restoring model: '+pfile
                                ;******************************************************************
                                ; performing a basic consistency check: are there negative
                                ; temperatures, are there negative diurnal ranges or days where not tmin<=tmean<=tmax.
                                ;
print,'Checking consistency of input data ...'
IF (min(tas_c) LT 0.0) THEN BEGIN
   print,'Model has negative temperature: Exiting.'
   STOP
ENDIF
                                ;
                                ;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
                                ;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
IF (vname_model_Tmin ne '' AND vname_model_Tmax ne '') THEN BEGIN
   IF (min(tmax_c-tmin_c) LT 0.0) THEN BEGIN
      print,'Model has negative diurnal range: Exiting.'
      STOP
   ENDIF
   IF (min(tmax_c-tas_c) LT 0.0) THEN BEGIN
      print,'Model has points with Tmax<Tmean: Exiting.'
      STOP
   ENDIF
   IF (max(tmin_c-tas_c) GT 0.0) THEN BEGIN
      print,'Model has points with Tmin>Tmean: Exiting.'
      STOP
   ENDIF
ENDIF

print,'Data passed basic consistency check.'
                                ; ******************************************************************
                                ;

meanthismonth_e = fltarr(NUMLANDPOINTS)


yr=APPLICATION_PERIOD_START
nyear=1L*(APPLICATION_PERIOD_STOP)-1L*(APPLICATION_PERIOD_START)+1
ind     = 0                     ; a counter for the days
ind_mon = 0
                                ;
                                ; assign the time values.

month_counter = 0
FOR y=0,nyear-1 DO BEGIN
   IF ( month(mon) EQ 12 ) THEN BEGIN
      nd=31
   ENDIF ELSE BEGIN
      nd=julday(month(mon)+1,1,yr+y)-julday(month(mon),1,yr+y)
   ENDELSE
   daysthismonth = ind+findgen(nd)
   print,'year = ',y
   for iday=0,nd-1 do begin
;        pr_e_day=reform(idldata(*,ind))*86400.0
;        pr_c_day=pr_e_day
                                ;
                                ;
;        d=-0.5+(iday*1.0/nd)
      d=-0.5+(iday*1.0/(nd-1))
                                ;
                                ; Weighting factors for the previous month (dm1), the current month
                                ; (d0) and the following month (dp1) are evaluated, such that for the
                                ; first (last) day of the month the correction factors of the previous
                                ; (following) month are equally weighted , i.e. dm1=d0=0.5
                                ; (dp1=d0=0.5), and for the days in the middle of the month d0=1,
                                ; dp1=dm1=0.
                                ;
      dm1=(abs(d)-d)*0.5
      d0=1-abs(d)
      dp1=(d+abs(d))*0.5
                                ;
                                ; producing a weighted average of the three pairs of coefficients.
      a_iday  = Am1*dm1  +  A*d0 +  Ap1*dp1
;                       a_iday = A
                                ;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
                                ;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      IF (vname_model_Tmin ne '' AND vname_model_Tmax ne '') THEN BEGIN
         ad_iday = Adm1*dm1 + Ad*d0 + Adp1*dp1
                                ;ad_iday = Ad
                                ;af_iday = Afm1*dm1 + Af*d0 + Afp1*dp1
      ENDIF
                                ;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
                                ;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
                                ;
                                ;START space LOOP over all land points
      for n=0L,NUMLANDPOINTS-1 do begin
                                ;
                                ;       if ((n mod 1000) eq 0) then begin
                                ;               print,n
                                ;       endif
                                ;diff_e =tas_e[n,ind]-tmin_e[n,ind]
                                ;delta_e =tmax_e[n,ind]-tmin_e[n,ind]

                                ;td_e[n,startidx:endidx] = delta_e);
                                ;tf_e[n,startidx:endidx] = diff_e/delta_e;

         if (iday eq 0) then begin
            meanthismonth_e(n) = mean(tas_e(n,daysthismonth))
         endif

         T_res=tas_e(n,ind)-meanthismonth_e(n)
                                ; Td_res=td_e(n,ind)-meanthismonth_e_delta
                                ; Tf_res=tf_e(n,ind)-meanthismonth_e_fact


                                ;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
                                ;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
                                ; IF (vname_model_Tmin ne '' AND vname_model_Tmax ne '') THEN BEGIN
                                ;   Td=Tmax_e(n,ind)-Tmin_e(n,ind)
                                ;    IF (Td GT 0.0) THEN Tf=(tas_e(n,ind)-Tmin_e(n,ind))/Td
                                ;    IF (Td EQ 0.0) THEN Tf=0.5
                                ;    IF (Td LT 0.0) THEN STOP
                                ;ENDIF
                                ;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
                                ;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
                                ;change to how correction is applied
                                ;first residual multiplied by factor, then offset and monthly mean
                                ;added back in
                                ;T_corr=  a_iday(n,0)+a_iday(n,1)*T
         T_corr=  a_iday(n,0)+a_iday(n,1)*T_res+meanthismonth_e(n)

                                ;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
                                ;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
                                ;IF (vname_model_Tmin ne '' AND vname_model_Tmax ne '') THEN BEGIN
                                ;Td_corr=ad_iday(n,0)+ad_iday(n,1)*Td
                                ;Td_corr=ad_iday(n,0)+Td                ad_iday(n,1)*Td_res+meanthismonth_e_delta

                                ;Td_corr=ad_iday(n,0)*Td




                                ;Td_corr=0.5*(Td_corr+abs(Td_corr))
                                ;Tf_corr=af_iday(n,0)+af_iday(n,1)*Tf
                                ;Tf_corr=af_iday(n,0)+af_iday(n,1)*Tf_res+meanthismonth_e_fact

                                ;Tf_corr = af_iday(n,0)*Tf

                                ;Tf_corr=0.5*(Tf_corr+abs(Tf_corr))
                                ;IF (Tf_corr GT 1.0) THEN If_corr=1.0
                                ;
                                ;ENDIF
                                ;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
                                ;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

         tas_c(n,ind)=T_corr
                                ;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
                                ;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
         IF (vname_model_Tmin ne '' AND vname_model_Tmax ne '') THEN BEGIN
                                ;tmin_c(n,ind)=T_corr-Td_corr*Tf_corr
                                ;tmax_c(n,ind)=T_corr+Td_corr*(1-Tf_corr)
                                ;tmin_c(n,ind)=T_corr-Td_corr*Tf_corr
            tmax_c(n,ind)=ad_iday(n,0)*(tmax_e(n,ind)-tas_e(n,ind))+T_corr
            tmin_c(n,ind)=ad_iday(n,1)*(tmin_e(n,ind)-tas_e(n,ind))+T_corr
                                ;
         ENDIF
                                ;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
                                ;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      endfor
                                ;
      ind=ind+1
                                ;**************************************************************
   endfor
endfor

                                ; printing information on the period completed.
print,'BC complete: construction decade ', derivation_period, ', application period: ', application_period, ', month ',month(mon)
                                ;
                                ; saving the corrected timeseries in the pathmodel folder
cmsave,tas_c,monread,filename=pathmodel+'T_BCed_'+derivation_period+'_'+application_period+'_'+month(mon)+'_'+run+'test.dat'

                                ;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
                                ;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
IF (vname_model_Tmin ne '' AND vname_model_Tmax ne '') THEN BEGIN

   cmsave,tmin_c,monread,filename=pathmodel+'Tmin_BCed_'+derivation_period+'_'+application_period+'_'+month(mon)+'_'+run+'test.dat'
   cmsave,tmax_c,monread,filename=pathmodel+'Tmax_BCed_'+derivation_period+'_'+application_period+'_'+month(mon)+'_'+run+'test.dat'

ENDIF
                                ;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
                                ;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++



close,3
end
