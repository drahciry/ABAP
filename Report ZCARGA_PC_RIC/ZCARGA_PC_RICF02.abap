*&---------------------------------------------------------------------*
*& Include          ZCARGA_PC_RICF02
*&---------------------------------------------------------------------*

**********************************************************************
*                  PROCESSAMENTO DE CSV - EDIÇÃO
**********************************************************************

FORM zf_process_data_csv_edit.

  " Declaração de variáveis locais

  DATA: lv_column     TYPE i,
        lv_lines      TYPE i,
        lv_count2     TYPE i,
        lv_percentage TYPE i,
        lv_text       TYPE string.

  DESCRIBE TABLE gt_file LINES lv_lines.

  LOOP AT gt_file ASSIGNING FIELD-SYMBOL(<fs_file>).

    lv_count2     = lv_count2 + 1.
    lv_percentage = ( lv_count2 / lv_lines ) * 100.
    lv_text       = 'Editando pedidos de compras...'.

    PERFORM zf_progresso USING lv_percentage lv_text.

    " Remove tabulação, caso exista

    FIND FIRST OCCURRENCE OF cl_abap_char_utilities=>horizontal_tab IN <fs_file>.
    IF sy-subrc EQ 0.
      REPLACE ALL OCCURRENCES OF cl_abap_char_utilities=>horizontal_tab IN <fs_file> WITH ';'.
    ENDIF.

    " Captura o nome dos campos da BAPI

    IF sy-tabix EQ 1.
      REPLACE ALL OCCURRENCES OF ')' IN <fs_file> WITH space.
      FIND ALL OCCURRENCES OF ';' IN <fs_file> MATCH COUNT DATA(lv_count).
      DO lv_count TIMES.
        lv_column = lv_column + 1.
        APPEND INITIAL LINE TO gt_poscol ASSIGNING FIELD-SYMBOL(<fs_poscol>).
        SPLIT <fs_file> AT ';' INTO <fs_poscol>-colnam <fs_file>.
        <fs_poscol>-poscol = lv_column.
        FIND FIRST OCCURRENCE OF '(' IN <fs_poscol>-colnam MATCH OFFSET DATA(lv_offset).
        IF sy-subrc EQ 0.
          lv_offset = lv_offset + 1.
          <fs_poscol>-colnam = <fs_poscol>-colnam+lv_offset.
        ENDIF.
      ENDDO.
      IF <fs_file> IS NOT INITIAL.
        lv_column = lv_column + 1.
        APPEND INITIAL LINE TO gt_poscol ASSIGNING <fs_poscol>.
        <fs_poscol>-poscol = lv_column.
        <fs_poscol>-colnam = <fs_file>.
        FIND FIRST OCCURRENCE OF '(' IN <fs_poscol>-colnam MATCH OFFSET lv_offset.
        IF sy-subrc EQ 0.
          lv_offset = lv_offset + 1.
          <fs_poscol>-colnam = <fs_poscol>-colnam+lv_offset.
        ENDIF.
      ENDIF.
      CONTINUE.
    ENDIF.

    APPEND INITIAL LINE TO gt_order ASSIGNING <fs_order>.
    APPEND INITIAL LINE TO gt_items ASSIGNING FIELD-SYMBOL(<fs_items>).
    APPEND INITIAL LINE TO gt_itemsx ASSIGNING FIELD-SYMBOL(<fs_itemsx>).

    " Captura os valores para os campos da BAPI de forma dinâmica

    LOOP AT gt_poscol ASSIGNING <fs_poscol>.

      SPLIT <fs_file> AT ';' INTO DATA(lv_value) <fs_file>.
      IF lv_value IS INITIAL.
        CONTINUE.
      ENDIF.
      IF sy-tabix EQ 1.
        <fs_order>-ebeln = lv_value.
      ELSEIF sy-tabix EQ 2.
        <fs_order>-ebelp = lv_value.
      ENDIF.
      ASSIGN COMPONENT <fs_poscol>-colnam OF STRUCTURE gw_headerbapi TO FIELD-SYMBOL(<fs_field>).
      IF sy-subrc EQ 0.
        <fs_field> = lv_value.
        ASSIGN COMPONENT <fs_poscol>-colnam OF STRUCTURE gw_headerbapix TO <fs_field>.
        <fs_field> = 'X'.
      ENDIF.
      ASSIGN COMPONENT <fs_poscol>-colnam OF STRUCTURE <fs_items> TO <fs_field>.
      IF sy-subrc EQ 0.
        <fs_field> = lv_value.
        ASSIGN COMPONENT <fs_poscol>-colnam OF STRUCTURE <fs_itemsx> TO <fs_field>.
        IF <fs_poscol>-colnam EQ 'PO_ITEM'.
          <fs_field> = lv_value.
        ELSE.
          <fs_field> = 'X'.
        ENDIF.
      ENDIF.

    ENDLOOP.

    " Realiza a atualização da linha

    PERFORM zf_bapi_edit USING gw_headerbapi-po_number CHANGING gt_return.
    READ TABLE gt_return ASSIGNING FIELD-SYMBOL(<fs_return>) WITH KEY type = 'E'.
    IF sy-subrc EQ 0.
      <fs_order>-icone = icon_red_light.
      <fs_order>-inlog = icon_history.
      <fs_order>-error = abap_true.
      LOOP AT gt_return ASSIGNING <fs_return>.

        APPEND INITIAL LINE TO gt_log ASSIGNING FIELD-SYMBOL(<fs_log>).
        MOVE-CORRESPONDING <fs_return> TO <fs_log>.
        MOVE-CORRESPONDING <fs_order> TO <fs_log>.

      ENDLOOP.
    ELSE.
      <fs_order>-icone = icon_green_light.
    ENDIF.
    CLEAR: gw_headerbapi, gw_headerbapix, gt_items, gt_itemsx, gt_return.

  ENDLOOP.

