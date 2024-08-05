# challenge/terraform
# Makefile

BLUE := $(shell printf "\033[0;36m")
DEF  := $(shell printf "\033[0m")

ifndef TF_PLAN_FILE
TF_PLAN_FILE := ./plan.out
endif



plan:
	$(info $(BLUE)# terraform initializing $(DEF))
	terraform init -input=false
	$(info $(BLUE)# terraform making plan $(DEF))

	terraform plan -input=false -out=$(TF_PLAN_FILE) $(TARGET)

apply:
	$(info $(BLUE)# terraform applying changes $(DEF))
	terraform apply $(TF_PLAN_FILE)

clean:
	rm -rf .terraform terraform.tfstate $(TF_PLAN_FILE)

.PHONY: clean plan apply
