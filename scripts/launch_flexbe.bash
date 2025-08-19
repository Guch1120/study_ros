#!/bin/bash

echo "--- FlexBE ---"

# --- 環境設定 ---
if [ -f "/home/dockeruser/ros2_ws/install/setup.bash" ]; then
    source /home/dockeruser/ros2_ws/install/setup.bash
fi

export XDG_CONFIG_HOME=/tmp/.chromium
export XDG_CACHE_HOME=/tmp/.chromium

# --- nwjsのインストールチェックを追加 ---
NWJS_DIR="/home/dockeruser/ros2_ws/install/flexbe_app/lib/flexbe_app/nwjs"

# NWJS_DIRで指定したディレクトリが存在しない場合に、中の処理を実行する
if [ ! -d "${NWJS_DIR}" ]; then
    # nwjsのインストールを実行
    echo "FlexBE App (nwjs) is not found. Installing nwjs..."
    ros2 run flexbe_app nwjs_install
    echo "nwjs installation finished."
else
# ディレクトリが存在する場合は、メッセージだけ表示して何もしない
    echo "FlexBE App (nwjs) is already installed. Skipping installation."
fi
# --- ここまで ---

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
        echo "No build file:ワークスペース名あってる？ workspace setup file not found. Did you build the workspace?"
    fi

    echo "Launching FlexBE..."
    setsid ros2 launch flexbe_app flexbe_full.launch.py &
    LAUNCH_PID=$!

    wait "$LAUNCH_PID"
    LAUNCH_PID=""

    echo -e "\e[33mEnded FlexBE\e[0m\n"
done

# --- スクリプトの完全終了処理 ---
trap - INT
echo "Finsish"