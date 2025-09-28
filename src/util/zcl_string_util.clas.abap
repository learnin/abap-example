CLASS zcl_string_util DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    "! val の文字数（コードポイント数）を返す（サロゲートペア文字も1文字と数える）
    "! @parameter val | 対象文字列
    "! @parameter result | 文字数
    CLASS-METHODS strlen_cp
      IMPORTING val           TYPE string
      RETURNING VALUE(result) TYPE i.

    "! val の off 位置から len 文字文の部分文字列を返す
    "! 例. substring_cp( val = `🍣𠮷野家` off = 1 len = 2 ) "𠮷野
    "! @parameter val | 対象文字列
    "! @parameter off | 部分文字列の開始位置（0始まり）
    "! @parameter len | 対象文字列の文字数
    "! @parameter result | 部分文字列
    CLASS-METHODS substring_cp
      IMPORTING
                val           TYPE string
                off           TYPE i
                len           TYPE i
      RETURNING VALUE(result) TYPE string.

  PROTECTED SECTION.
  PRIVATE SECTION.
    CLASS-METHODS to_utf32_xstring
      IMPORTING val           TYPE string
      RETURNING VALUE(result) TYPE xstring.

    CLASS-METHODS from_utf32_xstring
      IMPORTING val           TYPE xstring
      RETURNING VALUE(result) TYPE string.
ENDCLASS.

CLASS zcl_string_util IMPLEMENTATION.
  METHOD to_utf32_xstring.
    result = cl_abap_conv_codepage=>create_out( codepage = 'UTF-32BE' )->convert( val ).
  ENDMETHOD.

  METHOD from_utf32_xstring.
    result = cl_abap_conv_codepage=>create_in( codepage = 'UTF-32BE' )->convert( val ).
  ENDMETHOD.

  METHOD strlen_cp.
    result = xstrlen( to_utf32_xstring( val ) ) / 4.
  ENDMETHOD.

  METHOD substring_cp.
    DATA(target_xstr) = to_utf32_xstring( val ).

    FINAL(offset) = off * 4.
    FINAL(length) = len * 4.
    target_xstr = target_xstr+offset(length).

    result = from_utf32_xstring( target_xstr ).
  ENDMETHOD.

ENDCLASS.

