# Calculate the total size of blobs in all containers in a specified Azure storage account.
param (
    [ValidateNotNullOrEmpty()] [string]$ResourceGroupName = 'ResourceGroupName',
    [ValidateNotNullOrEmpty()] [string]$StorageAccountName = 'StorageAccountName'
)

$containerstats = @()
$storageAccount = Get-AzStorageAccount -ResourceGroupName $ResourceGroupName -Name $StorageAccountName
$Ctx = $storageAccount.Context

$containers = Get-AzStorageContainer -Context $Ctx -MaxCount 5000

# Initialize a variable to accumulate blob sizes
$total_blob_size = 0

# Iterate over each container
foreach ($container in $containers) {
    $blobs = Get-AzStorageBlob -Context $Ctx -Container $container.Name -MaxCount 5000
    foreach ($blob in $blobs) {
        # Accumulate blob sizes
        $total_blob_size += $blob.Length
    }
}

# Convert the total size to human-readable format (e.g., MB or GB)
function ConvertToHumanReadableSize($sizeInBytes) {
    $suffixes = "B", "KB", "MB", "GB", "TB"
    $index = 0
    while ($sizeInBytes -ge 1024 -and $index -lt $suffixes.Length) {
        $sizeInBytes /= 1024
        $index++
    }
    return "{0:N2} {1}" -f $sizeInBytes, $suffixes[$index]
}

# Print the total size
Write-Host "Total blob size in the storage account: $(ConvertToHumanReadableSize $total_blob_size)"
