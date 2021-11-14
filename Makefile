.PHONY: tf_plan tf_apply build zip

tf_plan:
	@echo "terraform plan -var-file secret.tfvars"
	@terraform plan -var-file secret.tfvars

tf_apply:
	@terraform apply -var-file secret.tfvars

build:
	@echo "build"
	@GOOS=linux GOARCH=amd64 CGO_ENABLED=0 go build -o ./main ./main.go

zip:
	@echo "zip"
	@zip ./main.zip ./main
