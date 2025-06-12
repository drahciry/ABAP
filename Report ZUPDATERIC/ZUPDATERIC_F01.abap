*&---------------------------------------------------------------------*
*& Include          ZUPDATERIC_F01
*&---------------------------------------------------------------------*

**********************************************************************
*                       POPUP DE CONFIRMAÇÃO
**********************************************************************

FORM zf_popup.

  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      titlebar       = 'Confirmação'
      text_question  = 'Todos os dados serão atualizados. Deseja continuar?'
      text_button_1  = 'Sim'
      icon_button_1  = 'ICON_OKAY'
      text_button_2  = 'Não'
      icon_button_2  = 'ICON_CANCEL'
      default_button = '2'
    IMPORTING
      answer         = lv_answer
    EXCEPTIONS
      text_not_found = 1
      OTHERS         = 2.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
    WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

ENDFORM.

**********************************************************************
*                           UPDATE NA TABELA
**********************************************************************

FORM zf_update_dados.

  DATA: lv_key        TYPE c,
        lv_lines      TYPE i,
        lv_count      TYPE i,
        lv_percentage TYPE i,
        lv_text       TYPE string.

  SELECT *
  FROM j_1bb2
  INTO TABLE gt_j1bb2_old
  WHERE prnter     NE c_locl
     OR prntercont NE c_locl.

  UPDATE j_1bb2
     SET prnter     = c_locl
         prntercont = c_locl
   WHERE prnter     NE c_locl
      OR prntercont NE c_locl.

  SELECT *
  FROM j_1bb2
  INTO TABLE gt_aux.

  DESCRIBE TABLE gt_j1bb2_old LINES lv_lines.

  LOOP AT gt_j1bb2_old ASSIGNING FIELD-SYMBOL(<fs_j1bb2_old>).

    lv_count      = lv_count + 1.
    lv_percentage = ( lv_count / lv_lines ) * 100.
    CONCATENATE 'Atualizando empresa:' <fs_j1bb2_old>-bukrs INTO lv_text.

    PERFORM zf_progresso USING lv_percentage lv_text.

    APPEND INITIAL LINE TO gt_j1bb2 ASSIGNING FIELD-SYMBOL(<fs_j1bb2>).
    MOVE-CORRESPONDING <fs_j1bb2_old> TO <fs_j1bb2>.

    READ TABLE gt_aux ASSIGNING FIELD-SYMBOL(<fs_aux>) WITH KEY bukrs  = <fs_j1bb2_old>-bukrs
                                                                branch = <fs_j1bb2_old>-branch
                                                                form   = <fs_j1bb2_old>-form.
    IF sy-subrc EQ 0.
      IF <fs_j1bb2_old>-prnter EQ <fs_aux>-prnter AND <fs_j1bb2_old>-prntercont EQ <fs_aux>-prntercont.
        <fs_j1bb2>-icone = '@0A@'.
        <fs_j1bb2>-log   = TEXT-001.
      ELSE.
        <fs_j1bb2>-icone          = '@08@'.
        <fs_j1bb2>-prnter_new     = c_locl.
        <fs_j1bb2>-prntercont_new = c_locl.
        lv_key                    = abap_true.
      ENDIF.
    ENDIF.

  ENDLOOP.

  IF lv_key EQ abap_true.
    COMMIT WORK AND WAIT.
  ELSE.
    ROLLBACK WORK.
  ENDIF.

ENDFORM.

**********************************************************************
*                         STATUS DE PROGRESSO
**********************************************************************

FORM zf_progresso USING p_percentage p_text.

  CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
    EXPORTING
      percentage = p_percentage
      text       = p_text.

ENDFORM.

**********************************************************************
*                          CONSTRUÇÃO DO ALV
**********************************************************************

FORM zf_display_alv.

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      i_callback_program       = sy-repid
      i_callback_pf_status_set = 'PF_STATUS'
