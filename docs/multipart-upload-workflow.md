# S3 Multipart Upload Workflow

## 1. Overview

Amazon S3 Multipart Upload allows a large file to be uploaded as multiple smaller parts.

In this project, PowerShell is used to split a large file into smaller parts, and AWS CLI is used to upload those parts to Amazon S3.

## 2. Project Workflow

```text
                Large File
                    │
                    ▼
          PowerShell File Split
                    │
                    ▼
          ┌──────────────────┐
          │   File Parts     │
          ├──────────────────┤
          │ part-001         │
          │ part-002         │
          │ part-003         │
          │ ...              │
          │ part-N           │
          └──────────────────┘
                    │
                    ▼
        Create Multipart Upload
                    │
                    ▼
                UploadId
                    │
                    ▼
          Upload Parts to S3
                    │
                    ▼
             Receive ETags
                    │
                    ▼
           fileparts.json
                    │
                    ▼
       Complete Multipart Upload
                    │
                    ▼
             Amazon S3 Object
```

## 3. Step 1 – Prepare the Large File

Place the large file on the local system.

Example:

```text
movie.mkv
```

The file can be several hundred MB or multiple GB in size.

## 4. Step 2 – Split the File

Run the PowerShell script:

```powershell
.\scripts\split-movie.ps1
```

The script divides the large file into approximately 100 MB parts.

Example:

```text
parts/
├── part-001
├── part-002
├── part-003
├── part-004
└── ...
```

## 5. Step 3 – Create Multipart Upload

AWS CLI creates a Multipart Upload session:

```bash
aws s3api create-multipart-upload \
    --bucket YOUR-BUCKET-NAME \
    --key movie.mkv
```

Amazon S3 returns an `UploadId`.

The UploadId identifies this specific Multipart Upload session.

## 6. Step 4 – Upload Parts

Each part is uploaded separately.

Example:

```bash
aws s3api upload-part \
    --bucket YOUR-BUCKET-NAME \
    --key movie.mkv \
    --part-number 1 \
    --body part-001 \
    --upload-id YOUR-UPLOAD-ID
```

Amazon S3 returns an `ETag` for the uploaded part.

The same process is repeated for all parts.

## 7. Step 5 – Track ETags

Every uploaded part has:

```text
PartNumber
ETag
```

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

This information is required to complete the Multipart Upload.

## 8. Step 6 – Complete the Upload

After all parts are successfully uploaded:

```bash
aws s3api complete-multipart-upload \
    --bucket YOUR-BUCKET-NAME \
    --key movie.mkv \
    --upload-id YOUR-UPLOAD-ID \
    --multipart-upload file://config/fileparts.json
```

Amazon S3 combines the uploaded parts into the final object.

## 9. Step 7 – Verify the Object

Check the S3 bucket:

```bash
aws s3 ls s3://YOUR-BUCKET-NAME/
```

You should see:

```text
movie.mkv
```

You can also check object metadata:

```bash
aws s3api head-object \
    --bucket YOUR-BUCKET-NAME \
    --key movie.mkv
```

## 10. Error Handling

If the Multipart Upload is no longer required, abort it:

```bash
aws s3api abort-multipart-upload \
    --bucket YOUR-BUCKET-NAME \
    --key movie.mkv \
    --upload-id YOUR-UPLOAD-ID
```

This prevents incomplete multipart uploads from remaining in the bucket.

## 11. Why Use Multipart Upload?

Multipart Upload is useful for large files because:

* Large files can be divided into smaller parts.
* Parts can be uploaded independently.
* Failed parts can be retried.
* Uploads can be automated.
* It is suitable for large videos, backups, datasets, and archives.

## 12. Technologies

| Technology | Purpose                                  |
| ---------- | ---------------------------------------- |
| Amazon S3  | Store the final object                   |
| AWS CLI    | Perform S3 operations                    |
| PowerShell | Split and automate files                 |
| JSON       | Store part numbers and ETags             |
| GitHub     | Project documentation and source control |

## 13. Final Architecture

```text
Windows Machine
      │
      │ PowerShell
      ▼
Large File
      │
      ▼
100 MB Parts
      │
      │ AWS CLI
      ▼
Amazon S3 Multipart Upload
      │
      ├── Part 1 → ETag
      ├── Part 2 → ETag
      ├── Part 3 → ETag
      ├── ...
      └── Part N → ETag
      │
      ▼
Complete Multipart Upload
      │
      ▼
Final Object
      │
      ▼
Amazon S3 Bucket
```
