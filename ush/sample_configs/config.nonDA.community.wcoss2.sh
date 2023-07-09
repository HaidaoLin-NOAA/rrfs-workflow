MACHINE="wcoss2"
ACCOUNT="RRFS-DEV"
HPSS_ACCOUNT="RRFS-DEV"
EXPT_SUBDIR="test_nonDA_community"

VERBOSE="TRUE"

RUN_ENVIR="community"
PREEXISTING_DIR_METHOD="rename"

WFLOW_XML_TMPL_FN="FV3LAM_wflow_nonDA.xml"

PREDEF_GRID_NAME="RRFS_CONUS_25km"
QUILTING="TRUE"

CCPP_PHYS_SUITE="FV3_GFS_v15p2"
FCST_LEN_HRS="12"
LBC_SPEC_INTVL_HRS="6"

DATE_FIRST_CYCL="20190615"
DATE_LAST_CYCL="20190615"
CYCL_HRS=( "00" )

EXTRN_MDL_NAME_ICS="FV3GFS"
EXTRN_MDL_NAME_LBCS="FV3GFS"

FV3GFS_FILE_FMT_ICS="grib2"
FV3GFS_FILE_FMT_LBCS="grib2"

WTIME_RUN_FCST="01:00:00"

DO_RETRO="TRUE"

USE_USER_STAGED_EXTRN_FILES="TRUE"
EXTRN_MDL_SOURCE_BASEDIR_ICS="/lfs/h2/emc/lam/noscrub/UFS_SRW_App/develop/input_model_data/FV3GFS/grib2"
EXTRN_MDL_FILES_ICS=( "gfs.t00z.pgrb2.0p25.f000" )
EXTRN_MDL_SOURCE_BASEDIR_LBCS="/lfs/h2/emc/lam/noscrub/UFS_SRW_App/develop/input_model_data/FV3GFS/grib2"
EXTRN_MDL_FILES_LBCS=( "gfs.t00z.pgrb2.0p25.f006" "gfs.t00z.pgrb2.0p25.f012" )
