*** Settings ***
Documentation    🛡️ AV Agent Validation Test Suite - Test-20
...              🔍 Process: Connect to target → Detect AV type → Collect agent information → Validate protection settings
...              ✅ Pass if AV agent (McAfee or Sentinel One) is installed, running, and meets CIP-007 R3.1 requirements
...              📊 Validates: Agent installation, real-time protection, signature updates, scan schedules, exclusions
...              📋 CIP-007 R3.1: Malicious code prevention via antivirus protection
...
Resource         ../../settings.resource
Resource         variables.resource
Resource         av_keywords.resource

Suite Setup      Initialize AV Test Environment
Suite Teardown   Generate AV Agent Executive Summary

Test Setup       Log Test Start    ${TEST_NAME}
Test Teardown    Log Test End      ${TEST_NAME}    ${TEST_STATUS}

*** Test Cases ***
Critical - Connect to Target Machine
    [Documentation]    🔗 Establish SSH connection to target machine for AV validation
    [Tags]             critical    connection    ssh    infrastructure

    Log    🔍 Connecting to target machine for AV validation...    console=yes
    Log    📋 Target Host: ${TARGET_HOSTNAME}    console=yes
    Log    📋 Username: ${SSH_USERNAME}    console=yes

    ${connection_status}=    Execute Command    echo "Connection active"
    Should Contain    ${connection_status}    Connection active

    Log    ✅ SSH connection to target machine verified and active    console=yes

Critical - Detect Operating System Type
    [Documentation]    🖥️ Detect operating system type (Windows/Linux) for appropriate AV detection
    [Tags]             critical    os_detection    platform

    Log    🔍 Detecting operating system type...    console=yes

    ${os_type}=    Detect Operating System
    Set Suite Variable    ${OS_TYPE}    ${os_type}

    Log    🖥️ Operating System: ${os_type}    console=yes
    Log    ✅ Operating system detected successfully    console=yes

Critical - Detect Installed AV Agent
    [Documentation]    🔍 Detect installed antivirus agent (McAfee, Sentinel One, or other)
    [Tags]             critical    av_detection    agent

    Log    🔍 Detecting installed antivirus agent...    console=yes
    Log    📋 OS Type: ${OS_TYPE}    console=yes

    ${av_type}=    Detect AV Agent    ${OS_TYPE}
    Set Suite Variable    ${AV_TYPE}    ${av_type}

    Log    🛡️ Detected AV Agent: ${av_type}    console=yes

    Should Not Be Empty    ${av_type}    msg=No supported AV agent detected (McAfee or Sentinel One)
    Should Match Regexp    ${av_type}    (?i)(mcafee|sentinelone|sentinel)    msg=Detected AV is not McAfee or Sentinel One: ${av_type}

    Log    ✅ AV agent detected: ${av_type}    console=yes

Critical - Verify AV Agent Installation Status
    [Documentation]    📦 Verify antivirus agent is properly installed
    [Tags]             critical    installation    status

    Log    🔍 Verifying AV agent installation status...    console=yes
    Log    📋 AV Type: ${AV_TYPE}    console=yes

    ${install_status}=    Verify AV Installation    ${AV_TYPE}    ${OS_TYPE}
    Set Suite Variable    ${INSTALL_STATUS}    ${install_status}

    Should Be True    ${install_status}    msg=AV agent is not properly installed

    Log    ✅ AV agent installation verified    console=yes

Critical - Verify AV Agent Service Status
    [Documentation]    🔄 Verify AV agent service is running
    [Tags]             critical    service    running

    Log    🔍 Verifying AV agent service status...    console=yes
    Log    📋 AV Type: ${AV_TYPE}    console=yes

    ${service_status}=    Verify AV Service Running    ${AV_TYPE}    ${OS_TYPE}
    Set Suite Variable    ${SERVICE_STATUS}    ${service_status}

    Should Be True    ${service_status}    msg=AV agent service is not running

    Log    ✅ AV agent service is running    console=yes

Critical - Collect AV Agent Information
    [Documentation]    📊 Collect comprehensive AV agent information
    [Tags]             critical    collection    information

    Log    🔍 Collecting AV agent information...    console=yes

    ${agent_info}=    Collect AV Agent Information    ${AV_TYPE}    ${OS_TYPE}
    Set Suite Variable    ${AGENT_INFO}    ${agent_info}

    Log    📊 Agent Version: ${agent_info}[version]    console=yes
    Log    📊 Agent Status: ${agent_info}[status]    console=yes

    Should Not Be Empty    ${agent_info}[version]    msg=Could not retrieve AV agent version

    Log    ✅ AV agent information collected    console=yes

Critical - Verify Real-Time Protection Enabled
    [Documentation]    🛡️ Verify real-time protection is enabled (CIP-007 R3.1 requirement)
    [Tags]             critical    real_time    protection    cip_007

    Log    🔍 Verifying real-time protection status...    console=yes
    Log    📋 CIP-007 R3.1: Malicious code prevention requires real-time scanning    console=yes

    ${rtp_enabled}=    Verify Real-Time Protection    ${AV_TYPE}    ${OS_TYPE}
    Set Suite Variable    ${RTP_ENABLED}    ${rtp_enabled}

    Should Be True    ${rtp_enabled}    msg=Real-time protection is NOT enabled - CIP-007 R3.1 VIOLATION

    Log    ✅ Real-time protection is ENABLED    console=yes
    Log    ✅ CIP-007 R3.1 requirement met: Real-time protection active    console=yes

