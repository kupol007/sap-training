class CL_SHM_AREA_HANDLE definition
  public
  inheriting from CL_SHM_AREA
  final
  create private

  global friends CL_SHM_AREA .

*"* public components of class CL_SHM_AREA_HANDLE
*"* do not include other source files here!!!
public section.

  constants AREA_NAME type SHM_AREA_NAME value 'CL_SHM_AREA_00'. "#EC NOTEXT
  data ROOT type ref to CL_SHM_AREA_ROOT read-only .

  class-methods CLASS_CONSTRUCTOR .
  class-methods GET_GENERATOR_VERSION
    returning
      value(GENERATOR_VERSION) type I .
  class-methods ATTACH_FOR_READ
    importing
      !INST_NAME type SHM_INST_NAME default CL_SHM_AREA=>DEFAULT_INSTANCE
    preferred parameter INST_NAME
    returning
      value(HANDLE) type ref to CL_SHM_AREA_HANDLE
    raising
      CX_SHM_INCONSISTENT
      CX_SHM_NO_ACTIVE_VERSION
      CX_SHM_READ_LOCK_ACTIVE
      CX_SHM_EXCLUSIVE_LOCK_ACTIVE
      CX_SHM_PARAMETER_ERROR
      CX_SHM_CHANGE_LOCK_ACTIVE .
  class-methods ATTACH_FOR_WRITE
    importing
      !INST_NAME type SHM_INST_NAME default CL_SHM_AREA=>DEFAULT_INSTANCE
      !ATTACH_MODE type SHM_ATTACH_MODE default CL_SHM_AREA=>ATTACH_MODE_DEFAULT
      !WAIT_TIME type I default 0
    preferred parameter INST_NAME
    returning
      value(HANDLE) type ref to CL_SHM_AREA_HANDLE
    raising
      CX_SHM_EXCLUSIVE_LOCK_ACTIVE
      CX_SHM_VERSION_LIMIT_EXCEEDED
      CX_SHM_CHANGE_LOCK_ACTIVE
      CX_SHM_PARAMETER_ERROR .
  class-methods ATTACH_FOR_UPDATE
    importing
      !INST_NAME type SHM_INST_NAME default CL_SHM_AREA=>DEFAULT_INSTANCE
      !ATTACH_MODE type SHM_ATTACH_MODE default CL_SHM_AREA=>ATTACH_MODE_DEFAULT
      !WAIT_TIME type I default 0
    preferred parameter INST_NAME
    returning
      value(HANDLE) type ref to CL_SHM_AREA_HANDLE
    raising
      CX_SHM_INCONSISTENT
      CX_SHM_NO_ACTIVE_VERSION
      CX_SHM_EXCLUSIVE_LOCK_ACTIVE
      CX_SHM_VERSION_LIMIT_EXCEEDED
      CX_SHM_CHANGE_LOCK_ACTIVE
      CX_SHM_PARAMETER_ERROR .
  class-methods DETACH_AREA
    returning
      value(RC) type SHM_RC .
  class-methods INVALIDATE_INSTANCE
    importing
      !INST_NAME type SHM_INST_NAME default CL_SHM_AREA=>DEFAULT_INSTANCE
      !TERMINATE_CHANGER type ABAP_BOOL default ABAP_TRUE
    preferred parameter INST_NAME
    returning
      value(RC) type SHM_RC
    raising
      CX_SHM_PARAMETER_ERROR .
  class-methods INVALIDATE_AREA
    importing
      !TERMINATE_CHANGER type ABAP_BOOL default ABAP_TRUE
    returning
      value(RC) type SHM_RC
    raising
      CX_SHM_PARAMETER_ERROR .
  class-methods FREE_INSTANCE
    importing
      !INST_NAME type SHM_INST_NAME default CL_SHM_AREA=>DEFAULT_INSTANCE
      !TERMINATE_CHANGER type ABAP_BOOL default ABAP_TRUE
    preferred parameter INST_NAME
    returning
      value(RC) type SHM_RC
    raising
      CX_SHM_PARAMETER_ERROR .
  class-methods FREE_AREA
    importing
      !TERMINATE_CHANGER type ABAP_BOOL default ABAP_TRUE
    returning
      value(RC) type SHM_RC
    raising
      CX_SHM_PARAMETER_ERROR .
  class-methods GET_INSTANCE_INFOS
    returning
      value(INFOS) type SHM_INST_INFOS .
  class-methods BUILD
    importing
      !INST_NAME type SHM_INST_NAME default CL_SHM_AREA=>DEFAULT_INSTANCE
    raising
      CX_SHMA_NOT_CONFIGURED
      CX_SHMA_INCONSISTENT
      CX_SHM_BUILD_FAILED .
  methods SET_ROOT
    importing
      !ROOT type ref to CL_SHM_AREA_ROOT
    raising
      CX_SHM_INITIAL_REFERENCE
      CX_SHM_WRONG_HANDLE .

  methods GET_ROOT
    redefinition .
