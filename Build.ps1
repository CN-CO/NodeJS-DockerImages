param (
    [Parameter(Mandatory=$true)][string]$ImagePrefix,
    [Parameter(Mandatory=$true)][string]$PowerShellImageTag
)

$nodeVersions = [string[]](Get-Content ".\NodeVersions.json" | ConvertFrom-Json)
$dockerFile = Get-Content -Path Dockerfile | Select-Object -Skip 1

if (!(Test-Path -Path "temp" -Type Container)) {
    $null = mkdir "temp"
}

Push-Location temp
Write-Host "Using base PowerShell image: mcr.microsoft.com/powershell:$($PowerShellImageTag)"

# Update Dockerfile with proper tag
.{
    "FROM mcr.microsoft.com/powershell:$($PowerShellImageTag) as installer"
    $dockerFile
} | Set-Content -Path Dockerfile

$nodeVersions.ForEach({
    $nodeVersion = $_
    $tag = "$($ImagePrefix)node:$($nodeVersion)-$($PowerShellImageTag.Replace('lts-',''))"
    Write-Host "Building $tag"

    # Create the Node.JS installer script
    Set-Content -Path "InstallNode.ps1" -Value @"
`$nodejsReleasesUrl = "https://nodejs.org/dist/latest-v$($nodeVersion).x/"
`$response = Invoke-WebRequest -Uri `$nodejsReleasesUrl -UseBasicParsing
`$versions = `$response.Content -split [Environment]::NewLine
`$filteredVersions = `$versions | Where-Object { `$_ -match 'win-x64.zip' -and `$_ -match '<a\s+href="([^"]+)">[^<]+</a>' }
`$latestVersion = `$Matches[1]
`$downloadUrl = "`$nodejsReleasesUrl/`$latestVersion"
Write-Host Downloading Node.JS from: `$downloadUrl
`$downloadPath = Join-Path `$env:TEMP "nodejs.zip"
`$extractionPath = Join-Path $env:TEMP "nodejs"
Invoke-WebRequest -Uri `$downloadUrl -OutFile `$downloadPath
`$null = New-Item -ItemType Directory -Path `$extractionPath
Expand-Archive -Path `$downloadPath -DestinationPath `$extractionPath
`$extractionPath = (Get-ChildItem "`$extractionPath")[0].FullName
Move-Item -Path `$extractionPath -Destination "C:\Program Files\Node.JS" -Force
[Environment]::SetEnvironmentVariable("Path", "`$env:Path;C:\Program Files\Node.JS", [EnvironmentVariableTarget]::Machine)
"@

    docker build -t $tag .
});
Pop-Location

Write-Host "Images built!"