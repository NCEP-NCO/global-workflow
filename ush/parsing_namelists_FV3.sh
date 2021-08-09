#! /bin/sh
#####
## "parsing_namelist_FV3.sh"
## This script writes namelist for FV3 model
##
## This is the child script of ex-global forecast,
## writing namelist for FV3
## This script is a direct execution.
#####

FV3_namelists(){

# copy over the tables
DIAG_TABLE_BASE=${DIAG_TABLE_BASE:-$PARM_FV3DIAG/diag_table}
DIAG_TABLE=${DIAG_TABLE:-$PARM_FV3DIAG/diag_table_aod}
DATA_TABLE=${DATA_TABLE:-$PARM_FV3DIAG/data_table}
FIELD_TABLE=${FIELD_TABLE:-$PARM_FV3DIAG/field_table}

# build the diag_table with the experiment name and date stamp
if [ $DOIAU = "YES" ]; then
cat > diag_table << EOF
FV3 Forecast
${gPDY:0:4} ${gPDY:4:2} ${gPDY:6:2} ${gcyc} 0 0
EOF
cat $DIAG_TABLE_BASE >> diag_table
else
cat > diag_table << EOF
FV3 Forecast
${sPDY:0:4} ${sPDY:4:2} ${sPDY:6:2} ${scyc} 0 0
EOF
cat $DIAG_TABLE_BASE >> diag_table
fi

# Append AOD diag table for MERRA2
if [ $IAER = "1011" ]; then
  cat $DIAG_TABLE >> diag_table
fi

$NCP $DATA_TABLE  data_table
$NCP $FIELD_TABLE field_table

cat > input.nml <<EOF
&amip_interp_nml
  interp_oi_sst = .true.
  use_ncep_sst = .true.
  use_ncep_ice = .false.
  no_anom_sst = .false.
  data_set = 'reynolds_oi'
  date_out_of_range = 'climo'
  $amip_interp_nml
/

&atmos_model_nml
  blocksize = $blocksize
  chksum_debug = $chksum_debug
  dycore_only = $dycore_only
  ccpp_suite = '$CCPP_SUITE'
  fdiag = $FDIAG
  fhmax = $FHMAX
  fhout = $FHOUT
  fhmaxhf = $FHMAX_HF
  fhouthf = $FHOUT_HF
  $atmos_model_nml
/

&diag_manager_nml
  prepend_date = .false.
  $diag_manager_nml
/

&fms_io_nml
  checksum_required = .false.
  max_files_r = 100
  max_files_w = 100
  $fms_io_nml
/

&mpp_io_nml
  shuffle=${shuffle:-1}
  deflate_level=${deflate_level:-1}
/

&fms_nml
  clock_grain = 'ROUTINE'
  domains_stack_size = ${domains_stack_size:-3000000}
  print_memory_usage = ${print_memory_usage:-".false."}
  $fms_nml
/

&fv_core_nml
  layout = $layout_x,$layout_y
  io_layout = $io_layout
  npx = $npx
  npy = $npy
  ntiles = $ntiles
  npz = $npz
EOF

if [ $cpl = .true. ]; then
  cat >> input.nml << EOF
  dz_min =  ${dz_min:-"6"}    ! no longer in develop branch
  psm_bc = ${psm_bc:-"0"}    ! no longer in develop branch
EOF
fi

cat >> input.nml << EOF
  grid_type = -1
  make_nh = $make_nh
  fv_debug = ${fv_debug:-".false."}
  range_warn = ${range_warn:-".true."}
  reset_eta = .false.
  n_sponge = ${n_sponge:-"10"}
  nudge_qv = ${nudge_qv:-".true."}
  nudge_dz = ${nudge_dz:-".false."}
  tau = ${tau:-10.}
  rf_cutoff = ${rf_cutoff:-"7.5e2"}
  d2_bg_k1 = ${d2_bg_k1:-"0.15"}
  d2_bg_k2 = ${d2_bg_k2:-"0.02"}
  kord_tm = ${kord_tm:-"-9"}
  kord_mt = ${kord_mt:-"9"}
  kord_wz = ${kord_wz:-"9"}
  kord_tr = ${kord_tr:-"9"}
  hydrostatic = $hydrostatic
  phys_hydrostatic = $phys_hydrostatic
  use_hydro_pressure = $use_hydro_pressure
  beta = 0.
  a_imp = 1.
  p_fac = 0.1
  k_split = $k_split
  n_split = $n_split
  nwat = ${nwat:-2}
  na_init = $na_init
  d_ext = 0.
  dnats = ${dnats:-0}
  fv_sg_adj = ${fv_sg_adj:-"450"}
  d2_bg = 0.
  nord = ${nord:-3}
  dddmp = ${dddmp:-0.1}
  d4_bg = ${d4_bg:-0.15}
  vtdm4 = $vtdm4
  delt_max = ${delt_max:-"0.002"}
  ke_bg = 0.
  do_vort_damp = $do_vort_damp
  external_ic = $external_ic
  external_eta = ${external_eta:-.true.}
  gfs_phil = ${gfs_phil:-".false."}
  nggps_ic = $nggps_ic
  mountain = $mountain
  ncep_ic = $ncep_ic
  d_con = $d_con
  hord_mt = $hord_mt
  hord_vt = $hord_xx
  hord_tm = $hord_xx
  hord_dp = -$hord_xx
  hord_tr = ${hord_tr:-"8"}
  adjust_dry_mass = ${adjust_dry_mass:-".true."}
  dry_mass=${dry_mass:-98320.0}
  consv_te = $consv_te
  do_sat_adj = ${do_sat_adj:-".false."}
  consv_am = .false.
  fill = .true.
  dwind_2d = .false.
  print_freq = $print_freq
  warm_start = $warm_start
  no_dycore = $no_dycore
  z_tracer = .true.
  agrid_vel_rst = ${agrid_vel_rst:-".true."}
  read_increment = $read_increment
  res_latlon_dynamics = $res_latlon_dynamics
  $fv_core_nml
/

&external_ic_nml
  filtered_terrain = $filtered_terrain
  levp = $LEVS
  gfs_dwinds = $gfs_dwinds
  checker_tr = .false.
  nt_checker = 0
  $external_ic_nml
/

&gfs_physics_nml
  fhzero       = $FHZER
  h2o_phys     = ${h2o_phys:-".true."}
  ldiag3d      = ${ldiag3d:-".false."}
  fhcyc        = $FHCYC
  use_ufo      = ${use_ufo:-".true."}
  pre_rad      = ${pre_rad:-".false."}
  imp_physics  = ${imp_physics:-"99"}
EOF

case "${CCPP_SUITE:-}" in
  "FV3_GFS_v15p2_coupled")
  cat >> input.nml << EOF
  oz_phys      = .false.
  oz_phys_2015 = .true.
