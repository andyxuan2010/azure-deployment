## important files/folders

### .gitignore for files not tracking

    **/.terraform/*
    *.tfstate
    *.tfstate.*
    credentials
    .git/*
    .git/hooks/post-checkout
    post-checkout.ps1


### .pre-commit-config.yaml
for pre-commit and other plugins
```
  - repo: https://github.com/antonbabenko/pre-commit-terraform
    rev: v1.77.1
    hooks:
      - id: terraform_fmt
      - id: terraform_validate
      - id: terraform_providers_lock
      - id: terraform_tflint
      - id: terraform_checkov
      - id: terraform_tfsec
      - id: terrascan
      - id: tfupdate
      - id: terraform_docs
        args:
          - '--args=--lockfile=false'
      - id: terraform_tflint
        args:
          - '--args=--only=terraform_deprecated_interpolation'
          - '--args=--only=terraform_deprecated_index'
          - '--args=--only=terraform_unused_declarations'
          - '--args=--only=terraform_comment_syntax'
          - '--args=--only=terraform_documented_outputs'
          - '--args=--only=terraform_documented_variables'
          - '--args=--only=terraform_typed_variables'
          - '--args=--only=terraform_module_pinned_source'
          - '--args=--only=terraform_naming_convention'
          - '--args=--only=terraform_required_version'
          - '--args=--only=terraform_required_providers'
          - '--args=--only=terraform_standard_module_structure'
          - '--args=--only=terraform_workspace_remote'


  - repo: https://github.com/pre-commit/pre-commit-hooks
    rev: v4.4.0
    hooks:
      - id: check-merge-conflict
      - id: trailing-whitespace
      - id: check-yaml
      - id: detect-private-key
      - id: check-added-large-files
```

### azure-pipelines.yml
for ADO pipelines

### backend.tf
remote state files location and other providers
```
  backend "azurerm" {
    subscription_id      = "subscription_id"
    resource_group_name  = "rg-ccoe-iac-cc-sbx"
    storage_account_name = "saccoeiacccsbx"
    container_name       = "terraform"
    key                  = "template/terraform.tfstate"
  }
```

### terraform.tfvars
Automatically loaded by terraform, per environment variables
as an example:
```
app_env     = "sbx"
app_vnet    = "vnet-ba-cc-sbx-app"
app_vnet_rg = "rg-ba-cc-sbx-app-network"
app_snet    = "snet-ba-cc-sbx-app-frontend"
app_rg      = "rg-example-cc-sbx"
iac_rg      = "rg-ccoe-iac-cc-sbx"
iac_kv      = "kv-ccoe-cc-sbx"
iac_st      = "stccoeiacccsbx"
```

### .git
for git/ADO/github purpose


### docs
project related some documents, ISAD and architecture designs

### reference
some reference docs, links and articles

### modules
for terraform modules

### scripts
for automation scripts, including shell/powershell/ansible scripts etc


### files
for support files. like ssh key, certificates




## Version

The version to reflect the changes and new added modules.
current version: 0.1

next version: 0.2 to add vm and adf


## terraform authentication through terminal against azure

### Authenticate Using Azure CLI with device code (not recommended)
```
az login --tenant tenant_id --use-device-code
az account set --subscription "subscription_id"
terraform init
terraform fmt && terraform validate
terraform plan && terraform apply --auto-approve
```

### Authenticate Using a Service Principal for Automation
The service principals have been already setup.
Environment variable in powershell in following format:
    $env:ARM_CLIENT_ID = "client_id"
    $env:ARM_CLIENT_SECRET = "secret"
    $env:ARM_TENANT_ID = "tenant_id"
    $env:ARM_SUBSCRIPTION_ID = "subscription_id"

There is no need to logon and best for automation. This is more for the individual terraform test for dev/sbx environment BEFORE COMMITTING THE CODE.
For the main branch and production environment.  ADO committing and PR is more preferable.
We are leveraging a git hook checkout and a script post-checkout.ps1 to automate the integration between git and terraform.
when switching from git branches, terraform also automatically switches from different backend.


### Authenticate with ADO PR/COMMITTING  for Automation (recommended)
This is more formal way for the deployment and source control of the terraform code.
main branch <-> production subscription and production environment
dev branch <-> nonprod subscription, dev environment
qa branch <-> nonprod subcription, qa env
poc branch <-> nonprod subcription, poc env
sbx branch <-> Inovation-sandbox subscription, sbx env
As soon as we commit the code, ADO pipeline will take care the authentication and CI/CD pipeline.
More details will come


## pre-commit and pre-commit-terraform install

### pre-commit

- install python 3 for windows (python and pip will be available)
- install git for windows (git bash will be available)
- install pre-commit by
  ```
    pre-commit install
  ```
  and use .pre-commit-config.yaml file

## Pipeline and usage summary

The repository has two infrastructure delivery paths. The GitHub Actions
Terraform workflow initializes, formats, plans, and—when the event is a push to
`main` with the required secrets—applies the configuration. The checked-in
`azure-pipelines.yml` provides the corresponding Azure DevOps init, validate,
plan, and apply stages. The Pages workflow only publishes repository
documentation.

For a local validation run, authenticate to the target subscription, then run
from the repository root:

```bash
terraform init
terraform fmt -check
terraform validate
terraform plan
```

Review backend, subscription, and environment settings before `terraform apply`.
Use the branch-to-environment mapping documented above and never commit ARM
credentials or Terraform state.
