*&---------------------------------------------------------------------*
*& Include          ZRUPDATE002F01
*&---------------------------------------------------------------------*

**********************************************************************
*                       POPUP DE CONFIRMAÇÃO
**********************************************************************

FORM zf_popup.

  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      titlebar       = 'Confirmação'
      text_question  = |Os valores do campo LDEST serão atualizados para 'LOCL'. Deseja continuar?|
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

**********************************************************************
*                           UPDATE NA TABELA
**********************************************************************

FORM zf_update_dados.

  DATA: lv_key        TYPE c,
        lv_count      TYPE i,
        lv_percentage TYPE i,
        lv_text       TYPE string.

  SELECT *
  FROM nach
  INTO TABLE gt_nach_old
  WHERE ldest NE c_locl.

  IF sy-subrc EQ 0.
    DESCRIBE TABLE gt_nach_old LINES lv_qtdreg.

    LOOP AT gt_nach_old ASSIGNING FIELD-SYMBOL(<fs_nach_old>).

      lv_count      = lv_count + 1.
      lv_percentage = ( lv_count / lv_qtdreg ) * 100.
      CONCATENATE 'Atualizando registro:' <fs_nach_old>-knumh INTO lv_text.

      PERFORM zf_progresso USING lv_percentage lv_text.

      APPEND INITIAL LINE TO gt_nach ASSIGNING FIELD-SYMBOL(<fs_nach>).
      MOVE-CORRESPONDING <fs_nach_old> TO <fs_nach>.

      APPEND INITIAL LINE TO gt_log ASSIGNING FIELD-SYMBOL(<fs_log>).

      <fs_log>-knumh = <fs_nach>-knumh.

      UPDATE nach
         SET ldest = c_locl
       WHERE knumh EQ <fs_nach_old>-knumh.

      IF sy-subrc EQ 0.
        <fs_nach>-icone = icon_red_light.
        <fs_nach>-log   = icon_history.
        <fs_log>-msglog = TEXT-L02.
      ELSE.
        <fs_nach>-icone     = icon_green_light.
        <fs_nach>-ldest_new = c_locl.
        <fs_log>-msglog     = TEXT-L01.
        lv_key              = abap_true.
      ENDIF.

    ENDLOOP.

    IF lv_key EQ abap_true.
        COMMIT WORK AND WAIT.
    ELSE.
      ROLLBACK WORK.
    ENDIF.
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