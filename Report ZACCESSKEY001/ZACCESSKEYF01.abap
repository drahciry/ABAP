*&---------------------------------------------------------------------*
*& Include          ZACCESSKEYF01
*&---------------------------------------------------------------------*

**********************************************************************
*                    FATIAMENTO DA CHAVE DE ACESSO
**********************************************************************

FORM zf_fatia_chave.

  LOOP AT gw_keyac[] INTO DATA(gw_aux).

    gw_chave-regio   = gw_aux-low+0(2).
    gw_chave-nfyear  = gw_aux-low+2(2).
    gw_chave-nfmonth = gw_aux-low+4(2).
    gw_chave-stcd1   = gw_aux-low+6(14).
    gw_chave-model   = gw_aux-low+20(2).
    gw_chave-serie   = gw_aux-low+22(3).
    gw_chave-nfnum9  = gw_aux-low+25(9).
    gw_chave-docnum9 = gw_aux-low+34(9).
    gw_chave-cdv     = gw_aux-low+43(1).

    APPEND gw_chave TO gt_chave.

    CLEAR: gw_aux, gw_chave.

  ENDLOOP.

ENDFORM.

**********************************************************************
*                          SELECT DINÂMICO
**********************************************************************

FORM zf_select_dinam CHANGING ch_query.

  IF s_docnum[] IS INITIAL.

    CONCATENATE     'regio   EQ gt_chave-regio'
                'AND nfyear  EQ gt_chave-nfyear'
                'AND nfmonth EQ gt_chave-nfmonth'
                'AND stcd1   EQ gt_chave-stcd1'
                'AND model   EQ gt_chave-model'
                'AND serie   EQ gt_chave-serie'
                'AND nfnum9  EQ gt_chave-nfnum9'
                'AND docnum9 EQ gt_chave-docnum9'
                'AND cdv     EQ gt_chave-cdv'
    INTO ch_query SEPARATED BY space.

  ELSE.

    CONCATENATE      'docnum IN s_docnum[]'
                'AND regio   EQ gt_chave-REGIO'
                'AND nfyear  EQ gt_chave-NFYEAR'
                'AND nfmonth EQ gt_chave-NFMONTH'
                'AND stcd1   EQ gt_chave-STCD1'
                'AND model   EQ gt_chave-MODEL'
                'AND serie   EQ gt_chave-SERIE'
                'AND nfnum9  EQ gt_chave-NFNUM9'
                'AND docnum9 EQ gt_chave-DOCNUM9'
                'AND cdv     EQ gt_chave-CDV'
    INTO ch_query SEPARATED BY space.

  ENDIF.

ENDFORM.

**********************************************************************
*                           SELECIONA DADOS
**********************************************************************

FORM zf_seleciona_dados.

  DATA: lv_query TYPE string.

  PERFORM zf_select_dinam CHANGING lv_query.

  SELECT docnum  " Nº documento
         docsta  " Status do documento
         scssta  " Status comunicação sistema
         conting " Sob contingência
         cancel  " Estornado
         code    " Código status
         regio   " Região do emissor
         nfyear  " Ano da data do documento
         nfmonth " Mês da data do documento
         stcd1   " Nº CNPJ/CPF do emissor
         model   " Modelo nota fiscal
         serie   " Séries
         nfnum9  " Número de nota fiscal eletrônica
         docnum9 " Nº aleatório na chave de acesso
         cdv     " Dígito verificador p/chave acesso
         authcod " Nº do log
         credat  " Data de criação
  FROM j_1bnfe_active
  INTO TABLE gt_active
  FOR ALL ENTRIES IN gt_chave
  WHERE (lv_query).

ENDFORM.

**********************************************************************
*                  CONSTRUÇÃO DA TABELA DE SAÍDA
**********************************************************************

FORM zf_build_return.

  DATA: lv_key TYPE char44.

  LOOP AT gt_active INTO DATA(gw_active).

    CONCATENATE gw_active-regio
                gw_active-nfyear
                gw_active-nfmonth
                gw_active-stcd1
                gw_active-model
                gw_active-serie
                gw_active-nfnum9
                gw_active-docnum9
                gw_active-cdv
                gw_active-docnum
    INTO lv_key.

    gw_return-docnum  = gw_active-docnum.
    gw_return-docsta  = gw_active-docsta.
    gw_return-scssta  = gw_active-scssta.
    gw_return-conting = gw_active-conting.
    gw_return-cancel  = gw_active-cancel.
    gw_return-keyaccs = lv_key.

    APPEND gw_return TO gt_return.

    CLEAR gw_return.

  ENDLOOP.

ENDFORM.

**********************************************************************
*                          CHAMADA DO ALV
**********************************************************************

