#!/bin/bash

# usage instructions
usage () {
cat << EOF_USAGE
Usage: $0 --platform=PLATFORM [OPTIONS] ... [TARGETS]

OPTIONS
  -h, --help
      show this help guide
  -p, --platform=PLATFORM
      name of machine you are building on
      (e.g. cheyenne | hera | jet | orion | wcoss2)
  -c, --compiler=COMPILER
      compiler to use; default depends on platform
      (e.g. intel | gnu | cray | gccgfortran)
  -a, --app=APPLICATION
      weather model application to build; for example, ATMAQ for RRFS-AQM
      (e.g. ATM | ATMAQ | ATMW | S2S | S2SW)
  --ccpp="CCPP_SUITE1,CCPP_SUITE2..."
      CCPP suites (CCPP_SUITES) to include in build; delimited with ','
  --enable-options="OPTION1,OPTION2,..."
      enable ufs-weather-model options; delimited with ','
      (e.g. 32BIT | INLINE_POST | UFS_GOCART | MOM6 | CICE6 | WW3 | CMEPS)
  --disable-options="OPTION1,OPTION2,..."
      disable ufs-weather-model options; delimited with ','
      (e.g. 32BIT | INLINE_POST | UFS_GOCART | MOM6 | CICE6 | WW3 | CMEPS)
  --continue
      continue with existing build
  --remove
      removes existing build; overrides --continue
  --clean
      does a "make clean"
  --build
      does a "make" (build only)
  --move
      move binaries to final location.
  --build-dir=BUILD_DIR
      build directory
  --install-dir=INSTALL_DIR
      installation prefix
  --bin-dir=BIN_DIR
      installation binary directory name ("exec" by default; any name is available)
  --build-type=BUILD_TYPE
      build type; defaults to RELEASE
      (e.g. DEBUG | RELEASE | RELWITHDEBINFO)
  --build-jobs=BUILD_JOBS
      number of build jobs; defaults to 4
  --use-sub-modules
      Use sub-component modules instead of top-level level SRW modules
  -v, --verbose
      build with verbose output

TARGETS
   default = builds the default list of apps (also not passing any target does the same)
   all = builds all apps
   Or any combinations of (ufs, ufs_utils, upp, gsi, rrfs_utils)

NOTE: See User's Guide for detailed build instructions

EOF_USAGE
}

# print settings
settings () {
cat << EOF_SETTINGS
Settings:

  HOME_DIR=${HOME_DIR}
  BUILD_DIR=${BUILD_DIR}
  INSTALL_DIR=${INSTALL_DIR}
  BIN_DIR=${BIN_DIR}
  PLATFORM=${PLATFORM}
  COMPILER=${COMPILER}
  APP=${APPLICATION}
  CCPP=${CCPP_SUITES}
  ENABLE_OPTIONS=${ENABLE_OPTIONS}
  DISABLE_OPTIONS=${DISABLE_OPTIONS}
  REMOVE=${REMOVE}
  CONTINUE=${CONTINUE}
  BUILD_TYPE=${BUILD_TYPE}
  BUILD_JOBS=${BUILD_JOBS}
  VERBOSE=${VERBOSE}
  BUILD_UFS=${BUILD_UFS}
  BUILD_UFS_UTILS=${BUILD_UFS_UTILS}
  BUILD_UPP=${BUILD_UPP}
  BUILD_GSI=${BUILD_GSI}
  BUILD_RRFS_UTILS=${BUILD_RRFS_UTILS}
  BUILD_NEXUS=${BUILD_NEXUS}
  BUILD_AQM_UTILS=${BUILD_AQM_UTILS}

EOF_SETTINGS
}

# print usage error and exit
usage_error () {
  printf "ERROR: $1\n" >&2
  usage >&2
  exit 1
}

# default settings
LCL_PID=$$
SORC_DIR=$(cd "$(dirname "$(readlink -f -n "${BASH_SOURCE[0]}" )" )" && pwd -P)
HOME_DIR="${SORC_DIR}/.."
BUILD_DIR="${SORC_DIR}/build"
INSTALL_DIR="${SORC_DIR}/build"
BIN_DIR="exec"
COMPILER=""
APPLICATION=""
CCPP_SUITES=""
ENABLE_OPTIONS=""
DISABLE_OPTIONS=""
BUILD_TYPE="RELEASE"
BUILD_JOBS=4
REMOVE=false
CONTINUE=false
VERBOSE=false

