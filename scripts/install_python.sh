#!/bin/bash

# install_python.sh - Install Python and optionally set as default

SCRIPT_DIR=$(dirname "$(readlink -f "$0")")
source "$SCRIPT_DIR/utils/common.sh"

if [ $# -eq 0 ]; then
    echo "Usage: $0 <python-version> [--set-default]"
    echo "Example: $0 3.11"
    echo "Example: $0 3.10.6 --set-default"
    exit 1
fi

python_version=$1
set_default=false
major_minor_version=$(echo "$python_version" | grep -oE '^[0-9]+\.[0-9]+')

if [ $# -ge 2 ] && [ "$2" == "--set-default" ]; then
    set_default=true
fi

if ! validate_python_version "$python_version"; then
    exit 1
fi

# Check if Python is already installed
if command -v "python${major_minor_version}" >/dev/null 2>&1; then
    echo "Python ${python_version} is already installed."
    
    if [ "$set_default" = true ]; then
        echo "Checking if Python ${major_minor_version} is set as default..."
        current_python=$(python --version 2>&1 | cut -d' ' -f2)
        if [ "$current_python" == "$major_minor_version" ]; then
            echo "Python ${major_minor_version} is already the default version."
            exit 0
        else
            echo "Python ${major_minor_version} is installed but not set as default."
        fi
    else
        exit 0
    fi
else
    echo "Python ${python_version} not found. Proceeding with installation..."
    
    sudo add-apt-repository ppa:deadsnakes/ppa -y || {
        echo "Error: Failed to add PPA repository" >&2
        exit 1
    }

    sudo apt update || {
        echo "Error: Failed to update package list" >&2
        exit 1
    }

    sudo apt install "python${python_version}" "python${python_version}-venv" "python${python_version}-dev" -y || {
        echo "Error: Failed to install Python ${python_version}" >&2
        exit 1
    }
fi

if [ "$set_default" = true ]; then
    echo "Setting Python ${major_minor_version} as default..."
    
    sudo update-alternatives --install /usr/bin/python python "/usr/bin/python${major_minor_version}" 1 || {
        echo "Error: Failed to set python alternative" >&2
        exit 1
    }
    
    sudo update-alternatives --install /usr/bin/python3 python3 "/usr/bin/python${major_minor_version}" 1 || {
        echo "Error: Failed to set python3 alternative" >&2
        exit 1
    }
    
    sudo update-alternatives --set python "/usr/bin/python${major_minor_version}" || {
        echo "Error: Failed to configure python alternative" >&2
        exit 1
    }
    
    sudo update-alternatives --set python3 "/usr/bin/python${major_minor_version}" || {
        echo "Error: Failed to configure python3 alternative" >&2
        exit 1
    }
    
    if command -v "pip${major_minor_version}" >/dev/null 2>&1; then
        sudo update-alternatives --install /usr/bin/pip pip "/usr/bin/pip${major_minor_version}" 1 || {
            echo "Error: Failed to set pip alternative" >&2
            exit 1
        }
        sudo update-alternatives --set pip "/usr/bin/pip${major_minor_version}" || {
            echo "Error: Failed to configure pip alternative" >&2
            exit 1
        }
    fi
    
    echo ""
    echo "Python ${major_minor_version} has been set as the default version."
    echo "Current default Python versions:"
    echo "python --version: $(python --version 2>&1)"
    echo "python3 --version: $(python3 --version 2>&1)"
    if command -v pip >/dev/null 2>&1; then
        echo "pip --version: $(pip --version 2>&1 | cut -d' ' -f1-2)"
    fi
else
    echo ""
    echo "You can use the installed Python with: python${major_minor_version}"
    echo "To set as default, run: $0 $python_version --set-default"
fi