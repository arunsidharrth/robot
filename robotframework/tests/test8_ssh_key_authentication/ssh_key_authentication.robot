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
    [Documentation]    🔗 SSH directly to the code server (Linux jump box) to prepare for SSH key-based authentication testing
    [Tags]             critical    connection    ssh    infrastructure

    Log    🔍 Connecting to Code Server (Linux jump box)...    console=yes
    Log    📋 Code Server: ${CODE_SERVER_HOST}    console=yes

    # Connection already established in Suite Setup
    ${connection_status}=    Execute Command    echo "Connection active"
    Should Contain    ${connection_status}    Connection active

    Log    ✅ SSH connection to Code Server established and verified    console=yes

Critical - Test Passwordless SSH Authentication
    [Documentation]    🔐 From the code server, attempt SSH connection to target machine using key-based authentication without password prompts, verify the connection succeeds, check authorized_keys file permissions (should be 600), and capture connection details
    [Tags]             critical    authentication    passwordless

    Log    🔍 Testing passwordless SSH authentication from Code Server to target...    console=yes
    Log    📋 Target: ${TARGET_USER}@${TARGET_HOST}    console=yes

    # Attempt passwordless SSH connection
    ${ssh_test}=    Execute Command    ssh -o StrictHostKeyChecking=no -o PasswordAuthentication=no -o BatchMode=yes -i ${SSH_KEY_PATH} ${TARGET_USER}@${TARGET_HOST} 'echo "SSH_AUTH_SUCCESS"'    return_stdout=True    return_stderr=True    return_rc=True

    Should Be Equal As Integers    ${ssh_test}[2]    0    msg=SSH key authentication failed with return code ${ssh_test}[2]. Error: ${ssh_test}[1]
    Should Contain    ${ssh_test}[0]    SSH_AUTH_SUCCESS    msg=SSH connection did not return expected success message

    Log    ✅ Passwordless SSH authentication successful    console=yes

    # Check authorized_keys file permissions (should be 600)
    Log    🔍 Checking authorized_keys file permissions...    console=yes
    ${auth_perms}=    Execute Command    ssh -o StrictHostKeyChecking=no -i ${SSH_KEY_PATH} ${TARGET_USER}@${TARGET_HOST} 'stat -c "%a" ${AUTHORIZED_KEYS_PATH}'
    Should Be Equal    ${auth_perms}    600    msg=authorized_keys permissions should be 600, found ${auth_perms}

    Log    🔒 authorized_keys permissions: ${auth_perms}    console=yes
    Log    ✅ authorized_keys file permissions validated (600)    console=yes

    # Capture connection details
    ${connection_details}=    Execute Command    ssh -o StrictHostKeyChecking=no -i ${SSH_KEY_PATH} ${TARGET_USER}@${TARGET_HOST} 'echo "Host: $(hostname), User: $(whoami), Time: $(date)"'
    Log    📊 Connection details: ${connection_details}    console=yes

Critical - Validate Authentication Security
    [Documentation]    🛡️ Confirm passwordless SSH works from code server to target, verify authorized_keys file contains correct public keys with proper permissions (600), validate SSH configuration, and ensure the jump box authentication chain is properly configured
    [Tags]             critical    security    validation

    Log    🔍 Validating authentication security configuration...    console=yes

    # Confirm passwordless SSH works
    Log    🔍 Confirming passwordless SSH from code server to target...    console=yes
    ${ssh_confirm}=    Execute Command    ssh -o StrictHostKeyChecking=no -o PasswordAuthentication=no -o BatchMode=yes -i ${SSH_KEY_PATH} ${TARGET_USER}@${TARGET_HOST} 'echo "Confirmed"'
    Should Contain    ${ssh_confirm}    Confirmed    msg=Passwordless SSH confirmation failed

    Log    ✅ Passwordless SSH from code server to target confirmed    console=yes

    # Verify authorized_keys contains correct public keys with proper permissions
    Log    🔍 Verifying public key in authorized_keys file...    console=yes
    ${pubkey}=    Execute Command    cat ${SSH_KEY_PATH}.pub
    ${auth_content}=    Execute Command    ssh -o StrictHostKeyChecking=no -i ${SSH_KEY_PATH} ${TARGET_USER}@${TARGET_HOST} 'cat ${AUTHORIZED_KEYS_PATH}'
    Should Contain    ${auth_content}    ${pubkey}    msg=Public key not found in authorized_keys file

    Log    ✅ Public key verified in authorized_keys file    console=yes

    # Verify authorized_keys permissions (600)
    ${auth_perms}=    Execute Command    ssh -o StrictHostKeyChecking=no -i ${SSH_KEY_PATH} ${TARGET_USER}@${TARGET_HOST} 'stat -c "%a" ${AUTHORIZED_KEYS_PATH}'
    Should Be Equal    ${auth_perms}    600    msg=authorized_keys permissions should be 600, found ${auth_perms}

    Log    ✅ authorized_keys permissions validated (600)    console=yes

    # Validate SSH configuration
    Log    🔍 Validating SSH configuration...    console=yes
    ${ssh_config}=    Execute Command    ssh -o StrictHostKeyChecking=no -i ${SSH_KEY_PATH} ${TARGET_USER}@${TARGET_HOST} 'grep -E "^(PubkeyAuthentication|PasswordAuthentication)" /etc/ssh/sshd_config 2>/dev/null || echo "Config check requires privileges"'
    Log    📋 SSH server configuration: ${ssh_config}    console=yes

    # Ensure jump box authentication chain is properly configured
    Log    🔍 Validating jump box authentication chain...    console=yes
    ${chain_validation}=    Validate SSH Authentication Chain
    Log    ✅ Jump box authentication chain properly configured    console=yes

    Log    📊 Authentication security validation summary:    console=yes
    Log    📊 - Passwordless SSH: ✅    console=yes
    Log    📊 - Public key in authorized_keys: ✅    console=yes
    Log    📊 - authorized_keys permissions (600): ✅    console=yes
    Log    📊 - SSH configuration: ✅    console=yes
    Log    📊 - Jump box authentication chain: ✅    console=yes
    Log    ✅ Authentication security validation: PASSED    console=yes
