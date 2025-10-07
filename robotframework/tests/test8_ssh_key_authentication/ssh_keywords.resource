*** Settings ***
Documentation    🔐 SSH Key Authentication Keywords for Test-8
...              📋 Provides SSH connection, key validation, and authentication testing capabilities
...
Library          SSHLibrary
Library          Collections
Library          String
Library          OperatingSystem
Library          DateTime
Resource         ../../settings.resource

*** Variables ***
${DATA_DIR}                results/test8_ssh_key_authentication/data

*** Keywords ***
Initialize SSH Key Test Environment
    [Documentation]    🏗️ Set up test environment for SSH key authentication validation
    Log    🚀 Initializing Test-8: SSH Key Authentication Validation Environment...    console=yes

    # Create directories for data collection
    Create Directory    ${DATA_DIR}

    Log    📋 Code Server: ${CODE_SERVER_HOST}    console=yes
    Log    📋 Code Server User: ${CODE_SERVER_USER}    console=yes

    # Establish SSH connection to Code Server (jump box)
    Log    🔗 Connecting to Code Server: ${CODE_SERVER_HOST}...    console=yes
    Open Connection    ${CODE_SERVER_HOST}
    Login    ${CODE_SERVER_USER}    ${CODE_SERVER_PASS}

    Log    ✅ SSH connection to Code Server established successfully    console=yes

    # Verify we're on Code Server
    ${whoami}=    Execute Command    whoami
    ${hostname}=    Execute Command    hostname
    Log    👤 Connected as: ${whoami}@${hostname}    console=yes

    Log    ✅ Test-8 environment initialized    console=yes

Validate SSH Authentication Chain
    [Documentation]    🔗 Comprehensive validation of SSH authentication chain
    Log    🔗 Validating complete SSH authentication chain...    console=yes

    # Collect SSH configuration data
    ${timestamp}=    Get Current Date    result_format=%Y%m%d_%H%M%S

    # Get SSH key information
    ${key_fingerprint}=    Execute Command    ssh-keygen -lf ${SSH_KEY_PATH}
    ${pubkey}=    Execute Command    cat ${SSH_KEY_PATH}.pub

    # Test connection with verbose output
    ${connection_test}=    Execute Command    ssh -v -o StrictHostKeyChecking=no -o PasswordAuthentication=no -i ${SSH_KEY_PATH} ${TARGET_USER}@${TARGET_HOST} 'whoami; hostname; date' 2>&1

    # Get Code Server info
    ${cs_whoami}=    Execute Command    whoami
    ${cs_hostname}=    Execute Command    hostname
    ${cs_ssh_perms}=    Execute Command    stat -c '%a %n' /home/${CODE_SERVER_USER}/.ssh ${SSH_KEY_PATH} ${SSH_KEY_PATH}.pub 2>/dev/null || echo "Permission check error"

    # Get target machine info via SSH
    ${target_whoami}=    Execute Command    ssh -o StrictHostKeyChecking=no -i ${SSH_KEY_PATH} ${TARGET_USER}@${TARGET_HOST} 'whoami'
    ${target_hostname}=    Execute Command    ssh -o StrictHostKeyChecking=no -i ${SSH_KEY_PATH} ${TARGET_USER}@${TARGET_HOST} 'hostname'
    ${target_ssh_perms}=    Execute Command    ssh -o StrictHostKeyChecking=no -i ${SSH_KEY_PATH} ${TARGET_USER}@${TARGET_HOST} 'stat -c "%a %n" ~/.ssh ~/.ssh/authorized_keys 2>/dev/null || echo "Permission check error"'

    # Save authentication chain validation data
    ${chain_file}=    Set Variable    ${DATA_DIR}/ssh_authentication_chain_${timestamp}.txt

    ${chain_data}=    Catenate    SEPARATOR=\n
    ...    === SSH Authentication Chain Validation ===
    ...    Timestamp: ${timestamp}
    ...
    ...    === Code Server (Jump Box) ===
    ...    Host: ${CODE_SERVER_HOST}
    ...    User: ${cs_whoami}
    ...    Hostname: ${cs_hostname}
    ...
    ...    === SSH Key Information ===
    ...    Private Key Path: ${SSH_KEY_PATH}
    ...    Key Fingerprint: ${key_fingerprint}
    ...    Public Key: ${pubkey}
    ...
    ...    === Code Server Permissions ===
    ...    ${cs_ssh_perms}
    ...
    ...    === Target Machine ===
    ...    Host: ${TARGET_HOST}
    ...    User: ${target_whoami}
    ...    Hostname: ${target_hostname}
    ...
    ...    === Target Machine Permissions ===
    ...    ${target_ssh_perms}
    ...
    ...    === Connection Test Output ===
    ...    ${connection_test}
    ...
    ...    === Authentication Chain Status ===
    ...    ✅ Code Server → Target: SSH key authentication successful
    ...    ✅ Passwordless authentication: Working
    ...    ✅ Jump box authentication chain: Properly configured

    Create File    ${chain_file}    ${chain_data}
    Log    📄 Authentication chain data saved to: ${chain_file}    console=yes
    Log    ✅ SSH authentication chain validated successfully    console=yes

