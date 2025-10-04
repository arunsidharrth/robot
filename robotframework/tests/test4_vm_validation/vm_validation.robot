*** Settings ***
Documentation    🖥️ VM Configuration Validation Test Suite - Test-4
...              🔍 Process: Connect to vCenter API → Query VM details → Compare vCenter vs EDS
...              ✅ Pass if VM configuration matches EDS requirements, ❌ Fail if mismatch
...              📊 Validates: Cluster placement, CPU cores, memory, hardware version, network, disks
...
Resource         ../../settings.resource
Resource         vm_keywords.resource
Resource         variables.resource

Suite Setup      Initialize VM Test Environment And Lookup Configuration
Suite Teardown   Generate VM Executive Summary And Disconnect

Test Setup       Log Test Start    ${TEST_NAME}
Test Teardown    Log Test End      ${TEST_NAME}    ${TEST_STATUS}

*** Variables ***
${VM_DETAILS}    ${EMPTY}

*** Test Cases ***
Critical - vCenter API Connection
    [Documentation]    🔌 Establish API connection to vCenter and retrieve VM details
    [Tags]             critical    vcenter    api    connection

    Log    🔍 Connecting to vCenter API and retrieving VM configuration...    console=yes

    # Validate vCenter connection details are available
    Should Not Be Equal    ${TARGET_VCENTER_HOST}    N/A
    ...    ❌ CONFIGURATION ERROR: vCenter host not specified in EDS

    Should Not Be Empty    ${VCENTER_USERNAME}
    ...    ❌ CONFIGURATION ERROR: vCenter username not provided (set VCENTER_USERNAME variable or ENV_VCENTER_USERNAME)

    Should Not Be Empty    ${VCENTER_PASSWORD}
    ...    ❌ CONFIGURATION ERROR: vCenter password not provided (set VCENTER_PASSWORD variable or ENV_VCENTER_PASSWORD)

    # Connect to vCenter and retrieve VM details
    ${vm_details}=    Connect To vCenter And Get VM Details
    ...    ${TARGET_HOSTNAME}
    ...    ${TARGET_VCENTER_HOST}
    ...    ${VCENTER_USERNAME}
    ...    ${VCENTER_PASSWORD}

    Set Suite Variable    ${VM_DETAILS}    ${vm_details}

    Log    ✅ vCenter API connection: SUCCESS - VM details retrieved    console=yes

Critical - VM Cluster Placement Validation
    [Documentation]    🏢 Validate VM is placed in the correct VxRail cluster per EDS specification
    [Tags]             critical    cluster    placement    compliance

    Log    🔍 Validating VM cluster placement: EDS vs vCenter...    console=yes

    # Get cluster placement from VM details
    ${actual_cluster_id}=    Get VM Cluster Placement    ${VM_DETAILS}

    # Validate against EDS
    Validate VM Cluster Placement Against EDS    ${actual_cluster_id}    ${TARGET_VXRAIL_CLUSTER}

    Log    ✅ Cluster placement validation: PASSED - VM in correct cluster    console=yes

Critical - VM CPU Configuration Validation
    [Documentation]    💻 Validate VM CPU allocation matches EDS specification
    [Tags]             critical    cpu    hardware    compliance

    Log    🔍 Validating VM CPU configuration: EDS vs vCenter...    console=yes

    # Get CPU configuration from VM details
    ${actual_cpu_count}=    Get VM CPU Configuration    ${VM_DETAILS}

    # Validate against EDS
    Validate VM CPU Against EDS    ${actual_cpu_count}    ${TARGET_VM_CPU_CORES}

    Log    ✅ CPU configuration validation: PASSED - EDS matches vCenter    console=yes

Critical - VM Memory Configuration Validation
    [Documentation]    🧠 Validate VM memory allocation matches EDS specification
    [Tags]             critical    memory    hardware    compliance

    Log    🔍 Validating VM memory configuration: EDS vs vCenter...    console=yes

    # Get memory configuration from VM details
    ${actual_memory_gb}=    Get VM Memory Configuration    ${VM_DETAILS}

    # Validate against EDS
    Validate VM Memory Against EDS    ${actual_memory_gb}    ${TARGET_VM_RAM}

    Log    ✅ Memory configuration validation: PASSED - EDS matches vCenter    console=yes

Critical - VM Hardware Version Validation
    [Documentation]    ⚙️ Validate VM hardware version matches EDS specification
    [Tags]             critical    hardware    version    compliance

    Log    🔍 Validating VM hardware version: EDS vs vCenter...    console=yes

    # Get hardware version from VM details
    ${actual_hw_version}=    Get VM Hardware Version    ${VM_DETAILS}

    # Validate against EDS
    Validate VM Hardware Version Against EDS    ${actual_hw_version}    ${TARGET_VM_HARDWARE_VERSION}

    Log    ✅ Hardware version validation: PASSED - EDS matches vCenter    console=yes

Critical - VM Network Adapter Validation
    [Documentation]    🌐 Validate VM network adapter configuration
    [Tags]             critical    network    adapters    compliance

    Log    🔍 Validating VM network adapters...    console=yes

    # Get network adapter configuration
    ${network_adapters}=    Get VM Network Adapter Configuration    ${VM_DETAILS}

    # Validate network configuration
    Validate VM Network Configuration    ${network_adapters}

    Log    ✅ Network adapter validation: PASSED - Adapters configured    console=yes

Critical - VM Disk Configuration Validation
    [Documentation]    💾 Validate VM disk configuration and capacity
    [Tags]             critical    disk    storage    compliance

    Log    🔍 Validating VM disk configuration...    console=yes

    # Get disk configuration
    ${total_disk_capacity}=    Get VM Disk Configuration    ${VM_DETAILS}

    # Validate disk configuration
    Validate VM Disk Configuration    ${total_disk_capacity}

    Log    ✅ Disk configuration validation: PASSED - Disks configured    console=yes

Normal - VM Properties Comprehensive Review
    [Documentation]    📋 Review all VM properties and configuration details
    [Tags]             normal    analysis    review    properties

    Log    🔍 Performing comprehensive VM properties review...    console=yes

    # Log comprehensive VM configuration
    ${config}=    Get From Dictionary    ${VM_DETAILS}    configuration

    Log    📊 VM Comprehensive Configuration:    console=yes
    Log    📊 - Name: ${config['name']}    console=yes
    Log    📊 - Power State: ${config['power_state']}    console=yes
    Log    📊 - CPU Count: ${config['cpu_count']}    console=yes
    Log    📊 - Cores per Socket: ${config['cores_per_socket']}    console=yes
    Log    📊 - Memory: ${config['memory_size_gb']} GB    console=yes
    Log    📊 - Hardware Version: ${config['hardware_version']}    console=yes
    Log    📊 - Guest OS: ${config['guest_os']}    console=yes

    Log    ℹ️ Comprehensive VM properties logged for review    console=yes
    Log    ✅ VM properties review: INFORMATIONAL - Complete    console=yes

*** Keywords ***
Generate VM Executive Summary And Disconnect
    [Documentation]    Generate executive summary and disconnect from vCenter

    Generate VM Executive Summary
    Disconnect From vCenter
