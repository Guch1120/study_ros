#!/bin/bash

# docker-compose.ymlから最初のサービス名を取得します。
# これにより、サービス名を手動で設定する必要がなくなります。
# 複数のサービスが定義されている場合は、最初のサービスが選択されます。
TARGET_SERVICE=$(docker-compose config --services | head -n 1)

if [ -z "$TARGET_SERVICE" ]; then
    echo "エラー: docker-compose.yml からサービスを特定できませんでした。"
    exit 1
fi

# 指定したサービスが起動中か確認
SERVICE_STATUS=$(docker-compose ps -q "$TARGET_SERVICE" 2>/dev/null | xargs docker inspect --format '{{.State.Status}}' 2>/dev/null)

if [ "$SERVICE_STATUS" = "running" ]; then
    echo "コンテナ ($TARGET_SERVICE) は既に起動しています。コンテナに入ります..."
    # docker-compose exec を実行し、terminatorを起動する
    docker compose exec "$TARGET_SERVICE" terminator
else
    echo "コンテナ ($TARGET_SERVICE) は起動していません。コンテナを起動します..."
    # Ctrl+Cが押されたときに実行される関数
    cleanup() {
        echo "Ctrl+Cが押されました。コンテナを停止します..."
        docker-compose stop
        exit 0 # trapの後、スクリプトを正常終了させる
    }

    # SIGINT (Ctrl+C) シグナルを捕捉し、cleanup関数を呼び出す
    trap cleanup INT

    # docker-compose up をフォアグラウンドで実行
    docker compose up -d
    # docker-compose up が Ctrl+C 以外で終了した場合 (例: コンテナが正常終了)、trap は実行されない
fi