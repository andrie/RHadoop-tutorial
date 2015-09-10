$ErrorActionPreference = "Stop"

# Load settings
. .\settings.ps1

# Check if Azure Powershell module is available
if (Get-Module -ListAvailable Azure) {
    Write-Host "Importing Azure Powershell module"
    Import-Module -Name Azure
} else {
    throw "Azure module not available. Please refer to: How to install and configure Azure PowerShell " +
       "(https://azure.microsoft.com/en-us/documentation/articles/powershell-install-configure)"
}

# Make Azure account and its subscriptions are available in current session
Add-AzureAccount

# Select subscription in case there are several subscriptions connected to the account
Select-AzureSubscription $settings.SubscriptionName

# Check if storage account exist and create it otherwise
if (!(Get-AzureStorageAccount -StorageAccountName $settings.StorageAccountName -ErrorAction SilentlyContinue  -WarningAction silentlyContinue)) {
    Write-Host "Creating new storage account: $($settings.StorageAccountName)"
    New-AzureStorageAccount `
        -StorageAccountName $settings.StorageAccountName `
        -Label $settings.StorageAccountLabel `
        -Location $settings.StorageAccountLocation
}

# Select storage account
Set-AzureSubscription `
    -SubscriptionName $settings.SubscriptionName `
    -CurrentStorageAccountName $settings.StorageAccountName

# Get the storage account key
$storageAccountKey = (Get-AzureStorageKey $settings.StorageAccountName).Primary

# Create the storage context object
$storageContext = New-AzureStorageContext -StorageAccountName $settings.StorageAccountName -StorageAccountKey $storageAccountKey

# Check if container exists and create it otherwise
if (!(Get-AzureStorageContainer -Name $settings.HDInsightContainerName -ErrorAction SilentlyContinue)) {
    Write-Host "Creating new storage container: $($settings.HDInsightContainerName)"
    New-AzureStorageContainer -Name $settings.HDInsightContainerName
}

# Check if the dataset exist and upload it otherwise.
$datasetPrefix = "user/$($settings.HDInsightUsername)/nyctaxitrips"
if (!(Get-AzureStorageBlob -Prefix $datasetPrefix -Container $settings.HDInsightContainerName)) {
    # Dataset consists of 12 trip_data and 12 trip_fare files. They can be copied from
    # a publicly available storage container. The most efficient way is to start asynchronous
    # copy operations and wait for their completion.
    for ($i=1; $i -le 12; $i++) {
        Start-CopyAzureStorageBlob `
            -SrcUri "https://nyctaxitrips.blob.core.windows.net/data/trip_fare_$i.csv.zip" `
            -DestBlob "$datasetPrefix/fare/trip_fare_$i.csv.zip" `
            -DestContainer $settings.HDInsightContainerName  `
            -DestContext $storageContext 

        Start-CopyAzureStorageBlob `
            -SrcUri "https://nyctaxitrips.blob.core.windows.net/data/trip_data_$i.csv.zip" `
            -DestBlob "$datasetPrefix/data/trip_data_$i.csv.zip" `
            -DestContainer $settings.HDInsightContainerName  `
            -DestContext $storageContext 
    }

    # Wait for all operations to complete.
    $pendingBlobsCount = 24
    while ($pendingBlobsCount -gt 0) {
        Write-Host $(Get-Date) : "Waiting for $pendingBlobsCount/24 asynchronous copy operations."
        Start-Sleep -Seconds 60
        $pendingBlobsCount = (Get-AzureStorageBlob -Prefix $datasetPrefix -Container $settings.HDInsightContainerName |
            Get-AzureStorageBlobCopyState |
            ?{ $_.Status -eq "Pending" } |
            Measure-Object).Count
    }
}

# Prepare R installation  script. Nodes should be able to download it by its Uri.
$scriptActionBlob = Set-AzureStorageBlobContent `
    -Container $settings.HDInsightContainerName `
    -File "r-installer.ps1" `
    -Blob "user/$($settings.HDInsightUsername)/r-installer.ps1" `
    -Force
$scriptActionBlobToken = New-AzureStorageBlobSASToken -ICloudBlob $scriptActionBlob.ICloudBlob -Permission r -ExpiryTime (Get-Date).AddDays(1)
$scriptActionUri = $scriptActionBlob.ICloudBlob.Uri.AbsoluteUri + $scriptActionBlobToken

# Create cluster configuration
$hdinsightConfig = New-AzureHDInsightClusterConfig `
        -HeadNodeVMSize $settings.HDInsightHeadNodeVMSize `
        -ClusterSizeInNodes $settings.HDInsightClusterSizeInNodes |
    Set-AzureHDInsightDefaultStorage `
        -StorageAccountName $settings.StorageAccountName `
        -StorageAccountKey $storageAccountKey `
        -StorageContainerName $settings.HDInsightContainerName |
    Add-AzureHDInsightScriptAction `
        -Name "Install R (x64) on Head and Data nodes" `
        -ClusterRoleCollection HeadNode,DataNode `
        -Uri $scriptActionUri

# Convert plain text user name and password to PSCredential object
$hdinsightPasswordSecureString = ConvertTo-SecureString -String $settings.HDInsightPassword -AsPlainText -Force  
$hdinsightCredential = New-Object -TypeName System.Management.Automation.PSCredential `
    -ArgumentList $settings.HDInsightUsername, $hdinsightPasswordSecureString

# Create cluster
Write-Host "$(Get-Date) : Creating new cluster"
$hdinsightCluster = New-AzureHDInsightCluster `
    -Name $settings.HDInsightClusterName `
    -Config $hdinsightConfig `
    -Credential $hdinsightCredential `
    -Location $settings.StorageAccountLocation `
    -ErrorAction Continue
Write-Host "$(Get-Date) : Operation completed"

# Check cluster state
Get-AzureHDInsightCluster -Name $settings.HDInsightClusterName
