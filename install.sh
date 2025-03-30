#!/bin/bash

# 检查用户是否具有 root 访问权限
if [ "$EUID" -ne 0 ]; then
  echo $'\e[32m请使用 root 权限运行.\e[0m'
  exit
fi

echo $'\e[35m'"  ___|              |        _ _|  _ \   /    
 |      _ \    __|  __|        |  |   |  _ \  
 |   | (   | \__ \  |          |  ___/  (   | 
\____|\___/  ____/ \__|      ___|_|    \___/  
                                              "$'\e[0m'

echo -e "\e[36m创建者 Masoud Gb 特别感谢 Hamid 路由器\e[0m"
echo $'\e[35m'"Gost Ipv6 脚本 v2.2.0"$'\e[0m'

options=($'\e[36m1. \e[0mGost 隧道 IPv4'
         $'\e[36m2. \e[0mGost 隧道 IPv6'
         $'\e[36m3. \e[0mGost 状态'
         $'\e[36m4. \e[0m更新脚本'
         $'\e[36m5. \e[0m添加新 IP'
         $'\e[36m6. \e[0m更改 Gost 版本'
         $'\e[36m7. \e[0m自动重启Gost'
         $'\e[36m8. \e[0m自动清除缓存'
         $'\e[36m9. \e[0m安装 BBR'
         $'\e[36m10. \e[0m卸载'
         $'\e[36m11. \e[0m退出')

# 使用青色打印提示和选项
printf "\e[32m请选择您的选项：\e[0m\n"
printf "%s\n" "${options[@]}"

# 读取白色的用户输入
read -p $'\e[97m您的选择： \e[0m' choice

# 如果选择了选项 1 或 2
if [ "$choice" -eq 1 ] || [ "$choice" -eq 2 ]; then
    if [ "$choice" -eq 1 ]; then
        read -p $'\e[97m请输入目的地 (Kharej) IPv4： \e[0m' destination_ip
    elif [ "$choice" -eq 2 ]; then
        read -p $'\e[97m请输入目的地 (Kharej) IPv6： \e[0m' destination_ip
    fi

    read -p $'\e[32m请从以下选项中选择一项：\n\e[0m\e[36m1. \e[0m输入 “自定 ”端口\n\e[36m2. \e[0m输入 “范围 ”端口\e[32m\n您的选择 \e[0m' port_option

if [ "$port_option" -eq 1 ]; then
    read -p $'\e[36m请输入所需的端口（用逗号分隔）： \e[0m' ports
elif [ "$port_option" -eq 2 ]; then
    read -p $'\e[36m请输入端口范围（例如 54,65000）： \e[0m' port_range

    IFS=',' read -ra port_array <<< "$port_range"

    # 检查 起始端口 和 终端端口 值是否在有效范围内
    if [ "${port_array[0]}" -lt 54 -o "${port_array[1]}" -gt 65000 ]; then
        echo $'\e[33m端口范围无效。请输入从 54 到 65000 的有效范围。\e[0m'
        exit
    fi

    ports=$(seq -s, "${port_array[0]}" "${port_array[1]}")
else
    echo $'\e[31m无效的选项。 退出...\e[0m'
    exit
fi

    read -p $'\e[32m选择协议：\n\e[0m\e[36m1. \e[0m通过 “tcp” 协议 \n\e[36m2. \e[0m通过 “UDP” 协议 \n\e[36m3. \e[0m通过 “Grpc” 协议 \e[32m\n您的选择： \e[0m' protocol_option

if [ "$protocol_option" -eq 1 ]; then
    protocol="tcp"
elif [ "$protocol_option" -eq 2 ]; then
    protocol="udp"
elif [ "$protocol_option" -eq 3 ]; then
    protocol="grpc"
else
    echo $'\e[31m无效的协议选项。 退出...\e[0m'
    exit
fi

    echo $'\e[32m您选择的选项\e[0m' $choice
    echo $'\e[97m目标 IP：\e[0m' $destination_ip
    echo $'\e[97m端口：\e[0m' $ports
    echo $'\e[97m协议：\e[0m' $protocol

    # 用于安装和配置 Gost 的命令
    echo $'\e[32m正在更新系统包，请稍候...\e[0m'
    sysctl net.ipv4.ip_local_port_range="1024 65535"
# 将 sysctl 命令添加到脚本的末尾
echo "sysctl net.ipv4.ip_local_port_range=\"1024 65535\"" >> /etc/rc.local

# 启用 systemd 服务以在重启后运行 sysctl 命令
cat <<EOL > /etc/systemd/system/sysctl-custom.service
[Unit]
Description=Custom sysctl settings

[Service]
ExecStart=/sbin/sysctl net.ipv4.ip_local_port_range="1024 65535"

[Install]
WantedBy=multi-user.target
EOL
# 启用服务
systemctl enable sysctl-custom

    apt update && sudo apt install wget nano -y && \
    # 为 'gost' 添加别名以执行脚本
        echo 'alias gost="bash /etc/gost/install.sh"' >> ~/.bashrc
        source ~/.bashrc
        echo $'\e[32m已创建符号链接： /usr/local/bin/gost\e[0m'
    echo $'\e[32m系统更新已完成。\e[0m'
    # 提示用户选择 Gost 版本
    echo $'\e[32m选择 Gost 版本：\e[0m'
    echo $'\e[36m1. \e[0mGost 版本 2.11.5（官方）'
    echo $'\e[36m2. \e[0mGost 版本 3.0.0（最新）'

    # 读取 Gost 版本的用户输入
    read -p $'\e[97m您的选择： \e[0m' gost_version_choice

    # 根据用户的选择下载并安装 Gost
    if [ "$gost_version_choice" -eq 1 ]; then
        echo $'\e[32m安装 Gost 版本 2.11.5，请稍候...\e[0m' && \
        wget https://raw.githubusercontent.com/masoudgb/Gost-ip6/main/gost/gost_2.11.5.gz && \
        echo $'\e[32mGost 下载成功.\e[0m' && \
        gunzip gost_2.11.5.gz && \
        sudo mv gost_2.11.5.gz /usr/local/bin/gost && \
        sudo chmod +x /usr/local/bin/gost && \
        echo $'\e[32mGost 安装成功.\e[0m'
    else
        if [ "$gost_version_choice" -eq 2 ]; then
    echo $'\e[32m正在安装 Gost 3.0.0 版本，请稍候...\e[0m'
    wget -O /tmp/gost.tar.gz https://raw.githubusercontent.com/masoudgb/Gost-ip6/main/gost/gost_3.0.0.tar.gz
    tar -xvzf /tmp/gost.tar.gz -C /usr/local/bin/
    chmod +x /usr/local/bin/gost
    echo $'\e[32mGost 安装成功.\e[0m'
else
    echo $'\e[31m选择无效。 退出...\e[0m'
    exit
fi
    fi
    # 继续创建 systemd 服务文件
    exec_start_command="ExecStart=/usr/local/bin/gost"

    # 为每个端口添加线路
    IFS=',' read -ra port_array <<< "$ports"
    port_count=${#port_array[@]}

    # 设置每个文件的最大端口数
    max_ports_per_file=12000

    # 计算所需的文件数
    file_count=$(( (port_count + max_ports_per_file - 1) / max_ports_per_file ))

    # 继续创建 systemd 服务文件
    for ((file_index = 0; file_index < file_count; file_index++)); do
        # 创建新的 systemd 服务文件
        cat <<EOL | sudo tee "/usr/lib/systemd/system/gost_$file_index.service" > /dev/null
[Unit]
Description=GO Simple Tunnel
After=network.target
Wants=network.target

[Service]
Type=simple
Environment="GOST_LOGGER_LEVEL=fatal"
EOL

        # 为当前文件中的每个端口添加行
        exec_start_command="ExecStart=/usr/local/bin/gost"
        for ((i = file_index * max_ports_per_file; i < (file_index + 1) * max_ports_per_file && i < port_count; i++)); do
            port="${port_array[i]}"
            exec_start_command+=" -L=$protocol://:$port/[$destination_ip]:$port"
        done

        # 将 ExecStart 命令附加到当前文件
        echo "$exec_start_command" | sudo tee -a "/usr/lib/systemd/system/gost_$file_index.service" > /dev/null

        # 完成当前的 systemd 服务文件
        cat <<EOL | sudo tee -a "/usr/lib/systemd/system/gost_$file_index.service" > /dev/null

[Install]
WantedBy=multi-user.target
EOL

        # 重新加载并重新启动 systemd 服务
        sudo systemctl enable "gost_$file_index.service"
        sudo systemctl start "gost_$file_index.service"
        sudo systemctl daemon-reload
        sudo systemctl restart "gost_$file_index.service"
    done

echo $'\e[32m已成功应用 Gost 配置.\e[0m'
    
# 如果选择了选项 3
elif [ "$choice" -eq 3 ]; then
    # 检查是否已安装 Gost
    if command -v gost &>/dev/null; then
        echo $'\e[32m已安装 Gost。检查配置和状态...\e[0m'
        
        # 检查 Gost 配置和状态
        systemctl list-unit-files | grep -q "gost_"
        if [ $? -eq 0 ]; then
            echo $'\e[32mGost 已配置并处于活动状态.\e[0m'
            
            # 获取并显示使用的 IP 和端口
            for service_file in /usr/lib/systemd/system/gost_*.service; do
                # 使用 awk 提取 IP、端口和协议信息
                service_info=$(awk -F'[-=:/\\[\\]]+' '/ExecStart=/ {print $14,$15,$22,$20,$23}' "$service_file")

                # 将提取的信息拆分为数组
                read -a info_array <<< "$service_info"

                # 显示 IP、端口和协议信息以及更正的端口范围
                echo -e "\e[97mIP:\e[0m ${info_array[0]} \e[97mPort:\e[0m ${info_array[1]},... \e[97mProtocol:\e[0m ${info_array[2]}"

            done
        else
            echo $'\e[33mGost 已安装，但未配置或处于活动状态.\e[0m'
        fi
    else
        echo $'\e[33m未安装 Gost 隧道。 \e[0m'
    fi

    read -n 1 -s -r -p $'\e[36m0. \e[0m返回菜单： \e[0m' choice

if [ "$choice" -eq 0 ]; then
    bash "$0"
fi

# 如果选择了选项 4
elif [ "$choice" -eq 4 ]; then
    read -p $'\e[32m是否要更新 Gost 脚本？ (y/n): \e[0m' update_choice

    if [ "$update_choice" == "y" ]; then
        echo $'\e[32m正在更新 Gost，请稍候...\e[0m'
        # 将 install.sh 保存在 /etc/gost 目录中
        sudo mkdir -p /etc/gost
wget -O /etc/gost/install.sh https://github.com/Jlz0/Gost-ip6/raw/main/install.sh
chmod +x /etc/gost/install.sh
        echo $'\e[32m更新已完成.\e[0m'
    else
        echo $'\e[32m更新已取消.\e[0m'
    fi

    bash "$0"
fi

# 如果选择了选项 5
if [ "$choice" -eq 5 ]; then
    read -p $'\e[97m请输入新的目的地 （Kharej） IP 4 或 6： \e[0m' destination_ip
    read -p $'\e[36m请输入新端口（以逗号分隔）： \e[0m' port
    read -p $'\e[32m选择协议：\n\e[0m\e[36m1. \e[0m按 tcp 协议 \n\e[36m2. \e[0m通过 Grpc 协议 \e[32m\n您的选择： \e[0m' protocol_option

    if [ "$protocol_option" -eq 1 ]; then
        protocol="tcp"
    elif [ "$protocol_option" -eq 2 ]; then
        protocol="grpc"
    else
        echo $'\e[31m无效的协议选项。退出...\e[0m'
        exit
    fi

    # 使用之前输入的默认协议
    echo $'\e[32m您选择的选项\e[0m' $choice
    echo $'\e[97m目标 IP：\e[0m' $destination_ip
    echo $'\e[97m端口(s):\e[0m' $port
    echo $'\e[97m协议:\e[0m' $protocol

    # 创建 systemd 服务文件
    cat <<EOL | sudo tee "/usr/lib/systemd/system/gost_$destination_ip.service" > /dev/null
[Unit]
Description=GO Simple Tunnel
After=network.target
Wants=network.target

[Service]
Type=simple
Environment="GOST_LOGGER_LEVEL=fatal"
EOL

    # 为每个端口添加线路
    IFS=',' read -ra port_array <<< "$port"
    port_count=${#port_array[@]}

    # 设置每个文件的最大端口数
    max_ports_per_file=12000

    # 计算所需的文件数
    file_count=$(( (port_count + max_ports_per_file - 1) / max_ports_per_file ))

    for ((file_index = 0; file_index < file_count; file_index++)); do
        # 为当前文件中的每个端口添加行
        exec_start_command="ExecStart=/usr/local/bin/gost"
        for ((i = file_index * max_ports_per_file; i < (file_index + 1) * max_ports_per_file && i < port_count; i++)); do
            port="${port_array[i]}"
            exec_start_command+=" -L=$protocol://:$port/[$destination_ip]:$port"
        done

        # 将 ExecStart 命令附加到当前文件
        echo "$exec_start_command" | sudo tee -a "/usr/lib/systemd/system/gost_$destination_ip.service" > /dev/null
    done

    # 完成 systemd 服务文件
    cat <<EOL | sudo tee -a "/usr/lib/systemd/system/gost_$destination_ip.service" > /dev/null

[Install]
WantedBy=multi-user.target
EOL

    # 重新加载并重新启动 systemd 服务
    sudo systemctl enable "gost_$destination_ip.service"
    sudo systemctl start "gost_$destination_ip.service"
    sudo systemctl daemon-reload
    sudo systemctl restart "gost_$destination_ip.service"
    
    echo $'\e[32m已成功应用 Gost 配置.\e[0m'
    bash "$0"
# 如果选择了选项 6
elif [ "$choice" -eq 6 ]; then
    echo $'\e[32m选择 Gost 版本:\e[0m'
    echo $'\e[36m1. \e[0mGost 版本 2.11.5（官方）'
    echo $'\e[36m2. \e[0mGost 版本 3.0.0（最新）'

    # 读取用户输入的 Gost 版本
    read -p $'\e[97m您的选择: \e[0m' gost_version_choice

    # 根据用户的选择下载并安装 Gost
    case "$gost_version_choice" in
        1)
            echo $'\e[32m安装 Gost 版本 2.11.5，请稍候...\e[0m' && \
            wget https://github.com/ginuerzh/gost/releases/download/v2.11.5/gost-linux-amd64-2.11.5.gz && \
            echo $'\e[32mGost 下载成功.\e[0m' && \
            gunzip gost-linux-amd64-2.11.5.gz && \
            sudo mv gost-linux-amd64-2.11.5 /usr/local/bin/gost && \
            sudo chmod +x /usr/local/bin/gost && \
            echo $'\e[32mGost 安装成功.\e[0m'
            ;;
        2)
            echo $'\e[32m正在安装 Gost 3.0.0 版本，请稍候...\e[0m' && \
            wget -O /tmp/gost.tar.gz https://github.com/go-gost/gost/releases/download/v3.0.0-nightly.20240128/gost_3.0.0-nightly.20240128_linux_amd64.tar.gz
    tar -xvzf /tmp/gost.tar.gz -C /usr/local/bin/
    chmod +x /usr/local/bin/gost
            echo $'\e[32mGost 安装成功.\e[0m'
            ;;
        *)
            echo $'\e[31m选择无效。 退出...\e[0m'
   exit
            ;;
    esac
    bash "$0"

# If option 7 is selected
elif [ "$choice" -eq 7 ]; then
    echo $'\e[32m选择自动重启选项:\e[0m'
    echo $'\e[36m1. \e[0m启用自动重启'
    echo $'\e[36m2. \e[0m禁用自动重启'

    # Read user input for Auto Restart option
    read -p $'\e[97m您的选择: \e[0m' auto_restart_option

    # Process user choice for Auto Restart
    case "$auto_restart_option" in
        1)
            # Logic to enable Auto Restart
            echo $'\e[32m已启用自动重启.\e[0m'
            # Remove any existing scheduled restart using 'at' command
            sudo at -l | awk '{print $1}' | xargs -I {} atrm {}
            # Prompt the user for the restart time in hours
            read -p $'\e[97m输入重启时间（以小时为单位）: \e[0m' restart_time_hours

            # Convert hours to minutes
            restart_time_minutes=$((restart_time_hours * 60))

            # Write a script to restart Gost
            echo -e "#!/bin/bash\n\nsudo systemctl daemon-reload\nsudo systemctl restart gost_*.service" | sudo tee /usr/bin/auto_restart_cronjob.sh > /dev/null

            # Give execute permission to the script
            sudo chmod +x /usr/bin/auto_restart_cronjob.sh

            # Remove any existing cron job for Auto Restart
            crontab -l | grep -v '/usr/bin/auto_restart_cronjob.sh' | crontab -

            # Write a new cron job to execute the script at the specified intervals
            (crontab -l ; echo "0 */$restart_time_hours * * * /usr/bin/auto_restart_cronjob.sh") | crontab -

            echo $'\e[32m已成功计划自动重启.\e[0m'
            ;;
        2)
            # Logic to disable Auto Restart
            echo $'\e[32m已禁用自动重启.\e[0m'
            # Remove the script and cron job for Auto Restart
            sudo rm -f /usr/bin/auto_restart_cronjob.sh
            crontab -l | grep -v '/usr/bin/auto_restart_cronjob.sh' | crontab -

            echo $'\e[32m已成功禁用自动重启.\e[0m'
            ;;
        *)
            echo $'\e[31m选择无效。 退出...\e[0m'
            exit
            ;;
    esac
 bash "$0"