protected section.
*"* protected components of class CL_SHM_AREA_00
*"* do not include other source files here!!!
private section.
*"* private components of class CL_SHM_AREA_00
*"* do not include other source files here!!!

  constants _VERSION_ type I value 12. "#EC NOTEXT
  class-data _TRACE_SERVICE type ref to IF_SHM_TRACE .
  class-data _TRACE_ACTIVE type ABAP_BOOL value ABAP_FALSE .
  constants _TRANSACTIONAL type ABAP_BOOL value ABAP_FALSE. "#EC NOTEXT
  constants _CLIENT_DEPENDENT type ABAP_BOOL value ABAP_FALSE. "#EC NOTEXT
ENDCLASS.



CLASS CL_SHM_AREA_HANDLE IMPLEMENTATION.


method ATTACH_FOR_READ .

  DATA:
    l_attributes       TYPE shma_attributes,
    l_root             TYPE REF TO object,
    l_cx               TYPE REF TO cx_root,
    l_client           TYPE shm_client,
    l_client_supplied  TYPE abap_bool.

* check if tracing should be activated/de-activated
  IF  ( NOT _trace_service IS INITIAL ).
    TRY.
        _trace_active =
          cl_shm_service=>trace_is_variant_active(
            _trace_service->variant-def_name
          ).
      CATCH cx_root.
    ENDTRY.
  ENDIF.


  IF _trace_active = abap_false OR
  _trace_service->variant-attach_for_read = abap_false.

*   >

    CREATE OBJECT handle.

    handle->client    = l_client.
    handle->inst_name = inst_name.

*   try sneak mode first
    handle->_attach_read( EXPORTING area_name  = area_name
                                    sneak_mode = abap_true
                          IMPORTING root       = l_root ).

    IF l_root IS INITIAL.
*     no root object returned, sneak mode was not successful.
*     -> read area properties from database and try again.
      cl_shm_service=>initialize(
        EXPORTING area_name       = handle->area_name
                  client          = l_client
        IMPORTING attributes      = l_attributes
      ).

      handle->properties = l_attributes-properties.
      handle->_attach_read( EXPORTING area_name  = area_name
                                      sneak_mode = abap_false
                            IMPORTING root       = l_root ).

    ENDIF.

    handle->root ?= l_root.
*   <

  ELSE.

    TRY.

*       >

        CREATE OBJECT handle.

        handle->client    = l_client.
        handle->inst_name = inst_name.

        handle->_attach_read( EXPORTING area_name  = area_name
                                        sneak_mode = abap_true
                              IMPORTING root       = l_root ).

        IF l_root IS INITIAL.
*         no root object returned, sneak mode was not successful.
*         -> read area properties from database and try again.
          cl_shm_service=>initialize(
            EXPORTING area_name       = handle->area_name
                      client          = l_client
            IMPORTING attributes      = l_attributes
          ).

          handle->properties = l_attributes-properties.
          handle->_attach_read( EXPORTING area_name  = area_name
                                          sneak_mode = abap_false
                                IMPORTING root       = l_root ).

        ENDIF.
        handle->root ?= l_root.

*       <
        _trace_service->trin_attach_for_read(
          area_name = area_name
          inst_name = inst_name
          client    = l_client ).

      CLEANUP INTO l_cx.
        _trace_service->trcx_attach_for_read(
          area_name = area_name
          inst_name = inst_name
          client    = l_client
          cx        = l_cx
        ).
    ENDTRY.

  ENDIF.

  handle->inst_trace_service = _trace_service.
  handle->inst_trace_active  = _trace_active.

endmethod.


method ATTACH_FOR_UPDATE .

  DATA:
    l_attributes TYPE shma_attributes,
    l_root       TYPE REF TO object,
    l_cx         TYPE REF TO cx_root,
    l_client     TYPE shm_client,
    l_client_supplied  TYPE abap_bool.

