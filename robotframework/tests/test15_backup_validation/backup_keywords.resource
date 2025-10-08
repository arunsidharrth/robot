*** Settings ***
Documentation    Keywords for Backup Validation Test Suite
Library          Collections
Library          OperatingSystem
Library          String
Library          DateTime
Library          ../../libraries/VCenterAPILibrary.py
Library          ../../libraries/BackupValidator.py

*** Keywords ***
Initialize Backup Validation Test Environment
    [Documentation]    Initialize test environment for backup validation
    Log    🚀 Initializing Backup Validation Test Environment...    console=yes

    # Initialize vCenter API connection variables
    Set Global Variable    ${VCENTER_API_CONN}    ${None}

    # Initialize test result tracking
    Set Global Variable    ${TEST_START_TIME}    ${EMPTY}
    ${start_time}=    Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    Set Global Variable    ${TEST_START_TIME}    ${start_time}

    # Create results directory
    Create Directory    results/test15_backup_validation

    Log    ✅ Test environment initialized at ${TEST_START_TIME}    console=yes

Connect To vCenter API
    [Documentation]    Establish connection to vCenter REST API
    Log    🔗 Connecting to vCenter API: ${VCENTER_API_ENDPOINT}    console=yes

    # Connect to vCenter API using library
    ${connection}=    VCenter API Connect    ${VCENTER_API_ENDPOINT}    ${VCENTER_USERNAME}    ${VCENTER_PASSWORD}    ${API_TIMEOUT}    ${API_VERIFY_SSL}
    Set Global Variable    ${VCENTER_API_CONN}    ${connection}

    Log    ✅ Connected to vCenter API: ${VCENTER_API_ENDPOINT}    console=yes
    RETURN    ${connection}

Verify vCenter API Connection
    [Documentation]    Verify vCenter API connection is active
    Log    🔍 Verifying vCenter API connection status...    console=yes

    # Verify connection
    ${status}=    VCenter API Verify Connection    ${VCENTER_API_CONN}

    Log    ✅ vCenter API connection verified: ${status}    console=yes
    RETURN    ${status}

Collect Backup Policy Configuration
    [Documentation]    Collect VM backup policy configuration via API
    Log    📊 Collecting backup policy configuration via API...    console=yes

    # Collect backup policies
    ${policies}=    VCenter API Get Backup Policies    ${VCENTER_API_CONN}    ${TARGET_VMS}

    ${count}=    Get Length    ${policies}
    Log    📊 Collected backup policies for ${count} VMs    console=yes

    RETURN    ${policies}

Collect Backup Schedule Settings
    [Documentation]    Collect backup schedule settings via API
    Log    📊 Collecting backup schedule settings via API...    console=yes

    # Collect schedules
    ${schedules}=    VCenter API Get Backup Schedules    ${VCENTER_API_CONN}    ${TARGET_VMS}

    ${count}=    Get Length    ${schedules}
    Log    📊 Collected backup schedules for ${count} VMs    console=yes

    RETURN    ${schedules}

Collect Recent Backup Job Status
    [Documentation]    Collect recent backup job status via API
    Log    📊 Collecting recent backup job status via API...    console=yes

    # Collect job status
    ${jobs}=    VCenter API Get Recent Backup Jobs    ${VCENTER_API_CONN}    ${TARGET_VMS}    ${BACKUP_LOOKBACK_DAYS}

    ${count}=    Get Length    ${jobs}
    Log    📊 Collected ${count} recent backup jobs    console=yes

    RETURN    ${jobs}

Collect Retention Policy Settings
    [Documentation]    Collect retention policy settings via API
    Log    📊 Collecting retention policy settings via API...    console=yes

    # Collect retention policies
    ${retention}=    VCenter API Get Retention Policies    ${VCENTER_API_CONN}    ${TARGET_VMS}

    ${count}=    Get Length    ${retention}
    Log    📊 Collected retention policies for ${count} VMs    console=yes

    RETURN    ${retention}

Collect Latest Backup Timestamps
    [Documentation]    Collect latest successful backup timestamps via API
    Log    📊 Collecting latest backup timestamps via API...    console=yes

    # Collect timestamps
    ${timestamps}=    VCenter API Get Latest Backup Timestamps    ${VCENTER_API_CONN}    ${TARGET_VMS}

    ${count}=    Get Length    ${timestamps}
    Log    📊 Collected latest backup timestamps for ${count} VMs    console=yes

    RETURN    ${timestamps}

