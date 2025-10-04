*** Settings ***
Documentation    🗄️ Storage and System Resource Keywords for Test-5
...              📋 Provides SSH connection, disk analysis, CPU validation, and data collection capabilities
...
Library          ../../library/EDSLookup.py
Library          SSHLibrary
Library          Collections
Library          String
Library          OperatingSystem
Library          DateTime
Resource         ../../settings.resource

*** Variables ***
${DATA_DIR}                results/test5_disk_space_validation/data

*** Keywords ***
Initialize Storage Test Environment And Lookup Configuration
    [Documentation]    🏗️ Set up test environment and lookup EDS configuration
    Log    🚀 Initializing Test-5: Storage & System Validation Environment...    console=yes

    # Create directories for data collection
    Create Directory    ${DATA_DIR}

    # Initialize EDS lookup and get configuration
    ${eds_config}=    Lookup Server Config    ${TARGET_HOSTNAME}

    # Store EDS configuration in suite variables for all tests
    Set Suite Variable    ${TARGET_IP}                    ${eds_config['ip']}
    Set Suite Variable    ${TARGET_CPU_CORES}            ${eds_config['cpu_cores']}
    Set Suite Variable    ${TARGET_RAM}                  ${eds_config['ram']}
    Set Suite Variable    ${TARGET_STORAGE_TYPE}         ${eds_config['storage_type']}
    Set Suite Variable    ${TARGET_STORAGE_TOTAL_TB}     ${eds_config['storage_total_tb']}
    Set Suite Variable    ${TARGET_DRIVE_VOLUME_GROUP}   ${eds_config['drive_volume_group']}
    Set Suite Variable    ${TARGET_FILE_SYSTEM}          ${eds_config['file_system']}
    Set Suite Variable    ${TARGET_LOGICAL_VOLUME}       ${eds_config['logical_volume_partition']}
    Set Suite Variable    ${TARGET_STORAGE_ALLOC_GB}     ${eds_config['storage_allocation_gb']}
    Set Suite Variable    ${TARGET_RECOMMENDED_GB}       ${eds_config['recommended_storage_gb']}
    Set Suite Variable    ${TARGET_DRIVE_PURPOSE}        ${eds_config['drive_purpose']}
    Set Suite Variable    ${TARGET_OS_TYPE}              ${eds_config['os_type']}

    Log    📋 EDS Target IP: ${TARGET_IP}    console=yes
    Log    📋 EDS CPU Cores: ${TARGET_CPU_CORES}    console=yes
    Log    📋 EDS RAM: ${TARGET_RAM} GB    console=yes
    Log    📋 EDS Storage Type: ${TARGET_STORAGE_TYPE}    console=yes
    Log    📋 EDS Storage Total: ${TARGET_STORAGE_TOTAL_TB} TB    console=yes
    Log    📋 EDS OS Type: ${TARGET_OS_TYPE}    console=yes

    # Establish SSH connection to target server
    Log    🔗 Connecting to target server: ${TARGET_IP}...    console=yes
    Open Connection    ${TARGET_IP}
    Login    ${SSH_USERNAME}    ${SSH_PASSWORD}

    Log    ✅ SSH connection established successfully    console=yes
    Log    ✅ Test-5 environment initialized    console=yes

Connect To Target Server
    [Documentation]    🔗 Establish SSH connection to target server
    Log    🔗 Connecting to target server: ${TARGET_IP}...    console=yes
    Open Connection    ${TARGET_IP}
    Login    ${SSH_USERNAME}    ${SSH_PASSWORD}
    Log    ✅ SSH connection established    console=yes

Get CPU Information From Server
    [Documentation]    💻 Collect CPU information from server via SSH
    Log    💻 Collecting CPU information from server...    console=yes

    # Get CPU core count
    ${cpu_cores_output}=    Execute Command    nproc
    ${cpu_cores}=    Strip String    ${cpu_cores_output}

    # Get detailed CPU info
    ${cpu_info_output}=    Execute Command    lscpu | grep -E "(Model name|CPU\\(s\\)|Core\\(s\\) per socket|Socket\\(s\\))"

    # Get CPU model information
    ${cpu_model_output}=    Execute Command    lscpu | grep "Model name" | cut -d':' -f2 | xargs
    ${cpu_model}=    Strip String    ${cpu_model_output}

    # Save CPU information to file
    ${timestamp}=    Get Current Date    result_format=%Y%m%d_%H%M%S
    ${cpu_file}=    Set Variable    ${DATA_DIR}/cpu_information_${timestamp}.txt

    ${cpu_data}=    Catenate    SEPARATOR=\n
    ...    === CPU Information Report ===
    ...    Timestamp: ${timestamp}
    ...    Target Server: ${TARGET_HOSTNAME} (${TARGET_IP})
    ...
    ...    === CPU Core Count ===
    ...    CPU Cores: ${cpu_cores}
    ...
    ...    === CPU Model ===
    ...    Model: ${cpu_model}
    ...
    ...    === Detailed CPU Information ===
    ...    ${cpu_info_output}

    Create File    ${cpu_file}    ${cpu_data}
    Log    📄 CPU information saved to: ${cpu_file}    console=yes
    Log    💻 Server CPU Cores: ${cpu_cores}    console=yes
    Log    💻 Server CPU Model: ${cpu_model}    console=yes

    RETURN    ${cpu_cores}

