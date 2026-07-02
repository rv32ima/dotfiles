{ ipxe, writeText, ... }:
ipxe.override {
  embedScript = writeText "embed.ipxe" ''
    #!ipxe
    dhcp || goto no_dhcp
    goto boot

    :no_dhcp
    echo DHCP failed on all interfaces. Manual configuration required.
    echo
    ifstat
    echo
    echo Interface to configure (e.g. net0):
    read iface
    ifopen ''${iface}
    echo IP address (e.g. 192.168.1.50):
    read ip
    echo Subnet mask (e.g. 255.255.255.0):
    read mask
    echo Gateway:
    read gw
    echo DNS server:
    read dns_server
    set ''${iface}/ip ''${ip}
    set ''${iface}/netmask ''${mask}
    set ''${iface}/gateway ''${gw}
    set dns ''${dns_server}

    :boot
    chain http://peer2peer.sea.t4t.net:8787/autoexec.ipxe
  '';
}
