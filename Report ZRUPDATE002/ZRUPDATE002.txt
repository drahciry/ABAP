**********************************************************************
*                                                                    *
*                        GEOSYSTEM                                   *
*                     WE MAKE IT VALUE                               *
*                                                                    *
**********************************************************************
* Programa : ZRUPDATE002                                             *
* Cliente  : GEOSYSTEM                                               *
* ID       : 0000000000                                              *
* Módulo   : N/A                                                     *
* Transação: N/A                                                     *
* Descrição: Atualização da NACH                                     *
* Autor    : Richard Gonçalves                                       *
* Data     : 25.04.2025                                              *
**********************************************************************
* Histórico de Alterações:                                           *
**********************************************************************
* Data       |Change #    |Autor      | Alteração                    *
**********************************************************************
* 25.04.2025 | S4HK902148 | RGONCALVES | 0000000000000000000000000   *
*            |            |            |     Atualização da NACH     *
**********************************************************************

REPORT zrupdate002.

**********************************************************************
*                             INCLUDES
**********************************************************************

INCLUDE: zrupdate002top, " Top include
         zrupdate002f01, " Lógica de update
         zrupdate002f02, " ALV dos registros atualizados
         zrupdate002f03. " ALV de log

**********************************************************************
*                         INÍCIO DA LÓGICA
**********************************************************************

START-OF-SELECTION.
  CASE lv_ucomm.
    WHEN 'BTN1'.
      PERFORM zf_popup.
      IF lv_answer EQ '1'.
        PERFORM: zf_update_dados.
        IF NOT gt_nach IS INITIAL.
          PERFORM: zf_build_header,
                   zf_build_layout,
                   zf_call_fieldcat,
           	       zf_display_alv.
        ELSE.
          MESSAGE TEXT-m02 TYPE 'I'.
        ENDIF.
      ELSE.
        MESSAGE TEXT-m01 TYPE 'S' DISPLAY LIKE 'E'.
      ENDIF.
  ENDCASE.