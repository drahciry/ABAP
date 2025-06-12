*&---------------------------------------------------------------------*
*& Include          ZCARGA_FORNEC_RICF05
*&---------------------------------------------------------------------*

**********************************************************************
*                          CONSTRUÇÃO DO ALV
**********************************************************************

FORM zf_display_alv_view.

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      i_callback_program       = sy-repid
      i_callback_pf_status_set = 'PF_STATUS_VIEW'
      i_callback_user_command  = 'USER_COMMAND_VIEW'
      i_callback_top_of_page   = 'TOP_OF_PAGE_VIEW'
      i_grid_title             = 'Fornecedores'
      is_layout                = gw_layout_view
      it_fieldcat              = gt_fieldcat_view
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

FORM top_of_page_view.

  CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
    EXPORTING
      it_list_commentary = gt_header_view
      i_logo             = 'LOGO_GEO_NOVA'.

ENDFORM.

**********************************************************************
*                        CONSTRUÇÃO DA HEADER
**********************************************************************

FORM zf_build_header_view.

  APPEND INITIAL LINE TO gt_header_view ASSIGNING FIELD-SYMBOL(<fs_header_view>).
  <fs_header_view>-typ = 'A'.

endform.

**********************************************************************
*                           USER COMMAND
**********************************************************************

FORM user_command_view USING p_ucomm    TYPE sy-ucomm
                             p_selfield TYPE slis_selfield.

  CASE p_ucomm.
    WHEN '&IC1'.
      PERFORM zf_log USING p_selfield.
    WHEN 'XLSX'.
      PERFORM zf_download_fornec.
  ENDCASE.

ENDFORM.

**********************************************************************
*                           PF-STATUS
**********************************************************************

FORM pf_status_view USING rkkblo TYPE kkblo_t_extab.

  SET PF-STATUS 'STATUS' EXCLUDING 'CAR'.

ENDFORM.

**********************************************************************
*                       CONSTRUÇÃO DO LAYOUT
**********************************************************************

FORM zf_build_layout_view.

  gw_layout_view-zebra           = 'X'.
  gw_layout_view-window_titlebar = 'Preview de Fornecedores'.

ENDFORM.

**********************************************************************
*                       CHAMADA DO FIELDCAT
**********************************************************************

