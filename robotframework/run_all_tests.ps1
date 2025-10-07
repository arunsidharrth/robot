param(
    [string]$Username,
    [string]$Password,
    [Parameter(Mandatory=$true)]
    [string]$TargetHostname,
    [string]$OutputDir = "results"
)

Write-Host "GSA Itential Robot Framework - Test Runner" -ForegroundColor Cyan

# Get credentials from environment variables if not provided as parameters
if ([string]::IsNullOrEmpty($Username)) {
    $Username = $env:SSH_USERNAME
    if ([string]::IsNullOrEmpty($Username)) {
        Write-Host "ERROR: Username not provided. Set SSH_USERNAME environment variable or use -Username parameter" -ForegroundColor Red
        exit 1
    }
    Write-Host "Using username from environment variable: SSH_USERNAME" -ForegroundColor Yellow
}

if ([string]::IsNullOrEmpty($Password)) {
    $Password = $env:SSH_PASSWORD
    if ([string]::IsNullOrEmpty($Password)) {
        Write-Host "ERROR: Password not provided. Set SSH_PASSWORD environment variable or use -Password parameter" -ForegroundColor Red
        exit 1
    }
    Write-Host "Using password from environment variable: SSH_PASSWORD" -ForegroundColor Yellow
}

# Use python from current environment
$pythonExe = "python"

Write-Host "Using Python: $pythonExe" -ForegroundColor Yellow

# Create results directory
if (!(Test-Path $OutputDir)) {
    New-Item -ItemType Directory -Path $OutputDir | Out-Null
}

# Find all test directories
$testDirs = Get-ChildItem -Path "tests" -Directory | Where-Object { $_.Name -like "test*_*" }

Write-Host "Found test suites: $($testDirs.Count)" -ForegroundColor Yellow

$allOutputFiles = @()

# Run each test suite
foreach ($testDir in $testDirs) {
    $testId = $testDir.Name.Split("_")[0]
    $suiteName = $testDir.Name
    Write-Host "Running $suiteName..." -ForegroundColor Green

    $suiteDir = "$OutputDir/$suiteName"
    $robotFile = Get-ChildItem -Path $testDir.FullName -Filter "*.robot" | Select-Object -First 1
    
    if ($robotFile) {
        # Run the robot test with python -m robot
        Write-Host ""
        & $pythonExe -m robot `
            --variable "SSH_USERNAME:$Username" `
            --variable "SSH_PASSWORD:$Password" `
            --variable "TARGET_HOSTNAME:$TargetHostname" `
            --variable "TEST_SUITE_ID:$testId" `
            --outputdir $suiteDir `
            $robotFile.FullName
        Write-Host ""

        # Collect output file for consolidation
        if (Test-Path "$suiteDir/output.xml") {
            $allOutputFiles += "$suiteDir/output.xml"
        }
    }
}

# Create consolidated reports
if ($allOutputFiles.Count -gt 0) {
    Write-Host "Creating consolidated reports..." -ForegroundColor Cyan
    
    try {
        Write-Host ""
        & $pythonExe -m robot.rebot `
            --outputdir $OutputDir `
            --output all_output.xml `
            --log all_log.html `
            --report all_report.html `
            $allOutputFiles
        Write-Host ""
        Write-Host "Consolidated reports created" -ForegroundColor Green
    }
    catch {
        Write-Host "Warning: Could not create consolidated reports" -ForegroundColor Yellow
    }
}

Write-Host "Tests completed!" -ForegroundColor Green
Write-Host "Results in: $OutputDir" -ForegroundColor Yellow