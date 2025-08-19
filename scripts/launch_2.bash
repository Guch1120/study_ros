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

# --- ビヘイビアパッケージの存在チェック ---
check_behavior_packages() {
    echo "Checking for existing behavior packages..."

    # `ros2 pkg xml` を全パッケージに対して実行すると非常に遅いため、
    # AMENT_PREFIX_PATH 内の全 package.xml を直接検索して高速化します。
    local found_package_file
    # findで見つかった全package.xmlをxargs経由でgrepに渡し、<flexbe_behaviors />を含むものを探す
    # `grep -l`はファイルパスを出力し、`head -n 1`で最初に見つかったものだけを取得
    found_package_file=$(echo "$AMENT_PREFIX_PATH" | tr ':' '\n' | while read -r path; do
        find "$path/share" -type f -name "package.xml" -print0 2>/dev/null
    done | xargs -0 --no-run-if-empty grep -l "<flexbe_behaviors />" | head -n 1)

    if [ -n "$found_package_file" ]; then
        # 見つかったパスからパッケージ名を抽出 (例: .../share/pkg_name/package.xml -> pkg_name)
        local pkg_name
        pkg_name=$(basename "$(dirname "$found_package_file")")
        echo "--> Behavior package found: $pkg_name"
        return 0 # 成功
    else
        echo "--> No behavior packages found."
        return 1 # 失敗
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
# --- ここまで ---

echo -e "\e[32mready\e[0m\n"


# --- 高度な終了処理 ---
LAUNCH_PID=""

cleanup() {
    echo -e "\n\e[33m Detect Ctrl+C...\e[0m"
    if [ -n "$LAUNCH_PID" ]; then
        # Step 1: まずはSIGINTで、丁寧にお願いする
        echo -n "  SIGINT..."
        echo " id:${LAUNCH_PID}"
        kill -SIGINT -- -"$LAUNCH_PID" 2>/dev/null
        
        # Step 2: 2秒待って、まだ生きてるか確認
        sleep 2
        # `ps`コマンドで、まだプロセスが存在するかどうかをチェック
        if ps -p "$LAUNCH_PID" > /dev/null; then
            # Step 3: まだ生きてたら、SIGKILLで強制的に終了させる
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

    # 毎回起動前に最新のワークスペース環境を読み込む
    if [ -f "/home/dockeruser/ros2_ws/install/setup.bash" ]; then
        echo "Sourcing workspace environment..."
        source /home/dockeruser/ros2_ws/install/setup.bash
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