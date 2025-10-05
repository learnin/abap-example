CLASS zcl_learnin_http01 DEFINITION
  PUBLIC
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_http_service_extension .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.

CLASS zcl_learnin_http01 IMPLEMENTATION.

  METHOD if_http_service_extension~handle_request.
    IF request->get_method(  ) <> `GET`.
      response->set_status( 405 ).
      RETURN.
    ENDIF.

    response->set_header_field( i_name = `Content-Disposition` i_value = `attachment; filename*=UTF-8''%E3%81%82%E3%81%84%E3%81%86.csv` ).
    response->set_content_type( `text/csv` ).

    FINAL(new_line) = cl_abap_char_utilities=>cr_lf.
    DATA(res_body) = |col1,col2{ new_line }|.
    res_body = |{ res_body }あいうえお,かきくけこ{ new_line }|.

    response->set_text( res_body ).
  ENDMETHOD.

ENDCLASS.