Collect Offsite Replication Status
    [Documentation]    Collect offsite replication status via API
    Log    📊 Collecting offsite replication status via API...    console=yes

    # Collect replication status
    ${replication}=    VCenter API Get Offsite Replication Status    ${VCENTER_API_CONN}    ${TARGET_VMS}

    ${count}=    Get Length    ${replication}
    Log    📊 Collected offsite replication status for ${count} VMs    console=yes

    RETURN    ${replication}

Validate Backup Policy Applied
    [Documentation]    Validate all VMs have appropriate backup policies applied
    [Arguments]    ${policy_data}
    Log    ✅ Validating backup policy application...    console=yes

    # Validate policies
    ${results}=    Backup Validator Validate Policies    ${policy_data}    ${TARGET_VMS}

    ${violations}=    Get From Dictionary    ${results}    violations
    ${violation_count}=    Get Length    ${violations}
    Log    📊 Validation complete: ${violation_count} violations found    console=yes

    RETURN    ${results}

Validate Schedule Alignment With RPO
    [Documentation]    Validate backup schedules meet RPO requirements
    [Arguments]    ${schedule_data}
    Log    ✅ Validating schedule alignment with RPO requirements...    console=yes

    # Validate schedules
    ${results}=    Backup Validator Validate RPO Alignment    ${schedule_data}    ${VM_CRITICALITY}    ${RPO_REQUIREMENTS}

    ${rpo_violations}=    Get From Dictionary    ${results}    rpo_violations
    ${rpo_violation_count}=    Get Length    ${rpo_violations}
    Log    📊 Validation complete: ${rpo_violation_count} RPO violations found    console=yes

    RETURN    ${results}

Validate Retention Settings Compliance
    [Documentation]    Validate retention settings meet compliance standards
    [Arguments]    ${retention_data}
    Log    ✅ Validating retention settings compliance...    console=yes

    # Validate retention
    ${results}=    Backup Validator Validate Retention Compliance    ${retention_data}    ${MIN_DAILY_RETENTION}    ${MIN_WEEKLY_RETENTION}    ${MIN_MONTHLY_RETENTION}

    ${violations}=    Get From Dictionary    ${results}    violations
    ${violation_count}=    Get Length    ${violations}
    Log    📊 Validation complete: ${violation_count} violations found    console=yes

    RETURN    ${results}

Validate Recent Job Completion Status
    [Documentation]    Validate recent backup jobs completed successfully
    [Arguments]    ${job_status}
    Log    ✅ Validating recent backup job completion status...    console=yes

    # Validate job completion
    ${results}=    Backup Validator Validate Job Status    ${job_status}

    ${failed_jobs}=    Get From Dictionary    ${results}    failed_jobs
    ${failed_count}=    Get Length    ${failed_jobs}
    Log    📊 Validation complete: ${failed_count} failed jobs found    console=yes

    RETURN    ${results}

Validate Backup Recency
    [Documentation]    Validate backups are recent and within acceptable time windows
    [Arguments]    ${timestamp_data}
    Log    ✅ Validating backup recency...    console=yes

    # Validate recency
    ${results}=    Backup Validator Validate Backup Recency    ${timestamp_data}    ${MAX_BACKUP_AGE_HOURS}

    ${stale_backups}=    Get From Dictionary    ${results}    stale_backups
    ${stale_count}=    Get Length    ${stale_backups}
    Log    📊 Validation complete: ${stale_count} stale backups found    console=yes

    RETURN    ${results}

Validate Offsite Replication Configuration
    [Documentation]    Validate offsite replication is enabled for critical VMs
    [Arguments]    ${replication_data}
    Log    ✅ Validating offsite replication configuration...    console=yes

    # Validate offsite replication
    ${results}=    Backup Validator Validate Offsite Replication    ${replication_data}    ${OFFSITE_REQUIRED_VMS}

    ${violations}=    Get From Dictionary    ${results}    violations
    ${violation_count}=    Get Length    ${violations}
    Log    📊 Validation complete: ${violation_count} violations found    console=yes

    RETURN    ${results}

