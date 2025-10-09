*** Settings ***
Documentation    🛡️ AV Agent Validation Test Suite - Test-20
...              🔍 Process: Connect to AV Console → Collect AV Agent Information → Validate AV Protection
...              ✅ Pass if antivirus configuration meets CIP-007 R3.1 requirements for malware protection
...              📊 Validates: Agent installation, real-time protection, signature updates, scan schedules, exclusions
...
Resource         ../../settings.resource
Resource         av_keywords.resource
Resource         variables.resource

Suite Setup      Initialize AV Agent Validation Test Environment
Suite Teardown   Generate AV Agent Validation Executive Summary

Test Setup       Log Test Start    ${TEST_NAME}
Test Teardown    Log Test End      ${TEST_NAME}    ${TEST_STATUS}

*** Test Cases ***
Critical - Connect to AV Console
    [Documentation]    🔗 SSH directly to the target machine to check Sentinel or McAfee installation status
    [Tags]             critical    connection    av_console

    Log    🔍 Connecting to target machine to check AV installation...    console=yes
    Log    📋 Target Machine: ${TARGET_HOSTNAME}    console=yes
    Log    📋 Expected AV Type: ${AV_TYPE}    console=yes

    # SSH connection already established in Suite Setup
    ${connection_status}=    Execute Command    echo "Connection active"
    Should Contain    ${connection_status}    Connection active

    # Check AV installation status
    ${av_installed}=    Check AV Installation Status
    Should Be True    ${av_installed}    msg=AV agent (${AV_TYPE}) not found on target machine

    Log    ✅ SSH connection established and AV installation confirmed    console=yes

Critical - Collect AV Agent Information
    [Documentation]    📊 Execute antivirus commands to gather agent installation status, real-time protection settings, signature update dates, scan schedules, and exclusion configurations while capturing screenshots of console listings and saving outputs
    [Tags]             critical    av_collection    information

    Log    🔍 Collecting AV agent information...    console=yes
    Log    📋 Target Machine: ${TARGET_HOSTNAME}    console=yes

    # Collect agent installation status
    Log    📊 Gathering agent installation status...    console=yes
    ${agent_status}=    Collect Agent Installation Status
    Set Suite Variable    ${AGENT_STATUS}    ${agent_status}
    Should Not Be Empty    ${agent_status}    msg=Failed to collect agent installation status
    Log    ✅ Agent installation status: ${agent_status['version']} - ${agent_status['status']}    console=yes

    # Collect real-time protection settings
    Log    📊 Gathering real-time protection settings...    console=yes
    ${rtp_settings}=    Collect Real Time Protection Settings
    Set Suite Variable    ${RTP_SETTINGS}    ${rtp_settings}
    Should Not Be Empty    ${rtp_settings}    msg=Failed to collect real-time protection settings
    Log    ✅ Real-time protection status: ${rtp_settings['enabled']}    console=yes

    # Collect signature update dates
    Log    📊 Gathering signature update information...    console=yes
    ${signature_info}=    Collect Signature Update Information
    Set Suite Variable    ${SIGNATURE_INFO}    ${signature_info}
    Should Not Be Empty    ${signature_info}    msg=Failed to collect signature update information
    Log    ✅ Signature last updated: ${signature_info['last_update']}    console=yes

    # Collect scan schedules
    Log    📊 Gathering scan schedule configuration...    console=yes
    ${scan_schedule}=    Collect Scan Schedule Configuration
    Set Suite Variable    ${SCAN_SCHEDULE}    ${scan_schedule}
    Should Not Be Empty    ${scan_schedule}    msg=Failed to collect scan schedule
    Log    ✅ Scan schedule: ${scan_schedule['frequency']}    console=yes

    # Collect exclusion configurations
    Log    📊 Gathering exclusion configurations...    console=yes
    ${exclusions}=    Collect Exclusion Configurations
    Set Suite Variable    ${EXCLUSIONS}    ${exclusions}
    Should Not Be Empty    ${exclusions}    msg=Failed to collect exclusion configurations
    ${exclusion_count}=    Get Length    ${exclusions['paths']}
    Log    ✅ Exclusion paths configured: ${exclusion_count}    console=yes

    # Capture screenshots and save outputs
    Log    📸 Capturing console screenshots and saving outputs...    console=yes
    ${screenshot_path}=    Capture AV Console Screenshot
    Set Suite Variable    ${SCREENSHOT_PATH}    ${screenshot_path}
    OperatingSystem.File Should Exist    ${screenshot_path}
    Log    ✅ Screenshot saved: ${screenshot_path}    console=yes

    ${output_file}=    Save AV Agent Output
    Set Suite Variable    ${OUTPUT_FILE}    ${output_file}
    OperatingSystem.File Should Exist    ${output_file}
    Log    ✅ Output saved: ${output_file}    console=yes

    Log    ✅ All AV agent information collected successfully    console=yes

