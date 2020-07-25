#!/usr/bin/env bash

set -ex

PLUGIN_DIR=$1


###
### DEPRECATED use bitops.before-deploy.d instead
###
BEFORE_SCRIPTS_DIR="bitops-before-deploy.d"
echo "Checking before scripts ($BEFORE_SCRIPTS_DIR)"
if [ -d "$PLUGIN_DIR/$BEFORE_SCRIPTS_DIR/" ];then
    echo "DEPRECATED NOTICE: 'bitops-before-deploy.d' is deprecated. Please use 'bitops.before-deploy.d'"
    BEFORE_DEPLOY=$(ls $PLUGIN_DIR/$BEFORE_SCRIPTS_DIR/)
    if [[ -n ${BEFORE_DEPLOY} ]];then
        echo "Running Before Deploy Scripts"
        END=$(ls $PLUGIN_DIR/$BEFORE_SCRIPTS_DIR/*.sh | wc -l)
        for ((i=1;i<=END;i++)); do
            if [[ -x "$PLUGIN_DIR/$BEFORE_SCRIPTS_DIR/$i.sh" ]]; then
                /bin/bash -x $PLUGIN_DIR/$BEFORE_SCRIPTS_DIR/$i.sh
            else
                echo "Before deploy script is not executible. Skipping..."
            fi
        done
    fi
fi



BEFORE_SCRIPTS_DIR="bitops.before-deploy.d"
echo "Checking before scripts ($BEFORE_SCRIPTS_DIR)"
if [ -d "$PLUGIN_DIR/$BEFORE_SCRIPTS_DIR/" ];then
    BEFORE_DEPLOY=$(ls $PLUGIN_DIR/$BEFORE_SCRIPTS_DIR/)
    if [[ -n ${BEFORE_DEPLOY} ]];then
        echo "Running Before Deploy Scripts"
        END=$(ls $PLUGIN_DIR/$BEFORE_SCRIPTS_DIR/*.sh | wc -l)
        for ((i=1;i<=END;i++)); do
            if [[ -x "$PLUGIN_DIR/$BEFORE_SCRIPTS_DIR/$i.sh" ]]; then
                /bin/bash -x $PLUGIN_DIR/$BEFORE_SCRIPTS_DIR/$i.sh
            else
                echo "Before deploy script is not executible. Skipping..."
            fi
        done
    fi
fi


