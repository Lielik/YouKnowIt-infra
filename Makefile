ENV ?= dev

.PHONY: init plan apply destroy validate fmt

init:
	terraform init -backend-config=config.s3.tfbackend -reconfigure

validate:
	terraform validate

fmt:
	terraform fmt -recursive

plan:
	terraform plan -var-file=environments/$(ENV).tfvars -out=tfplan

apply:
	terraform apply tfplan

destroy:
	terraform destroy -var-file=environments/$(ENV).tfvars