* check if tracing should be activated/de-activated
  IF  ( NOT _trace_service IS INITIAL ).
    TRY.
        _trace_active =
          cl_shm_service=>trace_is_variant_active(
            _trace_service->variant-def_name
          ).
      CATCH cx_root.
    ENDTRY.
  ENDIF.


  IF _trace_active = abap_false OR
  _trace_service->variant-attach_for_upd = abap_false.

*   >

    CREATE OBJECT handle.

    handle->client    = l_client.
    handle->inst_name = inst_name.

    cl_shm_service=>initialize(
      EXPORTING area_name    = handle->area_name
                client       = l_client
      IMPORTING attributes   = l_attributes
    ).

    handle->properties = l_attributes-properties.

    handle->_attach_update(
      EXPORTING area_name = handle->area_name
                mode      = attach_mode
                wait_time = wait_time
      IMPORTING root      = l_root ).

    IF handle->_lock IS NOT INITIAL AND
       abap_true = l_attributes-properties-has_versions.
* in case of Class-Constructors we have to call the attach twice
      handle->_attach_update_2(
        EXPORTING area_name = handle->area_name
                  mode      = attach_mode
                  wait_time = wait_time
        IMPORTING root      = l_root ).
    ENDIF.

    handle->root ?= l_root.

*   <

  ELSE.

    TRY.

*       >

        CREATE OBJECT handle.

        handle->client    = l_client.
        handle->inst_name = inst_name.

        cl_shm_service=>initialize(
          EXPORTING area_name    = handle->area_name
                    client       = l_client
          IMPORTING attributes   = l_attributes
        ).

        handle->properties = l_attributes-properties.

        handle->_attach_update(
          EXPORTING area_name = handle->area_name
                    mode      = attach_mode
                    wait_time = wait_time
          IMPORTING root      = l_root ).

        IF handle->_lock IS NOT INITIAL AND
           abap_true = l_attributes-properties-has_versions.
* in case of Class-Constructors we have to call the attach twice
          handle->_attach_update_2(
            EXPORTING area_name = handle->area_name
                      mode      = attach_mode
                      wait_time = wait_time
            IMPORTING root      = l_root ).
        ENDIF.

        handle->root ?= l_root.

*       <
        _trace_service->trin_attach_for_update(
          area_name = area_name
          inst_name = inst_name
          client    = l_client
          mode      = attach_mode
          wait_time = wait_time
        ).

      CLEANUP INTO l_cx.
        _trace_service->trcx_attach_for_update(
          area_name = area_name
          inst_name = inst_name
          client    = l_client
          mode      = attach_mode
          wait_time = wait_time
          cx        = l_cx
        ).
    ENDTRY.

  ENDIF.

  handle->inst_trace_service = _trace_service.
  handle->inst_trace_active  = _trace_active.

endmethod.


method ATTACH_FOR_WRITE .

  DATA:
    l_attributes TYPE shma_attributes,
    l_cx     TYPE REF TO cx_root,
    l_client TYPE shm_client,
    l_client_supplied  TYPE abap_bool.

* check if tracing should be activated/de-activated
  IF  ( NOT _trace_service IS INITIAL ).
    TRY.
        _trace_active =
          cl_shm_service=>trace_is_variant_active(
            _trace_service->variant-def_name
          ).
      CATCH cx_root.
    ENDTRY.
  ENDIF.


  IF _trace_active = abap_false OR
  _trace_service->variant-attach_for_write = abap_false.

*   >

    CREATE OBJECT handle.

    handle->client    = l_client.
    handle->inst_name = inst_name.

    cl_shm_service=>initialize(
      EXPORTING area_name    = handle->area_name
                client       = l_client
      IMPORTING attributes   = l_attributes
    ).

    handle->properties = l_attributes-properties.

    handle->_attach_write(
      area_name = handle->area_name
      mode      = attach_mode
      wait_time = wait_time ).

*   <

  ELSE.

    TRY.

*     >

        CREATE OBJECT handle.

        handle->client    = l_client.
        handle->inst_name = inst_name.

        cl_shm_service=>initialize(
          EXPORTING area_name    = handle->area_name
                    client       = l_client
          IMPORTING attributes   = l_attributes
        ).

        handle->properties = l_attributes-properties.

        handle->_attach_write(
          area_name = handle->area_name
          mode      = attach_mode
          wait_time = wait_time ).

