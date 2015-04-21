#!/bin/bash

LANG=C

m=$1
if [ -z "$m" ]; then
	echo "Usage: $0 <vm name>"
	exit 1
fi

# Stop VM
virsh destroy $m

# Remove NIC/DHCP info from libvirt and dnsmasq
virsh domiflist ${m} | awk '$2 == "network" {print $3,$5}' | \
while read n mac; do
	xml=$(virsh net-dumpxml $n | grep $mac | tail -1)
	ip=$(echo $xml | sed 's/.*ip=[^0-9]*\([0-9.]*\).*/\1/')
	if [ ! -z "$ip" ]; then
		x="<host mac='$mac' ip='$ip' />"
		virsh net-update $n delete ip-dhcp-host "$x" --live --config
	fi

	bridge=$(virsh net-info $n | awk '$1 == "Bridge:" {print $2}')
	lease=$(awk "\$2==\"$mac\" {print \$3,\$2}" /var/lib/libvirt/dnsmasq/$n.leases)
	if [ ! -z "$lease" ]; then
		dhcp_release $bridge $lease
	fi
done

# Remove from /etc/hosts
sed -i "/.* ${m}\$/d" /etc/hosts

# Remove from known_hosts if any
ssh-keygen -R ${m}

# Remove VM
virsh undefine $m

echo "Remove VM images in /var/lib/libvirt/images by yourself."
