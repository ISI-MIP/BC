#!/bin/sh
# @ initialdir = _WRKDIR_
# @ input = /dev/null
# @ job_type = serial
# @ class = largemem
# @ group = isimip
# @ notification = complete
# @ notify_user = buechner@pik-potsdam.de
# @ job_name = preparefiles_O
# @ comment = ISI-MIP IO
# @ checkpoint = no
# @ restart = no
# @ output = _WRKDIR_/ll.logs/preparefiles_O.out
# @ error =  _WRKDIR_/ll.logs/preparefiles_O.err
# @ queue

. exports
[[ -f exports.tmp ]] && source exports.tmp || export CONVERT_WFD=2

gdl <<EOF
.r period.pro
.r runidx.pro
.r gdl_exports
.r definitions/definitions_generic.pro
.r definitions/definitions_internal_generic.pro
.r gdl_routines/generic/ncdf2idl.pro
.r gdl_routines/generic/prepareData.pro
.r gdl_routines/generic/count_processed.pro
.r gdl_routines/generic/adapt_calendar
FORMAT_WFD = $CONVERT_WFD
.r gdl_routines/$BC_VERSION/prepareFiles_O.pro
exit
EOF

rm -f preparefiles_O.lock exports.tmp
