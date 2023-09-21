#!/bin/bash
# VMAdmin User
useradd -m vmadmin
usermod --password $(echo sml12345 | openssl passwd -1 -stdin) vmadmin
