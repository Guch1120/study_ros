#!/bin/bash
echo "launch gazebo"
# ROS2 Humbleの環境設定を読み込む
source /opt/ros/humble/setup.bash

# ワークスペースのセットアップファイルを確認し、なければビルドする
WS_PATH="/home/dockeruser/ros2_ws"
SETUP_FILE="$WS_PATH/install/setup.bash"

if [ -f "$SETUP_FILE" ]; then
    echo "Sourcing existing workspace: $SETUP_FILE"
    source "$SETUP_FILE"
else
    echo "Workspace setup file not found. Attempting to build workspace in '$WS_PATH'..."
    if [ -d "$WS_PATH/src" ]; then
        (cd "$WS_PATH" && colcon build --symlink-install)
        if [ -f "$SETUP_FILE" ]; then
            echo "Build successful. Sourcing new setup file."
            source "$SETUP_FILE"
        else
            echo "Build failed or setup file was not created. Gazebo may not find custom packages."
        fi
    else
        echo "Workspace 'src' directory not found in '$WS_PATH'. Cannot build."
    fi
fi


# Ctrl+C (SIGINT) を無視する
trap '' INT

while true; do
    # プロンプトメッセージに色を付ける (緑色 \e[32m)
    read -p $'\e[32mPress Enter to launch Gazebo (or type \'end\' to quit):\e[0m ' input
    if [[ "$input" == "end" ]]; then
        break
    fi
    gazebo
done

# SIGINTのトラップをデフォルトに戻す (念のため)
trap - INT
exec bash # Gazebo終了後、またはEnterを押さずにCtrl+Cなどで抜けた場合にシェルを起動
