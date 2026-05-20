# Ringkasan Frappe Docker Development

Repo ini digunakan untuk membuat environment development Frappe secara lokal menggunakan Docker. Cara utama yang disarankan adalah memakai wizard `setup-frappe-dev.sh`.

## 1. Prasyarat

Install dulu:

- Git
- Docker Desktop
- Docker Compose

Untuk macOS, cukup install Docker Desktop lalu pastikan Docker sedang berjalan.

Cek dengan:

```bash
docker info
docker compose version
git --version
```

## 2. Jalankan Wizard

Masuk ke folder repo:

```bash
cd /Users/apple/Documents/Codes/Python/frappe-development-server-setup
```

Jalankan wizard:

```bash
./setup-frappe-dev.sh
```

Jika belum bisa dijalankan:

```bash
chmod +x setup-frappe-dev.sh
./setup-frappe-dev.sh
```

Wizard akan menanyakan:

- Nama project
- Versi Frappe
- Port yang akan dipakai
- Docker subnet
- SSH key, opsional
- Konfirmasi setup

Biasanya kamu bisa menerima default yang diberikan wizard.

## 3. Hasil dari Wizard

Wizard akan membuat:

```text
.env.<PROJECT_NAME>
<PROJECT_NAME>-docker/
```

Dan menjalankan container Docker:

```text
frappe-<PROJECT_NAME>
mariadb-<PROJECT_NAME>
cache-<PROJECT_NAME>
queue-<PROJECT_NAME>
socketio-<PROJECT_NAME>
```

Setelah selesai, wizard akan otomatis masuk ke terminal container Frappe.

## 4. Inisialisasi Frappe di Dalam Container

Saat sudah masuk ke container dan berada di folder `/workspace`, jalankan startup script sesuai versi Frappe yang dipilih.

Contoh untuk Frappe v16:

```bash
source frappe-bench-startup-v16.sh
```

Untuk versi lain:

```bash
source frappe-bench-startup-v12.sh
source frappe-bench-startup-v13.sh
source frappe-bench-startup-v14.sh
source frappe-bench-startup-v15.sh
source frappe-bench-startup-v16.sh
```

Penting: gunakan `source`, bukan `bash`.

Script ini akan menyiapkan bench, dependency, database, dan site Frappe.

## 5. Jalankan Frappe

Setelah startup script selesai:

```bash
cd /workspace/frappe-bench
bench start
```

Lalu buka di browser:

```text
http://<PROJECT_NAME>.localhost:8000
```

Contoh:

```text
http://erpnext-demo.localhost:8000
```

Login default:

```text
User: Administrator
Password: administrator
```

## 6. Install ERPNext, Opsional

Jika ingin install ERPNext, jalankan di dalam container setelah Frappe selesai diinisialisasi:

```bash
cd /workspace/frappe-bench
bench get-app --branch version-16 erpnext https://github.com/frappe/erpnext.git
bench --site "$SITE_NAME" install-app erpnext
```

Sesuaikan branch dengan versi Frappe:

```text
Frappe v14 -> version-14
Frappe v15 -> version-15
Frappe v16 -> version-16
```

## 7. Install App Project Sendiri

Untuk repo HTTPS:

```bash
cd /workspace/frappe-bench
bench get-app https://example.com/myapp.git
bench --site "$SITE_NAME" install-app myapp
```

Untuk repo SSH:

```bash
cd /workspace/frappe-bench
bench get-app git@example.com:group/myapp.git
bench --site "$SITE_NAME" install-app myapp
```

Jika repo private, gunakan SSH key saat wizard menanyakan SSH key.

## 8. Masuk Lagi ke Container

Jika stack masih berjalan:

```bash
docker exec -e "TERM=xterm-256color" -it frappe-<PROJECT_NAME> bash
```

Jika stack berhenti:

```bash
docker compose --env-file ./.env.<PROJECT_NAME> up -d
docker exec -e "TERM=xterm-256color" -it frappe-<PROJECT_NAME> bash
```

## 9. Lokasi File Project

Kode Frappe dan app berada di:

```text
<PROJECT_NAME>-docker/frappe-bench/apps
```

Di dalam container, path-nya:

```text
/workspace/frappe-bench/apps
```

## 10. Import Database dari Instance Lain

Langkah umum:

1. Install app yang sama dengan source instance.
2. Download backup database `.sql`.
3. Taruh file `.sql` di folder `<PROJECT_NAME>-docker/`.
4. Masuk ke container.
5. Import database:

```bash
mysql -uroot -proot -h mariadb-<PROJECT_NAME> erpnext < backup.sql
cd /workspace/frappe-bench
bench migrate
```

## Troubleshooting Singkat

Jika Docker belum jalan, buka Docker Desktop, tunggu sampai running, lalu jalankan wizard lagi.

Jika port bentrok, jalankan wizard ulang lalu pilih re-scan network.

Jika salah nama project:

```bash
docker compose --env-file ./.env.<PROJECT_NAME> down
rm -rf .env.<PROJECT_NAME> <PROJECT_NAME>-docker
```

Jika muncul error database sudah ada, jalankan wizard lagi. Jika ditanya reset MariaDB volume, pilih reset hanya kalau ingin database lokal dihapus.

Jika SSH clone gagal:

```bash
ls -la /home/frappe/.ssh
cat /home/frappe/.ssh/config
ssh -T git@example.com
```

Ganti `git@example.com` dengan host Git yang kamu gunakan.

## Alur Paling Singkat

```bash
cd /Users/apple/Documents/Codes/Python/frappe-development-server-setup
./setup-frappe-dev.sh
source frappe-bench-startup-v16.sh
cd /workspace/frappe-bench
bench start
```

Intinya: jalankan wizard, masuk container, jalankan `source frappe-bench-startup-v*.sh`, lalu jalankan `bench start`.
