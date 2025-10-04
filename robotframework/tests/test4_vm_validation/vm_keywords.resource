*** Settings ***
Documentation    VM Validation Keywords - vCenter API interactions and VM data collection
Library          ../../library/VCenterAPI.py
Library          Collections
Library          String
Library          BuiltIn

*** Keywords ***
Connect To vCenter And Get VM Details
    [Documentation]    Connect to vCenter API and retrieve comprehensive VM configuration
    [Arguments]    ${vm_name}    ${vcenter_host}    ${vcenter_user}    ${vcenter_pass}

    Log    🔌 Connecting to vCenter: ${vcenter_host}    console=yes

    # Establish vCenter API connection
    ${session_id}=    Connect To VCenter    ${vcenter_host}    ${vcenter_user}    ${vcenter_pass}
    Log    ✅ Connected to vCenter API (Session: ${session_id})    console=yes

    # Get comprehensive VM details
    ${vm_details}=    Get VM Comprehensive Details    ${vm_name}

    Log    📦 Retrieved comprehensive VM details for: ${vm_name}    console=yes

    [Return]    ${vm_details}

Get VM Cluster Placement
    [Documentation]    Extract cluster placement from VM details
    [Arguments]    ${vm_details}

    ${cluster_info}=    Get From Dictionary    ${vm_details}    cluster_placement
    ${cluster_id}=      Get From Dictionary    ${cluster_info}    cluster_id
    ${host_name}=       Get From Dictionary    ${cluster_info}    host_name

    Log    🏢 VM Cluster ID: ${cluster_id}    console=yes
    Log    🖥️ VM Host: ${host_name}    console=yes

    [Return]    ${cluster_id}

Get VM CPU Configuration
    [Documentation]    Extract CPU configuration from VM details
    [Arguments]    ${vm_details}

    ${config}=        Get From Dictionary    ${vm_details}    configuration
    ${cpu_count}=     Get From Dictionary    ${config}        cpu_count
    ${cores_per_socket}=    Get From Dictionary    ${config}    cores_per_socket

    Log    💻 VM CPU Count: ${cpu_count}    console=yes
    Log    💻 VM Cores per Socket: ${cores_per_socket}    console=yes

    [Return]    ${cpu_count}

Get VM Memory Configuration
    [Documentation]    Extract memory configuration from VM details
    [Arguments]    ${vm_details}

    ${config}=        Get From Dictionary    ${vm_details}    configuration
    ${memory_gb}=     Get From Dictionary    ${config}        memory_size_gb

    Log    🧠 VM Memory: ${memory_gb} GB    console=yes

    [Return]    ${memory_gb}

Get VM Hardware Version
    [Documentation]    Extract hardware version from VM details
    [Arguments]    ${vm_details}

    ${config}=        Get From Dictionary    ${vm_details}    configuration
    ${hw_version}=    Get From Dictionary    ${config}        hardware_version

    Log    ⚙️ VM Hardware Version: ${hw_version}    console=yes

    [Return]    ${hw_version}

Get VM Network Adapter Configuration
    [Documentation]    Extract network adapter configuration from VM details
    [Arguments]    ${vm_details}

    ${adapters}=    Get From Dictionary    ${vm_details}    network_adapters
    ${adapter_count}=    Get Length    ${adapters}

    Log    🌐 VM Network Adapters: ${adapter_count}    console=yes

    FOR    ${adapter}    IN    @{adapters}
        ${label}=    Get From Dictionary    ${adapter}    label
        ${type}=     Get From Dictionary    ${adapter}    type
        ${network}=  Get From Dictionary    ${adapter}    network_name
        Log    🔌 Adapter: ${label}, Type: ${type}, Network: ${network}    console=yes
    END

    [Return]    ${adapters}

Get VM Disk Configuration
    [Documentation]    Extract disk configuration from VM details
    [Arguments]    ${vm_details}

    ${disks}=    Get From Dictionary    ${vm_details}    disk_configuration
    ${disk_count}=    Get Length    ${disks}
    ${total_capacity}=    Set Variable    ${0}

    Log    💾 VM Disks: ${disk_count}    console=yes

    FOR    ${disk}    IN    @{disks}
        ${label}=      Get From Dictionary    ${disk}    label
        ${capacity}=   Get From Dictionary    ${disk}    capacity_gb
        ${type}=       Get From Dictionary    ${disk}    type
        Log    💿 Disk: ${label}, Capacity: ${capacity} GB, Type: ${type}    console=yes
        ${total_capacity}=    Evaluate    ${total_capacity} + ${capacity}
    END

    Log    📊 Total Disk Capacity: ${total_capacity} GB    console=yes

    [Return]    ${total_capacity}

