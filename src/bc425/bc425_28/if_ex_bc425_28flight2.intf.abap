*"* components of interface IF_EX_BC425_28FLIGHT2
interface IF_EX_BC425_28FLIGHT2
  public .


  data WA type SFLIGHT28 .

  methods GET_DATA
    exporting
      value(E_FLIGHT) type SFLIGHT28 .
  methods PUT_DATA
    importing
      value(I_FLIGHT) type SFLIGHT28 .
endinterface.
