;; ISI-MIP bias correction code, based on algorithm used in WATCH
;; project (by Piani and Hearter)
;;
;;THIS IDL FILE CONTAINS THE MAIN PROCEDURES REQUIRED
;;FOR THE CONSTRUCTION OF THE TEMPERATURE BIAS CORRECTION COEFFICIENTS WITHIN
;;THE MONTHLY BIAS CORRECTION.
;;
;; requires: definitions.pro, definitions_internal.pro, functions.pro
;;
;;
;Calculates Monthly precipitation Bias Correction Factors using the
;specified files for the observations and model data for
;a given time period (construction_period).
;______________________________________________________________
;

monread=12
;
;
;*******************************************************************
; specifying the output file for the correction parameters
outfile=outputdir+'tas_cor_'+construction_period+'_'+month(mon)+'_'+runToCorrect+'_test.dat'
;
print,'Test outfile for existence : '+outfile
IF ( FILE_TEST(outfile) ) THEN BEGIN
   print,'Already present. exiting...'
   exit
ENDIF
;
; specifying the path to the model data for t2, tmin, tmax
pfile_temp2=pathmodel+MODELroot_T+construction_period+'_'+month(mon)+'_'+runToCorrect+'_test.dat'
pfile_tmin=pathmodel+MODELroot_Tmin+construction_period+'_'+month(mon)+'_'+runToCorrect+'_test.dat'
pfile_tmax=pathmodel+MODELroot_Tmax+construction_period+'_'+month(mon)+'_'+runToCorrect+'_test.dat'
;
; ... to the watch forcing data for t2, tmin, tmax
wfdfile_temp2 = pathWFD+WFDroot_T+construction_period+'_'+month(mon)+'_test.dat'
wfdfile_tmin  = pathWFD+WFDroot_Tmin+construction_period+'_'+month(mon)+'_test.dat'
wfdfile_tmax  = pathWFD+WFDroot_Tmax+construction_period+'_'+month(mon)+'_test.dat'
;

cmrestore,pfile_temp2
if (mon ne monread) then begin
   print,'error restoring',pfile_temp2
   stop
endif
construction_period_length = CONSTRUCTION_PERIOD_STOP*1L-CONSTRUCTION_PERIOD_START*1L+1
monlength = n_elements(idldata[1,*])/construction_period_length ;
print,monlength
tas_e=idldata*1.0D
l=n_elements(tas_e(0,*))
;
tmin_e=tas_e*0.0
IF (vname_model_Tmin ne '') THEN BEGIN
   monread=12
   cmrestore,pfile_tmin
   if (mon ne monread) then begin
      print,'error restoring',pfile_tmin
      stop
   endif
   tmin_e=idldata*1.0D
ENDIF
;
tmax_e=tas_e*0.0
IF (vname_model_Tmax ne '') THEN BEGIN
   monread=12
   cmrestore,pfile_tmax
   if (mon ne monread) then begin
      print,'error restoring',pfile_tmax
      stop
   endif
   tmax_e=idldata*1.0D
ENDIF

;
print,'done restoring '+construction_period+'_'+', month '+month(mon)+' model' ;******************
;*******************************************************************
;
;Get WFD for period*************************************
;
monread=12
cmrestore,wfdfile_temp2
if (mon ne monread) then begin
   print,'error restoring',wfdfile_temp2
   stop
endif
tas_o=idldata*1.0D
tas=0

monread=12
cmrestore,wfdfile_tmax
if (mon ne monread) then begin
   print,'error restoring',wfdfile_tmax
endif
tmax_o=idldata*1.0D
tmax=0

monread=12
cmrestore,wfdfile_tmin
if (mon ne monread) then begin
   print,'error restoring',wfdfile_tmin
endif
tmin_o=idldata*1.0D
tmin=0


; initialize
tas_e_res = tas_e
tmin_e_res = tmin_e
tmax_e_res = tmax_e
tas_o_res = tas_o
tmin_o_res = tmin_o
tmax_o_res = tmax_o


;******************************************************************
;Define bias correction parameters
;
a_tas=fltarr(NUMLANDPOINTS,2)
a_td=fltarr(NUMLANDPOINTS,2)
;

; define plotting axis
;plot,[lon(0)],[lat(0)],xrange=[-180,180],yrange=[-90,90]
;xyouts,-180,-80,'month = '+month(mon)
; check data
print,'Checking consistency of input data ...'
IF (min(tas_e) LT 0.0 OR min(tas_o) LT 0.0) THEN BEGIN
   print,'Model or WFD has negative temperature: Exiting.'
   STOP
