!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!Adrien Atallah
!Project 6
!
!This program .
!
! 	Input Variables:
!		-L: size of the box
!		-N: number of lattice points
! 
!	Intermediate variables: 
!		-dx: stepsize
!		-PEmat: Potential Energy matrix
!		-KEmat: Kinetic Energy matrix
!
! 	Subroutines used: 
!		-'KEmatrix(N, hbar, m, dx, KEmat)'	
!			-Creates KE matrix used for all scenarios
!		-'PsiMatrix(Gc, Gw, dx, L, N, Psi0)'	
!			-Creates the initial gaussian wave function
!		-'TimeStep(N, KEmat, dx, dt, L, hbar, m, Psi_n, Psi_np1, Pdens)'
!			-Takes a time step for the Psi matrix
!	
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
Program project6
 implicit none
 real :: c, hbar, V0, m, a !Constants
 	!Declare constant values as parameters:
 parameter (c = 1)
 parameter (hbar = 1) 
 parameter (m = 1) 
 
 real :: dt, L, Gc, Gw
 integer :: N, Nt 
 	!input variables
 
 real :: x, xi, dx, t, norm, Pdens, expectTop, varTop, expect, var
 real :: PEmat(1000, 1000), KEmat(1000, 1000), Psi0(2000), Psi_n(2000), Psi_np1(2000)
 integer :: i, j
 	!Intermediate variables
    
 character :: continue = 'y' 
 
 
 do while (continue == 'y' .or. continue == 'Y')    


 	print *, ' '
	print *, 'Computational Project 6:'
	print *, 'Time-Dependent Schrodinger Equation'
	print *, 'Written by: Adrien Atallah'
	print *, ' '

	print *, ' '
	print *, 'Enter the size of the box, L'
	print *, ' '
	read *, L
	
	print *, ' '
	print *, 'Enter the number of lattice points (less than 1000)'
	print *, ' '
	read *, N
	
	print *, ' '
	print *, 'Enter the time step'
	print *, ' '
	read*, dt

	print *, ' '
	print *, 'Enter the number of steps to take'
	print *, ' '
	read *, Nt
	
	print *, ' '
	print *, 'Enter the center of the Gaussian'
	print *, ' '
	read *, Gc
	
	print *, ' '
	print *, 'Enter the width of the Gaussian'
	print *, ' '
	read *, Gw
	
	dx = (2*L)/(N-1)
	t = 0.0
	norm = 0.0
	expectTop = 0.0
	varTop = 0.0
		
	open(unit = 1, file = 'Info.txt')
	write(1,*), '# Adrien Atallah'
	write(1,*), '# Project 6'
	write(1,*), '# Contains the norm, expectation value and variance'
	write(1,*), '# 1st column: norm, 2nd: expectation value, 3rd: variance'
	
	open(unit = 2, file = 'Pdense.txt') !unit 5, 6 reserved
	write(2,*), '# Adrien Atallah'
	write(2,*), '# Project 6'
	write(2,*), '# Contains the total probability density'
	
	open(unit = 3, file = 'variance.txt') !unit 5, 6 reserved
	write(3,*), '# Adrien Atallah'
	write(3,*), '# Project 6'
	write(3,*), '# Contains the Gaussian width as a function of time'
	write(3,*), '# t, width'
	
	open(unit = 4, file = 'wave.txt') !unit 5, 6 reserved
	write(4,*), '# Adrien Atallah'
	write(4,*), '# Project 6'
	write(4,*), '# Contains the probability density as a function of x'
	write(4,*), '# x, probability density'
	
	
	call KEmatrix(N, hbar, m, dx, KEmat)
	
	call PsiMatrix(Gc, Gw, dx, L, N, Psi0)
	
	call TimeStep(N, KEmat, dx, dt, L, hbar, m, Psi0, Psi_n, Pdens)
	
	do i = 1, Nt	
		t = t + dt
		
		call TimeStep(N, KEmat, dx, dt, L, hbar, m, Psi_n, Psi_np1, Pdens)
		
		do j = 1, N 
			 xi = -L + (j - 1)*dx 
			 norm = norm + Pdens*dx !calculate normalization
			 expectTop = expectTop + (xi)*Pdens !calculate numerator of expectation value
			 varTop = varTop + (xi)**2*Pdens !calcuate numerator for variance
			 write(4, *), xi, Pdens
		enddo		
		
		expect = expectTop/norm
		var = Sqrt( (varTop/norm) - expect**2)
		
		write(1, *), norm, expect, var
		write(3, *), t, var		
		
		norm = 0.0
		expectTop = 0.0
		VarTop = 0.0
		
	enddo
		
	write(2, *), Pdens

