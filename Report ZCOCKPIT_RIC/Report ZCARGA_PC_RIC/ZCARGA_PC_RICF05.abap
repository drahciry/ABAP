*&---------------------------------------------------------------------*
*& Include          ZCARGA_PC_RICF05
*&---------------------------------------------------------------------*

**********************************************************************
*                            CHAMADA DO ALV
**********************************************************************

FORM zf_display_alv_log.

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      i_grid_title          = 'Mensagens'
      is_layout             = gw_layout_log
      it_fieldcat           = gt_fieldcat_log
      i_screen_start_column = 20
      i_screen_start_line   = 5
      i_screen_end_column   = 140
      i_screen_end_line     = 20
    TABLES
      t_outtab              = gt_log_alv
    EXCEPTIONS
      program_error         = 1
      OTHERS                = 2.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
    WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

ENDFORM.

**********************************************************************
*                        CONSTRUÇÃO DO LAYOUT
**********************************************************************

FORM zf_build_layout_log.

  gw_layout_log-zebra           = abap_true.
  gw_layout_log-window_titlebar = 'Logs de erro'.
  gw_layout-colwidth_optimize   = abap_true.

ENDFORM.

**********************************************************************
*             CONSTRUÇÃO DO FIELDCAT - CRIAÇÃO DE PEDIDOS
**********************************************************************

FORM zf_call_fieldcat_log_create.

  DATA: lv_pos TYPE i.

  PERFORM: zf_build_fieldcat_log USING lv_pos 'lifnr'      'gt_log_alv' ' ' 'C' 'C200' '12' 'Fornecedor'             'Fornecedor'   'Fornecedor' CHANGING lv_pos,
           zf_build_fieldcat_log USING lv_pos 'type'       'gt_log_alv' ' ' 'C' 'C200' '10' 'Tipo da Mensagem'       'Tipo Msg.'    'Tp.Msg.'    CHANGING lv_pos,
           zf_build_fieldcat_log USING lv_pos 'id'         'gt_log_alv' ' ' 'C' 'C200' '10' 'ID da Mensagem'         'ID da Msg.'   'ID Msg.'    CHANGING lv_pos,
           zf_build_fieldcat_log USING lv_pos 'number'     'gt_log_alv' ' ' 'C' 'C200' '10' 'Nº da Mensgagem'        'Nº da Msg.'   'NºMsg.'     CHANGING lv_pos,
           zf_build_fieldcat_log USING lv_pos 'message'    'gt_log_alv' ' ' 'C' 'C200' '45' 'Mensagem'               'Mensagem'     'Msg.'       CHANGING lv_pos,
           zf_build_fieldcat_log USING lv_pos 'log_no'     'gt_log_alv' ' ' 'C' 'C200' '10' 'Log de Aplicação'       'Log de Apli.' 'LogApli.'   CHANGING lv_pos,
           zf_build_fieldcat_log USING lv_pos 'log_msg_no' 'gt_log_alv' ' ' 'C' 'C200' '10' 'Nº de Log de Aplicação' 'NºLogApli.'   'NºApli.'    CHANGING lv_pos,
           zf_build_fieldcat_log USING lv_pos 'message_v1' 'gt_log_alv' ' ' 'C' 'C200' '10' 'Variável 1'             'Variável 1'   'Var. 1'     CHANGING lv_pos,
           zf_build_fieldcat_log USING lv_pos 'message_v2' 'gt_log_alv' ' ' 'C' 'C200' '10' 'Variável 2'             'Variável 2'   'Var. 2'     CHANGING lv_pos,
           zf_build_fieldcat_log USING lv_pos 'message_v3' 'gt_log_alv' ' ' 'C' 'C200' '10' 'Variável 3'             'Variável 3'   'Var. 3'     CHANGING lv_pos,
           zf_build_fieldcat_log USING lv_pos 'message_v4' 'gt_log_alv' ' ' 'C' 'C200' '10' 'Variável 4'             'Variável 4'   'Var. 4'     CHANGING lv_pos.

ENDFORM.