# Turn off all apps to build and choose default later
DEFAULT_BUILD=true
BUILD_UFS="off"
BUILD_UFS_UTILS="off"
BUILD_UPP="off"
BUILD_GSI="off"
BUILD_RRFS_UTILS="off"
BUILD_NEXUS="off"
BUILD_AQM_UTILS="off"

# Make options
CLEAN=false
BUILD=false
MOVE=true
USE_SUB_MODULES=false #change default to true later

# process required arguments
if [[ ("$1" == "--help") || ("$1" == "-h") ]]; then
  usage
  exit 0
fi

# process optional arguments
while :; do
  case $1 in
    --help|-h) usage; exit 0 ;;
    --platform=?*|-p=?*) PLATFORM=${1#*=} ;;
    --platform|--platform=|-p|-p=) usage_error "$1 requires argument." ;;
    --compiler=?*|-c=?*) COMPILER=${1#*=} ;;
    --compiler|--compiler=|-c|-c=) usage_error "$1 requires argument." ;;
    --app=?*|-a=?*) APPLICATION=${1#*=} ;;
    --app|--app=|-a|-a=) usage_error "$1 requires argument." ;;
    --ccpp=?*) CCPP_SUITES=${1#*=} ;;
    --ccpp|--ccpp=) usage_error "$1 requires argument." ;;
    --enable-options=?*) ENABLE_OPTIONS=${1#*=} ;;
    --enable-options|--enable-options=) usage_error "$1 requires argument." ;;
    --disable-options=?*) DISABLE_OPTIONS=${1#*=} ;;
    --disable-options|--disable-options=) usage_error "$1 requires argument." ;;
    --remove) REMOVE=true ;;
    --remove=?*|--remove=) usage_error "$1 argument ignored." ;;
    --continue) CONTINUE=true ;;
    --continue=?*|--continue=) usage_error "$1 argument ignored." ;;
    --clean) CLEAN=true ;;
    --build) BUILD=true ;;
    --move) MOVE=true ;;
    --build-dir=?*) BUILD_DIR=${1#*=} ;;
    --build-dir|--build-dir=) usage_error "$1 requires argument." ;;
    --install-dir=?*) INSTALL_DIR=${1#*=} ;;
    --install-dir|--install-dir=) usage_error "$1 requires argument." ;;
    --bin-dir=?*) BIN_DIR=${1#*=} ;;
    --bin-dir|--bin-dir=) usage_error "$1 requires argument." ;;
    --build-type=?*) BUILD_TYPE=${1#*=} ;;
    --build-type|--build-type=) usage_error "$1 requires argument." ;;
    --build-jobs=?*) BUILD_JOBS=$((${1#*=})) ;;
    --build-jobs|--build-jobs=) usage_error "$1 requires argument." ;;
    --verbose|-v) VERBOSE=true ;;
    --verbose=?*|--verbose=) usage_error "$1 argument ignored." ;;
    --use-sub-modules) USE_SUB_MODULES=true ;;
    # targets
    default) ;;
    all) DEFAULT_BUILD=false; BUILD_UFS="on";
         BUILD_UFS_UTILS="on"; BUILD_UPP="on";
         BUILD_GSI="on"; BUILD_RRFS_UTILS="on";;
    ufs) DEFAULT_BUILD=false; BUILD_UFS="on" ;;
    ufs_utils) DEFAULT_BUILD=false; BUILD_UFS_UTILS="on" ;;
    upp) DEFAULT_BUILD=false; BUILD_UPP="on" ;;
    gsi) DEFAULT_BUILD=false; BUILD_GSI="on" ;;
    rrfs_utils) DEFAULT_BUILD=false; BUILD_RRFS_UTILS="on" ;;
    nexus) DEFAULT_BUILD=false; BUILD_NEXUS="on" ;;
    aqm_utils) DEFAULT_BUILD=false; BUILD_AQM_UTILS="on" ;;
    # unknown
    -?*|?*) usage_error "Unknown option $1" ;;
    *) break
  esac
  shift
done

# Ensure uppercase / lowercase ============================================
APPLICATION="${APPLICATION^^}"
PLATFORM="${PLATFORM,,}"
COMPILER="${COMPILER,,}"
EXTERNALS="${EXTERNALS^^}"

# check if PLATFORM is set
if [ -z $PLATFORM ] ; then
  printf "\nERROR: Please set PLATFORM.\n\n"
  usage
  exit 0
fi
# set PLATFORM (MACHINE)
MACHINE="${PLATFORM}"
printf "PLATFORM(MACHINE)=${PLATFORM}\n" >&2

