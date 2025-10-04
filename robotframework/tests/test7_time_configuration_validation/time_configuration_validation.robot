*** Settings ***
Documentation    ⏰ Time Configuration Validation Test Suite - Test-7
...              🔍 Process: Find hostname in EDS → SSH to server → Collect time/NTP data → Validate timezone and NTP configuration
...              ✅ Pass if timezone is Pacific/Los Angeles and NTP server is ntpx.domain.com with proper synchronization
...              📊 Validates: Timezone setting, Chrony service status, NTP server configuration, time synchronization
...
Resource         ../../settings.resource
Resource         time_keywords.resource
Resource         variables.resource

Suite Setup      Initialize Time Test Environment
Suite Teardown   Generate Time Configuration Executive Summary

Test Setup       Log Test Start    ${TEST_NAME}
Test Teardown    Log Test End      ${TEST_NAME}    ${TEST_STATUS}

*** Test Cases ***
Critical - Connect to Target Server
    [Documentation]    🔗 Establish direct connection to target machine via SSH
    [Tags]             critical    connection    ssh    infrastructure

    Log    🔍 Verifying SSH connection to target server...    console=yes
    Log    📋 Target: ${TARGET_HOSTNAME} (${TARGET_IP})    console=yes

    # Connection already established in Suite Setup
    ${connection_status}=    Execute Command    echo "Connection active"
    Should Contain    ${connection_status}    Connection active

    Log    ✅ SSH connection verified and active    console=yes

Critical - Collect Time Configuration Data
    [Documentation]    ⏰ Execute time-related commands to gather timezone, chrony, and NTP configuration
    [Tags]             critical    time    data_collection    ntp

    Log    🔍 Collecting time configuration data from server...    console=yes

    # Execute time configuration collection
    Collect Time Configuration Data

    # Verify data was collected
    Should Not Be Empty    ${TIMEDATECTL_OUTPUT}
    Should Not Be Empty    ${CHRONY_SOURCES_OUTPUT}
    Should Not Be Empty    ${CHRONY_TRACKING_OUTPUT}

    Log    📋 Timedatectl output collected: ${TIMEDATECTL_OUTPUT[:100]}...    console=yes
    Log    📋 Chrony sources collected: ${CHRONY_SOURCES_OUTPUT[:100]}...    console=yes
    Log    ✅ Time configuration data collected successfully    console=yes

Critical - Validate Timezone Setting
    [Documentation]    🌎 Validate timezone is set to Pacific/Los Angeles (America/Los_Angeles)
    [Tags]             critical    timezone    compliance

    Log    🔍 Validating timezone configuration...    console=yes
    Log    📋 Expected Timezone: Pacific/Los Angeles (America/Los_Angeles)    console=yes

    # Validate timezone matches Pacific/Los Angeles
    ${timezone_result}=    Validate Timezone Configuration

    Log    ⏰ Timezone validation result: ${timezone_result}    console=yes
    Log    ✅ Timezone validation: PASSED - Timezone correctly set to Pacific/Los Angeles    console=yes

Critical - Validate Chrony Service Status
    [Documentation]    📡 Validate chrony service is active and running
    [Tags]             critical    chrony    service    ntp

    Log    🔍 Validating chrony service status...    console=yes
    Log    📋 Expected: Chrony service active and running    console=yes

    # Validate chrony service is running
    Validate Chrony Service Status

    Log    ✅ Chrony service validation: PASSED - Service is active    console=yes

Critical - Validate NTP Server Configuration
    [Documentation]    🕐 Validate NTP server is configured to use ntpx.domain.com
    [Tags]             critical    ntp    server    configuration

    Log    🔍 Validating NTP server configuration...    console=yes
    Log    📋 Expected NTP Server: ntpx.domain.com    console=yes

    # Validate NTP server configuration
    ${ntp_servers}=    Validate NTP Server Configuration

    Log    🕐 Configured NTP servers: ${ntp_servers}    console=yes
    Log    ✅ NTP server configuration validated    console=yes

Critical - Validate Time Synchronization Status
    [Documentation]    🔄 Validate time synchronization is working and clock is synchronized
    [Tags]             critical    synchronization    ntp    time

    Log    🔍 Validating time synchronization status...    console=yes
    Log    📋 Expected: System clock synchronized with NTP server    console=yes

    # Validate time synchronization
    ${sync_status}=    Validate Time Synchronization Status

    Log    🔄 Synchronization status: ${sync_status}    console=yes
    Log    ✅ Time synchronization validation completed    console=yes

