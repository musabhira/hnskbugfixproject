# 🔐 Pocket Mates Android Keystore Permanent Backup & Recovery Guide

## 📌 1. Keystore Information & Credentials
- **File Name**: `upload-keystore.jks`
- **Location**: `android/upload-keystore.jks` and `android/app/upload-keystore.jks`
- **Properties Config**: `android/key.properties`
- **Alias Name**: `upload`
- **Store Password**: `pocket123`
- **Key Password**: `pocket123`
- **Validity**: Until **August 7, 2053** (27+ years validity)
- **SHA-1 Fingerprint**: `28:6F:CA:9E:14:18:8A:FF:90:FE:23:34:54:06:B1:D3:AA:54:65:9D`
- **SHA-256 Fingerprint**: `1A:29:BF:0D:98:36:2C:D0:42:D1:30:FE:9C:E5:6D:C7:13:41:70:8C:B8:1E:80:92:C4:8D:0E:53:20:90:FA:2F`

---

## 🛡️ 2. Why Did You Lose Your Keystore Last Time?
In Flutter and Android projects, `.gitignore` hides:
```
*.jks
*.keystore
key.properties
```
Because of this, when you push code to GitHub, **the `.jks` keystore file is NEVER uploaded to GitHub**. If your PC crashed or was formatted, the file was permanently lost from your hard drive.

---

## ⚡ 3. How to Restore the Keystore File from Base64 (Any PC, Anywhere)
If you ever lose `upload-keystore.jks`, open PowerShell in the `android/` folder and run this single command:

```powershell
[System.Convert]::FromBase64String("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") | Set-Content -Encoding Byte upload-keystore.jks
```

---

## 🏛️ 4. Google Play Console Recovery (If Keystore is Ever Lost)
Modern Android apps use **Google Play App Signing**. Google holds the master app signing key, and you only hold the **Upload Key**.
If you ever lose the upload key, Google Play allows you to reset it in **24 to 48 hours**:

1. Log into [Google Play Console](https://play.google.com/console).
2. Select **Pocket Mates**.
3. Go to **Release** > **Setup** > **App integrity** (or **App signing**).
4. Scroll down and click **"Request upload key reset"**.
5. Select the reason: **"I lost my upload key"**.
6. Upload the `upload_certificate.pem` file (located in `android/upload_certificate.pem` or copied directly from the Admin Panel).
7. Google Play Support will update your upload key within 48 hours, and you can immediately publish updates again!
