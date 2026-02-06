#!/bin/bash

# --- رنگ‌ها و استایل ---
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' 

# انتخاب زبان در بدو ورود
clear
echo -e "${BLUE}Please choose your language / لطفا زبان خود را انتخاب کنید:${NC}"
echo -e "1) English"
echo -e "2) فارسی"
echo -ne "\nSelection (1/2): "
read -r lang_choice

if [[ "$lang_choice" == "2" ]]; then
    LANG="FA"
else
    LANG="EN"
fi

# متون دوزبانه
if [[ "$LANG" == "FA" ]]; then
    MSG_BANNER="    SSH Automated Setup Wizard (2026)     "
    MSG_CONFIRM="[?] آیا از انجام این مرحله مطمئن هستید؟ (y/n): "
    MSG_CANCEL="[!] عملیات توسط کاربر لغو شد."
    MSG_UPDATING="[*] در حال آپدیت مخازن و نصب SSH..."
    MSG_SSH_READY="[+] سرویس SSH آماده و فعال شد."
    MSG_SUCCESS="      تنظیمات با موفقیت انجام شد!"
    MSG_INFO_HEAD="اطلاعات جهت اتصال از موبایل (Termux/JuiceSSH):"
    MSG_IP="📍 آدرس آی‌پی: "
    MSG_USER="👤 نام کاربری: "
    MSG_PORT="🔑 پورت:      "
    MSG_EXAMPLE="نمونه دستور جهت کپی:"
    MSG_MENU_1="1) ساخت کاربر جدید و تنظیم SSH"
    MSG_MENU_2="2) استفاده از یوزر فعلی ($USER) و تنظیم SSH"
    MSG_MENU_3="3) خروج"
    MSG_SELECT="گزینه مورد نظر را انتخاب کنید: "
    MSG_USER_EXISTS="[!] کاربر از قبل وجود دارد!"
    MSG_ENTER_USER="نام کاربری جدید: "
    MSG_ENTER_PASS="رمز عبور را وارد کنید: "
    MSG_ASK_SUDO="آیا این کاربر دسترسی Root (sudo) داشته باشد؟ (y/n): "
    MSG_INVALID="انتخاب اشتباه!"
else
    MSG_BANNER="    SSH Automated Setup Wizard (2026)     "
    MSG_CONFIRM="[?] Are you sure you want to proceed? (y/n): "
    MSG_CANCEL="[!] Operation cancelled by user."
    MSG_UPDATING="[*] Updating repositories and installing SSH..."
    MSG_SSH_READY="[+] SSH service is ready and enabled."
    MSG_SUCCESS="      Setup Completed Successfully!"
    MSG_INFO_HEAD="Connection Info for Mobile (Termux/JuiceSSH):"
    MSG_IP="📍 IP Address: "
    MSG_USER="👤 Username:   "
    MSG_PORT="🔑 Port:       "
    MSG_EXAMPLE="Example command to copy:"
    MSG_MENU_1="1) Create new user and setup SSH"
    MSG_MENU_2="2) Use current user ($USER) and setup SSH"
    MSG_MENU_3="3) Exit"
    MSG_SELECT="Please select an option: "
    MSG_USER_EXISTS="[!] User already exists!"
    MSG_ENTER_USER="Enter new username: "
    MSG_ENTER_PASS="Enter password: "
    MSG_ASK_SUDO="Give Root (sudo) access to this user? (y/n): "
    MSG_INVALID="Invalid selection!"
fi

# نمایش بنر
show_banner() {
    clear
    echo -e "${BLUE}==========================================${NC}"
    echo -e "${GREEN}${MSG_BANNER}${NC}"
    echo -e "${BLUE}==========================================${NC}"
}

# تاییدیه قبل از انجام هر مرحله (برگشت‌پذیر)
confirm() {
    echo -ne "${YELLOW}${MSG_CONFIRM}${NC}"
    read -r opt
    [[ "$opt" =~ ^[yY]$ ]] || return 1
}

# نصب و کانفیگ SSH
prepare_ssh() {
    echo -e "${BLUE}${MSG_UPDATING}${NC}"
    sudo apt update -y && sudo apt install -y openssh-server curl
    sudo systemctl enable --now ssh
    echo -e "${GREEN}${MSG_SSH_READY}${NC}"
}

# چاپ خروجی نهایی کاربرپسند
print_result() {
    local user=$1
    local ip=$(hostname -I | awk '{print $1}')
    echo -e "\n${GREEN}==========================================${NC}"
    echo -e "${GREEN}${MSG_SUCCESS}${NC}"
    echo -e "${GREEN}==========================================${NC}"
    echo -e "${BLUE}${MSG_INFO_HEAD}${NC}"
    echo -e "${MSG_IP} ${YELLOW}$ip${NC}"
    echo -e "${MSG_USER} ${YELLOW}$user${NC}"
    echo -e "${MSG_PORT} ${YELLOW}22${NC}"
    echo -e "------------------------------------------"
    echo -e "${BLUE}${MSG_EXAMPLE}${NC}"
    echo -e "ssh $user@$ip"
    echo -e "${GREEN}==========================================${NC}"
}

# منوی اصلی
while true; do
    show_banner
    echo -e "${MSG_MENU_1}"
    echo -e "${MSG_MENU_2}"
    echo -e "${MSG_MENU_3}"
    echo -ne "\n${MSG_SELECT}"
    read -r choice

    case $choice in
        1)
            echo -ne "${MSG_ENTER_USER}"
            read -r username
            if id "$username" &>/dev/null; then
                echo -e "${RED}${MSG_USER_EXISTS}${NC}"
                sleep 2; continue
            fi
            echo -ne "${MSG_ENTER_PASS}"
            read -rs password; echo
            
            if confirm; then
                sudo useradd -m -s /bin/bash "$username"
                echo "$username:$password" | sudo chpasswd
                echo -ne "${MSG_ASK_SUDO}"
                read -r is_admin
                [[ "$is_admin" =~ ^[yY]$ ]] && sudo usermod -aG sudo "$username"
                
                prepare_ssh
                print_result "$username"
                break
            else
                echo -e "${RED}${MSG_CANCEL}${NC}"
                sleep 2
            fi
            ;;
        2)
            if confirm; then
                prepare_ssh
                print_result "$USER"
                break
            else
                echo -e "${RED}${MSG_CANCEL}${NC}"
                sleep 2
            fi
            ;;
        3) exit 0 ;;
        *) echo -e "${RED}${MSG_INVALID}${NC}"; sleep 1 ;;
    esac
done