!!!!!!!!!!!!!
!Ask user if they want to run the program again
!!!!!!!!!!!!!!	
	print *, ' '
10	print *, 'Would you like to run the program again?'
	print *, 'type "y" for yes, "n" for no'
	print *, ' '
	read *, continue	
	
	
	if (continue /= 'n' .and. continue /= 'N' .and. continue /= 'y' .and. continue /= 'Y') then
		print *, ' '
		print *, 'Invalid entry, please try again'
		print *, ' '
		goto 10
	endif
end do
 
 close(1)
 close(2)
 close(3)
 close(4)

END  

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!KEmatrix(N, hbar, m, dx, KEmat)) initializes tridiagonal matrix for the Kinetic
! energy 
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
subroutine KEmatrix(N, hbar, m, dx, KEmat)
implicit none

 real, intent(in) :: hbar, m, dx
 integer, intent(in) :: N
 	!input variables
 		
 integer :: i, j 
 real :: k
 	!intermediate variables
 		
 real, intent(out) :: KEmat(1000, 1000)
 	!output variables
 

 do i = 1, N !initialize NxN Potential Energy matrix to 0
 	do j = 1, N
		KEmat(i, j) = 0
	enddo
 enddo    

 k = (hbar)**2/( 2*m*dx**2)

 do i = 1, N !initialize NxN Kinetic Energy matrix 	
	KEmat(i, i) = 2*k	
	KEmat(i+1, i) = -k
	KEmat(i, i+1) = -k
 enddo  
 
		
return
end	

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!PsiMatrix(N, hbar, m, dx, KEmat)) Creates the initial gaussian wave function
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
subroutine PsiMatrix(Gc, Gw, dx, L, N, Psi0)
implicit none

 real, intent(in) :: Gc, Gw, dx, L
 integer, intent(in) :: N
 	!input variables
 		
 integer :: i, j
 real :: xi, Gauss 
 	!intermediate variables
 		
 real, intent(out) :: Psi0(2000)
 	!output variables
 

 do i = 1, 2*N !initialize initial 2Nx1 Gaussian Psi matrix to 0
	Psi0(i) = 0.0
 enddo    

 do i = 1, N !initialize initial 2Nx1 Psi Matrix as gaussian wave function 
  	xi = -L + (i - 1)*dx 
  	Psi0(i) = Gauss(Gc, Gw, xi) 	
 enddo    
 
		
return
end	


!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!'TimeStep(N, KEmat, dx, dt, L, hbar, m, Psi_n, Psi_np1, Pdens)'
!	-Takes a time step for the Psi matrix
!
! 	Subroutines used: 
!		-'MatInv(LHStemp, LHSinv, 2*N, 2*N, Index)'	
!			-Returns the inverse of a matrix
!		-'multmat(2*N, 2*N, LHSinv, RHS, Product)'	
!			-Returns the product of two matricies
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
subroutine TimeStep(N, KEmat, dx, dt, L, hbar, m, Psi_n, Psi_np1, Pdens)
implicit none

 real, intent(in) :: KEmat(1000, 1000), Psi_n(2000), dx, L, hbar, m, dt
 integer, intent(in) :: N
 	!input variables
 
 real :: xi, k, sum, PEmat(1000, 1000), Hmat(1000, 1000), LHS(2000, 2000), RHS(2000, 2000), Identity(1000, 1000)
 real :: RePsi_np1(2000), ImPsi_np1(2000), ImNorm, ReNorm, LHStemp(2000, 2000), LHSInv(2000, 2000), Product(2000, 2000)
 integer :: i, j, Index(2000)
 	!intermediate variables
 		
 real, intent(out) :: Psi_np1(2000), Pdens
 	!output variables
 		
 k = dt/(2*hbar)

 do i = 1, 1000 !initialize all arrays to 0
 	do j = 1, 1000
		PEmat(i, j) = 0.0
		Hmat(i, j) = 0.0
		Identity(i, j) = 0.0
	enddo
 enddo    
 
 do i = 1, 2000
 	do j = 1, 2000
 		LHS(i, j) = 0.0
 		RHS(i, j) = 0.0
 		LHSInv(i, j) = 0.0
 		LHStemp(i, j) = 0.0
 		Product(i, j) = 0.0
 		
 	enddo
 	Psi_np1(i) = 0.0
 	ImPsi_np1 = 0.0
 	RePsi_np1 = 0.0
 	Index(i) = 0
 enddo
 		

  do i = 1, N !initialize PE for Harmonic oscillator and H = KE + PE matrices
  	xi = -L + (i - 1)*dx 
  	!PEmat(i, i) = Vho(hbar, m, xi) !create diagonalized matrix for PE of Harmonic Oscillator
  	
 	do j = 1, N 		
		Hmat(i, j) = KEmat(i, j) !+ PEmat(i, j)
	enddo
	
 enddo    
 
 do i = 1, N
 	Identity(i, i) = 1
 enddo
 
 do i = 1, N
 	do j = 1, N 	
		 LHS(i, j) = Identity(i, j) !first quadrant of the LHS of the equation to be solved 
		 RHS(i, j) = Identity(i, j) !first quadrant of the RHS of the equation to be solved 
	enddo
