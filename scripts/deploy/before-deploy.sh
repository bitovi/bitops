
#!/usr/bin/env bash

set -ex

PLUGIN_DIR=$1

if [ -d "$PLUGIN_DIR/bitops-before-deploy.d/" ];then
    BEFORE_DEPLOY=$(ls $PLUGIN_DIR/bitops-before-deploy.d/)
    if [[ -n ${BEFORE_DEPLOY} ]];then
        echo "Running Before Deploy Scripts"
        END=$(ls $PLUGIN_DIR/bitops-before-deploy.d/*.sh | wc -l)
        for ((i=1;i<=END;i++)); do
            if [[ -x "$PLUGIN_DIR/bitops-before-deploy.d/$i.sh" ]]; then
                /bin/bash -x $PLUGIN_DIR/bitops-before-deploy.d/$i.sh
            else
                echo "Before deploy script is not executible. Skipping..."
            fi
        done
    fi
fi