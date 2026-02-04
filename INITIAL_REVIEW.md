# Initial review: DCON vs RDCON (Fortran)

## Scope
This review compares the Fortran sources in:
- src/DCON/rdcon_fortran/dcon
- src/DCON/rdcon_fortran/rdcon

The focus is on **what subroutines are implemented in each code**, and where the file inventories differ.

## File inventory differences

### Only in DCON
- dcon.F
- dcon_netcdf.f
- fourfit.F
- README

### Only in RDCON
- dcon.f
- gal.f
- lib_interface.f
- makefile_db
- makefile_lib
- rdcon_netcdf.f
- sing1.f
- sing_ideal.f
- TESTGAL.f
- toolbox.f
- version.inc

## Subroutine inventory by file

### DCON-only files

#### dcon.F
- dcon_dealloc

#### dcon_netcdf.f
- check
- dcon_netcdf_out

#### fourfit.F
- fourfit_make_metric
- fourfit_make_matrix
- fourfit_action_matrix
- fourfit_write_metric
- fourfit_write_matrix
- fourfit_evals
- fourfit_diagnose_1
- fourfit_kinetic_matrix

### RDCON-only files

#### dcon.f
- dcon_dealloc
- dcon_regrid
- dcon_qpack
- dcon_run
- dcon_interface_run

#### gal.f
- gal_alloc
- gal_dealloc
- gal_hermite
- gal_make_grid
- gal_diagnose_grid
- gal_make_map
- gal_diagnose_map
- gal_assemble_rhs
- gal_assemble_mat
- gal_lsode_int
- gal_lsode_der
- gal_lsode_diagnose
- gal_get_fkg
- gal_gauss_quad
- gal_extension
- gal_make_arrays
- gal_solve
- gal_write_delta
- gal_set_boundary
- gal_diagnose_mat
- gal_spline_pack
- gal_read_input
- gal_write_pest3_data
- gal_get_solution
- gal_output_solution
- write_diagnostic_checkpoint
- write_diagnostic_checkpoint_rhs

#### lib_interface.f
- lib_interface_init
- lib_interface_input
- lib_interface_set_equil
- lib_interface_input_memory
- lib_interface_input_reorder
- lib_interface_input_reorder_good
- lib_interface_input_1
- lib_interface_set_equil_transp
- lib_interface_input_chease
- lib_interface_set_equil_chease

#### rdcon_netcdf.f
- check
- rdcon_netcdf_out

#### sing1.f
- sing1_mmat
- sing1_solve
- sing1_vmat
- sing1_get_ua
- sing1_get_dua
- sing1_der
- sing1_matvec
- sing1_write_mat
- sing1_vmat_diagnose
- sing1_ua_diagnose
- sing1_vmat_d
- sing1_solve_d
- sing1_get_ua_d
- sing1_get_dua_d
- sing1_get_ua_d_cut
- sing1_get_ua_cut
- sing1_delta
- sing1_kxscan
- sing1_xmin

#### sing_ideal.f
- sing_scan
- sing_find
- sing_lim
- sing_vmat
- sing_mmat
- sing_solve
- sing_get_ua
- sing_get_ca
- sing_der
- sing_ua_diagnose
- ksing_find
- sing_newton

#### TESTGAL.f
- test_hermite
- test_pack

#### toolbox.f
- toolbox_hermite
- toolbox_preflatcof

### Shared files (same filename in both trees)

#### bal.f
- DCON: bal_scan, bal_prep, bal_der, bal_int, bal_pse
- RDCON: bal_scan, bal_prep, bal_der, bal_int, bal_pse

#### debug.f
- DCON: debug1, debug2, debug3
- RDCON: debug1, debug2, debug3

#### free.f
- DCON: free_run, free_write_msc, free_ahb_prep, free_ahb_write, free_test, free_wvmats
- RDCON: free_run, free_write_msc, free_ahb_prep, free_ahb_write, free_get_wvac

#### mercier.f
- DCON: mercier_scan
- RDCON: mercier_scan

#### ode.f
- DCON: ode_run, ode_axis_init, ode_sing_init, ode_ideal_cross, ode_kin_cross, ode_resist_cross, ode_step, ode_unorm, ode_fixup, ode_test_fixup, ode_record_edge
- RDCON: ode_run, ode_axis_init, ode_sing_init, ode_ideal_cross, ode_step, ode_unorm, ode_fixup, ode_test_fixup

#### ode_output.f
- DCON: ode_output_open, ode_output_step, ode_output_close, ode_output_get_evals, ode_output_monitor, ode_output_get_crit, ode_output_sol
- RDCON: ode_output_open, ode_output_step, ode_output_close, ode_output_get_evals, ode_output_monitor, ode_output_get_crit, ode_output_sol

#### resist.f
- DCON: resist_eval
- RDCON: resist_eval

#### sing.f
- DCON: sing_scan, sing_find, sing_lim, sing_vmat, sing_mmat, sing_solve, sing_get_ua, sing_get_ca, sing_der, sing_ua_diagnose, ksing_find, sing_newton
- RDCON: sing_scan, sing_find, sing_lim, sing_vmat, sing_mmat, sing_solve, sing_get_ua, sing_get_dua, sing_get_ca, sing_der, sing_matvec, sing_ua_diagnose, sing_get_ua_cut, sing_min

#### fourfit (file name differs by extension)
- DCON: fourfit.F with extra subroutines `fourfit_action_matrix` and `fourfit_kinetic_matrix`
- RDCON: fourfit.f without those two subroutines

#### dcon (file name differs by extension)
- DCON: dcon.F only contains `dcon_dealloc`
- RDCON: dcon.f contains `dcon_dealloc`, `dcon_regrid`, `dcon_qpack`, `dcon_run`, `dcon_interface_run`

## Notable functional differences (high-level)
- RDCON adds the **Galerkin integrator** implementation (`gal.f`) and related tooling (`toolbox.f`, `TESTGAL.f`).
- RDCON includes a larger **library interface** surface (`lib_interface.f`) and more entry points in `dcon.f`.
- DCON’s `ode.f` includes additional crossing and output hooks (`ode_kin_cross`, `ode_resist_cross`, `ode_record_edge`) that are not present in RDCON’s `ode.f`.
- The singular-surface handling diverges:
  - DCON has `ksing_find` and `sing_newton` in `sing.f`.
  - RDCON adds `sing_get_dua`, `sing_matvec`, `sing_get_ua_cut`, `sing_min` in `sing.f` and also ships a separate `sing1.f` and `sing_ideal.f`.

---
Next step will be to plan how to integrate the Galerkin integrator into the Julia DCON implementation.
