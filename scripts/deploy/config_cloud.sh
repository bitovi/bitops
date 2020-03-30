function config_cloud_platform() {
    i=0
    while [ $i -lt $(shyaml get-value cloud_platform < "$TEMPDIR/bitops.config.default.yaml" | grep  '^- ' | wc -l) ]
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