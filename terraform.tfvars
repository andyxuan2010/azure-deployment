########################################
## this is for sbx environment
########################################
app_env     = "sbx"
app_vnet    = "vnet-ccoe-iac-cc-sbx"
app_vnet_rg = "rg-ccoe-iac-cc-sbx"
app_snet    = "snet-ccoe-iac-cc-sbx"

app_rg                 = "rg-ccoe-aro-cc-sbx"
app_vm                 = "azuwaarotest901"
disksize               = 60
public_network_enabled = true


iac_rg = "rg-ccoe-iac-cc-sbx"
iac_kv = "kv-ccoe-cc-sbx"
iac_st = "stccoeiacccsbx"
# sandbox we don't have AAD or AD groups
# app_remote_group = ["G-CCOE-Admin-F"]
# app_admin_group  = ["G-CCOE-Admin-F"]
# app_ad_group     = "G-CCOE-Admin-F"
# sql_ad_group     = "G-CCOE-Admin-F"
#no more than 8 characters since it will be used as a part of the VM name which has a limit of 15 characters.
#VM name pattern: <azwa><workload><suffix>, where suffix is a 3-digit number

#norally workload is no more than 7 characters, in order to have a 15 characters VM name
workload = "iactest"
#environment = "sbx"

# for managed instance database
app_sqlmi    = "azumisqlgen901"
app_sqlmi_rg = "rg-ba-cc-sbx-sqlmi"
app_sqlmi_db = "sqlmidb-iactest-cc-901"