Validate VM Cluster Placement Against EDS
    [Documentation]    Validate that VM is in the expected VxRail cluster
    [Arguments]    ${actual_cluster_id}    ${expected_cluster}

    Log    🔍 Validating cluster placement...    console=yes
    Log    📋 Expected VxRail Cluster: ${expected_cluster}    console=yes
    Log    🏢 Actual Cluster ID: ${actual_cluster_id}    console=yes

    # If EDS has specific cluster name, validate it's contained in cluster ID
    Run Keyword If    '${expected_cluster}' != 'N/A'
    ...    Should Contain    ${actual_cluster_id}    ${expected_cluster}    ignore_case=True
    ...    msg=❌ CLUSTER MISMATCH: Expected '${expected_cluster}' but VM is in cluster '${actual_cluster_id}'

    Log    ✅ Cluster placement validated    console=yes

Validate VM CPU Against EDS
    [Documentation]    Validate VM CPU configuration matches EDS specification
    [Arguments]    ${actual_cpu}    ${expected_cpu}

    Log    🔍 Validating CPU configuration...    console=yes
    Log    📋 EDS Expected CPU: ${expected_cpu}    console=yes
    Log    💻 vCenter Actual CPU: ${actual_cpu}    console=yes

    # Convert to integers for comparison
    ${actual_cpu_int}=    Convert To Integer    ${actual_cpu}
    ${expected_cpu_int}=  Convert To Integer    ${expected_cpu}

    Should Be Equal As Integers    ${actual_cpu_int}    ${expected_cpu_int}
    ...    ❌ CPU MISMATCH: EDS expects ${expected_cpu} cores but vCenter shows ${actual_cpu} cores

    Log    ✅ CPU configuration validated    console=yes

Validate VM Memory Against EDS
    [Documentation]    Validate VM memory configuration matches EDS specification
    [Arguments]    ${actual_memory_gb}    ${expected_ram}

    Log    🔍 Validating memory configuration...    console=yes
    Log    📋 EDS Expected RAM: ${expected_ram} GB    console=yes
    Log    🧠 vCenter Actual Memory: ${actual_memory_gb} GB    console=yes

    # Convert expected RAM (may have "GB" suffix) to number
    ${expected_ram_cleaned}=    Remove String    ${expected_ram}    GB    gb    ${SPACE}
    ${expected_ram_float}=      Convert To Number    ${expected_ram_cleaned}
    ${actual_memory_float}=     Convert To Number    ${actual_memory_gb}

    Should Be Equal As Numbers    ${actual_memory_float}    ${expected_ram_float}    precision=2
    ...    ❌ MEMORY MISMATCH: EDS expects ${expected_ram} GB but vCenter shows ${actual_memory_gb} GB

    Log    ✅ Memory configuration validated    console=yes

Validate VM Hardware Version Against EDS
    [Documentation]    Validate VM hardware version matches EDS specification
    [Arguments]    ${actual_hw_version}    ${expected_hw_version}

    Log    🔍 Validating hardware version...    console=yes
    Log    📋 EDS Expected HW Version: ${expected_hw_version}    console=yes
    Log    ⚙️ vCenter Actual HW Version: ${actual_hw_version}    console=yes

    Run Keyword If    '${expected_hw_version}' != 'N/A'
    ...    Should Contain    ${actual_hw_version}    ${expected_hw_version}    ignore_case=True
    ...    msg=❌ HARDWARE VERSION MISMATCH: EDS expects '${expected_hw_version}' but vCenter shows '${actual_hw_version}'

    Log    ✅ Hardware version validated    console=yes

Validate VM Network Configuration
    [Documentation]    Validate VM has network adapters configured
    [Arguments]    ${network_adapters}

    Log    🔍 Validating network configuration...    console=yes

    ${adapter_count}=    Get Length    ${network_adapters}
    Should Be True    ${adapter_count} > 0
    ...    ❌ NETWORK ERROR: VM has no network adapters configured

    Log    ✅ Network configuration validated (${adapter_count} adapter(s))    console=yes

Validate VM Disk Configuration
    [Documentation]    Validate VM disk configuration
    [Arguments]    ${total_disk_capacity_gb}

    Log    🔍 Validating disk configuration...    console=yes
    Log    💾 Total Disk Capacity: ${total_disk_capacity_gb} GB    console=yes

    ${capacity_float}=    Convert To Number    ${total_disk_capacity_gb}
    Should Be True    ${capacity_float} > 0
    ...    ❌ DISK ERROR: VM has no disk capacity configured

    Log    ✅ Disk configuration validated    console=yes

Disconnect From vCenter
    [Documentation]    Disconnect from vCenter API session

    Disconnect From VCenter
    Log    🔌 Disconnected from vCenter API    console=yes
