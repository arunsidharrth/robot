*** Settings ***
Documentation    💾 Backup Configuration Validation Test Suite - Test-15
...              🔍 Process: Connect to vCenter API → Collect Backup Configuration → Validate Backup Compliance
...              ✅ Pass if backup configuration meets data criticality requirements and compliance standards
...              📊 Validates: Backup policies, schedules, retention, job status, offsite replication
...
Resource         ../../settings.resource
Resource         backup_keywords.resource
Resource         variables.resource

Suite Setup      Initialize Backup Validation Test Environment
Suite Teardown   Generate Backup Validation Executive Summary

Test Setup       Log Test Start    ${TEST_NAME}
Test Teardown    Log Test End      ${TEST_NAME}    ${TEST_STATUS}

*** Test Cases ***
Critical - Connect to vCenter API
    [Documentation]    🔗 Establish API connection to VMware vCenter for backup policy queries
    [Tags]             critical    connection    vcenter_api    infrastructure

    Log    🔍 Establishing API connection to vCenter...    console=yes
    Log    📋 vCenter Server: ${VCENTER_SERVER}    console=yes
    Log    📋 API Endpoint: ${VCENTER_API_ENDPOINT}    console=yes

    # Establish vCenter API connection
    Connect To vCenter API

    # Verify API connection is active
    ${connection_status}=    Verify vCenter API Connection
    Should Be True    ${connection_status}    msg=Failed to establish vCenter API connection

    Log    ✅ vCenter API connection established successfully    console=yes

Critical - Collect VM Backup Policy Configuration
    [Documentation]    📊 Retrieve VM backup policy details via vCenter REST API
    [Tags]             critical    backup_policy    api_collection

    Log    🔍 Collecting VM backup policy configuration...    console=yes
    Log    📋 Target VMs: ${TARGET_VMS}    console=yes

    # Collect backup policy configuration
    ${policy_data}=    Collect Backup Policy Configuration
    Set Suite Variable    ${POLICY_DATA}    ${policy_data}

    ${vm_count}=    Get Length    ${policy_data}
    Should Be True    ${vm_count} > 0    msg=No backup policies found for target VMs

    Log    📊 Backup policies collected for ${vm_count} VMs    console=yes
    FOR    ${policy}    IN    @{policy_data}
        Log    📊 VM: ${policy['vm_name']} - Policy: ${policy['policy_name']}    console=yes
    END

    Log    ✅ Backup policy configuration collection complete    console=yes

Critical - Collect Backup Schedule Settings
    [Documentation]    📅 Retrieve backup schedule settings and RPO configuration via API
    [Tags]             critical    backup_schedule    rpo    api_collection

    Log    🔍 Collecting backup schedule settings...    console=yes

    # Collect schedule settings
    ${schedule_data}=    Collect Backup Schedule Settings
    Set Suite Variable    ${SCHEDULE_DATA}    ${schedule_data}

    ${schedule_count}=    Get Length    ${schedule_data}
    Should Be True    ${schedule_count} > 0    msg=No backup schedules found

    Log    📊 Backup schedules collected for ${schedule_count} VMs    console=yes
    FOR    ${schedule}    IN    @{schedule_data}
        Log    📊 VM: ${schedule['vm_name']} - Frequency: ${schedule['frequency']}, RPO: ${schedule['rpo_hours']}h    console=yes
    END

    Log    ✅ Backup schedule settings collection complete    console=yes

Critical - Collect Recent Backup Job Status
    [Documentation]    ✅ Retrieve recent backup job execution status via API
    [Tags]             critical    backup_jobs    job_status    api_collection

    Log    🔍 Collecting recent backup job status...    console=yes
    Log    📋 Looking back ${BACKUP_LOOKBACK_DAYS} days    console=yes

    # Collect job status
    ${job_status}=    Collect Recent Backup Job Status
    Set Suite Variable    ${JOB_STATUS}    ${job_status}

    ${job_count}=    Get Length    ${job_status}
    Should Be True    ${job_count} > 0    msg=No recent backup jobs found

    Log    📊 Recent backup jobs collected: ${job_count} jobs    console=yes
    FOR    ${job}    IN    @{job_status}
        Log    📊 VM: ${job['vm_name']} - Status: ${job['status']}, Completion: ${job['end_time']}    console=yes
    END

    Log    ✅ Recent backup job status collection complete    console=yes

Critical - Collect Retention Policy Settings
    [Documentation]    🗄️ Retrieve backup retention policy settings via API
    [Tags]             critical    retention    compliance    api_collection

    Log    🔍 Collecting retention policy settings...    console=yes

    # Collect retention policies
    ${retention_data}=    Collect Retention Policy Settings
    Set Suite Variable    ${RETENTION_DATA}    ${retention_data}

    ${retention_count}=    Get Length    ${retention_data}
    Should Be True    ${retention_count} > 0    msg=No retention policies found

    Log    📊 Retention policies collected for ${retention_count} VMs    console=yes
    FOR    ${retention}    IN    @{retention_data}
        Log    📊 VM: ${retention['vm_name']} - Daily: ${retention['daily_retention']}d, Weekly: ${retention['weekly_retention']}w    console=yes
    END

    Log    ✅ Retention policy settings collection complete    console=yes