ENDIF


;********************************************************************
IF (vname_model_Tmin ne '' AND vname_model_Tmax ne '') THEN BEGIN

   IF (min(tmax_e-tmin_e) LT 0.0 OR min(tmax_o-tmin_o) LT 0.0) THEN BEGIN
      print,'Model or WFD has negative diurnal range: Exiting.'
      STOP
   ENDIF
   IF (min(tmax_e-tas_e) LT 0.0 OR min(tmax_o-tas_o) LT 0.0) THEN BEGIN
      print,'Model or WFD has points with Tmax<Tmean: Exiting.'
      STOP
   ENDIF
   IF (max(tmin_e-tas_e) GT 0.0 OR max(tmin_o-tas_o) GT 0.0) THEN BEGIN
      print,'Model or WFD has points with Tmin>Tmean: Exiting.'
      STOP
   ENDIF

ENDIF


print,'Data passed basic consistency check.'
;
;******************************************************************
;tas_e_mnth=tas_e(*,monlength-1)
;tas_o_mnth=tas_o(*,monlength-1)
;delta_e = delta_e(*,monlength-1)
;delta_o = delta_o(*,monlength-1)


start_new_month = findgen(construction_period_length)*monlength
;START LOOP
if (mon eq 1) then begin
   monthlength=28
   leap=0
   for i=1,construction_period_length-1 do begin
      syear = CONSTRUCTION_PERIOD_START*1L+i
      nleap = syear/4.
      leap=leap+(nleap eq ceil(nleap))
      start_new_month(i) = (i*monthlength)+leap
   endfor
endif

                                ;start_new_month = findgen(construction_period_length)*monlength
                                ;print,start_new_month
for n=0L,(NUMLANDPOINTS-1) do begin

   if ((n mod 1000) eq 0) then begin
      print,n
   endif


;print,'length',n_elements(tas_e[n,*]),n_elements(tas_o[n,*])
   for mm=0,construction_period_length-1 do begin
                                ;print,'idx',mm
      startidx = start_new_month[mm]
      if (mm le (construction_period_length-2)) then endidx = start_new_month[mm+1]-1
      if (mm eq (construction_period_length-1)) then endidx = n_elements(tas_e[n,*])-1
                                ;       print,'start',startidx
                                ;       print,'end',endidx
      tas_e_res[n,startidx:endidx] = tas_e[n,startidx:endidx]-mean(tas_e[n,startidx:endidx]) ;
      tas_o_res[n,startidx:endidx] = tas_o[n,startidx:endidx]-mean(tas_o[n,startidx:endidx]) ;
   endfor

;+++++++++++++++ reorder residuals of tas +++++++++++++++
   y=reform(tas_o_res(n,sort(tas_o_res[n,*]))) ; obs
   x=reform(tas_e_res(n,sort(tas_e_res[n,*]))) ; mod

   length_data=n_elements(y)    ; the total number of days to correct

;_________________________________________________________
;
   xm=mean(x)
   ym=mean(y)
   yxm=mean(x*y)
   xxm=mean(x*x)
   divisor=xxm-xm*xm
   IF (divisor NE 0.0 AND xm NE 0.0) THEN BEGIN
      a=[ym+(ym*xm-yxm)/divisor*xm,-(ym*xm-yxm)/divisor]
   ENDIF ELSE BEGIN
      a=[ym-xm,1]
   ENDELSE
   IF (a(0) GT 50000.0 or a(0) LT -50000.0 or a(1) GT 5000.0 or a(1) LT -5000.0) THEN BEGIN
      a=[0,1]
   ENDIF
;

;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

;******************************************************
;********* end of fitting procedure ************************
; output data for the slope and offset
                                ;a_tas(n,*)=a
;******************************************************************
;First bias correction factor is the offset between the means
;over the full construction period
;******************************************************************
   a_tas(n,0)=mean(tas_o[n,*])-mean(tas_e[n,*])
   a_tas(n,1)=a(1)

   a_td(n,0)=mean(tmax_o[n,*]-tas_o[n,*])/mean(tmax_e[n,*]-tas_e[n,*])
   a_td(n,1)=mean(tmin_o[n,*]-tas_o[n,*])/mean(tmin_e[n,*]-tas_e[n,*])

;
endfor

;
;
cmsave,a_tas,a_td,monread,filename=outfile
;
;
close,2

end
