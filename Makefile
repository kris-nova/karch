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
kubernetes_clone    =     git@github.com:kris-nova/kubernetes.git


.PHONY: clone
clone: ## Clone containerd from Makefile flags
	@if [ ! -d containerd ]; then git clone $(containerd_clone); fi
	@if [ ! -d runc ]; then git clone $(runc_clone); fi
	@if [ ! -d kubernetes ]; then git clone $(kubernetes_clone); fi

logs: ## Run the logs
	journalctl -f -u containerd

restart: ## Restart systemd services
	systemctl daemon-reload
	systemctl restart containerd

all: containerd runc kubernetes ## Install containerd and runc from source!
	@cp -rv etc/* /etc

containerd: clone ## Install containerd from local source
	[ ! -d containerd ] && clone
	cd containerd && make -j32 && make install
	@cp -v containerd/containerd.service /lib/systemd/system/containerd.service

runc: clone ## Install runc from local source

kubernetes: clone ## Install kubernetes from local source



install_runc: ## Install containerd from source

install_kubernetes: ## Install kuberneretes from source




.PHONY: help
help:  ## 🤔 Show help messages for make targets
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[32m%-30s\033[0m %s\n", $$1, $$2}'