*&---------------------------------------------------------------------*
*& Include          ZRUPDATE002F03
*&---------------------------------------------------------------------*

**********************************************************************
*                          CONSTRUÇÃO DO ALV
**********************************************************************

FORM zf_display_alv_log.

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      i_callback_program      = sy-repid
      i_grid_title            = 'Logs'
      is_layout               = gw_layout_log
      it_fieldcat             = gt_fieldcat_log
      i_screen_start_column   = 20
      i_screen_start_line     = 5
      i_screen_end_column     = 100
      i_screen_end_line       = 20
    TABLES
      t_outtab                = gt_log_alv
    EXCEPTIONS
      program_error           = 1
      OTHERS                  = 2.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
    WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

ENDFORM.

**********************************************************************
*                       CONSTRUÇÃO DO LAYOUT
**********************************************************************

FORM zf_build_layout_log.

  gw_layout_log-zebra           = 'X'.
  gw_layout_log-window_titlebar = 'Logs de Erro'.

ENDFORM.

**********************************************************************
*                       CHAMADA DO FIELDCAT
**********************************************************************

FORM zf_call_fieldcat_log.

  DATA: lv_pos TYPE i.

  PERFORM: zf_build_fieldcat_log USING lv_pos 'knumh'  'gt_log_alv' 'X' 'C' 'C300' '10' 'Registro'         'Registro'     'Registro' CHANGING lv_pos,
           zf_build_fieldcat_log USING lv_pos 'msglog' 'gt_log_alv' ' ' 'C' 'C300' '34' 'Mensagem de erro' 'Msg. de Erro' 'Msg.Erro' CHANGING lv_pos.

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
  ch_col_pos              = p_col_pos + 1.
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