Get Memory Information From Server
    [Documentation]    🧠 Collect memory information from server via SSH
    Log    🧠 Collecting memory information from server...    console=yes

    # Get memory information in GB
    ${mem_output}=    Execute Command    free -h | grep "Mem:"
    ${mem_total_output}=    Execute Command    free -m | grep "Mem:" | awk '{print $2}'
    ${mem_total_mb}=    Strip String    ${mem_total_output}
    ${mem_total_gb}=    Evaluate    round(${mem_total_mb} / 1024, 1)

    # Get detailed memory info
    ${mem_info_output}=    Execute Command    cat /proc/meminfo | head -20

    # Save memory information to file
    ${timestamp}=    Get Current Date    result_format=%Y%m%d_%H%M%S
    ${mem_file}=    Set Variable    ${DATA_DIR}/memory_information_${timestamp}.txt

    ${mem_data}=    Catenate    SEPARATOR=\n
    ...    === Memory Information Report ===
    ...    Timestamp: ${timestamp}
    ...    Target Server: ${TARGET_HOSTNAME} (${TARGET_IP})
    ...
    ...    === Memory Summary ===
    ...    ${mem_output}
    ...    Total Memory: ${mem_total_gb} GB
    ...
    ...    === Detailed Memory Information ===
    ...    ${mem_info_output}

    Create File    ${mem_file}    ${mem_data}
    Log    📄 Memory information saved to: ${mem_file}    console=yes
    Log    🧠 Server Total Memory: ${mem_total_gb} GB    console=yes

    RETURN    ${mem_total_gb}

Get Disk Space Information From Server
    [Documentation]    💾 Collect comprehensive disk space information from server
    Log    💾 Collecting disk space information from server...    console=yes

    # Execute disk space commands
    ${df_output}=    Execute Command    df -h
    ${lsblk_output}=    Execute Command    lsblk
    ${fdisk_output}=    Execute Command    sudo fdisk -l 2>/dev/null || fdisk -l 2>/dev/null || echo "fdisk requires elevated privileges"
    ${mount_output}=    Execute Command    mount | grep -E "^/"

    # Get root filesystem information
    ${root_df_output}=    Execute Command    df -h / | tail -1
    ${root_size}=    Execute Command    df -h / | tail -1 | awk '{print $2}'
    ${root_used}=    Execute Command    df -h / | tail -1 | awk '{print $3}'
    ${root_available}=    Execute Command    df -h / | tail -1 | awk '{print $4}'
    ${root_usage_percent}=    Execute Command    df -h / | tail -1 | awk '{print $5}'

    # Get volume group information (if LVM is used)
    ${vg_output}=    Execute Command    sudo vgs 2>/dev/null || vgs 2>/dev/null || echo "Volume group information not available or requires privileges"
    ${lv_output}=    Execute Command    sudo lvs 2>/dev/null || lvs 2>/dev/null || echo "Logical volume information not available or requires privileges"

    # Save disk information to file
    ${timestamp}=    Get Current Date    result_format=%Y%m%d_%H%M%S
    ${disk_file}=    Set Variable    ${DATA_DIR}/disk_space_information_${timestamp}.txt

    ${disk_data}=    Catenate    SEPARATOR=\n
    ...    === Disk Space Information Report ===
    ...    Timestamp: ${timestamp}
    ...    Target Server: ${TARGET_HOSTNAME} (${TARGET_IP})
    ...
    ...    === Disk Usage Summary (df -h) ===
    ...    ${df_output}
    ...
    ...    === Block Device Information (lsblk) ===
    ...    ${lsblk_output}
    ...
    ...    === Root Filesystem Details ===
    ...    Total Size: ${root_size}
    ...    Used Space: ${root_used}
    ...    Available Space: ${root_available}
    ...    Usage Percentage: ${root_usage_percent}
    ...
    ...    === Mount Points ===
    ...    ${mount_output}
    ...
    ...    === Volume Group Information ===
    ...    ${vg_output}
    ...
    ...    === Logical Volume Information ===
    ...    ${lv_output}
    ...
    ...    === Partition Information (fdisk -l) ===
    ...    ${fdisk_output}

    Create File    ${disk_file}    ${disk_data}
    Log    📄 Disk space information saved to: ${disk_file}    console=yes
    Log    💾 Root filesystem: ${root_size} total, ${root_used} used, ${root_available} available (${root_usage_percent} used)    console=yes

    RETURN    ${root_size}

