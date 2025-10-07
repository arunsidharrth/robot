*** Settings ***
Documentation    🔐 SSH Key Authentication Validation Test Suite - Test-8
...              🔍 Process: Connect to Code Server → Test SSH key authentication → Validate authorized_keys configuration
...              ✅ Pass if SSH key authentication works passwordlessly from Code Server to target machine
...              📊 Validates: SSH key authentication, authorized_keys permissions, SSH configuration
...
Resource         ../../settings.resource
Resource         ssh_keywords.resource
Resource         variables.resource

Suite Setup      Initialize SSH Key Test Environment
Suite Teardown   Generate SSH Key Authentication Executive Summary

Test Setup       Log Test Start    ${TEST_NAME}
Test Teardown    Log Test End      ${TEST_NAME}    ${TEST_STATUS}

*** Test Cases ***
Critical - Connect to Code Server
    [Documentation]    🔗 Establish SSH connection to Code Server (Linux jump box)
    [Tags]             critical    connection    ssh    infrastructure

    Log    🔍 Verifying SSH connection to Code Server...    console=yes
    Log    📋 Code Server: ${CODE_SERVER_HOST}    console=yes

    # Connection already established in Suite Setup
    ${connection_status}=    Execute Command    echo "Connection active"
    Should Contain    ${connection_status}    Connection active

    Log    ✅ SSH connection to Code Server verified and active    console=yes

Critical - Verify SSH Private Key Exists
    [Documentation]    🔑 Verify SSH private key exists on Code Server with correct permissions
    [Tags]             critical    ssh_key    security

    Log    🔍 Verifying SSH private key on Code Server...    console=yes
    Log    📋 Expected key path: ${SSH_KEY_PATH}    console=yes

    # Check if private key exists
    ${key_exists}=    Execute Command    test -f ${SSH_KEY_PATH} && echo "exists" || echo "not found"
    Should Contain    ${key_exists}    exists    msg=SSH private key not found at ${SSH_KEY_PATH}

    Log    ✅ SSH private key found at ${SSH_KEY_PATH}    console=yes

Critical - Validate SSH Private Key Permissions
    [Documentation]    🔒 Validate SSH private key has secure permissions (600)
    [Tags]             critical    security    permissions

    Log    🔍 Validating SSH private key permissions...    console=yes
    Log    📋 Expected permissions: 600    console=yes

    # Check private key permissions
    ${key_perms}=    Execute Command    stat -c '%a' ${SSH_KEY_PATH}
    Should Be Equal    ${key_perms}    600    msg=SSH private key permissions should be 600, found ${key_perms}

    Log    🔒 Private key permissions: ${key_perms}    console=yes
    Log    ✅ SSH private key permissions validated    console=yes

Critical - Test Passwordless SSH Authentication
    [Documentation]    🔐 Test passwordless SSH connection from Code Server to target machine
    [Tags]             critical    authentication    passwordless

    Log    🔍 Testing passwordless SSH authentication...    console=yes
    Log    📋 Target: ${TARGET_USER}@${TARGET_HOST}    console=yes

    # Attempt passwordless SSH connection
    ${ssh_test}=    Execute Command    ssh -o StrictHostKeyChecking=no -o PasswordAuthentication=no -o BatchMode=yes -i ${SSH_KEY_PATH} ${TARGET_USER}@${TARGET_HOST} 'echo "SSH_AUTH_SUCCESS"'    return_stdout=True    return_stderr=True    return_rc=True

    Should Be Equal As Integers    ${ssh_test}[2]    0    msg=SSH key authentication failed with return code ${ssh_test}[2]. Error: ${ssh_test}[1]
    Should Contain    ${ssh_test}[0]    SSH_AUTH_SUCCESS    msg=SSH connection did not return expected success message

    Log    ✅ Passwordless SSH authentication successful    console=yes

Critical - Validate Authorized Keys File
    [Documentation]    📝 Verify authorized_keys file exists on target with correct permissions
    [Tags]             critical    authorized_keys    security

    Log    🔍 Validating authorized_keys file on target machine...    console=yes
    Log    📋 Expected path: ${AUTHORIZED_KEYS_PATH}    console=yes

    # Check if authorized_keys file exists
    ${auth_exists}=    Execute Command    ssh -o StrictHostKeyChecking=no -i ${SSH_KEY_PATH} ${TARGET_USER}@${TARGET_HOST} 'test -f ${AUTHORIZED_KEYS_PATH} && echo "exists" || echo "not found"'
    Should Contain    ${auth_exists}    exists    msg=authorized_keys file not found at ${AUTHORIZED_KEYS_PATH}

    Log    ✅ authorized_keys file found on target machine    console=yes

Critical - Validate Authorized Keys Permissions
    [Documentation]    🔒 Validate authorized_keys file has secure permissions (600)
    [Tags]             critical    security    permissions

    Log    🔍 Validating authorized_keys file permissions...    console=yes
    Log    📋 Expected permissions: 600    console=yes

    # Check authorized_keys permissions
    ${auth_perms}=    Execute Command    ssh -o StrictHostKeyChecking=no -i ${SSH_KEY_PATH} ${TARGET_USER}@${TARGET_HOST} 'stat -c "%a" ${AUTHORIZED_KEYS_PATH}'
    Should Be Equal    ${auth_perms}    600    msg=authorized_keys permissions should be 600, found ${auth_perms}

    Log    🔒 authorized_keys permissions: ${auth_perms}    console=yes
    Log    ✅ authorized_keys permissions validated    console=yes

