#!/usr/bin/env bash
set -e

# TODO: use $SCRIPTS_DIR/bitops-config/* instead
function config_ansible() {
    i=0
    while [ $i -lt $(shyaml get-value ansible < "$TEMPDIR/bitops.config.default.yaml" | grep  '^- ' | wc -l) ]
    do
      ANSIBLE_ENABLED=$(shyaml get-value ansible.actions.$i.enabled < "$TEMPDIR/bitops.config.default.yaml")
      if [ "$ANSIBLE_ENABLED" == True ]
      then
          echo "true"
      fi
      i=$(($i+1))
    done
}

config_ansible