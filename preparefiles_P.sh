#!/bin/sh
# @ initialdir = /home/buechner/isimip_iplex/data/BC_ISIMIP2/BC_routines
# @ input = /dev/null
# @ job_type = serial
# @ class = largemem
# @ group = isimip
# @ notification = complete
# @ notify_user = buechner@pik-potsdam.de
# @ job_name = preparefiles_P
# @ comment = ISI-MIP IO
# @ checkpoint = no
# @ restart = no
# @ output = /home/buechner/isimip_iplex/data/BC_ISIMIP2/BC_routines/ll.logs/preparefiles_P.out
# @ error =  /home/buechner/isimip_iplex/data/BC_ISIMIP2/BC_routines/ll.logs/preparefiles_P.err
# @ queue

. exports
[[ -f exports.tmp ]] && source exports.tmp || export CONVERT_WFD=2

gdl <<EOF
.r period.pro
.r runidx.pro
.r gdl_exports
.r definitions_generic.pro
.r definitions_internal_generic.pro
.r gdl_routines/generic/ncdf2idl.pro
.r gdl_routines/generic/prepareData.pro
.r gdl_routines/generic/count_processed.pro
.r gdl_routines/generic/adapt_calendar
FORMAT_WFD = $CONVERT_WFD
.r gdl_routines/$BC_VERSION/prepareFiles_P.pro
exit
EOF

rm -f preparefiles_P.lock exports.tmp
