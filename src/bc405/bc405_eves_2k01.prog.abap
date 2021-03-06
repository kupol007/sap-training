*&------------------------------------------------
*&  Include           BC405_EVES_2K01
*&------------------------------------------------
CLASS lcl_handler DEFINITION.
  PUBLIC SECTION.
    CLASS-METHODS:
      on_added_function
        FOR EVENT added_function
          OF cl_salv_events_table
        IMPORTING e_salv_function.  " type salv_de_function

ENDCLASS.                    "lcl_handler DEFINITION

*-------------------------------------------------
*       CLASS lcl_handler IMPLEMENTATION
*-------------------------------------------------
CLASS lcl_handler IMPLEMENTATION.
  METHOD on_added_function.
    DATA: lr_columns TYPE REF TO cl_salv_columns_table,
          lr_column TYPE REF TO cl_salv_column_table.
    DATA: l_lvc_s_colo TYPE lvc_s_colo.
    CASE e_salv_function.
      WHEN 'REORDER'.
* get the COLUMNS object
        lr_columns = gr_alv->get_columns( ).
* positions: (MANDT column + 3 key colums)
        lr_columns->set_column_position(
            columnname = 'SEATSOCC'
            position   = 5
               ).

        lr_columns->set_column_position(
            columnname = 'SEATSOCC_B'
            position   = 6
               ).

        lr_columns->set_column_position(
            columnname = 'SEATSOCC_F'
            position   = 7
               ).

* prepare color info
        l_lvc_s_colo-col = col_negative.
        l_lvc_s_colo-int = 0.
        l_lvc_s_colo-inv = 0.
* column SEATSOCC
        lr_column
          ?= lr_columns->get_column(
               columnname = 'SEATSOCC' ).
        lr_column->set_color( value = l_lvc_s_colo ).

* column SEATSOCC_B
        lr_column
          ?= lr_columns->get_column(
               columnname = 'SEATSOCC_B' ).
        lr_column->set_color( value = l_lvc_s_colo ).

* column SEATSOCC_F
        lr_column
          ?= lr_columns->get_column(
               columnname = 'SEATSOCC_F' ).
        lr_column->set_color( value = l_lvc_s_colo ).

    ENDCASE.
  ENDMETHOD.                    "on_added_function
ENDCLASS.                    "lcl_handler IMPLEMENTATION
