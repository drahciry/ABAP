*&---------------------------------------------------------------------*
*& Include          ZRUPDATE002F02
*&---------------------------------------------------------------------*

**********************************************************************
*                          CONSTRUÇÃO DO ALV
**********************************************************************

FORM zf_display_alv.

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      i_callback_program       = sy-repid
      i_callback_pf_status_set = 'PF_STATUS'
      i_callback_user_command  = 'USER_COMMAND'
      i_callback_top_of_page   = 'TOP_OF_PAGE'
      i_grid_title             = 'Registros'
      is_layout                = gw_layout
      it_fieldcat              = gt_fieldcat
    TABLES
      t_outtab                 = gt_nach
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
      i_logo             = 'LOGO_GEO_NOVA'.

ENDFORM.

**********************************************************************
*                            USER COMMAND
**********************************************************************

FORM user_command USING p_ucomm TYPE sy-ucomm
                        p_selfield TYPE slis_selfield.

  CASE p_ucomm.
    WHEN '&IC1'.
      IF p_selfield-fieldname EQ 'log' AND p_selfield-value EQ icon_history.
        READ TABLE gt_nach ASSIGNING FIELD-SYMBOL(<fs_nach>) INDEX p_selfield-tabindex.
        LOOP AT gt_log ASSIGNING FIELD-SYMBOL(<fs_log>) WHERE knumh = <fs_nach>-knumh.

          APPEND INITIAL LINE TO gt_log_alv ASSIGNING FIELD-SYMBOL(<fs_log_alv>).
          <fs_log_alv>-knumh  = <fs_log>-knumh.
          <fs_log_alv>-msglog = <fs_log>-msglog.

        ENDLOOP.
        IF NOT gt_log_alv IS INITIAL.
          PERFORM: zf_build_layout_log,
                   zf_call_fieldcat_log,
                   zf_display_alv_log.
          CLEAR: gt_log_alv, gt_fieldcat_log, gw_layout_log.
        ENDIF.
      ENDIF.
  ENDCASE.

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
  <fs_header>-typ  = 'H'.
  <fs_header>-info = 'Feedback de Atualização do campo LDEST'.

  APPEND INITIAL LINE TO gt_header ASSIGNING <fs_header>.
  <fs_header>-typ  = 'S'.
  <fs_header>-key  = 'Número de registros:'.
  <fs_header>-info = lv_qtdreg.

ENDFORM.

**********************************************************************
*                       CONSTRUÇÃO DO LAYOUT
**********************************************************************

FORM zf_build_layout.

  gw_layout-zebra           = 'X'.
  gw_layout-window_titlebar = 'Registros atualizados'.

ENDFORM.

**********************************************************************
*                       CHAMADA DO FIELDCAT
**********************************************************************

