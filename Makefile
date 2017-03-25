image_version:="0.0.19"

build-all: clean validate
	packer build ubuntu-1610.json

validate:
	packer validate ubuntu-1610.json

build-libvirt: clean validate
	packer build -only=libvirt ubuntu-1610.json
	./scripts/optimize_libvirt_box.sh

build-vmware: clean validate
	packer build -only=vmware ubuntu-1610.json

build-vbox: clean validate
	packer build -only=virtualbox ubuntu-1610.json

clean:
	rm -Rf output-* *.box tmp
	rm -Rf packer_cache

uninstall_libvirt:
	vagrant destroy
	vagrant box remove cilium/ubuntu-16.10
	-service libvirt-bin restart
	-service libvirtd restart

uninstall_vbox:
	vagrant destroy
	vagrant box remove cilium/ubuntu-16.10

install_libvirt:
	vagrant box add --force cilium/ubuntu-16.10 ubuntu-1610-libvirt.box
	vagrant up --provider=libvirt

install_vbox:
	vagrant box add --force cilium/ubuntu-16.10 ubuntu-1610-virtualbox.box
	vagrant up --provider=virtualbox
