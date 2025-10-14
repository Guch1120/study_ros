sudo apt update
sudo apt install -y python3-colcon-common-extensions python3-pip
sudo rosdep init
rosdep update

mkdir -p ~/hsr_ws/src && cd ~/hsr_ws/src


git clone -b humble https://github.com/hsr-project/gazebo_ros2_control.git
git clone -b humble https://github.com/hsr-project/hsrb_controllers.git
git clone -b humble https://github.com/hsr-project/hsrb_description.git
git clone -b humble https://github.com/hsr-project/hsrb_drivers.git
git clone -b humble https://github.com/hsr-project/hsrb_launch.git
git clone -b humble https://github.com/hsr-project/hsrb_manipulation.git
git clone -b humble https://github.com/hsr-project/hsrb_meshes.git
git clone -b humble https://github.com/hsr-project/hsrb_rosnav.git
git clone -b humble https://github.com/hsr-project/hsrb_simulator.git
git clone -b humble https://github.com/hsr-project/hsrb_teleop.git
git clone -b humble https://github.com/hsr-project/tmc_gazebo.git
git clone -b humble https://github.com/hsr-project/tmc_common.git
git clone -b humble https://github.com/hsr-project/tmc_common_msgs.git
git clone -b humble https://github.com/hsr-project/tmc_database.git
git clone -b humble https://github.com/hsr-project/tmc_manipulation.git
git clone -b humble https://github.com/hsr-project/tmc_manipulation_base.git
git clone -b humble https://github.com/hsr-project/tmc_manipulation_planner.git
git clone -b humble https://github.com/hsr-project/tmc_realtime_control.git
git clone -b humble https://github.com/hsr-project/tmc_voice.git
git clone -b humble https://github.com/hsr-project/hsrb_moveit_config.git
git clone -b humble https://github.com/hsr-project/hsrb_moveit_plugins.git
rm -rf hsrb_launch/hsrb_robot_launch


cd ~/hsr_ws
source /opt/ros/humble/setup.bash
rosdep install --from-paths . -y --ignore-src
colcon build --symlink-install --cmake-args -DCMAKE_BUILD_TYPE=Release
source install/setup.bash

