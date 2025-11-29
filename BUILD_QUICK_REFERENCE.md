# 快速构建命令参考

## 一键构建所有版本

```bash
chmod +x build-all-versions.sh
./build-all-versions.sh
```

或者用 Gradle 直接执行：
```bash
gradle clean buildPlugin -PideaVersion=2023.1 -PbuildSuffix=231 -x test -x buildSearchableOptions -x jarSearchableOptions && \
gradle clean buildPlugin -PideaVersion=2024.1 -PbuildSuffix=241 -x test -x buildSearchableOptions -x jarSearchableOptions && \
gradle clean buildPlugin -PideaVersion=2025.2 -PbuildSuffix=252 -x test -x buildSearchableOptions -x jarSearchableOptions
```

## 单个版本构建

### 仅构建 2023.1（后缀 231）
```bash
gradle clean buildPlugin -PideaVersion=2023.1 -PbuildSuffix=231 -x test -x buildSearchableOptions -x jarSearchableOptions
```
输出：`build/distributions/chinese-folder-annotator-231.zip`

### 仅构建 2024.1（后缀 241）
```bash
gradle clean buildPlugin -PideaVersion=2024.1 -PbuildSuffix=241 -x test -x buildSearchableOptions -x jarSearchableOptions
```
输出：`build/distributions/chinese-folder-annotator-241.zip`

### 仅构建 2025.2（后缀 252）
```bash
gradle clean buildPlugin -PideaVersion=2025.2 -PbuildSuffix=252 -x test -x buildSearchableOptions -x jarSearchableOptions
```
输出：`build/distributions/chinese-folder-annotator-252.zip`

## 使用脚本快速构建指定版本

```bash
./build-all-versions.sh 2024.1    # 只构建 2024.1
./build-all-versions.sh 2023.1    # 只构建 2023.1
./build-all-versions.sh 2025.2    # 只构建 2025.2
```

## 构建参数说明

| 参数 | 说明 | 必需 |
|------|------|------|
| `-PideaVersion=<版本>` | IntelliJ IDEA 版本号（如 2023.1）| ✓ |
| `-PbuildSuffix=<后缀>` | 输出 ZIP 的版本后缀（如 231）| ✓ |
| `-x test` | 跳过测试 | ✗ |
| `-x buildSearchableOptions` | 跳过可搜索选项构建 | ✗ |
| `-x jarSearchableOptions` | 跳过 JAR 可搜索选项 | ✗ |
| `--warning-mode all` | 显示所有警告 | ✗ |

## 构建输出位置

所有生成的插件 ZIP 文件都在：
```
build/distributions/
├── chinese-folder-annotator-231.zip  (2023.1)
├── chinese-folder-annotator-241.zip  (2024.1)
└── chinese-folder-annotator-252.zip  (2025.2)
```

## 安装插件

对于任何版本的 IntelliJ IDEA，使用对应的 ZIP 文件：

1. 打开 IntelliJ IDEA
2. Settings/Preferences → Plugins
3. 右上角 ⚙️ 菜单 → Install Plugin from Disk...
4. 选择对应版本的 ZIP 文件（如 `chinese-folder-annotator-241.zip`）
5. 重启 IDE

## 扩展到更多版本

编辑 `build-all-versions.sh`，在 `VERSIONS` 数组中添加新版本：

```bash
declare -A VERSIONS=(
    ["2023.1"]="231"
    ["2024.1"]="241"
    ["2025.2"]="252"
    ["2025.3"]="253"    # 新增
)
```

## 清理构建缓存

```bash
gradle clean                    # 清理本地构建目录
gradle cleanIdea                # 清理 IDE 相关缓存
rm -rf build/                   # 删除整个 build 目录
```

## 环境要求

- Java 17+（项目配置要求）
- Gradle 8.1+（包含在项目中）
- 网络连接（首次构建需下载 IntelliJ SDK）

## 故障排查

### 构建失败：GradleWrapperMain 类未找到
```bash
# 使用系统 Gradle 而不是 wrapper
gradle clean buildPlugin -PideaVersion=2023.1 -PbuildSuffix=231 ...
```

### Java 版本不兼容
```bash
java -version
# 确保 Java 17+ 版本
```

### 下载 SDK 超时
```bash
# 增加 Gradle 超时时间
gradle -Dorg.gradle.internal.http.socketTimeout=120000 buildPlugin -PideaVersion=2023.1 -PbuildSuffix=231
```
