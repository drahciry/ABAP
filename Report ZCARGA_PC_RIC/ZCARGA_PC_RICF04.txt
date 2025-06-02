*&---------------------------------------------------------------------*
*& Include          ZCARGA_PC_RICF04
*&---------------------------------------------------------------------*

**********************************************************************
*                          CONSTRUÇÃO DO ALV
**********************************************************************

FORM zf_display_alv_create.

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      i_callback_program       = sy-repid
      i_callback_pf_status_set = 'PF_STATUS_CREATE'
      i_callback_user_command  = 'USER_COMMAND_CREATE'
      i_callback_top_of_page   = 'TOP_OF_PAGE_CREATE'
      i_grid_title             = 'Pedidos'
      is_layout                = gw_layout
      it_fieldcat              = gt_fieldcat
    TABLES
      t_outtab                 = gt_order
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

FORM top_of_page_create.

  CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
    EXPORTING
      it_list_commentary = gt_header
      i_logo             = 'LOGO_GEO_NOVA'.

ENDFORM.

**********************************************************************
*                        CONSTRUÇÃO DA HEADER
**********************************************************************

FORM zf_build_header_create.

  APPEND INITIAL LINE TO gt_header ASSIGNING FIELD-SYMBOL(<fs_header>).
  <fs_header>-typ = 'A'.

ENDFORM.

**********************************************************************
*                           USER COMMAND
**********************************************************************

FORM user_command_create USING p_ucomm    TYPE sy-ucomm
                               p_selfield TYPE slis_selfield.

  CASE p_ucomm.
    WHEN '&IC1'.
      READ TABLE gt_order ASSIGNING <fs_order> INDEX p_selfield-tabindex.
      IF p_selfield-fieldname EQ 'ebeln' AND p_selfield-value IS NOT INITIAL.
        SET PARAMETER ID 'BES' FIELD p_selfield-value.
        CALL TRANSACTION 'ME23N' AND SKIP FIRST SCREEN.
      ELSEIF p_selfield-fieldname EQ 'inlog' AND <fs_order>-error EQ abap_true.
        LOOP AT gt_log ASSIGNING FIELD-SYMBOL(<fs_log>) WHERE lifnr = <fs_order>-lifnr.

          APPEND INITIAL LINE TO gt_log_alv ASSIGNING FIELD-SYMBOL(<fs_log_alv>).
          MOVE-CORRESPONDING <fs_log> TO <fs_log_alv>.

        ENDLOOP.
        PERFORM: zf_build_layout_log,
                 zf_call_fieldcat_log_create,
                 zf_display_alv_log.
        CLEAR: gt_log_alv, gt_fieldcat_log, gw_layout_log.
      ENDIF.
  ENDCASE.

ENDFORM.

**********************************************************************
*                           PF-STATUS
**********************************************************************

FORM pf_status_create USING rkkblo TYPE kkblo_t_extab.

  SET PF-STATUS 'STATUS' EXCLUDING 'EXIBIR'.

ENDFORM.

**********************************************************************
*                       CONSTRUÇÃO DO LAYOUT
**********************************************************************

FORM zf_build_layout_create.

  gw_layout-zebra           = 'X'.
  gw_layout-window_titlebar = 'View de Pedidos de Compra'.
  gw_layout-info_fieldname  = 'color'.

ENDFORM.

**********************************************************************
*                       CHAMADA DO FIELDCAT
**********************************************************************