FORM zf_call_fieldcat.

  DATA: lv_pos TYPE i.

  PERFORM: zf_build_fieldcat USING 'X' lv_pos 'icone'      'gt_nach' 'X' 'C' 'C300' '8'  'Status'                                 'Status'            'Status'     ' ' CHANGING lv_pos,
           zf_build_fieldcat USING ' ' lv_pos 'log'        'gt_nach' ' ' 'C' 'C300' '5'  'Log'                                    'Log'               'Log'        'X' CHANGING lv_pos,
           zf_build_fieldcat USING ' ' lv_pos 'knumh'      'gt_nach' ' ' 'C' 'C300' '15' 'Nº registro condição'                   'Nºreg.condição'    'Nºrg.cond.' ' ' CHANGING lv_pos,
           zf_build_fieldcat USING ' ' lv_pos 'ernam'      'gt_nach' ' ' 'C' 'C300' '15' 'Criado por'                             'Criado por'        'Criado/a'   ' ' CHANGING lv_pos,
           zf_build_fieldcat USING ' ' lv_pos 'erdat'      'gt_nach' ' ' 'C' 'C300' '15' 'Dt.criação'                             'Dt.criação'        'Dt.criação' ' ' CHANGING lv_pos,
           zf_build_fieldcat USING ' ' lv_pos 'kvewe'      'gt_nach' ' ' 'C' 'C300' '15' 'Utilização'                             'Utilização'        'Utilização' ' ' CHANGING lv_pos,
           zf_build_fieldcat USING ' ' lv_pos 'kotabnr'    'gt_nach' ' ' 'C' 'C300' '15' 'Nº da tabela'                           'Nº da tabela'      'Nºtabela'   ' ' CHANGING lv_pos,
           zf_build_fieldcat USING ' ' lv_pos 'kappl'      'gt_nach' ' ' 'C' 'C300' '15' 'Aplicação'                              'Aplicação'         'Aplicação'  ' ' CHANGING lv_pos,
           zf_build_fieldcat USING ' ' lv_pos 'kschl'      'gt_nach' ' ' 'C' 'C300' '15' 'Tipo de condição'                       'Tipo condição'     'Tp.cond.'   ' ' CHANGING lv_pos,
           zf_build_fieldcat USING ' ' lv_pos 'datab'      'gt_nach' ' ' 'C' 'C300' '15' 'Válido desde'                           'Válido desde'      'Vál.desde'  ' ' CHANGING lv_pos,
           zf_build_fieldcat USING ' ' lv_pos 'datbi'      'gt_nach' ' ' 'C' 'C300' '15' 'Válido até'                             'Válido até'        'até'        ' ' CHANGING lv_pos,
           zf_build_fieldcat USING ' ' lv_pos 'kosrt'      'gt_nach' ' ' 'C' 'C300' '15' 'Critério de pesquisa'                   'Critério pesq.'    'CritPesq.'  ' ' CHANGING lv_pos,
           zf_build_fieldcat USING ' ' lv_pos 'parvw'      'gt_nach' ' ' 'C' 'C300' '15' 'Função parceiro'                        'Função parceiro'   'Função'     ' ' CHANGING lv_pos,
           zf_build_fieldcat USING ' ' lv_pos 'parnr'      'gt_nach' ' ' 'C' 'C300' '15' 'Parceiro de mensagem'                   'Parceiro'          'Parceiro'   ' ' CHANGING lv_pos,
           zf_build_fieldcat USING ' ' lv_pos 'nacha'      'gt_nach' ' ' 'C' 'C300' '15' 'Meio transmissão'                       'Meio transmiss.'   'Meio'       ' ' CHANGING lv_pos,
           zf_build_fieldcat USING ' ' lv_pos 'anzal'      'gt_nach' ' ' 'C' 'C300' '15' 'Nº de mensagens'                        'Número'            'Número'     ' ' CHANGING lv_pos,
           zf_build_fieldcat USING ' ' lv_pos 'vsztp'      'gt_nach' ' ' 'C' 'C300' '15' 'Momento do envio'                       'Momento'           'Momento'    ' ' CHANGING lv_pos,
           zf_build_fieldcat USING ' ' lv_pos 'tcode'      'gt_nach' ' ' 'C' 'C300' '15' 'Estratégia comunicação'                 'Estrat.comunic.'   'Estratégia' ' ' CHANGING lv_pos,
           zf_build_fieldcat USING ' ' lv_pos 'aende'      'gt_nach' ' ' 'C' 'C300' '15' 'Mensag.modificação'                     'Mensagem modif.'   'Modif.'     ' ' CHANGING lv_pos,
           zf_build_fieldcat USING ' ' lv_pos 'pfld3'      'gt_nach' ' ' 'C' 'C300' '15' 'Nome do formulário'                     'Nome formulário'   'Nome'       ' ' CHANGING lv_pos,
           zf_build_fieldcat USING ' ' lv_pos 'pfld4'      'gt_nach' ' ' 'C' 'C300' '15' 'Formulário SAPscript'                   'Formulário'        'Formulário' ' ' CHANGING lv_pos,
           zf_build_fieldcat USING ' ' lv_pos 'pfld5'      'gt_nach' ' ' 'C' 'C300' '15' 'Módulo layout p/preparação p/impressão' 'Módulo layout'     'Módulo'     ' ' CHANGING lv_pos,
           zf_build_fieldcat USING ' ' lv_pos 'tdname'     'gt_nach' ' ' 'C' 'C300' '15' 'Chave de objeto'                        'Ch.obj.por ext.'   'Chv.objeto' ' ' CHANGING lv_pos,
           zf_build_fieldcat USING ' ' lv_pos 'tdid'       'gt_nach' ' ' 'C' 'C300' '15' 'ID de texto'                            'ID de texto'       'ID'         ' ' CHANGING lv_pos,
           zf_build_fieldcat USING ' ' lv_pos 'spras'      'gt_nach' ' ' 'C' 'C300' '15' 'Código de idioma'                       'Idioma'            'Idioma'     ' ' CHANGING lv_pos,
           zf_build_fieldcat USING ' ' lv_pos 'forfb'      'gt_nach' ' ' 'C' 'C300' '15' ''                                       ''                  ''           ' ' CHANGING lv_pos,
           zf_build_fieldcat USING ' ' lv_pos 'prifb'      'gt_nach' ' ' 'C' 'C300' '15' 'Notif.status via mail'                  'Status via mail'   'St.mail'    ' ' CHANGING lv_pos,
           zf_build_fieldcat USING ' ' lv_pos 'ldest'      'gt_nach' ' ' 'C' 'C300' '15' 'Impressora - Antiga'                    'Impressora Ant.'   'Impr.Ant.'  ' ' CHANGING lv_pos,
           zf_build_fieldcat USING ' ' lv_pos 'ldest_new'  'gt_nach' ' ' 'C' 'C300' '15' 'Impressora - Nova'                      'Impressora Nova'   'Impr.Nova'  ' ' CHANGING lv_pos,
           zf_build_fieldcat USING ' ' lv_pos 'dsnam'      'gt_nach' ' ' 'C' 'C300' '15' 'Nome ordem spool'                       'Nome'              'Nome'       ' ' CHANGING lv_pos,
           zf_build_fieldcat USING ' ' lv_pos 'dsuf1'      'gt_nach' ' ' 'C' 'C300' '15' 'Sufixo 1'                               'Sufixo 1'          'Sufixo 1'   ' ' CHANGING lv_pos,
           zf_build_fieldcat USING ' ' lv_pos 'dsuf2'      'gt_nach' ' ' 'C' 'C300' '15' 'Sufixo 2'                               'Sufixo 2'          'Sufixo 2'   ' ' CHANGING lv_pos,
           zf_build_fieldcat USING ' ' lv_pos 'dimme'      'gt_nach' ' ' 'C' 'C300' '15' 'Imprim.imediatamente'                   'Imprim.imediat.'   'Imediatam.' ' ' CHANGING lv_pos,
           zf_build_fieldcat USING ' ' lv_pos 'delet'      'gt_nach' ' ' 'C' 'C300' '15' 'Liberação após saída'                   'Lib.após saída'    'Liberação'  ' ' CHANGING lv_pos,
           zf_build_fieldcat USING ' ' lv_pos 'tdreceiver' 'gt_nach' ' ' 'C' 'C300' '15' 'Destinatário'                           'Destinatário'      'Destinat.'  ' ' CHANGING lv_pos,
           zf_build_fieldcat USING ' ' lv_pos 'tddivision' 'gt_nach' ' ' 'C' 'C300' '15' 'Departamento no falso-rosto'            'Departamento'      'Dpto.'      ' ' CHANGING lv_pos,
           zf_build_fieldcat USING ' ' lv_pos 'tdocover'   'gt_nach' ' ' 'C' 'C300' '15' 'Falso-rosto SAP'                        'Falso-rosto SAP'   '1ª pág.SAP' ' ' CHANGING lv_pos,
           zf_build_fieldcat USING ' ' lv_pos 'tdcovtitle' 'gt_nach' ' ' 'C' 'C300' '15' 'Texto p/falso-rosto'                    'Txt.falso rosto'   'Texto'      ' ' CHANGING lv_pos,
           zf_build_fieldcat USING ' ' lv_pos 'tdautority' 'gt_nach' ' ' 'C' 'C300' '15' 'Autorização'                            'Autorização'       'Autoriz.'   ' ' CHANGING lv_pos,
           zf_build_fieldcat USING ' ' lv_pos 'acout'      'gt_nach' ' ' 'C' 'C300' '15' 'Conclusão externa de SAPoffice'         'Conclusão externa' 'ConclExt'   ' ' CHANGING lv_pos,
           zf_build_fieldcat USING ' ' lv_pos 'acmem'      'gt_nach' ' ' 'C' 'C300' '15' 'ID-memória'                             'ID-memória'        'ID-memória' ' ' CHANGING lv_pos,
           zf_build_fieldcat USING ' ' lv_pos 'acnam'      'gt_nach' ' ' 'C' 'C300' '15' 'Elemento de execução'                   'Elemento exec.'    'Elem.exec.' ' ' CHANGING lv_pos,
           zf_build_fieldcat USING ' ' lv_pos 'event'      'gt_nach' ' ' 'C' 'C300' '15' 'Evento'                                 'Evento'            'Evento'     ' ' CHANGING lv_pos,
           zf_build_fieldcat USING ' ' lv_pos 'objtype'    'gt_nach' ' ' 'C' 'C300' '15' 'Tipo de objeto'                         'Tipo de objeto'    'Tp.objeto'  ' ' CHANGING lv_pos,
           zf_build_fieldcat USING ' ' lv_pos 'tdschedule' 'gt_nach' ' ' 'C' 'C300' '15' 'Hora de envio'                          'Programação'       'Progr.'     ' ' CHANGING lv_pos,
           zf_build_fieldcat USING ' ' lv_pos 'tdarmod'    'gt_nach' ' ' 'C' 'C300' '15' 'Modo de arquivamento'                   'Modo arquivmto.'   'Md.arquiv.' ' ' CHANGING lv_pos.

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
                                p_hotspot
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
    <fs_fieldcat>-hotspot   = p_hotspot.
  ENDIF.

ENDFORM.