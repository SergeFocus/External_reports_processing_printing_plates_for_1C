@echo off
chcp 1251
set DATA=`date +%F.%H%M%S`
set ARC="C:\Program Files\7-Zip\7z.exe"
set CC="C:\Program Files (x86)\1cv8\8.3.10.2580\bin\1cv8.exe"
set USR="s"
set PSW="s"

set TARGET="C:\Users\admin\Desktop\19.10.2018\*"
set DESTINATION="C:\Users\admin\Desktop\19.10.2018\%DATE%.7z"
set LOG="C:\Users\admin\Desktop\19.10.2018\%DATE%.txt"
set PAS="C:\Users\admin\Desktop\19.10.2018"

echo  ��������� ������ ������������� �� 1�

rem %CC% ENTERPRISE /F%PAS% /N%USR% /P%PSW% /WA- /AU- /DisableStartupMessages /C���������������������������� /Out%LOG% -NoTruncate

%CC% ENTERPRISE /F%PAS% /N%USR% /P%PSW% /WA- /AU- /DisableStartupMessages /C���������������������������� /UC������������� /Out%LOG% -NoTruncate

goto answer%ERRORLEVEL%

:answer0
echo ������������ ������ �������  >> %LOG%
echo ������������ ������ ������� 
goto exit

:answer3
echo  ������� ������ >> %LOG%
echo  ������� ������
goto exit

:answer1
echo  ������� ������ >> %LOG%
echo  ������� ������
goto exit

:answer101
echo � ������ ������� ������  >> %LOG%
echo � ������ ������� ������
goto exit

:error
echo ������ � ������  >> %LOG%
echo ������ � ������
goto exit

:exit