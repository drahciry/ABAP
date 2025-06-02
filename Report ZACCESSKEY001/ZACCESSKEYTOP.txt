*&---------------------------------------------------------------------*
*& Include          ZACCESSKEYTOP
*&---------------------------------------------------------------------*

**********************************************************************
*                       TABELAS DE REFERÊNCIA
**********************************************************************

TABLES: j_1bnfdoc.

**********************************************************************
*                          TIPOS DE TABELA
**********************************************************************

TYPES: BEGIN OF ty_active,
         docnum  TYPE j_1bnfe_active-docnum,  " Nº documento
         docsta  TYPE j_1bnfe_active-docsta,  " Status do documento
         scssta  TYPE j_1bnfe_active-scssta,  " Status comunicação sistema
         conting TYPE j_1bnfe_active-conting, " Sob contingência
         cancel  TYPE j_1bnfe_active-cancel,  " Estornado
         code    TYPE j_1bnfe_active-code,    " Código status
         regio   TYPE j_1bnfe_active-regio,   " Região do emissor
         nfyear  TYPE j_1bnfe_active-nfyear,  " Ano da data do documento
         nfmonth TYPE j_1bnfe_active-nfmonth, " Mês da data do documento
         stcd1   TYPE j_1bnfe_active-stcd1,   " Nº CNPJ/CPF do emissor
         model   TYPE j_1bnfe_active-model,   " Modelo nota fiscal
         serie   TYPE j_1bnfe_active-serie,   " Séries
         nfnum9  TYPE j_1bnfe_active-nfnum9,  " Número de nota fiscal eletrônica
         docnum9 TYPE j_1bnfe_active-docnum9, " Nº aleatório na chave de acesso
         cdv     TYPE j_1bnfe_active-cdv,     " Dígito verificador p/chave acesso
         authcod TYPE j_1bnfe_active-authcod, " Nº do log
         credat  TYPE j_1bnfe_active-credat,  " Data de criação
       END OF ty_active,

       BEGIN OF ty_chave,
         regio   TYPE j_1bnfe_active-regio,   " Região do emissor
         nfyear  TYPE j_1bnfe_active-nfyear,  " Ano da data do documento
         nfmonth TYPE j_1bnfe_active-nfmonth, " Mês da data do documento
         stcd1   TYPE j_1bnfe_active-stcd1,   " Nº CNPJ/CPF do emissor
         model   TYPE j_1bnfe_active-model,   " Modelo nota fiscal
         serie   TYPE j_1bnfe_active-serie,   " Séries
         nfnum9  TYPE j_1bnfe_active-nfnum9,  " Número de nota fiscal eletrônica
         docnum9 TYPE j_1bnfe_active-docnum9, " Nº aleatório na chave de acesso
         cdv     TYPE j_1bnfe_active-cdv,     " Dígito verificador p/chave acesso
       END OF ty_chave,

       BEGIN OF ty_key,
         keyaccs TYPE char44,
       END OF ty_key.

TYPES: BEGIN OF ty_return.
         INCLUDE TYPE ty_active.
         INCLUDE TYPE ty_key.
TYPES: END OF ty_return.

**********************************************************************
*                    TABELAS INTERNAS E WORK-AREAS
**********************************************************************

DATA: gt_chave    TYPE TABLE OF            ty_chave,
      gw_chave    TYPE                     ty_chave,
      gt_active   TYPE TABLE OF           ty_active,
      gt_return   TYPE TABLE OF           ty_return,
      gw_return   TYPE                    ty_return,
      gt_fieldcat TYPE          slis_t_fieldcat_alv,
      gw_fieldcat TYPE            slis_fieldcat_alv,
      gw_layout   TYPE              slis_layout_alv,
      gt_header   TYPE            slis_t_listheader,
      gw_header   TYPE              slis_listheader.

**********************************************************************
*                         VARIÁVEIS GLOBAIS
**********************************************************************

DATA: gv_keyac TYPE char44.

**********************************************************************
*                          TELA DE SELEÇÃO
**********************************************************************

SELECTION-SCREEN BEGIN OF BLOCK b01 WITH FRAME TITLE TEXT-t01.

  SELECT-OPTIONS: s_docnum FOR j_1bnfdoc-docnum,                 " Nº Documento
                  gw_keyac FOR gv_keyac NO INTERVALS OBLIGATORY. " Chave de acesso

SELECTION-SCREEN END OF BLOCK b01.