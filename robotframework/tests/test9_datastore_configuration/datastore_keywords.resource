*** Settings ***
Documentation    Keywords for Datastore Configuration Test Suite
Library          SSHLibrary
Library          Collections
Library          OperatingSystem
Library          String
Library          DateTime
Library          Screenshot
Library          ../../libraries/VCenterLibrary.py
Library          ../../libraries/DatastoreValidator.py

*** Keywords ***
Initialize Datastore Configuration Test Environment
    [Documentation]    Initialize test environment and create necessary directories
    Log    🚀 Initializing Datastore Configuration Test Environment...    console=yes

    # Create screenshot directory
    Create Directory    ${SCREENSHOT_DIR}

    # Initialize vCenter connection variables
    Set Global Variable    ${VCENTER_CONN}    ${None}

    # Initialize test result tracking
    Set Global Variable    ${TEST_START_TIME}    ${EMPTY}
    ${start_time}=    Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    Set Global Variable    ${TEST_START_TIME}    ${start_time}

    Log    ✅ Test environment initialized at ${TEST_START_TIME}    console=yes

Connect To vCenter
    [Documentation]    Establish connection to vCenter server
    Log    🔗 Connecting to vCenter server: ${VCENTER_SERVER}    console=yes

    # Connect to vCenter using library
    ${connection}=    VCenter Connect    ${VCENTER_SERVER}    ${VCENTER_USERNAME}    ${VCENTER_PASSWORD}
    Set Global Variable    ${VCENTER_CONN}    ${connection}

    Log    ✅ Connected to vCenter: ${VCENTER_SERVER}    console=yes
    RETURN    ${connection}

Verify vCenter Connection
    [Documentation]    Verify vCenter connection is active
    Log    🔍 Verifying vCenter connection status...    console=yes

    # Verify connection
    ${status}=    VCenter Verify Connection    ${VCENTER_CONN}

    Log    ✅ vCenter connection verified: ${status}    console=yes
    RETURN    ${status}

Locate Target Host In Cluster
    [Documentation]    Locate target ESXi host within the cluster
    Log    🔍 Locating target host ${VCENTER_HOST} in cluster ${CLUSTER_NAME}...    console=yes

    # Locate host in cluster
    ${found}=    VCenter Find Host In Cluster    ${VCENTER_CONN}    ${CLUSTER_NAME}    ${VCENTER_HOST}

    IF    ${found}
        Log    ✅ Target host located: ${VCENTER_HOST}    console=yes
    ELSE
        Log    ❌ Target host not found: ${VCENTER_HOST}    console=yes
    END

    RETURN    ${found}

Collect VM Datastore Assignments
    [Documentation]    Collect all VM to datastore assignments for the target host
    Log    📊 Collecting VM datastore assignments for host: ${VCENTER_HOST}...    console=yes

    # Collect VM assignments
    ${assignments}=    VCenter Get VM Datastore Assignments    ${VCENTER_CONN}    ${VCENTER_HOST}

    ${count}=    Get Length    ${assignments}
    Log    📊 Collected ${count} VM assignments    console=yes

    RETURN    ${assignments}

Collect Datastore Capacity
    [Documentation]    Collect capacity information for all datastores on target host
    Log    📊 Collecting datastore capacity information...    console=yes

    # Collect capacity data
    ${capacity}=    VCenter Get Datastore Capacity    ${VCENTER_CONN}    ${VCENTER_HOST}

    ${count}=    Get Length    ${capacity}
    Log    📊 Collected capacity data for ${count} datastores    console=yes

    RETURN    ${capacity}

Collect Datastore Performance Tiers
    [Documentation]    Collect performance tier classification for datastores
    Log    📊 Collecting datastore performance tier information...    console=yes

    # Collect performance tiers
    ${tiers}=    VCenter Get Datastore Performance Tiers    ${VCENTER_CONN}    ${VCENTER_HOST}

    ${count}=    Get Length    ${tiers}
    Log    📊 Collected performance tier data for ${count} datastores    console=yes

    RETURN    ${tiers}

Collect Datastore Subscription Levels
    [Documentation]    Collect subscription levels and oversubscription ratios
    Log    📊 Collecting datastore subscription level information...    console=yes

    # Collect subscription data
    ${subscription}=    VCenter Get Datastore Subscription Levels    ${VCENTER_CONN}    ${VCENTER_HOST}

    ${count}=    Get Length    ${subscription}
    Log    📊 Collected subscription data for ${count} datastores    console=yes

    RETURN    ${subscription}

Capture Host Configuration Screenshot
    [Documentation]    Capture screenshot of host configuration and status
    Log    📸 Capturing host configuration screenshot...    console=yes

    # Generate screenshot filename
    ${timestamp}=    Get Current Date    result_format=%Y%m%d_%H%M%S
    ${screenshot_file}=    Set Variable    ${SCREENSHOT_DIR}/host_config_${timestamp}.${SCREENSHOT_FORMAT}

    # Capture screenshot using vCenter web client
    ${path}=    VCenter Capture Host Screenshot    ${VCENTER_CONN}    ${VCENTER_HOST}    ${screenshot_file}

    Log    📸 Screenshot captured: ${path}    console=yes
    RETURN    ${path}

