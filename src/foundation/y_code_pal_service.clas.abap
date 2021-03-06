CLASS y_code_pal_service DEFINITION PUBLIC CREATE PUBLIC.
  PUBLIC SECTION.
    INTERFACES if_http_extension.
    TYPES: BEGIN OF versions,
             code_pal_for_abap TYPE string,
             sap_basis TYPE string,
             abapGit TYPE string,
           END OF versions.
  PROTECTED SECTION.
    METHODS raise_bad_request.
    METHODS raise_method_not_allowed.
    METHODS raise_internal_server_error.
    METHODS raise_forbidden.
    METHODS convert_json_to_structure IMPORTING json TYPE string
                                      RETURNING value(result) TYPE y_if_profile_manager=>file
                                      RAISING cx_abap_invalid_value.
    METHODS execute_import_profile.
    METHODS execute_get_versions.
    METHODS get_basis_version RETURNING VALUE(result) TYPE string.
  PRIVATE SECTION.
    DATA request TYPE REF TO if_http_request.
    DATA response TYPE ref to if_http_response.
ENDCLASS.


CLASS y_code_pal_service IMPLEMENTATION.

  METHOD if_http_extension~handle_request.
    request = server->request.
    response = server->response.

    CASE request->get_header_field( 'action' ).
      WHEN 'import_profile'.
        execute_import_profile( ).
      WHEN 'get_versions'.
        execute_get_versions( ).
      WHEN OTHERS.
        raise_bad_request( ).
        RETURN.
    ENDCASE.
  ENDMETHOD.

  METHOD execute_import_profile.
    IF request->get_method( ) <> 'POST'.
      raise_method_not_allowed( ).
      RETURN.
    ENDIF.

    IF request->get_content_type( ) <> 'application/json'.
      raise_bad_request( ).
      RETURN.
    ENDIF.

    DATA(json) = request->get_cdata( ).

    TRY.
        DATA(structure) = convert_json_to_structure( json ).
      CATCH cx_abap_invalid_value.
        raise_bad_request( ).
        RETURN.
    ENDTRY.

    DATA(profile_manager) = y_profile_manager=>create( ).

    TRY.
        profile_manager->import_profile( structure ).
      CATCH ycx_failed_to_add_a_line
            ycx_time_overlap.
        raise_internal_server_error( ).
        RETURN.
      CATCH ycx_no_delegation_rights.
        raise_forbidden( ).
        RETURN.
    ENDTRY.
  ENDMETHOD.

  METHOD execute_get_versions.
    IF request->get_method( ) <> 'GET'.
      raise_method_not_allowed( ).
      RETURN.
    ENDIF.

    DATA(structure) = VALUE versions( code_pal_for_abap = y_code_pal_version=>abap
                                      sap_basis = get_basis_version( )
                                      abapGit = zif_abapgit_version=>gc_abap_version ).

    DATA(json) = /ui2/cl_json=>serialize( structure ).

    response->set_content_type( 'application/json' ).
    response->set_cdata( json ).
  ENDMETHOD.

  METHOD raise_bad_request.
    response->set_status( code   = '400'
                          reason = 'Bad Request' ).
  ENDMETHOD.

  METHOD raise_method_not_allowed.
    response->set_status( code   = '405'
                          reason = 'Method Not Allowed' ).
  ENDMETHOD.

  METHOD raise_forbidden.
    response->set_status( code   = '403'
                          reason = 'Forbidden' ).
  ENDMETHOD.

  METHOD raise_internal_server_error.
    response->set_status( code   = '500'
                          reason = 'Internal Server Error' ).
  ENDMETHOD.

  METHOD convert_json_to_structure.
    /ui2/cl_json=>deserialize( EXPORTING json = json
                               CHANGING data = result ).

    IF result IS INITIAL.
      RAISE EXCEPTION TYPE cx_abap_invalid_value.
    ENDIF.
  ENDMETHOD.

  METHOD get_basis_version.
    SELECT SINGLE * FROM cvers INTO @DATA(cver) WHERE component = 'SAP_BASIS'.
    result = |{ cver-release }-{ cver-extrelease }|.
  ENDMETHOD.

ENDCLASS.
