lly edit the `config.xml` file for disabling the captive portal, changing the admin user, adding a new admin user, and applying some extra hardening configurations, follow the instructions below:

### Step 1: Download and Edit `config.xml`

1. **Download the `config.xml` file** from your pfSense box:

```sh
scp admin@100.80.4.30:/cf/conf/config.xml ~/ir/FreeBSD/config.xml
```

2. **Open the `config.xml` file** in a text editor:

```sh
vim ~/ir/FreeBSD/config.xml

```

### Step 2: Disable Captive Portal

Locate the `<captiveportal>` section and ensure the `<enabled>` tag is set to `false`:

```xml
  <captiveportal>
    <enabled>false</enabled>
  ...
  </captiveportal>
```

### Step 3: Change the Existing Admin User and Add a New Admin User

1. **Change the existing admin user**:
 
Locate the `<system>` section, then the user you want to modify (e.g., `admin`). Change the `<name>` tag to the new username.

```xml
<system>
    ...
    <user>
      <name>newadmin</name>
      <password>$2y$10$...</password> <!-- Ensure the password hash is correct -->
                                                                       <priv>
      <name>admin</name>
      </priv>
      ...
    </user>
    ...
</system>
```

2. **Add a new admin user**:
 
Add a new `<user>` entry within the `<system>` section with appropriate details. Make sure to generate a password hash using a tool like `openssl`.

```xml
<system>
...
<user>
  <name>newadminuser</name>
  <password>$2y$10$...</password> <!-- Ensure the password hash is correct -->
  <priv>
  <name>admin</name>
                                                                                                                                                                   </priv>
...
</user>
...
</system>
```

Example for generating a password hash:

```sh
openssl passwd -1 'your_password'
```

### Step 4: Extra Hardening Configurations

1. **Disable Root Login**:
 
Ensure the root login is disabled by setting the `<permitrootlogin>` tag to `no`.

```xml
<system>
...
  <ssh>
    <permitrootlogin>no</permitrootlogin>
  </ssh>
...
</system>
```

2. **Restrict WebGUI Access**:
 
Allow access to the WebGUI only from specific IP addresses.

```xml
<system>
...
  <webgui>
  <ssl_certref>your_cert_id</ssl_certref>
                                                                                                                                                                                                                                                                                         <disablehttpredirect>true</disablehttpredirect>
  <allowedips>192.168.1.100,192.168.1.101</allowedips> <!-- Add your allowed IPs here -->
  </webgui>
...
</system>
                                                                                                                                                                                                                                                                                                              ```

3. **Enable HTTPS for WebGUI**:
 
Ensure the WebGUI is configured to use HTTPS.

```xml
<system>
                                                                                                                                                                                                                                                                                                                               ...
  <webgui>
    <protocol>https</protocol>
    <ssl_certref>your_cert_id</ssl_certref>
  </webgui>
...
</system>
```

4. **Set Stronger Password Policies**:
 
Set password policies to enforce stronger passwords.

```xml
<system>
...
  <passwordpolicy>
  <minlength>12</minlength>
  <requirecomplexity>true</requirecomplexity>
  </passwordpolicy>
...
</system>
```

                                                                                                                                                                                                                                                                                                                                                                                                                      ### Step 5: Upload and Apply the Modified `config.xml`

1. **Upload the modified `config.xml` file** back to your pfSense box:

```sh
scp /path/to/local/config.xml admin@pfsense:/cf/conf/config.xml
```

2. **Reload the configuration** to apply changes:

```sh
ssh admin@pfsense
pfSsh.php playback config reload
```

### Summary of Changes to `config.xml`

```xml
<captiveportal>
  <enabled>false</enabled>
  ...
</captiveportal>

<system>
  ...
  <user>
    <name>newadmin</name>
    <password>$2y$10$...</password> <!-- Ensure the password hash is correct -->
    <priv>
      <name>admin</name>
    </priv>
    ...
  </user>
  <user>
    <name>newadminuser</name>
    <password>$2y$10$...</password> <!-- Ensure the password hash is correct -->
    <priv>
      <name>admin</name>
    </priv>
    ...
  </user>
  ...
  <ssh>
    <permitrootlogin>no</permitrootlogin>
  </ssh>
  <webgui>
    <protocol>https</protocol>
    <ssl_certref>your_cert_id</ssl_certref>
    <disablehttpredirect>true</disablehttpredirect>
    <allowedips>192.168.1.100,192.168.1.101</allowedips> <!-- Add your allowed IPs here -->
  </webgui>
  <passwordpolicy>
    <minlength>12</minlength>
    <requirecomplexity>true</requirecomplexity>
  </passwordpolicy>
  ...
</system>
```

By following these steps and making the specified changes, you can manually edit the `config.xml` file to disable the captive portal, change and add admin users, and apply additional hardening configurations.
