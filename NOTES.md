# $BITOPS_SCRIPT_DIR/bitops-config/convert-schema.sh $BITOPS_CONFIG_SCHEMA

export BITOPS_CONFIG_FILE=/Users/philh/Documents/ops_dir/test/terraform/bitops.config.yaml;
export BITOPS_DIR=$BITOPS_HOME; 
export BITOPS_CONFIG_SCHEMA=$BITOPS_HOME/scripts/helm/bitops.schema.yaml; 
export SCRIPTS_DIR=$BITOPS_HOME/scripts; 
$BITOPS_HOME/scripts/bitops-config/convert-schema.sh $BITOPS_CONFIG_SCHEMA $BITOPS_CONFIG_FILE


export ENV_FILE=$BITOPS_HOME/check-me-out-girl.txt; 

export DEBUG=true; \
export DEEP_DEBUg=true; \
export BITOPS_CONFIG_FILE=$BITOPS_HOME/docs/example-config-files/terraform.bitops.config.yaml; \
export BITOPS_DIR=$BITOPS_HOME; export BITOPS_CONFIG_SCHEMA=$BITOPS_HOME/scripts/terraform/bitops.schema.yaml; \
export SCRIPTS_DIR=$BITOPS_HOME/scripts; \
$BITOPS_HOME/scripts/bitops-config/convert-schema.sh $BITOPS_CONFIG_SCHEMA $BITOPS_CONFIG_FILE