EOF
  ;;
  "FV3_GSD_v0")
  cat >> input.nml << EOF
  iovr         = ${iovr:-"3"}
  ltaerosol    = ${ltaerosol:-".F."}
  lradar       = ${lradar:-".F."}
  ttendlim     = ${ttendlim:-0.005}
  oz_phys      = ${oz_phys:-".false."}
  oz_phys_2015 = ${oz_phys_2015:-".true."}
  lsoil_lsm    = ${lsoil_lsm:-"4"}
  do_mynnedmf  = ${do_mynnedmf:-".false."}
  do_mynnsfclay = ${do_mynnsfclay:-".false."}
  icloud_bl    = ${icloud_bl:-"1"}
  bl_mynn_edmf = ${bl_mynn_edmf:-"1"}
  bl_mynn_tkeadvect=${bl_mynn_tkeadvect:-".true."}
  bl_mynn_edmf_mom=${bl_mynn_edmf_mom:-"1"}
  min_lakeice  = ${min_lakeice:-"0.15"}
  min_seaice   = ${min_seaice:-"0.15"}
EOF
  ;;
  FV3_GFS_v16_coupled*)
  cat >> input.nml << EOF
  iovr         = ${iovr:-"3"}
  ltaerosol    = ${ltaerosol:-".false."}
  lradar       = ${lradar:-".false."}
  ttendlim     = ${ttendlim:-"0.005"}
  oz_phys      = ${oz_phys:-".false."}
  oz_phys_2015 = ${oz_phys_2015:-".true."}
  do_mynnedmf  = ${do_mynnedmf:-".false."}
  do_mynnsfclay = ${do_mynnsfclay:-".false."}
  icloud_bl    = ${icloud_bl:-"1"}
  bl_mynn_edmf = ${bl_mynn_edmf:-"1"}
  bl_mynn_tkeadvect = ${bl_mynn_tkeadvect:-".true."}
  bl_mynn_edmf_mom = ${bl_mynn_edmf_mom:-"1"}
  min_lakeice  = ${min_lakeice:-"0.15"}
  min_seaice   = ${min_seaice:-"0.15"}
