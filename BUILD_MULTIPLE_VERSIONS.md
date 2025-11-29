# 多版本构建指南

本文档说明如何为不同的 IntelliJ IDEA 版本构建插件。

## 目录版本映射

| IDEA 版本 | 版本后缀 | 构建命令 |
|-----------|---------|--------|
| 2023.1 | 231 | `./gradlew buildPlugin -PideaVersion=2023.1 -PbuildSuffix=231` |
| 2024.1 | 241 | `./gradlew buildPlugin -PideaVersion=2024.1 -PbuildSuffix=241` |
| 2025.2 | 252 | `./gradlew buildPlugin -PideaVersion=2025.2 -PbuildSuffix=252` |

## 方法 1：一键构建所有版本（推荐）

### Linux / macOS

```bash
chmod +x build-all-versions.sh
./build-all-versions.sh
```

### Windows

```bash
build-all-versions.bat
```

该脚本会自动为所有版本构建插件，生成的 ZIP 文件位于 `build/distributions/`

## 方法 2：手动逐个构建

### 构建 2023.1 版本

```bash
./gradlew clean buildPlugin -PideaVersion=2023.1 -PbuildSuffix=231 -x test -x buildSearchableOptions -x jarSearchableOptions
```

输出文件：`build/distributions/chinese-folder-annotator-231.zip`

### 构建 2024.1 版本

```bash
./gradlew clean buildPlugin -PideaVersion=2024.1 -PbuildSuffix=241 -x test -x buildSearchableOptions -x jarSearchableOptions
```

输出文件：`build/distributions/chinese-folder-annotator-241.zip`

### 构建 2025.2 版本

```bash
./gradlew clean buildPlugin -PideaVersion=2025.2 -PbuildSuffix=252 -x test -x buildSearchableOptions -x jarSearchableOptions
```

输出文件：`build/distributions/chinese-folder-annotator-252.zip`

## 方法 3：自定义构建特定版本

如果要构建其他 IntelliJ IDEA 版本，只需修改参数即可：

```bash
./gradlew buildPlugin -PideaVersion=<IDEA_VERSION> -PbuildSuffix=<SUFFIX>
```

### 常见 IDEA 版本号

- `2022.2` - 需要 JDK 17
- `2023.1` - 需要 JDK 17
- `2023.2` - 需要 JDK 17
- `2024.1` - 需要 JDK 17
- `2024.2` - 需要 JDK 17
- `2025.1` - 需要 JDK 21
- `2025.2` - 需要 JDK 21

## 参数说明

| 参数 | 说明 | 示例 |
|------|------|------|
| `ideaVersion` | IntelliJ IDEA 版本号 | `2023.1`, `2024.1`, `2025.2` |
| `buildSuffix` | 输出 ZIP 文件的版本后缀 | `231`, `241`, `252` |
| `intellij.localPath` | 本地 IntelliJ 安装路径（可选） | `/Applications/IntelliJ IDEA.app/Contents` |

## gradle.properties 配置

你也可以在 `gradle.properties` 中设置默认版本：

```properties
# 默认构建版本
ideaVersion=2024.1
buildSuffix=241

# 或使用本地 IntelliJ（如果有的话）
# intellij.localPath=/path/to/IntelliJ/installation
```

## 常见问题

### Q: 构建速度很慢？

**A**: 这是首次下载 IntelliJ SDK 的正常现象。后续构建会快很多。如果有本地 IntelliJ 安装，可以通过 `intellij.localPath` 加速。

### Q: 如何清理缓存的 SDK？

**A**: 
```bash
./gradlew cleanIdea
```

### Q: 需要同时保留多个版本的 SDK 吗？

**A**: Gradle 会自动管理 SDK 缓存，通常位于 `~/.gradle/caches/`。无需手动管理。

### Q: 能在 CI/CD 中使用吗？

**A**: 可以。在 GitHub Actions 或其他 CI 系统中执行构建脚本即可。例如：

```yaml
- name: Build multiple versions
  run: |
    chmod +x build-all-versions.sh
    ./build-all-versions.sh
```

## 构建输出

成功后，你会在 `build/distributions/` 目录中看到：

```
chinese-folder-annotator-231.zip
chinese-folder-annotator-241.zip
chinese-folder-annotator-252.zip
```

这些文件可以直接在对应版本的 IntelliJ IDEA 中安装：

1. Settings/Preferences → Plugins → ⚙️ → Install Plugin from Disk
2. 选择对应版本的 ZIP 文件
3. 重启 IDE

## 扩展配置

如果要添加更多版本，修改构建脚本中的版本映射：

### Bash 脚本 (build-all-versions.sh)

```bash
declare -A VERSIONS=(
    ["2023.1"]="231"
    ["2024.1"]="241"
    ["2025.2"]="252"
    ["2025.3"]="253"  # 新增
)
```

### Batch 脚本 (build-all-versions.bat)

```batch
set "versions[3]=2025.3"
set "suffixes[3]=253"
```

然后编辑循环上限：
```batch
for /l %%i in (0,1,3) do (  # 改为 3（从 0 开始，所以包括 0,1,2,3）
```

## 技术细节

### build.gradle.kts 配置

```kotlin
val ideaVersion = providers.gradleProperty("ideaVersion").orNull ?: "2023.1"
val buildSuffix = providers.gradleProperty("buildSuffix").orNull

intellij {
    version.set(ideaVersion)
}

tasks {
    buildPlugin {
        doLast {
            if (buildSuffix != null && buildSuffix.isNotBlank()) {
                // 为输出 ZIP 添加后缀
            }
        }
    }
}
```

这样 Gradle 会根据指定的版本下载对应的 IntelliJ SDK，并编译生成带版本后缀的插件包。
