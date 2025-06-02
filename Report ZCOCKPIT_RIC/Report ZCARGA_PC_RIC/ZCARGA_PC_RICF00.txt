*&---------------------------------------------------------------------*
*& Include          ZCARGA_PC_RICF00
*&---------------------------------------------------------------------*

**********************************************************************
*                     AT SELECTION SCREEN OUPUT
**********************************************************************

FORM zf_at_selection_screen_output.

  LOOP AT SCREEN.

    IF screen-group1 EQ 'T1'.
      IF p_create EQ 'X'.
        screen-active    = 1.
        screen-invisible = 0.
      ELSE.
        screen-active    = 0.
        screen-invisible = 1.
      ENDIF.
    ELSEIF screen-group1 EQ 'T2'.
      IF p_edit EQ 'X'.
        screen-active    = 1.
        screen-invisible = 0.
      ELSE.
        screen-active    = 0.
        screen-invisible = 1.
      ENDIF.
    ENDIF.
    MODIFY SCREEN.

  ENDLOOP.

ENDFORM.

**********************************************************************
*                         AT SELECTION SCREEN
**********************************************************************

FORM zf_at_selection_screen.

  CASE sy-ucomm.
    WHEN 'BTN01'.
      lv_ucomm         = 'BTN1'.
      sscrfields-ucomm = 'ONLI'.
    WHEN 'BTN02'.
      lv_ucomm         = 'BTN2'.
      sscrfields-ucomm = 'ONLI'.
  ENDCASE.

ENDFORM.

**********************************************************************
*                  POPUP DO EXPLORADOR DE ARQUIVOS
**********************************************************************

FORM zf_popup.

  CALL METHOD cl_gui_frontend_services=>file_open_dialog
    EXPORTING
      multiselection          = abap_false
    CHANGING
      file_table              = gt_filetable
      rc                      = lv_rc
    EXCEPTIONS
      file_open_dialog_failed = 1
      cntl_error              = 2
      error_no_gui            = 3
      not_supported_by_gui    = 4
      OTHERS                  = 5.
  IF sy-subrc EQ 0 AND lv_rc GT 0.
    READ TABLE gt_filetable INTO p_file INDEX 1.
  ELSEIF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
    WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

ENDFORM.

**********************************************************************
*                      SUB-ROTINA PRINCIPAL
**********************************************************************

FORM zf_main.

  IF p_file IS INITIAL.
    MESSAGE TEXT-m05 TYPE 'I' DISPLAY LIKE 'E'.
  ELSE.
    PERFORM zf_verify_extension.
    IF lv_key EQ abap_true.
      IF p_create IS NOT INITIAL.
        CASE abap_true.
          WHEN p_txt.
            PERFORM: zf_upload,
                     zf_process_data_txt_create.
          WHEN p_csv.
            PERFORM: zf_upload,
                     zf_process_data_csv_create.
          WHEN p_xls.
            PERFORM: zf_upload_excel,
                     zf_process_data_excel_create.
        ENDCASE.
        PERFORM zf_select_lifnr.
        IF lv_find EQ abap_true.
          IF gt_order IS NOT INITIAL.
            SORT gt_order BY lifnr matnr.
            PERFORM: zf_create_order,
                     zf_build_layout_create,
                     zf_build_header_create,
                     zf_call_fieldcat_create,
                     zf_display_alv_create.
          ELSE.
            MESSAGE TEXT-m04 TYPE 'I' DISPLAY LIKE 'E'.
          ENDIF.
        ELSE.
          MESSAGE TEXT-m03 TYPE 'I' DISPLAY LIKE 'E'.
        ENDIF.
      ELSE.
        CASE abap_true.
          WHEN p_csved.
            PERFORM: zf_upload,
                     zf_process_data_csv_edit.
          WHEN p_xlsed.
            PERFORM: zf_upload_excel,
                     zf_process_data_excel_edit.
        ENDCASE.
        IF gt_order IS NOT INITIAL.
          PERFORM: zf_build_layout_edit,
                   zf_build_header_edit,
                   zf_call_fieldcat_edit,
                   zf_display_alv_edit.
        ELSE.
          MESSAGE TEXT-m04 TYPE 'I' DISPLAY LIKE 'E'.
        ENDIF.
      ENDIF.
    ELSE.
      MESSAGE TEXT-m01 TYPE 'I' DISPLAY LIKE 'E'.
    ENDIF.
  ENDIF.

ENDFORM.