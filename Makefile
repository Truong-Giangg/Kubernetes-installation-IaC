init:
	terraform init

plan:
	terraform plan -input=false

apply:
	terraform apply -auto-approve -input=false

destroy:
	terraform destroy -auto-approve
