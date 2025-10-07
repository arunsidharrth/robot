"""
Datastore Validator Library for Robot Framework
Provides validation capabilities for datastore configurations
"""


class DatastoreValidator:
    """Library for validating datastore configurations"""

    ROBOT_LIBRARY_SCOPE = 'GLOBAL'

    def __init__(self):
        pass

    def datastore_validator_validate_vm_placement(self, vm_assignments, cluster_name):
        """
        Validate VM datastore placement against cluster standards

        Args:
            vm_assignments: List of VM to datastore assignments
            cluster_name: Name of the cluster

        Returns:
            Dictionary with validation results including violations list
        """
        violations = []

        # Stub validation logic - would implement actual rules in production
        # Example: Check if database VMs are on high-performance storage
        for vm in vm_assignments:
            if vm.get('app_type') == 'database' and 'nvme' not in vm.get('datastore', '').lower():
                violations.append({
                    'vm_name': vm['vm_name'],
                    'reason': f"Database VM should be on NVMe storage, found on {vm.get('datastore')}"
                })

        return {
            'violations': violations,
            'total_vms': len(vm_assignments),
            'cluster': cluster_name
        }

    def datastore_validator_validate_capacity(self, capacity_data, min_free_percent):
        """
        Validate datastores have sufficient available capacity

        Args:
            capacity_data: List of datastore capacity information
            min_free_percent: Minimum required free capacity percentage

        Returns:
            Dictionary with validation results including warnings list
        """
        warnings = []

        # Check each datastore against threshold
        for ds in capacity_data:
            free_percent = (ds['free_gb'] / ds['total_gb']) * 100
            if free_percent < min_free_percent:
                warnings.append({
                    'name': ds['name'],
                    'free_percent': round(free_percent, 2),
                    'free_gb': ds['free_gb'],
                    'total_gb': ds['total_gb']
                })

        return {
            'warnings': warnings,
            'total_datastores': len(capacity_data),
            'threshold': min_free_percent
        }

    def datastore_validator_validate_performance_tiers(self, vm_assignments, performance_tiers, vm_app_categories):
        """
        Validate VMs are on appropriate performance tiers

        Args:
            vm_assignments: List of VM to datastore assignments
            performance_tiers: List of datastore performance tier information
            vm_app_categories: Dictionary mapping app types to required performance tiers

        Returns:
            Dictionary with validation results including mismatches list
        """
        mismatches = []

        # Create datastore to tier mapping
        tier_map = {tier['name']: tier['performance_tier'] for tier in performance_tiers}

        # Check each VM against required tier
        for vm in vm_assignments:
            vm_datastore = vm.get('datastore')
            app_type = vm.get('app_type')

            if app_type and app_type in vm_app_categories:
                required_tier = vm_app_categories[app_type]
                current_tier = tier_map.get(vm_datastore, 'UNKNOWN')

                if current_tier != required_tier:
                    mismatches.append({
                        'vm_name': vm['vm_name'],
                        'current_tier': current_tier,
                        'required_tier': required_tier,
                        'datastore': vm_datastore
                    })

        return {
            'mismatches': mismatches,
            'total_vms': len(vm_assignments)
        }

    def datastore_validator_validate_subscription(self, subscription_data, max_ratio):
        """
        Validate datastore subscription ratios

        Args:
            subscription_data: List of datastore subscription information
            max_ratio: Maximum allowed subscription ratio

        Returns:
            Dictionary with validation results including oversubscribed list
        """
        oversubscribed = []

        # Check each datastore against max ratio
        for ds in subscription_data:
            ratio = ds['subscription_ratio']
            if ratio > max_ratio:
                oversubscribed.append({
                    'name': ds['name'],
                    'ratio': ratio,
                    'provisioned_gb': ds['provisioned_gb']
                })

        return {
            'oversubscribed': oversubscribed,
            'total_datastores': len(subscription_data),
            'max_ratio': max_ratio
        }
