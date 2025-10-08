# Test-20 AV Agent Validation - Mock Mode

## Overview
This directory contains both **real** and **mock** versions of the AV Agent Validation test suite for CIP-007 R3.1 compliance testing.

## Files

### Production Files (Require SSH Access)
- `av_agent_validation.robot` - Main test suite (requires SSH to target machine)
- `av_keywords.resource` - Real keywords that execute SSH commands
- `variables.resource` - Test variables and configuration

### Mock Files (Local Testing)
- `av_agent_validation_mock.robot` - Mock test suite (no SSH required)
- `av_keywords_mock.resource` - Mock keywords that simulate AV agent responses
- `README_MOCK.md` - This file

## Running Tests

### Mock Mode (Local Testing - No SSH Required)
```bash
# Run mock tests locally without any SSH connection
robot tests/test20_av_agent_validation/av_agent_validation_mock.robot

# Run with output directory
robot --outputdir results/test20_mock tests/test20_av_agent_validation/av_agent_validation_mock.robot
```

### Production Mode (Requires SSH Access)
```bash
# Run real tests against actual target machine
robot tests/test20_av_agent_validation/av_agent_validation.robot

# Run with output directory
robot --outputdir results/test20_av_agent_validation tests/test20_av_agent_validation/av_agent_validation.robot
```

## Mock Mode Features

### What Gets Mocked
- ✅ **SSH Connection** - No actual SSH connection established
- ✅ **OS Detection** - Returns current host OS (Windows/Linux/Darwin)
- ✅ **AV Detection** - Always detects "McAfee" as installed
- ✅ **Installation Check** - Always returns True
- ✅ **Service Status** - Always returns Running
- ✅ **Real-Time Protection** - Always returns Enabled
- ✅ **Signature Updates** - Returns current date (always up-to-date)
- ✅ **Scan Schedule** - Returns mock schedule "Daily at 2:00 AM"
- ✅ **Exclusions** - Returns mock exclusion list
- ✅ **Console Reporting** - Returns mock console connection
- ✅ **Screenshots** - Creates text files with mock data

### Mock Data Returned
- **AV Type:** McAfee
- **Version:** 10.7.0.1234
- **Status:** Running
- **RTP:** Enabled
- **Last Update:** Current date (always fresh)
- **Signature Age:** 0 days (always compliant)
- **Console:** Connected to epo-server.company.local

### Expected Test Results
When running in mock mode, all tests should **PASS** because:
- AV agent is "detected" (McAfee)
- Installation is "verified"
- Service is "running"
- Real-time protection is "enabled"
- Signatures are "up-to-date" (0 days old)
- Console reporting is "connected"
- **CIP-007 R3.1 compliance: COMPLIANT**

## Use Cases

### Mock Mode Use Cases
1. **Local Development** - Test suite logic without SSH access
2. **CI/CD Pipeline** - Validate test structure in automated builds
3. **Training** - Demonstrate test flow without production systems
4. **Debugging** - Test framework issues without external dependencies
5. **Documentation** - Generate sample reports

### Production Mode Use Cases
1. **Compliance Audits** - Actual CIP-007 R3.1 validation
2. **Security Assessments** - Real antivirus agent verification
3. **Production Monitoring** - Ongoing compliance checks
4. **Incident Response** - Verify AV protection during incidents

## Switching Between Modes

### To Use Mock Mode
```robot
# In av_agent_validation.robot, change the resource import:
Resource         av_keywords_mock.resource  # Use mock keywords
```

### To Use Production Mode
```robot
# In av_agent_validation.robot, use the original import:
Resource         av_keywords.resource       # Use real SSH keywords
```

### Or Use Separate Test Files
- Run `av_agent_validation_mock.robot` for mock testing
- Run `av_agent_validation.robot` for production testing

## Mock Mode Limitations

### What Mock Mode CANNOT Do
- ❌ Detect actual AV agent issues
- ❌ Verify real service status
- ❌ Check actual signature update dates
- ❌ Validate real console connectivity
- ❌ Provide genuine compliance status

### What Mock Mode CAN Do
- ✅ Validate test suite logic
- ✅ Test report generation
- ✅ Verify test flow and structure
- ✅ Generate sample documentation
- ✅ Debug keyword implementations

## Example Output

### Console Output (Mock Mode)
```
🔧 Initializing AV Test Environment (MOCK MODE)...
⚠️  Running in LOCAL MOCK mode - no SSH connection
✅ Mock environment initialized
🔍 MOCK: Simulating AV detection on Windows...
✅ AV Agent Detected: McAfee
📦 MOCK: Simulating installation verification for McAfee...
✅ AV Agent Installation Verified: McAfee
🔄 MOCK: Simulating service status check for McAfee...
✅ AV Service Running Verified: McAfee
🛡️ MOCK: Simulating real-time protection check for McAfee...
✅ Real-Time Protection Enabled: McAfee
✅ CIP-007 R3.1 COMPLIANT
```

### Generated Files
- **Screenshot:** `results/test20_mock/av_screenshots/McAfee_20241007_120000.txt`
- **Log:** `results/test20_mock/log.html`
- **Report:** `results/test20_mock/report.html`

## Customizing Mock Data

To customize mock responses, edit `av_keywords_mock.resource`:

```robot
# Example: Change detected AV type
Detect AV Agent
    ...
    RETURN    SentinelOne  # Instead of McAfee

# Example: Simulate old signatures
Get Signature Update Status
    ...
    ${sig_info}=    Create Dictionary
    ...    last_update=2024-09-01  # 30+ days old
    ...    version=8888.0
    RETURN    ${sig_info}

# Example: Simulate non-compliant state
Verify Real-Time Protection
    ...
    RETURN    ${False}  # RTP disabled
```

## Best Practices

1. **Use Mock for Development** - Test logic without SSH
2. **Use Production for Audits** - Real compliance validation
3. **Keep Both in Sync** - Update mock when changing production
4. **Document Changes** - Note differences in mock behavior
5. **Version Control** - Track both mock and production files

## Troubleshooting

### Mock Tests Fail
- Check that `av_keywords_mock.resource` is imported
- Verify `${OUTPUT_DIR}` is defined in `variables.resource`
- Ensure write permissions for output directory

### Production Tests Fail
- Verify SSH credentials in `variables.resource`
- Check network connectivity to target machine
- Confirm AV agent is actually installed
- Review firewall rules for SSH access

## Support

For issues or questions:
- Review Robot Framework logs in `results/` directory
- Check keyword implementations in resource files
- Consult CIP-007 R3.1 documentation for requirements