# choose default apps to build
if [ "${DEFAULT_BUILD}" = true ]; then
  BUILD_UFS="on"
  BUILD_UFS_UTILS="on"
  BUILD_UPP="on"
  BUILD_GSI="on"
  BUILD_RRFS_UTILS="on"
fi

# Choose components to build for air quality modeling (RRFS-AQM)
if [ "${APPLICATION}" = "ATMAQ" ]; then
  if [ "${DEFAULT_BUILD}" = true ]; then
    BUILD_NEXUS="on"
    BUILD_AQM_UTILS="on"
  fi
  if [ "${PLATFORM}" = "wcoss2" ]; then
    BUILD_POST_STAT="on"
  else
    BUILD_POST_STAT="off"
  fi
fi

set -eu

# automatically determine compiler
if [ -z "${COMPILER}" ] ; then
  case ${PLATFORM} in
    jet|hera|gaea) COMPILER=intel ;;
    orion) COMPILER=intel ;;
    wcoss2) COMPILER=intel ;;
    cheyenne) COMPILER=intel ;;
    macos|singularity) COMPILER=gnu ;;
    odin|noaacloud) COMPILER=intel ;;
    *)
      COMPILER=intel
      printf "WARNING: Setting default COMPILER=intel for new platform ${PLATFORM}\n" >&2;
      ;;
  esac
fi

printf "COMPILER=${COMPILER}\n" >&2

# print settings
if [ "${VERBOSE}" = true ] ; then
  settings
fi

# source version file only if it is specified in versions directory
BUILD_VERSION_FILE="${HOME_DIR}/versions/build.ver.${PLATFORM}"
if [ -f ${BUILD_VERSION_FILE} ]; then
  . ${BUILD_VERSION_FILE}
fi
RUN_VERSION_FILE="${HOME_DIR}/versions/run.ver.${PLATFORM}"
if [ -f ${RUN_VERSION_FILE} ]; then
  . ${RUN_VERSION_FILE}
fi

# set MODULE_FILE for this platform/compiler combination
MODULE_FILE="build_${PLATFORM}_${COMPILER}"
if [ ! -f "${HOME_DIR}/modulefiles/${MODULE_FILE}.lua" ]; then
  printf "ERROR: module file does not exist for platform/compiler\n" >&2
  printf "  MODULE_FILE=${MODULE_FILE}\n" >&2
  printf "  PLATFORM=${PLATFORM}\n" >&2
  printf "  COMPILER=${COMPILER}\n\n" >&2
  printf "Please make sure PLATFORM and COMPILER are set correctly\n" >&2
  usage >&2
  exit 64
fi

printf "MODULE_FILE=${MODULE_FILE}\n" >&2

# if build directory already exists then exit
if [ "${REMOVE}" = true ]; then
  printf "Remove build directory\n"
  printf "  BUILD_DIR=${BUILD_DIR}\n\n"
  rm -rf ${BUILD_DIR}
elif [ "${CONTINUE}" = true ]; then
  printf "Continue build in directory\n"
  printf "  BUILD_DIR=${BUILD_DIR}\n\n"
else
  if [ -d "${BUILD_DIR}" ]; then
    while true; do
      if [[ $(ps -o stat= -p ${LCL_PID}) != *"+"* ]] ; then
        printf "ERROR: Build directory already exists\n" >&2
        printf "  BUILD_DIR=${BUILD_DIR}\n\n" >&2
        usage >&2
        exit 64
      fi
      # interactive selection
      printf "Build directory (${BUILD_DIR}) already exists\n"
      printf "Please choose what to do:\n\n"
      printf "[R]emove the existing directory\n"
      printf "[C]ontinue building in the existing directory\n"
      printf "[Q]uit this build script\n"
      read -p "Choose an option (R/C/Q):" choice
      case ${choice} in
        [Rr]* ) rm -rf ${BUILD_DIR}; break ;;
        [Cc]* ) break ;;
        [Qq]* ) exit ;;
        * ) printf "Invalid option selected.\n" ;;
      esac
    done
  fi
fi

# cmake settings
CMAKE_SETTINGS="\
 -DCMAKE_BUILD_TYPE=${BUILD_TYPE}\
 -DCMAKE_INSTALL_PREFIX=${INSTALL_DIR}\
 -DCMAKE_INSTALL_BINDIR=${BIN_DIR}\
 -DBUILD_UFS=${BUILD_UFS}\
 -DBUILD_UFS_UTILS=${BUILD_UFS_UTILS}\
 -DBUILD_UPP=${BUILD_UPP}\
 -DBUILD_GSI=${BUILD_GSI}\
 -DBUILD_RRFS_UTILS=${BUILD_RRFS_UTILS}\
 -DBUILD_NEXUS=${BUILD_NEXUS}\
 -DBUILD_AQM_UTILS=${BUILD_AQM_UTILS}"

