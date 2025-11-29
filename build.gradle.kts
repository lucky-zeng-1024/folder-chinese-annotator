plugins {
    id("java")
    id("org.jetbrains.intellij") version "1.17.1"
}

// 支持多版本构建
val ideaVersion = providers.gradleProperty("ideaVersion").orNull ?: "2023.1"
val buildSuffix = providers.gradleProperty("buildSuffix").orNull

group = "com.zeng.chineseannotator"
// 版本号中包含 IDEA 版本后缀
version = if (buildSuffix != null && buildSuffix.isNotBlank()) {
    "1.0.0-${buildSuffix}"
} else {
    "1.0.0"
}

repositories {
    mavenCentral()
}

dependencies {
    testImplementation("junit:junit:4.13.2")
}

// See https://plugins.jetbrains.com/docs/intellij/tools-gradle-intellij-plugin.html
intellij {
    type.set("IC") // Target IDE Platform
    val lp = providers.gradleProperty("intellij.localPath").orNull
    if (lp != null && lp.isNotBlank()) {
        println("Using local IntelliJ at: $lp")
        localPath.set(lp)
    } else {
        println("Building for IntelliJ version: $ideaVersion")
        version.set(ideaVersion)
    }
    plugins.set(listOf(/* Plugin Dependencies */))
}

java {
    toolchain {
        languageVersion.set(JavaLanguageVersion.of(17))
    }
}

tasks {
    patchPluginXml {
        changeNotes.set("""
            Add change notes here.<br>
            <em>most HTML tags may be used</em>""".trimIndent())
    }
    // Avoid launching IDE to collect searchable options in headless/CI or with 2025.2
    buildSearchableOptions { enabled = false }
    jarSearchableOptions { enabled = false }
    
    // 禁用 instrumentation（避免 Packages 目录查找错误）
    instrumentCode { enabled = false }
    
    // 为构建的插件JAR添加版本后缀
    buildPlugin {
        doLast {
            val distributionsDir = file("build/distributions")
            distributionsDir.listFiles()?.forEach { file ->
                if (file.isFile && file.name.endsWith(".zip")) {
                    println("Generated: ${file.name}")
                }
            }
        }
    }
}

