*&---------------------------------------------------------------------*
*& Include          ZCARGA_FORNEC_RICF03
*&---------------------------------------------------------------------*

**********************************************************************
*                     REALIZA CARGA DE FORNECEDOR
**********************************************************************

FORM zf_realiza_carga USING    p_land1
                               p_name1
                               p_ort01
                               p_pstlz
                               p_regio
                               p_stras
                               p_spras
                               p_telf1
                               p_email
                               p_txjcd
                               p_ekorg
                               p_waers
                               p_zterm
                      CHANGING gt_return TYPE zst_t_bapiret2.

  DATA: lv_data   TYPE date,
        lv_street  TYPE string,
        lv_number TYPE string.

  PERFORM zf_format_street USING p_stras CHANGING lv_street lv_number.

  lv_data = |{ sy-datum+6(2) }.{ sy-datum+4(2) }.{ sy-datum(4) }|.

  PERFORM: zf_dynpro USING 'SAPLBUS_LOCATOR'                '3000'.
  PERFORM: zf_field  USING 'BDC_OKCODE'                     '=SCREEN_1000_CRE_ORGA',
           zf_field  USING 'BDC_SUBSCR'                     'SAPLBUS_LOCATOR                         2240SCREEN_3000_RESIZING_AREA',
           zf_field  USING 'BDC_SUBSCR'                     'SAPLBUS_LOCATOR                         3100SCREEN_1010_LEFT_AREA',
           zf_field  USING 'BDC_SUBSCR'                     'SAPLBUS_LOCATOR                         3202SCREEN_3100_TABSTRIP_AREA',
           zf_field  USING 'BDC_CURSOR'                     'BUS_LOCA_SRCH01-SEARCH_TYPE',
           zf_field  USING 'BUS_LOCA_SRCH01-SEARCH_TYPE'    '3',
           zf_field  USING 'BUS_LOCA_SRCH01-SEARCH_ID'      '1',
           zf_field  USING 'BDC_SUBSCR'                     'SAPLBUS_LOCATOR                         3211SCREEN_3200_SEARCH_AREA',
           zf_field  USING 'BDC_SUBSCR'                     'SAPLBUPA_DIALOG_SEARCH                  2100SCREEN_3200_SEARCH_FIELDS_AREA',
           zf_field  USING 'BUS_JOEL_SEARCH-PARTNER_NUMBER' '1000241',
           zf_field  USING 'BDC_SUBSCR'                     'SAPLBUS_LOCATOR                         3240SCREEN_3200_SEARCH_BUTTON_AREA',
           zf_field  USING 'BUS_LOCA_SRCH01-MAXHIT'         '100',
           zf_field  USING 'BDC_SUBSCR'                     'SAPLBUPA_DIALOG_JOEL                    1060SCREEN_3200_RESULT_AREA',
           zf_field  USING 'BDC_SUBSCR'                     'SAPLBUPA_DIALOG_JOEL                    1080SCREEN_1060_RESULT_AREA'.

  PERFORM: zf_dynpro USING 'SAPLBUS_LOCATOR'               '3000'.
  PERFORM: zf_field  USING 'BDC_OKCODE'                    '=SCREEN_1110_CHG_ROLE',
           zf_field  USING 'BDC_SUBSCR'                    'SAPLBUPA_DIALOG_JOEL                    1500SCREEN_1000_HEADER_AREA',
           zf_field  USING 'BUS_JOEL_MAIN-CREATION_GROUP'  'BP02',
           zf_field  USING 'BDC_SUBSCR'                    'SAPLBUPA_DIALOG_JOEL                    1110SCREEN_1100_ROLE_AND_TIME_AREA',
           zf_field  USING 'BDC_CURSOR'                    'BUS_JOEL_MAIN-PARTNER_ROLE',
           zf_field  USING 'BUS_JOEL_MAIN-PARTNER_ROLE'    'FLVN01',
           zf_field  USING 'BUS_JOEL_MAIN-PARTNER_TIMEDEP' '000001'.

  PERFORM: zf_dynpro USING 'SAPLSPO1'  	'0600'.
  PERFORM: zf_field  USING 'BDC_OKCODE' '=OPT1',
           zf_field  USING 'BDC_SUBSCR' 'SAPLSPO1                                0601SUBSCREEN'.

  PERFORM: zf_dynpro USING 'SAPLBUS_LOCATOR'               '3000'.
  PERFORM: zf_field  USING 'BDC_OKCODE'                    '=BUS_MAIN_ENTER',
           zf_field  USING 'BDC_SUBSCR'                    'SAPLBUS_LOCATOR                         2000SCREEN_3000_RESIZING_AREA',
           zf_field  USING 'BDC_SUBSCR'                    'SAPLBUPA_DIALOG_JOEL                    1000SCREEN_1010_RIGHT_AREA',
           zf_field  USING 'BDC_SUBSCR'                    'SAPLBUPA_DIALOG_JOEL                    1500SCREEN_1000_HEADER_AREA',
           zf_field  USING 'BUS_JOEL_MAIN-CREATION_GROUP'  'BP02',
           zf_field  USING 'BDC_SUBSCR'                    'SAPLBUPA_DIALOG_JOEL                    1100SCREEN_1000_WORKAREA_AREA',
           zf_field  USING 'BDC_SUBSCR'                    'SAPLBUPA_DIALOG_JOEL                    1110SCREEN_1100_ROLE_AND_TIME_AREA',
           zf_field  USING 'BUS_JOEL_MAIN-PARTNER_ROLE'    'FLVN01',
           zf_field  USING 'BUS_JOEL_MAIN-PARTNER_TIMEDEP' '000001',
           zf_field  USING 'BDC_SUBSCR'                    'SAPLBUPA_DIALOG_JOEL                    1130SCREEN_1110_TIME_AREA',
           zf_field  USING 'BDC_SUBSCR'                    'SAPLBUPA_DIALOG_JOEL                    1101SCREEN_1100_MAIN_AREA',
           zf_field  USING 'BDC_SUBSCR'                    'SAPLBUSS                                0028SCREEN_1100_TABSTRIP_AREA',
           zf_field  USING 'BDC_SUBSCR'                    'SAPLBUSS                                7016GENSUB',
           zf_field  USING 'BDC_SUBSCR'                    'SAPLBUD0                                1130A02P01',
           zf_field  USING 'BUS000FLDS-TITLE_MEDI'         '0003',
           zf_field  USING 'BDC_SUBSCR'                    'SAPLBUD0',
           zf_field  USING 'BUT000-NAME_ORG1'              p_name1,
           zf_field  USING 'BDC_SUBSCR'                    'SAPLBUD0                                1301A02P03',
           zf_field  USING 'BDC_SUBSCR'                    'SAPLBUD0                                1301A02P04',
           zf_field  USING 'BDC_SUBSCR'                    'SAPLBUD0                                1301A02P05',
           zf_field  USING 'BDC_SUBSCR'                    'SAPLBUD0                                1301A02P06',
           zf_field  USING 'BDC_SUBSCR'                    'SAPLBUD0                                1301A02P07',
           zf_field  USING 'BDC_SUBSCR'                    'SAPLBUD0                                1301A02P08',
           zf_field  USING 'BDC_SUBSCR'                    'SAPLBUD0                                1301A02P09',
           zf_field  USING 'BDC_SUBSCR'                    'SAPLFS_BP_BDT_FS_ATTRIBUTES             0110A02P10',
           zf_field  USING 'BDC_SUBSCR'                    'SAPLBUD0                                1110A03P01',
           zf_field  USING 'BDC_SUBSCR'                    'SAPLFS_BP_BDT_FS_ATTRIBUTES             0130A04P01',
           zf_field  USING 'BDC_SUBSCR'                    'SAPLBUA0                                0400A05P01',
           zf_field  USING 'BDC_SUBSCR'                    'SAPLSZA1                                0300ADDRESS',
           zf_field  USING 'BDC_SUBSCR'                    'SAPLSZA1                                0301COUNTRY_SCREEN',
           zf_field  USING 'BDC_CURSOR'                    'SZA1_D0100-SMTP_ADDR',
           zf_field  USING 'ADDR1_DATA-STREET'             lv_street,
           zf_field  USING 'ADDR1_DATA-HOUSE_NUM1'         lv_number,
           zf_field  USING 'ADDR1_DATA-POST_CODE1'         p_pstlz,
           zf_field  USING 'ADDR1_DATA-CITY1'              p_ort01,
           zf_field  USING 'ADDR1_DATA-COUNTRY'            p_land1,
           zf_field  USING 'ADDR1_DATA-REGION'             p_regio,
           zf_field  USING 'ADDR1_DATA-LANGU'              p_spras,
           zf_field  USING 'SZA1_D0100-MOB_NUMBER'         p_telf1,
           zf_field  USING 'SZA1_D0100-SMTP_ADDR'          p_email,
           zf_field  USING 'BDC_SUBSCR'                    'SAPLSZA1                                1300APPL_SUB_T',
           zf_field  USING 'BDC_SUBSCR'                    'SAPLSEXM                                0200APPL_SUB',
           zf_field  USING 'BDC_SUBSCR'                    'SAPLBUA0                                0310A05P02',
           zf_field  USING 'BDC_SUBSCR'                    'SAPLBUA0                                0300A05P03',
           zf_field  USING 'BDC_SUBSCR'                    'SAPLBUA0                                0700A06P01',
           zf_field  USING 'BDC_SUBSCR'                    'SAPLSZA11                               0100ADDR_ICOMM'.

  PERFORM: zf_dynpro USING 'SAPLBUS_LOCATOR'               '3000'.
  PERFORM: zf_field  USING 'BDC_OKCODE'	                   '=SCREEN_1100_TAB_08',
           zf_field  USING 'BDC_SUBSCR'	                   'SAPLBUS_LOCATOR                         2000SCREEN_3000_RESIZING_AREA',
           zf_field  USING 'BDC_SUBSCR'	                   'SAPLBUPA_DIALOG_JOEL                    1000SCREEN_1010_RIGHT_AREA',
           zf_field  USING 'BDC_SUBSCR'	                   'SAPLBUPA_DIALOG_JOEL                    1500SCREEN_1000_HEADER_AREA',
           zf_field  USING 'BUS_JOEL_MAIN-CREATION_GROUP'  'BP02',
           zf_field  USING 'BDC_SUBSCR'	                   'SAPLBUPA_DIALOG_JOEL                    1100SCREEN_1000_WORKAREA_AREA',
           zf_field  USING 'BDC_SUBSCR'	                   'SAPLBUPA_DIALOG_JOEL                    1110SCREEN_1100_ROLE_AND_TIME_AREA',
           zf_field  USING 'BUS_JOEL_MAIN-PARTNER_ROLE'	   'FLVN01',
           zf_field  USING 'BUS_JOEL_MAIN-PARTNER_TIMEDEP' '000001',
           zf_field  USING 'BDC_SUBSCR'	                   'SAPLBUPA_DIALOG_JOEL                    1130SCREEN_1110_TIME_AREA',
           zf_field  USING 'BDC_SUBSCR'	                   'SAPLBUPA_DIALOG_JOEL                    1101SCREEN_1100_MAIN_AREA',
           zf_field  USING 'BDC_SUBSCR'	                   'SAPLBUSS                                0028SCREEN_1100_TABSTRIP_AREA',
           zf_field  USING 'BDC_SUBSCR'	                   'SAPLBUSS                                7016GENSUB',
           zf_field  USING 'BDC_SUBSCR'	                   'SAPLBUD0                                1130A02P01',
           zf_field  USING 'BUS000FLDS-TITLE_MEDI'         '0003',
           zf_field  USING 'BDC_SUBSCR'	                   'SAPLBUD0                                1200A02P02',
           zf_field  USING 'BUT000-NAME_ORG1'	             p_name1,
           zf_field  USING 'BDC_SUBSCR'	                   'SAPLBUD0                                1301A02P03',
           zf_field  USING 'BDC_SUBSCR'	                   'SAPLBUD0                                1302A02P04',
           zf_field  USING 'BDC_SUBSCR'	                   'SAPLBUD0                                1300A02P05',
           zf_field  USING 'BDC_SUBSCR'	                   'SAPLBUD0                                1400A02P06',
           zf_field  USING 'BDC_SUBSCR'	                   'SAPLBUD0                                1360A02P07',
           zf_field  USING 'BDC_SUBSCR'	                   'SAPLBUD0                                1135A02P08',
           zf_field  USING 'BDC_SUBSCR'	                   'SAPLBUD0                                1140A02P09',
           zf_field  USING 'BDC_SUBSCR'	                   'SAPLFS_BP_BDT_FS_ATTRIBUTES             0110A02P10',
           zf_field  USING 'BDC_SUBSCR'	                   'SAPLBUD0                                1110A03P01',
           zf_field  USING 'BDC_SUBSCR'	                   'SAPLFS_BP_BDT_FS_ATTRIBUTES             0130A04P01',
           zf_field  USING 'BDC_SUBSCR'	                   'SAPLBUA0                                0400A05P01',
           zf_field  USING 'BDC_SUBSCR'	                   'SAPLSZA1                                0300ADDRESS',
           zf_field  USING 'BDC_SUBSCR'	                   'SAPLSZA1                                0301COUNTRY_SCREEN',
           zf_field  USING 'ADDR1_DATA-STREET'             lv_street,
           zf_field  USING 'ADDR1_DATA-HOUSE_NUM1'         lv_number,
           zf_field  USING 'ADDR1_DATA-POST_CODE1'         p_pstlz,
           zf_field  USING 'ADDR1_DATA-CITY1'            	 p_ort01,
           zf_field  USING 'ADDR1_DATA-COUNTRY'            p_land1,
           zf_field  USING 'ADDR1_DATA-REGION'             p_regio,
           zf_field  USING 'ADDR1_DATA-TIME_ZONE'	         'BRZLEA',
           zf_field  USING 'ADDR1_DATA-TAXJURCODE'         p_txjcd,
           zf_field  USING 'ADDR1_DATA-LANGU'	             p_spras,
           zf_field  USING 'SZA1_D0100-MOB_NUMBER'         p_telf1,
           zf_field  USING 'SZA1_D0100-SMTP_ADDR'	         p_email,
           zf_field  USING 'BDC_SUBSCR'	                   'SAPLSZA1                                1300APPL_SUB_T',
           zf_field  USING 'BDC_SUBSCR'	                   'SAPLSEXM                                0200APPL_SUB',
           zf_field  USING 'BDC_SUBSCR'	                   'SAPLBUA0                                0310A05P02',
           zf_field  USING 'BUS000FLDS-ADDR_VALID_FROM'	   lv_data,
           zf_field  USING 'BUS000FLDS-ADDR_VALID_TO'	     '31.12.9999',
           zf_field  USING 'BDC_SUBSCR'	                   'SAPLBUA0                                0300A05P03',
           zf_field  USING 'BDC_SUBSCR'                    'SAPLBUA0                                0700A06P01',
           zf_field  USING 'BDC_SUBSCR'	                   'SAPLSZA11                               0100ADDR_ICOMM',
           zf_field  USING 'BDC_CURSOR'	                   'SZA11_0100-SMTP_ADDR'.

  PERFORM: zf_dynpro USING 'SAPLBUS_LOCATOR'                '3000'.
  PERFORM: zf_field  USING 'BDC_OKCODE'	                    '=SCREEN_1000_MAIN_P02',
           zf_field  USING 'BDC_SUBSCR'	                    'SAPLBUS_LOCATOR                         2000SCREEN_3000_RESIZING_AREA',
           zf_field  USING 'BDC_SUBSCR'	                    'SAPLBUPA_DIALOG_JOEL                    1000SCREEN_1010_RIGHT_AREA',
           zf_field  USING 'BDC_SUBSCR'	                    'SAPLBUPA_DIALOG_JOEL                    1500SCREEN_1000_HEADER_AREA',
           zf_field  USING 'BUS_JOEL_MAIN-CREATION_GROUP'	  'BP02',
           zf_field  USING 'BDC_SUBSCR'	                    'SAPLBUPA_DIALOG_JOEL                    1100SCREEN_1000_WORKAREA_AREA',
           zf_field  USING 'BDC_SUBSCR'	                    'SAPLBUPA_DIALOG_JOEL                    1110SCREEN_1100_ROLE_AND_TIME_AREA',
           zf_field  USING 'BUS_JOEL_MAIN-PARTNER_ROLE'	    'FLVN01',
           zf_field  USING 'BUS_JOEL_MAIN-PARTNER_TIMEDEP'  '000001',
           zf_field  USING 'BDC_SUBSCR'	                    'SAPLBUPA_DIALOG_JOEL                    1130SCREEN_1110_TIME_AREA',
           zf_field  USING 'BDC_SUBSCR'	                    'SAPLBUPA_DIALOG_JOEL                    1101SCREEN_1100_MAIN_AREA',
           zf_field  USING 'BDC_SUBSCR'	                    'SAPLBUSS                                0028SCREEN_1100_TABSTRIP_AREA',
           zf_field  USING 'BDC_SUBSCR'	                    'SAPLBUSS                                7019GENSUB',
           zf_field  USING 'BDC_SUBSCR'	                    'SAPLCVI_FS_UI_VENDOR                    0021A02P01',
           zf_field  USING 'BDC_SUBSCR'	                    'SAPLCVI_FS_UI_VENDOR                    0020A03P01',
           zf_field  USING 'BDC_SUBSCR'	                    'SAPLCVI_FS_UI_VENDOR                    0001A04P01',
           zf_field  USING 'BDC_CURSOR'	                    'GS_LFA1-KUNNR',
           zf_field  USING 'BDC_SUBSCR'	                    'SAPLCVI_FS_UI_VENDOR_ENH                0013A05P01',
           zf_field  USING 'BDC_SUBSCR'	                    'SAPLCVI_FS_UI_VENDOR_ENH                0034A05P02',
           zf_field  USING 'BDC_SUBSCR'	                    'SAPLCVI_FS_UI_VENDOR_ENH                0014A05P03',
           zf_field  USING 'BDC_SUBSCR'	                    'SAPLCVI_FS_UI_VENDOR_ENH                0042A05P04',
           zf_field  USING 'BDC_SUBSCR'	                    'SAPLCVI_FS_UI_VENDOR                    0007A06P01',
           zf_field  USING 'BDC_SUBSCR'	                    'SAPLCVI_FS_UI_VENDOR                    0008A06P02',
           zf_field  USING 'BDC_SUBSCR'	                    'SAPLCVI_FS_UI_VENDOR                    0019A06P03',
           zf_field  USING 'BDC_SUBSCR'	                    'SAPLCVI_FS_UI_VENDOR                    0017A07P01',
           zf_field  USING 'BDC_SUBSCR'	                    'SAPLCVI_FS_UI_VENDOR_ENH                0002A08P01',
           zf_field  USING 'BDC_SUBSCR'	                    'SAPLCVI_FS_UI_VENDOR_ENH                0046A08P02',
           zf_field  USING 'BDC_SUBSCR'	                    'SAPLCVI_FS_UI_VENDOR_ENH                0056A09P01',
           zf_field  USING 'BDC_SUBSCR'	                    'SAPLBUSS                                0003A09P02',
           zf_field  USING 'BDC_SUBSCR'	                    'SAPLCVI_FS_UI_VENDOR_ENH                0059A09P03',
           zf_field  USING 'BDC_SUBSCR'	                    'SAPLCVI_FS_UI_VENDOR_ENH                0045A10P01'.

  PERFORM: zf_dynpro USING 'SAPLBUS_LOCATOR'               '3000'.
  PERFORM: zf_field  USING 'BDC_OKCODE'	                   '=BUS_MAIN_ENTER',
           zf_field  USING 'BDC_SUBSCR'	                   'SAPLBUPA_DIALOG_JOEL                    1500SCREEN_1000_HEADER_AREA',
           zf_field  USING 'BUS_JOEL_MAIN-CREATION_GROUP'	 'BP02',
           zf_field  USING 'BDC_SUBSCR'	                   'SAPLBUPA_DIALOG_JOEL                    1110SCREEN_1100_ROLE_AND_TIME_AREA',
           zf_field  USING 'BUS_JOEL_MAIN-PARTNER_ROLE'	   'FLVN01',
           zf_field  USING 'BUS_JOEL_MAIN-PARTNER_TIMEDEP' '000001',
           zf_field  USING 'BDC_SUBSCR'	                   'SAPLCVI_FS_UI_VENDOR_PORG               0070SCREEN_1100_SUB_HEADER_AREA',
           zf_field  USING 'BDC_CURSOR'	                   'GV_PURCHASING_ORG',
           zf_field  USING 'GV_PURCHASING_ORG'              p_ekorg.

  PERFORM: zf_dynpro USING 'SAPLBUS_LOCATOR'               '3000'.
  PERFORM: zf_field  USING 'BDC_OKCODE'	                   '=BUS_MAIN_ENTER',
           zf_field  USING 'BDC_SUBSCR'	                   'SAPLBUPA_DIALOG_JOEL                    1500SCREEN_1000_HEADER_AREA',
           zf_field  USING 'BUS_JOEL_MAIN-CREATION_GROUP'	 'BP02',
           zf_field  USING 'BDC_SUBSCR'	                   'SAPLBUPA_DIALOG_JOEL                    1110SCREEN_1100_ROLE_AND_TIME_AREA',
           zf_field  USING 'BUS_JOEL_MAIN-PARTNER_ROLE'	   'FLVN01',
           zf_field  USING 'BUS_JOEL_MAIN-PARTNER_TIMEDEP' '000001',
           zf_field  USING 'BDC_SUBSCR'	                   'SAPLCVI_FS_UI_VENDOR_PORG               0076A02P01',
           zf_field  USING 'GS_LFM1-WAERS'                 p_waers,
           zf_field  USING 'BDC_SUBSCR'	                   'SAPLCVI_FS_UI_VENDOR_PORG               0086A02P02',
           zf_field  USING 'BDC_CURSOR'	                   'GS_LFM1-ZTERM',
           zf_field  USING 'GS_LFM1-ZTERM'                 p_zterm.

  PERFORM: zf_dynpro USING 'SAPLBUS_LOCATOR'               '3000'.
  PERFORM: zf_field  USING 'BDC_OKCODE'	                   '=BUS_MAIN_SAVE',
           zf_field  USING 'BDC_SUBSCR'	                   'SAPLBUPA_DIALOG_JOEL                    1500SCREEN_1000_HEADER_AREA',
           zf_field  USING 'BUS_JOEL_MAIN-CREATION_GROUP'	 'BP02',
           zf_field  USING 'BDC_SUBSCR'	                   'SAPLBUPA_DIALOG_JOEL                    1110SCREEN_1100_ROLE_AND_TIME_AREA',
           zf_field  USING 'BUS_JOEL_MAIN-PARTNER_ROLE'	   'FLVN01',
           zf_field  USING 'BUS_JOEL_MAIN-PARTNER_TIMEDEP' '000001',
           zf_field  USING 'BDC_SUBSCR'	                   'SAPLCVI_FS_UI_VENDOR_PORG               0076A02P01',
           zf_field  USING 'GS_LFM1-WAERS'                 p_waers,
           zf_field  USING 'BDC_SUBSCR'	                   'SAPLCVI_FS_UI_VENDOR_PORG               0086A02P02',
           zf_field  USING 'BDC_CURSOR'	                   'GS_LFM1-ZTERM',
           zf_field  USING 'GS_LFM1-ZTERM'                 p_zterm.

  PERFORM: zf_dynpro USING 'SAPLBUS_LOCATOR'               '3000'.
  PERFORM: zf_field  USING 'BDC_OKCODE'	                   '=BUS_MAIN_BACK',
           zf_field  USING 'BDC_SUBSCR'	                   'SAPLBUPA_DIALOG_JOEL                    1110SCREEN_1100_ROLE_AND_TIME_AREA',
           zf_field  USING 'BUS_JOEL_MAIN-PARTNER_ROLE'	   'FLVN01',
           zf_field  USING 'BUS_JOEL_MAIN-PARTNER_TIMEDEP' '000001',
           zf_field  USING 'BDC_SUBSCR'	                   'SAPLCVI_FS_UI_VENDOR_PORG               0076A02P01',
           zf_field  USING 'BDC_CURSOR'	                   'GS_LFM1-WAERS'.

  opt_param-dismode  = 'N'.
  opt_param-updmode  = 'S'.
  opt_param-racommit = abap_true.

  CALL TRANSACTION 'BP' USING gt_bdc
                        OPTIONS FROM opt_param
                        MESSAGES INTO gt_message.

  CALL FUNCTION 'CONVERT_BDCMSGCOLL_TO_BAPIRET2'
    TABLES
      imt_bdcmsgcoll = gt_message
      ext_return     = gt_return.

  CLEAR: gt_bdc, gt_message.

