⚙️ Konfigurasi Lengkap Topologi WLC Wisata Alam 🌿
Konfigurasi ini mengikuti rencana VLAN sebelumnya dan dikerjakan berurutan, mulai dari Switch, Server, PC, WLC, AP, lalu Laptop.
📋 Rencana Alamat dan Port
Perangkat	Port Switch	VLAN	IP
🗄️ Server0	Fa0/1	10	192.168.10.10
🖥️ WLC	Fa0/2 (trunk)	10	192.168.10.2
📡 AP 3702i	Fa0/3	20	DHCP (192.168.20.x)
💻 PC0	Fa0/4	10	192.168.10.50
📱 Laptop0	WiFi	30	DHCP (192.168.30.x)
1️⃣ Switch 3560-24PS 🔀
enable
configure terminal
hostname SW-WISATA

! --- VLAN ---
vlan 10
 name MANAJEMEN
vlan 20
 name AP-MGMT
vlan 30
 name PENGUNJUNG
exit

! --- Layer 3 (gateway tiap VLAN) ---
ip routing

interface vlan 10
 ip address 192.168.10.1 255.255.255.0
 no shutdown
interface vlan 20
 ip address 192.168.20.1 255.255.255.0
 ip helper-address 192.168.10.10
 no shutdown
interface vlan 30
 ip address 192.168.30.1 255.255.255.0
 ip helper-address 192.168.10.10
 no shutdown
exit

! --- Port Server0 ---
interface fa0/1
 switchport mode access
 switchport access vlan 10
 no shutdown

! --- Port WLC (trunk) ---
interface fa0/2
 switchport trunk encapsulation dot1q
 switchport mode trunk
 switchport trunk native vlan 10
 switchport trunk allowed vlan 10,20,30
 no shutdown

! --- Port AP (PoE otomatis aktif) ---
interface fa0/3
 switchport mode access
 switchport access vlan 20
 no shutdown

! --- Port PC admin ---
interface fa0/4
 switchport mode access
 switchport access vlan 10
 no shutdown
end
write memory

💡 ip helper-address meneruskan permintaan DHCP dari VLAN 20 dan 30 ke Server0 yang berada di VLAN 10.

2️⃣ Server0 🗄️ (tab Config)

FastEthernet0

🌐 IP Address: 192.168.10.10
🌐 Subnet Mask: 255.255.255.0
🚪 Default Gateway: 192.168.10.1
🔍 DNS Server: 192.168.10.10

Services > DHCP (hidupkan Service: On, lalu buat 2 pool):

Field	Pool AP	Pool Pengunjung
Pool Name	POOL-AP	POOL-WISATA
Default Gateway	192.168.20.1	192.168.30.1
DNS Server	192.168.10.10	192.168.10.10
Start IP	192.168.20.10	192.168.30.10
Subnet Mask	255.255.255.0	255.255.255.0
Max User	50	200
WLC Address	192.168.10.2	(kosongkan)

Klik Add pada tiap pool 💾. Kolom WLC Address penting agar AP bisa menemukan controller. 🔎

3️⃣ PC0 💻 (tab Desktop > IP Configuration)
🌐 IP Address: 192.168.10.50
🌐 Subnet Mask: 255.255.255.0
🚪 Default Gateway: 192.168.10.1
🔍 DNS Server: 192.168.10.10
4️⃣ WLC-2504 🖥️

A. Alamat manajemen (tab Config > Management)

🌐 IP Address: 192.168.10.2
🌐 Subnet Mask: 255.255.255.0
🚪 Gateway: 192.168.10.1

B. Buka antarmuka web dari PC0 🌍

Desktop > Web Browser > buka http://192.168.10.2
👤 Username: admin
🔑 Password: Cisco123 (default Packet Tracer)

C. Buat interface VLAN pengunjung (menu CONTROLLER > Interfaces > New)

🏷️ Interface Name: PENGUNJUNG
🔢 VLAN ID: 30
🌐 IP Address: 192.168.30.2
🌐 Netmask: 255.255.255.0
🚪 Gateway: 192.168.30.1
📨 Primary DHCP Server: 192.168.10.10
Klik Apply ✅

D. Buat WLAN / SSID (menu WLANs > Create New > Go)

📛 Profile Name: Wisata-Alam
📶 SSID: Wisata-Alam
🔢 ID: 1
Tab General: Status Enabled ✅, Interface PENGUNJUNG
Tab Security > Layer 2: Layer 2 Security WPA2 + PSK, isi password misalnya wisata12345 🔐
Klik Apply 💾
5️⃣ AP 3702i 📡
🔌 Pastikan lampu link di kabel hijau (daya PoE dan data sudah masuk).
⏳ Tunggu 1 sampai 2 menit. AP mendapat IP dari pool POOL-AP, menemukan WLC lewat WLC Address, lalu membentuk tunnel CAPWAP. 🔗
✅ Cek di WLC: menu WIRELESS > Access Points. AP harus muncul di daftar.
6️⃣ Laptop0 📱
🔴 Matikan laptop, lalu ganti modul Ethernet dengan modul WPC300N (wireless). Nyalakan kembali.
⚙️ Buka tab Config > Wireless0:
📶 SSID: Wisata-Alam
🔐 Authentication: WPA2-PSK, isi wisata12345
🌐 IP Configuration: DHCP
🎉 Laptop akan mendapat IP 192.168.30.x.
🧪 Pengujian
Uji	Perintah / Cara	Hasil yang diharapkan
🔀 VLAN aktif	show vlan brief di switch	VLAN 10, 20, 30 muncul
🔌 Trunk WLC	show interfaces trunk	Fa0/2 berstatus trunking
📨 DHCP	ipconfig di Laptop0	IP 192.168.30.x
🏓 Konektivitas	ping 192.168.10.10 dari Laptop0	Reply dari Server0
📡 AP terdaftar	WLC > WIRELESS > Access Points	AP 3702i tampil
⚠️ Jika AP Belum Muncul di WLC
🔸 Cek WLC Address di pool POOL-AP sudah 192.168.10.2.
🔸 Pastikan ip helper-address ada di VLAN 20.
🔸 Pastikan ping 192.168.10.2 dari switch berhasil.
🔸 Tunggu lebih lama. Packet Tracer kadang butuh beberapa menit untuk registrasi AP. ⏱️
