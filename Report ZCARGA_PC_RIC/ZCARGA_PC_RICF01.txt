*&---------------------------------------------------------------------*
*& Include          ZCARGA_PC_RICF01
*&---------------------------------------------------------------------*

**********************************************************************
*                       VERIFICAÇÃO DA EXTENSÃO
**********************************************************************

FORM zf_verify_extension.

  " Declaração de constantes locais

  CONSTANTS: c_txt  TYPE char4 VALUE '.TXT',
             c_csv  TYPE char4 VALUE '.CSV',
             c_xls  TYPE char4 VALUE '.XLS',
             c_xlsx TYPE char5 VALUE '.XLSX'.

  " Declaração de variáveis locais

  DATA: lv_offset TYPE i.

  lv_offset = strlen( p_file ) - 4.

  IF p_create IS NOT INITIAL.
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
  ELSE.
    IF p_csved IS NOT INITIAL.
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
  ENDIF.

ENDFORM.

**********************************************************************
*                        UPLOAD DO ARQUIVO
**********************************************************************

FORM zf_upload.

  CALL METHOD cl_gui_frontend_services=>gui_upload
    EXPORTING
      filename                = p_file
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
*                      UPLOAD DE PLANILHA EXCEL
**********************************************************************

FORM zf_upload_excel.

  " Declaração de variáveis locais

  DATA: lv_filename TYPE rlgrap-filename.

  lv_filename = p_file.

  CALL FUNCTION 'ALSM_EXCEL_TO_INTERNAL_TABLE'
    EXPORTING
      filename                = lv_filename
      i_begin_col             = 1
      i_begin_row             = 1
      i_end_col               = 100
      i_end_row               = 9999
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
*                       CONVERSÃO DO MATERIAL
**********************************************************************

FORM zf_conversion_matnr USING p_input CHANGING ch_output.

  CALL FUNCTION 'CONVERSION_EXIT_MATN1_INPUT'
    EXPORTING
      input        = p_input
    IMPORTING
      output       = ch_output
    EXCEPTIONS
      length_error = 1
      OTHERS       = 2.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
    WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

ENDFORM.

**********************************************************************
*            INSERÇÃO DE DADOS DO ARQUIVO NA TABELA INTERNA
**********************************************************************

FORM zf_build_order USING p_field.

  IF <fs_order>-bukrs IS INITIAL.
    <fs_order>-bukrs = p_field.
  ELSEIF <fs_order>-bstyp IS INITIAL.
    <fs_order>-bstyp = p_field.
  ELSEIF <fs_order>-bsart IS INITIAL.
    <fs_order>-bsart = p_field.
  ELSEIF <fs_order>-lifnr IS INITIAL.
    PERFORM zf_left_zeros USING p_field CHANGING <fs_order>-lifnr.
  ELSEIF <fs_order>-ekorg IS INITIAL.
    <fs_order>-ekorg = p_field.
  ELSEIF <fs_order>-ekgrp IS INITIAL.
    PERFORM zf_left_zeros USING p_field CHANGING <fs_order>-ekgrp.
  ELSEIF <fs_order>-waers IS INITIAL.
    <fs_order>-waers = p_field.
  ELSEIF <fs_order>-itext IS INITIAL.
    <fs_order>-itext = p_field.
  ELSEIF <fs_order>-ebelp IS INITIAL.
    PERFORM zf_left_zeros USING p_field CHANGING <fs_order>-ebelp.
  ELSEIF <fs_order>-txz01 IS INITIAL.
    <fs_order>-txz01 = p_field.
  ELSEIF <fs_order>-matnr IS INITIAL.
    PERFORM zf_conversion_matnr USING p_field CHANGING <fs_order>-matnr.
  ELSEIF <fs_order>-werks IS INITIAL.
    <fs_order>-werks = p_field.
  ELSEIF lv_menge_str IS INITIAL.
    lv_menge_str = p_field.
  ELSEIF <fs_order>-meins IS INITIAL.
    <fs_order>-meins = p_field.
  ELSEIF lv_netpr_str IS INITIAL.
    lv_netpr_str = p_field.
  ELSEIF lv_peinh_str IS INITIAL.
    lv_peinh_str = p_field.
  ELSEIF lv_netwr_str IS INITIAL.
    lv_netwr_str = p_field.
  ELSEIF lv_brtwr_str IS INITIAL.
    lv_brtwr_str = p_field.
  ELSEIF <fs_order>-ptext IS INITIAL.
    <fs_order>-ptext = p_field.
    CLEAR: lv_menge_str, lv_netpr_str, lv_peinh_str, lv_netwr_str, lv_brtwr_str.
  ENDIF.

  IF lv_menge_str IS NOT INITIAL AND
     lv_netpr_str IS NOT INITIAL AND
     lv_peinh_str IS NOT INITIAL AND
     lv_netwr_str IS NOT INITIAL AND
     lv_brtwr_str IS NOT INITIAL.

    TRY.
        REPLACE ALL OCCURRENCES OF ',' IN lv_menge_str WITH '.'.
        REPLACE ALL OCCURRENCES OF ',' IN lv_netpr_str WITH '.'.
        REPLACE ALL OCCURRENCES OF ',' IN lv_peinh_str WITH '.'.
        REPLACE ALL OCCURRENCES OF ',' IN lv_netwr_str WITH '.'.
        REPLACE ALL OCCURRENCES OF ',' IN lv_brtwr_str WITH '.'.
        <fs_order>-menge = lv_menge_str.
        <fs_order>-netpr = lv_netpr_str.
        <fs_order>-peinh = lv_peinh_str.
        <fs_order>-netwr = lv_netwr_str.
        <fs_order>-brtwr = lv_brtwr_str.
      CATCH cx_sy_conversion_no_number INTO DATA(lv_error).
    ENDTRY.

  ENDIF.