EOF
  ;;
  FV3_GFS_v16*)
  cat >> input.nml << EOF
  iovr         = ${iovr:-"3"}
  ltaerosol    = ${ltaerosol:-".false."}
  lradar       = ${lradar:-".false."}
  ttendlim     = ${ttendlim:-"0.005"}
  oz_phys      = ${oz_phys:-".false."}
  oz_phys_2015 = ${oz_phys_2015:-".true."}
  lsoil_lsm    = ${lsoil_lsm:-"4"}
  do_mynnedmf  = ${do_mynnedmf:-".false."}
  do_mynnsfclay = ${do_mynnsfclay:-".false."}
  icloud_bl    = ${icloud_bl:-"1"}
  bl_mynn_edmf = ${bl_mynn_edmf:-"1"}
  bl_mynn_tkeadvect = ${bl_mynn_tkeadvect:-".true."}
  bl_mynn_edmf_mom = ${bl_mynn_edmf_mom:-"1"}
  min_lakeice  = ${min_lakeice:-"0.15"}
  min_seaice   = ${min_seaice:-"0.15"}
EOF
  ;;
  *)
  cat >> input.nml << EOF
  iovr         = ${iovr:-"3"}
EOF
  ;;
esac

cat >> input.nml <<EOF
  pdfcld       = ${pdfcld:-".false."}
  fhswr        = ${FHSWR:-"3600."}
  fhlwr        = ${FHLWR:-"3600."}
  ialb         = ${IALB:-"1"}
  iems         = ${IEMS:-"1"}
  iaer         = $IAER
  icliq_sw     = ${icliq_sw:-"2"}
  ico2         = $ICO2
  isubc_sw     = ${isubc_sw:-"2"}
  isubc_lw     = ${isubc_lw:-"2"}
  isol         = ${ISOL:-"2"}
  lwhtr        = ${lwhtr:-".true."}
  swhtr        = ${swhtr:-".true."}
  cnvgwd       = ${cnvgwd:-".true."}
  shal_cnv     = ${shal_cnv:-".true."}
  cal_pre      = ${cal_pre:-".true."}
  redrag       = ${redrag:-".true."}
  dspheat      = ${dspheat:-".true."}
  hybedmf      = ${hybedmf:-".false."}
  satmedmf     = ${satmedmf-".true."}
  isatmedmf    = ${isatmedmf-"1"}
  lheatstrg    = ${lheatstrg-".false."}
  lseaspray    = ${lseaspray:-".false."}
  random_clds  = ${random_clds:-".true."}
  trans_trac   = ${trans_trac:-".true."}
  cnvcld       = ${cnvcld:-".true."}
  imfshalcnv   = ${imfshalcnv:-"2"}
  imfdeepcnv   = ${imfdeepcnv:-"2"}
  cdmbgwd      = ${cdmbgwd:-"3.5,0.25"}
  prslrd0      = ${prslrd0:-"0."}
  ivegsrc      = ${ivegsrc:-"1"}
  isot         = ${isot:-"1"}
  lsoil        = ${lsoil:-"4"}
  lsm          = ${lsm:-"2"}
  iopt_dveg    = ${iopt_dveg:-"1"}
  iopt_crs     = ${iopt_crs:-"1"}
  iopt_btr     = ${iopt_btr:-"1"}
  iopt_run     = ${iopt_run:-"1"}
  iopt_sfc     = ${iopt_sfc:-"1"}
  iopt_frz     = ${iopt_frz:-"1"}
  iopt_inf     = ${iopt_inf:-"1"}
  iopt_rad     = ${iopt_rad:-"1"}
  iopt_alb     = ${iopt_alb:-"2"}
  iopt_snf     = ${iopt_snf:-"4"}
  iopt_tbot    = ${iopt_tbot:-"2"}
  iopt_stc     = ${iopt_stc:-"1"}
  debug        = ${gfs_phys_debug:-".false."}
  nstf_name    = $nstf_name
  nst_anl      = $nst_anl
  psautco      = ${psautco:-"0.0008,0.0005"}
  prautco      = ${prautco:-"0.00015,0.00015"}
  lgfdlmprad   = ${lgfdlmprad:-".false."}
  effr_in      = ${effr_in:-".false."}
  cplwav       = ${cplwav:-".false."}
  ldiag_ugwp   = ${ldiag_ugwp:-".false."}