*     I_CALLBACK_TOP_OF_PAGE   = 'TOP_OF_PAGE'
      i_grid_title             = 'Empresas'
      is_layout                = gw_layout
      it_fieldcat              = gt_fieldcat
    TABLES
      t_outtab                 = gt_j1bb2
    EXCEPTIONS
      program_error            = 1
      OTHERS                   = 2.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
    WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

ENDFORM.

**********************************************************************
*                           TOP OF PAGE
**********************************************************************

FORM top_of_page.

  CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
    EXPORTING
      it_list_commentary = gt_header
      i_logo             = 'LOGO_GEO'.

ENDFORM.

**********************************************************************
*                           PF-STATUS
**********************************************************************

FORM pf_status USING rkkblo TYPE kkblo_t_extab.

  SET PF-STATUS 'STATUS'.

ENDFORM.

**********************************************************************
*                       CONSTRUÇÃO DA HEADER
**********************************************************************

FORM zf_build_header.

  APPEND INITIAL LINE TO gt_header ASSIGNING FIELD-SYMBOL(<fs_header>).
  IF sy-subrc EQ 0.
    <fs_header>-typ = 'A'.
  ENDIF.

ENDFORM.

**********************************************************************
*                       CONSTRUÇÃO DO LAYOUT
**********************************************************************

FORM zf_build_layout.

  gw_layout-zebra           = 'X'.
  gw_layout-window_titlebar = 'Dispositivos de saída atualizados'.

ENDFORM.

**********************************************************************
*                       CHAMADA DO FIELDCAT
**********************************************************************

