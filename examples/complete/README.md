# complete

This example creates 2 pipelines with 2 codebuild stages.
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.0, <= 1.5.5 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.32 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_codepipeline"></a> [codepipeline](#module\_codepipeline) | ../.. | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_pipelines"></a> [pipelines](#input\_pipelines) | List of all custom pipelines to create. | `any` | `""` | no |
| <a name="input_additional_codebuild_projects"></a> [additional\_codebuild\_projects](#input\_additional\_codebuild\_projects) | Codebuild to trigger other pipelines. Used by the lambdas to trigger the correct pipeline. | `any` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to the resources created by the module. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_id"></a> [id](#output\_id) | The codepipeline ID |
| <a name="output_arn"></a> [arn](#output\_arn) | The codepipeline ARN |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