EOF

if [ $cpl = .true. ]; then
  cat >> input.nml << EOF
  fscav_aero = ${fscav_aero:-'*:0.0'}
EOF
else
cat >> input.nml <<EOF
  do_tofd      = ${do_tofd:-".true."}
EOF
fi

cat >> input.nml <<EOF
  do_sppt      = ${DO_SPPT:-".false."}
  do_shum      = ${DO_SHUM:-".false."}
  do_skeb      = ${DO_SKEB:-".false."}
EOF

if [ $cpl = .true. ]; then
  cat >> input.nml << EOF
  frac_grid    = ${FRAC_GRID:-".true."}
  cplchm = ${cplchem:-".false."}
  cplflx       = $cplflx
  cplwav2atm   = ${cplwav2atm}
EOF
fi

# Add namelist for IAU
if [ $DOIAU = "YES" ]; then
  cat >> input.nml << EOF
  iaufhrs      = ${IAUFHRS}
  iau_delthrs  = ${IAU_DELTHRS}
  iau_inc_files= ${IAU_INC_FILES}
  iau_drymassfixer = .false.
EOF
fi

if [ ${DO_CA:-"NO"} = "YES" ]; then
  cat >> input.nml << EOF
  do_ca      = .True.
  ca_sgs     = ${ca_sgs:-".True."}
  nca        = ${nca:-"1"}
  scells     = ${scells:-"2600"}
  tlives     = ${tlives:-"1800"}
  nseed      = ${nseed:-"1"}
  nfracseed  = ${nfracseed:-"0.5"}
  rcell      = ${rcell:-"0.72"}
  ca_trigger = ${ca_trigger:-".True."}
  nspinup    = ${nspinup:-"1"}
  iseed_ca   = ${ISEED_CA:-"12345"}
EOF
fi

case ${gwd_opt:-"2"} in
  1)
  cat >> input.nml <<EOF
  gwd_opt      = 1
  do_ugwp      = .false.
  do_ugwp_v0   = .false.
  do_ugwp_v1   = .false.
  do_tofd      = .true.
  $gfs_physics_nml
/
&cires_ugwp_nml
  knob_ugwp_version = ${knob_ugwp_version:-0}
  knob_ugwp_solver  = ${knob_ugwp_solver:-2}
  knob_ugwp_source  = ${knob_ugwp_source:-1,1,0,0}
  knob_ugwp_wvspec  = ${knob_ugwp_wvspec:-1,25,25,25}
  knob_ugwp_azdir   = ${knob_ugwp_azdir:-2,4,4,4}
  knob_ugwp_stoch   = ${knob_ugwp_stoch:-0,0,0,0}
  knob_ugwp_effac   = ${knob_ugwp_effac:-1,1,1,1}
  knob_ugwp_doaxyz  = ${knob_ugwp_doaxyz:-1}
  knob_ugwp_doheat  = ${knob_ugwp_doheat:-1}
  knob_ugwp_dokdis  = ${knob_ugwp_dokdis:-1}
  knob_ugwp_ndx4lh  = ${knob_ugwp_ndx4lh:-1}
  launch_level      = ${launch_level:-54}
  $cires_ugwp_nml
/

