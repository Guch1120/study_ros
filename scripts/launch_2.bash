#!/bin/bash

echo "--- FlexBE ---"

# --- 環境設定 ---
# ROSの基本環境を読み込む
if [ -f "/opt/ros/humble/setup.bash" ]; then
    source /opt/ros/humble/setup.bash
fi
# ワークスペースの環境を読み込む（ビルド後）
if [ -f "/home/dockeruser/ros2_ws/install/setup.bash" ]; then
    source /home/dockeruser/ros2_ws/install/setup.bash
fi

export XDG_CONFIG_HOME=/tmp/.chromium
export XDG_CACHE_HOME=/tmp/.chromium

# --- nwjsのインストールチェックを追加 ---
NWJS_DIR="/home/dockeruser/ros2_ws/install/flexbe_app/lib/flexbe_app/nwjs"

if [ ! -d "${NWJS_DIR}" ]; then
    echo "FlexBE App (nwjs) is not found. Installing nwjs..."
    ros2 run flexbe_app nwjs_install
    echo "nwjs installation finished."
else
    echo "FlexBE App (nwjs) is already installed. Skipping installation."
fi

# --- ビヘイビアパッケージの存在チェック ---
check_behavior_packages() {
    echo "Checking for existing behavior packages..."
    local found_package_file
    found_package_file=$(echo "$AMENT_PREFIX_PATH" | tr ':' '\n' | while read -r path; do
        find "$path/share" -type f -name "package.xml" -print0 2>/dev/null
    done | xargs -0 --no-run-if-empty grep -l "<flexbe_behaviors />" | head -n 1)

    if [ -n "$found_package_file" ]; then
        local pkg_name
        pkg_name=$(basename "$(dirname "$found_package_file")")
        echo "--> Behavior package found: $pkg_name"
        return 0
    else
        echo "--> No behavior packages found."
        return 1
    fi
}

if ! check_behavior_packages; then
    echo -e "\n\e[1;33m[ACTION REQUIRED] No behavior packages found!\e[0m"
    echo "It seems this is your first time, or no behavior repository has been created yet."
    echo "To create behaviors, you first need a behavior package."
    echo "Please run the following command in another terminal:"
    echo -e "  \e[32mros2 run flexbe_widget create_repo my_behaviors\e[0m"
    echo -e "After running the command, build your workspace (\e[32mcd ~/ros2_ws && colcon build\e[0m) and restart this launcher.\n"
fi

echo -e "\e[32mready\e[0m\n"

# --- 高度な終了処理 ---
LAUNCH_PID=""
cleanup() {
    echo -e "\n\e[33m Detect Ctrl+C...\e[0m"
    if [ -n "$LAUNCH_PID" ]; then
        echo -n "  SIGINT..."
        echo " id:${LAUNCH_PID}"
        kill -SIGINT -- -"$LAUNCH_PID" 2>/dev/null
        sleep 2
        if ps -p "$LAUNCH_PID" > /dev/null; then
            echo -n "  > SIGKILL..."
            echo  "process id: "$LAUNCH_PID
            kill -SIGKILL -- -"$LAUNCH_PID" 2>/dev/null
        else
            echo "  > all processes end"
        fi
    fi
}
trap cleanup INT

# --- メインの起動ループ ---
while true; do
    read -p $'\e[32mPress Enter to launch FlexBE (type \'end\' to quit):\e[0m ' input
    if [[ "$input" == "end" ]]; then
        break
    fi

    echo "Sourcing workspace environment..."
    # 毎回起動前に最新のワークスペース環境を読み込む
    if [ -f "/home/dockeruser/ros2_ws/install/setup.bash" ]; then
        source /home/dockeruser/ros2_ws/install/setup.bash
    else
        echo "Warning: workspace setup file not found. Did you build the workspace?"
    fi

    echo "Launching FlexBE..."
    setsid ros2 launch flexbe_app app.launch.py &
    LAUNCH_PID=$!

    wait "$LAUNCH_PID"
    LAUNCH_PID=""

    echo -e "\e[33mEnded FlexBE\e[0m\n"
done

# --- スクリプトの完全終了処理 ---
trap - INT
echo "Finsish"