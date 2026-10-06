untuk smartvue 
kalo pake IP
argument = "ip_ftp" "user" "password"
kalo host 
argument = "host_ftp" "user" "password"



untuk miror clr file<br>
Secret Server <br>
download  clr_mirror_script.ps1 kemudian pindah sesuai folder di secret server <br>
IIS :<br>
buat site, <br>
dan isi parameter :<br>
site name  : bebas <br>
pisical path: pilih folder sesuai yang sebelumnya di buat <br>
type : http <br>
hostname : masukan host yang digunakan untuk crl <br>
<br>
CMD run admin <br> 
buat schaduler : <br>
schtasks /create /tn "CLR Mirror Update" /tr "powershell.exe -NoProfile -ExecutionPolicy Bypass -File E:\Clr_Miror\clr_mirror.ps1" /sc HOURLY /mo 1 /ru SYSTEM /rl HIGHEST /f<br>
<br>
<br>
test run schaduler <br>
schtasks /run /tn "CLR Mirror Update"<br>

list schaduler <br>
schtasks /query /tn "CLR Mirror Update" /v /fo list<br>
<br>
Session connector <br>
tambahkan pada etc\host untuk crl url ke secret server <br>




