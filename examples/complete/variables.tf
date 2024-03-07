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

variable "tags" {
  type        = map(string)
  default     = {}
  description = "A map of tags to add to the resources created by the module."
}
