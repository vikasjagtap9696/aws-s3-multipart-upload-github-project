# Multipart Upload Workflow

## 1. Split

A large local file is split into smaller parts.

## 2. Initiate

`CreateMultipartUpload` starts a multipart upload and returns a unique `UploadId`.

## 3. Upload Parts

Each part is uploaded with `UploadPart`, a part number, and the same `UploadId`.

## 4. ETags

S3 returns an ETag for each uploaded part. The part number and ETag are required for completion.

## 5. Complete

`CompleteMultipartUpload` receives the ordered list of parts and ETags. S3 assembles the parts into one final object.

## 6. Failure Recovery

If the upload is interrupted, failed parts can be retried. If the upload is no longer needed, `AbortMultipartUpload` should be used to clean it up.
