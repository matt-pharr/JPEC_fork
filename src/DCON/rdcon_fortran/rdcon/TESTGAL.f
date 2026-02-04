! Fortran test script for Galerkin functions
! Compile with: gfortran -O0 -fbacktrace -g -fcheck=all -fPIC -c *.f
! Link with: gfortran TESTGAL.o *.o -std=legacy -framework Accelerate -o testgal
! Or on Linux: gfortran TESTGAL.o *.o -std=legacy -lopenblas -o testgal
! Run: ./testgal

      PROGRAM test_galerkin_fortran
      USE rdcon_run_mod
      IMPLICIT NONE
      
      WRITE(*,*) "========================================="
      WRITE(*,*) "Galerkin Fortran Test Suite"
      WRITE(*,*) "========================================="
      WRITE(*,*)
      
      CALL test_hermite
      CALL test_pack
      
      WRITE(*,*)
      WRITE(*,*) "========================================="
      WRITE(*,*) "All tests completed"
      WRITE(*,*) "========================================="
      
      END PROGRAM test_galerkin_fortran

c-----------------------------------------------------------------------
c     Test 1: Test Hermite basis functions
c-----------------------------------------------------------------------
      SUBROUTINE test_hermite
      USE rdcon_run_mod
      IMPLICIT NONE
      
      TYPE(hermite2_type) :: hermite
      REAL(r8) :: x, x0, x1
      INTEGER :: i
      
      WRITE(*,*) "Test 1: Hermite basis functions"
      WRITE(*,*) "---------------------------------"
      
      ! Test case 1: Evaluate at midpoint of [0, 1]
      x0 = 0.0_r8
      x1 = 1.0_r8
      x = 0.5_r8
      
      CALL gal_hermite(x, x0, x1, hermite)
      
      WRITE(*,*) "Test case 1: x=0.5 in [0,1]"
      WRITE(*,*) "Hermite basis functions (pb):"
      DO i = 0, 3
         WRITE(*,'(A,I1,A,ES24.16)') "  pb[", i, "] = ", hermite%pb(i)
      END DO
      WRITE(*,*) "Hermite basis derivatives (qb):"
      DO i = 0, 3
         WRITE(*,'(A,I1,A,ES24.16)') "  qb[", i, "] = ", hermite%qb(i)
      END DO
      
      ! Test case 2: Evaluate at left endpoint
      x = 0.0_r8
      CALL gal_hermite(x, x0, x1, hermite)
      
      WRITE(*,*)
      WRITE(*,*) "Test case 2: x=0.0 in [0,1]"
      WRITE(*,*) "Hermite basis functions (pb):"
      DO i = 0, 3
         WRITE(*,'(A,I1,A,ES24.16)') "  pb[", i, "] = ", hermite%pb(i)
      END DO
      
      ! Test case 3: Evaluate at right endpoint
      x = 1.0_r8
      CALL gal_hermite(x, x0, x1, hermite)
      
      WRITE(*,*)
      WRITE(*,*) "Test case 3: x=1.0 in [0,1]"
      WRITE(*,*) "Hermite basis functions (pb):"
      DO i = 0, 3
         WRITE(*,'(A,I1,A,ES24.16)') "  pb[", i, "] = ", hermite%pb(i)
      END DO
      
      ! Test case 4: Different interval [2, 5]
      x0 = 2.0_r8
      x1 = 5.0_r8
      x = 3.5_r8
      
      CALL gal_hermite(x, x0, x1, hermite)
      
      WRITE(*,*)
      WRITE(*,*) "Test case 4: x=3.5 in [2,5]"
      WRITE(*,*) "Hermite basis functions (pb):"
      DO i = 0, 3
         WRITE(*,'(A,I1,A,ES24.16)') "  pb[", i, "] = ", hermite%pb(i)
      END DO
      WRITE(*,*) "Hermite basis derivatives (qb):"
      DO i = 0, 3
         WRITE(*,'(A,I1,A,ES24.16)') "  qb[", i, "] = ", hermite%qb(i)
      END DO
      WRITE(*,*)
      
      END SUBROUTINE test_hermite