Critical - Validate AV Protection
    [Documentation]    ✅ Compare all collected antivirus data (agent installation, real-time protection status, signature currency, console reporting, scheduled scans, exclusion policies) against CIP-007 R3.1 requirements to ensure proper malware protection and compliance
    [Tags]             critical    validation    cip007_r31    compliance

    Log    🔍 Validating AV protection against CIP-007 R3.1 requirements...    console=yes

    # Validate agent installation
    Log    🔍 Validating agent installation status...    console=yes
    ${agent_valid}=    Validate Agent Installation    ${AGENT_STATUS}
    Should Be True    ${agent_valid}    msg=Agent installation validation failed
    Log    ✅ Agent installation validated    console=yes

    # Validate real-time protection status
    Log    🔍 Validating real-time protection status...    console=yes
    ${rtp_enabled}=    Get From Dictionary    ${RTP_SETTINGS}    enabled
    Should Be Equal    ${rtp_enabled}    True    msg=Real-time protection is not enabled
    Log    ✅ Real-time protection status validated (Enabled)    console=yes

    # Validate signature currency
    Log    🔍 Validating signature currency...    console=yes
    Log    📋 Maximum signature age: ${MAX_SIGNATURE_AGE_DAYS} days    console=yes
    ${signature_valid}=    Validate Signature Currency    ${SIGNATURE_INFO}
    Should Be True    ${signature_valid}    msg=Signature validation failed - outdated signatures
    Log    ✅ Signature currency validated (Current)    console=yes

    # Validate console reporting
    Log    🔍 Validating console reporting...    console=yes
    ${console_reporting}=    Validate Console Reporting
    Should Be True    ${console_reporting}    msg=Console reporting validation failed
    Log    ✅ Console reporting validated    console=yes

    # Validate scheduled scans
    Log    🔍 Validating scheduled scan configuration...    console=yes
    ${scan_valid}=    Validate Scheduled Scans    ${SCAN_SCHEDULE}
    Should Be True    ${scan_valid}    msg=Scheduled scan validation failed
    Log    ✅ Scheduled scans validated    console=yes

    # Validate exclusion policies
    Log    🔍 Validating exclusion policies...    console=yes
    ${exclusion_valid}=    Validate Exclusion Policies    ${EXCLUSIONS}
    Should Be True    ${exclusion_valid}    msg=Exclusion policy validation failed
    Log    ✅ Exclusion policies validated    console=yes

    Log    📊 AV protection validation summary (CIP-007 R3.1):    console=yes
    Log    📊 - Agent installation: ✅    console=yes
    Log    📊 - Real-time protection: ✅    console=yes
    Log    📊 - Signature currency: ✅    console=yes
    Log    📊 - Console reporting: ✅    console=yes
    Log    📊 - Scheduled scans: ✅    console=yes
    Log    📊 - Exclusion policies: ✅    console=yes
    Log    ✅ AV protection validation: PASSED - Meets CIP-007 R3.1 malware protection requirements    console=yes
