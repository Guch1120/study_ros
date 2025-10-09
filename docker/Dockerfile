# ベースイメージ
FROM osrf/ros:humble-desktop

ENV DEBIAN_FRONTEND=noninteractive
# OpenGLコンテキスト作成エラーの一般的な回避策としてソフトウェアレンダリングを強制
ENV LIBGL_ALWAYS_SOFTWARE=1


# パッケージインストール
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    wget \
    nano \
    curl \
    lsb-release \
    sudo \
    gnupg2 \
    python3-pip \
    ros-dev-tools \
    terminator \
    tree \
    x11-apps \
    dbus-x11 \
    ca-certificates \
    libcanberra-gtk3-module \
    libxkbcommon-x11-0 \
    libxcb-icccm4 \
    libxcb-image0 \
    libxcb-keysyms1 \
    libxcb-randr0 \
    libxcb-render-util0 \
    libxcb-xinerama0 \
    libxcb-cursor0 \
    ros-humble-gazebo-* \
    ros-humble-rqt-* \
    apt-transport-https \
    software-properties-common  \
    mesa-utils  \
    libnss3-dev \
    ros-humble-launch-testing \
    && rm -rf /var/lib/apt/lists/*

# realsense2のセットアップ
RUN mkdir -p /etc/apt/keyrings && \
    curl -sSf https://librealsense.intel.com/Debian/librealsense.pgp | tee /etc/apt/keyrings/librealsense.pgp > /dev/null
RUN echo "deb [signed-by=/etc/apt/keyrings/librealsense.pgp] https://librealsense.intel.com/Debian/apt-repo $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/librealsense.list

# realsenseとrtabmapもインストールする
RUN apt-get update && apt-get install -y \
    librealsense2-utils \
    librealsense2-dev \
    librealsense2-dbg \
    ros-humble-realsense2-camera \
    ros-humble-rtabmap-ros \
    && rm -rf /var/lib/apt/lists/*

RUN rm -f /etc/ros/rosdep/sources.list.d/20-default.list && rosdep init && rosdep update

# ユーザー設定
RUN useradd -m -s /bin/bash dockeruser && echo "dockeruser:yakiniku" | chpasswd && adduser dockeruser sudo
RUN echo "dockeruser ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/dockeruser-nopasswd

RUN groupadd -g 110 render || true && usermod -aG video,render dockeruser
USER dockeruser
# ワークスペースのセットアップ
WORKDIR /home/dockeruser/ros2_ws

# FlexBEのリポジトリを公式手順通り、humbleブランチを指定してクローン
RUN git clone https://github.com/FlexBE/flexbe_behavior_engine.git -b humble src/flexbe_behavior_engine && \
    git clone https://github.com/FlexBE/flexbe_app.git -b humble src/flexbe_app

# 依存関係をインストールしてからビルドする
RUN ["/bin/bash", "-c", "source /opt/ros/humble/setup.bash && \
    rosdep update && \
    rosdep install --from-paths src --ignore-src -r -y && \
    colcon build --symlink-install"]

# ワークスペースと設定ファイル用のディレクトリを作成
RUN mkdir -p /home/dockeruser/ros2_ws/src/my_robot_configs/launch
RUN mkdir -p /home/dockeruser/ros2_ws/src/my_robot_configs/config

COPY --chown=dockeruser:dockeruser scripts/my_realsense.launch.py /home/dockeruser/ros2_ws/src/my_robot_configs/launch/
COPY --chown=dockeruser:dockeruser src/rtabmap_params.yaml /home/dockeruser/ros2_ws/src/my_robot_configs/config/
# エントリーポイント
COPY --chown=dockeruser:dockeruser --chmod=755 docker/entrypoint.sh /home/dockeruser/entrypoint.sh
ENTRYPOINT ["/home/dockeruser/entrypoint.sh"]
CMD ["bash"]