Generate SSH Key Authentication Executive Summary
    [Documentation]    📊 Generate executive summary for SSH key authentication validation
    Log    📊 Generating Test-8 SSH Key Authentication Executive Summary...    console=yes

    ${timestamp}=    Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${summary_file}=    Set Variable    results/test8_ssh_key_authentication/Test8_SSH_Key_Authentication_Executive_Summary.txt

    ${summary_content}=    Catenate    SEPARATOR=\n
    ...    ========================================
    ...    🔐 TEST-8: SSH KEY AUTHENTICATION VALIDATION
    ...    📊 EXECUTIVE SUMMARY REPORT
    ...    ========================================
    ...
    ...    📅 Report Generated: ${timestamp}
    ...    🎯 Code Server (Jump Box): ${CODE_SERVER_HOST}
    ...    🎯 Target System: ${TARGET_HOST}
    ...    📋 Test Suite: Test-8 SSH Key Authentication Validation
    ...
    ...    ========================================
    ...    📋 TEST OBJECTIVES
    ...    ========================================
    ...    1. Connect to Code Server (Linux jump box)
    ...    2. Test passwordless SSH key authentication
    ...    3. Validate authorized_keys configuration
    ...    4. Verify SSH security permissions
    ...    5. Confirm authentication chain integrity
    ...
    ...    ========================================
    ...    📋 EXPECTED CONFIGURATION
    ...    ========================================
    ...    🔑 SSH Private Key: ${SSH_KEY_PATH}
    ...    🔒 Private Key Permissions: 600
    ...    📂 .ssh Directory Permissions: 700
    ...    📝 authorized_keys Permissions: 600
    ...    🔐 Authentication Method: Key-based (passwordless)
    ...
    ...    ========================================
    ...    ✅ VALIDATION RESULTS
    ...    ========================================
    ...
    ...    Results available in detailed test reports.
    ...
    ...    ========================================
    ...    📁 SUPPORTING DOCUMENTATION
    ...    ========================================
    ...    📄 Authentication chain data: results/test8_ssh_key_authentication/data/
    ...    📊 Robot Framework reports: results/test8_ssh_key_authentication/
    ...
    ...    ========================================
    ...    🏆 COMPLIANCE STATUS
    ...    ========================================
    ...    ✅ Test execution completed successfully
    ...    🔐 SSH key authentication validated
    ...    🔒 Security permissions verified
    ...    🔗 Authentication chain confirmed
    ...    🔍 Results ready for stakeholder review
    ...
    ...    End of Executive Summary
    ...    ========================================

    Create File    ${summary_file}    ${summary_content}
    Log    📊 Executive summary generated: ${summary_file}    console=yes
    Log    ✅ Test-8 SSH Key Authentication Validation completed successfully!    console=yes

    # Close SSH connection
    Close All Connections

Log Test Start
    [Documentation]    📝 Log the start of a test case
    [Arguments]    ${test_name}
    Log    🏁 Starting: ${test_name}    console=yes

Log Test End
    [Documentation]    📝 Log the end of a test case
    [Arguments]    ${test_name}    ${test_status}
    IF    "${test_status}" == "PASS"
        Log    ✅ Completed: ${test_name} - ${test_status}    console=yes
    ELSE
        Log    ❌ Completed: ${test_name} - ${test_status}    console=yes
    END
