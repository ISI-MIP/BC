;;THIS IDL FUNCTION CONTAINS ROUTINES TO CONVERT ORIGINAL NETCDF MODEL
;;DATA TO IDL SAVED FILES.
;;
;______________________________________________________________
;
; in = input file, out = output file, SWITCH_1D = switch for latlon or
; compressed format, varname is the name of the variable to read from
; the netcdf file, e.g. aprl
function ncdf2idl,in,out,SWITCH_1d,varname,multfactor,NUMLANDPOINTS,land,monread
;varname=VNAME
;multfactor=86400.0 ; from mm/s to mm/d
;
; the main loop over all months
;
;*******************************************************************
; specifying the path to the model data.
  pfile   = in
  outfile = out
; opening the model data.
  id=NCDF_OPEN(pfile)
; the variable 'aprl' is read from the file specified and stored in
; the idl variable dataarray
  NCDF_VARGET,id,varname,dataarray
; closing the read socket.
  NCDF_CLOSE,id
;
  print,'converting '+pfile+' to '+outfile+'.'
; if the original data is stored in a 2d lat-lon format
  IF (SWITCH_1d EQ 0) THEN BEGIN
; l is the number of timesteps that was read
     l=n_elements(dataarray(0,0,*))
;
; make a new 1d idl array that is compatible with the structure of the WFD.
     idldata=fltarr(NUMLANDPOINTS,l)
; the loop transfers the land points of the 2d array to the 1d array,
; making its structure compatible with the WFD.
;
     for i=0,l-1 do begin
        dum=reform(dataarray(*,*,i))
        idldata(*,i)=dum(land-1)*multfactor
     endfor
  ENDIF
;
;
;
; if the original data is stored in the compressed 1d WFD format
  if (SWITCH_1d EQ 1) THEN BEGIN
; l is the number of timesteps that was read
     l=n_elements(dataarray(0,*))
;
; make a new 1d idl array that is compatible with the structure of the WFD.
     idldata=fltarr(NUMLANDPOINTS,l)
; the loop transfers the land points of the 2d array to the 1d array,
; making its structure compatible with the WFD.
;
     for i=0,l-1 do begin
        dum=reform(dataarray(*,i))
        idldata(*,i)=dum*multfactor
     endfor
  ENDIF
;
  dataarray=0
; model data has now been read and the 2d array is set to zero.
;print,'done restoring '+START+' to '+STOP+' model only';******************
;*******************************************************************

  print, min(idldata), max(idldata)

  cmsave,idldata,monread,filename=outfile
;
;
end