FORM zf_call_fieldcat.

  DATA: lv_pos TYPE i.

  PERFORM: zf_build_fieldcat USING 'X' lv_pos 'icone'          'gt_j1bb2' 'X' 'C' 'C300' '8'  'Status'                        'Status'               'Status'         CHANGING lv_pos,
           zf_build_fieldcat USING ' ' lv_pos 'log'            'gt_j1bb2' ' ' 'C' 'C300' '8'  'Log'                           'Log'                  'Log'            CHANGING lv_pos,
           zf_build_fieldcat USING ' ' lv_pos 'bukrs'          'gt_j1bb2' ' ' 'C' 'C300' '15' 'Empresa'                       'Empresa'              'Empresa'        CHANGING lv_pos,
           zf_build_fieldcat USING ' ' lv_pos 'branch'         'gt_j1bb2' ' ' 'C' 'C300' '15' 'Local de negócios'             'Local de negócios'    'Loc.negócios'   CHANGING lv_pos,
           zf_build_fieldcat USING ' ' lv_pos 'form'           'gt_j1bb2' ' ' 'C' 'C300' '15' 'Formulário do documento'       'Formulário documento' 'Formulário'     CHANGING lv_pos,
           zf_build_fieldcat USING ' ' lv_pos 'subobj'         'gt_j1bb2' ' ' 'C' 'C300' '15' 'Grupo nºs NF'                  'Grupo nºs NF'         'Grupo'          CHANGING lv_pos,
           zf_build_fieldcat USING ' ' lv_pos 'totlih'         'gt_j1bb2' ' ' 'C' 'C300' '15' 'Linhas mensg.cabeç.'           'Linh.mens.cabç.'      'Mens.cabç.'     CHANGING lv_pos,
           zf_build_fieldcat USING ' ' lv_pos 'totlil'         'gt_j1bb2' ' ' 'C' 'C300' '15' 'Partidas individuais'          'Parts.indivs.'        'Part.indiv'     CHANGING lv_pos,
           zf_build_fieldcat USING ' ' lv_pos 'fatura'         'gt_j1bb2' ' ' 'C' 'C300' '15' 'Nota Fiscal Fatura'            'NF Fatura'            'Fatura'         CHANGING lv_pos,
           zf_build_fieldcat USING ' ' lv_pos 'series'         'gt_j1bb2' ' ' 'C' 'C300' '15' 'Séries'                        'Séries'               'Séries'         CHANGING lv_pos,
           zf_build_fieldcat USING ' ' lv_pos 'subser'         'gt_j1bb2' ' ' 'C' 'C300' '15' 'Subséries'                     'Subséries'            'Subséries'      CHANGING lv_pos,
           zf_build_fieldcat USING ' ' lv_pos 'numberrange'    'gt_j1bb2' ' ' 'C' 'C300' '15' 'Nº interv.num.'                'Nº interv.num.'       'Nº interv.num.' CHANGING lv_pos,
           zf_build_fieldcat USING ' ' lv_pos 'fieldname'      'gt_j1bb2' ' ' 'C' 'C300' '15' 'Chv.dinâmica config.impressão' 'Chv.dinâm.'           'ChvDinâm'       CHANGING lv_pos,
           zf_build_fieldcat USING ' ' lv_pos 'prnter'         'gt_j1bb2' ' ' 'C' 'C300' '15' 'Impressora - Antiga'           'Impressora - Ant.'    'Impr. Ant.'     CHANGING lv_pos,
           zf_build_fieldcat USING ' ' lv_pos 'prnter_new'     'gt_j1bb2' ' ' 'C' 'C300' '15' 'Impressora - Nova'             'Impressora - Nv.'     'Impr. Nova'     CHANGING lv_pos,
           zf_build_fieldcat USING ' ' lv_pos 'lasserprinter'  'gt_j1bb2' ' ' 'C' 'C300' '15' 'Numeração válida em condição'  'Nº válido'            'Nº válido'      CHANGING lv_pos,
           zf_build_fieldcat USING ' ' lv_pos 'prntercont'     'gt_j1bb2' ' ' 'C' 'C300' '15' 'Impressora - Antiga'           'Impressora - Ant.'    'Impr. Ant.'     CHANGING lv_pos,
           zf_build_fieldcat USING ' ' lv_pos 'prntercont_new' 'gt_j1bb2' ' ' 'C' 'C300' '15' 'Impressora - Nova'             'Impressora - Nv.'     'Impr. Nova'     CHANGING lv_pos,
           zf_build_fieldcat USING ' ' lv_pos 'nfenrnr'        'gt_j1bb2' ' ' 'C' 'C300' '15' 'Nº interv.num.'                'Nº interv.num.'       'Nº'             CHANGING lv_pos,
           zf_build_fieldcat USING ' ' lv_pos 'callrfc'        'gt_j1bb2' ' ' 'C' 'C300' '15' 'Execução RFC'                  'Execução RFC'         'Exec.RFC'       CHANGING lv_pos,
           zf_build_fieldcat USING ' ' lv_pos 'tpimp'          'gt_j1bb2' ' ' 'C' 'C300' '15' 'Formato impr.DANFE'            'Formato DANFE'        'Formato'        CHANGING lv_pos.

ENDFORM.

**********************************************************************
*                        CONSTRUÇÃO DO FIELDCAT
**********************************************************************

FORM zf_build_fieldcat USING    p_icon
                                p_col_pos
                                p_fieldname
                                p_tabname
                                p_key
                                p_just
                                p_emphasize
                                p_outputlen
                                p_seltext_l
                                p_seltext_m
                                p_seltext_s
                       CHANGING ch_col_pos.

  APPEND INITIAL LINE TO gt_fieldcat ASSIGNING FIELD-SYMBOL(<fs_fieldcat>).
  IF sy-subrc EQ 0.
    ch_col_pos              = p_col_pos + 1.
    <fs_fieldcat>-icon      = p_icon.
    <fs_fieldcat>-col_pos   = ch_col_pos.
    <fs_fieldcat>-fieldname = p_fieldname.
    <fs_fieldcat>-tabname   = p_tabname.
    <fs_fieldcat>-key       = p_key.
    <fs_fieldcat>-just      = p_just.
    <fs_fieldcat>-emphasize = p_emphasize.
    <fs_fieldcat>-outputlen = p_outputlen.
    <fs_fieldcat>-seltext_l = p_seltext_l.
    <fs_fieldcat>-seltext_m = p_seltext_m.
    <fs_fieldcat>-seltext_s = p_seltext_s.
  ENDIF.

ENDFORM.