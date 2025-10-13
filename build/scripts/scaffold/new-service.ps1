# ============= new-service.ps1 =============
param(
    [Parameter(Mandatory=$true)]
    [string]$Service,          # 服务名，例如：movieboot-service
    [Parameter(Mandatory=$true)]
    [string]$Package           # 包名，例如：com.huangyuan.movie
)

$PSDefaultParameterValues['*:Encoding'] = 'utf8NoBom'
$ErrorActionPreference = "Stop"
$Root       = Split-Path -Parent $PSScriptRoot | Split-Path -Parent | Split-Path -Parent
$Template   = Join-Path $Root "code\business\user-service"
$Target     = Join-Path $Root "code\business\$Service"

if (Test-Path $Target) {
    Write-Error "目标服务 $Service 已存在！"
    exit 1
}

# 1. 整体拷贝模板
Write-Host ">>> 拷贝模板..."
Copy-Item -Path $Template -Destination $Target -Recurse

# 2. 拆分旧/新包名、groupId、artifactId
$OldPkg     = "com.huangyuan.user"
$OldGroupId = "com.huangyuan"
$OldArtifact= "user-service"

$NewPkg     = $Package
$NewGroupId = $Package.Substring(0, $Package.LastIndexOf('.'))
$NewArtifact= $Service

# 3. 递归替换文件内容 + 文件名
$oldWord      = 'user'
$newWord      = $Service.Split('-')[0]          # movieboot
$oldWordCap   = (Get-Culture).TextInfo.ToTitleCase($oldWord)  # User
$newWordCap   = (Get-Culture).TextInfo.ToTitleCase($newWord)  # Movie
$excludeSet   = @('.jar','.class','.zip','.jpg','.png','.gif','.ico','.dll','.exe','.bin')

Get-ChildItem $Target -File -Recurse | ForEach-Object {
    # 跳过已知二进制后缀
    if ($excludeSet -contains $_.Extension) { return }

    # 跳过空文件
    if ($_.Length -eq 0) { return }

    $content = Get-Content $_.FullName -Raw -ErrorAction SilentlyContinue
    if ([string]::IsNullOrEmpty($content)) { return }   # 二进制或读不出内容直接跳过

    # ------ 1. 复合类名/变量名（大小写敏感）------
    $content = [regex]::Replace($content, 'User(?=[A-Z])', 'Movie',   'None')  # UserController -> MovieController
    $content = [regex]::Replace($content, 'USER(?=[A-Z])', 'MOVIE',   'None')  # USER_DTO      -> MOVIE_DTO
    $content = [regex]::Replace($content, '\buser\b',       'movie',   'None')  # userService   -> movieService

    # ------ 2. 替换包名、groupId、artifact ------
    $content = $content -replace [regex]::Escape($OldPkg),     $NewPkg
    $content = $content -replace [regex]::Escape($OldGroupId), $NewGroupId
    $content = $content -replace [regex]::Escape($OldArtifact),$NewArtifact

    # 写回文件
    Set-Content -Path $_.FullName -Value $content -NoNewline

    # ------ 4. 文件名替换 ------
    if ($_.Name -match $oldWordCap) {
        $newName = $_.Name -replace $oldWordCap, $newWordCap
        Rename-Item -Path $_.FullName -NewName $newName -Force
    }
}

# 4. 同级改名：com\huangyuan\user*  ->  com\huangyuan\movie*
Get-ChildItem $Target -Dir -Recurse | Where-Object {
    $_.FullName -match 'src\\(main|test)\\java\\com\\huangyuan$'
} | ForEach-Object {
    # 先改父级 user -> movie
    Get-ChildItem $_ -Dir -Filter 'user' | Rename-Item -NewName 'movie' -Force
    # 再改同级 user* -> movie*
    Get-ChildItem $_ -Dir -Filter 'user*' | Rename-Item -NewName { $_.Name -replace '^user', $newWord } -Force
}

# 5. 统一改模块名（文件夹 & pom.xml 里 artifactId 已替换，这里只改目录名）
@('user-boot','user-domain','user-infrastructure','user-interface','user-application') | ForEach-Object {
    $old = Join-Path $Target $_
    $new = $_.Replace('user', $Service.Split('-')[0])
    if (Test-Path $old) { Rename-Item $old $new -Force }
}

# # 6. 复制 Dockerfile / Helm 模板（若模板已存在则跳过）
# $dockerTemplate = Join-Path $Root "build\docker\user-service.Dockerfile"
# $helmTemplate   = Join-Path $Root "build\helm\user-service"
# if (Test-Path $dockerTemplate) {
#     Copy-Item $dockerTemplate (Join-Path $Target "$Service.Dockerfile")
# }
# if (Test-Path $helmTemplate) {
#     Copy-Item $helmTemplate (Join-Path $Target "helm") -Recurse
# }

Write-Host ">>> 完成！新服务已生成：$Target"