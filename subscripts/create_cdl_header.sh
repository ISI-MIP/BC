#!/bin/bash

case $1 in
    tas)
        LONG_NAME="surface air temperature"
        UNIT="K";;
    tasmin)
        LONG_NAME="surface minimum air temperature"
        UNIT="K";;
    tasmax)
        LONG_NAME="surface maximum air temperature"
        UNIT="K";;
    pr)
        LONG_NAME="total precipitation rate"
        UNIT="kg m-2 s-1";;
    prsn)
        LONG_NAME="snowfall rate"
        UNIT="kg m-2 s-1";;
    rlds)
        LONG_NAME="long wave downwelling radiation"
        UNIT="W m-2";;
    rsds)
        LONG_NAME="short wave downwelling radiation"
        UNIT="W m-2";;
    ps)
        LONG_NAME="pressure at surface"
        UNIT="pa";;
    uas)
        LONG_NAME="Eastward Near-Surface Wind"
        UNIT="m s-1";;
    vas)
        LONG_NAME="Northward Near-Surface Wind"
        UNIT="m s-1";;
    wind)
        LONG_NAME="Near-Surface Wind Speed"
        UNIT="m s-1";;
    rhs)
        LONG_NAME="surface relative humidity"
        UNIT="%";;
    *)
        echo "no valid variable";exit;;
esac

sed -e "s/_VAR_/$1/g" \
    -e "s/_LONG_NAME_/$LONG_NAME/g" \
    -e "s/_UNIT_/$UNIT/g" \
    -e "s/_GCM_/$2/g" \
    -e "s/_VERSION_/$BC_VERSION/g" \
    -e "s/_RUN_/$RUN/g" \
    etc/netcdf_info_generic.cdl > \
    netcdf_info_${2}_$1.cdl