ENDFORM.

**********************************************************************
*                        PROCESSAMENTO DE .TXT
**********************************************************************

FORM zf_process_data_txt_create.

  " Declaração de variáveis locais

  DATA: lv_pos   TYPE i,
        lv_field TYPE string.

  LOOP AT gt_file ASSIGNING FIELD-SYMBOL(<fs_file>).

    FIND FIRST OCCURRENCE OF cl_abap_char_utilities=>horizontal_tab IN <fs_file>.
    IF sy-subrc EQ 0.
      REPLACE ALL OCCURRENCES OF cl_abap_char_utilities=>horizontal_tab IN <fs_file> WITH space.
    ENDIF.
    APPEND INITIAL LINE TO gt_order ASSIGNING <fs_order>.
    DO.
      FIND FIRST OCCURRENCE OF ';' IN <fs_file> MATCH OFFSET lv_pos.
      IF sy-subrc EQ 0.
        lv_field  = <fs_file>+0(lv_pos).
        lv_pos    = lv_pos + 1.
        <fs_file> = <fs_file>+lv_pos.
        PERFORM zf_build_order USING lv_field.
      ELSE.
        IF <fs_file> IS NOT INITIAL.
          lv_field = <fs_file>.
          PERFORM zf_build_order USING lv_field.
        ENDIF.
        EXIT.
      ENDIF.
    ENDDO.
    CLEAR: lv_pos, lv_field.

  ENDLOOP.

ENDFORM.

**********************************************************************
*                        PROCESSAMENTO DE .CSV
**********************************************************************

