# sig-saml-tool
SAML SP management and configuration can be tedious and repetitive.
With more schools transitioning from CAS to SAML, it was time to finish up a tool that was started a long time ago.

This repo contains a bash script called 'samltool.sh' and its main purpose (for now) is to prompt the user for the information that it 
needs to generate a Service Provider metadata file using the 'sp-metadata-template.xml' template.

In the example below, we're going to use the script to generate SP metadata for the SIG General SSB application.
The base URL for the application is: https://example.school.edu/BannerGeneralSsb
```
[ssoadmin@weathertop saml]$ ls -l
total 8
-rwxr-xr-x. 1 ssoadmin ssoadmin 2632 Oct 25 15:53 samltool.sh
-rw-r--r--. 1 ssoadmin ssoadmin 1640 Oct 20 18:03 sp-metadata-template.xml
[ssoadmin@weathertop saml]$ ./samltool.sh
--------------------------------------------
█▀ █ █▀▀   █▀ ▄▀█ █▀▄▀█ █    ▀█▀ █▀█ █▀█ █
▄█ █ █▄█   ▄█ █▀█ █ ▀ █ █▄▄   █  █▄█ █▄█ █▄▄
--------------------------------------------

version 1.0

[*] Collecting environment information
- Enter hostname: example.school.edu
- Enter context path: BannerGeneralSsb
- Enter entity ID (suggested value='https://example.school.edu/BannerGeneralSsb'): https://example.school.edu/BannerGeneralSsb
- Enter ID: SIG General SSB
[*] Creating working directory (working-directory-20221025-155508)
[*] Copying SP metadata template
[*] Do you need to generate a certificate? (Y/N) Y
[*] Generating keystore...
- Enter cert data: CN=saml-banner-test.example.school.edu,OU=IT,O=SIG,L=San Diego,ST=CA,C=US
Enter keystore password:
Re-enter new password:
Enter key password for <samlsigning>
        (RETURN if same as keystore password):
[*] Exporting public certificate...
Enter keystore password:
Certificate stored in file <saml-signing.crt>
- Cleaning up and formatting cert
dos2unix: converting file saml-signing-temp.crt to Unix format ...
[*] Updating SP metadata...
- Updating entity id
- Updating id
- Updating certificate
- Updating host
- Updating context
[*] Done.
[ssoadmin@weathertop saml]$

[ssoadmin@weathertop saml]$ ls -l working-directory-20221025-155508/
total 24
-rw-r--r--. 1 ssoadmin ssoadmin 2254 Oct 25 15:55 samlKeystore.jks
-rw-r--r--. 1 ssoadmin ssoadmin 1287 Oct 25 15:55 saml-signing.crt
-rw-r--r--. 1 ssoadmin ssoadmin 1196 Oct 25 15:55 saml-signing-flat.crt
-rw-r--r--. 1 ssoadmin ssoadmin 1215 Oct 25 15:55 saml-signing-temp.crt
-rw-r--r--. 1 ssoadmin ssoadmin 4107 Oct 25 15:55 sp-metadata.xml
[ssoadmin@weathertop saml]$

[ssoadmin@weathertop saml]$ vi working-directory-20221025-155508/sp-metadata.xml
[ssoadmin@weathertop saml]$
```

What if you already have a signing certificate to use?
/A keypair may have been provided, or this might not be the first application in the environment and a keypair already exists.
Enter 'N' or 'n' at the 'Do you need to generate a certificate?' prompt and the script will then prompt for the keystore details.

In the example below, we have an existing keystore named 'exampleKeystore.jks' and it contains a keypair under the 'samlsigning' alias.

```
[ssoadmin@weathertop saml]$ keytool -genkeypair -keyalg RSA -alias samlsigning -dname "CN=saml-banner-test.exmaple.school.edu,OU=IT,O=SIG,L=San Diego,ST=CA,C=US" -validity 1825 -keysize 2048 -sigalg SHA256withRSA -keystore exampleKeystore.jks
Enter keystore password:
Re-enter new password:
Enter key password for <samlsigning>
        (RETURN if same as keystore password):
[ssoadmin@weathertop saml]$
```

The 'samltool.sh' script is run for the 'Student Registration SSB' application this time.
After entering 'N' or 'n' at the prompt to generate a certificate, the script will prompt the user for the necessary keystore details.

```
[ssoadmin@weathertop saml]$ ./samltool.sh
--------------------------------------------
█▀ █ █▀▀   █▀ ▄▀█ █▀▄▀█ █    ▀█▀ █▀█ █▀█ █
▄█ █ █▄█   ▄█ █▀█ █ ▀ █ █▄▄   █  █▄█ █▄█ █▄▄
--------------------------------------------
version 1.0

[*] Collecting environment information
- Enter hostname: example.school.edu
- Enter context path: StudentRegistrationSsb
- Enter entity ID (suggested value='https://example.school.edu/StudentRegistrationSsb'): https://example.school.edu/StudentRegistrationSsb
- Enter ID: SIG Student Registration
[*] Creating working directory (working-directory-20221025-155924)
[*] Copying SP metadata template
[*] Do you need to generate a certificate? (Y/N) N
[*] Prompting for keystore details...
- Enter keystore path: /home/ssoadmin/saml/exampleKeystore.jks
- Enter key alias: samlsigning
[*] Exporting public certificate...
Enter keystore password:
Certificate stored in file <saml-signing.crt>
- Cleaning up and formatting cert
dos2unix: converting file saml-signing-temp.crt to Unix format ...
[*] Updating SP metadata...
- Updating entity id
- Updating id
- Updating certificate
- Updating host
- Updating context
[*] Done.
[ssoadmin@weathertop saml]$


[ssoadmin@weathertop saml]$ ls -l working-directory-20221025-155924/
total 20
-rw-r--r--. 1 ssoadmin ssoadmin 1287 Oct 25 16:00 saml-signing.crt
-rw-r--r--. 1 ssoadmin ssoadmin 1196 Oct 25 16:00 saml-signing-flat.crt
-rw-r--r--. 1 ssoadmin ssoadmin 1215 Oct 25 16:00 saml-signing-temp.crt
-rw-r--r--. 1 ssoadmin ssoadmin 4140 Oct 25 16:00 sp-metadata.xml
[ssoadmin@weathertop saml]$
```
