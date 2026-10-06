untuk smartvue 
kalo pake IP
argument = "ip_ftp" "user" "password"
kalo host 
argument = "host_ftp" "user" "password"



untuk miror clr file
Secret Server 
download  clr_mirror_script.ps1 kemudian pindah sesuai folder di secret server 
IIS :
buat site, 
dan ini parameter :
site name  : bebas 
pisical path: pilih folder sesuai yang sebelumnya di buat 
type : http 
hostname : masukan host yang digunakan untuk crl 

CMD run admmin 
buat schaduler :
schtasks /create /tn "CLR Mirror Update" /tr "powershell.exe -NoProfile -ExecutionPolicy Bypass -File E:\Clr_Miror\clr_mirror.ps1" /sc HOURLY /mo 1 /ru SYSTEM /rl HIGHEST /f

test run schaduler 
schtasks /run /tn "CLR Mirror Update"

list schaduler 
schtasks /query /tn "CLR Mirror Update" /v /fo list

Session connector 
tambahkan pada etc\host untuk crl url ke secret server 