Critical - Collect Latest Backup Timestamps
    [Documentation]    ⏱️ Retrieve latest successful backup timestamps via API
    [Tags]             critical    backup_timestamp    recency

    Log    🔍 Collecting latest backup timestamps...    console=yes

    # Collect latest backup timestamps
    ${timestamp_data}=    Collect Latest Backup Timestamps
    Set Suite Variable    ${TIMESTAMP_DATA}    ${timestamp_data}

    ${timestamp_count}=    Get Length    ${timestamp_data}
    Should Be True    ${timestamp_count} > 0    msg=No backup timestamps found

    Log    📊 Latest backup timestamps collected for ${timestamp_count} VMs    console=yes
    FOR    ${timestamp}    IN    @{timestamp_data}
        Log    📊 VM: ${timestamp['vm_name']} - Last Backup: ${timestamp['last_backup_time']}    console=yes
    END

    Log    ✅ Latest backup timestamps collection complete    console=yes

Critical - Collect Offsite Replication Status
    [Documentation]    🌐 Retrieve offsite replication configuration and status via API
    [Tags]             critical    offsite_replication    dr    api_collection

    Log    🔍 Collecting offsite replication status...    console=yes

    # Collect offsite replication status
    ${replication_data}=    Collect Offsite Replication Status
    Set Suite Variable    ${REPLICATION_DATA}    ${replication_data}

    ${replication_count}=    Get Length    ${replication_data}
    Should Be True    ${replication_count} > 0    msg=No offsite replication data found

    Log    📊 Offsite replication data collected for ${replication_count} VMs    console=yes
    FOR    ${replication}    IN    @{replication_data}
        Log    📊 VM: ${replication['vm_name']} - Enabled: ${replication['offsite_enabled']}, Target: ${replication['offsite_target']}    console=yes
    END

    Log    ✅ Offsite replication status collection complete    console=yes

Critical - Validate Backup Policy Applied
    [Documentation]    ✅ Validate all VMs have appropriate backup policies applied
    [Tags]             critical    validation    policy_compliance

    Log    🔍 Validating backup policy application...    console=yes

    # Validate policies
    ${policy_results}=    Validate Backup Policy Applied    ${POLICY_DATA}

    # Check for policy violations
    ${violations}=    Get From Dictionary    ${policy_results}    violations
    ${violation_count}=    Get Length    ${violations}

    Log    📊 Policy validation results: ${violation_count} violations found    console=yes

    IF    ${violation_count} > 0
        FOR    ${violation}    IN    @{violations}
            Log    ⚠️ Violation: VM ${violation['vm_name']} - ${violation['reason']}    console=yes
        END
        Fail    Backup policy validation failed: ${violation_count} VMs without proper policies
    END

    Log    ✅ Backup policy validation: All VMs have appropriate policies applied    console=yes

Critical - Validate Schedule Alignment with RPO
    [Documentation]    ✅ Validate backup schedules meet RPO requirements for data criticality
    [Tags]             critical    validation    rpo_compliance

    Log    🔍 Validating backup schedule alignment with RPO requirements...    console=yes

    # Validate schedules against RPO
    ${schedule_results}=    Validate Schedule Alignment With RPO    ${SCHEDULE_DATA}

    # Check for RPO violations
    ${rpo_violations}=    Get From Dictionary    ${schedule_results}    rpo_violations
    ${rpo_violation_count}=    Get Length    ${rpo_violations}

    Log    📊 RPO validation results: ${rpo_violation_count} violations found    console=yes

    IF    ${rpo_violation_count} > 0
        FOR    ${violation}    IN    @{rpo_violations}
            Log    ⚠️ RPO Violation: VM ${violation['vm_name']} - Current: ${violation['current_rpo']}h, Required: ${violation['required_rpo']}h    console=yes
        END
        Fail    RPO validation failed: ${rpo_violation_count} VMs exceed RPO requirements
    END

    Log    ✅ Schedule validation: All backup schedules meet RPO requirements    console=yes

