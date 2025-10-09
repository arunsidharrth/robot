*** Settings ***
Documentation    💾 Datastore Configuration Validation Test Suite - Test-9
...              🔍 Process: Connect to vCenter → Collect Datastore Information → Validate Datastore Configuration
...              ✅ Pass if datastore configuration meets cluster standards and application requirements
...              📊 Validates: VM assignments, available capacity, performance tiers, subscription levels
...
Resource         ../../settings.resource
Resource         datastore_keywords.resource
Resource         variables.resource

Suite Setup      Initialize Datastore Configuration Test Environment
Suite Teardown   Generate Datastore Configuration Executive Summary

Test Setup       Log Test Start    ${TEST_NAME}
Test Teardown    Log Test End      ${TEST_NAME}    ${TEST_STATUS}

*** Test Cases ***
Critical - Connect to vCenter
    [Documentation]    🔗 Establish connection to VMware vCenter and locate the target host in the cluster environment
    [Tags]             critical    connection    vcenter    infrastructure

    Log    🔍 Establishing connection to vCenter...    console=yes
    Log    📋 vCenter Server: ${VCENTER_SERVER}    console=yes
    Log    📋 Target Host: ${VCENTER_HOST}    console=yes
    Log    📋 Cluster Environment: ${CLUSTER_NAME}    console=yes

    # Establish vCenter connection
    Connect To vCenter

    # Verify connection is active
    ${connection_status}=    Verify vCenter Connection
    Should Be True    ${connection_status}    msg=Failed to establish vCenter connection

    # Locate target host in cluster
    ${host_found}=    Locate Target Host In Cluster
    Should Be True    ${host_found}    msg=Target host ${VCENTER_HOST} not found in cluster ${CLUSTER_NAME}

    Log    ✅ vCenter connection established and target host located in cluster    console=yes

Critical - Collect Datastore Information
    [Documentation]    📊 Gather all datastore configuration data including VM assignments, available capacity, performance tiers, subscription levels, and capture screenshot of host configuration and status parameters
    [Tags]             critical    datastore    collection

    Log    🔍 Collecting all datastore configuration data...    console=yes
    Log    📋 Target Host: ${VCENTER_HOST}    console=yes

    # Collect VM assignments
    Log    📊 Collecting VM assignments to datastores...    console=yes
    ${vm_assignments}=    Collect VM Datastore Assignments
    Set Suite Variable    ${VM_ASSIGNMENTS}    ${vm_assignments}
    ${vm_count}=    Get Length    ${vm_assignments}
    Should Be True    ${vm_count} > 0    msg=No VMs found on target host
    Log    ✅ VM assignments collected: ${vm_count} VMs found    console=yes

    # Collect available capacity
    Log    📊 Collecting datastore capacity information...    console=yes
    ${capacity_data}=    Collect Datastore Capacity
    Set Suite Variable    ${CAPACITY_DATA}    ${capacity_data}
    ${datastore_count}=    Get Length    ${capacity_data}
    Should Be True    ${datastore_count} > 0    msg=No datastores found on target host
    FOR    ${ds}    IN    @{capacity_data}
        Log    📊 Datastore: ${ds['name']} - Total: ${ds['total_gb']}GB, Free: ${ds['free_gb']}GB, Used: ${ds['used_percent']}%    console=yes
    END
    Log    ✅ Capacity data collected for ${datastore_count} datastores    console=yes

    # Collect performance tier information
    Log    📊 Collecting datastore performance tier information...    console=yes
    ${performance_tiers}=    Collect Datastore Performance Tiers
    Set Suite Variable    ${PERFORMANCE_TIERS}    ${performance_tiers}
    ${tier_count}=    Get Length    ${performance_tiers}
    Should Be True    ${tier_count} > 0    msg=No performance tier information available
    FOR    ${tier}    IN    @{performance_tiers}
        Log    📊 Datastore: ${tier['name']} - Tier: ${tier['performance_tier']} - Type: ${tier['storage_type']}    console=yes
    END
    Log    ✅ Performance tier data collected for ${tier_count} datastores    console=yes

    # Collect subscription level information
    Log    📊 Collecting datastore subscription level information...    console=yes
    ${subscription_data}=    Collect Datastore Subscription Levels
    Set Suite Variable    ${SUBSCRIPTION_DATA}    ${subscription_data}
    ${sub_count}=    Get Length    ${subscription_data}
    Should Be True    ${sub_count} > 0    msg=No subscription level information available
    FOR    ${sub}    IN    @{subscription_data}
        Log    📊 Datastore: ${sub['name']} - Provisioned: ${sub['provisioned_gb']}GB, Ratio: ${sub['subscription_ratio']}:1    console=yes
    END
    Log    ✅ Subscription data collected for ${sub_count} datastores    console=yes

    # Capture host configuration screenshot
    Log    📸 Capturing host configuration screenshot...    console=yes
    Log    📋 Screenshot will include: Datastores, VM assignments, Capacity, Performance status    console=yes
    ${screenshot_path}=    Capture Host Configuration Screenshot
    Set Suite Variable    ${SCREENSHOT_PATH}    ${screenshot_path}
    OperatingSystem.File Should Exist    ${screenshot_path}
    Log    ✅ Screenshot saved: ${screenshot_path}    console=yes

    Log    ✅ All datastore information collected successfully    console=yes

