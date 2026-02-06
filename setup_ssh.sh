#!/bin/bash

# --- رنگ‌ها و استایل ---
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' 

# نمایش بنر
show_banner() {
    clear
    echo -e "${BLUE}==========================================${NC}"
    echo -e "${GREEN}    SSH Automated Setup Wizard (2026)     ${NC}"
    echo -e "${BLUE}==========================================${NC}"
}

# تاییدیه قبل از انجام هر مرحله (برگشت‌پذیر)
confirm() {
    echo -ne "${YELLOW}[?] آیا از انجام این مرحله مطمئن هستید؟ (y/n): ${NC}"
    read -r opt
    [[ "$opt" =~ ^[yY]$ ]] || return 1
}

# نصب و کانفیگ SSH
prepare_ssh() {
    echo -e "${BLUE}[*] در حال آپدیت مخازن و نصب SSH...${NC}"
    sudo apt update -y && sudo apt install -y openssh-server curl
    sudo systemctl enable --now ssh
    echo -e "${GREEN}[+] سرویس SSH آماده و فعال شد.${NC}"
}

# چاپ خروجی نهایی کاربرپسند
print_result() {
    local user=$1
    local ip=$(hostname -I | awk '{print $1}')
    echo -e "\n${GREEN}==========================================${NC}"
    echo -e "${GREEN}      تنظیمات با موفقیت انجام شد!${NC}"
    echo -e "${GREEN}==========================================${NC}"
    echo -e "${BLUE}اطلاعات جهت اتصال از موبایل (Termux/JuiceSSH):${NC}"
    echo -e "📍 آدرس آی‌پی:  ${YELLOW}$ip${NC}"
    echo -e "👤 نام کاربری:  ${YELLOW}$user${NC}"
    echo -e "🔑 پورت:       ${YELLOW}22${NC}"
    echo -e "------------------------------------------"
    echo -e "${BLUE}نمونه دستور جهت کپی:${NC}"
    echo -e "ssh $user@$ip"
    echo -e "${GREEN}==========================================${NC}"
}

# منوی اصلی
while true; do
    show_banner
    echo -e "1) ساخت کاربر جدید و تنظیم SSH"
    echo -e "2) استفاده از یوزر فعلی (${USER}) و تنظیم SSH"
    echo -e "3) خروج"
    echo -ne "\nگزینه مورد نظر را انتخاب کنید: "
    read -r choice

    case $choice in
        1)
            echo -ne "نام کاربری جدید: "
            read -r username
            if id "$username" &>/dev/null; then
                echo -e "${RED}[!] کاربر از قبل وجود دارد!${NC}"
                sleep 2; continue
            fi
            echo -ne "رمز عبور را وارد کنید: "
            read -rs password; echo
            
            if confirm; then
                sudo useradd -m -s /bin/bash "$username"
                echo "$username:$password" | sudo chpasswd
                echo -ne "آیا این کاربر دسترسی Root (sudo) داشته باشد؟ (y/n): "
                read -r is_admin
                [[ "$is_admin" =~ ^[yY]$ ]] && sudo usermod -aG sudo "$username"
                
                prepare_ssh
                print_result "$username"
                break
            fi
            ;;
        2)
            if confirm; then
                prepare_ssh
                print_result "$USER"
                break
            fi
            ;;
        3) exit 0 ;;
        *) echo -e "${RED}انتخاب اشتباه!${NC}"; sleep 1 ;;
    esac
done
