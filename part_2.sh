sudo "`IP_ADRESS=192.168.0.1 SUBNETMASK=255.255.255.0 envsubst < ./conf/ap-config/interfaces`" | sudo tee -a /etc/network/interfaces
