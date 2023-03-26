error:
	exit 1

master:
	multipass launch 22.04 --name master -c 2 -m 2G -d 10G --cloud-init cloud-init.yaml

shell:
	multipass shell master

kubeconfig:
	multipass exec master -- /opt/csr.sh
	multipass transfer master:/home/ubuntu/.kube/config .
	KUBECONFIG=config:~/.kube/config kubectl config view --flatten > ~/.kube/config
	rm config

	$(eval IP := $(shell multipass info master --format json | jq -r .info.master.ipv4[0]))
	kubectl config set-cluster kubenertes --server=https://$(IP):6443

clean:
	multipass delete master
	multipass purge
