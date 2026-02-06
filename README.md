# 🚀 Smart SSH Setup Wizard — 2026 Edition

![SSH Banner](https://img.shields.io/badge/SSH-Automated_Setup-blue?style=for-the-badge&logo=openssh)
![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)
![Platform](https://img.shields.io/badge/Platform-Linux-orange?style=for-the-badge&logo=linux)

---

## 🧠 What is this?

### 🇮🇷 فارسی
**Smart SSH Setup Wizard** 

یک اسکریپت هوشمند، ایمن و تعاملی برای راه‌اندازی سرویس SSH روی لینوکس است.  
طراحی شده برای کسانی که می‌خواهند **در کمترین زمان**، با **حداقل خطا** و **بیشترین شفافیت**، سیستم خود را برای اتصال از موبایل (Termux / JuiceSSH) یا کلاینت‌های دسکتاپ آماده کنند.

### 🇺🇸 English
**Smart SSH Setup Wizard** is an intelligent, safe, and interactive script for configuring SSH on Linux.  
Built for users who want a **fast**, **clear**, and **mistake-resistant** SSH setup — especially for mobile clients like Termux or JuiceSSH.

---

## ⚡ One-Line Installer (Zero Friction)

### 📥 Install & Run (Recommended)

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/rezajavadi995/Smart-SSH-Setup-Wizard-2026-Edition-/main/setup_ssh.sh)"
```


## ✨ Key Features | ویژگی‌ها

### 🔐 Secure by Design | امنیت از پایه
- Interactive confirmation before **any sensitive action**
- Masked password input (no echo, no leaks)
- Safe defaults with fully **reversible steps**

- گرفتن تأیید قبل از هر تغییر حساس
- مخفی بودن کامل پسورد هنگام تایپ
- تنظیمات امن پیش‌فرض با امکان بازگشت

---

### 👤 Smart User Management | مدیریت هوشمند کاربران
- Create a new dedicated SSH user
- Optional **sudo (root) access**
- Prevents accidental system lockout

- ساخت کاربر اختصاصی برای SSH
- دسترسی sudo به‌صورت اختیاری
- جلوگیری از قفل شدن ناخواسته سیستم

---

### 🌐 Auto Network Intelligence | تشخیص هوشمند شبکه
- Automatically detects local IP address
- Detects active network interface
- Instantly shows **ready-to-copy SSH connection examples**



---

### 🛡️ Tailscale Integration | اتصال امن با Tailscale
- Optional automatic setup of **Tailscale VPN**
- Enables secure SSH access **without port forwarding**
- Works seamlessly behind NAT, CGNAT, or dynamic IPs

- راه‌اندازی اختیاری و خودکار Tailscale
- اتصال امن SSH بدون نیاز به باز کردن پورت
- قابل استفاده پشت NAT، CGNAT و آی‌پی داینامیک

- شناسایی خودکار آی‌پی سیستم
- تشخیص اینترفیس فعال شبکه
- نمایش دستور اتصال SSH آماده‌ی کپی
