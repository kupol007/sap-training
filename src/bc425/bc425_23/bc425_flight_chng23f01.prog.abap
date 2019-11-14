*----------------------------------------------------------------------*
***INCLUDE BC425_FLIGHT_CHNG23F01 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  SAVE_FLIGHTS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM save_flights.

  PERFORM update_flight ON COMMIT.

  COMMIT WORK.

  CALL FUNCTION 'DEQUEUE_ESFLIGHT23'
    EXPORTING
      mode_SFLIGHT23 = 'E'
      mandt          = sy-mandt
      carrid         = SFLIGHT23-carrid
      connid         = SFLIGHT23-connid
      fldate         = SFLIGHT23-fldate.

ENDFORM.                    " SAVE_FLIGHTS

*&---------------------------------------------------------------------*
*&      Form  UPDATE_sflight
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM update_flight.

  UPDATE SFLIGHT23 FROM gs_flight.

  IF sy-subrc = 0.
    MESSAGE s008.
*   Daten erfolgreich verbucht
  ENDIF.

ENDFORM.                    " UPDATE_sflight
*&---------------------------------------------------------------------*
*&      Form  set_screen_status
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM set_screen_status .

  CLEAR: gs_excl_tab,
         gt_excl_tab.
  APPEND 'MORE' TO gt_excl_tab.
  APPEND 'CHNG' TO gt_excl_tab.
  APPEND 'CREA' TO gt_excl_tab.

  CASE save_ok.

    WHEN 'MORE'.
      APPEND 'SAVE' TO gt_excl_tab.

    WHEN 'CHNG' OR 'CREA'.

    WHEN OTHERS.
  ENDCASE.

  LOOP AT SCREEN.
    IF screen-group1 = 'MOD' AND gv_change_mode = c_false.
      screen-input = 0.
      MODIFY SCREEN.
    ENDIF.
  ENDLOOP.

ENDFORM.                    " set_screen_status
