#!/bin/sh

# Define text colors.
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# Define available platforms.
platforms='{"win":"win-x64.exe","mac":"mac-x64.dmg","mac-arm":"mac-arm64.dmg","linux":"linux-x86_64.AppImage","linux-arm":"linux-arm64.AppImage"}'
platform_keys=$(echo $platforms | jq -r ' keys | join(" ")')

####################################################################
# Validate arguments. Valid platform and volume mount.
####################################################################

# Make sure the /downloads directory is mounted, this is needed to write the Trezor binary to the host file system.
 if [ ! -d "/downloads" ]
    then echo -e "${RED}No volumne mounted!${NC} Make sure to run the container with a mount, so the downloaded file is available on the host. Start docker container with '-v \${PWD}/downloads:/downloads'"
    exit
fi

# Ask for platform when no platform is provided.
if [ -z "$1" ] || [ "$1" == "null" ]
then
    # Ask for platform.
    echo -e "Select your ${YELLOW}platform${NC}"
    platform_input=$(gum choose $platform_keys)
else
    # Use platform from provided commandline argument
    platform_input=$1
fi

# Get platform binary name based on provided argument.
platform=$(echo "$platforms" | jq -r  --arg selector "$platform_input" '.[$selector]')

# Quit when invalid platform is provided.
if [ -z "$platform" ] || [ "$platform" = "null" ]
    then echo -e "${RED}Invalid platform provided!${NC} Must be one of the following platforms: mac, mac-arm, win, linux, linux-arm"
    exit
fi

####################################################################
# Show selected platfom and binary name.
####################################################################
echo -e "Selected platform: ${YELLOW}${platform_input}${NC}"
echo "Corresponding binary name: ${platform}"
echo ""

####################################################################
# Get latest release and extract info about the files to download.
####################################################################
echo ""
echo "Determine latest release from GitHub."
github_release_url=https://api.github.com/repos/trezor/trezor-suite/releases/latest
echo "URL: $github_release_url"

# Download latest release info from GitHub API and store response in release.json for later reference.
curl --silent -H "Accept: application/vnd.github.v3+json" $github_release_url > release.json

# Extract release url, version and date.
release_url=$(cat release.json | jq -r .html_url)
release_version=$(cat release.json | jq -r .tag_name)
release_date=$(cat release.json | jq -r .published_at)

# Show release url, version and date.
echo ""
echo -e "The latest release is ${YELLOW}$release_version${NC}. This release was published on ${YELLOW}$release_date${NC}."
echo -e "Release details: $release_url"

# Determine file name for the binary and the signature.
binary_file=$(cat release.json | jq -r '.assets[] | select(.name|endswith('\"$platform\"')) | .name')
signature_file="$binary_file.asc"

# Get details about the files that should be downloaded.
signature_url=$(cat release.json | jq -r '.assets[] | select(.name|endswith('\"$signature_file\"')) | .browser_download_url')
binary_url=$(cat release.json | jq -r '.assets[] | select(.name|endswith('\"$binary_file\"')) | .browser_download_url')
binary_size=$(cat release.json | jq -r '.assets[] | select(.name|endswith('\"$binary_file\"')) | .size' | awk '{$1=$1/1000/1000; print $1,"MB";}')

####################################################################
# Download release binary and signature from GitHub.
####################################################################
echo ""
echo "Download Trezor binary from GitHub"
echo "URL: $binary_url"
echo -e "This file is ${YELLOW}$binary_size${NC}. Might take a while depending on your internet connection."
curl --progress-bar -L $binary_url > "$binary_file"
echo -e "${GREEN}Complete${NC}"

echo ""
echo "Download signature from GitHub"
echo "URL: $signature_url"
curl --silent -L $signature_url > "$signature_file"
echo -e "${GREEN}Complete${NC}"

####################################################################
# Download signing key from trezor website.
####################################################################
echo ""
echo "Download SatoshiLabs signing key from Trezor.io domain."
key_url=https://trezor.io/security/satoshilabs-2021-signing-key.asc 
echo "URL: $key_url"
curl --silent -L $key_url > signing-key.asc
echo -e "${GREEN}Complete${NC}"

####################################################################
# Import signing key and verify downloaded files.
####################################################################
echo ""
echo "Import SatoshiLabs signing key in gpg"
echo ""
gpg --import signing-key.asc 2> /dev/null

echo "Verify binary"
gpg --verify $signature_file 2> gpglog.txt
echo ""

# Quit if the verification failed.
if ! cat gpglog.txt | grep -q "Good signature"; then
    echo -e "${RED}INVALID SIGNATURE!!!!${NC}"
    echo ""
    echo "The downloaded files were not signed correctly!"
    exit
fi

# All good.
echo -e "${GREEN}Good signature!${NC}"
echo "The downloaded files have been signed by the Satoshilabs signing key."
echo ""

mv $binary_file /downloads/$binary_file
echo "Moved downloaded binary to host"
echo ""
echo -e "${GREEN}Done!${NC}"