fi

# If option 8 is selected
if [ "$choice" -eq 8 ]; then
    echo $'\e[32m选择 自动清除缓存 选项:\e[0m'
    echo $'\e[36m1. \e[0m启用自动清除缓存'
    echo $'\e[36m2. \e[0m禁用自动清除缓存'

    # Read user input for Auto Clear Cache option
    read -p $'\e[97m您的选择: \e[0m' auto_clear_cache_option

    # Process user choice for Auto Clear Cache
    case "$auto_clear_cache_option" in
        1)
            # Enable Auto Clear Cache
            enable_auto_clear_cache() {
                echo $'\e[32m已启用自动清除缓存.\e[0m'
                
                # Prompt user to choose the interval in days
                read -p $'\e[97m输入以天为单位的间隔（例如，1 表示每天，7 表示每周）: \e[0m' interval_days
                
                # Set up the cron job based on the interval
                cron_interval="0 0 */$interval_days * *"

                # Write a new cron job to execute the cache clearing commands at the specified interval
                (crontab -l 2>/dev/null; echo "$cron_interval sync; echo 1 > /proc/sys/vm/drop_caches && sync; echo 2 > /proc/sys/vm/drop_caches && sync; echo 3 > /proc/sys/vm/drop_caches") | crontab -

                echo $'\e[32m已成功计划自动清除缓存.\e[0m'
            }

            # Call the function to enable Auto Clear Cache
            enable_auto_clear_cache
            ;;
        2)
            # Disable Auto Clear Cache
            disable_auto_clear_cache() {
                echo $'\e[32m自动清除缓存已禁用.\e[0m'
                
                # Remove only the cron job related to auto clearing cache
                crontab -l | grep -v "drop_caches" | crontab -

                echo $'\e[32m已成功禁用自动清除缓存.\e[0m'
            }

            # Call the function to disable Auto Clear Cache
            disable_auto_clear_cache
            ;;
        *)
            echo $'\e[31m选择无效。 退出...\e[0m'
            exit
            ;;
    esac
 bash "$0"
