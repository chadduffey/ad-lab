resource_prefix = "lab"

# dc's
dc_resource_prefix = "dc"
extra_dc_resource_prefix = "extradc"
extra_dc_node_count = 1
node_location_dc   = "westus2"
vmsize_dc = "Standard_D2s_v3"
active_directory_domain = "jmpesp.xyz"
active_directory_netbios_name = "jmpesp"
domadminuser = "domainadmin"
domadminpassword = "adminP@ssw0rd1234"
safemode_password = "adminP@ssw0rd1234"

# member servers
member_resource_prefix = "server"
node_location_member = "westus2"
vmsize_member = "Standard_D2s_v3"
member_node_count = 2
adminuser = "localadmin"
adminpassword = "localP@ssw0rd12345"

# workstations
ws_resource_prefix = "ws"
node_location_ws = "westus2"
vmsize_ws = "Standard_D2s_v3"
workstation_node_count = 2

tags = {
  "Environment" = "lab"
  "Customer" = "lab"
}