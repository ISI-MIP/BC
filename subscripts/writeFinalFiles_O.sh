#!/bin/sh
# @ initialdir = _WRKDIR_
# @ input = /dev/null
# @ job_type = serial
# @ class = largemem
# @ group = isimip
# @ notification = complete
# @ notify_user = buechner@pik-potsdam.de
# @ job_name = writefiles
# @ comment = ISI-MIP IO
# @ checkpoint = no
# @ restart = no
# @ output = _WRKDIR_/ll.logs/writeFinalFiles_O.out
# @ error =  _WRKDIR_/ll.logs/writeFinalFiles_O.err
# @ queue

. exports

gdl <<EOF
.r period.pro
.r runidx.pro
.r gdl_exports
.r definitions/definitions_generic.pro
.r definitions/definitions_internal_generic.pro
.r gdl_routines/generic/createNCDF_v2.pro
.r gdl_routines/generic/create1dNCDF.pro
.r gdl_routines/generic/idl2latlon_O.pro
exit

EOF

rm writeFinalFiles_O.lock