c-----------------------------------------------------------------------
c     Test 2: Test grid packing function
c-----------------------------------------------------------------------
      SUBROUTINE test_pack
      USE rdcon_run_mod
      IMPLICIT NONE
      
      REAL(r8), DIMENSION(:), ALLOCATABLE :: x
      INTEGER :: nx_loc, i
      REAL(r8) :: pfac_loc
      CHARACTER(LEN=10) :: side_loc
      
      WRITE(*,*) "Test 2: Grid packing function"
      WRITE(*,*) "------------------------------"
      
      nx_loc = 5
      
      ! Test case 1: Uniform grid, both side_locs
      pfac_loc = 1.0_r8
      side_loc = "both"
      ALLOCATE(x(-nx_loc:nx_loc))
      x = gal_pack(nx_loc, pfac_loc, side_loc)
      
      WRITE(*,*) "Test case 1: nx_loc=5, pfac_loc=1.0, side_loc='both'"
      WRITE(*,*) "Grid points:"
      DO i = -nx_loc, nx_loc
         WRITE(*,'(A,I2,A,ES24.16)') "  x[", i, "] = ", x(i)
      END DO
      DEALLOCATE(x)
      
      ! Test case 2: Logarithmic packing, both side_locs
      pfac_loc = 2.0_r8
      side_loc = "both"
      ALLOCATE(x(-nx_loc:nx_loc))
      x = gal_pack(nx_loc, pfac_loc, side_loc)
      
      WRITE(*,*)
      WRITE(*,*) "Test case 2: nx_loc=5, pfac_loc=2.0, side_loc='both'"
      WRITE(*,*) "Grid points (log packing):"
      DO i = -nx_loc, nx_loc
         WRITE(*,'(A,I2,A,ES24.16)') "  x[", i, "] = ", x(i)
      END DO
      DEALLOCATE(x)
      
      ! Test case 3: Left side_loc packing
      pfac_loc = 2.0_r8
      side_loc = "left"
      ALLOCATE(x(-2*nx_loc:0))
      x = gal_pack(nx_loc, pfac_loc, side_loc)
      
      WRITE(*,*)
      WRITE(*,*) "Test case 3: nx_loc=5, pfac_loc=2.0, side_loc='left'"
      WRITE(*,*) "Grid points:"
      DO i = -2*nx_loc, 0
         WRITE(*,'(A,I3,A,ES24.16)') "  x[", i, "] = ", x(i)
      END DO
      DEALLOCATE(x)
      
      ! Test case 4: Right side_loc packing
      pfac_loc = 2.0_r8
      side_loc = "right"
      ALLOCATE(x(0:2*nx_loc))
      x = gal_pack(nx_loc, pfac_loc, side_loc)
      
      WRITE(*,*)
      WRITE(*,*) "Test case 4: nx_loc=5, pfac_loc=2.0, side_loc='right'"
      WRITE(*,*) "Grid points:"
      DO i = 0, 2*nx_loc
         WRITE(*,'(A,I2,A,ES24.16)') "  x[", i, "] = ", x(i)
      END DO
      DEALLOCATE(x)
      
      ! Test case 5: Exponential packing (pfac_loc < 1)
      pfac_loc = 0.5_r8
      side_loc = "both"
      ALLOCATE(x(-nx_loc:nx_loc))
      x = gal_pack(nx_loc, pfac_loc, side_loc)
      
      WRITE(*,*)
      WRITE(*,*) "Test case 5: nx_loc=5, pfac_loc=0.5, side_loc='both'"
      WRITE(*,*) "Grid points (exp packing):"
      DO i = -nx_loc, nx_loc
         WRITE(*,'(A,I2,A,ES24.16)') "  x[", i, "] = ", x(i)
      END DO
      DEALLOCATE(x)
      
      ! Test case 6: Power law packing (pfac_loc < 0)
      pfac_loc = -2.0_r8
      side_loc = "both"
      ALLOCATE(x(-nx_loc:nx_loc))
      x = gal_pack(nx_loc, pfac_loc, side_loc)
      
      WRITE(*,*)
      WRITE(*,*) "Test case 6: nx_loc=5, pfac_loc=-2.0, side_loc='both'"
      WRITE(*,*) "Grid points (power law packing):"
      DO i = -nx_loc, nx_loc
         WRITE(*,'(A,I2,A,ES24.16)') "  x[", i, "] = ", x(i)
      END DO
      DEALLOCATE(x)
      WRITE(*,*)
      
      END SUBROUTINE test_pack
