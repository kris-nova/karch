# =========================================================================== #
#            MIT License Copyright (c) 2022 Kris Nóva <kris@nivenly.com>      #
#                                                                             #
#                 ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓                 #
#                 ┃   ███╗   ██╗ ██████╗ ██╗   ██╗ █████╗   ┃                 #
#                 ┃   ████╗  ██║██╔═████╗██║   ██║██╔══██╗  ┃                 #
#                 ┃   ██╔██╗ ██║██║██╔██║██║   ██║███████║  ┃                 #
#                 ┃   ██║╚██╗██║████╔╝██║╚██╗ ██╔╝██╔══██║  ┃                 #
#                 ┃   ██║ ╚████║╚██████╔╝ ╚████╔╝ ██║  ██║  ┃                 #
#                 ┃   ╚═╝  ╚═══╝ ╚═════╝   ╚═══╝  ╚═╝  ╚═╝  ┃                 #
#                 ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛                 #
#                                                                             #
#                        This machine kills fascists.                         #
#                                                                             #
# =========================================================================== #

default: help

containerd_clone    =     git@github.com:kris-nova/containerd.git
runc_clone          =     git@github.com:kris-nova/runc.git
kubernetes_version  =     v1.24.0
kubernetes_clone    =     git@github.com:kubernetes/kubernetes.git
make_flags          =     -j32
ebtables_tarball    =     ebtables.tar.gz
ebtables_clone      =     https://aur.archlinux.org/cgit/aur.git/snapshot/$(ebtables_tarball)

all: containerd runc kubernetes ## Install containerd and runc from source!
	@cp -rv etc/* /etc

.PHONY: bin
bin: ## Add the bin scripts to $PATH
	@cp -rv bin/* /usr/local/bin

containerd: clone ## Install containerd from local source
	[ ! -d containerd ] && clone
	cd containerd && make $(make_flags)

runc: clone ## Install runc from local source

kubernetes: clone kubelet kubeadm ## Install kubernetes from local source

kubelet: clone ## Install kubelet from local source
	cd kubernetes && make $(make_flags) kubelet

kubeadm: clone ebtables ## Install kubernetes from local source
	cd kubernetes && make $(make_flags) kubeadm

ebtables: ## Install arch linux ebtables
	mkdir -p ebtables
	wget $(ebtables_clone) && tar -xzf $(ebtables_tarball)
	cd ebtables && makepkg -si

install: bin install_containerd install_runc install_kubernetes ## Global install (all the artifacts)

clone: ## Clone containerd from Makefile flags
	@if [ ! -d containerd ]; then git clone $(containerd_clone); fi
	@if [ ! -d runc ]; then git clone $(runc_clone); fi
	@if [ ! -d kubernetes ]; then git clone $(kubernetes_clone); cd kubernetes && git checkout tags/$(kubernetes_version) -b $(kubernetes_version); fi

logs: ## Run the logs
	journalctl -f -u containerd -u kubelet

restart: ## Restart systemd services
	systemctl daemon-reload
	systemctl restart containerd
	systemctl restart kubelet

install_runc: ## Install runc

install_kubernetes: ## Install kuberneretes
	cp -rv kubernetes/_output/bin/* /usr/local/bin

install_containerd: ## Install containerd
	cd containerd && make $(make_flags) install
	@cp -v containerd/containerd.service /lib/systemd/system/containerd.service

clean:
	@echo "This will DESTROY local copies of kubernetes, containerd, runc, ebtables"
	read -p "Press any key to continue..."
	rm -rvf kubernetes
	rm -rvf containerd
	rm -rvf runc
	rm -rvf ebtables
	rm -rvf *.tar.gz

.PHONY: help
help:  ## 🤔 Show help messages for make targets
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[32m%-30s\033[0m %s\n", $$1, $$2}'