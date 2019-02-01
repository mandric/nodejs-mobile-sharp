#!/bin/bash
# Helper script for Gradle to call node on macOS in case it is not found
echo PATH="$(test -n $NVM_DIR && dirname $(nvm which current)):$PATH"
node $@