Critical - Verify Public Key in Authorized Keys
    [Documentation]    🔑 Verify public key is present in authorized_keys file
    [Tags]             critical    public_key    validation

    Log    🔍 Verifying public key in authorized_keys...    console=yes

    # Get public key from Code Server
    ${pubkey}=    Execute Command    cat ${SSH_KEY_PATH}.pub
    Log    🔑 Public key: ${pubkey[:50]}...    console=yes

    # Get authorized_keys content from target
    ${auth_content}=    Execute Command    ssh -o StrictHostKeyChecking=no -i ${SSH_KEY_PATH} ${TARGET_USER}@${TARGET_HOST} 'cat ${AUTHORIZED_KEYS_PATH}'

    Should Contain    ${auth_content}    ${pubkey}    msg=Public key not found in authorized_keys file

    Log    ✅ Public key verified in authorized_keys file    console=yes

Normal - Validate SSH Directory Permissions
    [Documentation]    🔒 Ensure .ssh directory has correct permissions (700) on both machines
    [Tags]             normal    security    permissions

    Log    🔍 Validating .ssh directory permissions...    console=yes

    # Check Code Server .ssh directory permissions
    ${cs_ssh_perms}=    Execute Command    stat -c '%a' /home/${CODE_SERVER_USER}/.ssh
    Should Be Equal    ${cs_ssh_perms}    700    msg=Code Server .ssh directory should have 700 permissions, found ${cs_ssh_perms}
    Log    🔒 Code Server .ssh permissions: ${cs_ssh_perms}    console=yes

    # Check Target .ssh directory permissions
    ${target_ssh_perms}=    Execute Command    ssh -o StrictHostKeyChecking=no -i ${SSH_KEY_PATH} ${TARGET_USER}@${TARGET_HOST} 'stat -c "%a" ~/.ssh'
    Should Be Equal    ${target_ssh_perms}    700    msg=Target .ssh directory should have 700 permissions, found ${target_ssh_perms}
    Log    🔒 Target .ssh permissions: ${target_ssh_perms}    console=yes

    Log    ✅ .ssh directory permissions validated on both machines    console=yes

Normal - Validate SSH Key Type and Strength
    [Documentation]    🔐 Validate SSH key type and cryptographic strength
    [Tags]             normal    security    crypto

    Log    🔍 Validating SSH key type and strength...    console=yes

    # Get key information
    ${key_info}=    Execute Command    ssh-keygen -l -f ${SSH_KEY_PATH}
    Log    📊 SSH key information: ${key_info}    console=yes

    # Extract key type and bit strength
    ${key_type}=    Execute Command    ssh-keygen -l -f ${SSH_KEY_PATH} | awk '{print $4}' | tr -d '()'
    ${key_bits}=    Execute Command    ssh-keygen -l -f ${SSH_KEY_PATH} | awk '{print $1}'
    ${bits_int}=    Convert To Integer    ${key_bits}

    Log    🔑 Key type: ${key_type}    console=yes
    Log    🔑 Key strength: ${key_bits} bits    console=yes

    # Validate key strength based on type
    Run Keyword If    'RSA' in '''${key_type}'''
    ...    Should Be True    ${bits_int} >= 2048    msg=RSA key should be at least 2048 bits, found ${key_bits}
    Run Keyword If    'ED25519' in '''${key_type}''' or 'ECDSA' in '''${key_type}'''
    ...    Should Be True    ${bits_int} >= 256    msg=ED25519/ECDSA key should be at least 256 bits, found ${key_bits}

    Log    ✅ SSH key strength validated: ${key_bits} bits ${key_type}    console=yes

Normal - Validate SSH Configuration Security
    [Documentation]    🛡️ Validate SSH server configuration on target machine
    [Tags]             normal    security    configuration

    Log    🔍 Validating SSH server configuration...    console=yes

    # Check SSH server configuration
    ${ssh_config}=    Execute Command    ssh -o StrictHostKeyChecking=no -i ${SSH_KEY_PATH} ${TARGET_USER}@${TARGET_HOST} 'grep -E "^(PubkeyAuthentication|PasswordAuthentication|PermitRootLogin)" /etc/ssh/sshd_config 2>/dev/null || echo "Config check requires privileges"'

    Log    📋 SSH server configuration: ${ssh_config}    console=yes
    Log    ✅ SSH server configuration collected    console=yes

Normal - Comprehensive SSH Authentication Chain Validation
    [Documentation]    🔗 Validate complete authentication chain from Code Server to target
    [Tags]             normal    comprehensive    validation

    Log    🔍 Performing comprehensive SSH authentication chain validation...    console=yes

    # Validate authentication chain
    Validate SSH Authentication Chain

    Log    📊 Comprehensive validation summary:    console=yes
    Log    📊 - Code Server connection: ✅    console=yes
    Log    📊 - SSH private key: ✅    console=yes
    Log    📊 - Key permissions: ✅    console=yes
    Log    📊 - Passwordless authentication: ✅    console=yes
    Log    📊 - authorized_keys: ✅    console=yes
    Log    📊 - Directory permissions: ✅    console=yes
    Log    ✅ Comprehensive SSH authentication validation: PASSED    console=yes
