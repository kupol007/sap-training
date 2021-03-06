*&---------------------------------------------------------------------*
*& Report  SAPBC408EVES_2                                             *
*&                                                                     *
*&---------------------------------------------------------------------*
*&                                                                     *
*&                                                                     *
*&---------------------------------------------------------------------*

REPORT  sapbc408eves_2                                             .
TYPE-POOLS: col, icon.

* work area for ALV data
DATA:
  BEGIN OF wa_sflight.
INCLUDE TYPE sflight.
DATA: color(4),
    light,  "graphical indicator for booking status
    it_field_colors TYPE lvc_t_scol, "for cell highlighting
    changes_possible TYPE icon-id,
  END OF wa_sflight,

  it_sflight LIKE TABLE OF wa_sflight.

DATA:
  ok_code LIKE sy-ucomm.

DATA:
  alv TYPE REF TO cl_gui_alv_grid,
  cont TYPE REF TO cl_gui_custom_container.

DATA: my_variant TYPE disvariant,
      my_print type lvc_s_prnt.

* data needed for layout
DATA:
  wa_layout TYPE lvc_s_layo,
  wa_field_color LIKE LINE OF wa_sflight-it_field_colors.

* field catalog
DATA:
  it_field_cat TYPE lvc_t_fcat,
  wa_field_cat LIKE LINE OF it_field_cat.

DATA:
  bookings_total TYPE i,
  bookings_total_c(10),
  message_text(60).

SELECT-OPTIONS: so_car FOR wa_sflight-carrid,
                so_con FOR wa_sflight-connid.
SELECTION-SCREEN SKIP.
PARAMETERS: pa_lv TYPE disvariant-variant.

************************************************************************
*Local class for ALV event handling
************************************************************************
CLASS: lcl_handler DEFINITION.
  PUBLIC SECTION.
    CLASS-METHODS: on_doubleclick
                     FOR EVENT double_click OF cl_gui_alv_grid
                     IMPORTING es_row_no,
                   print_top
                     FOR EVENT print_top_of_page OF cl_gui_alv_grid,
                   print_tol
                     FOR EVENT print_top_of_list OF cl_gui_alv_grid.

ENDCLASS.                    "lcl_handler DEFINITION


*---------------------------------------------------------------------*
CLASS: lcl_handler IMPLEMENTATION.
  METHOD on_doubleclick.
    READ TABLE it_sflight INTO wa_sflight INDEX es_row_no-row_id.
    IF sy-subrc NE 0.
      MESSAGE i075(bc408).
      EXIT.
    ENDIF.

    bookings_total = wa_sflight-seatsocc + wa_sflight-seatsocc_b +
                       wa_sflight-seatsocc_f.

* built message text
    bookings_total_c = bookings_total.
    CONCATENATE 'Total number of bookings:'(m01)   "#EC *
                bookings_total_c
      INTO message_text.

    MESSAGE message_text TYPE 'I'.

  ENDMETHOD.                    "on_doubleclick

  METHOD print_top.
    DATA: pos TYPE i.
    FORMAT COLOR COL_HEADING.
    WRITE: / sy-datum.
    pos = sy-linsz / 2 - 3. " length of pagno: 6 chars
    WRITE AT pos sy-pagno.
    pos = sy-linsz - 11. " length of username: 12 chars
    WRITE: AT pos sy-uname.
    ULINE.
  ENDMETHOD.                    "print_top

  METHOD print_tol.
    DATA: wa_so_car LIKE LINE OF so_car,
          wa_so_con LIKE LINE OF so_con.
    CONSTANTS: end TYPE i VALUE 20.

    FORMAT COLOR COL_HEADING.
    WRITE: / 'Select options'(000), AT end space.           "#EC *
    SKIP.
    WRITE: / 'Airlines'(001), AT end space.                  "#EC *
    ULINE AT /(end).
    FORMAT COLOR COL_NORMAL.
    LOOP AT so_car INTO wa_so_car.
      WRITE: / wa_so_car-sign,
               wa_so_car-option,
               wa_so_car-low,
               wa_so_car-high.
    ENDLOOP.

    SKIP.

    FORMAT COLOR COL_HEADING.
    WRITE: / 'Connections'(002), AT end space .             "#EC *
    ULINE AT /(end).
    FORMAT COLOR COL_NORMAL.
    LOOP AT so_con INTO wa_so_con.
      WRITE: / wa_so_con-sign,
               wa_so_con-option,
               wa_so_con-low NO-ZERO,
               wa_so_con-high NO-ZERO.
    ENDLOOP.

    SKIP.

  ENDMETHOD.                    "print_tol

