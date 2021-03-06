*&------------------------------------
*&  Include           BC405_ARCS_3E01
*&------------------------------------
*&------------------------------------
*&   Event START-OF-SELECTION
*&------------------------------------
START-OF-SELECTION.
* retrieve data into internal table
  SELECT        * FROM  sflight
    INTO CORRESPONDING FIELDS OF TABLE it_sflight
         WHERE  carrid  IN so_car
         AND    connid  IN so_con.

* fill additional data fields
  LOOP AT it_sflight INTO wa_sflight.
* seats free
    wa_sflight-seatsfree =
      wa_sflight-seatsmax + wa_sflight-seatsmax_b
      + wa_sflight-seatsmax_f
      - wa_sflight-seatsocc - wa_sflight-seatsocc_b
      - wa_sflight-seatsocc_f.
* usage (exception light)
    IF wa_sflight-seatsfree = 0.
      wa_sflight-usage = '1'.
    ELSEIF wa_sflight-seatsfree <= 20.
      wa_sflight-usage = '2'.
    ELSE.
      wa_sflight-usage = '3'.
    ENDIF.
* icon "in the future/not in the future"
    IF wa_sflight-fldate > sy-datum.
      wa_sflight-icon_future = icon_positive.
    ELSE.
      wa_sflight-icon_future = icon_negative.
    ENDIF.
* cell colors
* single cell if planetype is 747-400
    IF wa_sflight-planetype = '747-400'.
      CLEAR wa_colors.
      wa_colors-fname = 'PLANETYPE'.
      wa_colors-color-col = col_positive.
      wa_colors-color-int = 1.
      APPEND wa_colors TO wa_sflight-it_colors.
    ENDIF.

* whole line if seatsfree gt 200
    IF wa_sflight-seatsfree >= 200.
      CLEAR wa_colors.
      wa_colors-color-col = col_heading.
      wa_colors-color-int = 1.
      APPEND wa_colors TO wa_sflight-it_colors.
    ENDIF.

    MODIFY it_sflight
      FROM wa_sflight
      TRANSPORTING
        seatsfree
        usage
        icon_future
        it_colors.
  ENDLOOP.

* adjustments for ALV type
  CASE 'X'.
    WHEN pa_full OR pa_list.

* decide about list display
      IF pa_list IS NOT INITIAL.
        list_display = if_salv_c_bool_sap=>true.
      ELSE.
        list_display = if_salv_c_bool_sap=>false.
      ENDIF.

* create ALV instance
      TRY.
          cl_salv_table=>factory(
           EXPORTING
             list_display   = list_display
*     R_CONTAINER    =
*     CONTAINER_NAME =
            IMPORTING
              r_salv_table   = gr_alv
            CHANGING
              t_table        = it_sflight
                 ).
        CATCH cx_salv_msg INTO gr_error.
        cl_sapbc405_exc_handler=>process_alv_error_msg(
          r_error = gr_error
                 ).

      ENDTRY.

* define settings
      PERFORM define_settings USING gr_alv.
* display ALV
      gr_alv->display( ).

    WHEN pa_cont.
      CALL SCREEN 100.
  ENDCASE.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_layout.
  DATA: gs_layout TYPE salv_s_layout_info,
        gs_key TYPE salv_s_layout_key.

  gs_key-report = sy-cprog.

  gs_layout =
    cl_salv_layout_service=>f4_layouts(
       s_key    = gs_key
*      restrict = if_salv_c_layout=>restrict_none
         ).

  p_layout = gs_layout-layout.