FORM zf_display_alv.

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      i_callback_program       = sy-repid
      i_callback_pf_status_set = 'PF_STATUS'
*     I_CALLBACK_USER_COMMAND  = ' '
      I_CALLBACK_TOP_OF_PAGE   = 'TOP_OF_PAGE'
      i_grid_title             = 'Notas Fiscais Encontradas'
*     I_GRID_SETTINGS          =
      is_layout                = gw_layout
      it_fieldcat              = gt_fieldcat
    TABLES
      t_outtab                 = gt_return
    EXCEPTIONS
      program_error            = 1
      OTHERS                   = 2.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
    WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

ENDFORM.

**********************************************************************
*                            TOP-OF-PAGE
**********************************************************************

FORM top_of_page.

  CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
    EXPORTING
      it_list_commentary = gt_header
      I_LOGO                   = 'LOGO_GEO'.
*     I_END_OF_LIST_GRID       =
*     I_ALV_FORM               =

ENDFORM.

FORM zf_build_header.

  gw_header-typ  = 'H'.
  gw_header-key  = 'Relatório de Notas Fiscais'.
  gw_header-info = 'Relatório de Notas Fiscais'.

  APPEND gw_header TO gt_header.

  CLEAR gw_header.

  gw_header-typ  = 'A'.

  APPEND gw_header TO gt_header.

  CLEAR gw_header.

ENDFORM.

**********************************************************************
*                             PF-STATUS
**********************************************************************

FORM pf_status USING rkkblo TYPE kkblo_t_extab.

  SET PF-STATUS 'STATUS'.

ENDFORM.

**********************************************************************
*                         CHAMADA DO LAYOUT
**********************************************************************

FORM zf_call_layout.

  gw_layout-zebra             = abap_true.
  gw_layout-window_titlebar   = 'Relatório de Notas Fiscais'.

ENDFORM.

**********************************************************************
*                       CHAMADA DO FIELDCAT
**********************************************************************

FORM zf_call_fieldcat.

  DATA: lv_pos TYPE i.

  PERFORM: zf_build_fieldcat USING lv_pos 'docnum'  'gt_return' 'X' 'C' 'C300' '14' 'Nº documento'               'Nº documento'     'Nº Doc.'    'X' CHANGING lv_pos,
           zf_build_fieldcat USING lv_pos 'docsta'  'gt_return' ' ' 'C' 'C300' '14' 'Status do documento'        'Status Doc.'      'Stat.doc.'  ' ' CHANGING lv_pos,
           zf_build_fieldcat USING lv_pos 'scssta'  'gt_return' ' ' 'C' 'C300' '14' 'Status comunicação sistema' 'St.comun.sistema' 'StComunSis' ' ' CHANGING lv_pos,
           zf_build_fieldcat USING lv_pos 'conting' 'gt_return' ' ' 'C' 'C300' '14' 'Sob contingência'           'Lançado cont.'    'Conting.'   ' ' CHANGING lv_pos,
           zf_build_fieldcat USING lv_pos 'cancel'  'gt_return' ' ' 'C' 'C300' '14' 'Estornado'                  'Estornado'        'Estornado'  ' ' CHANGING lv_pos,
           zf_build_fieldcat USING lv_pos 'keyaccs' 'gt_return' ' ' 'C' 'C300' '46' 'Chave de Acesso'            'Chave Acesso'     'Chave Ace.' ' ' CHANGING lv_pos.

ENDFORM.

**********************************************************************
*                      CONSTRUÇÃO DO FIELDCAT
**********************************************************************

FORM zf_build_fieldcat USING p_col_pos
                             p_fieldname
                             p_tabname
                             p_key
                             p_just
                             p_emphasize
                             p_outputlen
                             p_seltext_l
                             p_seltext_m
                             p_seltext_s
                             p_hotspot
                       CHANGING ch_col_pos.

  ch_col_pos            = p_col_pos + 1.
  gw_fieldcat-col_pos   = p_col_pos.
  gw_fieldcat-fieldname = p_fieldname.
  gw_fieldcat-tabname   = p_tabname.
  gw_fieldcat-key       = p_key.
  gw_fieldcat-just      = p_just.
  gw_fieldcat-emphasize = p_emphasize.
  gw_fieldcat-outputlen = p_outputlen.
  gw_fieldcat-seltext_l = p_seltext_l.
  gw_fieldcat-seltext_m = p_seltext_m.
  gw_fieldcat-seltext_s = p_seltext_s.
  gw_fieldcat-hotspot   = p_hotspot.

  APPEND gw_fieldcat TO gt_fieldcat.

  CLEAR gw_fieldcat.

ENDFORM.