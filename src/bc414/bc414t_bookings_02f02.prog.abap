*----------------------------------------------------------------------*
*   INCLUDE BC414T_BOOKINGS_02F02
*----------------------------------------------------------------------*

*----------------------------------------------------------------------*
*   FORM ENQ_SFLIGHT
*----------------------------------------------------------------------*
FORM enq_sflight.
************************************************************************
* a) Call Function ENQUEUE_ESFLIGHT
* b) Handle exceptions (use message 060)
************************************************************************
ENDFORM.                               "ENQ_SFLIGHT

*----------------------------------------------------------------------*
*   FORM ENQ_SBOOK
*----------------------------------------------------------------------*
FORM enq_sbook.
************************************************************************
* a) Call Function ENQUEUE_ESBOOK
* b) Handle exceptions (use message 061)
************************************************************************
ENDFORM.                               "ENQ_SBOOK

*----------------------------------------------------------------------*
*   FORM ENQ_SFLIGHT_SBOOK
*----------------------------------------------------------------------*
FORM enq_sflight_sbook.
************************************************************************
* a) Call Function ENQUEUE_ESFLIGHT_SBOOK
* b) Handle exceptions (use message 062)
************************************************************************
ENDFORM.                               "ENQ_SFLIGHT_SBOOK

*----------------------------------------------------------------------*
*   FORM DEQ_ALL
*----------------------------------------------------------------------*
FORM deq_all.
************************************************************************
* a) Call Function DEQUEUE_ALL
************************************************************************
ENDFORM.                               "DEQ_ALL