EOF
  ;;
  2)
  cat >> input.nml << EOF
  gwd_opt      = 2
  do_ugwp      = .false.
  do_ugwp_v0   = .false.
  do_ugwp_v1   = .true.
  do_tofd      = .false.
  do_ugwp_v1_orog_only = .false.
  do_gsl_drag_ls_bl    = ${do_gsl_drag_ls_bl:-".true."}
  do_gsl_drag_ss       = ${do_gsl_drag_ss:-".true."}
  do_gsl_drag_tofd     = ${do_gsl_drag_tofd:-".true."}
  $gfs_physics_nml
/
&cires_ugwp_nml
  knob_ugwp_version = ${knob_ugwp_version:-1}
  knob_ugwp_solver  = ${knob_ugwp_solver:-2}
  knob_ugwp_source  = ${knob_ugwp_source:-1,1,0,0}
  knob_ugwp_wvspec  = ${knob_ugwp_wvspec:-1,25,25,25}
  knob_ugwp_azdir   = ${knob_ugwp_azdir:-2,4,4,4}
  knob_ugwp_stoch   = ${knob_ugwp_stoch:-0,0,0,0}
  knob_ugwp_effac   = ${knob_ugwp_effac:-1,1,1,1}
  knob_ugwp_doaxyz  = ${knob_ugwp_doaxyz:-1}
  knob_ugwp_doheat  = ${knob_ugwp_doheat:-1}
  knob_ugwp_dokdis  = ${knob_ugwp_dokdis:-2}
  knob_ugwp_ndx4lh  = ${knob_ugwp_ndx4lh:-4}
  knob_ugwp_palaunch = ${knob_ugwp_palaunch:-275.0e2}
  knob_ugwp_nslope   = ${knob_ugwp_nslope:-1}
  knob_ugwp_lzmax    = ${knob_ugwp_lzmax:-15.750e3}
  knob_ugwp_lzmin    = ${knob_ugwp_lzmin:-0.75e3}
  knob_ugwp_lzstar   = ${knob_ugwp_lzstar:-2.0e3}
  knob_ugwp_taumin   = ${knob_ugwp_taumin:-0.25e-3}
  knob_ugwp_tauamp   = ${knob_ugwp_tauamp:-3.0e-3}
  knob_ugwp_lhmet    = ${knob_ugwp_lhmet:-200.0e3}
  knob_ugwp_orosolv  = ${knob_ugwp_orosolv:-'pss-1986'}
  $cires_ugwp_nml
/
EOF
  ;;
  *)
    echo "FATAL: Invalid gwd_opt specified: $gwd_opt"
    exit 1
  ;;
esac

echo "" >> input.nml

cat >> input.nml <<EOF
&gfdl_cloud_microphysics_nml
  sedi_transport = .true.
  do_sedi_heat = .false.
  rad_snow = .true.
  rad_graupel = .true.
  rad_rain = .true.
  const_vi = .F.
  const_vs = .F.
  const_vg = .F.
  const_vr = .F.
  vi_max = 1.
  vs_max = 2.
  vg_max = 12.
  vr_max = 12.
  qi_lim = 1.
  prog_ccn = .false.
  do_qa = .true.
  fast_sat_adj = .true.
  tau_l2v = 225.
  tau_v2l = 150.
  tau_g2v = 900.
  rthresh = 10.e-6  ! This is a key parameter for cloud water
  dw_land  = 0.16
  dw_ocean = 0.10
  ql_gen = 1.0e-3
  ql_mlt = 1.0e-3
  qi0_crt = 8.0E-5
  qs0_crt = 1.0e-3
  tau_i2s = 1000.
  c_psaci = 0.05
  c_pgacs = 0.01
  rh_inc = 0.30
  rh_inr = 0.30
  rh_ins = 0.30
  ccn_l = 300.
  ccn_o = 100.
  c_paut = 0.5
  c_cracw = 0.8
  use_ppm = .false.
  use_ccn = .true.
  mono_prof = .true.
  z_slope_liq  = .true.
  z_slope_ice  = .true.
  de_ice = .false.
  fix_negative = .true.
  icloud_f = 1
  mp_time = 150.
  reiflag = ${reiflag:-"2"}

  $gfdl_cloud_microphysics_nml
/

&interpolator_nml
  interp_method = 'conserve_great_circle'
  $interpolator_nml