*     <

        _trace_service->trin_attach_for_write(
          area_name = area_name
          inst_name = inst_name
          client    = l_client
          mode      = attach_mode
          wait_time = wait_time
        ).
      CLEANUP INTO l_cx.
        _trace_service->trcx_attach_for_write(
          area_name = area_name
          inst_name = inst_name
          client    = l_client
          mode      = attach_mode
          wait_time = wait_time
          cx        = l_cx
        ).
    ENDTRY.

  ENDIF.

  handle->inst_trace_service = _trace_service.
  handle->inst_trace_active  = _trace_active.

endmethod.


method BUILD .

  DATA:
    l_cls_name TYPE shm_auto_build_class_name,
    l_cx TYPE REF TO cx_root.

  IF _trace_active = abap_false OR
  _trace_service->variant-build = abap_false.

*   >
    l_cls_name =
      cl_shm_service=>get_auto_build_class_name( area_name ).

    CALL METHOD (l_cls_name)=>if_shm_build_instance~build
      EXPORTING
        inst_name = inst_name.
*   <

  ELSE.

    TRY.

*       >
        l_cls_name =
          cl_shm_service=>get_auto_build_class_name( area_name ).

        CALL METHOD (l_cls_name)=>if_shm_build_instance~build
          EXPORTING
            inst_name = inst_name.
*       <
        _trace_service->trin_build(
          area_name         = area_name
          inst_name         = inst_name
        ).

      CLEANUP INTO l_cx.
        _trace_service->trcx_build(
          area_name         = area_name
          inst_name         = inst_name
          cx                = l_cx
        ).
    ENDTRY.

  ENDIF.

endmethod.


method CLASS_CONSTRUCTOR .

* TRACE { DO NOT REMOVE THIS LINE !
  _trace_active = abap_false.
  TRY.
      _trace_service =
        cl_shm_service=>trace_get_service( area_name ).
      IF NOT _trace_service IS INITIAL.
        _trace_active =
          cl_shm_service=>trace_is_variant_active(
            _trace_service->variant-def_name
          ).
      ENDIF.
    CATCH cx_root.
  ENDTRY.
* TRACE } DO NOT REMOVE THIS LINE !

endmethod.


method DETACH_AREA .

  DATA:
    l_client TYPE shm_client,
    l_client_supplied TYPE abap_bool VALUE abap_false.


* >
  rc = _detach_area( area_name        = area_name
                     client           = l_client
                     client_supplied  = l_client_supplied
                     client_dependent = _client_dependent
                     transactional    = _transactional
       ).
* <

  IF _trace_active = abap_true.
    IF _trace_service->variant-detach_area = abap_true.
      _trace_service->trin_detach_area(
        area_name = area_name
        client    = l_client
        rc        = rc
      ).
    ENDIF.
  ENDIF.

endmethod.


method FREE_AREA .

  DATA:
    l_client TYPE shm_client,
    l_client_supplied TYPE abap_bool VALUE abap_false.


* >
  rc = _free_area( area_name         = area_name
                   client            = l_client
                   client_supplied   = l_client_supplied
                   client_dependent  = _client_dependent
                   transactional     = _transactional
                   terminate_changer = terminate_changer ).
* <

  IF _trace_active = abap_true.
    IF _trace_service->variant-free_area = abap_true.
      _trace_service->trin_free_area(
      area_name         = area_name
      client            = l_client
      terminate_changer = terminate_changer
      rc                = rc
    ).
    ENDIF.
  ENDIF.

endmethod.


method FREE_INSTANCE .

  DATA:
    l_client TYPE shm_client,
    l_client_supplied TYPE abap_bool VALUE abap_false.


* >
  rc = _free_instance( area_name         = area_name
                       inst_name         = inst_name
                       client            = l_client
                       client_supplied   = l_client_supplied
                       client_dependent  = _client_dependent
                       transactional     = _transactional
                       terminate_changer = terminate_changer ).
* <

  IF _trace_active = abap_true.
    IF _trace_service->variant-free_instance = abap_true.
      _trace_service->trin_free_instance(
        area_name         = area_name
        inst_name         = inst_name
        client            = l_client
        terminate_changer = terminate_changer
        rc                = rc
      ).
    ENDIF.
  ENDIF.

