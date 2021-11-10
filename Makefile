.PHONY: tf_plan tf_apply build zip

tf_plan:
	@echo "terraform plan -var-file secret.tfvars"
	@terraform plan -var-file secret.tfvars

tf_apply:
	@terraform apply -var-file secret.tfvars

build:
	@echo "build"
	@go build -o ./bin/main ./main.go

zip:
	@echo "zip"
	@zip ./zip/main.zip ./bin/main
