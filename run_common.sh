#!/bin/bash
set -e

# Bootstrap Arch Linux
source libraries/common.sh

# Environment setup
PACKAGE_DIR="$PWD/pkglists"

$1