ENDFORM.

**********************************************************************
*                                 DYNPRO
**********************************************************************

FORM zf_dynpro USING p_program p_dynpro.

  gw_bdc-program  = p_program.
  gw_bdc-dynpro   = p_dynpro.
  gw_bdc-dynbegin = abap_true.
  APPEND gw_bdc TO gt_bdc.
  CLEAR gw_bdc.

ENDFORM.

**********************************************************************
*                                CAMPOS
**********************************************************************

FORM zf_field USING p_name p_value.

  gw_bdc-fnam = p_name.
  gw_bdc-fval = p_value.
  APPEND gw_bdc TO gt_bdc.
  CLEAR gw_bdc.

ENDFORM.

**********************************************************************
*                        FORMATAÇÃO DO ENDEREÇO
**********************************************************************

FORM zf_format_street USING p_stras CHANGING ch_street ch_number.

  DATA: lv_len TYPE i.

  lv_len = strlen( p_stras ) - 1.
  DO.
    IF p_stras+lv_len(1) EQ space.
      ch_street = p_stras(lv_len).
      ch_number = p_stras+lv_len.
      CONDENSE ch_number NO-GAPS.
      EXIT.
    ENDIF.
    lv_len = lv_len - 1.
    IF lv_len LT 0.
      EXIT.
    ENDIF.
  ENDDO.

ENDFORM.