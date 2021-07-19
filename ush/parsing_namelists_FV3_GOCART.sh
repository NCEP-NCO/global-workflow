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
DIAG_TABLE=${DIAG_TABLE:-$PARM_FV3DIAG/diag_table_aer}
DATA_TABLE=${DATA_TABLE:-$PARM_FV3DIAG/data_table}
FIELD_TABLE=${FIELD_TABLE:-$PARM_FV3DIAG/field_table_aer}

# build the diag_table with the experiment name and date stamp
if [ $DOIAU = "YES" ]; then
cat > diag_table << EOF
FV3 Forecast
${gPDY:0:4} ${gPDY:4:2} ${gPDY:6:2} ${gcyc} 0 0
EOF
cat $DIAG_TABLE >> diag_table
else
cat > diag_table << EOF
FV3 Forecast
${sPDY:0:4} ${sPDY:4:2} ${sPDY:6:2} ${scyc} 0 0
EOF
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
  fdiag = $FDIAG
  fhmax = $FHMAX
  fhout = $FHOUT
  fhmaxhf = $FHMAX_HF     ! CROW configured
  fhouthf = $FHOUT_HF     ! CROW configured
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
  grid_type = -1
  make_nh = $make_nh 
  fv_debug = ${fv_debug:-".false."}
  range_warn = ${range_warn:-".false."}
  reset_eta = .false.
  n_sponge = ${n_sponge:-"10"}    ! CROW configured
  nudge_qv = ${nudge_qv:-".true."}
  tau = ${tau:-10.}
  rf_cutoff = ${rf_cutoff:-"7.5e2"}
  d2_bg_k1 = ${d2_bg_k1:-"0.15"}    ! CROW configured
  d2_bg_k2 = ${d2_bg_k2:-"0.02"}    ! CROW configured
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
  nwat = ${nwat:-2}		! CROW configured
  na_init = $na_init
  d_ext = 0.
  dnats = ${dnats:-0}		! CROW configured
  fv_sg_adj = ${fv_sg_adj:-"450"}
  d2_bg = 0.
  nord = ${nord:-3}		! CROW configured
  dddmp = ${dddmp:-0.2}		! CROW configured
  d4_bg = ${d4_bg:-0.15}	! CROW configured
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
  hord_mt = $hord_mt		! CROW configured
  hord_vt = $hord_xx		! CROW configured
  hord_tm = $hord_xx		! CROW configured
  hord_dp = -$hord_xx		! CROW configured
  hord_tr = ${hord_tr:-"8"}	
  adjust_dry_mass = ${adjust_dry_mass:-".true."}
  consv_te = $consv_te
  do_sat_adj = ${do_sat_adj:-".false."}	! CROW configured
  consv_am = .false.
  fill = .true.
  dwind_2d = .false.
  print_freq = $print_freq
  warm_start = $warm_start
  no_dycore = $no_dycore
  z_tracer = .true.
  read_increment = $read_increment
  res_latlon_dynamics = $res_latlon_dynamics
  $fv_core_nml
/

&cires_ugwp_nml
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
       knob_ugwp_version = ${knob_ugwp_version:-0}
       launch_level      = ${launch_level:-54}                   
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
       fhzero         = 6.
       ldiag3d        = .false.
       ldiag_ugwp     = .F.
       do_ugwp        = .F.
       do_tofd        = .F.
       fhcyc          = 24.
       nst_anl        = .true.
       use_ufo        = .true.
       pre_rad        = .false.
       ncld           = 5
       imp_physics    = 11
       pdfcld         = .false.
       fhswr          = 3600.
       fhlwr          = 3600.
       ialb           = 1
       iems           = 1
       IAER           = 111
       ico2           = 2
       isubc_sw       = 2
       isubc_lw       = 2
       isol           = 2
       lwhtr          = .true.
       swhtr          = .true.
       cnvgwd         = .true.
       shal_cnv       = .true.
       cal_pre        = .false.
       redrag         = .true.
       dspheat        = .true.
       hybedmf        = .T.
       satmedmf       = .F.
       lheatstrg      = .F.
       lgfdlmprad     = .F.
       effr_in        = .F.
       random_clds    = .false.
       trans_trac     = .true.
       cnvcld         = .true.
       imfshalcnv     = 2
       imfdeepcnv     = 2
       cdmbgwd        = 3.5,0.25
       prslrd0        = 0.
       ivegsrc        = 1
       isot           = 1
       lsm            = 1
       iopt_dveg      = 2
       iopt_crs       = 1
       iopt_btr       = 1
       iopt_run       = 1
       iopt_sfc       = 1
       iopt_frz       = 1
       iopt_inf       = 1
       iopt_rad       = 1
       iopt_alb       = 2
       iopt_snf       = 4
       iopt_tbot      = 2
       iopt_stc       = 1
       debug          = .false.
       h2o_phys       = .F.
       nstf_name      = 2,1,1,0,5
       iau_drymassfixer = .false.
       cplflx         = .F.
       cplwav         = .F.
       cplwav2atm     = .F.
       cplgocart      = .T.
       xkzminv        = 0.3
       xkzm_m         = 1.0
       xkzm_h         = 1.0
EOF

cat >> input.nml <<EOF
  $gfs_physics_nml
/
EOF

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
       tau_l2v = 300.
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
cat >> input.nml << EOF
&nam_stochy
/
&nam_sfcperts
/
EOF

echo "$(cat input.nml)"
}
