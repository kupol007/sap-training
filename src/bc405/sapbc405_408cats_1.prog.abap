*&---------------------------------------------------------------------*
*& Report  SAPBC408CATS_1                                             *
*&                                                                     *
*&---------------------------------------------------------------------*
*&                                                                     *
*&                                                                     *
*&---------------------------------------------------------------------*

REPORT  sapbc408cats_1.
TYPE-POOLS: col, icon.

* work area for ALV data and color information
DATA:
  BEGIN OF wa_sflight.
INCLUDE TYPE sflight.
DATA:
    light,  "graphical indicator for booking status
    it_field_colors  TYPE lvc_t_scol, "for cell highlighting
    changes_possible TYPE icon-id,
    color(4),
  END OF wa_sflight,

  it_sflight LIKE TABLE OF wa_sflight.

DATA:
  ok_code TYPE sy-ucomm.

DATA: cont TYPE REF TO cl_gui_custom_container,
      alv TYPE REF TO cl_gui_alv_grid.

DATA: my_variant TYPE disvariant.

* data needed for layout
DATA:
  wa_layout TYPE lvc_s_layo,
  wa_field_color LIKE LINE OF wa_sflight-it_field_colors.

* field catalog
DATA:
  it_field_cat TYPE lvc_t_fcat,
  wa_field_cat LIKE LINE OF it_field_cat.

SELECT-OPTIONS: so_car FOR wa_sflight-carrid,
                so_con FOR wa_sflight-connid.
SELECTION-SCREEN SKIP.
PARAMETERS: pa_lv TYPE disvariant-variant.

************************************************************************
*ABAP events
************************************************************************
START-OF-SELECTION.
  SELECT * FROM sflight
    INTO CORRESPONDING FIELDS OF TABLE it_sflight
    WHERE carrid IN so_car
    AND   connid IN so_con.

  LOOP AT it_sflight INTO wa_sflight.

* set indicator for flights of current month
* Fluege des laufenden Monats hervorheben
    IF wa_sflight-fldate(6) = sy-datum(6).
      CONCATENATE 'C' col_negative '01' INTO wa_sflight-color.
    ENDIF.

* set icon for bookings status
* Ikone fuer Buchungsstatus belegen
    IF wa_sflight-seatsocc = 0.
      wa_sflight-light = 1.
    ELSEIF wa_sflight-seatsocc < 50.
      wa_sflight-light = 2.
    ELSE.
      wa_sflight-light = 3.
    ENDIF.

* highlight specific aircraft
* besonderen Flugzeugtyp hervorheben
    IF wa_sflight-planetype = '747-400'.
      wa_field_color-fname = 'PLANETYPE'.
      wa_field_color-color-col = col_positive.
      wa_field_color-color-int = 1.
      wa_field_color-color-inv = 0.
      wa_field_color-nokeycol = 'X'.
      APPEND wa_field_color TO wa_sflight-it_field_colors.
    ENDIF.

* set indicator for flights in the past
* Ikone setzen fuer Fluege in der Vergangenheit
    IF wa_sflight-fldate < sy-datum.
      wa_sflight-changes_possible = icon_space.
    ELSE.
      wa_sflight-changes_possible = icon_okay.
    ENDIF.


    MODIFY it_sflight
      FROM wa_sflight
    TRANSPORTING color light it_field_colors changes_possible.
  ENDLOOP.

  CALL SCREEN 100.

************************************************************************
*PBO modules
************************************************************************
MODULE clear_ok_code OUTPUT.
  CLEAR ok_code.
ENDMODULE.                 " clear_ok_code  OUTPUT

*----------------------------------------------------------------------*
MODULE status_0100 OUTPUT.
  SET PF-STATUS 'DYN'.
  SET TITLEBAR 'T1'.
ENDMODULE.                 " STATUS_0100  OUTPUT

*----------------------------------------------------------------------*
MODULE create_and_transfer OUTPUT.
  CHECK cont IS INITIAL.
  CREATE OBJECT cont
    EXPORTING
      container_name              = 'MY_CONTROL_AREA'
    EXCEPTIONS
      OTHERS                      = 1.

  IF sy-subrc <> 0 AND sy-batch IS INITIAL.
    MESSAGE a010(bc405_408).
  ENDIF.

  CREATE OBJECT alv
    EXPORTING
      i_parent          = cont
    EXCEPTIONS
      OTHERS            = 1.

  IF sy-subrc <> 0 AND sy-batch IS INITIAL.
    MESSAGE a010(bc405_408).
  ENDIF.


  my_variant-report = sy-cprog.
  IF NOT pa_lv IS INITIAL.
    my_variant-variant = pa_lv.
  ENDIF.

*define layout
  wa_layout-grid_title = 'Flights'(h01).                    "#EC *
  wa_layout-no_hgridln = 'X'.
  wa_layout-no_vgridln = 'X'.

*field that contains information on row color
  wa_layout-info_fname = 'COLOR'.

*internal table that contains information on cell color
  wa_layout-ctab_fname = 'IT_FIELD_COLORS'.

*field that contains information on exception (indicator)
  wa_layout-excp_fname = 'LIGHT'.

* multiple row and column selection
  wa_layout-sel_mode = 'A'.

* fill field catalog
  wa_field_cat-fieldname = 'SEATSOCC'.
  wa_field_cat-do_sum = 'X'.
  APPEND wa_field_cat TO it_field_cat.

  CLEAR wa_field_cat.
  wa_field_cat-fieldname = 'PAYMENTSUM'.
  wa_field_cat-no_out = 'X'.
  APPEND wa_field_cat TO it_field_cat.

  CLEAR wa_field_cat.
  wa_field_cat-fieldname = 'LIGHT'.
  wa_field_cat-coltext = 'Utilization'(h02).                "#EC *
  APPEND wa_field_cat TO it_field_cat.

  CLEAR wa_field_cat.
  wa_field_cat-fieldname = 'CHANGES_POSSIBLE'.
  wa_field_cat-col_pos = 5.
  wa_field_cat-coltext = 'Changes possible'(h03).           "#EC *
  wa_field_cat-tooltip = 'Are changes possible?'(t01).      "#EC *
  APPEND wa_field_cat TO it_field_cat.

  CALL METHOD alv->set_table_for_first_display
    EXPORTING
      i_structure_name = 'SFLIGHT'
      is_variant       = my_variant
      i_save           = 'A'
      is_layout        = wa_layout
    CHANGING
      it_fieldcatalog  = it_field_cat
      it_outtab        = it_sflight
    EXCEPTIONS
      OTHERS           = 1.
  IF sy-subrc <> 0.
    MESSAGE a012(bc405_408).
  ENDIF.

ENDMODULE.                 " create_and_transfer  OUTPUT

************************************************************************
*PAI modules
************************************************************************
MODULE user_command_0100 INPUT.
  CASE ok_code.
    WHEN 'BACK' OR 'CANCEL' OR 'EXIT'.
      PERFORM free.
      SET SCREEN 0.
  ENDCASE.
ENDMODULE.                 " USER_COMMAND_0100  INPUT

************************************************************************
*Form routines
************************************************************************
FORM free.
  CALL METHOD: alv->free,
               cont->free.

  FREE: alv,
        cont.
ENDFORM.                    " free