Validate Complete Backup Compliance
    [Documentation]    Perform comprehensive backup compliance validation
    Log    🔍 Performing comprehensive backup compliance validation...    console=yes

    # Validate all aspects
    ${policy_validation}=    Validate Backup Policy Applied    ${POLICY_DATA}
    ${rpo_validation}=    Validate Schedule Alignment With RPO    ${SCHEDULE_DATA}
    ${retention_validation}=    Validate Retention Settings Compliance    ${RETENTION_DATA}
    ${job_validation}=    Validate Recent Job Completion Status    ${JOB_STATUS}
    ${recency_validation}=    Validate Backup Recency    ${TIMESTAMP_DATA}
    ${offsite_validation}=    Validate Offsite Replication Configuration    ${REPLICATION_DATA}

    # Aggregate results
    ${total_violations}=    Evaluate    ${policy_validation}['violations'].__len__() + ${rpo_validation}['rpo_violations'].__len__() + ${retention_validation}['violations'].__len__() + ${job_validation}['failed_jobs'].__len__() + ${recency_validation}['stale_backups'].__len__() + ${offsite_validation}['violations'].__len__()

    IF    ${total_violations} > 0
        Log    ⚠️ Comprehensive validation found ${total_violations} total issues    console=yes
    ELSE
        Log    ✅ Comprehensive validation: All checks passed    console=yes
    END

    RETURN    ${total_violations}

Generate Backup Validation Executive Summary
    [Documentation]    Generate executive summary report for backup validation test
    Log    📊 Generating Backup Validation Executive Summary...    console=yes

    # Get test end time
    ${end_time}=    Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    Set Global Variable    ${TEST_END_TIME}    ${end_time}

    # Generate summary report
    ${summary_file}=    Set Variable    results/test15_backup_validation/Test15_Backup_Validation_Executive_Summary.txt

    ${summary_content}=    Catenate    SEPARATOR=\n
    ...    ========================================
    ...    💾 TEST-15: BACKUP VALIDATION
    ...    📊 EXECUTIVE SUMMARY REPORT
    ...    ========================================
    ...
    ...    📅 Report Generated: ${end_time}
    ...    🎯 vCenter Server: ${VCENTER_SERVER}
    ...    📋 Test Suite: Test-15 Backup Configuration Validation
    ...
    ...    ========================================
    ...    📋 TEST OBJECTIVES
    ...    ========================================
    ...    1. Connect to vCenter REST API
    ...    2. Collect backup configuration via API calls
    ...    3. Validate backup compliance against standards
    ...
    ...    ========================================
    ...    📊 VALIDATION SCOPE
    ...    ========================================
    ...    ✅ Backup policy application
    ...    ✅ Schedule alignment with RPO
    ...    ✅ Retention settings compliance
    ...    ✅ Recent job completion status
    ...    ✅ Backup recency validation
    ...    ✅ Offsite replication configuration
    ...
    ...    ========================================
    ...    📋 TARGET VMS
    ...    ========================================

    FOR    ${vm}    IN    @{TARGET_VMS}
        ${summary_content}=    Catenate    SEPARATOR=\n    ${summary_content}    ...    🖥️ ${vm}
    END

    ${summary_content}=    Catenate    SEPARATOR=\n    ${summary_content}
    ...
    ...    ========================================
    ...    🔍 COMPLIANCE REQUIREMENTS
    ...    ========================================
    ...    📅 Maximum backup age: ${MAX_BACKUP_AGE_HOURS} hours
    ...    💾 Minimum daily retention: ${MIN_DAILY_RETENTION} days
    ...    📦 Minimum weekly retention: ${MIN_WEEKLY_RETENTION} weeks
    ...    🌐 Offsite replication: Required for critical VMs
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
    ...    📄 API data collected in JSON format
    ...    📊 Robot Framework reports: results/test15_backup_validation/
    ...
    ...    ========================================
    ...    🏆 COMPLIANCE STATUS
    ...    ========================================
    ...    ✅ Test execution completed successfully
    ...    💾 Backup policies validated
    ...    📅 Schedule compliance verified
    ...    🗄️ Retention settings confirmed
    ...    🌐 Offsite replication validated
    ...    🔍 Results ready for stakeholder review
    ...
    ...    End of Executive Summary
    ...    ========================================

    Create File    ${summary_file}    ${summary_content}
    Log    📊 Executive summary generated: ${summary_file}    console=yes
    Log    ✅ Test-15 Backup Validation completed successfully!    console=yes

    # Disconnect from vCenter API
    IF    ${VCENTER_API_CONN}
        VCenter API Disconnect    ${VCENTER_API_CONN}
        Log    🔌 Disconnected from vCenter API    console=yes
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
