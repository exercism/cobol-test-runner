#!/usr/bin/env bash
full_path=$(readlink -e "${BASH_SOURCE[0]}" )
script_dir=${full_path%/*}
slug=${script_dir##*/}

if cobolcheck_type=$(type cobolcheck); then
    echo "Found cobolcheck, ${cobolcheck_type}"
    COBOLCHECK=cobolcheck
else
    COBOLCHECK=$SCRIPT_DIR/bin/cobolcheck
fi
if [[ ! -x $COBOLCHECK ]]; then
    echo "cobolcheck not found, try to fetch it."
    ./bin/fetch-cobolcheck
fi

cd "${script_dir}"
"${COBOLCHECK}" -p "${slug}"
# compile and run
echo "COMPILE AND RUN TEST"
cobc -xj test.cob
