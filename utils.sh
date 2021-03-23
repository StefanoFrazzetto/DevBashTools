#!/bin/bash

string_append_timestamp() {
    if [ $# -eq 2 ]
    then
        # user provided date format
        local dateformat="$2"
    else
        local dateformat="%Y-%m-%d_%H.%M.%S"
    fi
    
    local timestamp=$(date "+$dateformat")
    printf "$1_$timestamp"
}
