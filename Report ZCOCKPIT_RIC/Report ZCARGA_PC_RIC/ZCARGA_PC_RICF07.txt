*&---------------------------------------------------------------------*
*& Include          ZCARGA_PC_RICF07
*&---------------------------------------------------------------------*

**********************************************************************
*                            CHAMADA DO ALV
**********************************************************************

FORM zf_display_alv_output.

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      i_grid_title          = 'Campos editados'
      is_layout             = gw_layout_output
      it_fieldcat           = gt_fieldcat_output
      i_screen_start_column = 20
      i_screen_start_line   = 5
      i_screen_end_column   = 140
      i_screen_end_line     = 20
    TABLES
      t_outtab              = gt_output
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

FORM zf_build_layout_output.

  gw_layout_log-zebra           = abap_true.
  gw_layout_log-window_titlebar = 'Log de campos editados'.

ENDFORM.

**********************************************************************
*                     CONSTRUÇÃO DO FIELDCAT
**********************************************************************

FORM zf_call_fieldcat_output.

  DATA: lv_pos TYPE i.

  PERFORM: zf_build_fieldcat_output USING lv_pos 'objectid'  'gt_output' ''          ''      ' ' 'C' 'C200' '15' 'Nº do Pedido' 'Nº Pedido'    'Pedido'       CHANGING lv_pos,
           zf_build_fieldcat_output USING lv_pos 'changenr'  'gt_output' 'CHANGENR'  'CDHDR' ' ' 'C' 'C200' '15' ''             ''             ''             CHANGING lv_pos,
           zf_build_fieldcat_output USING lv_pos 'username'  'gt_output' 'USERNAME'  'CDHDR' ' ' 'C' 'C200' '15' ''             ''             ''             CHANGING lv_pos,
           zf_build_fieldcat_output USING lv_pos 'udate'     'gt_output' 'UDATE'     'CDHDR' ' ' 'C' 'C200' '15' ''             ''             ''             CHANGING lv_pos,
           zf_build_fieldcat_output USING lv_pos 'utime'     'gt_output' 'UTIME'     'CDHDR' ' ' 'C' 'C200' '15' ''             ''             ''             CHANGING lv_pos,
           zf_build_fieldcat_output USING lv_pos 'tabname'   'gt_output' 'TABNAME'   'CDPOS' ' ' 'C' 'C200' '15' ''             ''             ''             CHANGING lv_pos,
           zf_build_fieldcat_output USING lv_pos 'chngind '  'gt_output' 'CHNGIND'   'CDPOS' ' ' 'C' 'C200' '15' ''             ''             ''             CHANGING lv_pos,
           zf_build_fieldcat_output USING lv_pos 'unit_old'  'gt_output' 'UNIT_OLD'  'CDPOS' ' ' 'C' 'C200' '15' ''             ''             ''             CHANGING lv_pos,
           zf_build_fieldcat_output USING lv_pos 'unit_new'  'gt_output' 'UNIT_NEW'  'CDPOS' ' ' 'C' 'C200' '15' ''             ''             ''             CHANGING lv_pos,
           zf_build_fieldcat_output USING lv_pos 'cuky_old'  'gt_output' ''          ''      ' ' 'C' 'C200' '15' 'Moeda Antiga' 'Moeda Antiga' 'Moeda Antiga' CHANGING lv_pos,
           zf_build_fieldcat_output USING lv_pos 'cuky_new'  'gt_output' ''          ''      ' ' 'C' 'C200' '15' 'Moeda Nova'   'Moeda Nova'   'Moeda Nova'   CHANGING lv_pos,
           zf_build_fieldcat_output USING lv_pos 'value_old' 'gt_output' 'VALUE_OLD' 'CDPOS' ' ' 'C' 'C200' '15' ''             ''             ''             CHANGING lv_pos,
           zf_build_fieldcat_output USING lv_pos 'value_new' 'gt_output' 'VALUE_NEW' 'CDPOS' ' ' 'C' 'C200' '15' ''             ''             ''             CHANGING lv_pos.

ENDFORM.

**********************************************************************
*                        CONSTRUÇÃO DO FIELDCAT
**********************************************************************

FORM zf_build_fieldcat_output USING p_col_pos
                                    p_fieldname
                                    p_tabname
                                    p_reffieldname
                                    p_reftabname
                                    p_key
                                    p_just
                                    p_emphasize
                                    p_outputlen
                                    p_seltext_l
                                    p_seltext_m
                                    p_seltext_s
                           CHANGING ch_col_pos.

  APPEND INITIAL LINE TO gt_fieldcat_output ASSIGNING FIELD-SYMBOL(<fs_fieldcat_output>).
  ch_col_pos                  = p_col_pos + 1.
  <fs_fieldcat_output>-col_pos       = ch_col_pos.
  <fs_fieldcat_output>-fieldname     = p_fieldname.
  <fs_fieldcat_output>-tabname       = p_tabname.
  <fs_fieldcat_output>-ref_fieldname = p_reffieldname.
  <fs_fieldcat_output>-ref_tabname   = p_reftabname.
  <fs_fieldcat_output>-key           = p_key.
  <fs_fieldcat_output>-just          = p_just.
  <fs_fieldcat_output>-emphasize     = p_emphasize.
  <fs_fieldcat_output>-outputlen     = p_outputlen.
  <fs_fieldcat_output>-seltext_l     = p_seltext_l.
  <fs_fieldcat_output>-seltext_m     = p_seltext_m.
  <fs_fieldcat_output>-seltext_s     = p_seltext_s.

ENDFORM.