Normal - Comprehensive Time Configuration Validation
    [Documentation]    📊 Perform comprehensive validation of all time configuration settings
    [Tags]             normal    comprehensive    validation    compliance

    Log    🔍 Performing comprehensive time configuration validation...    console=yes

    # Validate all time settings
    Validate All Time Settings

    Log    📊 Comprehensive validation summary:    console=yes
    Log    📊 - Timezone: Pacific/Los Angeles ✅    console=yes
    Log    📊 - Chrony Service: Active ✅    console=yes
    Log    📊 - NTP Server: Configured ✅    console=yes
    Log    📊 - Synchronization: Verified ✅    console=yes
    Log    ✅ Comprehensive time configuration validation: PASSED    console=yes

Normal - Hardware Clock Verification
    [Documentation]    🕰️ Verify hardware clock and its synchronization with system clock
    [Tags]             normal    hardware    clock    verification

    Log    🔍 Verifying hardware clock configuration...    console=yes

    # Check hardware clock
    ${hwclock_output}=    Execute Command    hwclock --show 2>/dev/null || echo "hwclock requires privileges"
    ${current_date}=      Execute Command    date

    Log    🕰️ Hardware Clock: ${hwclock_output}    console=yes
    Log    📅 System Date: ${current_date}    console=yes

    # Log hardware clock information
    Log    ℹ️ Hardware clock information collected for review    console=yes
    Log    ✅ Hardware clock verification: INFORMATIONAL    console=yes

Normal - NTP Source Analysis
    [Documentation]    📊 Analyze NTP source details and server reachability
    [Tags]             normal    analysis    ntp    sources

    Log    🔍 Analyzing NTP source details...    console=yes

    # Get detailed NTP source information
    ${sources_verbose}=    Execute Command    chronyc sources -v
    ${sourcestats}=        Execute Command    chronyc sourcestats

    Log    📊 NTP Sources (Verbose): ${sources_verbose}    console=yes
    Log    📊 NTP Source Statistics: ${sourcestats}    console=yes

    # Save NTP analysis
    ${timestamp}=    Get Current Date    result_format=%Y%m%d_%H%M%S
    ${ntp_analysis_file}=    Set Variable    ${DATA_DIR}/ntp_source_analysis_${timestamp}.txt

    ${ntp_analysis_data}=    Catenate    SEPARATOR=\n
    ...    === NTP Source Analysis ===
    ...    Timestamp: ${timestamp}
    ...    Target Server: ${TARGET_HOSTNAME} (${TARGET_IP})
    ...
    ...    === Chrony Sources (Verbose) ===
    ...    ${sources_verbose}
    ...
    ...    === Chrony Source Statistics ===
    ...    ${sourcestats}

    Create File    ${ntp_analysis_file}    ${ntp_analysis_data}
    Log    📄 NTP source analysis saved to: ${ntp_analysis_file}    console=yes
    Log    ✅ NTP source analysis: INFORMATIONAL - Available for review    console=yes

Normal - Clock Drift Monitoring
    [Documentation]    📉 Monitor clock drift and synchronization accuracy
    [Tags]             normal    monitoring    drift    accuracy

    Log    🔍 Monitoring clock drift and accuracy...    console=yes

    # Get tracking information for drift analysis
    ${tracking_output}=    Execute Command    chronyc tracking

    Log    📉 Chrony Tracking Info: ${tracking_output}    console=yes

    # Extract key metrics if available
    ${system_time_line}=    Execute Command    chronyc tracking | grep "System time" || echo "N/A"
    ${last_offset_line}=    Execute Command    chronyc tracking | grep "Last offset" || echo "N/A"
    ${rms_offset_line}=     Execute Command    chronyc tracking | grep "RMS offset" || echo "N/A"

    Log    📊 System Time Offset: ${system_time_line}    console=yes
    Log    📊 Last Offset: ${last_offset_line}    console=yes
    Log    📊 RMS Offset: ${rms_offset_line}    console=yes

    Log    ℹ️ Clock drift monitoring: Data collected for analysis    console=yes
    Log    ✅ Clock drift monitoring: INFORMATIONAL    console=yes