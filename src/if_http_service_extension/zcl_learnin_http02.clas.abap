CLASS zcl_learnin_http02 DEFINITION
  PUBLIC
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_http_service_extension .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.

CLASS zcl_learnin_http02 IMPLEMENTATION.

  METHOD if_http_service_extension~handle_request.
    IF request->get_method(  ) <> `GET`.
      response->set_status( 405 ).
      RETURN.
    ENDIF.

    response->set_header_field( i_name = `Content-Disposition` i_value = `attachment; filename*=UTF-8''%E3%81%82%E3%81%84%E3%81%86.pdf` ).
    response->set_content_type( `application/pdf` ).

    TRY.
        DATA(http_client) = cl_web_http_client_manager=>create_by_http_destination( i_destination = cl_http_destination_provider=>create_by_url( i_url = `https://www.pref.aichi.jp/kenmin/shohiseikatsu/education/pdf/student_guide.pdf` ) ).
        DATA(get) = http_client->execute( if_web_http_client=>get ).
        DATA(status) = get->get_status( ).
        IF status-code <> 200.
          response->set_status( status-code ).
          RETURN.
        ENDIF.
        response->set_binary( get->get_binary( ) ).
      CATCH cx_root INTO DATA(error).
        response->set_status( 500 ).
    ENDTRY.
  ENDMETHOD.
ENDCLASS.
