#!/bin/bash

set -e

mkdir -p $HOME/bin

cat > $HOME/bin/kinstall.sh << "EOF"
#!/bin/bash

apt-get update
apt-get -y install git vim
apt-get -y install libssl-dev libelf-dev
apt-get -y install pkg-config bison flex

wget --quiet 'http://kernel.ubuntu.com/~kernel-ppa/mainline/v4.9.17/linux-image-4.9.17-040917-generic_4.9.17-040917.201703220831_amd64.deb'
dpkg -i linux-image-4.9.17-040917-generic_4.9.17-040917.201703220831_amd64.deb
rm linux-image-4.9.17-040917-generic_4.9.17-040917.201703220831_amd64.deb
EOF

chmod 755 $HOME/bin/kinstall.sh
$HOME/bin/kinstall.sh

# Temporary hack for Ubuntu
#cp /usr/include/asm/unistd* /usr/include/x86_64-linux-gnu/asm/
echo 9p >> /etc/modules
echo 9pnet_virtio >> /etc/modules
echo 9pnet >> /etc/modules


# iproute2 installation
cat > $HOME/bin/iproute2.sh << "EOF"
#!/bin/bash

apt-get update
apt-get -y install git vim
apt-get -y install libssl-dev libelf-dev
apt-get -y install pkg-config bison flex
apt-get -y install gcc-multilib

cd $HOME
git clone -b net-next git://git.kernel.org/pub/scm/linux/kernel/git/shemminger/iproute2.git
cd iproute2/
./configure
make -j `getconf _NPROCESSORS_ONLN`
make install

# delete iproute2 sources
rm -Rf $HOME/iproute2
EOF

chmod 755 $HOME/bin/iproute2.sh
$HOME/bin/iproute2.sh

cat > $HOME/bin/iptables_cleanup.sh << "EOF"
#!/bin/bash

iptables -t nat -P PREROUTING ACCEPT
iptables -t nat -P POSTROUTING ACCEPT
iptables -t nat -P OUTPUT ACCEPT
iptables -t nat -F
iptables -t nat -X
iptables -t mangle -P PREROUTING ACCEPT
iptables -t mangle -P INPUT ACCEPT
iptables -t mangle -P FORWARD ACCEPT
iptables -t mangle -P OUTPUT ACCEPT
iptables -t mangle -P POSTROUTING ACCEPT
iptables -t mangle -F
iptables -t mangle -X
iptables -t filter -P INPUT ACCEPT
iptables -t filter -P FORWARD ACCEPT
iptables -t filter -P OUTPUT ACCEPT
iptables -t filter -F
iptables -t filter -X

ufw disable

rmmod ipt_REJECT nf_reject_ipv4 iptable_mangle ipt_MASQUERADE iptable_nat nf_nat_ipv4 iptable_filter ip6table_filter ip6_tables ip_tables xt_CHECKSUM xt_tcpudp xt_conntrack xt_addrtype ebtable_nat ebtables x_tables nf_nat_masquerade_ipv4 nf_conntrack_ipv4 nf_defrag_ipv4 nf_nat nf_conntrack
EOF

# script to be run by vagrant startup
chmod 755 $HOME/bin/iptables_cleanup.sh

# cleanup
apt-get -y remove build-essential bc pkg-config bison flex
apt-get -y autoremove
apt-get clean
