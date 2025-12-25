# ==============================================================================
# Windows Packaging Script for Citron
# ==============================================================================
# Packages Citron build into a ZIP archive
# ==============================================================================

param(
    [Parameter(Mandatory=$true)]
    [string]$ArtifactBasename,
    
    [Parameter(Mandatory=$false)]
    [string]$Arch = "x86_64"
)

Write-Host "========================================"
Write-Host "Packaging Citron for Windows"
Write-Host "Architecture: $Arch"
Write-Host "Artifact Basename: $ArtifactBasename"
Write-Host "========================================"

# Determine architecture suffix
if ($Arch -eq "x86_64") {
    $archSuffix = "-windows-amd64"
} else {
    $archSuffix = "-windows-arm64"
}

# Create output directory
New-Item -ItemType Directory -Path ".\dist" -Force | Out-Null

# Create temporary package directory
New-Item -ItemType Directory -Path ".\temp_package" -Force | Out-Null

# Copy build artifacts (exclude PDB files like working workflow)
Write-Host "Copying build artifacts..."
Get-ChildItem ".\build\bin\Release\" -Recurse | Where-Object { $_.Extension -ne ".pdb" } | ForEach-Object {
    $relativePath = $_.FullName.Replace((Resolve-Path ".\build\bin\Release\").Path, "").TrimStart('\')
    $destPath = Join-Path ".\temp_package" $relativePath
    $destDir = Split-Path $destPath -Parent
    if (!(Test-Path $destDir)) { New-Item -ItemType Directory -Path $destDir -Force | Out-Null }
    Copy-Item $_.FullName $destPath -Force
}

# Create ZIP archive
$zipName = "$ArtifactBasename$archSuffix.zip"
Write-Host "Creating ZIP archive: $zipName"
Compress-Archive -Path ".\temp_package\*" -DestinationPath ".\dist\$zipName" -Force

# Clean up temporary directory
Remove-Item ".\temp_package" -Recurse -Force

Write-Host "========================================"
Write-Host "Packaging completed successfully!"
Write-Host "Artifact: dist\$zipName"
Write-Host "========================================"