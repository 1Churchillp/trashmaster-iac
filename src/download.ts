import { S3Client, GetObjectCommand } from "@aws-sdk/client-s3";
import { createWriteStream } from "fs";
import { pipeline } from "stream/promises";
import path from "path";
import os from "os";

async function downloadFile() {
  const client = new S3Client({ region: "us-east-1" });
  const desktopPath = path.join(os.homedir(), "Desktop", "downloaded-file.bin");

  const command = new GetObjectCommand({
    Bucket: "trashmaster-ami-backup-2026",
    Key: "ami-0387ac14c76aca343.bin",
  });
  try {
    const response = await client.send(command);
    if (response.Body) {
      // Pipe the S3 readable stream to a local file write stream
      await pipeline(response.Body as any, createWriteStream(desktopPath));
      console.log(`File downloaded to: ${desktopPath}`);
    }
  } catch (err) {
    console.error("Error downloading file:", err);
  }
}

downloadFile();
