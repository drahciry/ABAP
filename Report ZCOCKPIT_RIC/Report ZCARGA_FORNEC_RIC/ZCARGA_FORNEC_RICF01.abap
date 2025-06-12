*&---------------------------------------------------------------------*
*& Include          ZCARGA_FORNEC_RICF01
*&---------------------------------------------------------------------*

**********************************************************************
*                          LÓGICA PRINCIPAL
**********************************************************************

FORM zf_main.

  CASE 'X'.

    WHEN p_txt.
      PERFORM zf_verify_extension.
      IF lv_key EQ abap_true.
        IF p_view IS NOT INITIAL.
          PERFORM: zf_gui_upload,
                   zf_process_data_txt,
                   zf_build_layout,
                   zf_call_fieldcat,
                   zf_display_alv.
        ELSE.
          PERFORM zf_popup_confirm.
          IF lv_answer EQ '1'.
            PERFORM: zf_gui_upload,
                     zf_process_data_txt,
                     zf_carga,
                     zf_build_layout_view,
                     zf_call_fieldcat_view,
                     zf_display_alv_view.
          ELSE.
            MESSAGE s003(zmc_carga_fornec) DISPLAY LIKE 'E'.
          ENDIF.
        ENDIF.
      ELSE.
        MESSAGE i001(zmc_carga_fornec) DISPLAY LIKE 'E'.
      ENDIF.
    WHEN p_csv.
      PERFORM zf_verify_extension.
      IF lv_key EQ abap_true.
        IF p_view IS NOT INITIAL.
          PERFORM: zf_gui_upload,
                   zf_process_data_csv,
                   zf_build_layout,
                   zf_call_fieldcat,
                   zf_display_alv.
        ELSE.
          PERFORM zf_popup_confirm.
          IF lv_answer EQ '1'.
            PERFORM: zf_gui_upload,
                     zf_process_data_csv,
                     zf_carga,
                     zf_build_layout_view,
                     zf_call_fieldcat_view,
                     zf_display_alv_view.
          ELSE.
            MESSAGE s003(zmc_carga_fornec) DISPLAY LIKE 'E'.
          ENDIF.
        ENDIF.
      ELSE.
        MESSAGE i001(zmc_carga_fornec) DISPLAY LIKE 'E'.
      ENDIF.
    WHEN p_xlsx.
      PERFORM zf_verify_extension.
      IF lv_key EQ abap_true.
        IF p_view IS NOT INITIAL.
          PERFORM: zf_gui_upload_xlsx,
                   zf_process_data_xlsx,
                   zf_build_layout,
                   zf_call_fieldcat,
                   zf_display_alv.
        ELSE.
          PERFORM zf_popup_confirm.
          IF lv_answer EQ '1'.
            PERFORM: zf_gui_upload_xlsx,
                     zf_process_data_xlsx,
                     zf_carga,
                     zf_build_layout_view,
                     zf_call_fieldcat_view,
                     zf_display_alv_view.
          ELSE.
            MESSAGE s003(zmc_carga_fornec) DISPLAY LIKE 'E'.
          ENDIF.
        ENDIF.
      ELSE.
        MESSAGE i001(zmc_carga_fornec) DISPLAY LIKE 'E'.
      ENDIF.
  ENDCASE.

  IF gt_loglifnr IS NOT INITIAL.
    INSERT zloglifnr_ric FROM TABLE gt_loglifnr.
  ENDIF.

ENDFORM.

**********************************************************************
*                      VERIFICAÇÃO DA EXTENSÃO
**********************************************************************

FORM zf_verify_extension.

  " Declaração de constantes locais

  CONSTANTS: c_txt  TYPE char4 VALUE '.txt',
             c_csv  TYPE char4 VALUE '.csv',
             c_xls  TYPE char4 VALUE '.xls',
             c_xlsx TYPE char5 VALUE '.xlsx'.

  " Declaração de variáveis locais

  DATA: lv_offset TYPE i.

  lv_offset = strlen( p_file ) - 4.

  IF p_txt IS NOT INITIAL.
    IF p_file+lv_offset EQ c_txt.
      lv_key = abap_true.
    ENDIF.
  ELSEIF p_csv IS NOT INITIAL.
    IF p_file+lv_offset EQ c_csv.
      lv_key = abap_true.
    ENDIF.
  ELSE.
    IF p_file+lv_offset EQ c_xls.
      lv_key = abap_true.
    ELSE.
      lv_offset = lv_offset - 1.
      IF p_file+lv_offset EQ c_xlsx.
        lv_key = abap_true.
      ENDIF.
    ENDIF.
  ENDIF.

ENDFORM.

**********************************************************************
*                    POPUP DE SELEÇÃO DE ARQUIVO
**********************************************************************

FORM zf_popup.

  CALL FUNCTION 'KD_GET_FILENAME_ON_F4'
    EXPORTING
      field_name    = p_file
    CHANGING
      file_name     = p_file
    EXCEPTIONS
      mask_too_long = 1
      OTHERS        = 2.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
    WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

ENDFORM.

