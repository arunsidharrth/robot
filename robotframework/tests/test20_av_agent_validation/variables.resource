*** Settings ***
Documentation    🛡️ Test-20 Variables: AV Agent Validation Configuration
...              📋 Contains all variables specific to antivirus agent testing and CIP-007 R3.1 compliance

*** Variables ***
# Target Configuration - Set via command line
${TARGET_HOSTNAME}           # Set via command line --variable TARGET_HOSTNAME:value

# 🎯 Test Suite Configuration
${TEST_SUITE_NAME}        Test-20 AV Agent Validation
${TEST_SUITE_ID}          test20
${TEST_DESCRIPTION}       Validate AV agent installation and configuration against CIP-007 R3.1 malware protection requirements

# 📁 Directory Paths
${TEST20_RESULTS_DIR}     results/test20_av_agent_validation
${TEST20_DATA_DIR}        results/test20_av_agent_validation/data

# 🏷️ Test Tags
@{CRITICAL_TAGS}          critical    av_agent    cip007_r31    compliance
@{NORMAL_TAGS}           normal      informational
@{AV_TAGS}               antivirus   mcafee   sentinelone   malware

# 🛡️ AV Configuration
${AV_TYPE}                Sentinel    # Options: Sentinel, McAfee
${AV_SERVICE_NAME}        sentinelone  # Service name to check
${MCAFEE_SERVICE_NAME}    McAfee

# 🔧 AV Agent Commands (Windows)
${CMD_SENTINEL_STATUS}    sc query sentinelone
${CMD_MCAFEE_STATUS}      sc query McAfee
${CMD_AV_VERSION}         wmic product where "name like '%Sentinel%' or name like '%McAfee%'" get name,version
${CMD_PROTECTION_STATUS}  Get-MpComputerStatus
${CMD_SIGNATURE_UPDATE}   Get-MpComputerStatus | Select-Object -ExpandProperty AntivirusSignatureLastUpdated
${CMD_SCAN_SCHEDULE}      Get-ScheduledTask | Where-Object {$_.TaskName -like "*antivirus*" -or $_.TaskName -like "*scan*"}
${CMD_EXCLUSIONS}         Get-MpPreference | Select-Object -ExpandProperty ExclusionPath

# 🔧 AV Agent Commands (Linux)
${CMD_SENTINEL_LINUX}     systemctl status sentinelone
${CMD_MCAFEE_LINUX}       /opt/McAfee/cma/bin/cmdagent -c
${CMD_LINUX_AV_STATUS}    ps aux | grep -E "sentinel|mcafee"

# 📊 CIP-007 R3.1 Compliance Requirements
${MAX_SIGNATURE_AGE_DAYS}     7       # Maximum days since last signature update
${REQUIRE_REAL_TIME_PROTECTION}    True    # Real-time protection must be enabled
${REQUIRE_SCHEDULED_SCANS}    True    # Scheduled scans must be configured
${MIN_SCAN_FREQUENCY_DAYS}    7       # Minimum scan frequency in days

# 🎨 Console Output Formatting
${LOG_PREFIX_AV}          🛡️ AV
${LOG_PREFIX_AGENT}       📦 Agent
${LOG_PREFIX_SIGNATURE}   🔄 Signature
${LOG_PREFIX_SCAN}        🔍 Scan
${LOG_PREFIX_VALIDATION}  ✅ Validating
${LOG_PREFIX_PASSED}      ✅ PASSED
${LOG_PREFIX_FAILED}      ❌ FAILED
${LOG_PREFIX_INFO}        ℹ️ INFO

# 📄 Report File Templates
${AV_STATUS_TEMPLATE}=       av_agent_status_%s.txt
${SIGNATURE_TEMPLATE}=       signature_update_%s.txt
${SCAN_SCHEDULE_TEMPLATE}=   scan_schedule_%s.txt
${EXCLUSION_TEMPLATE}=       exclusion_config_%s.txt

# 📊 AV Metrics Collection
@{AV_METRICS}             agent_status    signature_date    scan_schedule    exclusions    real_time_protection
@{REQUIRED_CHECKS}        installation    real_time_protection    signature_currency    scheduled_scans

# 🗂️ Expected AV Components
@{SENTINEL_COMPONENTS}    SentinelAgent    SentinelStaticEngine    SentinelHelperService
@{MCAFEE_COMPONENTS}      McAfeeFramework    McAfeeAgent    McAfeeScanner

# 💾 Data Storage Variables (populated at runtime)
${AGENT_STATUS}           ${EMPTY}
${RTP_SETTINGS}           ${EMPTY}
${SIGNATURE_INFO}         ${EMPTY}
${SCAN_SCHEDULE}          ${EMPTY}
${EXCLUSIONS}             ${EMPTY}
${SCREENSHOT_PATH}        ${EMPTY}
${OUTPUT_FILE}            ${EMPTY}
