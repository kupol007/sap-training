*----------------------------------------------------------------------*
***INCLUDE BC410INPD_0_PROPERTIESI01 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0100 INPUT.
  CASE ok_code.
    WHEN 'BACK'.
      SET SCREEN 0.
  ENDCASE.
ENDMODULE.                             " USER_COMMAND_0100  INPUT
