*** Settings ***
Documentation    Variable definitions for Backup Validation Test Suite

*** Variables ***
# Target Configuration - Pulled from command line like test3
${TARGET_HOSTNAME}             # Set via command line --variable TARGET_HOSTNAME:value

# vCenter API Connection Settings
${VCENTER_SERVER}              ${TARGET_HOSTNAME}    # Use same hostname as test3
${VCENTER_API_ENDPOINT}        https://${TARGET_HOSTNAME}/api
${VCENTER_USERNAME}            administrator@vsphere.local
${VCENTER_PASSWORD}            %{VCENTER_PASSWORD=default_password}

# Target VMs for Backup Validation
@{TARGET_VMS}                  production-db-01
...                            production-web-01
...                            production-app-01
...                            file-server-01

# Backup Validation Thresholds
${BACKUP_LOOKBACK_DAYS}        7
${MAX_BACKUP_AGE_HOURS}        26
${MIN_DAILY_RETENTION}         7
${MIN_WEEKLY_RETENTION}        4
${MIN_MONTHLY_RETENTION}       3

# RPO Requirements by VM Criticality (in hours)
&{RPO_REQUIREMENTS}            critical=4
...                            high=12
...                            medium=24
...                            low=48

# VM Criticality Classification
&{VM_CRITICALITY}              production-db-01=critical
...                            production-web-01=high
...                            production-app-01=high
...                            file-server-01=medium

# Offsite Replication Requirements
@{OFFSITE_REQUIRED_VMS}        production-db-01
...                            production-web-01
...                            production-app-01

# API Request Settings
${API_TIMEOUT}                 30
${API_VERIFY_SSL}              ${True}

# Test Result Variables (set during test execution)
${POLICY_DATA}                 ${EMPTY}
${SCHEDULE_DATA}               ${EMPTY}
${JOB_STATUS}                  ${EMPTY}
${RETENTION_DATA}              ${EMPTY}
${TIMESTAMP_DATA}              ${EMPTY}
${REPLICATION_DATA}            ${EMPTY}
