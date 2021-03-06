*DECK DSVCO
      SUBROUTINE DSVCO (RSAV, ISAV)
C***BEGIN PROLOGUE  DSVCO
C***SUBSIDIARY
C***PURPOSE  Subsidiary to DDEBDF
C***LIBRARY   SLATEC
C***TYPE      DOUBLE PRECISION (SVCO-S, DSVCO-D)
C***AUTHOR  (UNKNOWN)
C***DESCRIPTION
C
C   DSVCO transfers data from a common block to arrays within the
C   integrator package DDEBDF.
C
C***SEE ALSO  DDEBDF
C***ROUTINES CALLED  (NONE)
C***COMMON BLOCKS    DDEBD1
C***REVISION HISTORY  (YYMMDD)
C   820301  DATE WRITTEN
C   891214  Prologue converted to Version 4.0 format.  (BAB)
C   900328  Added TYPE section.  (WRB)
C***END PROLOGUE  DSVCO
C-----------------------------------------------------------------------
C THIS ROUTINE STORES IN RSAV AND ISAV THE CONTENTS OF COMMON BLOCK
C DDEBD1  , WHICH IS USED INTERNALLY IN THE DDEBDF PACKAGE.
C
C RSAV = DOUBLE PRECISION ARRAY OF LENGTH 218 OR MORE.
C ISAV = INTEGER ARRAY OF LENGTH 33 OR MORE.
C-----------------------------------------------------------------------
      INTEGER I, ILS, ISAV, LENILS, LENRLS
      DOUBLE PRECISION RLS, RSAV
      DIMENSION RSAV(*),ISAV(*)
      SAVE LENRLS, LENILS
      COMMON /DDEBD1/ RLS(218),ILS(33)
      DATA LENRLS /218/, LENILS /33/
C
C***FIRST EXECUTABLE STATEMENT  DSVCO
      DO 10 I = 1, LENRLS
         RSAV(I) = RLS(I)
   10 CONTINUE
      DO 20 I = 1, LENILS
         ISAV(I) = ILS(I)
   20 CONTINUE
      RETURN
C     ----------------------- END OF SUBROUTINE DSVCO
C     -----------------------
      END
