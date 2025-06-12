*&---------------------------------------------------------------------*
*& Include          ZCOCKPIT_RICTOP
*&---------------------------------------------------------------------*

TABLES: sscrfields.

DATA: lv_ucomm TYPE sy-ucomm.

SELECTION-SCREEN BEGIN OF BLOCK B01 WITH FRAME TITLE TEXT-T01.

  SELECTION-SCREEN SKIP 1.
  SELECTION-SCREEN PUSHBUTTON /1(30) btn1 USER-COMMAND btn01.
  SELECTION-SCREEN PUSHBUTTON 35(30) btn2 USER-COMMAND btn02.
  SELECTION-SCREEN SKIP 1.
  SELECTION-SCREEN PUSHBUTTON /1(30) btn3 USER-COMMAND btn03.

SELECTION-SCREEN END OF BLOCK B01.

INITIALIZATION.

  btn1 = TEXT-BT1.
  btn2 = TEXT-BT2.
  btn3 = TEXT-BT3.

AT SELECTION-SCREEN.

  CASE sy-ucomm.

    WHEN 'BTN01'.

      lv_ucomm         = 'BTN1'.
      sscrfields-ucomm = 'ONLI'.

    WHEN 'BTN02'.

      lv_ucomm         = 'BTN2'.
      sscrfields-ucomm = 'ONLI'.

    WHEN 'BTN03'.

      lv_ucomm         = 'BTN3'.
      sscrfields-ucomm = 'ONLI'.

  ENDCASE.