**********************************************************************
*             CONSTRUÇÃO DO FIELDCAT - EDIÇÃO DE PEDIDOS
**********************************************************************

FORM zf_call_fieldcat_log_edit.

  DATA: lv_pos TYPE i.

  PERFORM: zf_build_fieldcat_log USING lv_pos 'ebeln'      'gt_log_alv' ' ' 'C' 'C200' '12' 'Nº do Pedido'           'Nº Pedido'    'Pedido'     CHANGING lv_pos,
           zf_build_fieldcat_log USING lv_pos 'ebelp'      'gt_log_alv' ' ' 'C' 'C200' '12' 'Nº do Item'             'Nº Item'      'Item'       CHANGING lv_pos,
           zf_build_fieldcat_log USING lv_pos 'type'       'gt_log_alv' ' ' 'C' 'C200' '10' 'Tipo da Mensagem'       'Tipo Msg.'    'Tp.Msg.'    CHANGING lv_pos,
           zf_build_fieldcat_log USING lv_pos 'id'         'gt_log_alv' ' ' 'C' 'C200' '10' 'ID da Mensagem'         'ID da Msg.'   'ID Msg.'    CHANGING lv_pos,
           zf_build_fieldcat_log USING lv_pos 'number'     'gt_log_alv' ' ' 'C' 'C200' '10' 'Nº da Mensgagem'        'Nº da Msg.'   'NºMsg.'     CHANGING lv_pos,
           zf_build_fieldcat_log USING lv_pos 'message'    'gt_log_alv' ' ' 'C' 'C200' '45' 'Mensagem'               'Mensagem'     'Msg.'       CHANGING lv_pos,
           zf_build_fieldcat_log USING lv_pos 'log_no'     'gt_log_alv' ' ' 'C' 'C200' '10' 'Log de Aplicação'       'Log de Apli.' 'LogApli.'   CHANGING lv_pos,
           zf_build_fieldcat_log USING lv_pos 'log_msg_no' 'gt_log_alv' ' ' 'C' 'C200' '10' 'Nº de Log de Aplicação' 'NºLogApli.'   'NºApli.'    CHANGING lv_pos,
           zf_build_fieldcat_log USING lv_pos 'message_v1' 'gt_log_alv' ' ' 'C' 'C200' '10' 'Variável 1'             'Variável 1'   'Var. 1'     CHANGING lv_pos,
           zf_build_fieldcat_log USING lv_pos 'message_v2' 'gt_log_alv' ' ' 'C' 'C200' '10' 'Variável 2'             'Variável 2'   'Var. 2'     CHANGING lv_pos,
           zf_build_fieldcat_log USING lv_pos 'message_v3' 'gt_log_alv' ' ' 'C' 'C200' '10' 'Variável 3'             'Variável 3'   'Var. 3'     CHANGING lv_pos,
           zf_build_fieldcat_log USING lv_pos 'message_v4' 'gt_log_alv' ' ' 'C' 'C200' '10' 'Variável 4'             'Variável 4'   'Var. 4'     CHANGING lv_pos.

ENDFORM.

**********************************************************************
*                        CONSTRUÇÃO DO FIELDCAT
**********************************************************************

FORM zf_build_fieldcat_log USING    p_col_pos
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

  APPEND INITIAL LINE TO gt_fieldcat_log ASSIGNING FIELD-SYMBOL(<fs_fieldcat_log>).
  ch_col_pos                  = p_col_pos + 1.
  <fs_fieldcat_log>-col_pos   = ch_col_pos.
  <fs_fieldcat_log>-fieldname = p_fieldname.
  <fs_fieldcat_log>-tabname   = p_tabname.
  <fs_fieldcat_log>-key       = p_key.
  <fs_fieldcat_log>-just      = p_just.
  <fs_fieldcat_log>-emphasize = p_emphasize.
  <fs_fieldcat_log>-outputlen = p_outputlen.
  <fs_fieldcat_log>-seltext_l = p_seltext_l.
  <fs_fieldcat_log>-seltext_m = p_seltext_m.
  <fs_fieldcat_log>-seltext_s = p_seltext_s.

ENDFORM.