**********************************************************************
*                         UPLOAD DE ARQUIVO
**********************************************************************

FORM zf_gui_upload.

  DATA: lv_file TYPE string.

  lv_file = p_file.

  CALL METHOD cl_gui_frontend_services=>gui_upload
    EXPORTING
      filename                = lv_file
    CHANGING
      data_tab                = gt_file
    EXCEPTIONS
      file_open_error         = 1
      file_read_error         = 2
      no_batch                = 3
      gui_refuse_filetransfer = 4
      invalid_type            = 5
      no_authority            = 6
      unknown_error           = 7
      bad_data_format         = 8
      header_not_allowed      = 9
      separator_not_allowed   = 10
      header_too_long         = 11
      unknown_dp_error        = 12
      access_denied           = 13
      dp_out_of_memory        = 14
      disk_full               = 15
      dp_timeout              = 16
      not_supported_by_gui    = 17
      error_no_gui            = 18
      OTHERS                  = 19.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
    WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

ENDFORM.

**********************************************************************
*                         UPLOAD DE ARQUIVO
**********************************************************************

FORM zf_gui_upload_xlsx.

  CALL FUNCTION 'ALSM_EXCEL_TO_INTERNAL_TABLE'
    EXPORTING
      filename                = p_file
      i_begin_col             = 1
      i_begin_row             = 2
      i_end_col               = 16
      i_end_row               = 65000
    TABLES
      intern                  = gt_excel
    EXCEPTIONS
      inconsistent_parameters = 1
      upload_ole              = 2
      OTHERS                  = 3.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
    WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

ENDFORM.

**********************************************************************
*                         ZEROS A ESQUERDA
**********************************************************************

FORM zf_left_zeros USING p_input CHANGING ch_output.

  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      input  = p_input
    IMPORTING
      output = ch_output.

ENDFORM.

**********************************************************************
*                     CONSTRUÇÃO DO FORNECEDOR
**********************************************************************

FORM zf_build_fornecedor USING p_field p_id CHANGING ch_id.

  IF gw_fornecedor-land1 IS INITIAL.
    ch_id               = p_id + 1.
    gw_fornecedor-icone = '@09@'.
    gw_fornecedor-id    = p_id.
    gw_fornecedor-land1 = p_field.
  ELSEIF gw_fornecedor-name1 IS INITIAL.
    gw_fornecedor-name1 = p_field.
  ELSEIF gw_fornecedor-ort01 IS INITIAL.
    gw_fornecedor-ort01 = p_field.
  ELSEIF gw_fornecedor-pstlz IS INITIAL.
    gw_fornecedor-pstlz = p_field.
  ELSEIF gw_fornecedor-regio IS INITIAL.
    gw_fornecedor-regio = p_field.
  ELSEIF gw_fornecedor-stras IS INITIAL.
    gw_fornecedor-stras = p_field.
  ELSEIF gw_fornecedor-mcod1 IS INITIAL.
    gw_fornecedor-mcod1 = p_field.
  ELSEIF gw_fornecedor-mcod3 IS INITIAL.
    gw_fornecedor-mcod3 = p_field.
  ELSEIF gw_fornecedor-anred IS INITIAL.
    gw_fornecedor-anred = p_field.
  ELSEIF gw_fornecedor-ktokk IS INITIAL.
    gw_fornecedor-ktokk = p_field.
  ELSEIF gw_fornecedor-spras IS INITIAL.
    gw_fornecedor-spras = p_field.
  ELSEIF gw_fornecedor-telf1 IS INITIAL.
    gw_fornecedor-telf1 = p_field.
  ELSEIF gw_fornecedor-email IS INITIAL.
    gw_fornecedor-email = p_field.
  ELSEIF gw_fornecedor-txjcd IS INITIAL.
    gw_fornecedor-txjcd = p_field.
  ELSEIF gw_fornecedor-ekorg IS INITIAL.
    gw_fornecedor-ekorg = p_field.
  ELSEIF gw_fornecedor-waers IS INITIAL.
    gw_fornecedor-waers = p_field.
  ELSEIF gw_fornecedor-zterm IS INITIAL.
    gw_fornecedor-zterm = p_field.
    APPEND gw_fornecedor TO gt_fornecedor.
    CLEAR gw_fornecedor.
  ENDIF.

ENDFORM.

**********************************************************************
*                 CAPTURA DOS DADOS DO ARQUIVO .TXT
**********************************************************************

