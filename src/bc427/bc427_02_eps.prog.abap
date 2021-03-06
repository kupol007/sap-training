*-------------------------------------------------------------*
* This program translates the name of a weekday into English. *
*-------------------------------------------------------------*

REPORT  BC427_02_EPS.

PARAMETERS weekday TYPE s_weekday_02.


START-OF-SELECTION.

  CASE weekday.
    WHEN '1'.
      WRITE 'Monday'.
      EXIT.
    WHEN '2'.
      WRITE 'Tuesday'.
      EXIT.
    WHEN '3'.
      WRITE 'Wednesday'.
      EXIT.
    WHEN '4'.
      WRITE 'Thursday'.
      EXIT.
    WHEN '5'.
      WRITE 'Friday'.
      EXIT.
  ENDCASE.

ENHANCEMENT-POINT BC427_02_EP1 SPOTS BC427_02_ESPOT1.

ENHANCEMENT-SECTION     BC427_02_ES1 SPOTS BC427_02_ESPOT1.
  MESSAGE 'Invalid weekday input' TYPE 'I'.
END-ENHANCEMENT-SECTION.
