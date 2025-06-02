**********************************************************************
*                                                                    *
*                        GEOSYSTEM                                   *
*                     WE MAKE IT VALUE                               *
*                                                                    *
**********************************************************************
* Programa : ZCARGA_PC_RIC                                           *
* Cliente  : GEOSYSTEM                                               *
* ID       : 0000000000                                              *
* Módulo   : MM                                                      *
* Transação: N/A                                                     *
* Descrição: Carga de pedido de compras                              *
* Autor    : Richard Gonçalves                                       *
* Data     : 13.05.2025                                              *
**********************************************************************
* Histórico de Alterações:                                           *
**********************************************************************
* Data       |Change #    |Autor      | Alteração                    *
**********************************************************************
* 13.05.2025 | S4HK902148 | RGONCALVES | 0000000000000000000000000   *
*            |            |            | Carga de pedido de compras  *
**********************************************************************

REPORT zcarga_pc_ric.

**********************************************************************
*                             INCLUDES
**********************************************************************

INCLUDE: zcarga_pc_rictop, " Include Top
         zcarga_pc_ricf00, " Lógicas da tela de seleção e main
         zcarga_pc_ricf01, " Lógica de carga de criação
         zcarga_pc_ricf02, " Lógica de carga de edição
         zcarga_pc_ricf03, " BAPIs
         zcarga_pc_ricf04, " ALV de view de carga de criação
         zcarga_pc_ricf05, " ALV de log de erro
         zcarga_pc_ricf06, " ALV de view de carga de edição
         zcarga_pc_ricf07. " ALV de log de campos editados

**********************************************************************
*                          INÍCIO DA LÓGICA
**********************************************************************

START-OF-SELECTION.

  CASE lv_ucomm.
    WHEN 'BTN1'.
      PERFORM zf_download_layout_create. " Download do Layout de Criação de Pedido de Compra
    WHEN 'BTN2'.
      PERFORM zf_download_layout_edit. " Download do Layout de Edição de Pedido de Compra
    WHEN OTHERS.
      PERFORM zf_main. " Lógica Principal de Carga
  ENDCASE.

END-OF-SELECTION.