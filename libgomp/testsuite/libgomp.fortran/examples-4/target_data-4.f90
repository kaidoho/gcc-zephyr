! { dg-do run }

module e_51_4_mod
contains
  subroutine init (v1, v2, N)
    integer :: i, N
    real :: v1(N), v2(N)
    do i = 1, N
      v1(i) = i + 2.0
      v2(i) = i - 3.0
    end do
  end subroutine

  subroutine check (p, N)
    integer :: i, N
    real, parameter :: EPS = 0.00001
    real :: diff, p(N)
    do i = 1, N
      diff = p(i) - (i + 2.0) * (i - 3.0)
      if (diff > EPS .or. -diff > EPS) STOP 1
    end do
  end subroutine

  subroutine foo (p, v1, v2, N)
    real, pointer, dimension(:) :: p, v1, v2
    integer :: N
    call init (v1, v2, N)
    !$omp target data map(to: v1, v2) map(from: p)
      call vec_mult (p, v1, v2, N)
    !$omp end target data
    call check (p, N)
  end subroutine

  subroutine vec_mult (p, v1, v2, N)
    real, pointer, dimension(:) :: p, v1, v2
    integer :: i, N
    !$omp target map(to: v1, v2) map(from: p)
      !$omp parallel do
      do i = 1, N
        p(i) = v1(i) * v2(i)
      end do
    !$omp end target
  end subroutine
end module

program e_51_4
  use e_51_4_mod, only : foo
  integer :: n
  real, pointer, dimension(:) :: p, v1, v2
  n = 1000
  allocate (p(n), v1(n), v2(n))
  call foo (p, v1, v2, n)
  deallocate (p, v1, v2)
end program
