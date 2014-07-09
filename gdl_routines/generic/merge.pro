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

   if (T_Correct EQ 1 and P_Correct EQ 1) then types=['pr_BCed_','T_BCed_']
   if (T_Correct EQ 1 and P_Correct EQ 0) then types=['T_BCed_']
   if (T_Correct EQ 0 and P_Correct EQ 1) then types=['pr_BCed_']

   IF (vname_model_prsn eq '' AND vname_model_Tmin ne '' AND vname_model_Tmax ne '') THEN BEGIN
      if (T_Correct EQ 1 and P_Correct EQ 1) then types=['pr_BCed_','T_BCed_','Tmax_BCed_','Tmin_BCed_']
      if (T_Correct EQ 1 and P_Correct EQ 0) then types=['T_BCed_','Tmax_BCed_','Tmin_BCed_']
      if (T_Correct EQ 0 and P_Correct EQ 1) then types=['pr_BCed_']
   ENDIF
   IF (vname_model_prsn ne '' AND vname_model_Tmin eq '' AND vname_model_Tmax eq '') THEN BEGIN
      if (T_Correct EQ 1 and P_Correct EQ 1) then types=['pr_BCed_','pr_PRSN_BCed_','T_BCed_']
      if (T_Correct EQ 1 and P_Correct EQ 0) then types=['T_BCed_']
      if (T_Correct EQ 0 and P_Correct EQ 1) then types=['pr_BCed_','pr_PRSN_BCed_']
   ENDIF
   IF (vname_model_prsn ne '' AND vname_model_Tmin ne '' AND vname_model_Tmax ne '') THEN BEGIN
      if (T_Correct EQ 1 and P_Correct EQ 1) then types=['pr_BCed_','pr_PRSN_BCed_','T_BCed_','Tmax_BCed_','Tmin_BCed_']
      if (T_Correct EQ 1 and P_Correct EQ 0) then types=['T_BCed_','Tmax_BCed_','Tmin_BCed_']
      if (T_Correct EQ 0 and P_Correct EQ 1) then types=['pr_BCed_','pr_PRSN_BCed_']
   ENDIF


   types=['Tmin_BCed_']

;
;
;the main loop over the types to be output
   for typ=0,(n_elements(types)-1) do begin
;
      IF (OUTPUT_DATAFORMAT_2D EQ 1) THEN BEGIN
         outfileFinal=pathFinalData+types(typ)+derivation_period+'_'+application_period+'_'+run+'test.nc'
         outfileAll=pathmodel+types(typ)+derivation_period+'_'+application_period+'_'+month+'_'+run+'test.nc'
         spawn,'cdo -O mergetime '+outfileAll(0)+' '+outfileAll(1)+' '+outfileAll(2)+' '+outfileAll(3)+' '+outfileAll(4)+' '+outfileAll(5)+' '+outfileAll(6)+' '+outfileAll(7)+' '+outfileAll(8)+' '+outfileAll(9)+' '+outfileAll(10)+' '+outfileAll(11)+' '+outfileFinal
      ENDIF
;
      IF (OUTPUT_DATAFORMAT_1D EQ 1) THEN BEGIN
         outfileAll=pathmodel+'COMPRESSED_'+types(typ)+derivation_period+'_'+application_period+'_'+month+'_'+run+'test.nc'
         outfileFinal=pathFinalData+'COMPRESSED_'+types(typ)+derivation_period+'_'+application_period+'_'+run+'test.nc'
         spawn,'cdo -O mergetime '+outfileAll(0)+' '+outfileAll(1)+' '+outfileAll(2)+' '+outfileAll(3)+' '+outfileAll(4)+' '+outfileAll(5)+' '+outfileAll(6)+' '+outfileAll(7)+' '+outfileAll(8)+' '+outfileAll(9)+' '+outfileAll(10)+' '+outfileAll(11)+' '+outfileFinal
      ENDIF
;
   endfor                       ; TYPES FOR LOOP ENDS
endif                           ; END OF PRIMARY IF LOOP
end                             ; PROGRAM ENDS.