FORM zf_process_data_csv_create.

  LOOP AT gt_file ASSIGNING FIELD-SYMBOL(<fs_file>).

    APPEND INITIAL LINE TO gt_order ASSIGNING <fs_order>.
    SPLIT <fs_file> AT ';' INTO <fs_order>-bukrs  " Empresa
                                <fs_order>-bstyp  " Categoria do documento de compras
                                <fs_order>-bsart  " Tipo de documento de compras
                                <fs_order>-lifnr  " Nº conta do fornecedor
                                <fs_order>-ekorg  " Organização de compras
                                <fs_order>-ekgrp  " Grupo de compradores
                                <fs_order>-waers  " Código da moeda
                                <fs_order>-itext  " Texto de item
                                <fs_order>-ebelp  " Nº Item do documento de compra
                                <fs_order>-txz01  " Texto breve
                                <fs_order>-matnr  " Nº do material
                                <fs_order>-werks  " Centro
                                lv_menge_str      " Quantidade do pedido
                                <fs_order>-meins  " Unidade de medida do pedido
                                lv_netpr_str      " Preço líquido no documento de compra na moeda do documento
                                lv_peinh_str      " Unidade preço
                                lv_netwr_str      " Valor líquido do pedido em moeda de pedido
                                lv_brtwr_str      " Valor do pedido bruto em moeda de pedido
                                <fs_order>-ptext. " Texto de cabeçalho

    PERFORM zf_left_zeros USING <fs_order>-lifnr CHANGING <fs_order>-lifnr.
    PERFORM zf_left_zeros USING <fs_order>-ekgrp CHANGING <fs_order>-ekgrp.
    PERFORM zf_conversion_matnr USING <fs_order>-matnr CHANGING <fs_order>-matnr.

    TRY.
        REPLACE ALL OCCURRENCES OF ',' IN lv_menge_str WITH '.'.
        REPLACE ALL OCCURRENCES OF ',' IN lv_netpr_str WITH '.'.
        REPLACE ALL OCCURRENCES OF ',' IN lv_peinh_str WITH '.'.
        REPLACE ALL OCCURRENCES OF ',' IN lv_netwr_str WITH '.'.
        REPLACE ALL OCCURRENCES OF ',' IN lv_brtwr_str WITH '.'.
        <fs_order>-menge = lv_menge_str.
        <fs_order>-netpr = lv_netpr_str.
        <fs_order>-peinh = lv_peinh_str.
        <fs_order>-netwr = lv_netwr_str.
        <fs_order>-brtwr = lv_brtwr_str.
      CATCH cx_sy_conversion_no_number INTO DATA(lv_error).
        CONTINUE.
    ENDTRY.

  ENDLOOP.

ENDFORM.

**********************************************************************
*                       PROCESSAMENTO DE EXCEL
**********************************************************************

FORM zf_process_data_excel_create.

  LOOP AT gt_excel ASSIGNING FIELD-SYMBOL(<fs_excel>).

    CASE <fs_excel>-col.
      WHEN 1. " Empresa
        APPEND INITIAL LINE TO gt_order ASSIGNING <fs_order>.
        PERFORM zf_build_order USING <fs_excel>-value.
      WHEN 2. " Categoria do documento de compras
        PERFORM zf_build_order USING <fs_excel>-value.
      WHEN 3. " Tipo de documento de compras
        PERFORM zf_build_order USING <fs_excel>-value.
      WHEN 4. " Nº conta do fornecedor
        PERFORM zf_build_order USING <fs_excel>-value.
      WHEN 5. " Organização de compras
        PERFORM zf_build_order USING <fs_excel>-value.
      WHEN 6. " Grupo de compradores
        PERFORM zf_build_order USING <fs_excel>-value.
      WHEN 7. " Código da moeda
        PERFORM zf_build_order USING <fs_excel>-value.
      WHEN 8. " Texto de item
        PERFORM zf_build_order USING <fs_excel>-value.
      WHEN 9. " Nº Item do documento de compra
        PERFORM zf_build_order USING <fs_excel>-value.
      WHEN 10. " Texto breve
        PERFORM zf_build_order USING <fs_excel>-value.
      WHEN 11. " Nº do material
        PERFORM zf_build_order USING <fs_excel>-value.
      WHEN 12. " Centro
        PERFORM zf_build_order USING <fs_excel>-value.
      WHEN 13. " Quantidade do pedido
        PERFORM zf_build_order USING <fs_excel>-value.
      WHEN 14. " Unidade de medida do pedido
        PERFORM zf_build_order USING <fs_excel>-value.
      WHEN 15. " Preço líquido no documento de compra na moeda do documento
        PERFORM zf_build_order USING <fs_excel>-value.
      WHEN 16. " Unidade preço
        PERFORM zf_build_order USING <fs_excel>-value.
      WHEN 17. " Valor líquido do pedido em moeda de pedido
        PERFORM zf_build_order USING <fs_excel>-value.
      WHEN 18. " Valor do pedido bruto em moeda de pedido
        PERFORM zf_build_order USING <fs_excel>-value.
      WHEN 19. " Texto de cabeçalho
        PERFORM zf_build_order USING <fs_excel>-value.
    ENDCASE.

  ENDLOOP.

