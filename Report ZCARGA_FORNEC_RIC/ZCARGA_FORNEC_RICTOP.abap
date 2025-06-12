*&---------------------------------------------------------------------*
*& Include          ZCARGA_FORNEC_RICTOP
*&---------------------------------------------------------------------*

TYPE-POOLS: icon.

**********************************************************************
*                       TABELAS DE REFERÊNCIA
**********************************************************************

TABLES: lfa1, ekko, sscrfields.

**********************************************************************
*                            ESTRUTURAS
**********************************************************************

TYPES: BEGIN OF ty_fornecedor,
         check TYPE boolean,    " Checkbox
         icone TYPE icon_d,     " Ícone
         inlog TYPE icon_d,     " Log de erro
         error TYPE boolean,    " Chave para controle de erro
         id    TYPE numeric4,   " ID
         lifnr TYPE lfa1-lifnr, " Fornecedor
         land1 TYPE lfa1-land1, " País
         name1 TYPE lfa1-name1, " Nome
         ort01 TYPE lfa1-ort01, " Local
         pstlz TYPE lfa1-pstlz, " Código postal
         regio TYPE lfa1-regio, " Região
         stras TYPE lfa1-stras, " Rua
         mcod1 TYPE lfa1-mcod1, " Nome
         mcod3 TYPE lfa1-mcod3, " Local
         anred TYPE lfa1-anred, " Forma de tratamento
         ktokk TYPE lfa1-ktokk, " Grupo de contas
         spras TYPE lfa1-spras, " Código de idioma
         telf1 TYPE lfa1-telf1, " Telefone 1
         email TYPE string,     " Email
         txjcd TYPE lfa1-txjcd, " Domicílio fiscal
         ekorg TYPE ekko-ekorg, " Organiz.compras
         waers TYPE ekko-waers, " Moeda
         zterm TYPE ekko-zterm, " Condições pgto.
       END OF ty_fornecedor,

       BEGIN OF ty_layout,
         colu1  TYPE string, " País
         colu2  TYPE string, " Nome
         colu3  TYPE string, " Local
         colu4  TYPE string, " Código postal
         colu5  TYPE string, " Região
         colu6  TYPE string, " Rua
         colu7  TYPE string, " Nome
         colu8  TYPE string, " Local
         colu9  TYPE string, " Forma de tratamento
         colu10 TYPE string, " Grupo de contas
         colu11 TYPE string, " Código de idioma
         colu12 TYPE string, " Telefone 1
         colu13 TYPE string, " Email
         colu14 TYPE string, " Domicílio fiscal
         colu15 TYPE string, " Organiz.compras
         colu16 TYPE string, " Moeda
         colu17 TYPE string, " Condições pgto.
       END OF ty_layout,

       BEGIN OF ty_log,
         id     TYPE numeric4, " ID
         msglog TYPE string,   " Mensagem de log de erro
       END OF ty_log,

       BEGIN OF ty_download,
         lifnr TYPE string, " Nº Fornecedor
         ernam TYPE string, " Criador
         ktokk TYPE string, " Grupo de contas
         zterm TYPE string, " Condições pgto.
       END OF ty_download.


TYPES: zst_t_bapiret2 TYPE STANDARD TABLE OF bapiret2.

**********************************************************************
*                         TABELAS INTERNAS
**********************************************************************

DATA: gt_file          TYPE TABLE OF              string,
      gt_layout        TYPE TABLE OF           ty_layout,
      gt_excel         TYPE TABLE OF      alsmex_tabline,
      gt_return        TYPE TABLE OF            bapiret2,
      gt_log           TYPE TABLE OF              ty_log,
      gt_log_alv       TYPE TABLE OF              ty_log,
      gt_download      TYPE TABLE OF         ty_download,
      gt_loglifnr      TYPE TABLE OF       zloglifnr_ric,
      gt_fieldcat      TYPE          slis_t_fieldcat_alv,
      gt_fieldcat_log  TYPE          slis_t_fieldcat_alv,
      gt_fieldcat_view TYPE          slis_t_fieldcat_alv,
      gt_header        TYPE            slis_t_listheader,
      gt_header_view   TYPE            slis_t_listheader,
      gt_fornecedor    TYPE TABLE OF       ty_fornecedor
                       WITH KEY id.

**********************************************************************
*                             WORK-AREAS
**********************************************************************

DATA: gw_layout      TYPE slis_layout_alv,
      gw_fornecedor  TYPE ty_fornecedor,
      gw_layout_log  TYPE slis_layout_alv,
      gw_layout_view TYPE slis_layout_alv.

**********************************************************************
*                                SHDB
**********************************************************************

DATA: gt_bdc     TYPE TABLE OF    bdcdata,
      gw_bdc     TYPE             bdcdata,
      opt_param  TYPE          ctu_params,
      gt_message TYPE TABLE OF bdcmsgcoll.

**********************************************************************
*                             VARIÁVEIS
**********************************************************************

DATA: lv_answer   TYPE c,
      lv_key      TYPE c,
      lv_id       TYPE numeric4,
      lv_msgty    TYPE c,
      lv_msglog   TYPE string,
      lv_filename TYPE string,
      lv_path     TYPE string,
      lv_fullpath TYPE string,
      lv_ucomm    TYPE sy-ucomm.

**********************************************************************
*                          TELA DE SELEÇÃO
**********************************************************************

SELECTION-SCREEN BEGIN OF BLOCK b01 WITH FRAME TITLE TEXT-t01.

  SELECTION-SCREEN SKIP 1.

  PARAMETERS: p_file TYPE rlgrap-filename.

  SELECTION-SCREEN SKIP 1.

  SELECTION-SCREEN BEGIN OF BLOCK b02 WITH FRAME TITLE TEXT-t02.

    PARAMETERS: p_txt  RADIOBUTTON GROUP gp01,
                p_csv  RADIOBUTTON GROUP gp01,
                p_xlsx RADIOBUTTON GROUP gp01.

  SELECTION-SCREEN END OF BLOCK b02.

  SELECTION-SCREEN SKIP 1.

  SELECTION-SCREEN BEGIN OF BLOCK  b03 WITH FRAME TITLE TEXT-t03.

    PARAMETERS: p_view AS CHECKBOX.

  SELECTION-SCREEN END OF BLOCK b03.

  SELECTION-SCREEN SKIP 1.

  SELECTION-SCREEN BEGIN OF BLOCK b04 WITH FRAME TITLE TEXT-t04.

    SELECTION-SCREEN PUSHBUTTON /1(30) btn1 USER-COMMAND btn01.

  SELECTION-SCREEN END OF BLOCK b04.

SELECTION-SCREEN END OF BLOCK b01.

INITIALIZATION.

  p_view = 'X'.
  btn1   = TEXT-bt1.

AT SELECTION-SCREEN.

  CASE sy-ucomm.
    WHEN 'BTN01'.
      lv_ucomm         = 'BTN1'.
      sscrfields-ucomm = 'ONLI'.
  ENDCASE.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_file.

  PERFORM zf_popup.