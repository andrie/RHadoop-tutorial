$ErrorActionPreference = "Stop"

# Load settings
. .\settings.ps1

# Delete cluster
Remove-AzureHDInsightCluster -Name $settings.HDInsightClusterName