TOOLS_DIR := ./bin

TERRAFORM := $(TOOLS_DIR)/terraform
TERRAFORM_VERSION := 1.1.3

$(TERRAFORM):
	wget https://releases.hashicorp.com/terraform/$(TERRAFORM_VERSION)/terraform_$(TERRAFORM_VERSION)_linux_amd64.zip
	@unzip terraform_$(TERRAFORM_VERSION)_linux_amd64.zip
	@rm terraform_$(TERRAFORM_VERSION)_linux_amd64.zip
	mv terraform $(TOOLS_DIR)/

fmt: $(TERRAFORM)
	@$(TERRAFORM) fmt

init: $(TERRAFORM)
	@$(TERRAFORM) init

plan: $(TERRAFORM)
	@$(TERRAFORM) plan

apply: $(TERRAFORM)
	$(TERRAFORM) apply

destroy: $(TERRAFORM)
	@$(TERRAFORM) destroy
