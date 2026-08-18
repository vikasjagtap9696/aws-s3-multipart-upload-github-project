# ============================================================
# AWS S3 MANUAL MULTIPART UPLOAD
# ============================================================
#
# Purpose:
# Uploads split parts to Amazon S3 using the low-level S3 API.
#
# Flow:
#   CreateMultipartUpload
#       -> UploadId
#       -> UploadPart for every part
#       -> Collect ETags
#       -> Create parts.json
#       -> CompleteMultipartUpload
#
# Change only the configuration values below.
# ============================================================

# Your S3 bucket name.
$Bucket = "my-vikas-bucket-multi"

# Final object name in S3.
$Key = "movie-manual.mkv"

# Local folder containing part-001, part-002, ...
$PartsFolder = "D:\movie\parts"

# ------------------------------------------------------------
# Validate AWS CLI and parts folder.
# ------------------------------------------------------------

if (!(Get-Command aws -ErrorAction SilentlyContinue)) {
    throw "AWS CLI was not found. Install AWS CLI and run 'aws --version'."
}

if (!(Test-Path $PartsFolder)) {
    throw "Parts folder not found: $PartsFolder"
}

$Parts = Get-ChildItem "$PartsFolder\part-*" -File | Sort-Object Name

if ($Parts.Count -eq 0) {
    throw "No split parts were found in $PartsFolder"
}

Write-Host ""
Write-Host "Found $($Parts.Count) part(s)."
Write-Host "Creating Multipart Upload..."

# ------------------------------------------------------------
# Step 1: Create the multipart upload.
# AWS returns a unique UploadId.
# ------------------------------------------------------------

$CreateResult = aws s3api create-multipart-upload `
    --bucket $Bucket `
    --key $Key `
    --output json | ConvertFrom-Json

if (!$CreateResult.UploadId) {
    throw "Multipart upload could not be created."
}

$UploadId = $CreateResult.UploadId

Write-Host "UploadId: $UploadId"
Write-Host ""

# Store uploaded part numbers and ETags.
$PartList = @()

try {

    # --------------------------------------------------------
    # Step 2: Upload every part.
    # --------------------------------------------------------

    foreach ($Part in $Parts) {

        $PartNumber = [int]($Part.BaseName -replace "^part-", "")

        Write-Host "Uploading Part $PartNumber / $($Parts.Count)..."

        $UploadResult = aws s3api upload-part `
            --bucket $Bucket `
            --key $Key `
            --part-number $PartNumber `
            --body $Part.FullName `
            --upload-id $UploadId `
            --output json | ConvertFrom-Json

        if (!$UploadResult.ETag) {
            throw "No ETag returned for Part $PartNumber."
        }

        $PartList += [PSCustomObject]@{
            ETag       = $UploadResult.ETag
            PartNumber = $PartNumber
        }

        Write-Host "  ETag: $($UploadResult.ETag)"
    }

    # --------------------------------------------------------
    # Step 3: Create the JSON manifest required by S3.
    # --------------------------------------------------------

    $PartList = $PartList | Sort-Object PartNumber

    $MultipartData = @{
        Parts = @($PartList)
    }

    $JsonPath = Join-Path $PartsFolder "parts.json"

    $MultipartData |
        ConvertTo-Json -Depth 5 |
        Set-Content -Path $JsonPath -Encoding ascii

    Write-Host ""
    Write-Host "Created manifest: $JsonPath"

    # --------------------------------------------------------
    # Step 4: Complete the multipart upload.
    # --------------------------------------------------------

    Write-Host "Completing Multipart Upload..."

    $CompleteResult = aws s3api complete-multipart-upload `
        --bucket $Bucket `
        --key $Key `
        --upload-id $UploadId `
        --multipart-upload "file://$JsonPath"

    if ($LASTEXITCODE -ne 0) {
        throw "CompleteMultipartUpload failed."
    }

    Write-Host ""
    Write-Host "============================================"
    Write-Host "MULTIPART UPLOAD COMPLETED SUCCESSFULLY"
    Write-Host "============================================"
    Write-Host "S3 object: s3://$Bucket/$Key"

}
catch {
    Write-Host ""
    Write-Host "Upload failed. The multipart upload is still open."
    Write-Host "UploadId: $UploadId"
    Write-Host ""
    Write-Host "To abort it, run:"
    Write-Host "aws s3api abort-multipart-upload --bucket $Bucket --key $Key --upload-id `"$UploadId`""
    throw
}
