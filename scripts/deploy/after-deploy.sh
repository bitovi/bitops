#!/usr/bin/env bash

set -ex

PLUGIN_DIR=$1

if [ -d "$PLUGIN_DIR/bitops-after-deploy.d/" ];then
    AFTER_DEPLOY=$(ls $PLUGIN_DIR/bitops-after-deploy.d/)
    if [[ -n ${PLUGIN_DIR} ]];then
        echo "Running After Deploy Scripts"
        END=$(ls $PLUGIN_DIR/bitops-after-deploy.d/*.sh | wc -l)
        for ((i=1;i<=END;i++)); do
            if [[ -x "$PLUGIN_DIR/bitops-before-deploy.d/$i.sh" ]]; then
                /bin/bash -x $PLUGIN_DIR/bitops-after-deploy.d/$i.sh
            else
                printf "${ERROR} After deploy script is not executible. Skipping..."
            fi
        done
    fi
fi