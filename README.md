Delinea Supporting Configuration
1. SmartVU
Menggunakan IP FTP
Jika SmartVU menggunakan IP, gunakan argument:
```text
"ip_ftp" "user" "password"
```
Contoh:
```text
"192.168.1.10" "ftpuser" "password"
```
Menggunakan Hostname FTP
Jika SmartVU menggunakan hostname, gunakan argument:
```text
"host_ftp" "user" "password"
```
Contoh:
```text
"ftp.domain.local" "ftpuser" "password"
```
---
2. CRL Mirror
CRL Mirror digunakan agar Session Connector dapat melakukan certificate revocation check tanpa harus mengakses CRL server di Internet secara langsung.
A. Secret Server
1. Download Script
Download file:
```text
crl_mirror_script.ps1
```
Kemudian pindahkan script ke folder CRL Mirror di Secret Server.
Contoh folder:
```text
E:\CRL_Miror\
```
Contoh struktur:
```text
E:\CRL_Miror\
├── crl_mirror.ps1
├── GeoTrustTLSRSACAG1.crl
└── crl-download.log
```
Contoh CRL yang digunakan:
```text
http://cdp.geotrust.com/GeoTrustTLSRSACAG1.crl
```
---
B. Konfigurasi IIS
Buka:
```text
IIS Manager
→ Sites
→ Add Website
```
Isi parameter:
Parameter	Value
Site Name	Bebas, contoh `CRL-Mirror`
Physical Path	Folder CRL Mirror, contoh `E:\CRL_Miror`
Type	`http`
Port	`80`
Host Name	Hostname yang digunakan pada CRL URL
Contoh CRL URL:
```text
http://cdp.geotrust.com/GeoTrustTLSRSACAG1.crl
```
Maka Host Name IIS:
```text
cdp.geotrust.com
```
Pastikan:
```text
Anonymous Authentication : Enabled
```
Tambahkan MIME Type:
```text
Extension : .crl
MIME Type : application/pkix-crl
```
---
C. Membuat Scheduled Task
Buka:
```text
CMD → Run as Administrator
```
Buat scheduled task setiap 1 jam:
```cmd
schtasks /create /tn "CRL Mirror Update" /tr "powershell.exe -NoProfile -ExecutionPolicy Bypass -File E:\CRL_Miror\crl_mirror.ps1" /sc HOURLY /mo 1 /ru SYSTEM /rl HIGHEST /f
```
Test Scheduled Task
Jalankan task secara manual:
```cmd
schtasks /run /tn "CRL Mirror Update"
```
Cek Scheduled Task
```cmd
schtasks /query /tn "CRL Mirror Update" /v /fo list
```
Pastikan hasil terakhir:
```text
Status      : Ready
Last Result : 0
```
`Last Result : 0` berarti scheduled task berhasil.
Cek Log CRL Mirror
```cmd
type E:\CRL_Miror\crl-download.log
```
Contoh log sukses:
```text
[INFO] Starting CRL download
[INFO] Download attempt 1 of 3
[SUCCESS] Download attempt 1 successful.
[INFO] Downloaded CRL validation successful.
[INFO] Old CRL file deleted.
[SUCCESS] CRL download successful.
```
---
D. Session Connector
Edit file:
```text
C:\Windows\System32\drivers\etc\hosts
```
Tambahkan hostname CRL dan arahkan ke IP Secret Server.
Contoh:
```text
10.16.114.221    cdp.geotrust.com
```
Kemudian flush DNS:
```cmd
ipconfig /flushdns
```
Cek resolusi:
```cmd
ping cdp.geotrust.com
```
Hostname harus resolve ke IP Secret Server.
Contoh:
```text
cdp.geotrust.com → 10.16.114.221
```
---
E. Test CRL dari Session Connector
Download CRL menggunakan curl:
```cmd
curl.exe -v http://cdp.geotrust.com/GeoTrustTLSRSACAG1.crl -o GeoTrustTLSRSACAG1.crl
```
Jika berhasil, output harus menunjukkan:
```text
Established connection to cdp.geotrust.com (10.16.114.221 port 80)

HTTP/1.1 200 OK
Content-Type: application/pkix-crl
Server: Microsoft-IIS/10.0
```
Validasi file CRL:
```cmd
certutil -dump GeoTrustTLSRSACAG1.crl
```
Pastikan informasi seperti berikut dapat dibaca:
```text
Issuer
This Update
Next Update
CRL Entries
```
---
F. Flow CRL Mirror
```text
Internet CRL Server
cdp.geotrust.com
        |
        | Scheduled Download setiap 1 jam
        v
Secret Server
10.16.114.221
        |
        | E:\CRL_Miror\GeoTrustTLSRSACAG1.crl
        |
        | IIS HTTP/80
        v
Session Connector
        |
        | hosts override
        v
cdp.geotrust.com → 10.16.114.221
```
---
Catatan
Secret Server harus tetap dapat resolve:
```text
cdp.geotrust.com
```
ke Internet agar script dapat melakukan download CRL terbaru.
Jangan tambahkan hosts override berikut pada Secret Server:
```text
10.16.114.221    cdp.geotrust.com
```
Hosts override hanya digunakan pada Session Connector.
Dengan demikian:
```text
Secret Server
cdp.geotrust.com → Internet

Session Connector
cdp.geotrust.com → Secret Server / IIS CRL Mirror
```
