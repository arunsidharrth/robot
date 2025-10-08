*** Settings ***
Documentation    Variables for AV Agent Validation Test Suite

*** Variables ***
# Test identification
${TEST_SUITE_ID}              20
${TEST_SUITE_NAME}            AV Agent Validation
${TEST_SUITE_DESCRIPTION}     Validates antivirus agent installation and compliance with CIP-007 R3.1

# Target system variables (passed from run script)
${TARGET_HOSTNAME}            localhost
${SSH_USERNAME}               test
${SSH_PASSWORD}               test

# AV detection variables
${AV_TYPE}                    ${EMPTY}
${OS_TYPE}                    ${EMPTY}

# AV status variables
${INSTALL_STATUS}             ${False}
${SERVICE_STATUS}             ${False}
${RTP_ENABLED}                ${False}

# AV information variables
${AGENT_INFO}                 ${EMPTY}
${SIGNATURE_INFO}             ${EMPTY}
${SIGNATURE_AGE}              0
${SCAN_CONFIG}                ${EMPTY}
${EXCLUSIONS}                 ${EMPTY}
${CONSOLE_STATUS}             ${EMPTY}

# Screenshot paths
${SCREENSHOT_PATHS}           ${EMPTY}

# CIP-007 R3.1 requirements
${MAX_SIGNATURE_AGE_DAYS}     7
${REQUIRE_REAL_TIME_PROTECTION}    ${True}
${REQUIRE_CONSOLE_REPORTING}       ${True}

# Supported AV types
@{SUPPORTED_AV_TYPES}         McAfee    SentinelOne

# Output directory
${OUTPUT_DIR}                 ${CURDIR}/../../results/test20_av_agent_validation
