#!/bin/bash

PROGRAM_FILES_DIR="$HOME/.program_files"
BASE_URL="https://parcel.pixspla.net"
VERSION="1.0"
VERSIONTITLE="allstar"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

function check_for_updates() {
    latest_version=$(curl -s "$BASE_URL/version")
    if [[ "$latest_version" != "$VERSION" ]]; then
        echo -e "${YELLOW}A new version of Parcel is available: $latest_version.${NC}"
        echo -e "You can update Parcel using 'parcel update'."
    fi
}

function update_parcel() {
    echo -e "Updating Parcel..."
    rm -rf "$PROGRAM_FILES_DIR/parcel"
    wget "$BASE_URL/parcel" -P "$PROGRAM_FILES_DIR" 2> /dev/null
    chmod +x "$PROGRAM_FILES_DIR/parcel"
    echo -e "${GREEN}Parcel updated successfully.${NC}"
}

check_for_updates

if [[ ! ":$PATH:" == *":$PROGRAM_FILES_DIR:"* ]]; then
    echo -e "${RED}Warning:${NC} $PROGRAM_FILES_DIR is not in your PATH. Consider adding it to your PATH."
fi

function get_package() {
    package_name="$1"
    package_url="$BASE_URL/repo/packages/$package_name"

    if [[ -f "$PROGRAM_FILES_DIR/$package_name" ]]; then
        echo -e "Package ${GREEN}$package_name${NC} is already installed."
    else
        if wget --spider "$package_url/$package_name" 2>/dev/null; then
            mkdir -p "$PROGRAM_FILES_DIR"

            echo -e "Installing package ${GREEN}$package_name${NC}"
            echo -e "Getting ${GREEN}'$package_url/$package_name'${NC}"
            wget "$package_url/$package_name" -P "$PROGRAM_FILES_DIR" 2> /dev/null

            if wget --spider "$package_url/$package_name-files.zip" 2>/dev/null; then
                echo -e "Getting ${GREEN}'$package_url/$package_name-files.zip'${NC}"
                wget "$package_url/$package_name-files.zip" -P "$PROGRAM_FILES_DIR" 2> /dev/null
                unzip "$PROGRAM_FILES_DIR/$package_name-files.zip" -d "$PROGRAM_FILES_DIR/$package_name-files" > /dev/null
                echo "Cleaning up..."
                rm "$PROGRAM_FILES_DIR/$package_name-files.zip"
            fi

            chmod +x "$PROGRAM_FILES_DIR/$package_name"
            echo -e "Package ${GREEN}$package_name${NC} installed successfully."
        else
            echo -e "${RED}Error:${NC} Package ${GREEN}$package_name${NC} not found."
        fi
    fi
}

function remove_package() {
    package_name="$1"

    if [[ -f "$PROGRAM_FILES_DIR/$package_name" ]]; then
        rm -rf "$PROGRAM_FILES_DIR/$package_name"
        if [[ -d "$PROGRAM_FILES_DIR/$package_name-files" ]]; then
            rm -r "$PROGRAM_FILES_DIR/$package_name-files"
        fi
        echo -e "Package ${GREEN}$package_name${NC} removed."
    else
        echo -e "${RED}Error:${NC} Package ${GREEN}$package_name${NC} is not installed."
    fi
}

