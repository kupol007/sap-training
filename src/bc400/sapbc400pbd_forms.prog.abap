*&---------------------------------------------------------------------*
*& Report  SAPBC400PBD_FORMS                                           *
*&---------------------------------------------------------------------*
*&                                                                     *
*&                                                                     *
*&---------------------------------------------------------------------*

REPORT  sapbc400pbd_forms .

PARAMETERS pa_car TYPE s_carr_id.

CONSTANTS actvt_display TYPE activ_auth VALUE '03'.

DATA itab_flight TYPE sbc400_t_sbc400focc.
DATA subrc LIKE sy-subrc.


PERFORM authority_scarrid
          USING
            pa_car
            actvt_display
          CHANGING
            subrc.

IF subrc = 0.

  PERFORM fill_itab USING pa_car
                    CHANGING itab_flight.

  SORT itab_flight BY percentage.

  PERFORM write_itab USING itab_flight.

ENDIF.



*&---------------------------------------------------------------------*
*&      Form  FILL_ITAB
*&---------------------------------------------------------------------*
*       Filling internal table with records of sflight
*----------------------------------------------------------------------*
FORM fill_itab USING
                 value(iv_carrid) TYPE s_carr_id
               CHANGING
                 ct_flight TYPE sbc400_t_sbc400focc.

  DATA ls_flight TYPE sbc400focc.      " local structure

  SELECT carrid connid fldate seatsmax seatsocc FROM sflight
         INTO CORRESPONDING FIELDS OF TABLE ct_flight
         WHERE carrid = iv_carrid.

  IF sy-subrc = 0.
    LOOP AT ct_flight INTO ls_flight.
      ls_flight-percentage = 100 * ls_flight-seatsocc /
                             ls_flight-seatsmax.
      MODIFY ct_flight FROM ls_flight
                       INDEX sy-tabix
                       TRANSPORTING percentage .
    ENDLOOP.
  ENDIF.

ENDFORM.                               " FILL_ITAB


*&---------------------------------------------------------------------*
*&      Form  WRITE_ITAB
*&---------------------------------------------------------------------*
*       creating a list from internal table
*----------------------------------------------------------------------*
FORM write_itab USING it_flight TYPE sbc400_t_sbc400focc.

  DATA ls_flight TYPE sbc400focc.

  LOOP AT it_flight INTO ls_flight.

    WRITE: / ls_flight-carrid COLOR COL_KEY,
             ls_flight-connid COLOR COL_KEY,
             ls_flight-fldate COLOR COL_KEY,
             ls_flight-seatsocc,
             ls_flight-seatsmax,
             ls_flight-percentage, '%'.
  ENDLOOP.

ENDFORM.                               " WRITE_ITAB


*&---------------------------------------------------------------------*
*&      Form  AUTHORITY_SCARRID
*&---------------------------------------------------------------------*
*       authorization check
*----------------------------------------------------------------------*
FORM authority_scarrid
        USING
          value(iv_carrid) TYPE s_carr_id
          value(iv_actvt) TYPE activ_auth
        CHANGING
          cv_return LIKE sy-subrc.

  AUTHORITY-CHECK OBJECT 'S_CARRID'
      ID 'CARRID' FIELD iv_carrid
      ID 'ACTVT'  FIELD iv_actvt.

  cv_return = sy-subrc.

ENDFORM.                               " AUTHORITY_SCARRID
