#!/bin/bash
echo "I am a before ansible lifecycle script!"
python $TEMPDIR/_scripts/ansible/wait-for-inventory-hosts.py