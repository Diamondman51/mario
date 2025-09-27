-------------------------------------------------------------------------------------------------------------

$ErrorActionPreference = 'Stop'

$exeName = "mario.exe"
$repoRawUrl = "https://raw.githubusercontent.com/Diamondman51/mario/main"
$installDir = "$env:USERPROFILE\AppData\Local\Programs\teacher"
$exePath = Join-Path $installDir $exeName

function InstallOrUpdate {
    Write-Host "📦 Установка или обновление $exeName..."

    if (!(Test-Path -Path $installDir)) {
        New-Item -ItemType Directory -Path $installDir | Out-Null
    }

    $downloadUrl = "$repoRawUrl/$exeName"
    $tempPath = Join-Path $env:TEMP $exeName

    # ⚡ Качаем бинарь
    Invoke-WebRequest -Uri $downloadUrl -OutFile $tempPath

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
        Unblock-File -Path $exePath
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


# обновление
function RegisterAutoUpdateTask {
    $taskName = "UpdateMario"
    $scriptPath = $MyInvocation.MyCommand.Definition

    $action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-NoProfile -ExecutionPolicy Bypass -File `"$scriptPath`""
    $trigger = New-ScheduledTaskTrigger -Daily -At 12:00PM
    $settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries

    if (Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue) {
        Unregister-ScheduledTask -TaskName $taskName -Confirm:$false
    }

    Register-ScheduledTask -Action $action -Trigger $trigger -Settings $settings -TaskName $taskName -Description "Auto update for mario.exe" -User $env:USERNAME
    Write-Host "✅ Автообновление настроено (ежедневно в 12:00)"
}




# Запускаем установку / обновление
InstallOrUpdate
# Настраиваем автообновление
RegisterAutoUpdateTask
Start-Process $exePath

-----------------------------------------------------------------------------------------------------------------




# $ErrorActionPreference = 'Stop'

# $exeName = "mario.exe"
# $repoRawUrl = "https://raw.githubusercontent.com/Diamondman51/mario/main"
# $installDir = "$env:USERPROFILE\AppData\Local\Programs\teacher"
# $exePath = "$installDir\$exeName"

# function InstallOrUpdate {
#     Write-Host "📦 Установка или обновление $exeName..."

#     if (!(Test-Path -Path $installDir)) {
#         New-Item -ItemType Directory -Path $installDir | Out-Null
#     }

#     $downloadUrl = "$repoRawUrl/$exeName"
#     $tempPath = "$env:TEMP\$exeName"

#     try {
#         Invoke-WebRequest -Uri $downloadUrl -OutFile $tempPath -UseBasicParsing -ErrorAction Stop
#     } catch {
#         Write-Host "⚠️ Нет доступа к интернету, обновление пропущено"
#         return
#     }

#     $needUpdate = $true
#     if (Test-Path $exePath) {
#         $oldHash = Get-FileHash $exePath -Algorithm SHA256
#         $newHash = Get-FileHash $tempPath -Algorithm SHA256
#         if ($oldHash.Hash -eq $newHash.Hash) {
#             $needUpdate = $false
#             Write-Host "✅ Установлена последняя версия $exeName"
#         }
#     }

#     if ($needUpdate) {
#         Copy-Item -Path $tempPath -Destination $exePath -Force
#         Write-Host "✅ $exeName обновлён"
#     }

#     $envPath = [System.Environment]::GetEnvironmentVariable("Path", "User")
#     if ($envPath -notlike "*$installDir*") {
#         [System.Environment]::SetEnvironmentVariable("Path", "$envPath;$installDir", "User")
#         Write-Host "✅ Путь $installDir добавлен в PATH (для текущего пользователя)"
#     } else {
#         Write-Host "ℹ️ Путь уже в PATH"
#     }
# }

# function RegisterAutoUpdateTask {
#     $taskName = "UpdateMario"
#     $scriptPath = "$installDir\install.ps1"

#     # Действие: скрытый запуск PowerShell
#     $action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File `"$scriptPath`""

#     # Триггеры: ежедневно в 12:00 + при старте Windows
#     $triggerDaily = New-ScheduledTaskTrigger -Daily -At 12:00PM
#     $triggerStartup = New-ScheduledTaskTrigger -AtStartup

#     # Настройки
#     $settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries

#     # Перерегистрация если уже существует
#     if (Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue) {
#         Unregister-ScheduledTask -TaskName $taskName -Confirm:$false
#     }

#     Register-ScheduledTask -Action $action -Trigger @($triggerDaily, $triggerStartup) -Settings $settings -TaskName $taskName -Description "Auto update for mario.exe" -User $env:USERNAME

#     Write-Host "✅ Автообновление настроено (12:00 и при старте Windows, скрыто)"
# }

# # Выполняем установку / обновление
# InstallOrUpdate

# # Настраиваем автообновление
# RegisterAutoUpdateTask

# # 🚀 Запускаем приложение сразу (в скрытом PowerShell ничего мешать не будет)
# Start-Process "$exePath"