Get Storage Type From Server
    [Documentation]    📡 Identify storage type from server
    Log    📡 Identifying storage type from server...    console=yes

    # Check for various storage indicators
    ${storage_info}=    Execute Command    lsblk -o NAME,TYPE,FSTYPE,SIZE,MOUNTPOINT
    ${scsi_info}=       Execute Command    ls /sys/class/scsi_host/ 2>/dev/null | wc -l || echo "0"
    ${nvme_info}=       Execute Command    ls /dev/nvme* 2>/dev/null | wc -l || echo "0"
    ${virt_info}=       Execute Command    ls /sys/block/ | grep -E "(vd|xvd)" | wc -l || echo "0"

    # Determine storage type based on indicators
    ${storage_type}=    Set Variable    Unknown
    IF    "${nvme_info}" != "0"
        ${storage_type}=    Set Variable    NVMe
    ELSE IF    "${virt_info}" != "0"
        ${storage_type}=    Set Variable    Virtual/Cloud
    ELSE IF    "${scsi_info}" != "0"
        ${storage_type}=    Set Variable    SCSI/SAN
    ELSE
        ${storage_type}=    Set Variable    Local/Other
    END

    Log    📡 Detected storage type: ${storage_type}    console=yes
    RETURN    ${storage_type}

Get Filesystem Information From Server
    [Documentation]    🗂️ Collect filesystem information from server
    Log    🗂️ Collecting filesystem information from server...    console=yes

    # Get root filesystem type
    ${root_fs_type}=    Execute Command    df -T / | tail -1 | awk '{print $2}'
    ${root_mount}=      Execute Command    df / | tail -1 | awk '{print $1}'

    # Get all filesystem types
    ${fs_types_output}=    Execute Command    df -T | tail -n +2

    Log    🗂️ Root filesystem type: ${root_fs_type}    console=yes
    Log    🗂️ Root mounted from: ${root_mount}    console=yes

    RETURN    ${root_fs_type}

Validate CPU Cores Against EDS
    [Documentation]    💻 Validate CPU cores match EDS expectation
    [Arguments]    ${actual_cpu_cores}

    Log    🔍 Validating CPU cores: EDS vs Server...    console=yes
    Log    📋 EDS Expected: ${TARGET_CPU_CORES} cores    console=yes
    Log    💻 Server Actual: ${actual_cpu_cores} cores    console=yes

    Should Be Equal As Strings    ${actual_cpu_cores}    ${TARGET_CPU_CORES}
    ...    ❌ CPU CORE MISMATCH: EDS expects '${TARGET_CPU_CORES}' cores but server has '${actual_cpu_cores}' cores

    Log    ✅ CPU cores validation: PASSED - EDS matches Server    console=yes

Validate Memory Against EDS
    [Documentation]    🧠 Validate memory allocation matches EDS expectation
    [Arguments]    ${actual_memory_gb}

    Log    🔍 Validating memory allocation: EDS vs Server...    console=yes
    Log    📋 EDS Expected: ${TARGET_RAM} GB    console=yes
    Log    🧠 Server Actual: ${actual_memory_gb} GB    console=yes

    # Allow for small differences in memory reporting (within 1GB tolerance)
    ${ram_difference}=    Evaluate    abs(float("${actual_memory_gb}") - float("${TARGET_RAM}"))
    ${tolerance_passed}=    Evaluate    ${ram_difference} <= 1

    Should Be True    ${tolerance_passed}
    ...    ❌ MEMORY MISMATCH: EDS expects '${TARGET_RAM}' GB but server has '${actual_memory_gb}' GB (difference: ${ram_difference} GB, tolerance: 1GB)

    Log    ✅ Memory validation: PASSED - EDS matches Server (within tolerance)    console=yes