ENDFORM.

**********************************************************************
*                 PROCESSAMENTO DE EXCEL - EDIÇÃO
**********************************************************************

FORM zf_process_data_excel_edit.

  DATA: lv_lines      TYPE i,
        lv_count      TYPE i,
        lv_percentage TYPE i,
        lv_text       TYPE string.

  LOOP AT gt_excel ASSIGNING FIELD-SYMBOL(<fs_excel>).

    lv_count      = lv_count + 1.
    lv_percentage = ( lv_count / lv_lines ) * 100.
    lv_text       = 'Editando pedidos de compras...'.

    PERFORM zf_progresso USING lv_percentage lv_text.

    " Salva o nome dos campos da BAPI

    IF <fs_excel>-row EQ 1.
      APPEND INITIAL LINE TO gt_poscol ASSIGNING FIELD-SYMBOL(<fs_poscol>).
      <fs_poscol>-poscol = <fs_excel>-col.
      <fs_poscol>-colnam = <fs_excel>-value.
      FIND FIRST OCCURRENCE OF '(' IN <fs_poscol>-colnam MATCH OFFSET DATA(lv_offset).
      IF sy-subrc EQ 0.
        lv_offset = lv_offset + 1.
        <fs_poscol>-colnam = <fs_poscol>-colnam+lv_offset.
        REPLACE ALL OCCURRENCES OF ')' IN <fs_poscol>-colnam WITH space.
      ENDIF.
      CONTINUE.
    ENDIF.

    AT NEW row.
      APPEND INITIAL LINE TO gt_order ASSIGNING <fs_order>.
      APPEND INITIAL LINE TO gt_items ASSIGNING FIELD-SYMBOL(<fs_items>).
      APPEND INITIAL LINE TO gt_itemsx ASSIGNING FIELD-SYMBOL(<fs_itemsx>).
    ENDAT.

    " Captura os valores para os campos da BAPI de forma dinâmica

    READ TABLE gt_poscol ASSIGNING <fs_poscol> WITH KEY poscol = <fs_excel>-col.
    IF sy-subrc EQ 0.
      IF <fs_excel>-col EQ 1.
        <fs_order>-ebeln = <fs_excel>-value.
      ELSEIF <fs_excel>-col EQ 2.
        <fs_order>-ebelp = <fs_excel>-value.
      ENDIF.
      ASSIGN COMPONENT <fs_poscol>-colnam OF STRUCTURE gw_headerbapi TO FIELD-SYMBOL(<fs_field>).
      IF sy-subrc EQ 0.
        <fs_field> = <fs_excel>-value.
        ASSIGN COMPONENT <fs_poscol>-colnam OF STRUCTURE gw_headerbapix TO <fs_field>.
        <fs_field> = 'X'.
      ENDIF.
      ASSIGN COMPONENT <fs_poscol>-colnam OF STRUCTURE <fs_items> TO <fs_field>.
      IF sy-subrc EQ 0.
        <fs_field> = <fs_excel>-value.
        ASSIGN COMPONENT <fs_poscol>-colnam OF STRUCTURE <fs_itemsx> TO <fs_field>.
        IF <fs_poscol>-colnam EQ 'PO_ITEM'.
          <fs_field> = <fs_excel>-value.
        ELSE.
          <fs_field> = 'X'.
        ENDIF.
      ENDIF.
    ENDIF.

    " Realiza a atualização da linha

    AT END OF row.
      PERFORM zf_bapi_edit USING gw_headerbapi-po_number CHANGING gt_return.
      READ TABLE gt_return ASSIGNING FIELD-SYMBOL(<fs_return>) WITH KEY type = 'E'.
      IF sy-subrc EQ 0.
        <fs_order>-icone = icon_red_light.
        <fs_order>-inlog = icon_history.
        <fs_order>-error = abap_true.
        LOOP AT gt_return ASSIGNING <fs_return>.

          APPEND INITIAL LINE TO gt_log ASSIGNING FIELD-SYMBOL(<fs_log>).
          MOVE-CORRESPONDING <fs_return> TO <fs_log>.
          MOVE-CORRESPONDING <fs_order> TO <fs_log>.

        ENDLOOP.
      ELSE.
        <fs_order>-icone = icon_green_light.
      ENDIF.
      CLEAR: gt_items, gt_itemsx, gw_headerbapi, gw_headerbapix, gt_return.
    ENDAT.

  ENDLOOP.

