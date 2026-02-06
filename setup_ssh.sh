#!/bin/bash

export LC_ALL=C
export LANG=en_US.UTF-8

# --- رنگ‌ها و استایل ---
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
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
    MSG_UPDATING="[*] در حال آپدیت مخازن و نصب SSH (لطفا کمی صبر کنید)..."
    MSG_SSH_READY="[+] سرویس SSH آماده و فعال شد."
    MSG_SUCCESS="      تنظیمات با موفقیت انجام شد!"
    MSG_INFO_HEAD="اطلاعات جهت اتصال (Local/Tailscale):"
    MSG_IP="📍 آدرس آی‌پی: "
    MSG_USER="👤 نام کاربری: "
    MSG_PORT="🔑 پورت:      "
    MSG_EXAMPLE="نمونه دستور جهت کپی:"
    MSG_SHORTCUT="[+] میانبر ایجاد شد! از این پس با دستور 'setupssh' در هر جا وارد شوید."
    # منوها
    MSG_MENU_1="1) ساخت کاربر جدید و تنظیم SSH"
    MSG_MENU_2="2) استفاده از یوزر فعلی ($USER) و تنظیم SSH"
    MSG_MENU_3="3) نصب و راه‌اندازی Tailscale (دسترسی جهانی)"
    MSG_MENU_4="4) خروج"
    MSG_SELECT="گزینه مورد نظر را انتخاب کنید: "
    # پیام‌های ورودی و خطا
    MSG_USER_EXISTS="[!] کاربر از قبل وجود دارد!"
    MSG_ENTER_USER="نام کاربری جدید: "
    MSG_ENTER_PASS="رمز عبور را وارد کنید: "
    MSG_ASK_SUDO="آیا این کاربر دسترسی Root (sudo) داشته باشد؟ (y/n): "
    MSG_INVALID="انتخاب اشتباه!"
    # پیام‌های Tailscale
    MSG_TS_INSTALL="[*] در حال دانلود و نصب سرویس Tailscale..."
    MSG_TS_AUTH="[!] لطفاً لینک زیر را باز کنید و احراز هویت را انجام دهید:"
    MSG_TS_DONE="[+] اتصال Tailscale با موفقیت برقرار شد."
else
    MSG_BANNER="    SSH Automated Setup Wizard (2026)     "
    MSG_CONFIRM="[?] Are you sure you want to proceed? (y/n): "
    MSG_CANCEL="[!] Operation cancelled by user."
    MSG_UPDATING="[*] Updating repositories and installing SSH (Please wait)..."
    MSG_SSH_READY="[+] SSH service is ready and enabled."
    MSG_SUCCESS="      Setup Completed Successfully!"
    MSG_INFO_HEAD="Connection Info (Local/Tailscale):"
    MSG_IP="📍 IP Address: "
    MSG_USER="👤 Username:   "
    MSG_PORT="🔑 Port:       "
    MSG_EXAMPLE="Example command to copy:"
    MSG_SHORTCUT="[+] Shortcut created! Use 'setupssh' command from anywhere."
    # Menus
    MSG_MENU_1="1) Create new user and setup SSH"
    MSG_MENU_2="2) Use current user ($USER) and setup SSH"
    MSG_MENU_3="3) Install & Setup Tailscale (Global Access)"
    MSG_MENU_4="4) Exit"
    MSG_SELECT="Please select an option: "
    # Input/Error messages
    MSG_USER_EXISTS="[!] User already exists!"
    MSG_ENTER_USER="Enter new username: "
    MSG_ENTER_PASS="Enter password: "
    MSG_ASK_SUDO="Give Root (sudo) access to this user? (y/n): "
    MSG_INVALID="Invalid selection!"
    # Tailscale messages
    MSG_TS_INSTALL="[*] Downloading and installing Tailscale service..."
    MSG_TS_AUTH="[!] Please open the link below to authenticate:"
    MSG_TS_DONE="[+] Tailscale connected successfully."
fi

# ایجاد میانبر (Symlink) برای اجرای سریع
create_shortcut() {
    local script_path=$(readlink -f "$0")
    if [[ ! -f "/usr/local/bin/setupssh" ]]; then
        sudo ln -sf "$script_path" /usr/local/bin/setupssh > /dev/null 2>&1
        sudo chmod +x /usr/local/bin/setupssh > /dev/null 2>&1
        echo -e "${CYAN}${MSG_SHORTCUT}${NC}"
        sleep 2
    fi
}