ENDCLASS.                    "lcl_handler IMPLEMENTATION


************************************************************************
*ABAP events
************************************************************************
*----------------------------------------------------------------------*
START-OF-SELECTION.
  SELECT * FROM sflight
    INTO CORRESPONDING FIELDS OF TABLE it_sflight
    WHERE carrid IN so_car
    AND   connid IN so_con.

  LOOP AT it_sflight INTO wa_sflight.
    CLEAR: wa_sflight-it_field_colors.

* set indicator for flights of current month
* Fluege des laufenden Monats hervorheben
    IF wa_sflight-fldate(6) = sy-datum(6).
      CONCATENATE 'C' col_negative '01' INTO wa_sflight-color.
    ENDIF.

* set icon for bookings status
* Ikone für Buchungsstatus belegen
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
      APPEND wa_field_color TO wa_sflight-it_field_colors.
    ENDIF.

* set indicator for flights in the past
* Ikone setzen für Flüge in der Vergangenheit
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
MODULE status_0100 OUTPUT.
  SET PF-STATUS 'DYN'.
  SET TITLEBAR 'T1'.
ENDMODULE.                 " STATUS_0100  OUTPUT

*---------------------------------------------------------------------*
MODULE clear_ok_code OUTPUT.
  CLEAR ok_code.
ENDMODULE.                 " clear_ok_code  OUTPUT

*----------------------------------------------------------------------*
MODULE create_and_transfer OUTPUT.
  CHECK cont IS INITIAL.
  CREATE OBJECT cont
    EXPORTING
      container_name              = 'MY_CONTROL_AREA'
    EXCEPTIONS
      OTHERS                      = 1.

  IF sy-subrc <> 0 AND sy-batch IS INITIAL.
    MESSAGE a010(bc408).
  ENDIF.

  CREATE OBJECT alv
    EXPORTING
      i_parent          = cont
    EXCEPTIONS
      OTHERS            = 1.

  IF sy-subrc <> 0 AND sy-batch IS INITIAL.
    MESSAGE a010(bc408).
  ENDIF.

* register event handlers
  SET HANDLER:
    lcl_handler=>on_doubleclick  FOR alv,
    lcl_handler=>print_top       FOR alv,
    lcl_handler=>print_tol       FOR alv.

  my_variant-report = sy-cprog.
  IF NOT pa_lv IS INITIAL.
    my_variant-variant = pa_lv.
  ENDIF.

  my_print-prntlstinf = 'X'.
  my_print-grpchgedit = 'X'.

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

*multiple row and column selection
  wa_layout-sel_mode = 'A'.

*fill field catalog
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
      is_print         = my_print
    CHANGING
      it_outtab        = it_sflight
      it_fieldcatalog  = it_field_cat
    EXCEPTIONS
      OTHERS           = 1.
  IF sy-subrc <> 0.
    MESSAGE a012(bc408).
  ENDIF.

ENDMODULE.                 " create_and_transfer OUTPUT

************************************************************************
*PAI modules
************************************************************************
MODULE user_command_0100 INPUT.
  CASE ok_code.
    WHEN 'BACK' OR 'EXIT' OR 'CANCEL'.
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