ENDFORM.

**********************************************************************
*            DOWNLOAD DE LAYOUT DE CARGA - CRIAÇÃO DE PEDIDO
**********************************************************************

FORM zf_download_layout_edit.

  " Estruturas locais

  TYPES: BEGIN OF ty_layout,
           col01 TYPE string, " Nº do Pedido de Compras (PO_NUMBER)
           col02 TYPE string, " Nº do Item do Pedido (PO_ITEM)
           col03 TYPE string, " Campo exemplo 1 (NOME TÉCNICO)
           col04 TYPE string, " Campo exemplo 2 (NOME TÉCNICO)
         END OF ty_layout.

  " Declaração de variáveis locais

  DATA: lv_file     TYPE string,
        lv_path     TYPE string,
        lv_fullpath TYPE string.

  " Declaração de tabelas internas locais

  DATA: gt_layout TYPE TABLE OF ty_layout.

  APPEND INITIAL LINE TO gt_layout ASSIGNING FIELD-SYMBOL(<fs_layout>).
  <fs_layout>-col01 = 'Nº do Pedido de Compras (PO_NUMBER)'.
  <fs_layout>-col02 = 'Nº do Item do Pedido (PO_ITEM)'.
  <fs_layout>-col03 = 'Moeda (CURRENCY)'.
  <fs_layout>-col04 = 'Qual campo quiser/quantos quiser'.

  " Popup do explorador de arquivos

  CALL METHOD cl_gui_frontend_services=>file_save_dialog
    EXPORTING
      default_file_name         = 'Layout de Carga de Edição de Pedido de Compras.xls'
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