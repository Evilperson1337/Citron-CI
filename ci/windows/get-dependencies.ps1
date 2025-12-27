# ==============================================================================
# Windows Dependency Installation Script
# ==============================================================================
# Installs all required dependencies for building Citron on Windows
# ==============================================================================

param(
    [Parameter(Mandatory=$false)]
    [string]$Arch = "x86_64"
)

Write-Host "========================================"
Write-Host "Installing Windows Dependencies"
Write-Host "Architecture: $Arch"
Write-Host "========================================"

# Install Chocolatey (if not already installed)
if (!(Get-Command choco -ErrorAction SilentlyContinue)) {
    Write-Host "Installing Chocolatey..."
    Set-ExecutionPolicy Bypass -Scope Process -Force
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
}

# Install sccache (ccache alternative for Windows)
Write-Host "Installing sccache..."
choco install sccache -y

# Install Vulkan SDK (version 1.4.335.0)
Write-Host "Installing Vulkan SDK..."
if ($Arch -eq "x86_64") {
    $vulkan_sdk_url = "https://sdk.lunarg.com/sdk/download/1.4.335.0/windows/vulkansdk-windows-X64-1.4.335.0.exe"
} else {
    $vulkan_sdk_url = "https://sdk.lunarg.com/sdk/download/1.4.335.0/warm/vulkansdk-windows-ARM64-1.4.335.0.exe"
}

Invoke-WebRequest -Uri $vulkan_sdk_url -OutFile VulkanSDK-Installer.exe
Start-Process -FilePath ".\VulkanSDK-Installer.exe" -ArgumentList "--accept-licenses", "--default-answer", "--confirm-command", "install" -Wait

# Add Vulkan SDK to PATH (includes glslangValidator)
$vulkanPath = "C:\VulkanSDK\1.4.335.0\Bin"
echo "$vulkanPath" | Out-File -FilePath $env:GITHUB_PATH -Append
$env:PATH = "$vulkanPath;$env:PATH"

Write-Host "========================================"
Write-Host "Dependencies installed successfully!"
Write-Host "========================================"