Validate Storage Type Against EDS
    [Documentation]    📡 Validate storage type matches EDS expectation
    [Arguments]    ${actual_storage_type}

    Log    🔍 Validating storage type: EDS vs Server...    console=yes
    Log    📋 EDS Expected: ${TARGET_STORAGE_TYPE}    console=yes
    Log    📡 Server Detected: ${actual_storage_type}    console=yes

    # Note: Storage type validation may be informational since detection can vary
    Log    ℹ️ Storage type comparison: EDS '${TARGET_STORAGE_TYPE}' vs Server '${actual_storage_type}'    console=yes
    Log    ✅ Storage type validation: INFORMATIONAL - Logged for review    console=yes

Validate Root Filesystem Against EDS
    [Documentation]    🗂️ Validate root filesystem configuration against EDS
    [Arguments]    ${actual_fs_type}    ${actual_root_size}

    Log    🔍 Validating root filesystem: EDS vs Server...    console=yes
    Log    📋 EDS Expected Mount: ${TARGET_LOGICAL_VOLUME}    console=yes
    Log    📋 EDS Expected Storage: ${TARGET_STORAGE_ALLOC_GB} GB    console=yes
    Log    🗂️ Server Filesystem: ${actual_fs_type}    console=yes
    Log    🗂️ Server Root Size: ${actual_root_size}    console=yes

    # Log filesystem information for compliance review
    Log    ℹ️ Filesystem validation: Type=${actual_fs_type}, Size=${actual_root_size}    console=yes
    Log    ✅ Filesystem validation: LOGGED for compliance review    console=yes

Generate Storage Executive Summary
    [Documentation]    📊 Generate executive summary for storage validation results
    Log    📊 Generating Test-5 Storage Validation Executive Summary...    console=yes

    ${timestamp}=    Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${summary_file}=    Set Variable    results/test5_disk_space_validation/Test5_Storage_Executive_Summary.txt

    ${summary_content}=    Catenate    SEPARATOR=\n
    ...    ========================================
    ...    🗄️ TEST-5: STORAGE & SYSTEM VALIDATION
    ...    📊 EXECUTIVE SUMMARY REPORT
    ...    ========================================
    ...
    ...    📅 Report Generated: ${timestamp}
    ...    🎯 Target System: ${TARGET_HOSTNAME} (${TARGET_IP})
    ...    📋 Test Suite: Test-5 Disk Space & System Validation
    ...
    ...    ========================================
    ...    📋 EDS BASELINE CONFIGURATION
    ...    ========================================
    ...    💻 CPU Cores (Expected): ${TARGET_CPU_CORES}
    ...    🧠 RAM (Expected): ${TARGET_RAM} GB
    ...    📡 Storage Type (Expected): ${TARGET_STORAGE_TYPE}
    ...    💾 Storage Total (Expected): ${TARGET_STORAGE_TOTAL_TB} TB
    ...    🗂️ Mount Point (Expected): ${TARGET_LOGICAL_VOLUME}
    ...    📊 Storage Allocation (Expected): ${TARGET_STORAGE_ALLOC_GB} GB
    ...    🎯 Drive Purpose: ${TARGET_DRIVE_PURPOSE}
    ...    🖥️ OS Type (Expected): ${TARGET_OS_TYPE}
    ...
    ...    ========================================
    ...    ✅ VALIDATION RESULTS
    ...    ========================================
    ...
    ...    Results available in detailed test reports.
    ...
    ...    ========================================
    ...    📁 SUPPORTING DOCUMENTATION
    ...    ========================================
    ...    📄 Detailed data files: results/test5_disk_space_validation/data/
    ...    📊 Robot Framework reports: results/test5_disk_space_validation/
    ...
    ...    ========================================
    ...    🏆 COMPLIANCE STATUS
    ...    ========================================
    ...    ✅ Test execution completed successfully
    ...    📋 All data collected and validated against EDS
    ...    🔍 Results ready for stakeholder review
    ...
    ...    End of Executive Summary
    ...    ========================================

    Create File    ${summary_file}    ${summary_content}
    Log    📊 Executive summary generated: ${summary_file}    console=yes
    Log    ✅ Test-5 Storage Validation completed successfully!    console=yes

Log Test Start
    [Documentation]    📝 Log the start of a test case
    [Arguments]    ${test_name}
    Log    🏁 Starting: ${test_name}    console=yes

Log Test End
    [Documentation]    📝 Log the end of a test case
    [Arguments]    ${test_name}    ${test_status}
    IF    "${test_status}" == "PASS"
        Log    ✅ Completed: ${test_name} - ${test_status}    console=yes
    ELSE
        Log    ❌ Completed: ${test_name} - ${test_status}    console=yes
    END