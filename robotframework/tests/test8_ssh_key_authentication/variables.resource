*** Settings ***
Documentation    🔐 Test-8 SSH Key Authentication Variables
...              📋 Configuration variables for SSH key authentication validation
...

*** Variables ***
# Code Server (Jump Box) Configuration
${CODE_SERVER_HOST}          192.168.1.100
${CODE_SERVER_USER}          codeserver
${CODE_SERVER_PASS}          password123

# Target Machine Configuration - Pulled from command line like test3
${TARGET_HOSTNAME}           # Set via command line --variable TARGET_HOSTNAME:value
${TARGET_HOST}               ${TARGET_HOSTNAME}    # Use same hostname as test3
${TARGET_USER}               testuser

# SSH Key Configuration
${SSH_KEY_PATH}              /home/codeserver/.ssh/id_rsa
${AUTHORIZED_KEYS_PATH}      /home/testuser/.ssh/authorized_keys

# Expected Permissions
${EXPECTED_KEY_PERMS}        600
${EXPECTED_DIR_PERMS}        700
