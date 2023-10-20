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

data "aws_caller_identity" "current" {}

locals {

  default_tags = {
    provisioner = "Terraform"
  }

  codebuilds = [
    for pipeline in var.pipelines : {
      codebuild_projects = [
        for stage in pipeline.stages : {
          name                              = stage.project_name
          buildspec                         = stage.buildspec
          build_image                       = try(stage.build_image, var.build_image)
          privileged_mode                   = try(stage.privileged_mode, var.privileged_mode)
          build_image_pull_credentials_type = try(stage.build_image_pull_credentials_type, var.build_image_pull_credentials_type)
          environment_variables             = try(stage.environment_variables, var.environment_variables)
          codebuild_iam = try(jsonencode({
            Version = "2012-10-17",
            Statement = concat([
              {
                Action = [
                  "s3:PutObject",
                  "s3:GetObject",
                  "s3:GetObjectVersion",
                  "s3:GetBucketAcl",
                  "s3:GetBucketLocation"
                ],
                Effect   = "Allow",
                Resource = "arn:aws:s3:::codepipeline*"
              }
              ],
              [
                {
                  Action = [
                    "ecr:GetAuthorizationToken",
                    "ecr:BatchCheckLayerAvailability",
                    "ecr:GetDownloadUrlForLayer",
                    "ecr:BatchGetImage"
                  ],
                  Effect   = "Allow",
                  Resource = "*"
                }
              ],
            try(jsondecode(stage.codebuild_iam).Statement, []))
          }), null)
        } if stage.provider == "CodeBuild"
      ]
      pipeline_name = pipeline.name
    }
  ]

  pipelines_source_stages = [
    for i in range(length(var.pipelines)) : {
      name             = var.pipelines[i].name
      create_s3_source = var.pipelines[i].create_s3_source
      source_stage = var.pipelines[i].create_s3_source ? merge(var.pipelines[i].source_stage, {
        configuration = merge(var.pipelines[i].source_stage.configuration, {
          S3Bucket = replace(replace(module.resource_names["s3"].standard, var.naming_prefix, "${var.naming_prefix}-${var.pipelines[i].name}"), "_", "-")
        })
      }) : var.pipelines[i].source_stage

      stages = var.pipelines[i].stages
    }
  ]

  sns_topics = {
    for pipeline in var.pipelines :

    pipeline.name => {
      subscriptions = try(pipeline.approval_sns_subscribers, null) != null ? pipeline.approval_sns_subscribers : null
      created_by    = try(pipeline.approval_sns_subscribers, null) != null ? pipeline.name : null
    }
  }

  pipelines = [
    for pipeline in range(length(var.pipelines)) : {
      name             = var.pipelines[pipeline].name
      create_s3_source = var.pipelines[pipeline].create_s3_source

      stages = concat(
        [local.pipelines_source_stages[pipeline].source_stage],
        [for stage in range(length(var.pipelines[pipeline].stages)) : {
          stage_name = var.pipelines[pipeline].stages[stage].stage_name
          name       = var.pipelines[pipeline].stages[stage].name
          category   = var.pipelines[pipeline].stages[stage].category
          owner      = try(var.pipelines[pipeline].stages[stage].owner, "AWS")
          provider   = var.pipelines[pipeline].stages[stage].provider
          version    = try(var.pipelines[pipeline].stages[stage].version, "1")
          # The follow logic returns the element at the index if the provider for the stage equals "CodeBuild", "Manual", or other.
          # Within each element, there is logic to build the configuration key-value
          # The "CodeBuild" provider, will set the codebuild project based on which pipeline created it and its name.
          # The "Manual" provider, sets the arn of the SNS topic it created for notifications.
          # If the provider does not match either elements, it uses the configuration value as-is.
          configuration = merge(
            [
              try(var.pipelines[pipeline].stages[stage].buildspec, null) != null ?
              {
                ProjectName = "${element([for codebuild in module.codebuild :
                  element([for project_name in codebuild.project_name :
                    project_name if project_name ==
                    replace(module.resource_names["codebuild"].standard, var.naming_prefix, "${var.naming_prefix}_${codebuild.pipeline_name}_${var.pipelines[pipeline].stages[stage].project_name}")
                  ], 0) if codebuild.pipeline_name == var.pipelines[pipeline].name
                ], 0)}"
              } : {},
              try(var.pipelines[pipeline].approval_sns_subscribers, null) != null ?
              {
                NotificationArn = "arn:aws:sns:${var.region}:${data.aws_caller_identity.current.account_id}:${element([for topic in module.sns_topic : topic.sns_topic_name if topic.sns_created_by == var.pipelines[pipeline].name], 0)}"
              } : {},
              null
          ][var.pipelines[pipeline].stages[stage].provider == "CodeBuild" ? 0 : var.pipelines[pipeline].stages[stage].provider == "Manual" ? 1 : 2], var.pipelines[pipeline].stages[stage].configuration)
          input_artifacts  = try(var.pipelines[pipeline].stages[stage].input_artifacts, [])
          output_artifacts = try(var.pipelines[pipeline].stages[stage].output_artifacts, [])
          run_order        = try(var.pipelines[pipeline].stages[stage].run_order, null)
          region           = try(var.pipelines[pipeline].stages[stage].region, null)
          namespace        = try(var.pipelines[pipeline].stages[stage].namespace, null)
        }]
      )
    }
  ]

  tags = merge(local.default_tags, var.tags)
}