ENDFORM.

**********************************************************************
*            DOWNLOAD DE LAYOUT DE CARGA - CRIAÇÃO DE PEDIDO
**********************************************************************

FORM zf_download_layout_create.

  " Estruturas locais

  TYPES: BEGIN OF ty_layout,
           col01 TYPE string, " Empresa
           col02 TYPE string, " Categoria do documento de compras
           col03 TYPE string, " Tipo de documento de compras
           col04 TYPE string, " Nº conta do fornecedor
           col05 TYPE string, " Organização de compras
           col06 TYPE string, " Grupo de compradores
           col07 TYPE string, " Código da moeda
           col08 TYPE string, " Nº Item do documento de compra
           col09 TYPE string, " Texto breve
           col10 TYPE string, " Nº do material
           col11 TYPE string, " Centro
           col12 TYPE string, " Quantidade do pedido
           col13 TYPE string, " Unidade de medida do pedido
           col14 TYPE string, " Preço líquido no documento de compra na moeda do documento
           col15 TYPE string, " Unidade preço
           col16 TYPE string, " Valor líquido do pedido em moeda de pedido
           col17 TYPE string, " Valor do pedido bruto em moeda de pedido
         END OF ty_layout.

  " Declaração de variáveis locais

  DATA: lv_file     TYPE string,
        lv_path     TYPE string,
        lv_fullpath TYPE string.

  " Declaração de tabelas internas locais

  DATA: gt_layout TYPE TABLE OF ty_layout.

  APPEND INITIAL LINE TO gt_layout ASSIGNING FIELD-SYMBOL(<fs_layout>).
  <fs_layout>-col01 = 'Empresa'.
  <fs_layout>-col02 = 'Categoria do documento de compras'.
  <fs_layout>-col03 = 'Tipo de documento de compras'.
  <fs_layout>-col04 = 'Nº conta do fornecedor'.
  <fs_layout>-col05 = 'Organização de compras'.
  <fs_layout>-col06 = 'Grupo de compradores'.
  <fs_layout>-col07 = 'Código da moeda'.
  <fs_layout>-col08 = 'Nº Item do documento de compra'.
  <fs_layout>-col09 = 'Texto breve'.
  <fs_layout>-col10 = 'Nº do material'.
  <fs_layout>-col11 = 'Centro'.
  <fs_layout>-col12 = 'Quantidade do pedido'.
  <fs_layout>-col13 = 'Unidade de medida do pedido'.
  <fs_layout>-col14 = 'Preço líquido no documento de compra na moeda do documento'.
  <fs_layout>-col15 = 'Unidade preço'.
  <fs_layout>-col16 = 'Valor líquido do pedido em moeda de pedido'.
  <fs_layout>-col17 = 'Valor do pedido bruto em moeda de pedido'.

  " Popup do explorador de arquivos

  CALL METHOD cl_gui_frontend_services=>file_save_dialog
    EXPORTING
      default_file_name         = 'Layout de Carga de Criação de Pedido de Compras.xls'
      file_filter               = 'Planilha Excel (*.xls)|*.xls|'
    CHANGING
      filename                  = lv_file
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

  " Download do arquivo

  IF lv_fullpath IS NOT INITIAL.

    CALL METHOD cl_gui_frontend_services=>gui_download
      EXPORTING
        filename                = lv_fullpath
        write_field_separator   = 'X'
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
    ENDIF.

  ELSE.
    MESSAGE TEXT-m02 TYPE 'S' DISPLAY LIKE 'E'.
  ENDIF.

ENDFORM.

**********************************************************************
*                         STATUS DE PROGRESSO
**********************************************************************

FORM zf_progresso USING p_percentage p_text.

  CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
    EXPORTING
      percentage = p_percentage
      text       = p_text.

ENDFORM.