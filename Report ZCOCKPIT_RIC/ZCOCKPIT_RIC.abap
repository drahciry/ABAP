**********************************************************************
*                                                                    *
*                        GEOSYSTEM                                   *
*                     WE MAKE IT VALUE                               *
*                                                                    *
**********************************************************************
* Programa : ZCOCKPIT_RIC                                            *
* Cliente  : GEOSYSTEM                                               *
* ID       : 0000000000                                              *
* Módulo   : MM                                                      *
* Transação: N/A                                                     *
* Descrição: Cockpit                                                 *
* Autor    : Richard Gonçalves                                       *
* Data     : 14.04.2025                                              *
**********************************************************************
* Histórico de Alterações:                                           *
**********************************************************************
* Data       |Change #    |Autor      | Alteração                    *
**********************************************************************
* 14.04.2025 | S4HK902148 | RGONCALVES | 0000000000000000000000000   *
*            |            |            |           Cockpit           *
**********************************************************************

REPORT zcockpit_ric.

INCLUDE: zcockpit_rictop.

START-OF-SELECTION.

  CASE lv_ucomm.

    WHEN 'BTN1'.
      SUBMIT zcarga_fornec_ric VIA SELECTION-SCREEN AND RETURN.
    WHEN 'BTN2'.
      SUBMIT zcarga_pc_ric VIA SELECTION-SCREEN AND RETURN.
    WHEN 'BTN3'.
  ENDCASE.