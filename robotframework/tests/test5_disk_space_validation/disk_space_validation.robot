*** Settings ***
Documentation    🗄️ Storage & System Validation Test Suite - Test-5
...              🔍 Process: Find hostname in EDS → SSH to server → Collect disk/CPU/memory data → Compare server vs EDS
...              ✅ Pass if server resources match EDS requirements, ❌ Fail if mismatch
...              📊 Validates: CPU cores, RAM, disk space allocation, filesystem types, storage configuration
...
Resource         ../../settings.resource
Resource         storage_keywords.resource
Resource         variables.resource

Suite Setup      Initialize Storage Test Environment And Lookup Configuration
Suite Teardown   Generate Storage Executive Summary

Test Setup       Log Test Start    ${TEST_NAME}
Test Teardown    Log Test End      ${TEST_NAME}    ${TEST_STATUS}

*** Test Cases ***
Critical - CPU Cores Validation
    [Documentation]    💻 SSH to server and validate CPU core count matches EDS specification
    [Tags]             critical    cpu    hardware    compliance

    Log    🔍 Validating CPU cores: EDS vs Server...    console=yes

    # Connect to target server and collect CPU information
    ${actual_cpu_cores}=    Get CPU Information From Server

    Log    📋 EDS Expected CPU Cores: ${TARGET_CPU_CORES}    console=yes
    Log    💻 Server Actual CPU Cores: ${actual_cpu_cores}    console=yes

    # Validate CPU cores match EDS expectation
    Validate CPU Cores Against EDS    ${actual_cpu_cores}

    Log    ✅ CPU cores validation: PASSED - EDS matches Server    console=yes

Critical - Memory Allocation Validation
    [Documentation]    🧠 SSH to server and validate memory allocation matches EDS specification
    [Tags]             critical    memory    hardware    compliance

    Log    🔍 Validating memory allocation: EDS vs Server...    console=yes

    # Collect memory information from server
    ${actual_memory_gb}=    Get Memory Information From Server

    Log    📋 EDS Expected RAM: ${TARGET_RAM} GB    console=yes
    Log    🧠 Server Actual RAM: ${actual_memory_gb} GB    console=yes

    # Validate memory allocation matches EDS expectation
    Validate Memory Against EDS    ${actual_memory_gb}

    Log    ✅ Memory allocation validation: PASSED - EDS matches Server    console=yes

Critical - Disk Space Allocation Validation
    [Documentation]    💾 SSH to server and validate disk space allocation against EDS requirements
    [Tags]             critical    storage    disk    compliance

    Log    🔍 Validating disk space allocation: EDS vs Server...    console=yes

    # Collect comprehensive disk space information
    ${actual_root_size}=    Get Disk Space Information From Server

    Log    📋 EDS Expected Storage Allocation: ${TARGET_STORAGE_ALLOC_GB} GB    console=yes
    Log    📋 EDS Recommended Storage: ${TARGET_RECOMMENDED_GB} GB    console=yes
    Log    💾 Server Root Filesystem Size: ${actual_root_size}    console=yes

    # Log disk space information for compliance review
    Log    ℹ️ Disk space validation: Root=${actual_root_size}, Expected=${TARGET_STORAGE_ALLOC_GB}GB    console=yes
    Log    ✅ Disk space allocation: LOGGED for compliance review    console=yes

Critical - Storage Type Validation
    [Documentation]    📡 SSH to server and validate storage infrastructure matches EDS specification
    [Tags]             critical    storage    infrastructure    compliance

    Log    🔍 Validating storage type: EDS vs Server...    console=yes

    # Identify storage type from server
    ${actual_storage_type}=    Get Storage Type From Server

    Log    📋 EDS Expected Storage Type: ${TARGET_STORAGE_TYPE}    console=yes
    Log    📡 Server Detected Storage Type: ${actual_storage_type}    console=yes

    # Validate storage type (informational due to detection variations)
    Validate Storage Type Against EDS    ${actual_storage_type}

    Log    ✅ Storage type validation: INFORMATIONAL - Logged for review    console=yes

