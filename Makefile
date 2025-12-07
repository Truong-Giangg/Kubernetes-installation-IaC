init-cluster:
	cd environments/local/cluster && terraform init
plan-cluster:
	cd environments/local/cluster && terraform plan -input=false
apply-cluster:
	cd environments/local/cluster && terraform apply -auto-approve -input=false
destroy-cluster:
	cd environments/local/cluster && terraform destroy -auto-approve
init-addons:
	cd environments/local/addons && terraform init
plan-addons:
	cd environments/local/addons && terraform plan -input=false
apply-addons:
	cd environments/local/addons && terraform apply -auto-approve -input=false
destroy-addons:
	cd environments/local/addons && terraform destroy -auto-approve