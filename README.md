# AWS S3 Multipart Upload Using AWS CLI & PowerShell

## 📌 Project Overview

This project demonstrates how to upload a large file to **Amazon S3** using **Multipart Upload** with AWS CLI and PowerShell.

Instead of uploading the complete file as one object, the file is divided into smaller parts. Each part is uploaded separately and finally all parts are combined into one object in Amazon S3.


## 🏗️ Architecture Diagram

This diagram shows the complete AWS S3 Multipart Upload workflow used in this project.

![AWS S3 Multipart Upload Architecture](docs/architecture-diagram.png)

## 🛠️ Technologies Used

* Amazon S3
* AWS CLI
* PowerShell
* Windows
* JSON
* Git & GitHub

## 🎯 Project Objective

The main objectives of this project are:

* Understand Amazon S3 Multipart Upload.
* Upload large files in smaller parts.
* Use AWS CLI for S3 operations.
* Automate file splitting using PowerShell.
* Upload individual parts to S3.
* Collect ETags for uploaded parts.
* Complete the Multipart Upload.
* Verify the final object in S3.

## 📂 Project Structure

```text
aws-s3-multipart-upload-cli-powershell/
│
├── README.md
├── LICENSE
├── .gitignore
│
├── scripts/
│   ├── split-movie.ps1
│   └── upload-multipart.ps1
│
├── config/
│   └── fileparts.json
│
├── commands/
│   └── aws-cli-commands.md
│
├── screenshots/
│   ├── 01-file-split.png
│   ├── 02-create-multipart-upload.png
│   ├── 03-upload-parts.png
│   ├── 04-list-parts.png
│   ├── 05-complete-upload.png
│   └── 06-s3-final-object.png
│
└── docs/
    └── multipart-upload-workflow.md
```

## 🔄 Multipart Upload Workflow

### 1. Split the Large File

A large file is divided into smaller parts using PowerShell.

Example:

```text
movie.mkv
    │
    ├── part-1
    ├── part-2
    ├── part-3
    ├── ...
    └── part-N
```

In this project, the file is divided into approximately **100 MB parts**.

### 2. Create Multipart Upload

AWS CLI is used to initiate a Multipart Upload.

```bash
aws s3api create-multipart-upload \
    --bucket YOUR_BUCKET_NAME \
    --key movie.mkv
```

AWS returns an **UploadId**.

Example:

```text
UploadId = xxxxxxxxxxxxxxxxx
```

### 3. Upload Individual Parts

Each file part is uploaded separately.

Example:

```bash
aws s3api upload-part \
    --bucket YOUR_BUCKET_NAME \
    --key movie.mkv \
    --part-number 1 \
    --body part-1 \
    --upload-id YOUR_UPLOAD_ID
```

The command returns an **ETag**.

Example:

```json
{
    "ETag": "\"xxxxxxxxxxxxxxxx\""
}
```

### 4. Upload All Parts

The same process is repeated for every part.

```text
Part 1 → S3 → ETag
Part 2 → S3 → ETag
Part 3 → S3 → ETag
...
Part N → S3 → ETag
```

### 5. Store Part Information

The Part Number and ETag are stored in JSON format.

Example:

```json
{
  "Parts": [
    {
      "PartNumber": 1,
      "ETag": "ETAG_OF_PART_1"
    },
    {
      "PartNumber": 2,
      "ETag": "ETAG_OF_PART_2"
    }
  ]
}
```

### 6. Complete Multipart Upload

After all parts are uploaded, the Multipart Upload is completed.

```bash
aws s3api complete-multipart-upload \
    --bucket YOUR_BUCKET_NAME \
    --key movie.mkv \
    --upload-id YOUR_UPLOAD_ID \
    --multipart-upload file://config/fileparts.json
```

Amazon S3 then combines all uploaded parts into the final object.

## ✅ Final Result

```text
Local Large File
       │
       ▼
Split into Parts
       │
       ▼
Upload Parts to S3
       │
       ▼
Collect ETags
       │
       ▼
Complete Multipart Upload
       │
       ▼
Final Object in Amazon S3
```

## 🔐 AWS Configuration

Before running the commands, configure AWS CLI:

```bash
aws configure
```

Enter:

```text
AWS Access Key ID
AWS Secret Access Key
Default Region
Default Output Format
```

> Never upload AWS Access Keys, Secret Keys, `.aws` credentials, or other sensitive information to GitHub.

## 📸 Project Screenshots

Screenshots demonstrating the project workflow are available in:

```text
screenshots/
```

They include:

1. File splitting
2. Multipart upload creation
3. Part uploads
4. Uploaded parts
5. Multipart upload completion
6. Final S3 object

## 💡 Why Multipart Upload?

Amazon S3 Multipart Upload is useful when working with large files because:

* Large files can be uploaded in smaller parts.
* Parts can be uploaded independently.
* Failed parts can be retried without restarting the entire upload.
* Uploads can be automated.
* It is suitable for large datasets, videos, backups, and other large objects.

## 📚 Learning Outcomes

Through this project, I learned:

* Amazon S3
* S3 Multipart Upload
* AWS CLI
* PowerShell scripting
* JSON configuration
* ETags
* AWS authentication
* Git & GitHub
* Large-file upload concepts

## 👨‍💻 Author

**Vikas Jagtap**

GitHub: `https://github.com/vikasjagtap9696`

---

⭐ If you found this project useful, feel free to explore the repository.
