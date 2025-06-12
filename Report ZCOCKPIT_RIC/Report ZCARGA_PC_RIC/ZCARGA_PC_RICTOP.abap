*&---------------------------------------------------------------------*
*& Include          ZCARGA_PC_RICTOP
*&---------------------------------------------------------------------*

TYPE-POOLS: icon.

**********************************************************************
*                        TABELAS DE REFERÊNCIA
**********************************************************************

TABLES: sscrfields, ekko, ekpo, zloglifnr_ric, cdhdr, cdpos.

**********************************************************************
*                     ESTRUTURAS E TIPOS DE TABELA
**********************************************************************

" Estrutura do pedido de compras

TYPES: BEGIN OF ty_order,
         ebeln TYPE ekko-ebeln, " Nº documento de compra
         bukrs TYPE ekko-bukrs, " Empresa
         bstyp TYPE ekko-bstyp, " Categoria do documento de compras
         bsart TYPE ekko-bsart, " Tipo de documento de compras
         lifnr TYPE ekko-lifnr, " Nº conta do fornecedor
         ekorg TYPE ekko-ekorg, " Organização de compras
         ekgrp TYPE ekko-ekgrp, " Grupo de compradores
         waers TYPE ekko-waers, " Código da moeda
         itext TYPE string,     " Texto de item
         ebelp TYPE ekpo-ebelp, " Nº Item do documento de compra
         txz01 TYPE ekpo-txz01, " Texto breve
         matnr TYPE ekpo-matnr, " Nº do material
         werks TYPE ekpo-werks, " Centro
         menge TYPE ekpo-menge, " Quantidade do pedido
         meins TYPE ekpo-meins, " Unidade de medida do pedido
         netpr TYPE ekpo-netpr, " Preço líquido no documento de compra na moeda do documento
         peinh TYPE ekpo-peinh, " Unidade preço
         netwr TYPE ekpo-netwr, " Valor líquido do pedido em moeda de pedido
         brtwr TYPE ekpo-brtwr, " Valor do pedido bruto em moeda de pedido
         ptext TYPE string,     " Texto de cabeçalho
         icone TYPE char4,      " Ícone
         inlog TYPE char4,      " Campo de log
         error TYPE boolean,    " Campo chave de erro
         color TYPE char4,      " Cor da linha
         check TYPE boolean,    " Campo de check do ALV
       END OF ty_order,

       " Estrutura de controle da posição da coluna

       BEGIN OF ty_poscol,
         poscol TYPE i,      " Posição da coluna
         colnam TYPE string, " Nome técnico da coluna
       END OF ty_poscol,

       BEGIN OF ty_cdhdr,
         objectid TYPE cdhdr-objectid,
         changenr TYPE cdhdr-changenr,
         username TYPE cdhdr-username,
         udate    TYPE cdhdr-udate,
         utime    TYPE cdhdr-utime,
       END OF ty_cdhdr,

       BEGIN OF ty_cdpos,
         objectid_p TYPE cdpos-objectid,
         changenr_p TYPE cdpos-changenr,
         tabname    TYPE cdpos-tabname,
         tabkey     TYPE cdpos-tabkey,
         chngind    TYPE cdpos-chngind,
         unit_old   TYPE cdpos-unit_old,
         unit_new   TYPE cdpos-unit_new,
         cuky_old   TYPE cdpos-cuky_old,
         cuky_new   TYPE cdpos-cuky_new,
         value_new  TYPE cdpos-value_new,
         value_old  TYPE cdpos-value_old,
       END OF ty_cdpos,

       BEGIN OF ty_comparison,
         objectid TYPE cdhdr-objectid,
       END OF ty_comparison.

" Estrutura da tabela de log

TYPES: BEGIN OF ty_bapiret3.
TYPES: lifnr TYPE lfa1-lifnr,
       ebeln TYPE ekko-ebeln,
       ebelp TYPE ekpo-ebelp.
       INCLUDE TYPE bapiret2.
TYPES: END OF ty_bapiret3.

" Estrutura da tabela de view de campos editados

TYPES: BEGIN OF ty_output.
         INCLUDE TYPE ty_cdhdr.
         INCLUDE TYPE ty_cdpos.
TYPES: END OF ty_output.

" Tipos de tabela

TYPES: zst_t_bapiret2 TYPE STANDARD TABLE OF bapiret2.

TYPES: zst_t_tline TYPE STANDARD TABLE OF tline.

**********************************************************************
*                          TABELAS INTERNAS
**********************************************************************

