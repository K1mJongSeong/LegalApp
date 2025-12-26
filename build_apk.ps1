# Flutter APK Build Script
# APK 경로 문제를 자동으로 해결합니다

param(
    [switch]$Release,
    [switch]$Clean
)

$buildType = if ($Release) { "release" } else { "debug" }
$apkName = "app-$buildType.apk"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Flutter APK Build Script" -ForegroundColor Cyan
Write-Host "  Build Type: $buildType" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

# Clean if requested
if ($Clean) {
    Write-Host "`n[1/4] Cleaning project..." -ForegroundColor Yellow
    flutter clean
}

# Get dependencies
Write-Host "`n[2/4] Getting dependencies..." -ForegroundColor Yellow
flutter pub get

# Build APK
Write-Host "`n[3/4] Building APK ($buildType)..." -ForegroundColor Yellow
if ($Release) {
    flutter build apk --release 2>&1 | Out-Null
} else {
    flutter build apk --debug 2>&1 | Out-Null
}

# Check if APK was generated
$sourcePath = "android\app\build\outputs\flutter-apk\$apkName"
$destDir = "build\app\outputs\flutter-apk"
$destPath = "$destDir\$apkName"

if (Test-Path $sourcePath) {
    # Create destination directory if needed
    if (!(Test-Path $destDir)) {
        New-Item -ItemType Directory -Force -Path $destDir | Out-Null
    }
    
    # Copy APK to expected location
    Copy-Item $sourcePath -Destination $destPath -Force
    
    $fileSize = [math]::Round((Get-Item $sourcePath).Length / 1MB, 2)
    
    Write-Host "`n[4/4] Build completed successfully!" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green
    Write-Host "  APK Location:" -ForegroundColor White
    Write-Host "  $destPath" -ForegroundColor Cyan
    Write-Host "  Size: $fileSize MB" -ForegroundColor White
    Write-Host "========================================" -ForegroundColor Green
} else {
    Write-Host "`n[ERROR] APK not found at: $sourcePath" -ForegroundColor Red
    Write-Host "Build may have failed. Check the error messages above." -ForegroundColor Red
    exit 1
}



