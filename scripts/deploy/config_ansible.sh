function config_ansible() {
    count=$(shyaml get-value ansible < "$TEMPDIR/bitops.config.default.yaml" | grep  '^- ' | wc -l)
    i=0
    while [ $i -lt $count ]
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