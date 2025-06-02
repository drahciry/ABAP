*&---------------------------------------------------------------------*
*& Include          ZCARGA_FORNEC_RICF02
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
      i_grid_title             = 'Fornecedores'
      is_layout                = gw_layout
      it_fieldcat              = gt_fieldcat
    TABLES
      t_outtab                 = gt_fornecedor
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
*                        CONSTRUÇÃO DA HEADER
**********************************************************************

FORM zf_build_header.

  APPEND INITIAL LINE TO gt_header ASSIGNING FIELD-SYMBOL(<fs_header>).
  <fs_header>-typ = 'A'.

ENDFORM.

**********************************************************************
*                           USER COMMAND
**********************************************************************

FORM user_command USING p_ucomm    TYPE sy-ucomm
                        p_selfield TYPE slis_selfield.

  CASE p_ucomm.
    WHEN 'CAR'.
      LOOP AT gt_fornecedor ASSIGNING FIELD-SYMBOL(<fs_fornecedor>) WHERE check = abap_true.
        PERFORM zf_realiza_carga USING    <fs_fornecedor>-land1
                                          <fs_fornecedor>-name1
                                          <fs_fornecedor>-ort01
                                          <fs_fornecedor>-pstlz
                                          <fs_fornecedor>-regio
                                          <fs_fornecedor>-stras
                                          <fs_fornecedor>-spras
                                          <fs_fornecedor>-telf1
                                          <fs_fornecedor>-email
                                          <fs_fornecedor>-txjcd
                                          <fs_fornecedor>-ekorg
                                          <fs_fornecedor>-waers
                                          <fs_fornecedor>-zterm
                                 CHANGING gt_return.

        READ TABLE gt_return ASSIGNING FIELD-SYMBOL(<fs_return>) WITH KEY type = 'S' id = 'R1' number = 425.
        IF sy-subrc EQ 0.
          PERFORM zf_left_zeros USING <fs_return>-message_v1 CHANGING <fs_fornecedor>-lifnr.
          <fs_fornecedor>-icone = icon_green_light.
          APPEND INITIAL LINE TO gt_loglifnr ASSIGNING FIELD-SYMBOL(<fs_loglifnr>).
          <fs_loglifnr>-mandt = sy-mandt.
          <fs_loglifnr>-lifnr = <fs_fornecedor>-lifnr.
          <fs_loglifnr>-ernam = sy-uname.
          <fs_loglifnr>-erdat = sy-datum.
          <fs_loglifnr>-hora  = sy-uzeit.
          <fs_loglifnr>-trans = sy-tcode.
        ELSE.
          <fs_fornecedor>-icone = icon_red_light.
          <fs_fornecedor>-inlog = icon_history.
          <fs_fornecedor>-error = abap_true.
          LOOP AT gt_return ASSIGNING <fs_return>.

            APPEND INITIAL LINE TO gt_log ASSIGNING FIELD-SYMBOL(<fs_log>).
            <fs_log>-id     = <fs_fornecedor>-id.
            <fs_log>-msglog = <fs_return>-message.

          ENDLOOP.
        ENDIF.
        CLEAR gt_return.
      ENDLOOP.
      IF sy-subrc EQ 0.
        p_selfield-refresh    = abap_true.
        p_selfield-row_stable = abap_true.
      ELSE.
        MESSAGE TEXT-m01 TYPE 'S' DISPLAY LIKE 'E'.
      ENDIF.
    WHEN '&IC1'.
      PERFORM zf_log USING p_selfield.
    WHEN 'XLSX'.
      PERFORM zf_download_fornec.
  ENDCASE.

ENDFORM.

**********************************************************************
*                           PF-STATUS
**********************************************************************

FORM pf_status USING rkkblo TYPE kkblo_t_extab.

  SET PF-STATUS 'STATUS'.

ENDFORM.

**********************************************************************
*                       CONSTRUÇÃO DO LAYOUT
**********************************************************************

FORM zf_build_layout.

  gw_layout-zebra           = 'X'.
  gw_layout-window_titlebar = 'Preview de Fornecedores'.
  gw_layout-box_fieldname   = 'CHECK'.

ENDFORM.

**********************************************************************
*                       CHAMADA DO FIELDCAT
**********************************************************************

