resource "aws_codebuild_project" "tf-plan" {
  name          = "BuildConsole"
  description   = "Plan stage for terraform"
  service_role  = aws_iam_role.tf-codebuild-role.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "mcr.microsoft.com/dotnet/sdk"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "SERVICE_ROLE"
    registry_credential{
        credential = var.dockerhub_credentials
        credential_provider = "SECRETS_MANAGER"
    }
 }
 source {
     type   = "CODEPIPELINE"
     buildspec = file("buildspec.yml")
 }
}

resource "aws_codedeploy_app" "code_deploy" {
  name          = "MyConsoleDeployment"
  compute_platform = "Server"
}
resource "aws_codedeploy_deployment_group" "DeployGroup" {
  app_name               = "MyConsoleDeployment"
  deployment_group_name  = "MyConsoleDeploymentGroup"
  service_role_arn      ="arn:aws:iam::606104556660:role/CodeDeployRoleForEc2"  
  deployment_config_name = "CodeDeployDefault.AllAtOnce"


  
  # Use the tags to identify the EC2 instance
  ec2_tag_set {
    ec2_tag_filter {
      key    = "Name"
      value  = "HTmlec2"
      type   = "KEY_AND_VALUE"
    }

   

  }
}



resource "aws_codepipeline" "cicd_pipeline" {

    name = "CICDPipelineConsoleproject"
    role_arn = aws_iam_role.tf-codepipeline-role.arn

    artifact_store {
        type="S3"
        location = aws_s3_bucket.codepipeline_artifacts.id
       // location = aws_s3_bucket.codepipeline_artifacts.id

    }

   stage {
    name = "Source"

    action {
      name            = "Source"
      category        = "Source"
      owner           = "AWS"
      provider        = "CodeStarSourceConnection"
      version         = "1"
            output_artifacts = ["tf-code"]
            configuration = {
                FullRepositoryId = "PradeepaLakshmanan-CH-2022/TerraformPipeline"
                BranchName   = "main"
                ConnectionArn=var.codestar_connector_credentials
               // ConnectionArn = var.codestar_connector_credentials
                OutputArtifactFormat = "CODE_ZIP"
            }
        }
    }

    stage {
        name ="Build"
        action{
            name = "Build"
            category = "Build"
            provider = "CodeBuild"
            version = "1"
            owner = "AWS"
            input_artifacts = ["tf-code"]
            configuration = {
                ProjectName = "BuildConsole"
            }
        }
    }

 stage {
  name = "Deploy"

  action {
    name            = "DeployEC2"
    category        = "Deploy"
    owner           = "AWS"
    provider        = "CodeDeploy"
    version = "1"
   run_order       = 1
    input_artifacts = ["tf-code"]

    configuration = {
      ApplicationName  = "MyConsoleDeployment"
      DeploymentGroupName = "MyConsoleDeploymentGroup"
  
    }
  }
}


}
