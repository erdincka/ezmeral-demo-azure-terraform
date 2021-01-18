# Azure Subscription and Service Principle for azurerm provider https://docs.microsoft.com/en-us/azure/developer/terraform/get-started-cloud-shell
subscription_id = ""
client_id       = ""
client_secret   = ""
tenant_id       = ""

#
# Select an appropriate region
#
region = "eastus2"

#
# Set this to something meaningful.  it is used as a tag in Azure
#
project_id         = "ecp-demo"
user               = "centos"

# you may need to change the instance types if
# the defaults are not available in your region

# ctr_instance_type  = ""
# gtw_instance_type  = ""
# wkr_instance_type  = ""
# rdp_instance_type   = ""
# mapr_instance_type = ""
# nfs_instance_type  = ""
# ad_instance_type   = ""

# EPIC install options
epic_dl_url          = ""
# epic_options = "--skipeula"                             # epic < 5.2 
# epic_options = "--skipeula --default-password admin123"   # epic >= 5.2

# specify how many MAPR instances you want (0 or 3)
mapr_cluster_1_count         = 0                     # How many hosts do you want for MAPR CLUSTER 1? (0 or 3)
mapr_cluster_2_count         = 0                     # How many hosts do you want for MAPR CLUSTER 2? (0 or 3)

# DON'T CHANGE
selinux_disabled = true
ad_server_enabled = false

rdp_server_enabled = true # Do not disable this unless you are doing a manual installation
rdp_server_operating_system = "LINUX"
create_eip_rdp_linux_server = true

ca_key = <<EOF
-----BEGIN RSA PRIVATE KEY-----
MIIEowIBAAKCAQEAmuBggPR0hBnydZfXPnHAPA+sSG9ixA+7nfduGrfkLNuGRl7r
NxlU0ilFcXriBEpv39dCNVFtUPJJ/ZREo1jRpLPrjrxP6vCgsYMMNhy9qP4Jk593
wE0PkAnsUYol3DZT3s8wDLsmSRE0ylEg4f1D1DIjXSnr6h6/O9OgajFEUna9OkGf
kJDr9/hY4iQwm5ccerdj0jDiPkWRI2JRQe1/2/UvahrhM4dt+ijeevsZ05AuCBbv
5Mpb22jdJGAVRfkbQtOBM9JLIOjG8mykbZg5h3kYm/0qU0RjPd9P444zGhkyKYfT
K0MRFoQwf4ghzzOhocovFt5abcLNsuYs1tYNUwIDAQABAoIBAGiWd3T+ICUJZKu2
s1tu87Nbnit4VMk0Gq3tZoRShJsqT/37oXoe+CHITyX4JuNg5TXTJtncuCa+x+qf
ks6Ab2p7Oeq1Dn8IqmvVpIxyUj3p98uiF/tbztOlb9oMoc6ZPYAsiDVAuPUE0pKB
wOP75S9KAImsgq0iwF+FZUHxLUNF8UfCtEGrWd7nY1MNwF5vZuu5kjT9u3GvAt+s
7guMmNuO/SRwA/OhfTFRtwXUk8o+cJDBnDkmzj+U3dX/Z6eGYS2Jhi+Jo/z4+4LQ
vkMB9Xtgtq9H3q4jbLjhc3mMCf55PLLLHkH5v3Bd3BezeLwuFYm2JOIK9WNuhQQ+
xEZ4omkCgYEAxVS/6m837zKWfhnU9vbMs6rRniLgICn6mNsdPsI9ApP6o4Jk7dTu
XbH6+IxLR+0ipTN2dOcj7RYNnVT6rgb5SosEMrz+UDKOgPeTdmOKhi5JTPp9v2Mt
AhmdtWpf98jyu6HeHL2nTRyiMLRYE/2f7BghyJ9ZRMn/RpxeEXjA+V8CgYEAyOxT
mZsfe0ktnsXIADuFkrOzmUfSR6CCfzATJ5ASqOf7VEG7fWeUGgMtgjZG28TySxNC
YUfSwZb0Dxs3cUhM5l6WU3Ym+7VadiFe93iBWdgwESLczpjfpE7qSTDoShlUWYDv
zsBBgOBfNKAIaTbRB/jqriJrtjBq7O3wIuFLzI0CgYAHnifyguyj3U4V/CVOi2SH
oxaIhkwksbos4HiWjaURTmkkmsoOrGOvVkmcAr59PlhSDFSMWsf2RR2tbzRmN3q0
N/2nf8hJjEoYDHay4VDdsTe/MwRbuRZpuFdwQ3UE+cr1F2Cdt2yX+3z/aFbmHqpn
0N6tAgnOMAYc0biH8CNy/QKBgQCYgUizPtsWaOUHrnewNX2dbGjV333sgBiNEaB4
VxLSwcIyofH9rbDsTZ0tSKVgCo0eDvBDhpCiAEIfdTkP8yDrer//eZ79TxnqsEm0
7PLBjyZs21leNwsJXBzYkRa/p5oulX9wHt2ZRLT+7Ll1ovXmZzk6E0ZOc1G1pKSw
1PEDwQKBgCY+zLSyWs/M3oI9y9aMfOuQFHgRZxDcSG7ce2xGUAwsUKJwtq4XylQZ
QkABF4fWIeEs0h0tOt+yowF1PU7Q4AH1MKQZCoqKP1Y62T/zGRr59huDZlN+Z3tf
OIotPP8nCOs8Sqq76VHaFxLLIrkCowq+wjtLzNgRRGbkDwohd//l
-----END RSA PRIVATE KEY-----
EOF