FORM zf_call_fieldcat.

  DATA: lv_pos TYPE i.

  PERFORM: zf_build_fieldcat USING 'X' lv_pos 'icone' 'gt_fornecedor' 'X' 'C' 'C300' '5'  'Status'              'Status'           'Status'     ' ' CHANGING lv_pos,
           zf_build_fieldcat USING 'X' lv_pos 'inlog' 'gt_fornecedor' 'X' 'C' 'C300' '5'  'Log'                 'Log'              'Log'        'X' CHANGING lv_pos,
           zf_build_fieldcat USING ' ' lv_pos 'lifnr' 'gt_fornecedor' ' ' 'C' 'C300' '12' 'Fornecedor'          'Fornecedor'       'Fornecedor' 'X' CHANGING lv_pos,
           zf_build_fieldcat USING ' ' lv_pos 'land1' 'gt_fornecedor' ' ' 'C' 'C300' '6'  'País'                'País'             'País'       ' ' CHANGING lv_pos,
           zf_build_fieldcat USING ' ' lv_pos 'name1' 'gt_fornecedor' ' ' 'C' 'C300' '20' 'Nome'                'Nome'             'Nome'       ' ' CHANGING lv_pos,
           zf_build_fieldcat USING ' ' lv_pos 'ort01' 'gt_fornecedor' ' ' 'C' 'C300' '20' 'Local'               'Local'            'Local'      ' ' CHANGING lv_pos,
           zf_build_fieldcat USING ' ' lv_pos 'pstlz' 'gt_fornecedor' ' ' 'C' 'C300' '20' 'Código postal'       'Código postal'    'Cód.postal' ' ' CHANGING lv_pos,
           zf_build_fieldcat USING ' ' lv_pos 'regio' 'gt_fornecedor' ' ' 'C' 'C300' '8'  'Região'              'Região'           'Região'     ' ' CHANGING lv_pos,
           zf_build_fieldcat USING ' ' lv_pos 'stras' 'gt_fornecedor' ' ' 'C' 'C300' '20' 'Rua'                 'Rua'              'Rua'        ' ' CHANGING lv_pos,
           zf_build_fieldcat USING ' ' lv_pos 'mcod1' 'gt_fornecedor' ' ' 'C' 'C300' '20' 'Nome'                'Nome'             'Nome'       ' ' CHANGING lv_pos,
           zf_build_fieldcat USING ' ' lv_pos 'mcod3' 'gt_fornecedor' ' ' 'C' 'C300' '20' 'Local'               'Local'            'Local'      ' ' CHANGING lv_pos,
           zf_build_fieldcat USING ' ' lv_pos 'anred' 'gt_fornecedor' ' ' 'C' 'C300' '20' 'Forma de tratamento' 'FrmTrat.'         'FrmTrat.'   ' ' CHANGING lv_pos,
           zf_build_fieldcat USING ' ' lv_pos 'ktokk' 'gt_fornecedor' ' ' 'C' 'C300' '20' 'Grupo de contas'     'Grupo de contas'  'Grp.contas' ' ' CHANGING lv_pos,
           zf_build_fieldcat USING ' ' lv_pos 'spras' 'gt_fornecedor' ' ' 'C' 'C300' '18' 'Código de idioma'    'Idioma'           'Idioma'     ' ' CHANGING lv_pos,
           zf_build_fieldcat USING ' ' lv_pos 'telf1' 'gt_fornecedor' ' ' 'C' 'C300' '20' 'Telefone 1'          'Telefone 1'       'Telefone 1' ' ' CHANGING lv_pos,
           zf_build_fieldcat USING ' ' lv_pos 'email' 'gt_fornecedor' ' ' 'C' 'C300' '20' 'Email'               'Email'            'Email'      ' ' CHANGING lv_pos,
           zf_build_fieldcat USING ' ' lv_pos 'txjcd' 'gt_fornecedor' ' ' 'C' 'C300' '20' 'Domicílio fiscal'    'Domicílio fiscal' 'DomFiscal'  ' ' CHANGING lv_pos,
           zf_build_fieldcat USING ' ' lv_pos 'ekorg' 'gt_fornecedor' ' ' 'C' 'C300' '20' 'Organiz.compras'     'Org.compras'      'Org.compr.' ' ' CHANGING lv_pos,
           zf_build_fieldcat USING ' ' lv_pos 'waers' 'gt_fornecedor' ' ' 'C' 'C300' '7'  'Moeda'               'Moeda'            'Moeda'      ' ' CHANGING lv_pos,
           zf_build_fieldcat USING ' ' lv_pos 'zterm' 'gt_fornecedor' ' ' 'C' 'C300' '20' 'Condições pgto.'     'Cond.pgto.'       'Cond.pgto.' ' ' CHANGING lv_pos.

ENDFORM.

**********************************************************************
*                        CONSTRUÇÃO DO FIELDCAT
**********************************************************************

FORM zf_build_fieldcat USING p_icon
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

**********************************************************************
*                       LAYOUT PARA DOWNLOAD
**********************************************************************

