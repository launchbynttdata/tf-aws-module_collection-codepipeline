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

variable "pipelines" {
  description = "List of all custom pipelines to create."
  type        = any
  default     = ""
}

variable "additional_codebuild_projects" {
  description = "Codebuild to trigger other pipelines. Used by the lambdas to trigger the correct pipeline."
  type        = any
  default     = null
}

variable "build_image" {
  type        = string
  default     = "aws/codebuild/amazonlinux2-x86_64-standard:4.0"
  description = "Docker image for build environment, e.g. 'aws/codebuild/standard:2.0' or 'aws/codebuild/eb-nodejs-6.10.0-amazonlinux-64:4.0.0'. For more info: http://docs.aws.amazon.com/codebuild/latest/userguide/build-env-ref.html"
}

variable "privileged_mode" {
  type        = bool
  default     = false
  description = "(Optional) If set to true, enables running the Docker daemon inside a Docker container on the CodeBuild instance. Used when building Docker images"
}

variable "build_image_pull_credentials_type" {
  type        = string
  default     = "CODEBUILD"
  description = "Type of credentials AWS CodeBuild uses to pull images in your build.Valid values: CODEBUILD, SERVICE_ROLE. When you use a cross-account or private registry image, you must use SERVICE_ROLE credentials."
}

variable "environment_variables" {
  type = list(object(
    {
      name  = string
      value = string
      type  = string
    }
  ))

  default = []

  description = "A list of maps, that contain the keys 'name', 'value', and 'type' to be used as additional environment variables for the build. Valid types are 'PLAINTEXT', 'PARAMETER_STORE', or 'SECRETS_MANAGER'"
}

### TF Module Resource variables
variable "naming_prefix" {
  description = "Prefix for the provisioned resources."
  type        = string
  default     = "platform"
}

variable "environment" {
  description = "Environment in which the resource should be provisioned like dev, qa, prod etc."
  type        = string
  default     = "dev"
}

variable "environment_number" {
  description = "The environment count for the respective environment. Defaults to 000. Increments in value of 1"
  default     = "000"
}

variable "region" {
  description = "AWS Region in which the infra needs to be provisioned"
  default     = "us-east-2"
}

variable "resource_number" {
  description = "The resource count for the respective resource. Defaults to 000. Increments in value of 1"
  default     = "000"
}

variable "resource_names_map" {
  description = "A map of key to resource_name that will be used by tf-aws-wrapper_module-codepipeline module to generate resource names"
  type = map(object(
    {
      name       = string
      max_length = optional(number, 60)
    }
  ))
  default = {
    pipeline = {
      name       = "pln"
      max_length = 63
    }
    function = {
      name       = "fn"
      max_length = 63
    }
    s3 = {
      name       = "s3"
      max_length = 63
    }
    codebuild = {
      name       = "cb"
      max_length = 63
    }
    sns = {
      name       = "sns"
      max_length = 63
    }
  }
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "A map of tags to add to the resources created by the module."
}

variable "null_resource_aws_profile" {
  description = "Temporary variable to identify the AWS profile to use for CodePipeline Deployment until provider supports pipeline versions."
  type        = string
  default     = null
}
