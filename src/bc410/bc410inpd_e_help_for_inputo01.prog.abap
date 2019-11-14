*----------------------------------------------------------------------*
***INCLUDE BC410D_TEMPLATE1O01 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0100 OUTPUT.
  SET PF-STATUS 'STATUS_100'.
  SET TITLEBAR 'TITLE_100'.

ENDMODULE.                             " STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_0200  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0200 OUTPUT.
  SET PF-STATUS 'STATUS_200'.
  SET TITLEBAR 'TITLE_200' WITH
              sdyn_conn-carrid
              sdyn_conn-connid
              sdyn_conn-fldate .
ENDMODULE.                             " STATUS_0200  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  TRANS_TO_200  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE trans_to_200 OUTPUT.
  MOVE-CORRESPONDING wa_conn TO sdyn_conn.
ENDMODULE.                             " TRANS_TO_200  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  clear_ok_code  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE clear_ok_code OUTPUT.
  CLEAR ok_code.
ENDMODULE.                             " clear_ok_code  OUTPUT
