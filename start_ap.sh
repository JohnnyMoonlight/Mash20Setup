nmcli con add type wifi ifname wlan0 con-name webmash_ap autoconnect yes ssid webmash
nmcli con modify webmash_ap 802-11-wireless.mode ap 802-11-wireless.band bg ipv4.method shared
nmcli con modify webmash_ap wifi-sec.key-mgmt wpa-psk
nmcli con modify webmash_ap wifi-sec.psk 12345678
nmcli con up webmash_ap
