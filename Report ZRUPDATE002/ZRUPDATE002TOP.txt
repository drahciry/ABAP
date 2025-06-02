*&---------------------------------------------------------------------*
*& Include          ZRUPDATE002TOP
*&---------------------------------------------------------------------*

TYPE-POOLS: icon.

**********************************************************************
*                       TABELAS DE REFERÊNCIA
**********************************************************************

TABLES: sscrfields, nach.

**********************************************************************
*                         TIPOS DE TABELA
**********************************************************************

TYPES: BEGIN OF ty_new,
         icone     TYPE char4,
         log       TYPE char4,
         ldest_new TYPE char4,
       END OF ty_new,

       BEGIN OF ty_log,
         knumh  TYPE nach-knumh,
         msglog TYPE string,
       END OF ty_log.

TYPES: BEGIN OF ty_saida.
         INCLUDE TYPE nach.
         INCLUDE TYPE ty_new.
TYPES: END OF ty_saida.

**********************************************************************
*                          TABELAS INTERNAS
**********************************************************************

DATA: gt_nach_old TYPE TABLE OF nach,
      gt_nach     TYPE TABLE OF ty_saida,
      gt_log      TYPE TABLE OF ty_log,
      gt_log_alv  TYPE TABLE OF ty_log.

**********************************************************************
*                               ALV
**********************************************************************

DATA: gt_fieldcat     TYPE slis_t_fieldcat_alv,
      gt_fieldcat_log TYPE slis_t_fieldcat_alv,
      gt_header       TYPE slis_t_listheader,
      gw_layout       TYPE slis_layout_alv,
      gw_layout_log   TYPE slis_layout_alv.

**********************************************************************
*                         VARIÁVEIS GLOBAIS
**********************************************************************

DATA: lv_ucomm  TYPE sy-ucomm,
      lv_answer TYPE c,
      lv_qtdreg TYPE i.

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