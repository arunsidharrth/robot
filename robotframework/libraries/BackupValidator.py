"""
Backup Validator Library for Robot Framework
Provides validation capabilities for backup configurations and compliance
"""

from datetime import datetime, timedelta


class BackupValidator:
    """Library for validating backup configurations"""

    ROBOT_LIBRARY_SCOPE = 'GLOBAL'

    def __init__(self):
        pass

    def backup_validator_validate_policies(self, policy_data, target_vms):
        """
        Validate all VMs have backup policies applied

        Args:
            policy_data: List of VM backup policy information
            target_vms: List of target VM names

        Returns:
            Dictionary with validation results including violations list
        """
        violations = []

        # Create VM to policy mapping
        vm_policy_map = {policy['vm_name']: policy for policy in policy_data}

        # Check each target VM
        for vm in target_vms:
            if vm not in vm_policy_map:
                violations.append({
                    'vm_name': vm,
                    'reason': 'No backup policy found for VM'
                })
            elif not vm_policy_map[vm].get('policy_applied'):
                violations.append({
                    'vm_name': vm,
                    'reason': f"Backup policy not applied (Policy: {vm_policy_map[vm].get('policy_name', 'None')})"
                })
            elif vm_policy_map[vm].get('policy_name') == 'None':
                violations.append({
                    'vm_name': vm,
                    'reason': 'VM has no backup policy assigned'
                })

        return {
            'violations': violations,
            'total_vms': len(target_vms),
            'compliant_vms': len(target_vms) - len(violations)
        }

    def backup_validator_validate_rpo_alignment(self, schedule_data, vm_criticality, rpo_requirements):
        """
        Validate backup schedules meet RPO requirements

        Args:
            schedule_data: List of backup schedule information
            vm_criticality: Dictionary mapping VMs to criticality levels
            rpo_requirements: Dictionary mapping criticality to RPO hours

        Returns:
            Dictionary with validation results including RPO violations
        """
        rpo_violations = []

        # Create VM to schedule mapping
        vm_schedule_map = {schedule['vm_name']: schedule for schedule in schedule_data}

        # Check each VM's RPO
        for vm_name, criticality in vm_criticality.items():
            required_rpo = rpo_requirements.get(criticality, 24)

            if vm_name not in vm_schedule_map:
                rpo_violations.append({
                    'vm_name': vm_name,
                    'current_rpo': None,
                    'required_rpo': required_rpo,
                    'criticality': criticality,
                    'reason': 'No backup schedule found'
                })
                continue

            current_rpo = vm_schedule_map[vm_name].get('rpo_hours', 0)

            if current_rpo > required_rpo:
                rpo_violations.append({
                    'vm_name': vm_name,
                    'current_rpo': current_rpo,
                    'required_rpo': required_rpo,
                    'criticality': criticality,
                    'reason': f'RPO exceeds requirement ({current_rpo}h > {required_rpo}h)'
                })

        return {
            'rpo_violations': rpo_violations,
            'total_vms': len(vm_criticality),
            'compliant_vms': len(vm_criticality) - len(rpo_violations)
        }

    def backup_validator_validate_retention_compliance(self, retention_data, min_daily, min_weekly, min_monthly):
        """
        Validate retention settings meet compliance standards

        Args:
            retention_data: List of retention policy information
            min_daily: Minimum daily retention required
            min_weekly: Minimum weekly retention required
            min_monthly: Minimum monthly retention required

        Returns:
            Dictionary with validation results including violations
        """
        violations = []

        for retention in retention_data:
            vm_name = retention['vm_name']
            daily = retention.get('daily_retention', 0)
            weekly = retention.get('weekly_retention', 0)
            monthly = retention.get('monthly_retention', 0)

            reasons = []
            if daily < min_daily:
                reasons.append(f'Daily retention {daily} < {min_daily} required')
            if weekly < min_weekly:
                reasons.append(f'Weekly retention {weekly} < {min_weekly} required')
            if monthly < min_monthly:
                reasons.append(f'Monthly retention {monthly} < {min_monthly} required')

            if reasons:
                violations.append({
                    'vm_name': vm_name,
                    'daily_retention': daily,
                    'weekly_retention': weekly,
                    'monthly_retention': monthly,
                    'reason': '; '.join(reasons)
                })

        return {
            'violations': violations,
            'total_vms': len(retention_data),
            'compliant_vms': len(retention_data) - len(violations)
        }

    def backup_validator_validate_job_status(self, job_status):
        """
        Validate recent backup jobs completed successfully

        Args:
            job_status: List of recent backup job information

        Returns:
            Dictionary with validation results including failed jobs
        """
        failed_jobs = []
        vm_latest_jobs = {}

        # Get latest job per VM
        for job in job_status:
            vm_name = job['vm_name']
            job_time = datetime.strptime(job['end_time'], '%Y-%m-%d %H:%M:%S')

            if vm_name not in vm_latest_jobs or job_time > datetime.strptime(vm_latest_jobs[vm_name]['end_time'], '%Y-%m-%d %H:%M:%S'):
                vm_latest_jobs[vm_name] = job

        # Check for failures
        for vm_name, job in vm_latest_jobs.items():
            if job['status'] != 'Success':
                failed_jobs.append({
                    'vm_name': vm_name,
                    'job_id': job['job_id'],
                    'status': job['status'],
                    'end_time': job['end_time'],
                    'error_message': job.get('error_message', 'Unknown error')
                })

        return {
            'failed_jobs': failed_jobs,
            'total_jobs': len(job_status),
            'successful_jobs': len(job_status) - len(failed_jobs)
        }

    def backup_validator_validate_backup_recency(self, timestamp_data, max_age_hours):
        """
        Validate backups are recent and within acceptable time windows

        Args:
            timestamp_data: List of latest backup timestamp information
            max_age_hours: Maximum acceptable backup age in hours

        Returns:
            Dictionary with validation results including stale backups
        """
        stale_backups = []
        now = datetime.now()

        for timestamp in timestamp_data:
            vm_name = timestamp['vm_name']
            last_backup_str = timestamp['last_backup_time']
            last_backup = datetime.strptime(last_backup_str, '%Y-%m-%d %H:%M:%S')

            age = now - last_backup
            age_hours = age.total_seconds() / 3600

            if age_hours > max_age_hours:
                stale_backups.append({
                    'vm_name': vm_name,
                    'last_backup_time': last_backup_str,
                    'age_hours': round(age_hours, 2),
                    'max_age_hours': max_age_hours,
                    'reason': f'Backup is {round(age_hours, 2)}h old (exceeds {max_age_hours}h threshold)'
                })

        return {
            'stale_backups': stale_backups,
            'total_vms': len(timestamp_data),
            'current_backups': len(timestamp_data) - len(stale_backups)
        }

    def backup_validator_validate_offsite_replication(self, replication_data, offsite_required_vms):
        """
        Validate offsite replication is enabled for critical VMs

        Args:
            replication_data: List of offsite replication status information
            offsite_required_vms: List of VMs that require offsite replication

        Returns:
            Dictionary with validation results including violations
        """
        violations = []

        # Create VM to replication mapping
        vm_replication_map = {rep['vm_name']: rep for rep in replication_data}

        # Check each VM that requires offsite replication
        for vm in offsite_required_vms:
            if vm not in vm_replication_map:
                violations.append({
                    'vm_name': vm,
                    'reason': 'No offsite replication configuration found'
                })
            elif not vm_replication_map[vm].get('offsite_enabled'):
                violations.append({
                    'vm_name': vm,
                    'reason': 'Offsite replication is not enabled (required for critical VM)'
                })
            elif vm_replication_map[vm].get('replication_status') != 'Healthy':
                violations.append({
                    'vm_name': vm,
                    'reason': f"Offsite replication status is {vm_replication_map[vm].get('replication_status')} (expected: Healthy)"
                })

        return {
            'violations': violations,
            'total_required_vms': len(offsite_required_vms),
            'compliant_vms': len(offsite_required_vms) - len(violations)
        }