FORM zf_process_data_txt.

  DATA: lv_pos   TYPE i,
        lv_line  TYPE string,
        lv_field TYPE string,
        gt_field TYPE TABLE OF string.

  CLEAR lv_id.
  LOOP AT gt_file ASSIGNING FIELD-SYMBOL(<fs_file>).

    IF sy-tabix EQ 1.
      CONTINUE.
    ENDIF.

    FIND FIRST OCCURRENCE OF cl_abap_char_utilities=>horizontal_tab IN <fs_file>.

    IF sy-subrc EQ 0.

      REPLACE ALL OCCURRENCES OF cl_abap_char_utilities=>horizontal_tab IN <fs_file> WITH space.

    ENDIF.

    lv_line = <fs_file>.
    CLEAR: lv_pos, lv_field, gt_field[].
    DO.
      FIND ';' IN lv_line MATCH OFFSET lv_pos.
      IF sy-subrc EQ 0.
        lv_field = lv_line(lv_pos).
        PERFORM zf_build_fornecedor USING lv_field lv_id CHANGING lv_id.
        CLEAR lv_field.
      ELSE.
        EXIT.
      ENDIF.
      lv_pos = lv_pos + 1.
      lv_line = lv_line+lv_pos.
    ENDDO.

    IF lv_line IS NOT INITIAL.
      PERFORM zf_build_fornecedor USING lv_line lv_id CHANGING lv_id.
      CLEAR lv_line.
    ENDIF.

  ENDLOOP.

ENDFORM.

**********************************************************************
*                 CAPTURA DOS DADOS DO ARQUIVO .CSV
**********************************************************************

FORM zf_process_data_csv.

  LOOP AT gt_file ASSIGNING FIELD-SYMBOL(<fs_file>).

    IF sy-tabix EQ 1.
      CONTINUE.
    ENDIF.

    FIND FIRST OCCURRENCE OF ';' IN <fs_file>.
    IF sy-subrc EQ 0.
      lv_id = lv_id + 1.
      gw_fornecedor-icone = '@09@'.
      gw_fornecedor-id    = lv_id.
      SPLIT <fs_file> AT ';' INTO gw_fornecedor-land1
                                  gw_fornecedor-name1
                                  gw_fornecedor-ort01
                                  gw_fornecedor-pstlz
                                  gw_fornecedor-regio
                                  gw_fornecedor-stras
                                  gw_fornecedor-mcod1
                                  gw_fornecedor-mcod3
                                  gw_fornecedor-anred
                                  gw_fornecedor-ktokk
                                  gw_fornecedor-spras
                                  gw_fornecedor-telf1
                                  gw_fornecedor-email
                                  gw_fornecedor-txjcd
                                  gw_fornecedor-ekorg
                                  gw_fornecedor-waers
                                  gw_fornecedor-zterm.
      APPEND gw_fornecedor TO gt_fornecedor.
      CLEAR gw_fornecedor.
    ENDIF.

  ENDLOOP.

ENDFORM.

**********************************************************************
*                CAPTURA DOS DADOS DO ARQUIVO .XLSX
**********************************************************************

FORM zf_process_data_xlsx.

  LOOP AT gt_excel ASSIGNING FIELD-SYMBOL(<fs_excel>).
    CASE <fs_excel>-col.
      WHEN 1.
        lv_id = lv_id + 1.
        gw_fornecedor-icone = '@09@'.
        gw_fornecedor-id    = lv_id.
        gw_fornecedor-land1 = <fs_excel>-value.
      WHEN 2.
        gw_fornecedor-name1 = <fs_excel>-value.
      WHEN 3.
        gw_fornecedor-ort01 = <fs_excel>-value.
      WHEN 4.
        gw_fornecedor-pstlz = <fs_excel>-value.
      WHEN 5.
        gw_fornecedor-regio = <fs_excel>-value.
      WHEN 6.
        gw_fornecedor-stras = <fs_excel>-value.
      WHEN 7.
        gw_fornecedor-mcod1 = <fs_excel>-value.
      WHEN 8.
        gw_fornecedor-mcod3 = <fs_excel>-value.
      WHEN 9.
        gw_fornecedor-anred = <fs_excel>-value.
      WHEN 10.
        gw_fornecedor-ktokk = <fs_excel>-value.
      WHEN 11.
        gw_fornecedor-spras = <fs_excel>-value.
      WHEN 12.
        gw_fornecedor-telf1 = <fs_excel>-value.
      WHEN 13.
        gw_fornecedor-email = <fs_excel>-value.
      WHEN 14.
        gw_fornecedor-txjcd = <fs_excel>-value.
      WHEN 15.
        gw_fornecedor-ekorg = <fs_excel>-value.
      WHEN 16.
        gw_fornecedor-waers = <fs_excel>-value.
      WHEN 17.
        gw_fornecedor-zterm = <fs_excel>-value.
        APPEND gw_fornecedor TO gt_fornecedor.
        CLEAR gw_fornecedor.
    ENDCASE.
  ENDLOOP.

ENDFORM.

**********************************************************************
*                   POPUP DE CONFIRMAÇÃO DE CARGA
**********************************************************************

FORM zf_popup_confirm.

  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      titlebar       = 'Confirmação'
      text_question  = 'Preview não mostrado. Deseja realizar a carga mesmo assim?'
      text_button_1  = 'Sim'
      icon_button_1  = 'ICON_OKAY'
      text_button_2  = 'Não'
      icon_button_2  = 'ICON_CANCEL'
      default_button = '2'
    IMPORTING
      answer         = lv_answer
    EXCEPTIONS
      text_not_found = 1
      OTHERS         = 2.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
    WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

ENDFORM.