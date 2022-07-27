#! /bin/bash

readonly script_dir=$(cd `dirname $0` && pwd)
readonly data_dir="${XDG_DATA_HOME:-$HOME/.local/share}/solana/test-ledger/"


solana-test-validator --bind-address 127.0.0.1 \
                      --ledger "${data_dir}" 

