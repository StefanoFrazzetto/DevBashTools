#!/bin/bash

source ${tools_dir}/utils.sh

function adb_screenshot {
  if [ $# -eq 0 ]
  then
    name="screenshot"
  else
    name="$1"
  fi
  filename="$(string_append_timestamp ${name}).png"
  adb exec-out screencap -p > $filename
  echo "screenshot saved to `pwd`/$filename"
}

function adb_record_screen {
    # capture signals
    exitScript() {
        trap - SIGINT SIGTERM SIGTERM # clear the trap
        tput cnorm

        extract

        remove_rec; wait
    }; trap exitScript SIGINT SIGTERM # set trap

    extract(){
        # use adb to copy recording from device to current dir 
        printf "\n%*s\n" $((0)) "Copying $fileName to your computer!"
        wait && adb pull sdcard/$fileName || return
    }

    remove_rec() {
      # remove all files on device containing 'rec.'
      adb -d shell rm -f *"/sdcard/rec."*
    }

    record(){
        prefix="$1"
        fileName="$(string_append_timestamp ${prefix}).mp4"

        printf "\n%*s\n" $((0)) "Starting new recording: $fileName"
        printf "\n\n%*s\n" $((0)) "Use CTRL-C to stop the recording..."
        adb -d shell screenrecord /sdcard/$fileName || adb shell echo \04
    }

    if [ $# -eq 0 ]
    then
      name="recording"
    else
      name="$1"
    fi

    remove_rec
    record "$name" && wait && exitScript
}