FORM zf_call_fieldcat_view.

  DATA: lv_pos TYPE i.

  PERFORM: zf_build_fieldcat_view USING 'X' lv_pos 'icone' 'gt_fornecedor' 'X' 'C' 'C300' '5'  'Status'              'Status'           'Status'     ' ' CHANGING lv_pos,
           zf_build_fieldcat_view USING 'X' lv_pos 'inlog' 'gt_fornecedor' 'X' 'C' 'C300' '5'  'Log'                 'Log'              'Log'        'X' CHANGING lv_pos,
           zf_build_fieldcat_view USING ' ' lv_pos 'lifnr' 'gt_fornecedor' ' ' 'C' 'C300' '12' 'Fornecedor'          'Fornecedor'       'Fornecedor' 'X' CHANGING lv_pos,
           zf_build_fieldcat_view USING ' ' lv_pos 'land1' 'gt_fornecedor' ' ' 'C' 'C300' '6'  'País'                'País'             'País'       ' ' CHANGING lv_pos,
           zf_build_fieldcat_view USING ' ' lv_pos 'name1' 'gt_fornecedor' ' ' 'C' 'C300' '20' 'Nome'                'Nome'             'Nome'       ' ' CHANGING lv_pos,
           zf_build_fieldcat_view USING ' ' lv_pos 'ort01' 'gt_fornecedor' ' ' 'C' 'C300' '20' 'Local'               'Local'            'Local'      ' ' CHANGING lv_pos,
           zf_build_fieldcat_view USING ' ' lv_pos 'pstlz' 'gt_fornecedor' ' ' 'C' 'C300' '20' 'Código postal'       'Código postal'    'Cód.postal' ' ' CHANGING lv_pos,
           zf_build_fieldcat_view USING ' ' lv_pos 'regio' 'gt_fornecedor' ' ' 'C' 'C300' '8'  'Região'              'Região'           'Região'     ' ' CHANGING lv_pos,
           zf_build_fieldcat_view USING ' ' lv_pos 'stras' 'gt_fornecedor' ' ' 'C' 'C300' '20' 'Rua'                 'Rua'              'Rua'        ' ' CHANGING lv_pos,
           zf_build_fieldcat_view USING ' ' lv_pos 'mcod1' 'gt_fornecedor' ' ' 'C' 'C300' '20' 'Nome'                'Nome'             'Nome'       ' ' CHANGING lv_pos,
           zf_build_fieldcat_view USING ' ' lv_pos 'mcod3' 'gt_fornecedor' ' ' 'C' 'C300' '20' 'Local'               'Local'            'Local'      ' ' CHANGING lv_pos,
           zf_build_fieldcat_view USING ' ' lv_pos 'anred' 'gt_fornecedor' ' ' 'C' 'C300' '20' 'Forma de tratamento' 'FrmTrat.'         'FrmTrat.'   ' ' CHANGING lv_pos,
           zf_build_fieldcat_view USING ' ' lv_pos 'ktokk' 'gt_fornecedor' ' ' 'C' 'C300' '20' 'Grupo de contas'     'Grupo de contas'  'Grp.contas' ' ' CHANGING lv_pos,
           zf_build_fieldcat_view USING ' ' lv_pos 'spras' 'gt_fornecedor' ' ' 'C' 'C300' '18' 'Código de idioma'    'Idioma'           'Idioma'     ' ' CHANGING lv_pos,
           zf_build_fieldcat_view USING ' ' lv_pos 'telf1' 'gt_fornecedor' ' ' 'C' 'C300' '20' 'Telefone 1'          'Telefone 1'       'Telefone 1' ' ' CHANGING lv_pos,
           zf_build_fieldcat_view USING ' ' lv_pos 'email' 'gt_fornecedor' ' ' 'C' 'C300' '20' 'Email'               'Email'            'Email'      ' ' CHANGING lv_pos,
           zf_build_fieldcat_view USING ' ' lv_pos 'txjcd' 'gt_fornecedor' ' ' 'C' 'C300' '20' 'Domicílio fiscal'    'Domicílio fiscal' 'DomFiscal'  ' ' CHANGING lv_pos,
           zf_build_fieldcat_view USING ' ' lv_pos 'ekorg' 'gt_fornecedor' ' ' 'C' 'C300' '20' 'Organiz.compras'     'Org.compras'      'Org.compr.' ' ' CHANGING lv_pos,
           zf_build_fieldcat_view USING ' ' lv_pos 'waers' 'gt_fornecedor' ' ' 'C' 'C300' '7'  'Moeda'               'Moeda'            'Moeda'      ' ' CHANGING lv_pos,
           zf_build_fieldcat_view USING ' ' lv_pos 'zterm' 'gt_fornecedor' ' ' 'C' 'C300' '20' 'Condições pgto.'     'Cond.pgto.'       'Cond.pgto.' ' ' CHANGING lv_pos.

ENDFORM.

**********************************************************************
*                        CONSTRUÇÃO DO FIELDCAT
**********************************************************************

FORM zf_build_fieldcat_view USING    p_icon
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

  APPEND INITIAL LINE TO gt_fieldcat_view ASSIGNING FIELD-SYMBOL(<fs_fieldcat_view>).
  ch_col_pos              = p_col_pos + 1.
  <fs_fieldcat_view>-icon      = p_icon.
  <fs_fieldcat_view>-col_pos   = ch_col_pos.
  <fs_fieldcat_view>-fieldname = p_fieldname.
  <fs_fieldcat_view>-tabname   = p_tabname.
  <fs_fieldcat_view>-key       = p_key.
  <fs_fieldcat_view>-just      = p_just.
  <fs_fieldcat_view>-emphasize = p_emphasize.
  <fs_fieldcat_view>-outputlen = p_outputlen.
  <fs_fieldcat_view>-seltext_l = p_seltext_l.
  <fs_fieldcat_view>-seltext_m = p_seltext_m.
  <fs_fieldcat_view>-seltext_s = p_seltext_s.
  <fs_fieldcat_view>-hotspot   = p_hotspot.

ENDFORM.

**********************************************************************
*                        CARGA DE FORNECEDOR
**********************************************************************

FORM zf_carga.

  LOOP AT gt_fornecedor ASSIGNING FIELD-SYMBOL(<fs_fornecedor>).
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
      <fs_fornecedor>-lifnr = <fs_return>-message_v1.
      <fs_fornecedor>-icone = icon_green_light.
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

ENDFORM.