*"* components of interface IF_EX_BC427_01_MX_BADI
interface IF_EX_BC427_01_MX_BADI
  public .


  interfaces IF_BADI_INTERFACE .

  methods SHOW_ADDITIONAL_CUSTOMER_DATA
    importing
      !IM_CUSTOMID type SCUSTOM-ID .
endinterface.
