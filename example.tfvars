# Replace the <> with the actual values
pipelines = [
  {
    name             = "pr_event"
    create_s3_source = true
    source_stage = {
      stage_name = "Source"
      name       = "Source"
      category   = "Source"
      owner      = "AWS"
      provider   = "S3"
      version    = "1"
      configuration = {
        S3ObjectKey          = "trigger_pipeline.zip"
        PollForSourceChanges = "false"
      }
      input_artifacts  = []
      output_artifacts = ["SourceArtifact"]
      run_order        = null
      region           = null
      namespace        = null
    }
    stages = [
      {
        stage_name       = "Simulated-Merge"
        name             = "Sim-Merge"
        category         = "Build"
        owner            = "AWS"
        provider         = "CodeBuild"
        project_name     = "sim_merge"
        buildspec        = "sim_merge.yml"
        version          = "1"
        configuration    = {}
        input_artifacts  = ["SourceArtifact"]
        output_artifacts = []
        run_order        = null
        region           = null
        namespace        = null
      },
      {
        stage_name       = "Terragrunt-Plan"
        name             = "TG-Plan"
        category         = "Build"
        owner            = "AWS"
        provider         = "CodeBuild"
        project_name     = "tg_plan"
        buildspec        = "tg_plan.yml"
        version          = "1"
        configuration    = {}
        input_artifacts  = ["SourceArtifact"]
        output_artifacts = []
        run_order        = null
        region           = null
        namespace        = null
      }
    ]
  },
  {
    name             = "pr_merge"
    create_s3_source = true
    approval_sns_subscribers = [
      {
        protocol = "email"
        endpoint = "john.doe@example.com"
      },
      {
        protocol = "email"
        endpoint = "jane.doe@example.com"
      }
    ]
    source_stage = {
      stage_name = "Source"
      name       = "Source"
      category   = "Source"
      owner      = "AWS"
      provider   = "S3"
      version    = "1"
      configuration = {
        S3ObjectKey          = "trigger_pipeline.zip"
        PollForSourceChanges = "false"
      }
      input_artifacts  = []
      output_artifacts = ["SourceArtifact"]
      run_order        = null
      region           = null
      namespace        = null
    }
    stages = [
      {
        stage_name       = "Terragrunt-Plan"
        name             = "TG-Plan"
        category         = "Build"
        owner            = "AWS"
        provider         = "CodeBuild"
        project_name     = "tg_plan"
        buildspec        = "tg_plan.yml"
        version          = "1"
        configuration    = {}
        input_artifacts  = ["SourceArtifact"]
        output_artifacts = []
        run_order        = null
        region           = null
        namespace        = null
      },
      {
        stage_name       = "Trigger-QA"
        name             = "Trigger-Env"
        category         = "Build"
        owner            = "AWS"
        provider         = "CodeBuild"
        project_name     = "trigger_env"
        buildspec        = "trigger_env.yml"
        version          = "1"
        configuration    = {}
        input_artifacts  = ["SourceArtifact"]
        output_artifacts = []
        run_order        = null
        region           = null
        namespace        = null
      },
      {
        stage_name       = "Manual-Approval"
        name             = "Manual-Approval"
        category         = "Approval"
        owner            = "AWS"
        provider         = "Manual"
        version          = "1"
        configuration    = {}
        input_artifacts  = []
        output_artifacts = []
        run_order        = null
        region           = null
        namespace        = null
      }
    ]
  }
]
