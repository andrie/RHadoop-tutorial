# Use unique prefix for cluster resources
$prefix = "andrier"

$settings = New-Object PSObject -Property @{
    # Subscription
    SubscriptionName = "Visual Studio Ultimate with MSDN"

    # Storage account
    StorageAccountName = "$($prefix)hadooptutorial"
    StorageAccountLabel = "RHaddop-tutorial"
    StorageAccountLocation = "West Europe"

    # Cluster
    HDInsightClusterName = "$($prefix)-r-hadoop-tutorial"
    HDInsightContainerName = "$($prefix)-r-hadoop-tutorial-hdfs"
    HDInsightUsername = "admin"
    HDInsightPassword =  "RHadoopTutorial2015!"
    HDInsightClusterSizeInNodes = 2
    HDInsightHeadNodeVMSize = "Large"

    # Custom version of the script referenced at:
    #   Install and use R on HDInsight Hadoop clusters
    #   https://azure.microsoft.com/en-us/documentation/articles/hdinsight-hadoop-r-scripts
    RInstallerScriptUri = "https://raw.githubusercontent.com/StanislawSwierc/RHadoop-tutorial/master/hdinsight/r-installer.ps1"
    #RInstallerScriptUri = "https://raw.githubusercontent.com/$($user)/RHadoop-tutorial/master/hdinsight/r-installer.ps1"
}
