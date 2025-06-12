*&---------------------------------------------------------------------*
*& Include          ZCARGA_FORNEC_RICF04
*&---------------------------------------------------------------------*

**********************************************************************
*                       CONSTRUÇÃO DO LOG DO ALV
**********************************************************************

FORM zf_log USING p_selfield TYPE slis_selfield.

  READ TABLE gt_fornecedor ASSIGNING FIELD-SYMBOL(<fs_fornecedor>) INDEX p_selfield-tabindex.
  IF p_selfield-fieldname EQ 'inlog' AND <fs_fornecedor>-error EQ abap_true.
    LOOP AT gt_log ASSIGNING FIELD-SYMBOL(<fs_log>) WHERE id = <fs_fornecedor>-id.

      APPEND INITIAL LINE TO gt_log_alv ASSIGNING FIELD-SYMBOL(<fs_log_alv>).
      <fs_log_alv>-id     = <fs_log>-id.
      <fs_log_alv>-msglog = <fs_log>-msglog.

    ENDLOOP.
    IF gt_log_alv IS NOT INITIAL.
      PERFORM: zf_build_layout_log,
               zf_call_fieldcat_log,
               zf_display_alv_log.
      CLEAR: gt_fieldcat_log, gw_layout_log, gt_log_alv.
    ENDIF.
  ENDIF.

ENDFORM.

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
      i_screen_end_column   = 80
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

  gw_layout_log-zebra           = 'X'.
  gw_layout_log-window_titlebar = 'Logs de erro'.

ENDFORM.

**********************************************************************
*                        CONSTRUÇÃO DO FIELDCAT
**********************************************************************

FORM zf_call_fieldcat_log.

  DATA: lv_pos TYPE i.

  PERFORM: zf_build_fieldcat_log USING lv_pos 'msglog' 'gt_log_alv' 'X' 'C' 'C300' '34' 'Mensagem de Erro' 'Msg. de Erro' 'Msg.Erro' CHANGING lv_pos.

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