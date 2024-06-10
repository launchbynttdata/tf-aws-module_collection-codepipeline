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
  source = "../.."

  additional_codebuild_projects = var.additional_codebuild_projects
  pipelines                     = var.pipelines
  logical_product_family        = var.logical_product_family
  logical_product_service       = var.logical_product_service

  tags = var.tags
}

resource "aws_s3_object" "pipeline_trigger_object" {
  depends_on = [module.codepipeline]
  # The codepipeline primitive module doesn't expose the S3 bucket name, so we have to hardcode it here
  bucket = "terratest-cpmodule-pr-merge-useast2-dev-000-s3-000"
  key    = "trigger_pipeline.zip"
  source = "trigger_pipeline.zip"
}
