*&---------------------------------------------------------------------*
*& Include BC402_CALD_CREATE_CUSTOMERTOP                               *
*&                                                                     *
*&---------------------------------------------------------------------*

PROGRAM  sapbc402_cald_create_customer MESSAGE-ID bc402.

DATA:
  answer, flag.

DATA:
  ok_code LIKE sy-ucomm,
  save_ok LIKE ok_code.

TABLES:
  scustom,
  sbuspart.
