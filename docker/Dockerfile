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
    ros-humble-moveit \
    && rm -rf /var/lib/apt/lists/*
RUN rm -f /etc/ros/rosdep/sources.list.d/20-default.list && rosdep init && rosdep update

# ユーザー設定
RUN useradd -m -s /bin/bash dockeruser && echo "dockeruser:yakiniku" | chpasswd && adduser dockeruser sudo
RUN echo "dockeruser ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/dockeruser-nopasswd
RUN groupadd -g 110 render || true && usermod -aG video,render dockeruser
USER dockeruser
# ワークスペースのセットアップ
WORKDIR /home/dockeruser/ros2_ws

# ワークスペースと設定ファイル用のディレクトリを作成
RUN mkdir -p /home/dockeruser/ros2_ws/scripts
RUN mkdir -p /home/dockeruser/ros2_ws/Setup_HSR

# エントリーポイント
COPY --chown=dockeruser:dockeruser --chmod=755 docker/entrypoint.sh /home/dockeruser/entrypoint.sh
ENTRYPOINT ["/home/dockeruser/entrypoint.sh"]
CMD ["bash"]