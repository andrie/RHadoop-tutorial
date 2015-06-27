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
if (!(Get-AzureStorageAccount -StorageAccountName $settings.StorageAccountName -ErrorAction SilentlyContinue)) {
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

# Create cluster configuration
$hdinsightConfig = New-AzureHDInsightClusterConfig `
        -HeadNodeVMSize $settings.HDInsightHeadNodeVMSize `
        -ClusterSizeInNodes $settings.HDInsightClusterSizeInNodes |
    Set-AzureHDInsightDefaultStorage `
        -StorageAccountName $settings.StorageAccountName `
        -StorageAccountKey $storageAccountKey `
        -StorageContainerName $settings.HDInsightContainerName |
    Add-AzureHDInsightScriptAction `
        -Name "Install R" `
        -ClusterRoleCollection HeadNode,DataNode `
        -Uri $settings.RInstallerScriptUri

# Convert plain text user name and password to PSCredential object
$hdinsightPasswordSecureString = ConvertTo-SecureString -String $settings.HDInsightPassword -AsPlainText -Force  
$hdinsightCredential = New-Object -TypeName System.Management.Automation.PSCredential `
    -ArgumentList $settings.HDInsightUsername, $hdinsightPasswordSecureString

# Create cluster
$hdinsightCluster = New-AzureHDInsightCluster `
    -Name $settings.HDInsightClusterName `
    -Config $hdinsightConfig `
    -Credential $hdinsightCredential `
    -Location $settings.StorageAccountLocation

# Check cluster state
Get-AzureHDInsightCluster -Name $settings.HDInsightClusterName 


