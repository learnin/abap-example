CLASS zlrap100_cl_travel_q DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_rap_query_provider.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zlrap100_cl_travel_q IMPLEMENTATION.
  METHOD if_rap_query_provider~select.
    CASE io_request->get_entity_id( ).
      WHEN 'ZLRAP100_R_TRAVELCE'.
        DATA(lv_sql_filter) = io_request->get_filter( )->get_as_sql_string( ).

*        AUTHORITY-CHECK OBJECT 'XXX'
*            ID 'CARRID' DUMMY
*            ID 'ACTVT'  DUMMY.
        IF sy-subrc <> 0.
            IF io_request->is_data_requested( ).
              io_request->get_paging( )->get_offset( ).
              DATA auth_err_res_tab TYPE STANDARD TABLE OF ZLRAP100_R_TRAVELCE.
              io_response->set_data( auth_err_res_tab ).
            ENDIF.
            IF io_request->is_total_numb_of_rec_requested( ).
                io_response->set_total_number_of_records( 0 ).
            ENDIF.
            RETURN.
        ENDIF.

        IF io_request->is_data_requested( ).
          DATA(lv_offset) = io_request->get_paging( )->get_offset( ).
          DATA(lv_page_size) = io_request->get_paging( )->get_page_size( ).
          DATA(lv_max_rows) = COND #( WHEN lv_page_size = if_rap_query_paging=>page_size_unlimited
                                      THEN 0 ELSE lv_page_size ).

          SELECT '1' as travel_id, '2' as travel_status
          FROM /dmo/travel
*          WHERE (lv_sql_filter)
          ORDER BY ('primary key')
          INTO TABLE @DATA(lt_travel_resp)
          OFFSET @lv_offset UP TO @lv_max_rows ROWS.
*         UP TO 1 ROWS.
          io_response->set_data( lt_travel_resp ).
        ENDIF.
        IF io_request->is_total_numb_of_rec_requested( ).
          SELECT COUNT( * )
          FROM /dmo/travel
*          WHERE (lv_sql_filter)
          INTO @DATA(lt_travel_count).
          io_response->set_total_number_of_records( lt_travel_count ).
        ENDIF.
    ENDCASE.
  ENDMETHOD.

ENDCLASS.

