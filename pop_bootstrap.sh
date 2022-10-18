#!/bin/bash -ex

# Bootstrap Pop!_OS Linux
source libraries/common.sh

# Environment setup
PACKAGE_DIR="$PWD/pkglists"

common::run_bootstrap "libraries/ubuntu.sh"