enddo

 do i = 1, N
 	do j = N+1, 2*N 	
		 LHS(i, j) = -k*Hmat(i, j - N) !second quadrant of the LHS of the equation to be solved
		 RHS(i, j) = k*Hmat(i, j - N) !second quadrant of the RHS of the equation to be solved 
	enddo
enddo

 do i = N+1, 2*N
 	do j = 1, N 	
		 LHS(i, j) = k*Hmat(i - N, j) !third quadrant of the LHS of the equation to be solved 
		 RHS(i, j) = -k*Hmat(i - N, j) !third quadrant of the RHS of the equation to be solved 
	enddo
enddo

 do i = N+1, 2*N
 	do j = N+1, 2*N 	
		 LHS(i, j) = Identity(i - N, j - N) !forth quadrant of the LHS of the equation to be solved 
		 RHS(i, j) = Identity(i - N, j - N) !forth quadrant of the RHS of the equation to be solved 
	enddo
enddo


 do i = 1, 2*N
 	do j = 1, 2*N 	
		 LHStemp(i, j) = LHS(i, j) !create temporarly LHS matrix as it will be destroyed
	enddo
enddo

 call MatInv(LHStemp, LHSinv, 2*N, 2000, Index)
 
 call multmat(2000, 2*N, LHSinv, RHS, Product)
 
 sum = 0.0
 
 do i = 1, 2*N
 	do j = 1, 2*N
 		sum = sum + Product(i, j)*Psi_n(j) !Multiply LHSinv*RHS*Psi_n
 	enddo
 		
 	Psi_np1(i) = sum
 	sum = 0.0
 enddo  
 
 do i = 1, N
 	RePsi_np1(i) = Psi_np1(i)
 	!print*, RePsi_np1(i)
 enddo
 
  do i = N+1, 2*N
 	ImPsi_np1(i) = Psi_np1(i)
 enddo
 
 
 !Now calculate the probablity density
 ReNorm = 0
 ImNorm = 0
 Pdens = 0
 
 do i = 1, N 
 	ReNorm = ReNorm + RePsi_np1(i)**2 
 enddo
 
 do i = N+1, 2*N
 	ImNorm = ImNorm + ImPsi_np1(i)**2
 enddo
 
 Pdens = ReNorm**2 + ImNorm**2 	

return
end	

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! Function Gauss(Gc, Gw, x) returns a gaussian function of x
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
 real function Gauss(Gc, Gw, x)
 implicit none
 
 real, intent(in) :: Gc, Gw, x
 	!input variables
 		
 real :: k, pi
 	!intermediate variables
 	
pi = acos(-1.0)		
 
 k = 1/( (2.0*pi*Gw**2.0)**(1.0/4.0) )
 
 Gauss = k*exp( (-(x - Gc)**2.0)/(4.0*Gw**2.0) )
 
 return
 end 
 
 !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
! C   package EIGLIB   -- from numerical recipes
! CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC

      subroutine eig(A,n,np,e,vec,work)
