      module namelist_soilveg
      implicit none
      save

      INTEGER MAX_SLOPETYP
      INTEGER MAX_SOILTYP
      INTEGER MAX_VEGTYP

      PARAMETER(MAX_SLOPETYP = 30)
      PARAMETER(MAX_SOILTYP = 30)
      PARAMETER(MAX_VEGTYP = 30)

      REAL SLOPE_DATA(MAX_SLOPETYP)
      REAL RSMTBL(MAX_VEGTYP)
      REAL RGLTBL(MAX_VEGTYP)
      REAL HSTBL(MAX_VEGTYP)
      REAL SNUPX(MAX_VEGTYP)
      REAL BB(MAX_SOILTYP)
      REAL DRYSMC(MAX_SOILTYP)
      REAL F11(MAX_SOILTYP)
      REAL MAXSMC(MAX_SOILTYP)
      REAL REFSMC(MAX_SOILTYP)
      REAL SATPSI(MAX_SOILTYP)
      REAL SATDK(MAX_SOILTYP)
      REAL SATDW(MAX_SOILTYP)
      REAL WLTSMC(MAX_SOILTYP)
      REAL QTZ(MAX_SOILTYP)
      LOGICAL LPARAM
      REAL ZBOT_DATA
      REAL SALP_DATA
      REAL CFACTR_DATA
      REAL CMCMAX_DATA
      REAL SBETA_DATA
      REAL RSMAX_DATA
      REAL TOPT_DATA
      REAL REFDK_DATA
      REAL FRZK_DATA
      INTEGER BARE
      INTEGER DEFINED_VEG
      INTEGER DEFINED_SOIL
      INTEGER DEFINED_SLOPE
      REAL FXEXP_DATA
      INTEGER NROOT_DATA(MAX_VEGTYP)
      REAL REFKDT_DATA
      REAL Z0_DATA(MAX_VEGTYP)
      REAL CZIL_DATA
      REAL LAI_DATA(MAX_VEGTYP)
      REAL CSOIL_DATA
      end module namelist_soilveg