DATA: gt_excel           TYPE TABLE OF       alsmex_tabline,
      gt_filetable       TYPE                     filetable,
      gt_order           TYPE TABLE OF             ty_order,
      gt_poscol          TYPE TABLE OF            ty_poscol,
      gt_file            TYPE TABLE OF               string,
      gt_loglifnr        TYPE TABLE OF        zloglifnr_ric,
      gt_return          TYPE TABLE OF             bapiret2,
      gt_items           TYPE TABLE OF         bapimepoitem,
      gt_itemsx          TYPE TABLE OF        bapimepoitemx,
      gt_lines           TYPE TABLE OF                tline,
      gt_comparison      TYPE TABLE OF        ty_comparison,
      gt_cdhdr           TYPE TABLE OF             ty_cdhdr,
      gt_cdpos           TYPE TABLE OF             ty_cdpos,
      gt_output          TYPE TABLE OF            ty_output,
      gt_fieldcat        TYPE           slis_t_fieldcat_alv,
      gt_fieldcat_log    TYPE           slis_t_fieldcat_alv,
      gt_fieldcat_output TYPE           slis_t_fieldcat_alv,
      gt_header          TYPE             slis_t_listheader,
      gt_log             TYPE TABLE OF          ty_bapiret3,
      gt_log_alv         TYPE TABLE OF          ty_bapiret3.

**********************************************************************
*                           FIELD-SYMBOLS
**********************************************************************

FIELD-SYMBOLS: <fs_order> TYPE ty_order.

**********************************************************************
*                             WORK-AREAS
**********************************************************************

DATA: gw_headerbapi    TYPE  bapimepoheader,
      gw_headerbapix   TYPE bapimepoheaderx,
      gw_headertext    TYPE           thead,
      gw_layout        TYPE slis_layout_alv,
      gw_layout_log    TYPE slis_layout_alv,
      gw_layout_output TYPE slis_layout_alv.

**********************************************************************
*                          VARIÁVEIS GLOBAIS
**********************************************************************

DATA: lv_rc        TYPE        i,
      lv_idlif     TYPE        i,
      lv_ebeln     TYPE    ebeln,
      lv_key       TYPE  boolean,
      lv_commit    TYPE  boolean,
      lv_psave     TYPE  boolean,
      lv_find      TYPE  boolean,
      lv_ucomm     TYPE sy-ucomm,
      lv_convert   TYPE  boolean,
      lv_menge_str TYPE   string,
      lv_netpr_str TYPE   string,
      lv_peinh_str TYPE   string,
      lv_netwr_str TYPE   string,
      lv_brtwr_str TYPE   string.

**********************************************************************
*                           TELA DE SELEÇÃO
**********************************************************************

SELECTION-SCREEN BEGIN OF BLOCK b01 WITH FRAME TITLE TEXT-t01.

  " Caminho do arquivo

  PARAMETERS: p_file TYPE string.

  SELECTION-SCREEN SKIP 1.

  " Opção de criação ou edição de pedido de compra

  SELECTION-SCREEN BEGIN OF BLOCK b04 WITH FRAME TITLE TEXT-t05.

    PARAMETERS: p_create RADIOBUTTON GROUP gp02 USER-COMMAND radgrp1,
                p_edit   RADIOBUTTON GROUP gp02.

    SELECTION-SCREEN SKIP 1.

    " Extensão do arquivo de criação

    SELECTION-SCREEN BEGIN OF BLOCK b02 WITH FRAME TITLE TEXT-t02.

      PARAMETERS: p_txt RADIOBUTTON GROUP gp01 MODIF ID t1,
                  p_csv RADIOBUTTON GROUP gp01 MODIF ID t1,
                  p_xls RADIOBUTTON GROUP gp01 MODIF ID t1.

    SELECTION-SCREEN END OF BLOCK b02.

    " Botão de download do layout

    SELECTION-SCREEN BEGIN OF BLOCK b03 WITH FRAME TITLE TEXT-t03.

      SELECTION-SCREEN PUSHBUTTON /1(30) btn1 USER-COMMAND btn01 MODIF ID t1.

    SELECTION-SCREEN END OF BLOCK b03.

    " Extensão do arquivo de edição

    SELECTION-SCREEN BEGIN OF BLOCK b05 WITH FRAME TITLE TEXT-t02.

      PARAMETERS: p_csved RADIOBUTTON GROUP gp03 MODIF ID t2,
                  p_xlsed RADIOBUTTON GROUP gp03 MODIF ID t2.

    SELECTION-SCREEN END OF BLOCK b05.

    " Botão de download de layout

    SELECTION-SCREEN BEGIN OF BLOCK b06 WITH FRAME TITLE TEXT-t04.

      SELECTION-SCREEN PUSHBUTTON /1(30) btn2 USER-COMMAND btn02 MODIF ID t2.

    SELECTION-SCREEN END OF BLOCK b06.

  SELECTION-SCREEN END OF BLOCK b04.

SELECTION-SCREEN END OF BLOCK b01.

" Inicializa valores para os parâmetros

INITIALIZATION.

  p_create = 'X'.
  btn1     = TEXT-bt1.
  btn2     = TEXT-bt1.

  " Oculta opções de forma dinâmica de acordo com opção selecionada

AT SELECTION-SCREEN OUTPUT.

  PERFORM zf_at_selection_screen_output.

  " Captura cliques do usuário na tela de seleção

AT SELECTION-SCREEN.

  PERFORM zf_at_selection_screen.

  " Atualiza o campo do caminho do arquivo de forma dinâmica

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_file.

  PERFORM zf_popup.