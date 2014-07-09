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


   types=['rhs_']

;
;
;the main loop over the types to be output
   for typ=0,(n_elements(types)-1) do begin
;
      IF (OUTPUT_DATAFORMAT_2D EQ 1) THEN BEGIN
         outfileFinal=pathFinalData+types(typ)+application_period+'_'+run+'test.nc'
         outfileAll=pathmodel+types(typ)+application_period+'_'+month+'_'+run+'test.nc'
         spawn,'cdo mergetime '+outfileAll(0)+' '+outfileAll(1)+' '+outfileAll(2)+' '+outfileAll(3)+' '+outfileAll(4)+' '+outfileAll(5)+' '+outfileAll(6)+' '+outfileAll(7)+' '+outfileAll(8)+' '+outfileAll(9)+' '+outfileAll(10)+' '+outfileAll(11)+' '+outfileFinal
      ENDIF
;
      IF (OUTPUT_DATAFORMAT_1D EQ 1) THEN BEGIN
         outfileAll=pathmodel+'COMPRESSED_'+types(typ)+application_period+'_'+month+'_'+run+'test.nc'
         outfileFinal=pathFinalData+'COMPRESSED_'+types(typ)+application_period+'_'+run+'test.nc'
         spawn,'cdo mergetime '+outfileAll(0)+' '+outfileAll(1)+' '+outfileAll(2)+' '+outfileAll(3)+' '+outfileAll(4)+' '+outfileAll(5)+' '+outfileAll(6)+' '+outfileAll(7)+' '+outfileAll(8)+' '+outfileAll(9)+' '+outfileAll(10)+' '+outfileAll(11)+' '+outfileFinal
      ENDIF
;
   endfor                       ; TYPES FOR LOOP ENDS
endif                           ; END OF PRIMARY IF LOOP
end                             ; PROGRAM ENDS.
