#! /bin/bash

readonly script_dir=$(cd `dirname $0` && pwd)
readonly config_file="${script_dir}/solana-config.yml"
readonly data_dir="${script_dir}/../run/solana/ledger"

readonly json_rpc_url=`cat ${config_file} | grep -E "^json_rpc_url" | sed -E "s/json_rpc_url\s*:\s*(\S*)\s*/\1/"`
readonly keypair_path=`cat ${config_file} | grep -E "^keypair_path" | sed -E 's/keypair_path\s*:\s*(\S*)\s*/\1/'`
readonly commitment=`cat ${config_file} | grep -E "^commitment" | sed -E "s/commitment\s*:\s*('|\")?(\S*)('|\")?\s*/\1/"`

readonly url=

echo ${json_rpc_url}
echo ${keypair_path}
echo ${commitment}

cd "${script_dir}"
mkdir -p "${data_dir}"

if [ ! `expect -v 2>&1 | grep version | wc -l ` -eq 1 ]; then
    echo "Trying to install \`expect\`."
    sudo apt-get update && sudo apt-get install expect
    if [ $? -ne 0 ]; then
        echo "Fail to install \`expect\`."
        echo "Stop the script. Find out the reason, fix it and try again."
    fi
fi

if [ ! -f "${script_dir}/${keypair_path}" ]; then
    echo "Keypair file doesn't exist."
    exit 102
    /usr/bin/expect <( cat << EOF
    spawn solana-keygen new --config "${config_file}" --outfile "${keypair_path}"
    # https://www.baeldung.com/linux/bash-interactive-prompts
    expect "BIP39 Passphrase (empty for none): "
    send "$BIP39_MNEMONIC\r"
    expect "Enter same passphrase again: "
    send "$BIP39_MNEMONIC\r"
    interact
EOF
)
fi

solana config get --config "${config_file}"

solana-test-validator --config "${config_file}" \
                      --ledger "${data_dir}"