fi

# 如果选择了选项 9
if [ "$choice" -eq 9 ]; then
    echo $'\e[32m正在安装 BBR，请稍候...\e[0m' && \
    wget -N --no-check-certificate https://github.com/teddysun/across/raw/master/bbr.sh && \
    chmod +x bbr.sh && \
    bash bbr.sh
    bash "$0"

# 如果选择了选项 10
elif [ "$choice" -eq 10 ]; then
    # 提示用户进行确认
    read -p $'\e[91m警告\e[33m: 这将卸载 Gost 并删除所有相关数据。您确定要继续吗？ (y/n): ' uninstall_confirm

    # 检查用户确认
    if [ "$uninstall_confirm" == "y" ]; then
        # 单行卸载倒计时
        echo $'\e[32m在 3 秒内卸载 Gost... \e[0m' && sleep 1 && echo $'\e[32m2... \e[0m' && sleep 1 && echo $'\e[32m1... \e[0m' && sleep 1 && {
            # 删除 auto_restart_cronjob.sh 脚本
            sudo rm -f /usr/bin/auto_restart_cronjob.sh

            # 删除自动重启的 cron 作业
            crontab -l | grep -v '/usr/bin/auto_restart_cronjob.sh' | crontab -

            # 继续执行其余的卸载过程
            sudo systemctl daemon-reload
            sudo systemctl stop gost_*.service
            sudo rm -f /usr/local/bin/gost
            sudo rm -rf /etc/gost
            sudo rm -f /usr/lib/systemd/system/gost_*.service
            sudo rm -f /etc/systemd/system/multi-user.target.wants/gost_*.service
            systemctl stop sysctl-custom
            systemctl disable sysctl-custom
            sudo rm -f /etc/systemd/system/sysctl-custom.service
            sudo rm -f /etc/systemd/system/multi-user.target.wants/sysctl-custom.service
            systemctl daemon-reload
            
            echo $'\e[32m已成功卸载 Gost.\e[0m'
        }
    else
        echo $'\e[32m卸载已取消.\e[0m'
    fi
    
# If option 11 is selected
elif [ "$choice" -eq 11 ]; then
    echo $'\e[32m您已退出脚本。\e[0m'
    exit
fi
