"""
vCenter API Library for Robot Framework
Provides VM configuration retrieval from VMware vCenter using REST API
"""

import requests
import json
import urllib3
from robot.api.logger import info, warn, error

# Disable SSL warnings for self-signed certificates
urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)


class VCenterAPI:
    """Library to interact with vCenter API and retrieve VM configuration data"""

    def __init__(self):
        self.session = None
        self.vcenter_host = None
        self.api_session_id = None

    def connect_to_vcenter(self, vcenter_host, username, password):
        """
        Establish API connection to VMware vCenter

        Args:
            vcenter_host: vCenter server hostname or IP
            username: vCenter username
            password: vCenter password
        """
        try:
            self.vcenter_host = vcenter_host
            base_url = f"https://{vcenter_host}/rest/com/vmware/cis/session"

            info(f"Connecting to vCenter API at {vcenter_host}...")

            # Create session
            response = requests.post(
                base_url,
                auth=(username, password),
                verify=False,
                headers={'Content-Type': 'application/json'}
            )

            if response.status_code == 200:
                self.api_session_id = response.json()['value']
                info(f"Successfully connected to vCenter API")
                return self.api_session_id
            else:
                error(f"Failed to connect to vCenter: {response.status_code} - {response.text}")
                raise RuntimeError(f"vCenter authentication failed: {response.status_code}")

        except Exception as e:
            error(f"Error connecting to vCenter: {str(e)}")
            raise RuntimeError(f"Failed to connect to vCenter API: {str(e)}")

    def find_vm_by_name(self, vm_name):
        """
        Find VM by name and return VM ID

        Args:
            vm_name: Name of the VM to find

        Returns:
            VM ID (moref)
        """
        try:
            if not self.api_session_id:
                raise RuntimeError("Not connected to vCenter. Call connect_to_vcenter first.")

            url = f"https://{self.vcenter_host}/rest/vcenter/vm"
            headers = {
                'vmware-api-session-id': self.api_session_id,
                'Content-Type': 'application/json'
            }

            # Filter by VM name
            params = {'filter.names': vm_name}

            info(f"Searching for VM: {vm_name}")
            response = requests.get(url, headers=headers, params=params, verify=False)

            if response.status_code == 200:
                vms = response.json().get('value', [])
                if vms:
                    vm_id = vms[0]['vm']
                    info(f"Found VM '{vm_name}' with ID: {vm_id}")
                    return vm_id
                else:
                    error(f"VM '{vm_name}' not found in vCenter")
                    raise ValueError(f"VM '{vm_name}' not found")
            else:
                error(f"Failed to search for VM: {response.status_code} - {response.text}")
                raise RuntimeError(f"VM search failed: {response.status_code}")

        except Exception as e:
            error(f"Error finding VM: {str(e)}")
            raise

    def get_vm_configuration(self, vm_id):
        """
        Retrieve comprehensive VM configuration data

        Args:
            vm_id: VM identifier (moref)

        Returns:
            Dictionary with VM configuration details
        """
        try:
            if not self.api_session_id:
                raise RuntimeError("Not connected to vCenter. Call connect_to_vcenter first.")

            url = f"https://{self.vcenter_host}/rest/vcenter/vm/{vm_id}"
            headers = {
                'vmware-api-session-id': self.api_session_id,
                'Content-Type': 'application/json'
            }

            info(f"Retrieving VM configuration for VM ID: {vm_id}")
            response = requests.get(url, headers=headers, verify=False)

            if response.status_code == 200:
                vm_data = response.json().get('value', {})

                # Extract key configuration data
                config = {
                    'name': vm_data.get('name', 'N/A'),
                    'power_state': vm_data.get('power_state', 'N/A'),
                    'cpu_count': vm_data.get('cpu', {}).get('count', 'N/A'),
                    'cores_per_socket': vm_data.get('cpu', {}).get('cores_per_socket', 'N/A'),
                    'memory_size_mb': vm_data.get('memory', {}).get('size_MiB', 'N/A'),
                    'memory_size_gb': round(vm_data.get('memory', {}).get('size_MiB', 0) / 1024, 2),
                    'hardware_version': vm_data.get('hardware', {}).get('version', 'N/A'),
                    'guest_os': vm_data.get('guest_OS', 'N/A'),
                    'boot_devices': vm_data.get('boot', {}).get('type', 'N/A')
                }

                info(f"VM Configuration retrieved: {json.dumps(config, indent=2)}")
                return config
            else:
                error(f"Failed to get VM configuration: {response.status_code} - {response.text}")
                raise RuntimeError(f"VM configuration retrieval failed: {response.status_code}")

        except Exception as e:
            error(f"Error retrieving VM configuration: {str(e)}")
            raise

    def get_vm_cluster_placement(self, vm_id):
        """
        Get the cluster placement information for a VM

        Args:
            vm_id: VM identifier (moref)

        Returns:
            Dictionary with cluster information
        """
        try:
            if not self.api_session_id:
                raise RuntimeError("Not connected to vCenter. Call connect_to_vcenter first.")

            # First get the host where VM is running
            url = f"https://{self.vcenter_host}/rest/vcenter/vm/{vm_id}"
            headers = {
                'vmware-api-session-id': self.api_session_id,
                'Content-Type': 'application/json'
            }

            response = requests.get(url, headers=headers, verify=False)

            if response.status_code == 200:
                vm_data = response.json().get('value', {})
                host_id = vm_data.get('host', 'N/A')

                # Get cluster information from host
                if host_id != 'N/A':
                    host_url = f"https://{self.vcenter_host}/rest/vcenter/host/{host_id}"
                    host_response = requests.get(host_url, headers=headers, verify=False)

                    if host_response.status_code == 200:
                        host_data = host_response.json().get('value', {})

                        cluster_info = {
                            'cluster_id': host_data.get('cluster', 'N/A'),
                            'host_id': host_id,
                            'host_name': host_data.get('name', 'N/A')
                        }

                        info(f"VM Cluster Placement: {json.dumps(cluster_info, indent=2)}")
                        return cluster_info

            return {'cluster_id': 'N/A', 'host_id': 'N/A', 'host_name': 'N/A'}

        except Exception as e:
            error(f"Error retrieving cluster placement: {str(e)}")
            raise

    def get_vm_network_adapters(self, vm_id):
        """
        Get network adapter configuration for a VM

        Args:
            vm_id: VM identifier (moref)

        Returns:
            List of network adapter configurations
        """
        try:
            if not self.api_session_id:
                raise RuntimeError("Not connected to vCenter. Call connect_to_vcenter first.")

            url = f"https://{self.vcenter_host}/rest/vcenter/vm/{vm_id}/hardware/ethernet"
            headers = {
                'vmware-api-session-id': self.api_session_id,
                'Content-Type': 'application/json'
            }

            info(f"Retrieving network adapters for VM ID: {vm_id}")
            response = requests.get(url, headers=headers, verify=False)

            if response.status_code == 200:
                adapters = response.json().get('value', [])

                adapter_list = []
                for adapter in adapters:
                    adapter_info = {
                        'label': adapter.get('label', 'N/A'),
                        'type': adapter.get('type', 'N/A'),
                        'mac_address': adapter.get('mac_address', 'N/A'),
                        'backing_type': adapter.get('backing', {}).get('type', 'N/A'),
                        'network_name': adapter.get('backing', {}).get('network_name', 'N/A')
                    }
                    adapter_list.append(adapter_info)

                info(f"Network Adapters: {json.dumps(adapter_list, indent=2)}")
                return adapter_list
            else:
                warn(f"Failed to get network adapters: {response.status_code}")
                return []

        except Exception as e:
            error(f"Error retrieving network adapters: {str(e)}")
            return []

    def get_vm_disk_configuration(self, vm_id):
        """
        Get disk configuration for a VM

        Args:
            vm_id: VM identifier (moref)

        Returns:
            List of disk configurations
        """
        try:
            if not self.api_session_id:
                raise RuntimeError("Not connected to vCenter. Call connect_to_vcenter first.")

            url = f"https://{self.vcenter_host}/rest/vcenter/vm/{vm_id}/hardware/disk"
            headers = {
                'vmware-api-session-id': self.api_session_id,
                'Content-Type': 'application/json'
            }

            info(f"Retrieving disk configuration for VM ID: {vm_id}")
            response = requests.get(url, headers=headers, verify=False)

            if response.status_code == 200:
                disks = response.json().get('value', [])

                disk_list = []
                for disk in disks:
                    disk_info = {
                        'label': disk.get('label', 'N/A'),
                        'capacity_gb': round(disk.get('capacity', 0) / (1024**3), 2),
                        'type': disk.get('type', 'N/A'),
                        'backing_type': disk.get('backing', {}).get('type', 'N/A')
                    }
                    disk_list.append(disk_info)

                info(f"Disk Configuration: {json.dumps(disk_list, indent=2)}")
                return disk_list
            else:
                warn(f"Failed to get disk configuration: {response.status_code}")
                return []

        except Exception as e:
            error(f"Error retrieving disk configuration: {str(e)}")
            return []

    def get_vm_comprehensive_details(self, vm_name):
        """
        Get all comprehensive VM details including cluster, config, network, and disks

        Args:
            vm_name: Name of the VM

        Returns:
            Dictionary with all VM details
        """
        try:
            # Find VM by name
            vm_id = self.find_vm_by_name(vm_name)

            # Collect all information
            details = {
                'vm_id': vm_id,
                'vm_name': vm_name,
                'configuration': self.get_vm_configuration(vm_id),
                'cluster_placement': self.get_vm_cluster_placement(vm_id),
                'network_adapters': self.get_vm_network_adapters(vm_id),
                'disk_configuration': self.get_vm_disk_configuration(vm_id)
            }

            info(f"Comprehensive VM Details collected for '{vm_name}'")
            return details

        except Exception as e:
            error(f"Error collecting comprehensive VM details: {str(e)}")
            raise

    def disconnect_from_vcenter(self):
        """Disconnect from vCenter API by deleting the session"""
        try:
            if self.api_session_id:
                url = f"https://{self.vcenter_host}/rest/com/vmware/cis/session"
                headers = {
                    'vmware-api-session-id': self.api_session_id,
                    'Content-Type': 'application/json'
                }

                requests.delete(url, headers=headers, verify=False)
                info("Disconnected from vCenter API")
                self.api_session_id = None
        except Exception as e:
            warn(f"Error disconnecting from vCenter: {str(e)}")