! C
! C  INPUT: 
! C       A(i,j): symmetry n x n matrix (declared np x np)
! C      n = working dimension of A
! C     np = declared dimension of A
! C    work(i) = dummy array
! C
! C   OUTPUT:
! C     e(i) = vector of eigenvalues of A
! C     vec(i,j) = arrays of eigenvectors of A
! C
! C   SUBROUTINES CALLED:
! C     tred2: reduces A to tridiagonal
! C     tqli:   find eigenvalues, eigenvectors of tridiagonal
! C
      implicit none
      
      integer n,np
      real a(np,np)		! array to be diagonalized 
      real e(np)		! eigenvalues out 
      real vec(np,np)		! eigenvectors out
      real work(np)		!
      integer i,j
      
      do i =1,n
      	do j = 1,n
      	     vec(i,j)=a(i,j)
      	enddo
      enddo
      call tred2(vec,n,np,e,work)
      call tqli(e,work,n,np,vec)
      return
      end

! CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
! C
! C   subroutine TRED2
! C   
! C   reduces a matrix to tridiagonal; taken from numerical recipes
! C
! C  INPUT:
! C  A(i,j) : n x n symmetric matrix (this gets destroyed)
! C  n = working dimension of A
! C  np = declared dimension of A
! C  
! C  OUTPUT:
! C     d(i): diagonal elements
! C     e(i): off diagonal elements 
! C  NB: A is replaced by orthogonal transformation
! C

      SUBROUTINE tred2(a,n,np,d,e)
      INTEGER n,np
      REAL a(np,np),d(np),e(np)
      INTEGER i,j,k,l
      REAL f,g,h,hh,scale
      do 18 i=n,2,-1
        l=i-1
        h=0.
        scale=0.
        if(l.gt.1)then
          do 11 k=1,l
            scale=scale+abs(a(i,k))
11        continue
          if(scale.eq.0.)then
            e(i)=a(i,l)
          else
            do 12 k=1,l
              a(i,k)=a(i,k)/scale
              h=h+a(i,k)**2
12          continue
            f=a(i,l)
            g=-sign(sqrt(h),f)
            e(i)=scale*g
            h=h-f*g
            a(i,l)=f-g
            f=0.
            do 15 j=1,l
! C     Omit following line if finding only eigenvalues
              a(j,i)=a(i,j)/h
              g=0.
              do 13 k=1,j
                g=g+a(j,k)*a(i,k)
13            continue
              do 14 k=j+1,l
                g=g+a(k,j)*a(i,k)
14            continue
              e(j)=g/h
              f=f+e(j)*a(i,j)
15          continue
            hh=f/(h+h)
            do 17 j=1,l
              f=a(i,j)
              g=e(j)-hh*f
              e(j)=g
              do 16 k=1,j
                a(j,k)=a(j,k)-f*e(k)-g*a(i,k)
16            continue
17          continue
          endif
        else
          e(i)=a(i,l)
        endif
        d(i)=h
18    continue
! C     Omit following line if finding only eigenvalues.
      d(1)=0.
      e(1)=0.
      do 24 i=1,n
! C     Delete lines from here ...
        l=i-1
        if(d(i).ne.0.)then
          do 22 j=1,l
            g=0.
            do 19 k=1,l
              g=g+a(i,k)*a(k,j)
19          continue
            do 21 k=1,l
              a(k,j)=a(k,j)-g*a(k,i)
21          continue
22        continue
        endif
!C     ... to here when finding only eigenvalues.
        d(i)=a(i,i)
!C     Also delete lines from here ...
        a(i,i)=1.
        do 23 j=1,l
          a(i,j)=0.
          a(j,i)=0.
23      continue
!C     ... to here when finding only eigenvalues.
24    continue
      return
      END


! CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
! C
! C  subroutine TQLI
! C   
! C  solves tridiagonal matrix for eigenvalues through implicit QL shift
! C  (see numerical recipes)
! C
! C INPUT: 
! C   d(i): diagonal matrix elements
! C   e(i): off-diagonal matrix elements
! C   n = working dimension
! C   np = declared dimension
! C   z(i,j): output from TRED2; this will transform back to original basis
! C
! C  OUTPUT:
! C   d(i): will hold eigenvalues
! C   z(i,j) will hold eigenvectors in original basis  
! C 
! C FUNCTIONS CALLED: 
! C  pythag
! C

      SUBROUTINE tqli(d,e,n,np,z)
      INTEGER n,np
      REAL d(np),e(np),z(np,np)
