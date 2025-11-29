#!/bin/bash
# 设置 Java 17 环境
export JAVA_HOME=/usr/local/sdkman/candidates/java/17.0.17-ms
export PATH=$JAVA_HOME/bin:$PATH
java -version
