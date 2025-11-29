@echo off
REM 多版本构建脚本（Windows）
REM 用法: build-all-versions.bat

setlocal enabledelayedexpansion

echo ==========================================
echo 开始构建多个 IntelliJ IDEA 版本的插件
echo ==========================================
echo.

REM 定义版本数组（Windows 批处理没有关联数组，使用并行的数组）
set "versions[0]=2023.1"
set "suffixes[0]=231"

set "versions[1]=2024.1"
set "suffixes[1]=241"

set "versions[2]=2025.2"
set "suffixes[2]=252"

REM 输出目录
set "OUTPUT_DIR=build\distributions"
if not exist "%OUTPUT_DIR%" mkdir "%OUTPUT_DIR%"

REM 遍历所有版本
for /l %%i in (0,1,2) do (
    set "version=!versions[%%i]!"
    set "suffix=!suffixes[%%i]!"
    
    echo 正在构建 IDEA !version! (后缀: !suffix!)...
    
    REM 执行构建
    call gradlew.bat clean buildPlugin ^
        -PideaVersion="!version!" ^
        -PbuildSuffix="!suffix!" ^
        -x test ^
        -x buildSearchableOptions ^
        -x jarSearchableOptions ^
        --warning-mode all
    
    if errorlevel 1 (
        echo ✗ !version! 版本构建失败
        exit /b 1
    )
    
    echo ✓ !version! 版本构建完成
    echo.
)

echo ==========================================
echo 所有版本构建完成！
echo ==========================================
echo.
echo 生成的文件位于: %OUTPUT_DIR%
dir "%OUTPUT_DIR%\*.zip"

pause