FORM zf_layout_download.

  APPEND INITIAL LINE TO gt_layout ASSIGNING FIELD-SYMBOL(<fs_layout>).
  <fs_layout>-colu1  = 'País'.
  <fs_layout>-colu2  = 'Nome'.
  <fs_layout>-colu3  = 'Local'.
  <fs_layout>-colu4  = 'Código postal'.
  <fs_layout>-colu5  = 'Região'.
  <fs_layout>-colu6  = 'Rua'.
  <fs_layout>-colu7  = 'Nome'.
  <fs_layout>-colu8  = 'Local'.
  <fs_layout>-colu9  = 'Forma de tratamento'.
  <fs_layout>-colu10 = 'Grupo de contas'.
  <fs_layout>-colu11 = 'Código de idioma'.
  <fs_layout>-colu12 = 'Telefone 1'.
  <fs_layout>-colu13 = 'Email'.
  <fs_layout>-colu14 = 'Domicílio fiscal'.
  <fs_layout>-colu15 = 'Organiz.compras'.
  <fs_layout>-colu16 = 'Moeda'.
  <fs_layout>-colu17 = 'Condições pgto.'.

  CALL METHOD cl_gui_frontend_services=>file_save_dialog
    EXPORTING
      default_file_name         = 'Layout de Excel (APENAS LAYOUT).xls'
      file_filter               = 'XLS'
    CHANGING
      filename                  = lv_filename
      path                      = lv_path
      fullpath                  = lv_fullpath
    EXCEPTIONS
      cntl_error                = 1
      error_no_gui              = 2
      not_supported_by_gui      = 3
      invalid_default_file_name = 4
      OTHERS                    = 5.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
    WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

  CALL METHOD cl_gui_frontend_services=>gui_download
    EXPORTING
      filename                = lv_fullpath
      write_field_separator   = 'X'
      trunc_trailing_blanks   = 'X'
    CHANGING
      data_tab                = gt_layout
    EXCEPTIONS
      file_write_error        = 1
      no_batch                = 2
      gui_refuse_filetransfer = 3
      invalid_type            = 4
      no_authority            = 5
      unknown_error           = 6
      header_not_allowed      = 7
      separator_not_allowed   = 8
      filesize_not_allowed    = 9
      header_too_long         = 10
      dp_error_create         = 11
      dp_error_send           = 12
      dp_error_write          = 13
      unknown_dp_error        = 14
      access_denied           = 15
      dp_out_of_memory        = 16
      disk_full               = 17
      dp_timeout              = 18
      file_not_found          = 19
      dataprovider_exception  = 20
      control_flush_error     = 21
      not_supported_by_gui    = 22
      error_no_gui            = 23
      OTHERS                  = 24.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
    WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ELSE.
    IF lv_fullpath IS NOT INITIAL.
      MESSAGE i002(zmc_carga_fornec) DISPLAY LIKE 'S'.
    ELSE.
      MESSAGE s003(zmc_carga_fornec) DISPLAY LIKE 'E'.
    ENDIF.
  ENDIF.

  CLEAR gt_layout.

ENDFORM.

**********************************************************************
*                  DOWNLOAD DOS FORNECEDORES CRIADOS
**********************************************************************

FORM zf_download_fornec.

  APPEND INITIAL LINE TO gt_download ASSIGNING FIELD-SYMBOL(<fs_download>).
  <fs_download>-lifnr = 'Nº Fornecedor'.
  <fs_download>-ernam = 'Criador'.
  <fs_download>-ktokk = 'Grupo de contas'.
  <fs_download>-zterm = 'Condições pgto.'.

  LOOP AT gt_fornecedor ASSIGNING FIELD-SYMBOL(<fs_fornecedor>) WHERE lifnr IS NOT INITIAL.

    APPEND INITIAL LINE TO gt_download ASSIGNING <fs_download>.
    <fs_download>-lifnr = <fs_fornecedor>-lifnr.
    <fs_download>-ernam = sy-uname.
    <fs_download>-ktokk = <fs_fornecedor>-ktokk.
    <fs_download>-zterm = <fs_fornecedor>-zterm.

  ENDLOOP.

  CALL METHOD cl_gui_frontend_services=>file_save_dialog
    EXPORTING
      default_file_name         = 'Fornecedores criados.xls'
      file_filter               = 'Planilha Excel (*.xls)|*.xls|'
    CHANGING
      filename                  = lv_filename
      path                      = lv_path
      fullpath                  = lv_fullpath
    EXCEPTIONS
      cntl_error                = 1
      error_no_gui              = 2
      not_supported_by_gui      = 3
      invalid_default_file_name = 4
      OTHERS                    = 5.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
    WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

  CALL METHOD cl_gui_frontend_services=>gui_download
    EXPORTING
      filename                = lv_fullpath
      write_field_separator   = 'X'
      trunc_trailing_blanks   = 'X'
    CHANGING
      data_tab                = gt_download
    EXCEPTIONS
      file_write_error        = 1
      no_batch                = 2
      gui_refuse_filetransfer = 3
      invalid_type            = 4
      no_authority            = 5
      unknown_error           = 6
      header_not_allowed      = 7
      separator_not_allowed   = 8
      filesize_not_allowed    = 9
      header_too_long         = 10
      dp_error_create         = 11
      dp_error_send           = 12
      dp_error_write          = 13
      unknown_dp_error        = 14
      access_denied           = 15
      dp_out_of_memory        = 16
      disk_full               = 17
      dp_timeout              = 18
      file_not_found          = 19
      dataprovider_exception  = 20
      control_flush_error     = 21
      not_supported_by_gui    = 22
      error_no_gui            = 23
      OTHERS                  = 24.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
    WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ELSE.
    IF lv_fullpath IS NOT INITIAL.
      MESSAGE i004(zmc_carga_fornec) DISPLAY LIKE 'S'.
    ELSE.
      MESSAGE s003(zmc_carga_fornec) DISPLAY LIKE 'E'.
    ENDIF.
  ENDIF.

  CLEAR gt_download.

ENDFORM.