#!/bin/bash

# common.sh - Common utility functions

validate_python_version() {
    local version=$1
    if [[ ! $version =~ ^[0-9]+\.[0-9]+(\.[0-9]+)?$ ]]; then
        echo "Error: Invalid Python version format. Please use format like 3.10, 3.11, or 3.11.x" >&2
        return 1
    fi
    return 0
}