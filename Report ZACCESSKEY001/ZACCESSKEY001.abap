**********************************************************************
*                                                                    *
*                        GEOSYSTEM                                   *
*                     WE MAKE IT VALUE                               *
*                                                                    *
**********************************************************************
* Programa : ZACCESSKEY001                                           *
* Cliente  : GeoSystem                                               *
* ID       : 0000000000                                              *
* Módulo   : SD                                                      *
* Transação: N/A                                                     *
* Descrição: Relatório de notas fiscais                              *
* Autor    : Richard Gonçalves                                       *
* Data     : 08.04.2025                                              *
**********************************************************************
* Histórico de Alterações:                                           *
**********************************************************************
* Data       |Change #    |Autor      | Alteração                    *
**********************************************************************
* 08.04.2025 | S4HK902148 | RGONCALVES | 0000000000000000000000000   *
*            |            |            | Relatório de notas fiscais  *
**********************************************************************

REPORT ZACCESSKEY001 NO STANDARD PAGE HEADING.

**********************************************************************
*                           INCLUDES
**********************************************************************

INCLUDE: ZACCESSKEYTOP, ZACCESSKEYF01.

**********************************************************************
*                        INÍCIO DA LÓGICA
**********************************************************************

START-OF-SELECTION.

PERFORM: zf_fatia_chave,
         zf_seleciona_dados.

IF gt_active IS NOT INITIAL.

  PERFORM: zf_build_return,
           zf_build_header,
           zf_call_layout,
           zf_call_fieldcat,
           zf_display_alv.

ELSE.

  MESSAGE I000(ZMCACCESSKEY).

ENDIF.

END-OF-SELECTION.