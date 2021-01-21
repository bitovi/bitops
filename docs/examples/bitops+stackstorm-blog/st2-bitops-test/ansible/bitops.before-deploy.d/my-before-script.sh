#!/bin/bash
echo "I am a before ansible lifecycle script!"
python ./bitops.before-deploy.d/wait-for-inventory-hosts.py