if [ ! -z "${APPLICATION}" ]; then
  CMAKE_SETTINGS="${CMAKE_SETTINGS} -DAPP=${APPLICATION}"
fi
if [ ! -z "${CCPP_SUITES}" ]; then
  CMAKE_SETTINGS="${CMAKE_SETTINGS} -DCCPP_SUITES=${CCPP_SUITES}"
fi
if [ ! -z "${ENABLE_OPTIONS}" ]; then
  CMAKE_SETTINGS="${CMAKE_SETTINGS} -DENABLE_OPTIONS=${ENABLE_OPTIONS}"
fi
if [ ! -z "${DISABLE_OPTIONS}" ]; then
  CMAKE_SETTINGS="${CMAKE_SETTINGS} -DDISABLE_OPTIONS=${DISABLE_OPTIONS}"
fi
if [ "${APPLICATION}" = "ATMAQ" ]; then
  CMAKE_SETTINGS="${CMAKE_SETTINGS} -DCPL_AQM=ON -DBUILD_POST_STAT=${BUILD_POST_STAT}"
fi

# make settings
MAKE_SETTINGS="-j ${BUILD_JOBS}"
if [ "${VERBOSE}" = true ]; then
  MAKE_SETTINGS="${MAKE_SETTINGS} VERBOSE=1"
fi

# Before we go on load modules, we first need to activate Lmod for some systems
source ${HOME_DIR}/etc/lmod-setup.sh $MACHINE

# source the module file for this platform/compiler combination, then build the code
printf "... Load MODULE_FILE and create BUILD directory ...\n"

if [ $USE_SUB_MODULES = true ]; then
    #helper to try and load module
    function load_module() {

        set +e
        #try most specialized modulefile first
        MODF="$1${PLATFORM}.${COMPILER}"
        if [ $BUILD_TYPE != "RELEASE" ]; then
            MODF="${MODF}.debug"
        else
            MODF="${MODF}.release"
        fi
        module is-avail ${MODF}
        if [ $? -eq 0 ]; then
            module load ${MODF}
            return
        fi
        # without build type
        MODF="$1${PLATFORM}.${COMPILER}"
        module is-avail ${MODF}
        if [ $? -eq 0 ]; then
            module load ${MODF}
            return
        fi
        # without compiler
        MODF="$1${PLATFORM}"
        module is-avail ${MODF}
        if [ $? -eq 0 ]; then
            module load ${MODF}
            return
        fi
        set -e

        # else fallback on app level modulefile
        printf "... Fall back to app level modulefile ...\n"
        module use ${HOME_DIR}/modulefiles
        module load ${MODULE_FILE}
    }
    if [ $BUILD_UFS = "on" ]; then
        printf "... Loading UFS modules ...\n"
        module use ${SORC_DIR}/ufs-weather-model/modulefiles
        load_module "ufs_"
    fi
    if [ $BUILD_UFS_UTILS = "on" ]; then
        printf "... Loading UFS_UTILS modules ...\n"
        module use ${SORC_DIR}/UFS_UTILS/modulefiles
        load_module "build."
    fi
    if [ $BUILD_UPP = "on" ]; then
        printf "... Loading UPP modules ...\n"
        module use ${SORC_DIR}/UPP/modulefiles
        load_module ""
    fi
    if [ $BUILD_GSI = "on" ]; then
        printf "... Loading GSI modules ...\n"
        module use ${SORC_DIR}/gsi/modulefiles
        load_module "gsi_"
    fi
    if [ $BUILD_RRFS_UTILS = "on" ]; then
        printf "... Loading RRFS_UTILS modules ...\n"
        load_module ""
    fi
    if [ $BUILD_NEXUS = "on" ]; then
        printf "... Loading NEXUS modules ...\n"
        module use ${SORC_DIR}/arl_nexus/modulefiles
        load_module ""
    fi
    if [ $BUILD_AQM_UTILS = "on" ]; then
        printf "... Loading AQM-utils modules ...\n"
        module use ${SORC_DIR}/AQM-utils/modulefiles
        load_module ""
    fi
else
    module use ${HOME_DIR}/modulefiles
    module load ${MODULE_FILE}