FORM zf_call_fieldcat_create.

  DATA: lv_pos TYPE i.

  PERFORM: zf_build_fieldcat_create USING 'X' lv_pos 'icone' 'gt_order' ''      ''     'X' 'C' 'C300' '8'  'Status' 'Status' 'Status' ' ' CHANGING lv_pos,
           zf_build_fieldcat_create USING 'X' lv_pos 'inlog' 'gt_order' ''      ''     'X' 'C' 'C300' '5'  'Log'    'Log'    'Log'    'X' CHANGING lv_pos,
           zf_build_fieldcat_create USING ' ' lv_pos 'ebeln' 'gt_order' 'EBELN' 'EKKO' 'X' 'C' 'C300' '12' ''       ''       ''       'X' CHANGING lv_pos,
           zf_build_fieldcat_create USING ' ' lv_pos 'bukrs' 'gt_order' 'BUKRS' 'EKKO' ' ' 'C' 'C300' '9'  ''       ''       ''       ' ' CHANGING lv_pos,
           zf_build_fieldcat_create USING ' ' lv_pos 'bstyp' 'gt_order' 'BSTYP' 'EKKO' ' ' 'C' 'C300' '17' ''       ''       ''       ' ' CHANGING lv_pos,
           zf_build_fieldcat_create USING ' ' lv_pos 'bsart' 'gt_order' 'BSART' 'EKKO' ' ' 'C' 'C300' '17' ''       ''       ''       ' ' CHANGING lv_pos,
           zf_build_fieldcat_create USING ' ' lv_pos 'lifnr' 'gt_order' 'LIFNR' 'EKKO' ' ' 'C' 'C300' '17' ''       ''       ''       ' ' CHANGING lv_pos,
           zf_build_fieldcat_create USING ' ' lv_pos 'ekorg' 'gt_order' 'EKORG' 'EKKO' ' ' 'C' 'C300' '17' ''       ''       ''       ' ' CHANGING lv_pos,
           zf_build_fieldcat_create USING ' ' lv_pos 'ekgrp' 'gt_order' 'EKGRP' 'EKKO' ' ' 'C' 'C300' '17' ''       ''       ''       ' ' CHANGING lv_pos,
           zf_build_fieldcat_create USING ' ' lv_pos 'waers' 'gt_order' 'WAERS' 'EKKO' ' ' 'C' 'C300' '7'  ''       ''       ''       ' ' CHANGING lv_pos,
           zf_build_fieldcat_create USING ' ' lv_pos 'ebelp' 'gt_order' 'EBELP' 'EKPO' ' ' 'C' 'C300' '17' ''       ''       ''       ' ' CHANGING lv_pos,
           zf_build_fieldcat_create USING ' ' lv_pos 'txz01' 'gt_order' 'TXZ01' 'EKPO' ' ' 'C' 'C300' '25' ''       ''       ''       ' ' CHANGING lv_pos,
           zf_build_fieldcat_create USING ' ' lv_pos 'matnr' 'gt_order' 'MATNR' 'EKPO' ' ' 'C' 'C300' '17' ''       ''       ''       ' ' CHANGING lv_pos,
           zf_build_fieldcat_create USING ' ' lv_pos 'werks' 'gt_order' 'WERKS' 'EKPO' ' ' 'C' 'C300' '17' ''       ''       ''       ' ' CHANGING lv_pos,
           zf_build_fieldcat_create USING ' ' lv_pos 'menge' 'gt_order' 'MENGE' 'EKPO' ' ' 'C' 'C300' '17' ''       ''       ''       ' ' CHANGING lv_pos,
           zf_build_fieldcat_create USING ' ' lv_pos 'meins' 'gt_order' 'MEINS' 'EKPO' ' ' 'C' 'C300' '11' ''       ''       ''       ' ' CHANGING lv_pos,
           zf_build_fieldcat_create USING ' ' lv_pos 'netpr' 'gt_order' 'NETPR' 'EKPO' ' ' 'C' 'C300' '17' ''       ''       ''       ' ' CHANGING lv_pos,
           zf_build_fieldcat_create USING ' ' lv_pos 'peinh' 'gt_order' 'PEINH' 'EKPO' ' ' 'C' 'C300' '17' ''       ''       ''       ' ' CHANGING lv_pos,
           zf_build_fieldcat_create USING ' ' lv_pos 'netwr' 'gt_order' 'NETWR' 'EKPO' ' ' 'C' 'C300' '17' ''       ''       ''       ' ' CHANGING lv_pos,
           zf_build_fieldcat_create USING ' ' lv_pos 'brtwr' 'gt_order' 'BRTWR' 'EKPO' ' ' 'C' 'C300' '17' ''       ''       ''       ' ' CHANGING lv_pos.

ENDFORM.

**********************************************************************
*                        CONSTRUÇÃO DO FIELDCAT
**********************************************************************

FORM zf_build_fieldcat_create USING p_icon
                                    p_col_pos
                                    p_fieldname
                                    p_tabname
                                    p_ref_fieldname
                                    p_ref_tabname
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
    ch_col_pos                  = p_col_pos + 1.
    <fs_fieldcat>-icon          = p_icon.
    <fs_fieldcat>-col_pos       = ch_col_pos.
    <fs_fieldcat>-fieldname     = p_fieldname.
    <fs_fieldcat>-tabname       = p_tabname.
    <fs_fieldcat>-ref_fieldname = p_ref_fieldname.
    <fs_fieldcat>-ref_tabname   = p_ref_tabname.
    <fs_fieldcat>-key           = p_key.
    <fs_fieldcat>-just          = p_just.
    <fs_fieldcat>-emphasize     = p_emphasize.
    <fs_fieldcat>-outputlen     = p_outputlen.
    <fs_fieldcat>-seltext_l     = p_seltext_l.
    <fs_fieldcat>-seltext_m     = p_seltext_m.
    <fs_fieldcat>-seltext_s     = p_seltext_s.
    <fs_fieldcat>-hotspot       = p_hotspot.
  ENDIF.

ENDFORM.