#!/bin/bash
echo "--------------------------------------------"
echo "█▀ █ █▀▀   █▀ ▄▀█ █▀▄▀█ █    ▀█▀ █▀█ █▀█ █  "
echo "▄█ █ █▄█   ▄█ █▀█ █ ▀ █ █▄▄   █  █▄█ █▄█ █▄▄"
echo "--------------------------------------------"
echo "version 1.0"
echo ""

export timestamp=`date +"%Y%m%d-%H%M%S"`

echo "[*] Collecting environment information"
read -p "- Enter hostname: " host
#echo "User entered: ${host}"

read -p "- Enter context path: " context
#echo "User entered: ${context}"

read -p "- Enter entity ID (suggested value='https://${host}/${context}'): " entityid
#echo "User entered: ${entityid}"

read -p "- Enter ID: " spid
#echo "User entered: ${spid}"

echo "[*] Creating working directory (working-directory-${timestamp})"
mkdir working-directory-${timestamp}

echo "[*] Copying SP metadata template"
cp sp-metadata-template.xml working-directory-${timestamp}/sp-metadata.xml

cd working-directory-${timestamp}

read -p "[*] Do you need to generate a certificate? (Y/N) " gencert
#echo "User entered: ${gencert}"

if [[ $gencert == "Y" || $gencert == "y" ]]; then
        echo "[*] Generating keystore..."

        read -p "- Enter cert data: " certdata
        #echo "User entered: ${certdata}"

        keytool -genkeypair -keyalg RSA -alias samlsigning -dname "${certdata}" -validity 1825 -keysize 2048 -sigalg SHA256withRSA -keystore samlKeystore.jks

        echo "[*] Exporting public certificate..."
        keytool -export -alias samlsigning -keystore samlKeystore.jks -rfc -file saml-signing.crt

elif [[ $gencert == "N" || $gencert == "n" ]] ; then
        echo "[*] Prompting for keystore details..."
        read -p "- Enter keystore path: " keystore
        #echo "User entered: ${keystore}"

        read -p "- Enter key alias: " keyalias
        #echo "User entered: ${keyalias}"

        echo "[*] Exporting public certificate..."
        keytool -export -alias ${keyalias} -keystore $keystore -rfc -file saml-signing.crt
else
  echo "[!] ERROR: Invalid keystore option, exiting"
  exit 2
fi

#cat saml-signing.crt
#echo "SAML certificate contents = `cat saml-signing.crt`"

echo "- Cleaning up and formatting cert"
certbody=`cat saml-signing.crt | tail -n +2 | head -n -1`

#echo "Cert body = ${certbody}"

# Dump certificat to a temp file
echo "${certbody}" > saml-signing-temp.crt
# Fix newline character encoding
dos2unix saml-signing-temp.crt
# Remove newline characters
tr -d '\n' < saml-signing-temp.crt > saml-signing-flat.crt
flattenedcert=`cat saml-signing-flat.crt`

echo "[*] Updating SP metadata..."
echo "- Updating entity id"
sed -i "s|<ENTITYID>|${entityid}|g" sp-metadata.xml
echo "- Updating id"
sed -i "s|<SPID>|${spid}|g" sp-metadata.xml
echo "- Updating certificate"
#echo "Flattened cert = ${flattenedcert}"
sed -i "s|<CERTBODY>|${flattenedcert}|g" sp-metadata.xml
echo "- Updating host"
sed -i "s|<HOST>|${host}|g" sp-metadata.xml
echo "- Updating context"
sed -i "s|<CONTEXT>|${context}|g" sp-metadata.xml
echo "[*] Done."
