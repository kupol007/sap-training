*"* components of interface IF_EX_BC425_14FLIGHT2
interface IF_EX_BC425_14FLIGHT2
  public .


  data WA type SFLIGHT14 .

  methods GET_DATA
    exporting
      value(E_FLIGHT) type SFLIGHT14 .
  methods PUT_DATA
    importing
      value(I_FLIGHT) type SFLIGHT14 .
endinterface.
