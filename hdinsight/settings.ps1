# Use unique prefix for cluster resources
$user = "andrie"

# Use user as a prefix for related resources
$prefix = $user

$settings = New-Object PSObject -Property @{
    # Subscription
    SubscriptionName = "Visual Studio Ultimate with MSDN"

    # Storage account
    StorageAccountName = "$($prefix)rhadooptutorial"
    StorageAccountLabel = "RHaddop-tutorial"
    StorageAccountLocation = "West Europe"

    # Cluster
    HDInsightClusterName = "$($prefix)-r-hadoop-tutorial"
    HDInsightContainerName = "$($prefix)-r-hadoop-tutorial-hdfs"
    HDInsightUsername = $user
    HDInsightPassword =  "RHadoopTutorial2015!"
    HDInsightClusterSizeInNodes = 2
    HDInsightHeadNodeVMSize = "Large"
}
