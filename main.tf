// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

module "codepipeline" {
  source = "git::https://github.com/nexient-llc/tf-aws-module-codepipeline.git?ref=0.1.0"
  count  = length(local.pipelines)

  name             = replace(module.resource_names["pipeline"].standard, var.naming_prefix, "${var.naming_prefix}_${local.pipelines[count.index].name}")
  create_s3_source = local.pipelines[count.index].create_s3_source
  source_s3_bucket = replace(module.resource_names["s3"].standard, var.naming_prefix, "${var.naming_prefix}_${local.pipelines[count.index].name}")
  stages           = local.pipelines[count.index].stages
  pipelineType     = local.pipelines[count.index].pipelineType

  tags = merge(local.tags, { resource_name = replace(module.resource_names["pipeline"].standard, var.naming_prefix, "${var.naming_prefix}_${local.pipelines[count.index].name}") })
}

module "codebuild" {
  source = "git::https://github.com/nexient-llc/tf-aws-wrapper_module-codebuild.git?ref=0.1.0"
  count  = length(local.codebuilds)

  codebuild_projects = local.codebuilds[count.index].codebuild_projects
  naming_prefix      = "${var.naming_prefix}_${local.codebuilds[count.index].pipeline_name}"
  environment_number = var.environment_number
  environment        = var.environment
  resource_number    = var.resource_number
  pipeline_name      = local.codebuilds[count.index].pipeline_name

  tags = var.tags
}

module "additional_codebuild_projects" {
  source = "git::https://github.com/nexient-llc/tf-aws-wrapper_module-codebuild.git?ref=0.1.0"
  count  = var.additional_codebuild_projects != null ? 1 : 0

  codebuild_projects = [var.additional_codebuild_projects[count.index]]
  naming_prefix      = var.naming_prefix
  environment_number = var.environment_number
  environment        = var.environment
  resource_number    = var.resource_number

  tags = var.tags
}

module "sns_topic" {
  source   = "git::https://github.com/nexient-llc/tf-aws-wrapper_module-sns.git?ref=0.1.0"
  for_each = { for k in compact([for k, v in local.sns_topics : v.created_by != null ? k : null]) : k => local.sns_topics[k] }

  subscriptions      = each.value.subscriptions != null ? each.value.subscriptions : null
  created_by         = each.value.created_by
  naming_prefix      = "${var.naming_prefix}_${each.value.created_by}"
  environment_number = var.environment_number
  environment        = var.environment
  resource_number    = var.resource_number

  tags = var.tags
}

module "resource_names" {
  source = "git::https://github.com/nexient-llc/tf-module-resource_name.git?ref=0.1.0"

  for_each = var.resource_names_map

  logical_product_name = var.naming_prefix
  region               = join("", split("-", var.region))
  class_env            = var.environment
  cloud_resource_type  = each.value.name
  instance_env         = var.environment_number
  instance_resource    = var.resource_number
  maximum_length       = each.value.max_length
}

# This is needed until Terraform supports CodePipeline versions
# https://github.com/hashicorp/terraform-provider-aws/issues/34122
resource "null_resource" "get_pipeline_stages" {
  triggers = { always_run = timestamp() }
  for_each = { for idx, pipeline in local.v2_pipelines : idx => pipeline }

  provisioner "local-exec" {
    command = "mkdir -p ${local.json_path} && aws codepipeline get-pipeline --region ${var.region} --profile ${var.null_resource_aws_profile} --name ${module.codepipeline[index(local.v2_pipelines, each.value)].id} --output json > ${local.json_path}/${index(local.v2_pipelines, each.value)}_pipeline_output.json && jq '.pipeline.pipelineType = \"V2\" | del(.metadata)' ${local.json_path}/${index(local.v2_pipelines, each.value)}_pipeline_output.json > ${local.json_path}/${index(local.v2_pipelines, each.value)}_pipeline_stages.json"
  }
}

data "local_file" "codepipeline_file" {
  count      = var.null_resource_aws_profile != null ? length(null_resource.get_pipeline_stages) : 0
  depends_on = [null_resource.get_pipeline_stages]

  filename = "${local.json_path}/${count.index}_pipeline_stages.json"
}

resource "null_resource" "invoke_aws_cli" {
  count = var.null_resource_aws_profile != null ? length(data.local_file.codepipeline_file) : 0
  provisioner "local-exec" {
    command = <<EOT
aws codepipeline update-pipeline --cli-input-json file://${local.json_path}/${count.index}_pipeline_stages.json --region ${var.region} --profile '${var.null_resource_aws_profile}'
EOT
  }

  depends_on = [
    module.codepipeline
  ]
}
