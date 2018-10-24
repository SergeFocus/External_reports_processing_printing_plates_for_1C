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

echo  Завершаем работу пользователей из 1С

%CC% ENTERPRISE /F%PAS% /N%USR% /P%PSW% /WA- /AU- /DisableStartupMessages /CЗавершитьРаботуПользователей /Out%LOG% -NoTruncate

rem %CC% ENTERPRISE /F%PAS% /N%USR% /P%PSW% /WA- /AU- /DisableStartupMessages /CРазрешитьРаботуПользователей /UCКодРазрешения /Out%LOG% -NoTruncate

goto answer%ERRORLEVEL%

:answer0
echo тестирование прошло успешно  >> %LOG%
echo тестирование прошло успешно 
goto exit

:answer3
echo  имеются ошибки >> %LOG%
echo  имеются ошибки
goto exit

:answer1
echo  имеются ошибки >> %LOG%
echo  имеются ошибки
goto exit

:answer101
echo в данных имеются ошибки  >> %LOG%
echo в данных имеются ошибки
goto exit

:error
echo ошибка в Архиве  >> %LOG%
echo ошибка в Архиве
goto exit

:exit