Critical - Verify Signature Update Status
    [Documentation]    📅 Verify antivirus signatures are up-to-date
    [Tags]             critical    signatures    updates    cip_007

    Log    🔍 Verifying AV signature update status...    console=yes
    Log    📋 CIP-007 R3.1: Requires current malware definitions    console=yes

    ${sig_info}=    Get Signature Update Status    ${AV_TYPE}    ${OS_TYPE}
    Set Suite Variable    ${SIGNATURE_INFO}    ${sig_info}

    Log    📅 Last Signature Update: ${sig_info}[last_update]    console=yes
    Log    📊 Signature Version: ${sig_info}[version]    console=yes

    ${days_old}=    Calculate Days Since Update    ${sig_info}[last_update]
    Set Suite Variable    ${SIGNATURE_AGE}    ${days_old}

    Should Be True    ${days_old} <= 7    msg=Signatures are ${days_old} days old (>7 days) - CIP-007 R3.1 VIOLATION

    Log    ✅ Signatures are current: ${days_old} days old    console=yes
    Log    ✅ CIP-007 R3.1 requirement met: Current malware definitions    console=yes

Normal - Verify Scheduled Scan Configuration
    [Documentation]    📅 Verify scheduled scans are configured
    [Tags]             normal    scheduled_scan    configuration

    Log    🔍 Verifying scheduled scan configuration...    console=yes

    ${scan_config}=    Get Scheduled Scan Configuration    ${AV_TYPE}    ${OS_TYPE}
    Set Suite Variable    ${SCAN_CONFIG}    ${scan_config}

    Should Not Be Empty    ${scan_config}[schedule]    msg=No scheduled scans configured

    Log    📅 Scan Schedule: ${scan_config}[schedule]    console=yes
    Log    📅 Last Scan: ${scan_config}[last_scan]    console=yes

    Log    ✅ Scheduled scan configuration verified    console=yes

Normal - Collect Exclusion List Configuration
    [Documentation]    📋 Collect antivirus exclusion list configuration
    [Tags]             normal    exclusions    configuration

    Log    🔍 Collecting AV exclusion list configuration...    console=yes

    ${exclusions}=    Get AV Exclusions    ${AV_TYPE}    ${OS_TYPE}
    Set Suite Variable    ${EXCLUSIONS}    ${exclusions}

    Log    📋 Total Exclusions: ${exclusions}[count]    console=yes
    Log    📋 Path Exclusions: ${exclusions}[paths]    console=yes
    Log    📋 Process Exclusions: ${exclusions}[processes]    console=yes

    Log    ✅ Exclusion list collected    console=yes

Normal - Verify AV Console Reporting
    [Documentation]    📡 Verify AV agent is reporting to management console
    [Tags]             normal    console    reporting

    Log    🔍 Verifying AV console reporting status...    console=yes

    ${console_status}=    Verify Console Reporting    ${AV_TYPE}    ${OS_TYPE}
    Set Suite Variable    ${CONSOLE_STATUS}    ${console_status}

    Should Be True    ${console_status}[is_connected]    msg=AV agent is not reporting to management console

    Log    📡 Console: ${console_status}[console_address]    console=yes
    Log    📡 Last Check-in: ${console_status}[last_checkin]    console=yes

    Log    ✅ AV console reporting verified    console=yes

Normal - Capture AV Agent Screenshots
    [Documentation]    📸 Capture screenshots of AV agent console and status
    [Tags]             normal    screenshots    documentation

    Log    📸 Capturing AV agent screenshots...    console=yes

    ${screenshot_paths}=    Capture AV Screenshots    ${AV_TYPE}    ${OS_TYPE}
    Set Suite Variable    ${SCREENSHOT_PATHS}    ${screenshot_paths}

    Log    📸 Screenshots saved to: ${screenshot_paths}    console=yes
    Log    ✅ AV agent screenshots captured    console=yes

Normal - Validate Against CIP-007 R3.1 Requirements
    [Documentation]    ✅ Comprehensive validation against CIP-007 R3.1 requirements
    [Tags]             normal    compliance    cip_007    validation

    Log    🔍 Validating complete AV configuration against CIP-007 R3.1...    console=yes
    Log    📋 CIP-007 R3.1 Requirements:    console=yes
    Log    📋   1. Malware prevention tools deployed    console=yes
    Log    📋   2. Real-time protection enabled    console=yes
    Log    📋   3. Current malware definitions    console=yes
    Log    📋   4. Regular updates configured    console=yes

    # Validate all requirements
    ${compliance}=    Validate CIP007 R31 Compliance
    ...    agent_installed=${INSTALL_STATUS}
    ...    service_running=${SERVICE_STATUS}
    ...    rtp_enabled=${RTP_ENABLED}
    ...    signature_age=${SIGNATURE_AGE}
    ...    console_connected=${CONSOLE_STATUS}[is_connected]

    Should Be True    ${compliance}[is_compliant]    msg=CIP-007 R3.1 compliance validation FAILED: ${compliance}[failures]

    Log    ✅ CIP-007 R3.1 Compliance Validation Summary:    console=yes
    Log    ✅   - AV Agent Installed: ✅ ${AV_TYPE}    console=yes
    Log    ✅   - Service Running: ✅    console=yes
    Log    ✅   - Real-Time Protection: ✅ Enabled    console=yes
    Log    ✅   - Signature Age: ✅ ${SIGNATURE_AGE} days old    console=yes
    Log    ✅   - Console Reporting: ✅ Connected    console=yes
    Log    ✅ CIP-007 R3.1 COMPLIANCE: PASSED ✅    console=yes
