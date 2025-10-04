*** Settings ***
Documentation    VM Validation Test Variables - EDS Configuration Data
Library          ../../library/EDSLookup.py
Library          BuiltIn
Library          OperatingSystem

*** Variables ***
# Will be populated from EDS during suite setup
${TARGET_VXRAIL_CLUSTER}         ${EMPTY}
${TARGET_VCENTER_HOST}           ${EMPTY}
${TARGET_VM_CPU_CORES}           ${EMPTY}
${TARGET_VM_RAM}                 ${EMPTY}
${TARGET_VM_HARDWARE_VERSION}    ${EMPTY}
${TARGET_VM_MEMORY_RESERVATION}  ${EMPTY}
${TARGET_VM_CPU_RESERVATION}     ${EMPTY}

# vCenter credentials - Default values (can be overridden via environment variables)
${VCENTER_USERNAME}              test
${VCENTER_PASSWORD}              test
${DEFAULT_VCENTER_HOST}          www.linux.com

*** Keywords ***
Initialize VM Test Environment And Lookup Configuration
    [Documentation]    Initialize test environment and lookup VM configuration from EDS

    Log    🚀 Initializing VM Validation Test Suite (Test-4)    console=yes
    Log    🎯 Target VM: ${TARGET_HOSTNAME}    console=yes

    # Lookup configuration from EDS sheet
    ${eds_config}=    Lookup Server Config    ${TARGET_HOSTNAME}

    # Extract VM-specific EDS configuration
    Set Suite Variable    ${TARGET_VXRAIL_CLUSTER}         ${eds_config['vxrail_cluster']}

    # Use EDS vCenter host if available, otherwise use default
    ${vcenter_from_eds}=    Set Variable    ${eds_config['vcenter_host']}
    ${final_vcenter_host}=    Run Keyword If    '${vcenter_from_eds}' == 'N/A'
    ...    Set Variable    ${DEFAULT_VCENTER_HOST}
    ...    ELSE
    ...    Set Variable    ${vcenter_from_eds}
    Set Suite Variable    ${TARGET_VCENTER_HOST}           ${final_vcenter_host}

    Set Suite Variable    ${TARGET_VM_CPU_CORES}           ${eds_config['cpu_cores']}
    Set Suite Variable    ${TARGET_VM_RAM}                 ${eds_config['ram']}
    Set Suite Variable    ${TARGET_VM_HARDWARE_VERSION}    ${eds_config['vm_hardware_version']}
    Set Suite Variable    ${TARGET_VM_MEMORY_RESERVATION}  ${eds_config['vm_memory_reservation']}
    Set Suite Variable    ${TARGET_VM_CPU_RESERVATION}     ${eds_config['vm_cpu_reservation']}

    # vCenter credentials are already set as default values in variables section
    # They can be overridden via environment variables if needed
    ${env_vcenter_user}=    Get Environment Variable    VCENTER_USERNAME    ${VCENTER_USERNAME}
    ${env_vcenter_pass}=    Get Environment Variable    VCENTER_PASSWORD    ${VCENTER_PASSWORD}

    Set Suite Variable    ${VCENTER_USERNAME}    ${env_vcenter_user}
    Set Suite Variable    ${VCENTER_PASSWORD}    ${env_vcenter_pass}

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
