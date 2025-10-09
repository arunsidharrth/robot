*** Settings ***
Documentation    🗄️ Test-5 Variables: Storage & System Validation Configuration
...              📋 Contains all variables specific to storage and system resource testing

*** Variables ***
# Target Configuration - Set via command line
${TARGET_HOSTNAME}           # Set via command line --variable TARGET_HOSTNAME:value

# 🎯 Test Suite Configuration
${TEST_SUITE_NAME}        Test-5 Storage & System Validation
${TEST_SUITE_ID}          test5
${TEST_DESCRIPTION}       Validate disk space allocation, CPU, memory, and storage configuration against EDS requirements

# 📁 Directory Paths
${TEST5_RESULTS_DIR}      results/test5_disk_space_validation
${TEST5_DATA_DIR}         results/test5_disk_space_validation/data

# 🏷️ Test Tags
@{CRITICAL_TAGS}          critical    storage    system    compliance
@{NORMAL_TAGS}           normal      informational
@{STORAGE_TAGS}          storage     disk       filesystem
@{SYSTEM_TAGS}           cpu         memory     hardware

# 📊 Storage Validation Thresholds
${MEMORY_TOLERANCE_GB}    1.0         # Allow 1GB tolerance for memory validation
${DISK_USAGE_WARNING}     80          # Warn if disk usage exceeds 80%
${DISK_USAGE_CRITICAL}    90          # Critical if disk usage exceeds 90%

# 🔧 Storage Commands (Linux)
${CMD_DISK_USAGE}         df -h
${CMD_BLOCK_DEVICES}      lsblk
${CMD_PARTITION_INFO}     fdisk -l
${CMD_MOUNT_POINTS}       mount | grep -E "^/"
${CMD_CPU_COUNT}          nproc
${CMD_CPU_INFO}           lscpu
${CMD_MEMORY_INFO}        free -h
${CMD_MEMORY_DETAILED}    cat /proc/meminfo
${CMD_VOLUME_GROUPS}      vgs
${CMD_LOGICAL_VOLUMES}    lvs

# 📋 EDS Field Mappings (populated at runtime from EDS lookup)
${TARGET_CPU_CORES}       ${EMPTY}    # Will be set from EDS
${TARGET_RAM}             ${EMPTY}    # Will be set from EDS
${TARGET_STORAGE_TYPE}    ${EMPTY}    # Will be set from EDS
${TARGET_STORAGE_TOTAL_TB}           ${EMPTY}    # Will be set from EDS
${TARGET_DRIVE_VOLUME_GROUP}         ${EMPTY}    # Will be set from EDS
${TARGET_FILE_SYSTEM}     ${EMPTY}    # Will be set from EDS
${TARGET_LOGICAL_VOLUME}  ${EMPTY}    # Will be set from EDS
${TARGET_STORAGE_ALLOC_GB}           ${EMPTY}    # Will be set from EDS
${TARGET_RECOMMENDED_GB}  ${EMPTY}    # Will be set from EDS
${TARGET_DRIVE_PURPOSE}   ${EMPTY}    # Will be set from EDS
${TARGET_OS_TYPE}         ${EMPTY}    # Will be set from EDS

# 📄 Report File Templates
${CPU_REPORT_TEMPLATE}=    cpu_information_%s.txt
${MEMORY_REPORT_TEMPLATE}=    memory_information_%s.txt
${DISK_REPORT_TEMPLATE}=    disk_space_information_%s.txt
${STORAGE_REPORT_TEMPLATE}=    storage_validation_%s.txt

# 🎨 Console Output Formatting
${LOG_PREFIX_EDS}         📋 EDS
${LOG_PREFIX_SERVER}      🖥️ Server
${LOG_PREFIX_VALIDATION}  🔍 Validating
${LOG_PREFIX_PASSED}      ✅ PASSED
${LOG_PREFIX_FAILED}      ❌ FAILED
${LOG_PREFIX_INFO}        ℹ️ INFO

# 💾 Storage Categories (for separate disk validation)
@{STORAGE_CATEGORIES}     root    application    cyber_tools    data
${ROOT_MOUNT_POINT}       /
${APP_MOUNT_POINT}        /opt
${CYBER_MOUNT_POINT}      /var
${DATA_MOUNT_POINT}       /home

# 🗂️ Filesystem Types to Validate
@{EXPECTED_FS_TYPES}      ext4    xfs    btrfs
@{VIRTUAL_FS_TYPES}       tmpfs   devtmpfs    sysfs    proc

# 📊 Storage Metrics Collection
@{DISK_METRICS}           total_size    used_space    available_space    usage_percent
@{CPU_METRICS}            core_count    model_name    architecture      max_frequency
@{MEMORY_METRICS}         total_memory  available_memory    buffers_cache    swap_total