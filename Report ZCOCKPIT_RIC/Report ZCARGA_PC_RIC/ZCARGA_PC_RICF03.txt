*&---------------------------------------------------------------------*
*& Include          ZCARGA_PC_RICF03
*&---------------------------------------------------------------------*

**********************************************************************
*                VERIFICAÇÃO DA CRIAÇÃO DO FORNECEDOR
**********************************************************************

FORM zf_select_lifnr.

  SELECT *
  FROM zloglifnr_ric
  INTO TABLE gt_loglifnr
  FOR ALL ENTRIES IN gt_order
  WHERE lifnr EQ gt_order-lifnr
    AND trans EQ 'ZPIT001'.

  IF sy-subrc EQ 0.
    lv_find = abap_true.
  ENDIF.

ENDFORM.

**********************************************************************
*                 BAPI PARA CRIAR PEDIDO DE COMPRAS
**********************************************************************

FORM zf_bapi CHANGING gt_return TYPE zst_t_bapiret2.

  CALL FUNCTION 'BAPI_PO_CREATE1'
    EXPORTING
      poheader         = gw_headerbapi
      poheaderx        = gw_headerbapix
    IMPORTING
      exppurchaseorder = lv_ebeln
    TABLES
      return           = gt_return
      poitem           = gt_items
      poitemx          = gt_itemsx.

  IF lv_ebeln IS NOT INITIAL.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        wait = abap_true.
  ELSE.
    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
  ENDIF.

ENDFORM.

**********************************************************************
*                   CRIAÇÃO DO PEDIDO DE COMPRAS
**********************************************************************

