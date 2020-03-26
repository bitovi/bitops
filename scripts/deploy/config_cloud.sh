function config_cloud_platform() {
    count=$(shyaml get-value cloud_platform < "$TEMPDIR/bitops.config.default.yaml" | grep  '^- ' | wc -l)
    i=0
    while [ $i -lt $count ]
    do
      CP_ENABLED=$(shyaml get-value cloud_platform.$i.enabled < "$TEMPDIR/bitops.config.default.yaml")
      CLOUD_PLATFORM=$(shyaml get-value cloud_platform.$i.name < "$TEMPDIR/bitops.config.default.yaml")
      if [ "$CP_ENABLED" == True ]
      then
          echo "$CLOUD_PLATFORM"
      fi
      i=$(($i+1))
    done
}

config_cloud_platform