function upgrade_package() {
    package_name="$1"
    package_url="$BASE_URL/repo/packages/$package_name"

    if [[ -f "$PROGRAM_FILES_DIR/$package_name" ]]; then
        if wget --spider "$package_url/$package_name" 2>/dev/null; then
            echo -e "Upgrading package ${GREEN}$package_name${NC}"
            if [[ -f "$PROGRAM_FILES_DIR/$package_name" ]]; then
                rm -rf "$PROGRAM_FILES_DIR/$package_name"
                if [[ -d "$PROGRAM_FILES_DIR/$package_name-files" ]]; then
                    rm -r "$PROGRAM_FILES_DIR/$package_name-files"
                fi
            fi
            echo -e "Getting ${GREEN}'$package_url/$package_name'${NC}"
            wget "$package_url/$package_name" -P "$PROGRAM_FILES_DIR" 2> /dev/null

            if wget --spider "$package_url/$package_name-files.zip" 2>/dev/null; then
                echo -e "Getting ${GREEN}'$package_url/$package_name-files.zip'${NC}"
                wget "$package_url/$package_name-files.zip" -P "$PROGRAM_FILES_DIR" 2> /dev/null
                unzip "$PROGRAM_FILES_DIR/$package_name-files.zip" -d "$PROGRAM_FILES_DIR/$package_name-files" > /dev/null
                echo "Cleaning up..."
                rm "$PROGRAM_FILES_DIR/$package_name-files.zip"
            fi

            chmod +x "$PROGRAM_FILES_DIR/$package_name"
            echo -e "Package ${GREEN}$package_name${NC} upgraded successfully."
        else
            echo -e "${RED}Error:${NC} Package ${GREEN}$package_name${NC} not found."
        fi
    else
        echo -e "${RED}Error:${NC} Package ${GREEN}$package_name${NC} is not installed."
    fi
}

function info_package() {
    package_name="$1"
    package_info_url="$BASE_URL/repo/packages/$package_name/metadata"

    if wget --spider "$package_info_url" 2>/dev/null; then
        wget -N "$package_info_url" -O "$PROGRAM_FILES_DIR/$package_name-info.txt" 2> /dev/null

        while IFS= read -r line; do
            key=$(echo "$line" | cut -d'=' -f1 | tr -d '[:space:]')
            value=$(echo "$line" | cut -d'=' -f2- | sed 's/^ *//')
            echo -e "${YELLOW}${key}:${NC} ${PURPLE}${value}${NC}"
        done < "$PROGRAM_FILES_DIR/$package_name-info.txt"
        
        rm "$PROGRAM_FILES_DIR/$package_name-info.txt"
    else
        echo -e "${RED}Error:${NC} Package info for ${GREEN}$package_name${NC} not found."
    fi
}

function help_message() {
    echo -e "${GREEN}Parcel${NC}: Noodle's Package Manager For Stupid Programs"
    echo ""
    echo -e "${PURPLE}Commands${NC}"
    echo -e "  ${BLUE}get${NC} ${YELLOW}<package_name>${NC}     - Install a package."
    echo -e "  ${BLUE}remove${NC} ${YELLOW}<package_name>${NC}  - Remove a package."
    echo -e "  ${BLUE}upgrade${NC} ${YELLOW}<package_name>${NC} - Upgrade a package."
    echo -e "  ${BLUE}info${NC} ${YELLOW}<package_name>${NC}    - Get package information."
    echo -e "  ${BLUE}update${NC}                 - Update Parcel."
    echo ""
    echo -e "${PURPLE}Arguments${NC}"
    echo -e "  ${BLUE}--help, -h${NC}             - Show this help message."
    echo -e "  ${BLUE}--version, -v${NC}          - Show the version of Parcel."
}

case "$1" in
    "update")
        update_parcel
        ;;
    "get")
        get_package "$2"
        ;;
    "remove")
        remove_package "$2"
        ;;
    "upgrade")
        upgrade_package "$2"
        ;;
    "info")
        info_package "$2"
        ;;
    "--help" | "-h")
        help_message
        ;;
    "--version" | "-v")
        echo -e "${GREEN}Parcel${NC} ${PURPLE}v$VERSION${NC} (codename '$VERSIONTITLE')"
        echo -e "Created by ${BLUE}NoodleDX${NC}"
        ;;
    "")
        help_message
        ;;
    *)
        echo -e "${RED}Error:${NC} Unknown command: $1"
        help_message
        exit 1
        ;;
esac