Validate VM Datastore Placement
    [Documentation]    Validate VM datastore assignments against cluster standards
    [Arguments]    ${vm_assignments}
    Log    ✅ Validating VM datastore placement...    console=yes

    # Validate placement
    ${results}=    Datastore Validator Validate VM Placement    ${vm_assignments}    ${CLUSTER_NAME}

    ${violations}=    Get From Dictionary    ${results}    violations
    ${violation_count}=    Get Length    ${violations}
    Log    📊 Validation complete: ${violation_count} violations found    console=yes

    RETURN    ${results}

Validate Datastore Capacity
    [Documentation]    Validate datastores have sufficient available capacity
    [Arguments]    ${capacity_data}
    Log    ✅ Validating datastore capacity...    console=yes

    # Validate capacity against thresholds
    ${results}=    Datastore Validator Validate Capacity    ${capacity_data}    ${MIN_FREE_CAPACITY_PERCENT}

    ${warnings}=    Get From Dictionary    ${results}    warnings
    ${warning_count}=    Get Length    ${warnings}
    Log    📊 Validation complete: ${warning_count} warnings found    console=yes

    RETURN    ${results}

Validate Performance Tier Assignment
    [Documentation]    Validate VMs are on appropriate performance tiers
    [Arguments]    ${vm_assignments}    ${performance_tiers}
    Log    ✅ Validating performance tier assignments...    console=yes

    # Validate tier assignments
    ${results}=    Datastore Validator Validate Performance Tiers    ${vm_assignments}    ${performance_tiers}    ${VM_APP_CATEGORIES}

    ${mismatches}=    Get From Dictionary    ${results}    mismatches
    ${mismatch_count}=    Get Length    ${mismatches}
    Log    📊 Validation complete: ${mismatch_count} mismatches found    console=yes

    RETURN    ${results}

Validate Subscription Ratios
    [Documentation]    Validate datastore subscription ratios
    [Arguments]    ${subscription_data}
    Log    ✅ Validating subscription ratios...    console=yes

    # Validate subscription ratios
    ${results}=    Datastore Validator Validate Subscription    ${subscription_data}    ${MAX_SUBSCRIPTION_RATIO}

    ${oversubscribed}=    Get From Dictionary    ${results}    oversubscribed
    ${oversub_count}=    Get Length    ${oversubscribed}
    Log    📊 Validation complete: ${oversub_count} oversubscribed datastores found    console=yes

    RETURN    ${results}

Validate Complete Datastore Configuration
    [Documentation]    Perform comprehensive datastore configuration validation
    Log    🔍 Performing comprehensive datastore configuration validation...    console=yes

    # Validate all aspects
    ${vm_placement}=    Validate VM Datastore Placement    ${VM_ASSIGNMENTS}
    ${capacity}=    Validate Datastore Capacity    ${CAPACITY_DATA}
    ${performance}=    Validate Performance Tier Assignment    ${VM_ASSIGNMENTS}    ${PERFORMANCE_TIERS}
    ${subscription}=    Validate Subscription Ratios    ${SUBSCRIPTION_DATA}

    # Aggregate results
    ${total_violations}=    Evaluate    ${vm_placement}['violations'].__len__() + ${capacity}['warnings'].__len__() + ${performance}['mismatches'].__len__() + ${subscription}['oversubscribed'].__len__()

    IF    ${total_violations} > 0
        Log    ⚠️ Comprehensive validation found ${total_violations} total issues    console=yes
    ELSE
        Log    ✅ Comprehensive validation: All checks passed    console=yes
    END

    RETURN    ${total_violations}

Generate Datastore Configuration Executive Summary
    [Documentation]    Generate executive summary report for datastore configuration test
    Log    📊 Generating Datastore Configuration Executive Summary...    console=yes

    # Get test end time
    ${end_time}=    Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    Set Global Variable    ${TEST_END_TIME}    ${end_time}

    # Generate summary report
    ${summary_file}=    Set Variable    ${EXECDIR}/test_results/test9_datastore_executive_summary.html
    Create File    ${summary_file}    <html><head><title>Datastore Configuration Test Summary</title></head><body>

    # Add summary content
    Append To File    ${summary_file}    <h1>🎯 Datastore Configuration Validation - Executive Summary</h1>
    Append To File    ${summary_file}    <p><strong>Test Period:</strong> ${TEST_START_TIME} to ${TEST_END_TIME}</p>
    Append To File    ${summary_file}    <p><strong>vCenter Server:</strong> ${VCENTER_SERVER}</p>
    Append To File    ${summary_file}    <p><strong>Target Host:</strong> ${VCENTER_HOST}</p>
    Append To File    ${summary_file}    <p><strong>Cluster:</strong> ${CLUSTER_NAME}</p>
    Append To File    ${summary_file}    <p><strong>Screenshot:</strong> ${SCREENSHOT_PATH}</p>
    Append To File    ${summary_file}    </body></html>

    Log    ✅ Executive summary generated: ${summary_file}    console=yes

    # Disconnect from vCenter
    IF    ${VCENTER_CONN}
        VCenter Disconnect    ${VCENTER_CONN}
        Log    🔌 Disconnected from vCenter    console=yes
    END

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