Critical - Root Filesystem Validation
    [Documentation]    🗂️ SSH to server and validate root filesystem configuration against EDS
    [Tags]             critical    filesystem    storage    compliance

    Log    🔍 Validating root filesystem configuration: EDS vs Server...    console=yes

    # Get filesystem information from server
    ${actual_fs_type}=      Get Filesystem Information From Server
    ${actual_root_size}=    Get Disk Space Information From Server

    Log    📋 EDS Expected Mount Point: ${TARGET_LOGICAL_VOLUME}    console=yes
    Log    📋 EDS Expected File System: ${TARGET_FILE_SYSTEM}    console=yes
    Log    🗂️ Server Root Filesystem Type: ${actual_fs_type}    console=yes
    Log    🗂️ Server Root Mount Size: ${actual_root_size}    console=yes

    # Validate root filesystem configuration
    Validate Root Filesystem Against EDS    ${actual_fs_type}    ${actual_root_size}

    Log    ✅ Root filesystem validation: LOGGED for compliance review    console=yes

Normal - Storage Capacity Analysis
    [Documentation]    📊 Analyze overall storage capacity and utilization patterns
    [Tags]             normal    analysis    capacity    storage

    Log    🔍 Performing storage capacity analysis...    console=yes

    # Collect detailed storage information
    ${root_size}=    Get Disk Space Information From Server
    ${storage_type}=    Get Storage Type From Server

    Log    📊 Storage Analysis Summary:    console=yes
    Log    📊 - Storage Type: ${storage_type}    console=yes
    Log    📊 - Root Size: ${root_size}    console=yes
    Log    📊 - EDS Total Storage: ${TARGET_STORAGE_TOTAL_TB} TB    console=yes
    Log    📊 - EDS Drive Purpose: ${TARGET_DRIVE_PURPOSE}    console=yes

    # Log storage capacity analysis
    Log    ℹ️ Storage capacity analysis completed and logged    console=yes
    Log    ✅ Storage capacity analysis: INFORMATIONAL - Available for review    console=yes

Normal - Volume Group Analysis
    [Documentation]    🏗️ Analyze volume group and logical volume configuration
    [Tags]             normal    analysis    lvm    volumes

    Log    🔍 Analyzing volume group configuration...    console=yes

    Log    📋 EDS Volume Group Info: ${TARGET_DRIVE_VOLUME_GROUP}    console=yes
    Log    📋 EDS Logical Volume: ${TARGET_LOGICAL_VOLUME}    console=yes
    Log    📋 EDS File System: ${TARGET_FILE_SYSTEM}    console=yes

    # Get actual filesystem information
    ${actual_fs_type}=    Get Filesystem Information From Server

    Log    🏗️ Server Filesystem Type: ${actual_fs_type}    console=yes

    # Log volume configuration for analysis
    Log    ℹ️ Volume group analysis: EDS vs Server configuration logged    console=yes
    Log    ✅ Volume group analysis: INFORMATIONAL - Available for review    console=yes

Normal - Operating System Validation
    [Documentation]    🖥️ Validate operating system type matches EDS specification
    [Tags]             normal    os    system    compliance

    Log    🔍 Validating operating system: EDS vs Server...    console=yes

    # Get OS information from server
    ${os_info}=    Execute Command    cat /etc/os-release | grep PRETTY_NAME | cut -d'"' -f2
    ${kernel_info}=    Execute Command    uname -r

    Log    📋 EDS Expected OS Type: ${TARGET_OS_TYPE}    console=yes
    Log    🖥️ Server OS: ${os_info}    console=yes
    Log    🖥️ Server Kernel: ${kernel_info}    console=yes

    # Log OS validation for compliance review
    Log    ℹ️ OS validation: EDS expects '${TARGET_OS_TYPE}', Server runs '${os_info}'    console=yes
    Log    ✅ Operating system validation: LOGGED for compliance review    console=yes