Critical - Validate Retention Settings Compliance
    [Documentation]    ✅ Validate retention settings meet compliance standards
    [Tags]             critical    validation    retention_compliance

    Log    🔍 Validating retention settings compliance...    console=yes
    Log    📋 Minimum daily retention: ${MIN_DAILY_RETENTION} days    console=yes
    Log    📋 Minimum weekly retention: ${MIN_WEEKLY_RETENTION} weeks    console=yes

    # Validate retention policies
    ${retention_results}=    Validate Retention Settings Compliance    ${RETENTION_DATA}

    # Check for retention violations
    ${retention_violations}=    Get From Dictionary    ${retention_results}    violations
    ${retention_violation_count}=    Get Length    ${retention_violations}

    Log    📊 Retention validation results: ${retention_violation_count} violations found    console=yes

    IF    ${retention_violation_count} > 0
        FOR    ${violation}    IN    @{retention_violations}
            Log    ⚠️ Retention Violation: VM ${violation['vm_name']} - ${violation['reason']}    console=yes
        END
        Fail    Retention validation failed: ${retention_violation_count} VMs with insufficient retention
    END

    Log    ✅ Retention validation: All settings meet compliance standards    console=yes

Critical - Validate Recent Job Completion Status
    [Documentation]    ✅ Validate recent backup jobs completed successfully
    [Tags]             critical    validation    job_success

    Log    🔍 Validating recent backup job completion status...    console=yes

    # Validate job completion
    ${job_results}=    Validate Recent Job Completion Status    ${JOB_STATUS}

    # Check for failed jobs
    ${failed_jobs}=    Get From Dictionary    ${job_results}    failed_jobs
    ${failed_count}=    Get Length    ${failed_jobs}

    Log    📊 Job validation results: ${failed_count} failed jobs found    console=yes

    IF    ${failed_count} > 0
        FOR    ${failed}    IN    @{failed_jobs}
            Log    ⚠️ Failed Job: VM ${failed['vm_name']} - Status: ${failed['status']}, Error: ${failed['error_message']}    console=yes
        END
        Fail    Job validation failed: ${failed_count} backup jobs failed
    END

    Log    ✅ Job validation: All recent backup jobs completed successfully    console=yes

Critical - Validate Backup Recency
    [Documentation]    ✅ Validate backups are recent and within acceptable time windows
    [Tags]             critical    validation    backup_recency

    Log    🔍 Validating backup recency...    console=yes
    Log    📋 Maximum backup age: ${MAX_BACKUP_AGE_HOURS} hours    console=yes

    # Validate backup recency
    ${recency_results}=    Validate Backup Recency    ${TIMESTAMP_DATA}

    # Check for stale backups
    ${stale_backups}=    Get From Dictionary    ${recency_results}    stale_backups
    ${stale_count}=    Get Length    ${stale_backups}

    Log    📊 Recency validation results: ${stale_count} stale backups found    console=yes

    IF    ${stale_count} > 0
        FOR    ${stale}    IN    @{stale_backups}
            Log    ⚠️ Stale Backup: VM ${stale['vm_name']} - Last backup: ${stale['last_backup_time']}, Age: ${stale['age_hours']}h    console=yes
        END
        Fail    Recency validation failed: ${stale_count} VMs have stale backups
    END

    Log    ✅ Recency validation: All backups are current and within acceptable time windows    console=yes

Critical - Validate Offsite Replication Configuration
    [Documentation]    ✅ Validate offsite replication is enabled for critical VMs
    [Tags]             critical    validation    offsite_compliance    dr

    Log    🔍 Validating offsite replication configuration...    console=yes

    # Validate offsite replication
    ${replication_results}=    Validate Offsite Replication Configuration    ${REPLICATION_DATA}

    # Check for replication violations
    ${offsite_violations}=    Get From Dictionary    ${replication_results}    violations
    ${offsite_violation_count}=    Get Length    ${offsite_violations}

    Log    📊 Offsite validation results: ${offsite_violation_count} violations found    console=yes

    IF    ${offsite_violation_count} > 0
        FOR    ${violation}    IN    @{offsite_violations}
            Log    ⚠️ Offsite Violation: VM ${violation['vm_name']} - ${violation['reason']}    console=yes
        END
        Fail    Offsite replication validation failed: ${offsite_violation_count} VMs missing offsite protection
    END

    Log    ✅ Offsite validation: Critical VMs have proper offsite replication configured    console=yes

Normal - Comprehensive Backup Compliance Validation
    [Documentation]    🔗 Perform comprehensive validation of all backup compliance aspects
    [Tags]             normal    comprehensive    validation

    Log    🔍 Performing comprehensive backup compliance validation...    console=yes

    # Validate complete backup configuration
    Validate Complete Backup Compliance

    Log    📊 Comprehensive validation summary:    console=yes
    Log    📊 - vCenter API connection: ✅    console=yes
    Log    📊 - Backup policies applied: ✅    console=yes
    Log    📊 - Schedule alignment with RPO: ✅    console=yes
    Log    📊 - Retention settings compliance: ✅    console=yes
    Log    📊 - Recent job completion: ✅    console=yes
    Log    📊 - Backup recency: ✅    console=yes
    Log    📊 - Offsite replication: ✅    console=yes
    Log    ✅ Comprehensive backup compliance validation: PASSED    console=yes
