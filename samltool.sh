#!/bin/bash

echo "--------------------------------------------"
echo "█▀ █ █▀▀   █▀ ▄▀█ █▀▄▀█ █    ▀█▀ █▀█ █▀█ █  "
echo "▄█ █ █▄█   ▄█ █▀█ █ ▀ █ █▄▄   █  █▄█ █▄█ █▄▄"
echo "--------------------------------------------"
echo "version 2.0"
echo ""

export timestamp=`date +"%Y%m%d-%H%M%S"`
export host=""
export context=""
export entityid=""
export spid=""
export gencert=""

function printhelp() {
        echo "Usage: $0 [-h] [-v] [-m mode] [-f filename]"
}

if [ $# -eq 0 ]; then
        printhelp
        exit 1
fi

while getopts "hvm:u:e:i:o:k:p:a:d:f:" option; do
  case $option in
    h) # display help message
      printhelp
      exit 0
      ;;
    v) # enable verbose mode
      VERBOSE=1
      ;;
    m) # mode
      MODE="$OPTARG"
      ;;
    f) # set filename
      FILENAME="$OPTARG"
      ;;
    \?) # invalid option
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
  esac
done

function readcsv() {
        # Read the file line by line
        while IFS=, read -r url spentityid spid keystorepath keystorepass spkeyalias certdata
        do
                # Process each field as needed
                echo "url: $url"
                echo "spentityid: $spentityid"
                echo "spid: $spid"
                echo "keystorepath: $keystorepath"
                echo "keystorepass: $keystorepass"
                echo "spkeyalias: $spkeyalias"
                echo "certdata: $certdata"
        done < "$FILENAME"
}

function doprompts() {
        echo "[*] Collecting environment information"
        read -p "- Enter hostname (include port if not using 443): " host
        #echo "User entered: ${host}"

        read -p "- Enter context path: " context
        #echo "User entered: ${context}"

        read -p "- Enter entity ID (suggested value='https://${host}/${context}'): " entityid
        #echo "User entered: ${entityid}"

        read -p "- Enter ID: " spid
        #echo "User entered: ${spid}"

        while true; do
                read -p "[*] Do you need to generate a certificate? (Y/N) " gencert
                #echo "User entered: ${gencert}"

                if [[ "$gencert" == "Y" || "$gencert" == "y" ]]; then
                        $GENCERT="Y"    # normalize input
                        break
                elif [[ "$gencert" == "N" || "$gencert" == "n" ]]; then
                        $GENCERT="N"    # normalize input
                        break
                else
                        echo "Invalid input. Please enter Y or N."
                fi
        done
}

if [ $MODE == "prompt" ]; then
        echo "Prompt mode selected"
        doprompts
        echo "hostname = ${host}"
elif [ $MODE == "file" ]; then
        if [ -z "$FILENAME" ]; then
                echo "ERROR: Please provide a file using -f"
                exit 1
        else
                echo "Reading from file: $FILENAME"
                readcsv
        fi
else
        echo "ERROR: Unrecognized mode option, valid values: prompt, file"
        exit 1
fi

echo "[*] Creating working directory (working-directory-${timestamp})"
mkdir working-directory-${timestamp}

echo "[*] Copying SP metadata template"
cp sp-metadata-template.xml working-directory-${timestamp}/sp-metadata.xml

#cd working-directory-${timestamp}
