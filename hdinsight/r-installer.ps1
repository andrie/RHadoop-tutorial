<# 
.SYNOPSIS 
  Install R to HDInsight cluster.
   
.DESCRIPTION 
  This installs R on HDInsight cluster and it runs on YARN. 
 
.EXAMPLE 
  .\r-installer-v02.ps1 -RSrc https://hdiconfigactions.blob.core.windows.net/rconfigactionv01/R-3.1.1-win.exe -RmrSrc https://hdiconfigactions.blob.core.windows.net/rconfigactionv01/rmr2_3.1.2.zip -RhdfsSrc https://hdiconfigactions.blob.core.windows.net/rconfigactionv01/rhdfs_1.0.8.zip
#> 

param ( 
    # The binary executable installer location for R. 
    [Parameter()]
    [String]$RSrc,
 
    # The zip file for R MapReduce.
    [Parameter()]
    [String]$RmrSrc,

    # The zip file for R HDFS.
    [Parameter()]
    [String]$RhdfsSrc)

# Use default parameters in case they are not specified.
if (!$RSrc) 
{ 
    $RSrc = "https://hdiconfigactions.blob.core.windows.net/rconfigactionv01/R-3.1.1-win.exe"; 
}
if (!$RmrSrc) 
{ 
    $RmrSrc = "https://hdiconfigactions.blob.core.windows.net/rconfigactionv01/rmr2_3.1.2.zip"; 
}
if (!$RhdfsSrc) 
{
    $RhdfsSrc = "https://hdiconfigactions.blob.core.windows.net/rconfigactionv01/rhdfs_1.0.8.zip";
}

# Download config action module from a well-known directory.
$CONFIGACTIONURI = "https://hdiconfigactions.blob.core.windows.net/configactionmodulev02/HDInsightUtilities-v02.psm1";
$CONFIGACTIONMODULE = "C:\HDInsightUtilities.psm1";
$webclient = New-Object System.Net.WebClient;
$webclient.DownloadFile($CONFIGACTIONURI, $CONFIGACTIONMODULE);

# (TIP) Import config action helper method module to make writing config action easy.
if (Test-Path ($CONFIGACTIONMODULE))
{ 
    Import-Module $CONFIGACTIONMODULE;
} 
else
{
    Write-Output "Failed to load HDInsightUtilities module, exiting ...";
    exit;
}

# (TIP) Write-HDILog is the way to write to STDOUT and STDERR in HDInsight config action script.
Write-HDILog "Starting R installation at: $(Get-Date)";

$rInstallationRoot = (Get-Item "$env:HADOOP_HOME").parent.FullName+'\R\R-3.1.1';
$rExecutableDir = $rInstallationRoot + '\bin\x64';

# (TIP) Test whether the destination file already exists and this makes the script idempotent so it functions properly upon reboot and reimage.
if (Test-Path $rInstallationRoot) 
{
    Write-HDILog "Destination: $rInstallationRoot already exists, exiting ...";
    exit;
}

# Install R.
# (TIP) It is always good to download to user temporary location.
$rDest = $env:temp + '\' + [guid]::NewGuid() + '.exe';
Save-HDIFile -SrcUri $RSrc -DestFile $rDest;
Start-Process -wait $rDest "/COMPONENTS=x64,main,translation /DIR=$rInstallationRoot /SILENT";
Remove-Item $rDest;

# Download rmr and rhdfs libraries.
$rmrDest = $env:temp + '\rmr2_3.1.2.zip';
Save-HDIFile -SrcUri $RmrSrc -DestFile $rmrDest; 
$rhdfsDest = $env:temp + '\rhdfs_1.0.8.zip';
Save-HDIFile -SrcUri $RhdfsSrc -DestFile $rhdfsDest;

# Install RMR and RHDFS.
[Environment]::SetEnvironmentVariable('PATH', $env:PATH + ';' + $rExecutableDir, 'Process');
$output = Invoke-HDICmdScript -CmdToExecute "RScript.exe -e ""install.packages(c('XML', 'getopt', 'dplyr', 'RCurl', 'rJava', 'Rcpp', 'RJSONIO', 'bitops', 'digest', 'functional', 'reshape2', 'stringr', 'plyr',  'caTools', 'stringdist', 'R.utils'), repos='http://ftp.heanet.ie/mirrors/cran.r-project.org/')""";

Write-HDILog $output;
$output = Invoke-HDICmdScript -CmdToExecute "R.exe CMD INSTALL $rmrDest";
Write-HDILog $output;
$output = Invoke-HDICmdScript -CmdToExecute "R.exe CMD INSTALL $rhdfsDest";
Write-HDILog $output;

# (TIP) Please clean up temporary files when no longer needed.
Remove-Item $rmrDest;
Remove-Item $rhdfsDest;

# Config environment variables.
[Environment]::SetEnvironmentVariable('PATH', $env:PATH + ';' + $rExecutableDir + ';' + $env:JAVA_HOME + '\jre\bin\server', 'Machine');
[Environment]::SetEnvironmentVariable('HADOOP_CMD', $env:HADOOP_HOME + '\bin\hadoop', 'Machine');
[Environment]::SetEnvironmentVariable('HDFS_CMD', $env:HADOOP_HOME + '\bin\hdfs', 'Machine');
[Environment]::SetEnvironmentVariable('HADOOP_STREAMING', (gci ($env:HADOOP_HOME + '\share\hadoop\tools\lib') -filter *streaming* | Select-Object -First 1 | % { $_.FullName }), 'Machine');

# Restart nodemanager to pick up environment variable changes.
if (Get-HDIService -ServiceName nodemanager) 
{
    Restart-Service nodemanager;
}

Write-HDILog "Done with R installation at: $(Get-Date)";