# AWS CLI Commands – S3 Multipart Upload

This file contains the AWS CLI commands used in the S3 Multipart Upload project.

## 1. Check AWS CLI Installation

```bash
aws --version
```

## 2. Configure AWS CLI

```bash
aws configure
```

Enter your:

```text
AWS Access Key ID
AWS Secret Access Key
Default region name
Default output format
```

> Never commit AWS credentials to GitHub.

## 3. Verify AWS Identity

```bash
aws sts get-caller-identity
```

## 4. List S3 Buckets

```bash
aws s3 ls
```

## 5. List Objects in a Bucket

```bash
aws s3 ls s3://YOUR-BUCKET-NAME/
```

## 6. Create Multipart Upload

```bash
aws s3api create-multipart-upload \
    --bucket YOUR-BUCKET-NAME \
    --key movie.mkv
```

The command returns an `UploadId`.

## 7. Upload a Part

```bash
aws s3api upload-part \
    --bucket YOUR-BUCKET-NAME \
    --key movie.mkv \
    --part-number 1 \
    --body part-001 \
    --upload-id YOUR-UPLOAD-ID
```

The response contains an `ETag`.

Example:

```json
{
    "ETag": "\"xxxxxxxxxxxxxxxx\""
}
```

## 8. List Uploaded Parts

```bash
aws s3api list-parts \
    --bucket YOUR-BUCKET-NAME \
    --key movie.mkv \
    --upload-id YOUR-UPLOAD-ID
```

This command verifies the parts that have already been uploaded.

## 9. Complete Multipart Upload

Create a JSON file containing the uploaded parts and their ETags.

Example:

```json
{
  "Parts": [
    {
      "PartNumber": 1,
      "ETag": "ETAG_PART_1"
    },
    {
      "PartNumber": 2,
      "ETag": "ETAG_PART_2"
    }
  ]
}
```

Then run:

```bash
aws s3api complete-multipart-upload \
    --bucket YOUR-BUCKET-NAME \
    --key movie.mkv \
    --upload-id YOUR-UPLOAD-ID \
    --multipart-upload file://config/fileparts.json
```

## 10. Verify Final Object

```bash
aws s3api head-object \
    --bucket YOUR-BUCKET-NAME \
    --key movie.mkv
```

Or:

```bash
aws s3 ls s3://YOUR-BUCKET-NAME/
```

## 11. List Incomplete Multipart Uploads

```bash
aws s3api list-multipart-uploads \
    --bucket YOUR-BUCKET-NAME
```

## 12. Abort Multipart Upload

If an upload fails and you want to remove the incomplete upload:

```bash
aws s3api abort-multipart-upload \
    --bucket YOUR-BUCKET-NAME \
    --key movie.mkv \
    --upload-id YOUR-UPLOAD-ID
```

## Complete Workflow

```text
aws configure
      ↓
Create Multipart Upload
      ↓
Get UploadId
      ↓
Upload Part 1
      ↓
Upload Part 2
      ↓
Upload Part 3
      ↓
      ...
      ↓
Upload Part N
      ↓
Collect ETags
      ↓
Complete Multipart Upload
      ↓
Final Object in S3
```

## Security Notes

Never commit these files or values to GitHub:

* AWS Access Key
* AWS Secret Access Key
* AWS Session Token
* `.aws/credentials`
* `.env`
* Private configuration files

Use IAM permissions with the minimum access required for the project.
