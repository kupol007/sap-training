*&---------------------------------------------------------------------*
*& Report  SAPBC412_CFWT_EXERCISE1                                     *
*&                                                                     *
*&---------------------------------------------------------------------*
*& Copy template for the first exercise of course BC412                *
*& 'ABAP Dialog Programming using EnjoySAP-Controls'.                  *
*& This template program covers conventional screen processing for     *
*& screen 100 (including GUI title and GUI status).                    *
*& All control specific processing has to be added.                    *
*&---------------------------------------------------------------------*

REPORT  sapbc412_cfwt_exercise1 MESSAGE-ID bc412.
* data declarations
*   screen specific
DATA:
    ok_code      TYPE sy-ucomm,        " command field
    copy_ok_code LIKE ok_code,         " copy of ok_code
    l_answer     TYPE c.               " return flag (used in
" standard user dialogs)

* start of main program
START-OF-SELECTION.

  CALL SCREEN 100.                     " container screen for SAP-Enjoy
  " controls

* end of main program
************************************************************************
*                                                                      *
*              S C R E E N   M O D U L E S                             *
*                                                                      *
************************************************************************
*
*&---------------------------------------------------------------------*
*&      Module  INIT_CONTROL_PROCESSING  OUTPUT
*&---------------------------------------------------------------------*
*       Here you should implement the EnjoySAP control processing:
*       1)  create container object and link to screen area
*       2)  create picture object and link to container
*----------------------------------------------------------------------*
MODULE init_control_processing OUTPUT.
* to be implemented
ENDMODULE.                             " INIT_CONTROL_PROCESSING  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       Implementation of user commands of type ' ':
*       - push buttons on the screen
*       - GUI functions
*----------------------------------------------------------------------*
MODULE user_command_0100 INPUT.
  copy_ok_code = ok_code.
  CLEAR ok_code.

  CASE copy_ok_code.
    WHEN 'BACK'.
      CLEAR l_answer.
      CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
           EXPORTING
*               DEFAULTOPTION  = 'Y'
                textline1      = text-004
                textline2      = text-005
                titel          = text-007
                cancel_display = ' '
           IMPORTING
                answer         = l_answer.

      CASE l_answer.
        WHEN 'J'.
          PERFORM free_control_ressources.
          LEAVE TO SCREEN 0.
        WHEN 'N'.
          SET SCREEN sy-dynnr.
      ENDCASE.

    WHEN 'STRETCH'.        " picture operation: stretch to fit area
*     to be implemented later
    WHEN 'NORMAL'.         " picture operation: fit to normal size
*     to be implemented later
    WHEN 'NORMAL_CENTER'.  " picture operation: center in normal size
*     to be implemented later
    WHEN 'FIT'.                        " picture operation: zoom picture
*     to be implemented later
    WHEN 'FIT_CENTER'.     " picture operation: zoom and center
*     to be implemented later
  ENDCASE.
ENDMODULE.                             " USER_COMMAND_0100  INPUT

*&---------------------------------------------------------------------*
*&      Module  STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*       Set GUI for screen 0100
*----------------------------------------------------------------------*
MODULE status_0100 OUTPUT.
  SET PF-STATUS 'STATUS_NORM_0100'.
  SET TITLEBAR 'TITLE_NORM_0100'.

ENDMODULE.                             " STATUS_0100  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  EXIT_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       Implementation of user commands of type 'E'.
*----------------------------------------------------------------------*
MODULE exit_command_0100 INPUT.
  CASE ok_code.
    WHEN 'CANCEL'.        " cancel current screen processing
      CLEAR l_answer.
      CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
           EXPORTING
*               DEFAULTOPTION  = 'Y'
                textline1      = text-004
                textline2      = text-005
                titel          = text-006
                cancel_display = ' '
           IMPORTING
                answer         = l_answer.
      CASE l_answer.
        WHEN 'J'.
          PERFORM free_control_ressources.
          LEAVE TO SCREEN 0.
        WHEN 'N'.
          CLEAR ok_code.
          SET SCREEN sy-dynnr.
      ENDCASE.

    WHEN 'EXIT'.                       " leave program
      CLEAR l_answer.
      CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
           EXPORTING
*               DEFAULTOPTION  = 'Y'
                textline1      = text-001
                textline2      = text-002
                titel          = text-003
                cancel_display = 'X'
           IMPORTING
                answer         = l_answer.
      CASE l_answer.
        WHEN 'J' OR 'N'.               " no data to update
          PERFORM free_control_ressources.
          LEAVE PROGRAM.
        WHEN 'A'.
          CLEAR ok_code.
          SET SCREEN sy-dynnr.
      ENDCASE.
  ENDCASE.
ENDMODULE.                             " EXIT_COMMAND_0100  INPUT

************************************************************************
*                                                                      *
*              F O R M     R O U T I N E S                             *
*                                                                      *
************************************************************************
*
*&---------------------------------------------------------------------*
*&      Form  FREE_CONTROL_RESSOURCES
*&---------------------------------------------------------------------*
*       Here you should implement: Free all control related ressources.
*----------------------------------------------------------------------*
*       no interface
*----------------------------------------------------------------------*
FORM free_control_ressources.
* to be implemented later
ENDFORM.                               " FREE_CONTROL_RESSOURCES