ca_cert = <<EOF
-----BEGIN CERTIFICATE-----
MIIDSzCCAjOgAwIBAgIIPkySS+2b3eIwDQYJKoZIhvcNAQELBQAwIDEeMBwGA1UE
AxMVbWluaWNhIHJvb3QgY2EgM2U0YzkyMCAXDTIwMDIyOTE4MTk1MFoYDzIxMjAw
MjI5MTgxOTUwWjAgMR4wHAYDVQQDExVtaW5pY2Egcm9vdCBjYSAzZTRjOTIwggEi
MA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQCa4GCA9HSEGfJ1l9c+ccA8D6xI
b2LED7ud924at+Qs24ZGXus3GVTSKUVxeuIESm/f10I1UW1Q8kn9lESjWNGks+uO
vE/q8KCxgww2HL2o/gmTn3fATQ+QCexRiiXcNlPezzAMuyZJETTKUSDh/UPUMiNd
KevqHr8706BqMURSdr06QZ+QkOv3+FjiJDCblxx6t2PSMOI+RZEjYlFB7X/b9S9q
GuEzh236KN56+xnTkC4IFu/kylvbaN0kYBVF+RtC04Ez0ksg6MbybKRtmDmHeRib
/SpTRGM930/jjjMaGTIph9MrQxEWhDB/iCHPM6Ghyi8W3lptws2y5izW1g1TAgMB
AAGjgYYwgYMwDgYDVR0PAQH/BAQDAgKEMB0GA1UdJQQWMBQGCCsGAQUFBwMBBggr
BgEFBQcDAjASBgNVHRMBAf8ECDAGAQH/AgEAMB0GA1UdDgQWBBQT2Q46hkQnjZ7G
BBgMrpZIv0FemjAfBgNVHSMEGDAWgBQT2Q46hkQnjZ7GBBgMrpZIv0FemjANBgkq
hkiG9w0BAQsFAAOCAQEATB+YL20s8OLBPyl5OKwdNDqaMpAK0voZW2TVS0Qo6Igk
72mq0kpdHypdJjYhMK2e49/NZD3s2KCJWLzV7WVZ2LHy0MXzxZKIzQYbzg/GMbn1
zYp3aj4TRiJaoPaokupq07/qYDUyg2Raq51ffoHSH6bmQG+6RplRmLU2HCuKYXjZ
0AeuGEEanqV0jlxw3ngcGF+sPj+aXnmMHQJ1V/8E5d2kcbbIFfxNLlkhE2fgkBoG
cip9mzyHK6hoKgRLNuyadurvI6sJ53lyBapCQkYk2TvCrHNKh4UUXIPKYeIpEb7a
mdzJvUDlumspdeiX1InWOc15LrZndFcoyN0PIL+fLg==
-----END CERTIFICATE-----
EOF
