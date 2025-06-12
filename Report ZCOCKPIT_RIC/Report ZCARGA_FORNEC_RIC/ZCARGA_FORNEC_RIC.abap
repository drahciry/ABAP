**********************************************************************
*                                                                    *
*                        GEOSYSTEM                                   *
*                     WE MAKE IT VALUE                               *
*                                                                    *
**********************************************************************
* Programa : ZCARGA_FORNEC_RIC                                       *
* Cliente  : GEOSYSTEM                                               *
* ID       : 0000000000                                              *
* Módulo   : MM                                                      *
* Transação: N/A                                                     *
* Descrição: Carga de fornecedor                                     *
* Autor    : Richard Gonçalves                                       *
* Data     : 14.04.2025                                              *
**********************************************************************
* Histórico de Alterações:                                           *
**********************************************************************
* Data       |Change #    |Autor      | Alteração                    *
**********************************************************************
* 14.04.2025 | S4HK902148 | RGONCALVES | 0000000000000000000000000   *
*            |            |            |     Carga de fornecedor     *
**********************************************************************

REPORT zcarga_fornec_ric.

**********************************************************************
*                             INCLUDES
**********************************************************************

INCLUDE: zcarga_fornec_rictop, " Top Include
         zcarga_fornec_ricf01, " Lógica de Carga do Programa
         zcarga_fornec_ricf02, " ALV de Preview de Carga
         zcarga_fornec_ricf03, " SHDB
         zcarga_fornec_ricf04, " ALV de Log
         zcarga_fornec_ricf05. " ALV de View de Carga Detalhada (caso preview não seja selecionada)

**********************************************************************
*                          INÍCIO DA LÓGICA
**********************************************************************

START-OF-SELECTION.

  CASE lv_ucomm.
    WHEN 'BTN1'.
      PERFORM zf_layout_download.
    WHEN OTHERS.
      PERFORM zf_main.
  ENDCASE.

END-OF-SELECTION.