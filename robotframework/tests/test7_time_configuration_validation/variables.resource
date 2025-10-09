*** Settings ***
Documentation    ⏰ Test-7 Variables: Time Configuration Validation
...              📋 Contains all variables specific to time zone and NTP configuration testing

*** Variables ***
# Target Configuration - Set via command line
${TARGET_HOSTNAME}           # Set via command line --variable TARGET_HOSTNAME:value

# 🎯 Test Suite Configuration
${TEST_SUITE_NAME}        Test-7 Time Configuration Validation
${TEST_SUITE_ID}          test7
${TEST_DESCRIPTION}       Validate timezone (Pacific/Los Angeles) and NTP configuration (ntpx.domain.com)

# 📁 Directory Paths
${TEST7_RESULTS_DIR}      results/test7_time_configuration_validation
${TEST7_DATA_DIR}         results/test7_time_configuration_validation/data

# 🏷️ Test Tags
@{CRITICAL_TAGS}          critical    time    ntp    compliance
@{NORMAL_TAGS}           normal      informational
@{TIME_TAGS}             timezone    chrony    ntp    synchronization

# ⏰ Expected Time Configuration
${EXPECTED_TIMEZONE}      America/Los_Angeles
${EXPECTED_TZ_ALT}        Pacific/Los Angeles
${EXPECTED_NTP_SERVER}    ntpx.domain.com
${NTP_SYNC_TOLERANCE_SEC}=    5.0         # Allow 5 second tolerance for time sync

# 🔧 Time Configuration Commands (Linux)
${CMD_TIMEDATECTL}        timedatectl
${CMD_CHRONY_SOURCES}     chronyc sources
${CMD_CHRONY_TRACKING}    chronyc tracking
${CMD_HWCLOCK}            hwclock --show
${CMD_CURRENT_DATE}       date
${CMD_TIMEZONE_FILE}      cat /etc/timezone
${CMD_LOCALTIME_LINK}     ls -l /etc/localtime

# 📊 Validation Requirements
@{REQUIRED_TIME_CHECKS}   timezone    chrony_status    ntp_server    synchronization
${CHRONY_SERVICE_NAME}    chronyd

# 📄 Report File Templates
${TIME_CONFIG_TEMPLATE}=    time_configuration_%s.txt
${CHRONY_REPORT_TEMPLATE}=    chrony_status_%s.txt
${NTP_REPORT_TEMPLATE}=    ntp_synchronization_%s.txt

# 🎨 Console Output Formatting
${LOG_PREFIX_TIME}        ⏰ Time
${LOG_PREFIX_NTP}         🕐 NTP
${LOG_PREFIX_CHRONY}      📡 Chrony
${LOG_PREFIX_VALIDATION}  🔍 Validating
${LOG_PREFIX_PASSED}      ✅ PASSED
${LOG_PREFIX_FAILED}      ❌ FAILED
${LOG_PREFIX_INFO}        ℹ️ INFO