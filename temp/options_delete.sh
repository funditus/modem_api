#!/bin/sh

#wget -O - --header "Referer: http://192.168.0.1/index.html" --post-data 'multi_data=1&isTest=false&cmd=wifi_coverage%2Cm_ssid_enable%2Cimei%2Cweb_version%2Cwa_inner_version%2Chardware_version%2CMAX_Access_num%2CSSID1%2Cm_SSID%2Cm_HideSSID%2Cm_MAX_Access_num%2Clan_ipaddr%2Cwan_active_band%2Cmac_address%2Cmsisdn%2CLocalDomain%2Cwan_ipaddr%2Cipv6_wan_ipaddr%2Cipv6%2Cpdp_type%2Cpdp_type%2Cppp_status%2Csim_iccid%2Csim_imsi%2Crmcc%2Crmnc%2Crssi%2Crscp%2Clte_rsrp%2Cecio%2Clte_snr%2Cnetwork_type%2Clte_rssi%2Clac_code%2Ccell_id%2Clte_pci%2Cdns_mode%2Cprefer_dns_manual%2Cstandby_dns_manual%2Cprefer_dns_auto%2Cstandby_dns_auto%2Cipv6_dns_mode%2Cipv6_prefer_dns_manual%2Cipv6_standby_dns_manual%2Cipv6_prefer_dns_auto%2Cipv6_standby_dns_auto%2Cmodel_name' http://192.168.0.1/goform/goform_get_cmd_process 2>/dev/null

echo '"sms_received_flag", "sts_received_flag", "signalbar","network_type", "network_provider",
"ppp_status","EX_SSID1","ex_wifi_status","EX_wifi_profile","m_ssid_enable", 'sms_unread_num', "RadioOff",
"simcard_roam", "lan_ipaddr","station_mac", "battery_charging", "battery_vol_percent", "battery_pers","spn_display_flag","plmn_display_flag","spn_name_data","spn_b1_flag","spn_b2_flag",
"realtime_tx_bytes","realtime_rx_bytes","realtime_time","realtime_tx_thrpt","realtime_rx_thrpt",
"monthly_rx_bytes","monthly_tx_bytes","monthly_time","date_month","data_volume_limit_switch",
"data_volume_limit_size","data_volume_alert_percent","data_volume_limit_unit","roam_setting_option","upg_roam_switch" '
