*&---------------------------------------------------------------------*
*& Include          ZCARGA_PC_RICF06
*&---------------------------------------------------------------------*

**********************************************************************
*                 VERIFICAÇÃO DE CAMPOS ATUALIZADOS
**********************************************************************

FORM zf_edited_fields.

  LOOP AT gt_order ASSIGNING <fs_order> WHERE check = abap_true.

    APPEND INITIAL LINE TO gt_comparison ASSIGNING FIELD-SYMBOL(<fs_comparison>).
    <fs_comparison>-objectid = <fs_order>-ebeln.

  ENDLOOP.

  IF gt_comparison IS INITIAL.
    MESSAGE TEXT-M06 TYPE 'I' DISPLAY LIKE 'E'.
    RETURN.
  ENDIF.

  SELECT objectid
         changenr
         username
         udate
         utime
  FROM cdhdr
  INTO TABLE gt_cdhdr
  FOR ALL ENTRIES IN gt_comparison
  WHERE objectclas EQ 'EINKBELEG'
    AND objectid   EQ gt_comparison-objectid
    AND udate      EQ sy-datum.

  IF sy-subrc EQ 0.

    SELECT objectid
           changenr
           tabname
           tabkey
           chngind
           unit_old
           unit_new
           cuky_old
           cuky_new
           value_new
           value_old
    FROM cdpos
    INTO TABLE gt_cdpos
    FOR ALL ENTRIES IN gt_cdhdr
    WHERE objectclas EQ 'EINKBELEG'
      AND objectid   EQ gt_cdhdr-objectid
      AND changenr   EQ gt_cdhdr-changenr.

    IF sy-subrc EQ 0.
      LOOP AT gt_cdpos ASSIGNING FIELD-SYMBOL(<fs_cdpos>).

        APPEND INITIAL LINE TO gt_output ASSIGNING FIELD-SYMBOL(<fs_output>).
        READ TABLE gt_cdhdr ASSIGNING FIELD-SYMBOL(<fs_cdhdr>) WITH KEY objectid = <fs_cdpos>-objectid_p
                                                                        changenr = <fs_cdpos>-changenr_p.
        IF sy-subrc EQ 0.
          MOVE-CORRESPONDING <fs_cdhdr> TO <fs_output>.
        ENDIF.
        MOVE-CORRESPONDING <fs_cdpos> TO <fs_output>.

      ENDLOOP.
    ENDIF.

  ENDIF.
  SORT gt_output BY udate utime DESCENDING.

ENDFORM.

**********************************************************************
*                          CONSTRUÇÃO DO ALV
**********************************************************************

FORM zf_display_alv_edit.

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      i_callback_program       = sy-repid
      i_callback_pf_status_set = 'PF_STATUS_EDIT'
      i_callback_user_command  = 'USER_COMMAND_EDIT'
      i_callback_top_of_page   = 'TOP_OF_PAGE_EDIT'
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

FORM top_of_page_edit.

  CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
    EXPORTING
      it_list_commentary = gt_header
      i_logo             = 'LOGO_GEO_NOVA'.

ENDFORM.

**********************************************************************
*                        CONSTRUÇÃO DA HEADER
**********************************************************************

FORM zf_build_header_edit.

  APPEND INITIAL LINE TO gt_header ASSIGNING FIELD-SYMBOL(<fs_header>).
  <fs_header>-typ = 'A'.

ENDFORM.

**********************************************************************
*                           USER COMMAND
**********************************************************************

FORM user_command_edit USING p_ucomm    TYPE sy-ucomm
                             p_selfield TYPE slis_selfield.

  CASE p_ucomm.
    WHEN '&IC1'.
      READ TABLE gt_order ASSIGNING <fs_order> INDEX p_selfield-tabindex.
      IF p_selfield-fieldname EQ 'ebeln' AND p_selfield-value IS NOT INITIAL.
        SET PARAMETER ID 'BES' FIELD p_selfield-value.
        CALL TRANSACTION 'ME23N' AND SKIP FIRST SCREEN.
      ELSEIF p_selfield-fieldname EQ 'inlog' AND <fs_order>-error EQ abap_true.
        LOOP AT gt_log ASSIGNING FIELD-SYMBOL(<fs_log>) WHERE ebeln = <fs_order>-ebeln
                                                          AND ebelp = <fs_order>-ebelp.

          APPEND INITIAL LINE TO gt_log_alv ASSIGNING FIELD-SYMBOL(<fs_log_alv>).
          MOVE-CORRESPONDING <fs_log> TO <fs_log_alv>.

        ENDLOOP.
        PERFORM: zf_build_layout_log,
                 zf_call_fieldcat_log_edit,
                 zf_display_alv_log.
        CLEAR: gt_log_alv, gt_fieldcat_log, gw_layout_log.
      ENDIF.
    WHEN 'EXIBIR'.
      PERFORM zf_edited_fields.
      IF gt_output IS NOT INITIAL.
        PERFORM: zf_build_layout_output,
                 zf_call_fieldcat_output,
                 zf_display_alv_output.
        CLEAR: gt_output, gt_fieldcat_output, gw_layout_output, gt_comparison.
      ENDIF.
  ENDCASE.

ENDFORM.

**********************************************************************
*                           PF-STATUS
**********************************************************************

FORM pf_status_edit USING rkkblo TYPE kkblo_t_extab.

  SET PF-STATUS 'STATUS'.

ENDFORM.

**********************************************************************
*                       CONSTRUÇÃO DO LAYOUT
**********************************************************************

FORM zf_build_layout_edit.

  gw_layout-zebra           = 'X'.
  gw_layout-window_titlebar = 'View da atualização de pedidos de compra'.
  gw_layout-box_fieldname   = 'CHECK'.

ENDFORM.

**********************************************************************
*                       CHAMADA DO FIELDCAT
**********************************************************************

FORM zf_call_fieldcat_edit.

  DATA: lv_pos TYPE i.

  PERFORM: zf_build_fieldcat_edit USING 'X' lv_pos 'icone' 'gt_order' ''      ''     'X' 'C' 'C300' '8'  'Status' 'Status' 'Status' ' ' CHANGING lv_pos,
           zf_build_fieldcat_edit USING 'X' lv_pos 'inlog' 'gt_order' ''      ''     'X' 'C' 'C300' '5'  'Log'    'Log'    'Log'    'X' CHANGING lv_pos,
           zf_build_fieldcat_edit USING ' ' lv_pos 'ebeln' 'gt_order' 'EBELN' 'EKKO' 'X' 'C' 'C300' '12' ''       ''       ''       'X' CHANGING lv_pos,
           zf_build_fieldcat_edit USING ' ' lv_pos 'ebelp' 'gt_order' 'EBELP' 'EKPO' ' ' 'C' 'C300' '9'  ''       ''       ''       ' ' CHANGING lv_pos.

ENDFORM.

**********************************************************************
*                        CONSTRUÇÃO DO FIELDCAT
**********************************************************************

FORM zf_build_fieldcat_edit USING p_icon
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

ENDFORM.