FORM zf_create_order.

  " Declaração de tabelas internas locais

  DATA: gt_tabix TYPE TABLE OF sy-tabix.

  " Declaração de variáveis locais

  DATA: lv_color      TYPE char4,
        lv_lines      TYPE i,
        lv_count      TYPE i,
        lv_percentage TYPE i,
        lv_text       TYPE string.

  DESCRIBE TABLE gt_order LINES lv_lines.

  LOOP AT gt_order ASSIGNING <fs_order>.

    lv_count      = lv_count + 1.
    lv_percentage = ( lv_count / lv_lines ) * 100.
    lv_text       = 'Criando pedidos de compra...'.

    PERFORM zf_progresso USING lv_percentage lv_text.

    CLEAR gt_return.

    " No primeiro registro do fornecedor, é registrado o cabeçalho do pedido

    AT NEW lifnr.
      IF lv_color EQ 'C110'.
        lv_color = 'C210'.
      ELSE.
        lv_color = 'C110'.
      ENDIF.
      lv_psave  = abap_false.
      CLEAR: gt_tabix, gt_items, gt_itemsx, gw_headerbapi, gw_headerbapix, lv_ebeln.

      " Cabeçalho

      gw_headerbapi-comp_code = <fs_order>-bukrs.
      gw_headerbapi-doc_type  = <fs_order>-bsart.
      gw_headerbapi-vendor    = <fs_order>-lifnr.
      gw_headerbapi-purch_org = <fs_order>-ekorg.
      gw_headerbapi-pur_group = <fs_order>-ekgrp.
      gw_headerbapi-currency  = <fs_order>-waers.

      gw_headerbapix-comp_code = 'X'.
      gw_headerbapix-doc_type  = 'X'.
      gw_headerbapix-vendor    = 'X'.
      gw_headerbapix-purch_org = 'X'.
      gw_headerbapix-pur_group = 'X'.
      gw_headerbapix-currency  = 'X'.
    ENDAT.

    <fs_order>-color = lv_color.
    APPEND sy-tabix TO gt_tabix.

    " Itens do pedido

    APPEND INITIAL LINE TO gt_items ASSIGNING FIELD-SYMBOL(<fs_items>).
    <fs_items>-po_item    = <fs_order>-ebelp.
    <fs_items>-short_text = <fs_order>-txz01.
    <fs_items>-material   = <fs_order>-matnr.
    <fs_items>-plant      = <fs_order>-werks.
    <fs_items>-quantity   = <fs_order>-menge.
    <fs_items>-po_unit    = <fs_order>-meins.
    <fs_items>-net_price  = <fs_order>-netpr.
    <fs_items>-price_unit = <fs_order>-peinh.

    APPEND INITIAL LINE TO gt_itemsx ASSIGNING FIELD-SYMBOL(<fs_itemsx>).
    <fs_itemsx>-po_item    = <fs_order>-ebelp.
    <fs_itemsx>-short_text = 'X'.
    <fs_itemsx>-material   = 'X'.
    <fs_itemsx>-plant      = 'X'.
    <fs_itemsx>-quantity   = 'X'.
    <fs_itemsx>-po_unit    = 'X'.
    <fs_itemsx>-net_price  = 'X'.
    <fs_itemsx>-price_unit = 'X'.

    " No último registro do fornecedor, é realizada a tentativa de carga

    AT END OF lifnr.

      " Verifica se o fornecedor foi criado pela transação ZPIT001

      READ TABLE gt_loglifnr ASSIGNING FIELD-SYMBOL(<fs_loglifnr>) WITH KEY lifnr = <fs_order>-lifnr.
      IF sy-subrc NE 0.
        LOOP AT gt_order ASSIGNING FIELD-SYMBOL(<fs_orderr>) WHERE lifnr = <fs_order>-lifnr.

          <fs_orderr>-icone = icon_red_light.
          <fs_orderr>-inlog = icon_history.
          <fs_orderr>-error = abap_true.

        ENDLOOP.
        APPEND INITIAL LINE TO gt_log ASSIGNING FIELD-SYMBOL(<fs_log>).
        <fs_log>-lifnr    = <fs_order>-lifnr.
        <fs_log>-message  = TEXT-e01.
        CONTINUE.
      ENDIF.
      PERFORM zf_bapi CHANGING gt_return.

      " Após tentativa de carga, verifica se deu sucesso ou erro, e adiciona texto aos objetos de textos

      LOOP AT gt_tabix INTO DATA(lv_tabix).

        READ TABLE gt_order ASSIGNING <fs_orderr> INDEX lv_tabix.
        IF sy-subrc EQ 0 AND lv_ebeln IS NOT INITIAL.
          <fs_orderr>-icone = icon_green_light.

          " Salva texto dos itens

          PERFORM zf_left_zeros USING lv_ebeln CHANGING <fs_orderr>-ebeln.
          CONCATENATE <fs_orderr>-ebeln <fs_orderr>-ebelp INTO DATA(lv_item).
          WHILE strlen( <fs_orderr>-itext ) GT 132.

            APPEND INITIAL LINE TO gt_lines ASSIGNING FIELD-SYMBOL(<fs_lines>).
            <fs_lines>-tdline = <fs_orderr>-itext+0(132).
            <fs_orderr>-itext = <fs_orderr>-itext+132.

          ENDWHILE.
          IF <fs_orderr>-itext IS NOT INITIAL.
            APPEND INITIAL LINE TO gt_lines ASSIGNING <fs_lines>.
            <fs_lines>-tdline = <fs_orderr>-itext.
          ENDIF.
          gw_headertext-tdobject = 'EKPO'.
          gw_headertext-tdname   = lv_item.
          gw_headertext-tdid     = 'F01'.
          gw_headertext-tdspras  = sy-langu.
          PERFORM zf_save_text USING gw_headertext gt_lines.

          " Salva texto do cabeçalho

          IF NOT lv_psave EQ abap_true.
            CLEAR: gw_headertext, gt_lines.
            WHILE strlen( <fs_orderr>-ptext ) GT 132.

              APPEND INITIAL LINE TO gt_lines ASSIGNING <fs_lines>.
              <fs_lines>-tdline = <fs_orderr>-ptext+0(132).
              <fs_orderr>-ptext = <fs_orderr>-ptext+132.

            ENDWHILE.
            IF <fs_orderr>-ptext IS NOT INITIAL.
              APPEND INITIAL LINE TO gt_lines ASSIGNING <fs_lines>.
              <fs_lines>-tdline = <fs_orderr>-ptext.
            ENDIF.
            lv_psave               = abap_true.
            gw_headertext-tdobject = 'EKKO'.
            gw_headertext-tdname   = <fs_orderr>-ebeln.
            gw_headertext-tdid     = 'F01'.
            gw_headertext-tdspras  = sy-langu.
            PERFORM zf_save_text USING gw_headertext gt_lines.
          ENDIF.
          CLEAR: gw_headertext, gt_lines.
        ELSE.
          <fs_orderr>-icone = icon_red_light.
          <fs_orderr>-inlog = icon_history.
          <fs_orderr>-error = abap_true.
          LOOP AT gt_return ASSIGNING FIELD-SYMBOL(<fs_return>).

            APPEND INITIAL LINE TO gt_log ASSIGNING <fs_log>.
            MOVE-CORRESPONDING <fs_return> TO <fs_log>.
            <fs_log>-lifnr = <fs_order>-lifnr.

          ENDLOOP.
        ENDIF.

      ENDLOOP.
      CLEAR gt_return.
    ENDAT.

  ENDLOOP.

ENDFORM.

**********************************************************************
*                       SAVE DO TEXTO NA ME23N
**********************************************************************

FORM zf_save_text CHANGING pw_header TYPE thead
                           pt_lines  TYPE zst_t_tline.

  CALL FUNCTION 'SAVE_TEXT'
    EXPORTING
      header          = pw_header
      insert          = 'X'
      savemode_direct = 'X'
    TABLES
      lines           = pt_lines
    EXCEPTIONS
      id              = 1
      language        = 2
      name            = 3
      object          = 4
      OTHERS          = 5.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
    WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

ENDFORM.

**********************************************************************
*               BAPI PARA EDITAR PEDIDO DE COMPRAS
**********************************************************************

FORM zf_bapi_edit USING p_ebeln CHANGING gt_return TYPE zst_t_bapiret2.

  CALL FUNCTION 'BAPI_PO_CHANGE'
    EXPORTING
      purchaseorder = p_ebeln
      poheader      = gw_headerbapi
      poheaderx     = gw_headerbapix
    TABLES
      return        = gt_return
      poitem        = gt_items
      poitemx       = gt_itemsx.
  READ TABLE gt_return ASSIGNING FIELD-SYMBOL(<fs_return>) WITH KEY type = 'E'.
  IF sy-subrc NE 0.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        wait = abap_true.
  ELSE.
    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
  ENDIF.

ENDFORM.