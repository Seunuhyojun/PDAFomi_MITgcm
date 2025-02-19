#include "CPP_OPTIONS.h"

CBOP
C     !ROUTINE: INI_VEL_ENS
C     !INTERFACE:
      SUBROUTINE INI_VEL_ENS( myThid, ensstr )

C     !DESCRIPTION: \bv
C     *=================================================================
C     | SUBROUTINE INI_VEL
C     | o Initialize flow field (either to zero or from input files)
C     *=================================================================
C     \ev

C     !USES:
      IMPLICIT NONE
C     === Global variables ===
#include "SIZE.h"
#include "EEPARAMS.h"
#include "PARAMS.h"
#include "GRID.h"
#include "DYNVARS.h"

C     !INPUT/OUTPUT PARAMETERS:
C     == Routine arguments ==
C     myThid ::  Number of this instance of INI_VEL
      INTEGER myThid
      CHARACTER(len=5) :: ensstr          ! String for ensemble member

C     !LOCAL VARIABLES:
C     == Local variables ==
C     i,j,k  :: Loop counters
C     bi,bj  :: tile indices
      INTEGER bi,bj,i,j,k
CEOP

C--   Initialise velocity fields to zero
C
C     If you want to specify an analytic initial state for the flow
C     field then customize the following section of code.
C     It is, however, often easier to generate initial conditions
C     off-line and read them from input files...
C
      DO bj = myByLo(myThid), myByHi(myThid)
       DO bi = myBxLo(myThid), myBxHi(myThid)
        DO k=1,Nr
         DO j=1-Oly,sNy+Oly
          DO i=1-Olx,sNx+Olx
           uVel(i,j,k,bi,bj)=0. _d 0
           vVel(i,j,k,bi,bj)=0. _d 0
          ENDDO
         ENDDO
        ENDDO
       ENDDO
      ENDDO

      IF (uVelInitFile .NE. ' ' .OR. vVelInitFile .NE. ' ') THEN
C     Read an initial state for each component if required
       IF (uVelInitFile .NE. ' ')
     & CALL READ_FLD_XYZ_RL( uVelInitFile, ensstr, uVel, 0, myThid )

       IF (vVelInitFile .NE. ' ')
     & CALL READ_FLD_XYZ_RL( vVelInitFile, ensstr, vVel, 0, myThid )

       CALL EXCH_UV_XYZ_RL(uVel,vVel,.TRUE.,myThid)
      ENDIF

      DO bj = myByLo(myThid), myByHi(myThid)
       DO bi = myBxLo(myThid), myBxHi(myThid)
        DO k=1,Nr
         DO j=1-Oly,sNy+Oly
          DO i=1-Olx,sNx+Olx
           uVel(i,j,k,bi,bj)=uVel(i,j,k,bi,bj)*_maskW(i,j,k,bi,bj)
           vVel(i,j,k,bi,bj)=vVel(i,j,k,bi,bj)*_maskS(i,j,k,bi,bj)
          ENDDO
         ENDDO
        ENDDO
       ENDDO
      ENDDO

      RETURN
      END
