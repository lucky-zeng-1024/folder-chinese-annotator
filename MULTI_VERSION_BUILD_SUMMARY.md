# 多版本构建配置 - 实现总结

本文档总结了如何配置项目支持为多个 IntelliJ IDEA 版本构建插件。

## ✅ 已完成的更改

### 1. 修改 `build.gradle.kts`

**增加版本参数支持：**
```kotlin
// 支持多版本构建
val ideaVersion = providers.gradleProperty("ideaVersion").orNull ?: "2023.1"
val buildSuffix = providers.gradleProperty("buildSuffix").orNull

intellij {
    type.set("IC")
    version.set(ideaVersion)  // 使用参数指定版本
    // ...
}
```

**增加后缀重命名逻辑：**
```kotlin
tasks {
    buildPlugin {
        doLast {
            // 为生成的 ZIP 文件添加版本后缀
            if (buildSuffix != null && buildSuffix.isNotBlank()) {
                // 文件重命名逻辑
            }
        }
    }
}
```

### 2. 更新 `gradle.properties`

已注释掉硬编码的本地路径，支持通过命令行参数传入：
```properties
# intellij.localPath=D:/JetBrains/IntelliJ IDEA 2025.2
# ideaVersion=2023.1
# buildSuffix=231
org.gradle.jvmargs=-Xmx2g -Dfile.encoding=UTF-8
```

### 3. 创建 `build-all-versions.sh` (Linux/macOS)

一键构建所有版本的 Bash 脚本，支持：
- 构建所有版本：`./build-all-versions.sh`
- 构建特定版本：`./build-all-versions.sh 2024.1`

### 4. 创建 `build-all-versions.bat` (Windows)

Windows 批处理脚本，实现相同功能。

### 5. 创建文档

- `BUILD_MULTIPLE_VERSIONS.md` - 详细的多版本构建指南
- `BUILD_QUICK_REFERENCE.md` - 快速参考和常用命令

## 🚀 使用方式

### 最简单的方式：执行脚本

```bash
chmod +x build-all-versions.sh
./build-all-versions.sh
```

这会依次构建：
- 2023.1 → `chinese-folder-annotator-231.zip`
- 2024.1 → `chinese-folder-annotator-241.zip`
- 2025.2 → `chinese-folder-annotator-252.zip`

### 构建单个版本

```bash
# 使用脚本
./build-all-versions.sh 2024.1

# 或直接用 gradle（推荐用系统 gradle，避免 wrapper 问题）
gradle clean buildPlugin -PideaVersion=2024.1 -PbuildSuffix=241 -x test -x buildSearchableOptions -x jarSearchableOptions
```

## 📝 版本映射表

| IDEA 版本 | 版本后缀 |
|-----------|---------|
| 2023.1 | 231 |
| 2024.1 | 241 |
| 2025.2 | 252 |

> 可根据需要在脚本中添加更多版本

## 📦 构建输出

所有 ZIP 文件生成在 `build/distributions/`：
```
build/distributions/
├── chinese-folder-annotator-231.zip
├── chinese-folder-annotator-241.zip
└── chinese-folder-annotator-252.zip
```

## 🔧 扩展配置

### 添加新版本

1. 编辑 `build-all-versions.sh`：
```bash
declare -A VERSIONS=(
    ["2023.1"]="231"
    ["2024.1"]="241"
    ["2025.2"]="252"
    ["2026.1"]="261"  # 添加新版本
)
```

2. 编辑 `BUILD_MULTIPLE_VERSIONS.md` 的版本表

### 使用本地 IntelliJ（加速离线构建）

如果本地有 IntelliJ 安装，修改 `gradle.properties`：
```properties
intellij.localPath=/path/to/IntelliJ/installation
```

然后构建时会使用本地 IDE，无需下载 SDK。

## ⚙️ 技术细节

### 参数传递机制

```bash
gradle buildPlugin -PideaVersion=2024.1 -PbuildSuffix=241
```

这会：
1. 设置 `ideaVersion` 为 `2024.1`
2. 设置 `buildSuffix` 为 `241`
3. Gradle 读取这些参数并相应配置构建
4. buildPlugin 任务执行后，根据 `buildSuffix` 重命名输出文件

### 为什么需要后缀？

- **区分版本**：相同的源代码可能在不同 IDEA 版本下需要不同的依赖
- **防止覆盖**：多个版本的 ZIP 文件可以同时存在不会相互覆盖
- **易于识别**：文件名直接显示支持的 IDEA 版本

## 🛠️ 故障排查

### 问题 1：Gradle wrapper JAR 缺失
```bash
# 使用系统 gradle 而不是 wrapper
gradle clean buildPlugin -PideaVersion=2023.1 -PbuildSuffix=231 ...
```

### 问题 2：Java 版本不兼容
```bash
# 需要 Java 17+
java -version
```

### 问题 3：下载超时
```bash
# 增加超时时间
gradle -Dorg.gradle.internal.http.socketTimeout=120000 buildPlugin -PideaVersion=2023.1 -PbuildSuffix=231 ...
```

## 📚 相关文件

- `build.gradle.kts` - 主构建配置
- `gradle.properties` - Gradle 属性
- `build-all-versions.sh` - Linux/macOS 构建脚本
- `build-all-versions.bat` - Windows 构建脚本
- `BUILD_MULTIPLE_VERSIONS.md` - 详细指南
- `BUILD_QUICK_REFERENCE.md` - 快速参考

## ✨ 优势

✓ **支持多个 IntelliJ 版本** - 同时为不同版本构建  
✓ **自动化构建** - 一键构建所有版本  
✓ **易于扩展** - 添加新版本只需修改脚本  
✓ **版本隔离** - 不同版本文件明确分开  
✓ **跨平台支持** - 提供 Bash 和 Batch 脚本  
✓ **文档完善** - 详细的使用指南和快速参考  

## 📞 快速开始

```bash
# 1. 进入项目目录
cd /workspaces/chinese-folder-annotator

# 2. 赋予脚本执行权限
chmod +x build-all-versions.sh

# 3. 构建所有版本（首次会下载 SDK，较慢）
./build-all-versions.sh

# 4. 检查输出
ls -lh build/distributions/
```

完成！现在你可以轻松为多个 IntelliJ IDEA 版本构建插件了。
