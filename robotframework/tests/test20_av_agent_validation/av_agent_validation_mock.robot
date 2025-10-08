*** Settings ***
Documentation    🛡️ AV Agent Validation Test Suite - Test-20 (MOCK MODE)
...              🔍 Process: Detect AV type → Collect agent information → Validate protection settings
...              ✅ Pass if AV agent (McAfee or Sentinel One) is installed, running, and meets CIP-007 R3.1 requirements
...              📊 Validates: Agent installation, real-time protection, signature updates, scan schedules, exclusions
...              📋 CIP-007 R3.1: Malicious code prevention via antivirus protection
...              ⚠️  MOCK MODE: For local testing without SSH connection
...
Resource         ../../settings.resource
Resource         variables.resource
Resource         av_keywords_mock.resource

Suite Setup      Initialize AV Test Environment
Suite Teardown   Generate AV Agent Executive Summary

Test Setup       Log Test Start    ${TEST_NAME}
Test Teardown    Log Test End      ${TEST_NAME}    ${TEST_STATUS}

*** Test Cases ***
Critical - Detect Operating System
    [Documentation]    🖥️ Detect the operating system type (Windows/Linux)
    [Tags]             critical    detection    os

    Log    🔍 Detecting operating system type...    console=yes

    ${os_type}=    Detect Operating System
    Set Suite Variable    ${OS_TYPE}    ${os_type}

    Should Not Be Equal    ${os_type}    Unknown    msg=Unable to detect operating system

    Log    ✅ Operating System Detected: ${os_type}    console=yes

Critical - Detect AV Agent Type
    [Documentation]    🔍 Detect installed antivirus agent type
    [Tags]             critical    detection    av_agent

    Log    🔍 Detecting antivirus agent type...    console=yes
    Log    📋 OS Type: ${OS_TYPE}    console=yes

    ${av_type}=    Detect AV Agent    ${OS_TYPE}
    Set Suite Variable    ${AV_TYPE}    ${av_type}

    Should Not Be Equal    ${av_type}    None    msg=No antivirus agent detected

    Log    ✅ AV Agent Detected: ${av_type}    console=yes

Critical - Verify AV Agent Installation
    [Documentation]    📦 Verify AV agent is properly installed
    [Tags]             critical    installation    verification

    Log    🔍 Verifying AV agent installation...    console=yes
    Log    📋 AV Type: ${AV_TYPE}    console=yes
    Log    📋 OS Type: ${OS_TYPE}    console=yes

    ${install_status}=    Verify AV Installation    ${AV_TYPE}    ${OS_TYPE}
    Set Suite Variable    ${INSTALL_STATUS}    ${install_status}

    Should Be True    ${install_status}    msg=AV agent ${AV_TYPE} is not properly installed

    Log    ✅ AV Agent Installation Verified: ${AV_TYPE}    console=yes

Critical - Verify AV Service Running
    [Documentation]    🔄 Verify AV service is running
    [Tags]             critical    service    running

    Log    🔍 Verifying AV service status...    console=yes
    Log    📋 AV Type: ${AV_TYPE}    console=yes

    ${service_status}=    Verify AV Service Running    ${AV_TYPE}    ${OS_TYPE}
    Set Suite Variable    ${SERVICE_STATUS}    ${service_status}

    Should Be True    ${service_status}    msg=AV service ${AV_TYPE} is not running

    Log    ✅ AV Service Running Verified: ${AV_TYPE}    console=yes

Critical - Collect AV Agent Information
    [Documentation]    📊 Collect comprehensive AV agent information
    [Tags]             critical    collection    agent_info

    Log    🔍 Collecting AV agent information...    console=yes

    ${agent_info}=    Collect AV Agent Information    ${AV_TYPE}    ${OS_TYPE}
    Set Suite Variable    ${AGENT_INFO}    ${agent_info}

    Log    📊 Agent Version: ${agent_info}[version]    console=yes
    Log    📊 Agent Status: ${agent_info}[status]    console=yes
    Log    📊 Last Update: ${agent_info}[last_update]    console=yes

    Log    ✅ AV Agent Information Collected    console=yes

Critical - Verify Real-Time Protection Enabled
    [Documentation]    🛡️ Verify real-time protection is enabled
    [Tags]             critical    protection    real_time    cip007

    Log    🔍 Verifying real-time protection status...    console=yes

    ${rtp_enabled}=    Verify Real-Time Protection    ${AV_TYPE}    ${OS_TYPE}
    Set Suite Variable    ${RTP_ENABLED}    ${rtp_enabled}

    Should Be True    ${rtp_enabled}    msg=Real-time protection is not enabled for ${AV_TYPE}

    Log    ✅ Real-Time Protection Enabled: ${AV_TYPE}    console=yes

Critical - Collect Signature Update Status
    [Documentation]    📅 Collect antivirus signature update status
    [Tags]             critical    collection    signatures    updates

    Log    🔍 Collecting signature update status...    console=yes

    ${sig_info}=    Get Signature Update Status    ${AV_TYPE}    ${OS_TYPE}
    Set Suite Variable    ${SIGNATURE_INFO}    ${sig_info}

    Log    📊 Last Signature Update: ${sig_info}[last_update]    console=yes
    Log    📊 Signature Version: ${sig_info}[version]    console=yes

    Log    ✅ Signature Update Status Collected    console=yes

