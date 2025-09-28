CLASS ltc_test DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.
    METHODS strlen_cp FOR TESTING.
    METHODS substring_cp FOR TESTING.
ENDCLASS.

CLASS ltc_test IMPLEMENTATION.
  METHOD strlen_cp.
    FINAL(actual) = zcl_string_util=>strlen_cp( val = `🍣𠮷野家` ).
    cl_abap_unit_assert=>assert_equals( act = actual exp = 4 ).
  ENDMETHOD.

  METHOD substring_cp.
    FINAL(actual) = zcl_string_util=>substring_cp( val = `🍣𠮷野家` off = 1 len = 2 ).
    cl_abap_unit_assert=>assert_equals( act = actual exp = `𠮷野` ).
  ENDMETHOD.

ENDCLASS.

