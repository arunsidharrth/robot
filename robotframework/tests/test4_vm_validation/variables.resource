*** Settings ***
Documentation    VM Validation Test Variables - EDS Configuration Data
Library          ../../library/EDSLookup.py

*** Variables ***
# Will be populated from EDS during suite setup
${TARGET_VXRAIL_CLUSTER}         ${EMPTY}
${TARGET_VCENTER_HOST}           ${EMPTY}
${TARGET_VM_CPU_CORES}           ${EMPTY}
${TARGET_VM_RAM}                 ${EMPTY}
${TARGET_VM_HARDWARE_VERSION}    ${EMPTY}
${TARGET_VM_MEMORY_RESERVATION}  ${EMPTY}
${TARGET_VM_CPU_RESERVATION}     ${EMPTY}

# vCenter credentials (to be set via environment variables or test parameters)
${VCENTER_USERNAME}              ${EMPTY}
${VCENTER_PASSWORD}              ${EMPTY}

*** Keywords ***
Initialize VM Test Environment And Lookup Configuration
    [Documentation]    Initialize test environment and lookup VM configuration from EDS

    Log    🚀 Initializing VM Validation Test Suite (Test-4)    console=yes
    Log    🎯 Target VM: ${TARGET_HOSTNAME}    console=yes

    # Lookup configuration from EDS sheet
    ${eds_config}=    Lookup Server Config    ${TARGET_HOSTNAME}

    # Extract VM-specific EDS configuration
    Set Suite Variable    ${TARGET_VXRAIL_CLUSTER}         ${eds_config['vxrail_cluster']}
    Set Suite Variable    ${TARGET_VCENTER_HOST}           ${eds_config['vcenter_host']}
    Set Suite Variable    ${TARGET_VM_CPU_CORES}           ${eds_config['cpu_cores']}
    Set Suite Variable    ${TARGET_VM_RAM}                 ${eds_config['ram']}
    Set Suite Variable    ${TARGET_VM_HARDWARE_VERSION}    ${eds_config['vm_hardware_version']}
    Set Suite Variable    ${TARGET_VM_MEMORY_RESERVATION}  ${eds_config['vm_memory_reservation']}
    Set Suite Variable    ${TARGET_VM_CPU_RESERVATION}     ${eds_config['vm_cpu_reservation']}

    # Get vCenter credentials from environment or suite variables
    ${vcenter_user}=    Get Variable Value    ${VCENTER_USERNAME}    ${EMPTY}
    ${vcenter_pass}=    Get Variable Value    ${VCENTER_PASSWORD}    ${EMPTY}

    # If not set, try to get from environment variables
    Run Keyword If    '${vcenter_user}' == '${EMPTY}'
    ...    Set Suite Variable    ${VCENTER_USERNAME}    ${ENV_VCENTER_USERNAME}

    Run Keyword If    '${vcenter_pass}' == '${EMPTY}'
    ...    Set Suite Variable    ${VCENTER_PASSWORD}    ${ENV_VCENTER_PASSWORD}

    Log    📋 EDS Configuration Retrieved:    console=yes
    Log    📋 - VxRail Cluster: ${TARGET_VXRAIL_CLUSTER}    console=yes
    Log    📋 - vCenter Host: ${TARGET_VCENTER_HOST}    console=yes
    Log    📋 - CPU Cores: ${TARGET_VM_CPU_CORES}    console=yes
    Log    📋 - RAM: ${TARGET_VM_RAM}    console=yes
    Log    📋 - Hardware Version: ${TARGET_VM_HARDWARE_VERSION}    console=yes

    Log    ✅ VM Test Environment Initialized    console=yes

Generate VM Executive Summary
    [Documentation]    Generate executive summary for VM validation test results

    Log    📊 Generating VM Validation Executive Summary...    console=yes

    ${summary_file}=    Set Variable    ${OUTPUT_DIR}/Test4_VM_Validation_Executive_Summary.txt

    ${summary}=    Catenate    SEPARATOR=\n
    ...    ========================================
    ...    VM VALIDATION TEST - EXECUTIVE SUMMARY
    ...    ========================================
    ...    ${EMPTY}
    ...    Test Suite: Test-4 VM Validation
    ...    Target VM: ${TARGET_HOSTNAME}
    ...    ${EMPTY}
    ...    EDS CONFIGURATION:
    ...    - VxRail Cluster: ${TARGET_VXRAIL_CLUSTER}
    ...    - vCenter Host: ${TARGET_VCENTER_HOST}
    ...    - Expected CPU Cores: ${TARGET_VM_CPU_CORES}
    ...    - Expected RAM: ${TARGET_VM_RAM}
    ...    - Expected Hardware Version: ${TARGET_VM_HARDWARE_VERSION}
    ...    - Memory Reservation: ${TARGET_VM_MEMORY_RESERVATION}
    ...    - CPU Reservation: ${TARGET_VM_CPU_RESERVATION}
    ...    ${EMPTY}
    ...    VALIDATION STATUS:
    ...    - See detailed test report for validation results
    ...    ${EMPTY}
    ...    ========================================

    Create File    ${summary_file}    ${summary}

    Log    ✅ Executive Summary generated: ${summary_file}    console=yes
