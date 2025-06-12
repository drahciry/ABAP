*&---------------------------------------------------------------------*
*& Include          ZUPDATERIC_TOP
*&---------------------------------------------------------------------*

**********************************************************************
*                       TABELAS DE REFERÊNCIA
**********************************************************************

TABLES: sscrfields, j_1bb2.

**********************************************************************
*                         TIPOS DE TABELA
**********************************************************************

TYPES: BEGIN OF ty_new,
         icone          TYPE char4,
         log            TYPE string,
         prnter_new     TYPE char4,
         prntercont_new TYPE char4,
       END OF ty_new.

TYPES: BEGIN OF ty_saida.
         INCLUDE TYPE j_1bb2.
         INCLUDE TYPE ty_new.
TYPES: END OF ty_saida.

**********************************************************************
*                          TABELAS INTERNAS
**********************************************************************

DATA: gt_aux       TYPE TABLE OF j_1bb2,
      gt_j1bb2_old TYPE TABLE OF j_1bb2,
      gt_j1bb2     TYPE TABLE OF ty_saida.

**********************************************************************
*                               ALV
**********************************************************************

DATA: gt_fieldcat TYPE slis_t_fieldcat_alv,
      gt_header   TYPE slis_t_listheader,
      gw_layout   TYPE slis_layout_alv.

**********************************************************************
*                         VARIÁVEIS GLOBAIS
**********************************************************************

DATA: lv_ucomm  TYPE sy-ucomm,
      lv_answer TYPE c.

**********************************************************************
*                         CONSTANTES GLOBAIS
**********************************************************************

CONSTANTS: c_locl TYPE char4 VALUE 'LOCL'.

**********************************************************************
*                          TELA DE SELEÇÃO
**********************************************************************

SELECTION-SCREEN BEGIN OF BLOCK b01 WITH FRAME TITLE TEXT-t01.
  SELECTION-SCREEN PUSHBUTTON /1(30) btn1 USER-COMMAND btn01.
SELECTION-SCREEN END OF BLOCK b01.

INITIALIZATION.
  btn1 = TEXT-bt1.

AT SELECTION-SCREEN.
  CASE sy-ucomm.
    WHEN 'BTN01'.
      lv_ucomm         = 'BTN1'.
      sscrfields-ucomm = 'ONLI'.
  ENDCASE.