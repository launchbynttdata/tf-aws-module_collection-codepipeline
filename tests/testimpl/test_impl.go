package testimpl

import (
	"context"
	"testing"

	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/config"
	"github.com/aws/aws-sdk-go-v2/service/codepipeline"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/launchbynttdata/lcaf-component-terratest/types"
	"github.com/stretchr/testify/require"
)

func TestDoesPilelineExist(t *testing.T, ctx types.TestContext) {
	pipelineId := terraform.OutputList(t, ctx.TerratestTerraformOptions(), "id")[0]
	codepipelineClient := codepipeline.NewFromConfig(GetAWSConfig(t))

	getPipelineOutput, err := codepipelineClient.GetPipeline(context.TODO(), &codepipeline.GetPipelineInput{Name: &pipelineId})
	if err != nil {
		t.Errorf("Error getting pipeline %s: %v", pipelineId, err)
	}

	t.Run("TestDoesPipelineExist", func(t *testing.T) {
		require.Equal(t, pipelineId, *getPipelineOutput.Pipeline.Name, "Pipeline ID does not match")
		require.NotEmpty(t, (*getPipelineOutput).Pipeline.Stages, "Pipeline does not have any stages")
	})

	//TODO: Add tests to verify that the pipeline runs successfully
}

func GetAWSConfig(t *testing.T) (cfg aws.Config) {
	cfg, err := config.LoadDefaultConfig(context.TODO())
	require.NoErrorf(t, err, "unable to load SDK config, %v", err)
	return cfg
}
