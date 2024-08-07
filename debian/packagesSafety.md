
mmands, and Scripts to Identify Altered Binaries

To identify if common binaries (e.g., `usermod`, `sudo`, `cd`, etc.) have been altered, you can use a combination of hash checks and file integrity tools. Here's a step-by-step approach:

#### 1. Hash Check Against Repository

1. **Generate Hashes for Known Good Binaries:**
Use a clean, trusted system to generate hashes for the binaries you want to verify. 

```sh
# Generate hashes for common binaries
for bin in /usr/bin/usermod /usr/bin/sudo /usr/bin/cd; do
sha256sum $bin >> trusted_binaries.sha256
done
```

2. **Compare Hashes on Target System:**
Transfer the `trusted_binaries.sha256` file to the target system and compare the hashes.

```sh
# Compare hashes on the target system
for bin in /usr/bin/usermod /usr/bin/sudo /usr/bin/cd; do
sha256sum -c trusted_binaries.sha256 --ignore-missing | grep -v 'OK'
done
```

#### 2. Using File Integrity Tools

**AIDE (Advanced Intrusion Detection Environment):**
AIDE is a file integrity checker that can be used to verify the integrity of your system binaries.

1. **Install AIDE:**
```sh
sudo apt-get install aide -y
```

2. **Initialize AIDE Database:**
```sh
sudo aideinit
sudo cp /var/lib/aide/aide.db.new /var/lib/aide/aide.db
```

3. **Check for Changes:**
```sh
sudo aide --check
```

#### 3. Custom Script to Verify Binary Integrity

                                                                   Here's a custom script that generates and compares SHA-256 hashes of critical binaries:

1. **Generate Trusted Hashes (on a clean system):**

```sh
#!/bin/bash
# Generate trusted hashes for critical binaries
BINARIES=(
                                                                                      "/usr/bin/usermod"
"/usr/bin/sudo"
                                                                                                    "/usr/bin/cd"
                                                                                                       )
 
TRUSTED_HASHES="trusted_binaries.sha256"
 
for bin in "${BINARIES[@]}"; do
sha256sum "$bin" >> "$TRUSTED_HASHES"
done
                                                                                                                                
echo "Trusted hashes saved to $TRUSTED_HASHES"
```

2. **Check Binaries on Target System:**

```sh
#!/bin/bash
# Check integrity of critical binaries
TRUSTED_HASHES="trusted_binaries.sha256"
TEMP_HASHES="temp_binaries.sha256"
 
if [ ! -f "$TRUSTED_HASHES" ]; then
echo "Trusted hashes file not found!"
exit 1
fi
 
                                                                                                                                                                                  BINARIES=(
"/usr/bin/usermod"
"/usr/bin/sudo"
                                                                                                                                                                                                       "/usr/bin/cd"
)
 
for bin in "${BINARIES[@]}"; do
sha256sum "$bin" >> "$TEMP_HASHES"
done
 
# Compare hashes
diff "$TRUSTED_HASHES" "$TEMP_HASHES"
 
if [ $? -eq 0 ]; then
echo "All binaries are intact."
else
echo "WARNING: Some binaries have been altered!"
fi
 
# Clean up
rm "$TEMP_HASHES"
```

3. **Run the Scripts:**

- On a clean system, run the first script to generate `trusted_binaries.sha256`.
- Transfer `trusted_binaries.sha256` to the target system.
                                                                                                                                                                                                                                                                                  - Run the second script on the target system to check the integrity of the binaries.

#### 4. Advanced Techniques

**Use `rpm` or `dpkg` for Package Verification:**

For RPM-based systems (e.g., CentOS, RHEL):

```sh
# Verify installed packages
sudo rpm -Va | grep '^..5'
```

For Debian-based systems (e.g., Ubuntu):

```sh
# Verify installed packages
sudo debsums -c
```

This will check for any changes in the files managed by the package manager.

By following these steps and utilizing the provided scripts and tools, you can effectively verify the integrity of critical system binaries and ensure they have not been altered.
