
#Calls to get your ip address which can then be used to set rules if access is needed
#We mainly using this if developing the terraform script outside of the private vnet.  On the proper build agent we can turn this
#off with the variable which is used to turn off allowing the build agent an approve rule because the build agent will be on the network

data "http" "ip" {
  url = "https://ifconfig.me"
}

locals {
  build_agent_ip = data.http.ip.body
}