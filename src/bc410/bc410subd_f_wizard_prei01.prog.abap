*----------------------------------------------------------------------*
***INCLUDE BC410SUBD_F_WIZARD_PREI01 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  get_spfli  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE get_spfli INPUT.

  SELECT SINGLE * FROM spfli INTO CORRESPONDING FIELDS OF sdyn_conn
   WHERE carrid = sdyn_conn-carrid AND connid = sdyn_conn-connid.

ENDMODULE.                             " get_spfli  INPUT
*&---------------------------------------------------------------------*
*&      Module  exit  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE exit INPUT.
  LEAVE PROGRAM.
ENDMODULE.                             " exit  INPUT
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