Critical - Validate Signature Update Recency
    [Documentation]    ⏰ Validate signatures are updated within required timeframe
    [Tags]             critical    validation    signatures    cip007

    Log    🔍 Validating signature update recency...    console=yes
    Log    📋 Maximum allowed age: ${MAX_SIGNATURE_AGE_DAYS} days    console=yes

    ${signature_age}=    Calculate Days Since Update    ${SIGNATURE_INFO}[last_update]
    Set Suite Variable    ${SIGNATURE_AGE}    ${signature_age}

    Should Be True    ${signature_age} <= ${MAX_SIGNATURE_AGE_DAYS}
    ...    msg=Signatures are ${signature_age} days old (max allowed: ${MAX_SIGNATURE_AGE_DAYS} days)

    Log    ✅ Signature Update Recency Validated: ${signature_age} days old    console=yes

Normal - Collect Scheduled Scan Configuration
    [Documentation]    📅 Collect scheduled scan configuration
    [Tags]             normal    collection    scans    schedule

    Log    🔍 Collecting scheduled scan configuration...    console=yes

    ${scan_config}=    Get Scheduled Scan Configuration    ${AV_TYPE}    ${OS_TYPE}
    Set Suite Variable    ${SCAN_CONFIG}    ${scan_config}

    Log    📊 Scan Schedule: ${scan_config}[schedule]    console=yes
    Log    📊 Last Scan: ${scan_config}[last_scan]    console=yes

    Log    ✅ Scheduled Scan Configuration Collected    console=yes

Normal - Collect AV Exclusions
    [Documentation]    📋 Collect antivirus exclusion list
    [Tags]             normal    collection    exclusions

    Log    🔍 Collecting AV exclusions...    console=yes

    ${exclusions}=    Get AV Exclusions    ${AV_TYPE}    ${OS_TYPE}
    Set Suite Variable    ${EXCLUSIONS}    ${exclusions}

    Log    📊 Exclusion Count: ${exclusions}[count]    console=yes
    Log    📊 Excluded Paths: ${exclusions}[paths]    console=yes
    Log    📊 Excluded Processes: ${exclusions}[processes]    console=yes

    Log    ✅ AV Exclusions Collected    console=yes

Normal - Verify Console Reporting
    [Documentation]    📡 Verify AV agent is reporting to management console
    [Tags]             normal    console    reporting    management

    Log    🔍 Verifying console reporting status...    console=yes

    ${console_status}=    Verify Console Reporting    ${AV_TYPE}    ${OS_TYPE}
    Set Suite Variable    ${CONSOLE_STATUS}    ${console_status}

    ${is_connected}=    Get From Dictionary    ${console_status}    is_connected

    Log    📊 Console Connected: ${is_connected}    console=yes
    Log    📊 Console Address: ${console_status}[console_address]    console=yes
    Log    📊 Last Check-in: ${console_status}[last_checkin]    console=yes

    Log    ✅ Console Reporting Status Collected    console=yes

Normal - Capture AV Agent Screenshots
    [Documentation]    📸 Capture screenshots/output of AV agent status
    [Tags]             normal    screenshots    documentation

    Log    🔍 Capturing AV agent screenshots...    console=yes

    ${screenshot_paths}=    Capture AV Screenshots    ${AV_TYPE}    ${OS_TYPE}
    Set Suite Variable    ${SCREENSHOT_PATHS}    ${screenshot_paths}

    Log    📸 Screenshots captured: ${screenshot_paths}    console=yes

    Log    ✅ AV Agent Screenshots Captured    console=yes

Critical - Validate CIP-007 R3.1 Compliance
    [Documentation]    ✅ Validate complete CIP-007 R3.1 malicious code prevention compliance
    [Tags]             critical    compliance    cip007    validation

    Log    🔍 Validating CIP-007 R3.1 compliance...    console=yes
    Log    📋 CIP-007 R3.1: Malicious Code Prevention    console=yes

    # Validate compliance
    ${compliance}=    Validate CIP007 R31 Compliance
    ...    ${INSTALL_STATUS}
    ...    ${SERVICE_STATUS}
    ...    ${RTP_ENABLED}
    ...    ${SIGNATURE_AGE}
    ...    ${CONSOLE_STATUS}[is_connected]

    ${is_compliant}=    Get From Dictionary    ${compliance}    is_compliant
    ${failures}=    Get From Dictionary    ${compliance}    failures

    # Log compliance status
    IF    ${is_compliant}
        Log    ✅ CIP-007 R3.1 COMPLIANT    console=yes
    ELSE
        ${failure_count}=    Get Length    ${failures}
        Log    ❌ CIP-007 R3.1 NON-COMPLIANT: ${failure_count} failures    console=yes
        FOR    ${failure}    IN    @{failures}
            Log    ❌ ${failure}    console=yes
        END
        Fail    CIP-007 R3.1 compliance validation failed: ${failure_count} issues found
    END

    Log    ✅ CIP-007 R3.1 Compliance Validation: PASSED    console=yes
