#!/bin/bash
set -e

# Bootstrap Arch Linux
source libraries/common.sh

# Environment setup
PACKAGE_DIR="$PWD/pkglists"

common::run_bootstrap "libraries/macos.sh"
