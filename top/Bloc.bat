@echo off
chcp 1251
set DATA=`date +%F.%H%M%S`
set ARC="C:\Program Files\7-Zip\7z.exe"
set CC="C:\Program Files (x86)\1cv8\8.3.10.2252\bin\1cv8.exe"
set USR="s"
set PSW="s"

set TARGET="C:\Base1C\TopCredit\*"
set DESTINATION="C:\Base1C\BskcUP\%DATE%.7z"
set LOG="C:\Base1C\BskcUP\%DATE%.txt"
set PAS="C:\Base1C\TopCredit"

echo  ��������� ������ ������������� �� 1�

%CC% ENTERPRISE /F%PAS% /N%USR% /P%PSW% /WA- /AU- /DisableStartupMessages /C���������������������������� /Out%LOG% -NoTruncate

rem %CC% ENTERPRISE /F%PAS% /N%USR% /P%PSW% /WA- /AU- /DisableStartupMessages /C���������������������������� /UC������������� /Out%LOG% -NoTruncate

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