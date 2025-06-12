**********************************************************************
*                                                                    *
*                        GEOSYSTEM                                   *
*                     WE MAKE IT VALUE                               *
*                                                                    *
**********************************************************************
* Programa : ZUPDATERIC                                              *
* Cliente  : GEOSYSTEM                                               *
* ID       : 0000000000                                              *
* Módulo   : N/A                                                     *
* Transação: N/A                                                     *
* Descrição: Atualização da J_1BB2                                   *
* Autor    : Richard Gonçalves                                       *
* Data     : 24.04.2025                                              *
**********************************************************************
* Histórico de Alterações:                                           *
**********************************************************************
* Data       |Change #    |Autor      | Alteração                    *
**********************************************************************
* 24.04.2025 | S4HK902148 | RGONCALVES | 0000000000000000000000000   *
*            |            |            |    Atualização da J_1BB2    *
**********************************************************************

REPORT zupdateric.

**********************************************************************
*                             INCLUDES
**********************************************************************

INCLUDE: zupdateric_top, zupdateric_f01.

**********************************************************************
*                         INÍCIO DA LÓGICA
**********************************************************************

START-OF-SELECTION.
  CASE lv_ucomm.
    WHEN 'BTN1'.
      PERFORM zf_popup.
      IF lv_answer EQ '1'.
        PERFORM: zf_update_dados.
        IF NOT gt_j1bb2 IS INITIAL.
          PERFORM: zf_build_header,
                   zf_build_layout,
                   zf_call_fieldcat,
           	       zf_display_alv.
        ELSE.
          MESSAGE TEXT-M02 TYPE 'I'.
        ENDIF.
      ELSE.
        MESSAGE TEXT-M01 TYPE 'S' DISPLAY LIKE 'E'.
      ENDIF.
  ENDCASE.