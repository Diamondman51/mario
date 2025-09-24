$ErrorActionPreference = 'Stop'

$exeName = "mario.exe"
$repoRawUrl = "https://raw.githubusercontent.com/Diamondman51/mario/main"
$installDir = "$env:USERPROFILE\AppData\Local\Programs\teacher"
$exePath = "$installDir\$exeName"

function InstallOrUpdate {
    Write-Host "📦 Установка или обновление $exeName..."

    if (!(Test-Path -Path $installDir)) {
        New-Item -ItemType Directory -Path $installDir | Out-Null
    }

    $downloadUrl = "$repoRawUrl/$exeName"
    $tempPath = "$env:TEMP\$exeName"

    Invoke-WebRequest -Uri $downloadUrl -OutFile $tempPath -UseBasicParsing

    $needUpdate = $true
    if (Test-Path $exePath) {
        $oldHash = Get-FileHash $exePath -Algorithm SHA256
        $newHash = Get-FileHash $tempPath -Algorithm SHA256
        if ($oldHash.Hash -eq $newHash.Hash) {
            $needUpdate = $false
            Write-Host "✅ Установлена последняя версия $exeName"
        }
    }

    if ($needUpdate) {
        Copy-Item -Path $tempPath -Destination $exePath -Force
        Write-Host "✅ $exeName обновлён"
    }

    $envPath = [System.Environment]::GetEnvironmentVariable("Path", "User")
    if ($envPath -notlike "*$installDir*") {
        [System.Environment]::SetEnvironmentVariable("Path", "$envPath;$installDir", "User")
        Write-Host "✅ Путь $installDir добавлен в PATH (для текущего пользователя)"
    } else {
        Write-Host "ℹ️ Путь уже в PATH"
    }
}

# Запускаем установку / обновление
InstallOrUpdate
