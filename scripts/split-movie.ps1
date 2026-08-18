# ============================================================
# AWS S3 MULTIPART UPLOAD - FILE SPLITTER
# ============================================================
#
# Purpose:
# Splits a large file into smaller parts for an S3 Multipart Upload.
#
# Change only:
#   $FilePath
#   $OutputFolder
#   $PartSize
# ============================================================

# Path of the original file.
$FilePath = "D:\movie\movie.mkv"

# Folder where split parts will be created.
$OutputFolder = "D:\movie\parts"

# Size of each part.
# 100 MB is suitable for the user's 1.3 GiB test file.
$PartSize = 100MB

# Create output folder if it does not exist.
if (!(Test-Path $OutputFolder)) {
    New-Item -ItemType Directory -Path $OutputFolder | Out-Null
}

# Open the original file for reading.
$FileStream = [System.IO.File]::OpenRead($FilePath)

# Allocate a buffer equal to the selected part size.
$Buffer = New-Object byte[] $PartSize

# Start part numbering at 1.
$PartNumber = 1

try {
    while ($true) {

        # Read up to one part from the original file.
        $BytesRead = $FileStream.Read($Buffer, 0, $Buffer.Length)

        # Stop when the complete file has been read.
        if ($BytesRead -eq 0) {
            break
        }

        # Create names such as part-001, part-002, etc.
        $PartPath = Join-Path $OutputFolder ("part-{0:D3}" -f $PartNumber)

        # Create the current part file.
        $PartStream = [System.IO.File]::Create($PartPath)

        try {
            # Write only the bytes actually read.
            $PartStream.Write($Buffer, 0, $BytesRead)
        }
        finally {
            $PartStream.Close()
        }

        Write-Host "Created Part $PartNumber : $PartPath ($BytesRead bytes)"

        $PartNumber++
    }
}
finally {
    # Always close the original file.
    $FileStream.Close()
}

Write-Host ""
Write-Host "=========================================="
Write-Host "FILE SPLITTING COMPLETED"
Write-Host "Total parts: $($PartNumber - 1)"
Write-Host "Parts location: $OutputFolder"
Write-Host "=========================================="