fi
module list

#####################################################################
# Temporary fix
#######################################

# CCPP SDF file for FV3_HRRR_gf
UWM_CCPP_DIR="${SORC_DIR}/ufs-weather-model/FV3/ccpp"
SDF_GF_FN="suite_FV3_HRRR_gf.xml"
SDF_GF_FP="${UWM_CCPP_DIR}/suites/${SDF_GF_FN}"
if [ ! -f "${SDF_GF_FP}" ]; then
  cp "${UWM_CCPP_DIR}/suites_not_used/${SDF_GF_FN}" "${SDF_GF_FP}"
fi

RRFS_BRIDGELOAN_DIR="${SORC_DIR}/rrfs_bridgeloan"
if [ -d "${RRFS_BRIDGELOAN_DIR}" ]; then
  # Temporary fix for specific hash of GSI
  GSI_HEAD_FP="${SORC_DIR}/gsi/.git/HEAD"
  GSI_HEAD_VALUE=$(<${GSI_HEAD_FP})
  GSI_hash="${GSI_HEAD_VALUE:0:7}"
  printf " *** Hash of GSI: %s \n" ${GSI_hash}
  if [ "${GSI_hash}" = "00cac54" ]; then
    cp "${RRFS_BRIDGELOAN_DIR}/gsi/constants.f90" "${SORC_DIR}/gsi/constants.f90"
    printf " *** Some files of GSI have been replaced. *** \n"
  fi

  # Temporary fix for specific hash of ufs-weather-model
  UWM_HEAD_FP="${SORC_DIR}/ufs-weather-model/.git/HEAD"
  UWM_HEAD_VALUE=$(<${UWM_HEAD_FP})
  UWM_hash="${UWM_HEAD_VALUE:0:7}"
  printf " *** Hash of UFS Weather Model: %s \n" ${UWM_hash}
  if [ "${UWM_hash}" = "f1f0180" ]; then
    UWM_SRC_DIR="${RRFS_BRIDGELOAN_DIR}/ufs_weather_model/FV3"
    UWM_DST_DIR="${SORC_DIR}/ufs-weather-model/FV3"
    cp "${UWM_SRC_DIR}/io/fv3atm_clm_lake_io.F90" "${UWM_DST_DIR}/io/fv3atm_clm_lake_io.F90"
    cp "${UWM_SRC_DIR}/io/fv3atm_restart_io.F90" "${UWM_DST_DIR}/io/fv3atm_restart_io.F90"
    cp "${UWM_SRC_DIR}/io/fv3atm_rrfs_sd_io.F90" "${UWM_DST_DIR}/io/fv3atm_rrfs_sd_io.F90"
    cp "${UWM_SRC_DIR}/io/fv3atm_sfc_io.F90" "${UWM_DST_DIR}/io/fv3atm_sfc_io.F90"
    cp "${UWM_SRC_DIR}/atmos_cubed_sphere/tools/fv_io.F90" "${UWM_DST_DIR}/atmos_cubed_sphere/tools/fv_io.F90"

    printf " *** Some files of UFS Weather Model have been replaced. *** \n"
  fi
fi
#####################################################################

mkdir -p ${BUILD_DIR}
cd ${BUILD_DIR}

if [ "${CLEAN}" = true ]; then
    if [ -f $PWD/Makefile ]; then
       printf "... Clean executables ...\n"
       make ${MAKE_SETTINGS} clean 2>&1 | tee log.make
    fi
elif [ "${BUILD}" = true ]; then
    printf "... Generate CMAKE configuration ...\n"
    cmake ${SORC_DIR} ${CMAKE_SETTINGS} 2>&1 | tee log.cmake

    printf "... Compile executables ...\n"
    make ${MAKE_SETTINGS} build 2>&1 | tee log.make
else
    printf "... Generate CMAKE configuration ...\n"
    cmake ${SORC_DIR} ${CMAKE_SETTINGS} 2>&1 | tee log.cmake

    printf "... Compile and install executables ...\n"
    make ${MAKE_SETTINGS} install 2>&1 | tee log.make

    if [ "${MOVE}" = true ]; then
       if [[ ! ${HOME_DIR} -ef ${INSTALL_DIR} ]]; then
           printf "... Moving executables to final locations ...\n"
           mkdir -p ${HOME_DIR}/${BIN_DIR}
           mv ${INSTALL_DIR}/${BIN_DIR}/* ${HOME_DIR}/${BIN_DIR}
       fi
    fi
fi

exit 0