/

&namsfc
  FNGLAC   = '${FNGLAC}'
  FNMXIC   = '${FNMXIC}'
  FNTSFC   = '${FNTSFC}'
  FNSNOC   = '${FNSNOC}'
  FNZORC   = '${FNZORC}'
  FNALBC   = '${FNALBC}'
  FNALBC2  = '${FNALBC2}'
  FNAISC   = '${FNAISC}'
  FNTG3C   = '${FNTG3C}'
  FNVEGC   = '${FNVEGC}'
  FNVETC   = '${FNVETC}'
  FNSOTC   = '${FNSOTC}'
  FNSMCC   = '${FNSMCC}'
  FNMSKH   = '${FNMSKH}'
  FNTSFA   = '${FNTSFA}'
  FNACNA   = '${FNACNA}'
  FNSNOA   = '${FNSNOA}'
  FNVMNC   = '${FNVMNC}'
  FNVMXC   = '${FNVMXC}'
  FNSLPC   = '${FNSLPC}'
  FNABSC   = '${FNABSC}'
  LDEBUG = ${LDEBUG:-".false."}
  FSMCL(2) = ${FSMCL2:-99999}
  FSMCL(3) = ${FSMCL3:-99999}
  FSMCL(4) = ${FSMCL4:-99999}
  LANDICE  = ${landice:-".true."}
  FTSFS = ${FTSFS:-90}
  FAISL = ${FAISL:-99999}
  FAISS = ${FAISS:-99999}
  FSNOL = ${FSNOL:-99999}
  FSNOS = ${FSNOS:-99999}
  FSICL = ${FSICL:-99999}
  FSICS = ${FSICS:-99999}
  FTSFL = ${FTSFL:-99999}
  FVETL = ${FVETL:-99999}
  FSOTL = ${FSOTL:-99999}
  FvmnL = ${FvmnL:-99999}
  FvmxL = ${FvmxL:-99999}
  FSLPL = ${FSLPL:-99999}
  FABSL = ${FABSL:-99999}
  $namsfc_nml
/

&fv_grid_nml
  grid_file = 'INPUT/grid_spec.nc'
  $fv_grid_nml
/
EOF

# Add namelist for stochastic physics options
echo "" >> input.nml
if [ $MEMBER -gt 0 ]; then

    cat >> input.nml << EOF
&nam_stochy
EOF

  if [ $DO_SKEB = ".true." ]; then
    cat >> input.nml << EOF
  skeb = $SKEB
  iseed_skeb = ${ISEED_SKEB:-$ISEED}
  skeb_tau = ${SKEB_TAU:-"-999."}
  skeb_lscale = ${SKEB_LSCALE:-"-999."}
  skebnorm = ${SKEBNORM:-"1"}
  skeb_npass = ${SKEB_nPASS:-"30"}
  skeb_vdof = ${SKEB_VDOF:-"5"}
EOF
  fi

  if [ $DO_SHUM = ".true." ]; then
    cat >> input.nml << EOF
  shum = $SHUM
  iseed_shum = ${ISEED_SHUM:-$ISEED}
  shum_tau = ${SHUM_TAU:-"-999."}
  shum_lscale = ${SHUM_LSCALE:-"-999."}
EOF
  fi

  if [ $DO_SPPT = ".true." ]; then
    cat >> input.nml << EOF
  sppt = $SPPT
  iseed_sppt = ${ISEED_SPPT:-$ISEED}
  sppt_tau = ${SPPT_TAU:-"-999."}
  sppt_lscale = ${SPPT_LSCALE:-"-999."}
  sppt_logit = ${SPPT_LOGIT:-".true."}
  sppt_sfclimit = ${SPPT_SFCLIMIT:-".true."}
  use_zmtnblck = ${use_zmtnblck:-".true."}
EOF
  fi

  cat >> input.nml << EOF
  $nam_stochy_nml
/
EOF


    cat >> input.nml << EOF
&nam_sfcperts
  $nam_sfcperts_nml
/
EOF

else

  cat >> input.nml << EOF
&nam_stochy
/
&nam_sfcperts
/
EOF

fi

echo "$(cat input.nml)"
}
