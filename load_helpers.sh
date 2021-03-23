#!/bin/bash

tools_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
echo "Loading scripts from $tools_dir"

# Source custom tools
for f in ${tools_dir}/helpers/*.sh; do source $f; done