# نمایش بنر
show_banner() {
    clear
    echo -e "${BLUE}==========================================${NC}"
    echo -e "${GREEN}${MSG_BANNER}${NC}"
    echo -e "${BLUE}==========================================${NC}"
}

# تاییدیه قبل از انجام هر مرحله
confirm() {
    echo -ne "${YELLOW}${MSG_CONFIRM}${NC}"
    read -r opt
    [[ "$opt" =~ ^[yY]$ ]] || return 1
}

# نصب و کانفیگ SSH (هوشمند و بدون پیام‌های ترسناک)
prepare_ssh() {
    echo -e "${BLUE}${MSG_UPDATING}${NC}"
    # چک کردن نصب بودن (برای جلوگیری از آپدیت بی مورد)
    if ! command -v sshd >/dev/null 2>&1 || ! command -v curl >/dev/null 2>&1; then
        sudo apt update -y > /dev/null 2>&1
        sudo apt install -y openssh-server curl > /dev/null 2>&1
    fi
    sudo systemctl enable --now ssh > /dev/null 2>&1
    echo -e "${GREEN}${MSG_SSH_READY}${NC}"
}

# نصب و کانفیگ Tailscale (بهینه‌سازی شده برای ایرانسل و 2026)

setup_tailscale() {
    sudo rm -f /etc/apt/sources.list.d/tailscale.list > /dev/null 2>&1

    if ! command -v tailscale >/dev/null 2>&1; then
        echo -e "${CYAN}${MSG_TS_INSTALL}${NC}"
        curl -fsSL https://tailscale.com/install.sh | sh > /dev/null 2>&1
    fi

    echo -e "${YELLOW}${MSG_TS_AUTH}${NC}"
    
    # اجرای دستور در پس‌زمینه برای لحظه‌ای، تا اینترفیس ساخته شود و MTU را سریع کم کنیم
    sudo tailscale up --reset --force-reauth & 
    sleep 2
    
    # تلاش مکرر برای تنظیم MTU به محض ساخته شدن اینترفیس
    sudo ip link set dev tailscale0 mtu 1280 > /dev/null 2>&1
    
    # حالا صبر می‌کنیم تا کاربر مرحله لاگین را تمام کند
    wait $! 2>/dev/null || sudo tailscale up --reset

    echo -e "${GREEN}${MSG_TS_DONE}${NC}"
    
    ts_ip=$(tailscale ip -4)
    print_result "$USER" "$ts_ip"
}

# چاپ خروجی نهایی (ادغام با ساختار شما + تراز بصری)
print_result() {
    local user=$1
    local custom_ip=$2
    local final_ip
    
    if [[ -n "$custom_ip" ]]; then
        final_ip="$custom_ip"
    else
        final_ip=$(hostname -I | awk '{print $1}')
    fi

    echo -e "\n${GREEN}==========================================${NC}"
    echo -e "${GREEN}${MSG_SUCCESS}${NC}"
    echo -e "${GREEN}==========================================${NC}"
    echo -e "${BLUE}${MSG_INFO_HEAD}${NC}"
    
    # استفاده از printf برای تراز شدن خروجی بصری
    printf "${MSG_IP} ${YELLOW}%s${NC}\n" "$final_ip"
    printf "${MSG_USER} ${YELLOW}%s${NC}\n" "$user"
    printf "${MSG_PORT} ${YELLOW}%s${NC}\n" "22"
    
    echo -e "------------------------------------------"
    echo -e "${BLUE}${MSG_EXAMPLE}${NC}"
    echo -e "${YELLOW}ssh $user@$final_ip${NC}"
    echo -e "${GREEN}==========================================${NC}"
}

# اجرای میانبر در شروع
create_shortcut

# منوی اصلی
while true; do
    show_banner
    echo -e "${MSG_MENU_1}"
    echo -e "${MSG_MENU_2}"
    echo -e "${MSG_MENU_3}"
    echo -e "${MSG_MENU_4}"
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
                sudo useradd -m -s /bin/bash "$username" > /dev/null 2>&1
                echo "$username:$password" | sudo chpasswd
                echo -ne "${MSG_ASK_SUDO}"
                read -r is_admin
                [[ "$is_admin" =~ ^[yY]$ ]] && sudo usermod -aG sudo "$username" > /dev/null 2>&1
                
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
        3)
            if confirm; then
                setup_tailscale
                break
            else
                echo -e "${RED}${MSG_CANCEL}${NC}"
                sleep 2
            fi
            ;;
        4) exit 0 ;;
        *) echo -e "${RED}${MSG_INVALID}${NC}"; sleep 1 ;;
    esac
done
