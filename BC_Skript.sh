#!/bin/bash

###############################################################
### input #####################################################
###############################################################
#########
# Note: The bias correction for wind, radiation, and pressure has to run serial. Parallel runs are not possible due to limitations of RAM. If this would not be the case the shell scripts have to be adjusted
########

# example:
# ./BC_Skript.sh 'T' 'rcp2p6' 'yes' 'HadGEM2-ES'

### $1 ... vars: P, T, lw, sw, ps, wind, rhs
### $2 ... rcps: rcp2p6, rcp4p5, rcp6p0, rcp8p5
### $3 ... full: yes, no
### $4 ... GCM : HadGEM2-ES, IPSL-CM5A-LR, GFDL-ESM2M, MIROC-ESM-CHEM, NorESM1-M, CNRM-CM5, CCSM4

WRKDIR=$(pwd)

#read configuration
. exports

GCM=$4

# create output folders
DATA_PATH=$BASE_PATH/${GCM}_${BC_VERSION}_run$BC_RUN_INTERNAL
OUTPATH1=$DATA_PATH/BC_data
OUTPATH2=$DATA_PATH/finalOutputData
OUTPATH3=$DATA_PATH/factors
mkdir -p $DATA_PATH $OUTPATH1 $OUTPATH2 $OUTPATH3 ll.logs

# export paths, imported in definitions_generic.pro
cat > gdl_exports <<EOF
BC_RUNNUMBER =  '${GCM}_${BC_VERSION}_run$BC_RUN_INTERNAL'
varidx       =  '$1'
modelname    =  '$GCM'
ensemble     =  '$ENSEMBLE'
pathdat      =  '$BASE_PATH/'
pathmodelorg =  '$GCM_INPUT_BASE_PATH/$GCM/'
pathWFDorg   =  '$WFD_PATH/'
END
EOF

[[ $GCM = "GFDL-ESM2M" ]] && HIST_START_YEAR=1861 || HIST_START_YEAR=1860

RCPS_INT=$2

