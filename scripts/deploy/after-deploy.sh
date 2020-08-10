#!/usr/bin/env bash

set -ex

PLUGIN_DIR=$1


###
### DEPRECATED use bitops.after-deploy.d instead
###
AFTER_SCRIPTS_DIR="bitops-after-deploy.d"
echo "Checking after scripts ($AFTER_SCRIPTS_DIR)"
if [ -d "$PLUGIN_DIR/$AFTER_SCRIPTS_DIR/" ];then
    echo "DEPRECATED NOTICE: 'bitops-after-deploy.d' is deprecated. Please use 'bitops.after-deploy.d'"
    deploy_script=$(ls $PLUGIN_DIR/$AFTER_SCRIPTS_DIR/)
    if [[ -n ${deploy_script} ]];then
        echo "Running After Deploy Scripts"
        for script in $PLUGIN_DIR/$AFTER_SCRIPTS_DIR/*.sh; do
            if [[ -x "$script" ]]; then
                /bin/bash -x $script
            else
                echo "After deploy script [$script] is not executible. Skipping..."
            fi
        done
    fi
fi

AFTER_SCRIPTS_DIR="bitops.after-deploy.d"
echo "Checking after scripts ($AFTER_SCRIPTS_DIR)"
if [ -d "$PLUGIN_DIR/$AFTER_SCRIPTS_DIR/" ];then
    deploy_script=$(ls $PLUGIN_DIR/$AFTER_SCRIPTS_DIR/)
    if [[ -n ${deploy_script} ]];then
        echo "Running After Deploy Scripts"
        for script in $PLUGIN_DIR/$AFTER_SCRIPTS_DIR/*.sh; do
            if [[ -x "$script" ]]; then
                /bin/bash -x $script
            else
                echo "After deploy script [$script] is not executible. Skipping..."
            fi
        done
    fi
fi
