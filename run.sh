#!/usr/bin/env bash
set -e

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TOOLS_DIR="$HOME/.local/share/ssb-tools"
JDK_DIR="$TOOLS_DIR/jdk8"
PLAY_DIR="$TOOLS_DIR/play-1.4.5"

mkdir -p "$TOOLS_DIR"

# 1. Verifica ou baixa o OpenJDK 8 localmente (sem precisar de sudo)
if [ -x "/usr/lib/jvm/java-8-openjdk-amd64/bin/java" ]; then
    JAVA_HOME="/usr/lib/jvm/java-8-openjdk-amd64"
elif [ -x "$JDK_DIR/bin/java" ]; then
    JAVA_HOME="$JDK_DIR"
else
    echo "=> Baixando OpenJDK 8 (Temurin) em $JDK_DIR ..."
    mkdir -p "$JDK_DIR"
    curl -fL "https://api.adoptium.net/v3/binary/latest/8/ga/linux/x64/jdk/hotspot/normal/eclipse" -o "$TOOLS_DIR/jdk8.tar.gz"
    tar -xzf "$TOOLS_DIR/jdk8.tar.gz" -C "$JDK_DIR" --strip-components=1
    rm -f "$TOOLS_DIR/jdk8.tar.gz"
    JAVA_HOME="$JDK_DIR"
fi

# 2. Verifica ou baixa o Play Framework 1.4.5 localmente
if [ ! -f "$PLAY_DIR/framework/play-1.4.5.jar" ]; then
    echo "=> Baixando Play Framework 1.4.5 em $PLAY_DIR ..."
    curl -fL "https://github.com/playframework/play1/releases/download/1.4.5/play-1.4.5.zip" -o "$TOOLS_DIR/play-1.4.5.zip"
    python3 -c "import zipfile; zipfile.ZipFile('$TOOLS_DIR/play-1.4.5.zip').extractall('$TOOLS_DIR')"
    rm -f "$TOOLS_DIR/play-1.4.5.zip"
fi

echo "============================================================"
echo " Iniciando Sistema de Seleção de Bolsistas (Play! 1.4.5)"
echo " Java: $($JAVA_HOME/bin/java -version 2>&1 | head -n 1)"
echo " Acesse no navegador: http://localhost:9000"
echo " Pressione Ctrl+C para parar o servidor."
echo "============================================================"

exec "$JAVA_HOME/bin/java" \
    -Xms256m -Xmx1024m \
    -Dfile.encoding=UTF-8 \
    -javaagent:"$PLAY_DIR/framework/play-1.4.5.jar" \
    -classpath "$PROJECT_DIR/conf:$PLAY_DIR/framework/play-1.4.5.jar:$PLAY_DIR/framework/lib/*:$PLAY_DIR/modules/docviewer/lib/*" \
    -Dapplication.path="$PROJECT_DIR" \
    -Dplay.id="" \
    play.server.Server