for VAR in $1;do

    case $VAR in
        T)
            VARS_IN="T Tmin Tmax"
            VARS_OUT="tas tasmin tasmax"
            VARS_WFD_IDL=$VARS_IN
            VARS_MODEL_IDL=$VARS_IN
            VAR_TF="tas";;
        P)
            VARS_IN="pr pr_PRSN"
            VARS_OUT="pr prsn"
            VARS_WFD_IDL="pr"
            VARS_MODEL_IDL="precip prsn"
            VAR_TF="pr";;
        LW)
            VARS_IN="lw"
            VARS_OUT="rlds"
            VARS_WFD_IDL=$VARS_IN
            VARS_MODEL_IDL=$VARS_IN
            VAR_TF="lw";;
        SW)
            VARS_IN="sw"
            VARS_OUT="rsds"
            VARS_WFD_IDL=$VARS_IN
            VARS_MODEL_IDL=$VARS_IN
            VAR_TF="sw";;
        ps)
            VARS_IN="ps"
            VARS_OUT="ps"
            VARS_WFD_IDL=$VARS_IN
            VARS_MODEL_IDL=$VARS_IN
            VAR_TF="ps";;
        wind)
            VARS_IN="U V wind"
            VARS_OUT="uas vas wind"
            VARS_WFD_IDL="wind"
            VARS_MODEL_IDL="U V"
            VAR_TF="wind";;
        rhs)
            VARS_IN="rhs"
            VARS_OUT="rhs"
            VARS_WFD_IDL="hur"
            VARS_MODEL_IDL="rhs"
            VAR_TF="rhs";;
        *)
            echo "no valid variable";exit;;
    esac

    FILE_IDENT=$VAR
    case $VAR in
        T|P)
            WRITE_SCRIPT="writeFinalFiles";;
        *)
            FILE_IDENT="O"
            WRITE_SCRIPT="writeFinalFiles_O";;
    esac

    [[ $VAR = "rhs" ]] && FILE_TAG="" || FILE_TAG="_BCed_1960_1999"

    if [[ $3 = "yes" ]];then
        if [[ $VAR != "rhs" ]];then
            echo "Prepare WFD and GCM data for constructing factors ..."
            cp definitions/runidx_rcp2p6.pro runidx.pro
            cp definitions/period_2000_2049.pro period.pro

            # prepare data for the construction period and the future period into idl format
            WFD2IDL_COMPLETE=YES
            MOD2IDL_COMPLETE=YES
            for VAR_WFD_IDL in $VARS_WFD_IDL;do
                [[ $(ls $BASE_PATH/WFD_IDL/wfd_${VAR_WFD_IDL}_*.dat 2>/dev/null |wc -l ) -lt 12 ]] && WFD2IDL_COMPLETE="NO" > /dev/null
            done
            for VAR_MODEL_IDL in $VARS_MODEL_IDL;do
                [[ $(ls $OUTPATH1/${VAR_MODEL_IDL}_1960_1999*.dat 2>/dev/null |wc -l ) -lt 12 ]] && MOD2IDL_COMPLETE="NO" > /dev/null
                [[ $(ls $OUTPATH1/${VAR_MODEL_IDL}_2000_2049*.dat 2>/dev/null |wc -l ) -lt 12 ]] && MOD2IDL_COMPLETE="NO" > /dev/null
            done
            [[ $WFD2IDL_COMPLETE = "NO" ]] && echo "export CONVERT_WFD=1" > exports.tmp || echo "export CONVERT_WFD=2" > exports.tmp
            #           echo " WFD2IDL_COMPLETE :" $WFD2IDL_COMPLETE
            #           echo " MOD2IDL_COMPLETE :" $MOD2IDL_COMPLETE
            if [[ $WFD2IDL_COMPLETE = "NO" || $MOD2IDL_COMPLETE = "NO" ]];then
                echo " ...preparing $VAR"
                LL_SCRIPT=preparefiles_$FILE_IDENT.sh
                touch preparefiles_$FILE_IDENT.lock
                sed -e "s/_WRKDIR_/${WRKDIR//\//\\/}/g" subscripts/$LL_SCRIPT > $LL_SCRIPT
                echo -n " ";llsubmit $LL_SCRIPT && rm $LL_SCRIPT
                echo " logfile: $WRKDIR/ll.logs/preparefiles_$FILE_IDENT.out"
                echo " ...wait for LoadL jobs to finish..."
                while test -e preparefiles_$FILE_IDENT.lock;do sleep 5;done
                rm exports.tmp
            else
                echo " WFD and GCM data already converted to IDL format."
            fi
        fi
    fi

    # calculate transfer function
    if [[ $VAR != "rhs" ]];then
        COMPUTE_TF=NO
        echo " ...calculating transfer function for $VAR"
        CONSTRUCT_MAIN_SCRIPT=construct_${FILE_IDENT}_cor.llsubmit
        cp subscripts/construct_cor_mon.llsubmit.template $CONSTRUCT_MAIN_SCRIPT
        for MON in $(seq 1 12);do
            [[ $MON -lt 10 ]] && MON=0$MON
            if [[ ! -e $OUTPATH3/${VAR_TF}_cor_1960_1999_${MON}__test.dat ]];then
                echo "  ...include factor contruction for month $MON"
                COMPUTE_TF=YES
                touch construct_${FILE_IDENT}_cor_mon$MON.lock
                MON_INT=$((10#$MON - 1))
                sed -e s/_MON_GDL_/$MON_INT/ \
                    -e s/_MON_FILE_/$MON/ \
                    -e s/_WRKDIR_/${WRKDIR//\//\\/}/g \
                    subscripts/construct_${FILE_IDENT}_cor_mon_template > \
                    construct_${FILE_IDENT}_cor_mon$MON.sh
                chmod +x construct_${FILE_IDENT}_cor_mon$MON.sh
                cat <<EOF >> $CONSTRUCT_MAIN_SCRIPT
# @ step_name = construct_${FILE_IDENT}_cor_mon$MON
# @ output = $WRKDIR/ll.logs/\$(step_name).out
# @ error =  $WRKDIR/ll.logs/\$(step_name).err
# @ class = largemem
# @ executable = $WRKDIR/construct_${FILE_IDENT}_cor_mon$MON.sh
# @ queue

EOF
            fi
        done
        sed -i "s/_WRKDIR_/${WRKDIR//\//\\/}/g" $CONSTRUCT_MAIN_SCRIPT
        if [[ $COMPUTE_TF = "YES" ]];then
            echo -n " ";llsubmit $CONSTRUCT_MAIN_SCRIPT
            echo " logfiles: $WRKDIR/ll.logs/construct_${FILE_IDENT}_cor_mon*.out"
            echo " ...wait for LoadL jobs to finish..."
            while ls construct_${FILE_IDENT}_cor_mon*.lock &> /dev/null;do sleep 5;done;echo
        else
            echo " transfer functions for all months already calculated"
        fi
        rm -f $CONSTRUCT_MAIN_SCRIPT
    else
        echo " Factors for rhs not needed."
    fi

    # correct data
    for RCP in $RCPS_INT;do
        for PERIOD in $PERIODS;do
            if [[ $PERIOD = "${HIST_START_YEAR}_1899" ]] || [[ $PERIOD = "1900_1949" ]] || [[ $PERIOD = "1950_1959" ]] || [[ $PERIOD = "1960_1999" ]];then
                [[ $3 = "no" ]] && continue
                [[ $RCP = "rcp4p5" ]] || [[ $RCP = "rcp6p0" ]] || [[ $RCP = "rcp8p5" ]] && continue
                cp definitions/runidx_historical.pro runidx.pro
            else
                cp definitions/runidx_$RCP.pro runidx.pro
            fi

            echo " ...processing transfer function application for period $VAR $RCP $PERIOD ..."
            cp definitions/period_$PERIOD.pro period.pro

            MOD2IDL_COMPLETE=YES
            for VAR_MODEL_IDL in $VARS_MODEL_IDL;do
                [[ $(ls $OUTPATH1/${VAR_MODEL_IDL}_$PERIOD*.dat 2>/dev/null |wc -l ) -lt 12 ]] && MOD2IDL_COMPLETE="NO" > /dev/null
            done
            # echo " MOD2IDL_COMPLETE :" $MOD2IDL_COMPLETE
            # exit
            if [[ $MOD2IDL_COMPLETE = "NO" ]];then
                echo " ...preparing $VAR $PERIOD"
                touch preparefiles_$FILE_IDENT.lock
                LL_SCRIPT=preparefiles_$FILE_IDENT.sh
                sed -e "s/_WRKDIR_/${WRKDIR//\//\\/}/g" subscripts/$LL_SCRIPT > $LL_SCRIPT
                echo -n " ";llsubmit $LL_SCRIPT && rm $LL_SCRIPT
                echo " logfile: $WRKDIR/ll.logs/preparefiles_$FILE_IDENT.out"
                echo " ...wait for LoadL jobs to finish..."
                while test -e preparefiles_$FILE_IDENT.lock;do sleep 5;done;echo
            else
                echo " GCM data already converted to IDL format."
            fi

            if [[ $VAR != "rhs" ]];then
                APPLY_TF=NO
                APPLY_MAIN_SCRIPT=apply_${FILE_IDENT}_cor.llsubmit
                cp subscripts/apply_cor_mon.llsubmit.template $APPLY_MAIN_SCRIPT
                for MON in $(seq 1 12);do
                    [[ $MON -lt 10 ]] && MON=0$MON
                    APPLY_THIS_MON=NO
                    for VAR_IN in $VARS_IN;do
                        if [[ ! -e $OUTPATH1/${VAR_IN}_BCed_1960_1999_${PERIOD}_${MON}_test.dat ]];then
                            APPLY_TF=YES
                            APPLY_THIS_MON=YES
                        fi
                    done
                    if [[ $APPLY_THIS_MON = "YES" ]];then
                        echo " ...include transfer function application for month $MON"
                        touch apply_${FILE_IDENT}_cor_mon$MON.lock
                        MON_INT=$((10#$MON - 1))
                        sed -e s/_MON_GDL_/$MON_INT/ \
                            -e s/_MON_FILE_/$MON/ \
                            -e s/_WRKDIR_/${WRKDIR//\//\\/}/g \
                            subscripts/apply_${FILE_IDENT}_cor_mon_template > \
                            apply_${FILE_IDENT}_cor_mon$MON.sh
                        chmod +x apply_${FILE_IDENT}_cor_mon$MON.sh
                        cat <<EOF >> $APPLY_MAIN_SCRIPT
# @ step_name = apply_${FILE_IDENT}_cor_mon$MON
# @ output = $WRKDIR/ll.logs/\$(step_name).out
# @ error =  $WRKDIR/ll.logs/\$(step_name).err
# @ class = largemem
# @ executable = $WRKDIR/apply_${FILE_IDENT}_cor_mon$MON.sh
# @ queue

EOF
                    fi
                done
                sed -i "s/_WRKDIR_/${WRKDIR//\//\\/}/g" $APPLY_MAIN_SCRIPT
                if [[ $APPLY_TF = "YES" ]];then
                    echo -n " ";llsubmit $APPLY_MAIN_SCRIPT
                    echo " logfiles: $WRKDIR/ll.logs/apply_${FILE_IDENT}_cor_mon*.out"
                    echo " ...wait for LoadL jobs to finish..."
                    while ls apply_${FILE_IDENT}_cor_mon*.lock &> /dev/null;do sleep 5;done;echo
                else
                    echo " ...transfer function already applied to all months"
                fi
                rm -f $APPLY_MAIN_SCRIPT
            else
                echo " bias correction for rhs not needed."
            fi

            # write bced data to netCDF
            WRITE_COMPLETE=YES
            [[ $VAR = "rhs" ]] && FILE_TAG="" || FILE_TAG="_BCed_1960_1999"
            for VAR_IN in $VARS_IN;do
                [[ $(ls $OUTPATH1/${VAR_IN}${FILE_TAG}_$PERIOD*.nc 2>/dev/null |wc -l ) -lt 12 ]] && WRITE_COMPLETE=NO
                [[ ! -f $OUTPATH2/${VAR_IN}${FILE_TAG}_${PERIOD}_test.nc ]] && WRITE_COMPLETE=NO
            done
            #            echo "WRITE_COMPLETE   :" $WRITE_COMPLETE
            if [[ $WRITE_COMPLETE = "NO" ]];then
                echo " ...writing files"
                touch $WRITE_SCRIPT.lock
                LL_SCRIPT=$WRITE_SCRIPT.sh
                sed -e "s/_WRKDIR_/${WRKDIR//\//\\/}/g" subscripts/$LL_SCRIPT > $LL_SCRIPT
                echo -n " ";llsubmit $LL_SCRIPT && rm $LL_SCRIPT
                echo " logfile: $WRKDIR/ll.logs/$WRITE_SCRIPT.out"
                echo " ...wait for LoadL job to finish..."
                while test -e $WRITE_SCRIPT.lock;do sleep 5;done;echo
            else
                echo " corrected data already written to netCDF format."
            fi
        done #PERIODS

        #        if [[ $3 != "no" ]];then
        for VAR_IN in $VARS_IN;do
            IFILE1=$OUTPATH2/${VAR_IN}${FILE_TAG}_2000_2049_test.nc
            IFILE2=$OUTPATH2/${VAR_IN}${FILE_TAG}_2050_2099_test.nc
            OFILE=$OUTPATH2/${VAR_IN}${FILE_TAG}_2000_2099_test.nc

            if [[ ! -e $OFILE ]];then
                if [[ -e $IFILE1 && -e $IFILE2 ]];then
                    echo " ...cat $RCP $VAR_IN"
                    cdo -s cat \
                        $OUTPATH2/${VAR_IN}${FILE_TAG}_2000_2049_test.nc \
                        $OUTPATH2/${VAR_IN}${FILE_TAG}_2050_2099_test.nc \
                        $OUTPATH2/${VAR_IN}${FILE_TAG}_2000_2099_test.nc && \
                        rm -f \
                        $OUTPATH2/${VAR_IN}${FILE_TAG}_2000_2049_test.nc \
                        $OUTPATH2/${VAR_IN}${FILE_TAG}_2050_2099_test.nc
                fi
            fi
        done
        #        fi

        [[ $RCP = "rcp2p6" ]] && REPACK_HIST="yes" || REPACK_HIST="no"
        [[ $3 = "no" || $RCP = "rcp2p6" ]] && REPACK_FUT="yes" || REPACK_FUT="no"

        if [[ $REPACK_HIST = "yes" ]];then
            echo $PERIODS
            [[ $(echo $PERIODS|grep ${HIST_START_YEAR}_1899 2>/dev/null) ]] && REPACK_HIST1="yes" || REPACK_HIST1="no"
            [[ $(echo $PERIODS|grep 1900_1949 2>/dev/null) ]] && REPACK_HIST2="yes" || REPACK_HIST2="no"
            [[ $(echo $PERIODS|grep 1950_1959 2>/dev/null) ]] && REPACK_HIST3="yes" || REPACK_HIST3="no"
            [[ $(echo $PERIODS|grep 1960_1999 2>/dev/null) ]] && REPACK_HIST4="yes" || REPACK_HIST4="no"
            [[ $(echo $PERIODS|grep 1960_1999 2>/dev/null) ]] && REPACK_HIST5="yes" || REPACK_HIST5="no"
        fi

        for VAR_OUT in $VARS_OUT;do
            LL_SCRIPT=repack_ia.sh.$VAR_OUT
            sed \
                -e "s/_WRKDIR_/${WRKDIR//\//\\/}/g" \
                -e "s/_RCP_/$RCP/" \
                -e "s/_GCM_/$GCM/" \
                -e "s/_VAR_/$VAR_OUT/g" \
                -e "s/_COMPUTE1_/$REPACK_HIST1/" \
                -e "s/_COMPUTE2_/$REPACK_HIST2/" \
                -e "s/_COMPUTE3_/$REPACK_HIST3/" \
                -e "s/_COMPUTE4_/$REPACK_HIST4/" \
                -e "s/_COMPUTE5_/$REPACK_HIST5/" \
                -e "s/_COMPUTE6_/$REPACK_FUT/" \
                subscripts/repack_ia.sh.template > \
                $LL_SCRIPT
            echo "repack data for variable $VAR_OUT"
            echo -n " ";llsubmit $LL_SCRIPT && rm $LL_SCRIPT
            echo " logfiles: $WRKDIR/ll.logs/repack.out"
        done
    done
    #        rm $OUTPATH?/*${VAR}*
done
rm -f runidx.pro period.pro gdl_exports
echo "...done"