!CU    USES pythag
      INTEGER i,iter,k,l,m
      REAL b,c,dd,f,g,p,r,s,pythag
      do 11 i=2,n
        e(i-1)=e(i)
11    continue
      e(n)=0.
      do 15 l=1,n
        iter=0
1       do 12 m=l,n-1
          dd=abs(d(m))+abs(d(m+1))
          if (abs(e(m))+dd.eq.dd) goto 2
12      continue
        m=n
2       if(m.ne.l)then
          if(iter.eq.1000) print*,'too many iterations in tqli' !*** I changed from 30 to 300
          iter=iter+1
          g=(d(l+1)-d(l))/(2.*e(l))
          r=pythag(g,1.)
          g=d(m)-d(l)+e(l)/(g+sign(r,g))
          s=1.
          c=1.
          p=0.
          do 14 i=m-1,l,-1
            f=s*e(i)
            b=c*e(i)
            r=pythag(f,g)
            e(i+1)=r
            if(r.eq.0.)then
              d(i+1)=d(i+1)-p
              e(m)=0.
              goto 1
            endif
            s=f/r
            c=g/r
            g=d(i+1)-p
            r=(d(i)-g)*s+2.*c*b
            p=s*r
            d(i+1)=g+p
            g=c*r-b
!C     Omit lines from here ...
            do 13 k=1,n
              f=z(k,i+1)
              z(k,i+1)=s*z(k,i)+c*f
              z(k,i)=c*z(k,i)-s*f
13          continue
!C     ... to here when finding only eigenvalues.
14        continue
          d(l)=d(l)-p
          e(l)=g
          e(m)=0.
          goto 1
        endif
15    continue
      return
      END

!CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC

      FUNCTION pythag(a,b)
      REAL a,b,pythag
      REAL absa,absb
      absa=abs(a)
      absb=abs(b)
      if(absa.gt.absb)then
        pythag=absa*sqrt(1.+(absb/absa)**2)
      else
        if(absb.eq.0.)then
          pythag=0.
        else
          pythag=absb*sqrt(1.+(absa/absb)**2)
        endif
      endif
      return
      END

! CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
! C
! C  subroutine eigsrt
! C  sorts eigenvalues into ASCENDING ORDER
! C
! C  INPUT:
! C  d(i): eigenvalues
! C   v(i,j): matrix of eigenvectors
! C   n = working dimension
! C  np = declared dimension   
! C
      SUBROUTINE eigsrt(d,v,n,np)
      INTEGER n,np
      REAL d(np),v(np,np)
      INTEGER i,j,k
      REAL p
      do 13 i=1,n-1
        k=i
        p=d(i)
        do 11 j=i+1,n
          if(d(j).le.p)then
            k=j
            p=d(j)
          endif
11      continue
        if(k.ne.i)then
          d(k)=d(i)
          d(i)=p
          do 12 j=1,n
            p=v(j,i)
            v(j,i)=v(j,k)
            v(j,k)=p
12        continue
        endif
13    continue
      return
      END
      
! CCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
! c
! c	subroutine printnicematrix(size, n, array)
! c
! c	Prints a nice looking matrix
! c
! c	Input:
! c		integer size - maxsize of matrix
! c		integer n - actual size of matrix
! c		real array(size, size) - the matrix to print
! c

      subroutine printnicematrix(size,n,array)

      implicit none

      integer size,n
      real array(size,size)
      integer i,j

      do i =1,n
           write(6,100)(array(i,j),j=1,n)
       enddo
  100 format(10f8.3)
       return
       end
       
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!       
      subroutine MatInv(A,AINV,N,NP,INDX)
! C
! C     takes N X N matrix A (physical dimension NP X NP) and 
! C     computes A^-1 = AINV
! C
! C   calls subroutines
! C       LUDCMP  -- LU decomposition
! C          note: LUDCMP overwrites input 
! C       LUBKSB  -- LU forward and back substitution
! C

      implicit none
      integer n,np
      real A(NP,NP),AINV(NP,NP)
      integer INDX(Np)			! dummy
      integer i,j
      real d

      do i = 1,n
      	do j = 1,n
      		ainv(i,j) = 0.0
      	enddo
      	ainv(i,i) = 1.0
      enddo
      call ludcmp(a,n,np,indx,d)
      do j = 1,n
      	call lubksb(a,n,np,indx,ainv(1,j))
      enddo
      return
      end


! CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
! C
! C   subroutine LUbksb(A,n,np,indx,b)
! C   applies forward- and backsubstitution to get A^-1 b
! C   
      SUBROUTINE LUBKSB(A,N,NP,INDX,B)
      DIMENSION A(NP,NP),INDX(N),B(N)
      II=0
      DO 12 I=1,N
        LL=INDX(I)
        SUM=B(LL)
        B(LL)=B(I)
        IF (II.NE.0)THEN
          DO 11 J=II,I-1
            SUM=SUM-A(I,J)*B(J)
11        CONTINUE
        ELSE IF (SUM.NE.0.) THEN
          II=I
        ENDIF
        B(I)=SUM
12    CONTINUE
      DO 14 I=N,1,-1
        SUM=B(I)
        IF(I.LT.N)THEN
          DO 13 J=I+1,N
            SUM=SUM-A(I,J)*B(J)
13        CONTINUE
        ENDIF
        B(I)=SUM/A(I,I)
14    CONTINUE
      RETURN
      END
      
! CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
! C
! C   subroutine ludcmp(A,n,np,indx,d)
! C   reads in matrix A and does LU decomposition
! C   from Numerical Recipes
! C   
! C   INPUT:
! C       A(NP,NP) : real matrix; must be declared in calling routine
! C      n    = dimension of A used 
! C      np  = physical declared dimension of array A (np >= n)
! C     indx(n) : an array declared by calling routine; used for decomposition
! C     d = +/- 1; keeps track of exchanges of rows (needed to get sign of determinant) 
! C       
! C   OUTPUT:
! C       L and U returned in matrix A; assumes L(i,i) = 1
! C       note!  matrix A is destroyed in the process 
! C
      SUBROUTINE LUDCMP(A,N,NP,INDX,D)
      PARAMETER (NMAX=1000,TINY=1.0E-20)
      DIMENSION A(NP,NP),INDX(N),VV(NMAX)
      D=1.
      DO 12 I=1,N
        AAMAX=0.
        DO 11 J=1,N
          IF (ABS(A(I,J)).GT.AAMAX) AAMAX=ABS(A(I,J))
11      CONTINUE
        !IF (AAMAX.EQ.0.) PAUSE 'Singular matrix.'
        VV(I)=1./AAMAX
12    CONTINUE
      DO 19 J=1,N
        IF (J.GT.1) THEN
          DO 14 I=1,J-1
            SUM=A(I,J)
            IF (I.GT.1)THEN
              DO 13 K=1,I-1
                SUM=SUM-A(I,K)*A(K,J)
13            CONTINUE
              A(I,J)=SUM
            ENDIF
14        CONTINUE
        ENDIF
        AAMAX=0.
        DO 16 I=J,N
          SUM=A(I,J)
          IF (J.GT.1)THEN
            DO 15 K=1,J-1
              SUM=SUM-A(I,K)*A(K,J)
15          CONTINUE
            A(I,J)=SUM
          ENDIF
          DUM=VV(I)*ABS(SUM)
          IF (DUM.GE.AAMAX) THEN
            IMAX=I
            AAMAX=DUM
          ENDIF
16      CONTINUE
        IF (J.NE.IMAX)THEN
          DO 17 K=1,N
            DUM=A(IMAX,K)
            A(IMAX,K)=A(J,K)
            A(J,K)=DUM
17        CONTINUE
          D=-D
          VV(IMAX)=VV(J)
        ENDIF
        INDX(J)=IMAX
        IF(J.NE.N)THEN
          IF(A(J,J).EQ.0.)A(J,J)=TINY
          DUM=1./A(J,J)
          DO 18 I=J+1,N
            A(I,J)=A(I,J)*DUM
18        CONTINUE
        ENDIF
19    CONTINUE
      IF(A(N,N).EQ.0.)A(N,N)=TINY
      RETURN
      END
!CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC

      subroutine multmat(size,n,a,b,c)
      implicit none
      
      integer size
      real a(size,size),b(size,size),c(size,size)
      integer n
      integer i,j,k
      real temp


      do i = 1,n
        do j = 1,n
           temp = 0.0
           do k = 1,n
              temp = temp+a(i,k)*b(k,j)
           enddo
           c(i,j)=temp
        enddo
      enddo
      return
      end
