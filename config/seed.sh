#!/usr/bin/env zsh
set -e

fail() {
    echo $1
    exit 1
}

cmd=$(basename "$0")
dir=$(dirname "$0")

host=$1
output=$2
[[ -n $host && -n $output ]] || fail "usage: $cmd <hostname> <output>"
[[ -f $output ]] && fail "error: $output already exists"

echo "Starting seed generation"

temp=$(mktemp -d -t ${cmd}-XXXX)
trap "rm -rf $temp" EXIT
echo "Using $temp for generation"

# cp $dir/user-data $temp
ssh_key=$(<~/.ssh/id_rsa.pub)

export host ssh_key
envsubst < $dir/meta-data > $temp/meta-data
envsubst < $dir/user-data > $temp/user-data

genisoimage -output $output \
  -input-charset UTF-8 \
  -volid cidata \
  -joliet -rock \
  $temp/*
