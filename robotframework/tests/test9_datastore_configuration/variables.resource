*** Settings ***
Documentation    Variable definitions for Datastore Configuration Test Suite

*** Variables ***
# Target Configuration - Pulled from command line like test3
${TARGET_HOSTNAME}             # Set via command line --variable TARGET_HOSTNAME:value

# vCenter Connection Settings
${VCENTER_SERVER}              vcenter.example.com
${VCENTER_USERNAME}            administrator@vsphere.local
${VCENTER_PASSWORD}            %{VCENTER_PASSWORD=default_password}
${VCENTER_HOST}                ${TARGET_HOSTNAME}    # Use same hostname as test3
${CLUSTER_NAME}                Production-Cluster

# Datastore Validation Thresholds
${MIN_FREE_CAPACITY_PERCENT}   20
${MAX_SUBSCRIPTION_RATIO}      2.0

# Screenshot Settings
${SCREENSHOT_DIR}              ${EXECDIR}/test_results/screenshots
${SCREENSHOT_FORMAT}           png

# Performance Tier Definitions
@{HIGH_PERFORMANCE_TIERS}      SSD    NVMe    All-Flash
@{STANDARD_PERFORMANCE_TIERS}  SAS    SATA
@{ARCHIVE_TIERS}               SATA-Archive    NL-SAS

# VM Application Categories (for performance tier validation)
&{VM_APP_CATEGORIES}           database=HIGH_PERFORMANCE
...                            web=STANDARD_PERFORMANCE
...                            file=STANDARD_PERFORMANCE
...                            archive=ARCHIVE
...                            backup=ARCHIVE

# Test Result Variables (set during test execution)
${VM_ASSIGNMENTS}              ${EMPTY}
${CAPACITY_DATA}               ${EMPTY}
${PERFORMANCE_TIERS}           ${EMPTY}
${SUBSCRIPTION_DATA}           ${EMPTY}
${SCREENSHOT_PATH}             ${EMPTY}
