#!/bin/bash
set -e

# 多版本构建脚本 - 使用 Gradle Wrapper 8.1
# 用法: 
#   ./build-all-versions.sh          - 构建所有版本（2023.1 → 231, 2024.1 → 241, 2025.2 → 252）
#   ./build-all-versions.sh 2023.1   - 仅构建指定版本

export JAVA_HOME=/usr/local/sdkman/candidates/java/17.0.17-ms
export PATH=$JAVA_HOME/bin:$PATH

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$PROJECT_DIR"

# 确保 gradlew 可执行
chmod +x gradlew

# 定义版本映射
declare -A VERSIONS=(
    ["2023.1"]="231"
    ["2024.1"]="241"
    ["2025.2"]="252"
)

# 输出配置
OUTPUT_DIR="build/distributions"
mkdir -p "$OUTPUT_DIR"

echo "=========================================="
echo "IntelliJ IDEA 插件多版本构建脚本"
echo "=========================================="
echo ""
echo "环境信息："
echo "  Java: $(java -version 2>&1 | head -1)"
echo "  Gradle: $(./gradlew --version 2>&1 | head -1)"
echo ""

# 如果提供了参数，则仅构建指定版本
if [ $# -gt 0 ]; then
    SPECIFIC_VERSION="$1"
    if [ -z "${VERSIONS[$SPECIFIC_VERSION]}" ]; then
        echo "❌ 错误：不支持的版本 $SPECIFIC_VERSION"
        echo ""
        echo "支持的版本："
        for v in "${!VERSIONS[@]}"; do
            echo "  - $v (${VERSIONS[$v]})"
        done
        exit 1
    fi
    
    suffix="${VERSIONS[$SPECIFIC_VERSION]}"
    echo "正在构建 IDEA $SPECIFIC_VERSION (后缀: $suffix)..."
    
    ./gradlew clean buildPlugin \
        -PideaVersion="$SPECIFIC_VERSION" \
        -PbuildSuffix="$suffix" \
        -x test \
        -x buildSearchableOptions \
        -x jarSearchableOptions
    
    echo "✓ $SPECIFIC_VERSION 版本构建完成"
else
    # 遍历所有版本
    for version in "${!VERSIONS[@]}"; do
        suffix="${VERSIONS[$version]}"
        echo "正在构建 IDEA $version (后缀: $suffix)..."
        
        # 执行构建
        ./gradlew clean buildPlugin \
            -PideaVersion="$version" \
            -PbuildSuffix="$suffix" \
            -x test \
            -x buildSearchableOptions \
            -x jarSearchableOptions
        
        echo "✓ $version 版本构建完成"
        echo ""
    done
    
    echo "=========================================="
    echo "所有版本构建完成！"
    echo "=========================================="
fi

echo ""
echo "生成的文件位于: $OUTPUT_DIR"
ls -lh "$OUTPUT_DIR"/*.zip 2>/dev/null || echo "未找到 ZIP 文件"