Critical - Validate Datastore Configuration
    [Documentation]    ✅ Compare all collected datastore data (VM placement, available capacity, performance tier, subscription ratios) against cluster standards and application requirements to ensure proper storage allocation and performance compliance
    [Tags]             critical    validation    compliance

    Log    🔍 Validating datastore configuration against cluster standards...    console=yes

    # Validate VM datastore placement
    Log    🔍 Validating VM datastore placement...    console=yes
    ${placement_results}=    Validate VM Datastore Placement    ${VM_ASSIGNMENTS}
    ${violations}=    Get From Dictionary    ${placement_results}    violations
    ${violation_count}=    Get Length    ${violations}
    Log    📊 VM placement validation: ${violation_count} violations found    console=yes
    IF    ${violation_count} > 0
        FOR    ${violation}    IN    @{violations}
            Log    ⚠️ Violation: VM ${violation['vm_name']} - ${violation['reason']}    console=yes
        END
        Fail    VM datastore placement has ${violation_count} violations
    END
    Log    ✅ VM datastore placement validated    console=yes

    # Validate available capacity
    Log    🔍 Validating datastore available capacity...    console=yes
    Log    📋 Minimum required free capacity: ${MIN_FREE_CAPACITY_PERCENT}%    console=yes
    ${capacity_results}=    Validate Datastore Capacity    ${CAPACITY_DATA}
    ${warnings}=    Get From Dictionary    ${capacity_results}    warnings
    ${warning_count}=    Get Length    ${warnings}
    Log    📊 Capacity validation: ${warning_count} warnings found    console=yes
    IF    ${warning_count} > 0
        FOR    ${warning}    IN    @{warnings}
            Log    ⚠️ Warning: Datastore ${warning['name']} - Free: ${warning['free_percent']}% (Below threshold: ${MIN_FREE_CAPACITY_PERCENT}%)    console=yes
        END
        Fail    Datastore capacity validation failed: ${warning_count} datastores below minimum threshold
    END
    Log    ✅ Available capacity validated    console=yes

    # Validate performance tier assignment
    Log    🔍 Validating performance tier assignments...    console=yes
    ${tier_results}=    Validate Performance Tier Assignment    ${VM_ASSIGNMENTS}    ${PERFORMANCE_TIERS}
    ${mismatches}=    Get From Dictionary    ${tier_results}    mismatches
    ${mismatch_count}=    Get Length    ${mismatches}
    Log    📊 Performance tier validation: ${mismatch_count} mismatches found    console=yes
    IF    ${mismatch_count} > 0
        FOR    ${mismatch}    IN    @{mismatches}
            Log    ⚠️ Mismatch: VM ${mismatch['vm_name']} - Current tier: ${mismatch['current_tier']}, Required: ${mismatch['required_tier']}    console=yes
        END
        Fail    Performance tier validation failed: ${mismatch_count} VMs on incorrect storage tier
    END
    Log    ✅ Performance tier validated    console=yes

    # Validate subscription ratios
    Log    🔍 Validating datastore subscription ratios...    console=yes
    Log    📋 Maximum allowed subscription ratio: ${MAX_SUBSCRIPTION_RATIO}:1    console=yes
    ${sub_results}=    Validate Subscription Ratios    ${SUBSCRIPTION_DATA}
    ${oversubscribed}=    Get From Dictionary    ${sub_results}    oversubscribed
    ${oversub_count}=    Get Length    ${oversubscribed}
    Log    📊 Subscription validation: ${oversub_count} oversubscribed datastores found    console=yes
    IF    ${oversub_count} > 0
        FOR    ${oversub}    IN    @{oversubscribed}
            Log    ⚠️ Oversubscribed: Datastore ${oversub['name']} - Ratio: ${oversub['ratio']}:1 (Max: ${MAX_SUBSCRIPTION_RATIO}:1)    console=yes
        END
        Fail    Subscription validation failed: ${oversub_count} datastores exceed maximum ratio
    END
    Log    ✅ Subscription ratios validated    console=yes

    Log    📊 Datastore configuration validation summary:    console=yes
    Log    📊 - VM datastore placement: ✅    console=yes
    Log    📊 - Available capacity: ✅    console=yes
    Log    📊 - Performance tier assignment: ✅    console=yes
    Log    📊 - Subscription ratios: ✅    console=yes
    Log    ✅ Datastore configuration validation: PASSED - All datastores meet cluster standards and application requirements    console=yes
