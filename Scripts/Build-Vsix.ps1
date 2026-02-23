param(
    [string]$Configuration = "Release",
    [string]$VsixOutputPath = (Join-Path $PSScriptRoot "..\GitFlow.VS.Extension\bin\Release\net48")
)

$repoRoot = Resolve-Path (Join-Path $PSScriptRoot "..")
$projectPath = Join-Path $repoRoot "GitFlow.VS.Extension\GitFlow.VS.Extension.csproj"

$vswhere = Join-Path ${env:ProgramFiles(x86)} "Microsoft Visual Studio\Installer\vswhere.exe"
if (-not (Test-Path $vswhere)) {
    throw "vswhere.exe not found. Install Visual Studio or the VS Build Tools."
}

$msbuild = & $vswhere -latest -requires Microsoft.Component.MSBuild -find MSBuild\Current\Bin\MSBuild.exe
if (-not $msbuild) {
    throw "MSBuild.exe not found. Ensure the Visual Studio Build Tools are installed."
}

if (-not (Test-Path $VsixOutputPath)) {
    New-Item -ItemType Directory -Path $VsixOutputPath -Force | Out-Null
}

& $msbuild $projectPath /t:Build /t:CreateVsixContainer /p:Configuration=$Configuration /p:CreateVsixContainer=true /p:DeployExtension=false
if ($LASTEXITCODE -ne 0) {
    exit $LASTEXITCODE
}

$vsixRoot = Join-Path $repoRoot "GitFlow.VS.Extension\bin"
$vsix = Get-ChildItem -Path $vsixRoot -Filter *.vsix -Recurse | Sort-Object LastWriteTime -Descending | Select-Object -First 1
if (-not $vsix) {
    throw "VSIX not found in $vsixRoot"
}

Write-Host "VSIX built: $($vsix.FullName)"