endmethod.


method GET_GENERATOR_VERSION .
  generator_version = _version_.
endmethod.


method GET_INSTANCE_INFOS .

  DATA:
    l_client TYPE shm_client,
    l_client_supplied TYPE abap_bool VALUE abap_false.


* >
  infos = _get_instance_infos(
            area_name        = area_name
            client           = l_client
            client_supplied  = l_client_supplied
            client_dependent = _client_dependent
            transactional    = _transactional
          ).
* <

  IF _trace_active = abap_true.
    IF _trace_service->variant-get_instance_inf = abap_true.
      _trace_service->trin_get_instance_infos(
        area_name         = area_name
        client            = l_client
        infos             = infos
      ).
    ENDIF.
  ENDIF.

endmethod.


method GET_ROOT .

  DATA:
    l_cx        TYPE REF TO cx_root,
    l_area_name TYPE string,
    l_inst_name TYPE string,
    l_client    TYPE string.

  IF _trace_active = abap_false OR
  _trace_service->variant-get_root = abap_false.

*   >
    IF is_valid( ) = abap_false.
      l_area_name = me->area_name.
      l_inst_name = me->inst_name.
      l_client    = me->client.
      RAISE EXCEPTION TYPE cx_shm_already_detached
        EXPORTING
          area_name = l_area_name
          inst_name = l_inst_name
          client    = l_client.
    ENDIF.
    root = me->root.
*   <

  ELSE.

    TRY.

*       >
        IF is_valid( ) = abap_false.
          l_area_name = me->area_name.
          l_inst_name = me->inst_name.
          l_client    = me->client.
          RAISE EXCEPTION TYPE cx_shm_already_detached
            EXPORTING
              area_name = l_area_name
              inst_name = l_inst_name
              client    = l_client.
        ENDIF.
        root = me->root.
*       <

        _trace_service->trin_get_root(
          area_name = area_name
        ).

      CLEANUP INTO l_cx.
        _trace_service->trcx_get_root(
          area_name = area_name
          cx        = l_cx
        ).
    ENDTRY.

  ENDIF.

endmethod.


method INVALIDATE_AREA .

  DATA:
    l_client TYPE shm_client,
    l_client_supplied TYPE abap_bool VALUE abap_false.


* >
  rc = _invalidate_area( area_name         = area_name
                         client            = l_client
                         client_supplied   = l_client_supplied
                         client_dependent  = _client_dependent
                         transactional     = _transactional
                         terminate_changer = terminate_changer ).
* <

  IF _trace_active = abap_true.
    IF _trace_service->variant-invalidate_area = abap_true.
      _trace_service->trin_invalidate_area(
        area_name         = area_name
        client            = l_client
        terminate_changer = terminate_changer
        rc                = rc
      ).
    ENDIF.
  ENDIF.

endmethod.


method INVALIDATE_INSTANCE .

  DATA:
    l_client TYPE shm_client,
    l_client_supplied TYPE abap_bool value abap_false.


* >
  rc = _invalidate_instance(
    area_name         = area_name
    inst_name         = inst_name
    client            = l_client
    client_supplied   = l_client_supplied
    client_dependent  = _client_dependent
    transactional     = _transactional
    terminate_changer = terminate_changer
  ).
* <

  IF _trace_active = abap_true.
    IF _trace_service->variant-invalidate_inst = abap_true.
      _trace_service->trin_invalidate_instance(
        area_name         = area_name
        inst_name         = inst_name
        client            = l_client
        terminate_changer = terminate_changer
        rc                = rc
      ).
    ENDIF.
  ENDIF.

endmethod.


method SET_ROOT .

  DATA:
    l_cx TYPE REF TO cx_root.

  IF _trace_active = abap_false OR
  _trace_service->variant-set_root = abap_false.

*   >
    _set_root( root ).
    me->root = root.
*   <

  ELSE.

    TRY.

*       >
        _set_root( root ).
        me->root = root.
*       <
        _trace_service->trin_set_root(
          area_name         = area_name
          inst_name         = inst_name
          root              = root
        ).

      CLEANUP INTO l_cx.
        _trace_service->trcx_set_root(
          area_name         = area_name
          inst_name         = inst_name
          root              = root
          cx                = l_cx
        ).
    ENDTRY.

  ENDIF.

endmethod.
ENDCLASS.
