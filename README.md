# Extract Source Map

This is a Bash script that downloads JavaScript `.map` files from a list of URLs and extracts their embedded source code files to a specified output directory.

---

## 📦 Prerequisites

Make sure the following are installed:

```bash
sudo apt-get install jq wget
```

Make the script executable:
```bash
chmod +x unpack_map.sh
```
---
## 🚀 Usage
Option 1: With Arguments
```bash
./unpack_map.sh URLs.txt outputFolder
```
---
Option 2: Interactive Mode
```bash
./unpack_map.sh
```
You'll be prompted to enter:
```bash
Enter path to txt file with URLs: URLs.txt
Enter output folder path: outputFolder
```

📄 Input Format Example

URLs.txt:
```
https://example.com/assets/app.js.map
https://cdn.site.net/build/main.js.map?ver=1.2.3
```
