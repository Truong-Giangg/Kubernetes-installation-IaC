init:
	cd environments/local && terraform init
plan:
	cd environments/local && terraform plan -input=false
apply:
	cd environments/local && terraform apply -auto-approve -input=false
destroy:
	cd environments/local && terraform destroy -auto-approve
