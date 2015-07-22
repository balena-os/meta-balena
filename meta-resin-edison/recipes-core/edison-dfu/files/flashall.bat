::batch file for win platform
@echo off
set BASE_DIR=%~dp0
set USB_VID=8087
set USB_PID=0a99
set /a TIMEOUT=60

::Phone flash tools configuration part
set DO_RECOVERY=0
set EDISON_XML_FILE="%BASE_DIR%pft-config-edison.xml"
set PFT_XML_FILE="%BASE_DIR%pft-config-edison.xml"

:: Handle Ifwi file for DFU update
set IFWI_DFU_FILE=%BASE_DIR%edison_ifwi-dbg

set VAR_DIR=%BASE_DIR%u-boot-envs\
set VARIANT_NAME_DEFAULT=edison-defaultrndis
set VARIANT_NAME_BLANK=edison-blankrndis
set VARIANT_NAME=%VARIANT_NAME_BLANK%

set LOG_FILENAME=flash.log
set /a verbose_output=0
:: ********************************************************************
:: parse arg
set show_help=0
set argcount=0
set appname=%0
:parse_arg_start
if -%1-==-- goto parse_arg_end
if -%1- == ---recovery- (
	set /a DO_RECOVERY=1
)
if -%1- == ---keep-data- (
	set VARIANT_NAME=%VARIANT_NAME_DEFAULT%
)
if -%1- == -/?- set /a show_help=1
if -%1- == --h- set /a show_help=1
if -%1- == ---help- set /a show_help=1
if -%1- == --v- set /a verbose_output=1
set /a argcount+= 1
shift
goto :parse_arg_start
:parse_arg_end

:: handle help on cmd arg
if %show_help% == 1 (
	call:print-usage %appname%
	exit /b
)

if %verbose_output% == 1 goto skip_init_log
echo ** Flashing Edison Board %date% %time% ** >> %LOG_FILENAME%
:skip_init_log

:: ********************************************************************
:: Ifwi flashing part
if %DO_RECOVERY% == 0 goto :skip_flash_ifwi
echo Starting Recovery mode
echo Please plug and reboot the board
if not exist %PFT_XML_FILE% (
	echo %PFT_XML_FILE% does not exist
	exit /b 3
)
echo Flashing IFWI
call:flash-ifwi
if %errorlevel% neq 0 ( exit /b %errorlevel%)
echo Recovery Success...
echo You can now try a regular flash
goto :skip_flash_kernel
:skip_flash_ifwi

:: ********************************************************************
:: Kernel & rootfs flashing part
echo Using U-boot target: %VARIANT_NAME%
set VARIANT_FILE="%VAR_DIR%%VARIANT_NAME%.bin"
	if not exist %VARIANT_FILE% (
		echo U-boot target %VARIANT_NAME%: %VARIANT_FILE% not found aborting
		exit /b 5
)

echo Now waiting for dfu device %USB_VID%:%USB_PID%
echo Please plug and reboot the board
call:dfu-wait
if %errorlevel% neq 0 ( exit /b %errorlevel%)

echo Flashing IFWI
call:flash-dfu-ifwi ifwi00 "%IFWI_DFU_FILE%-00-dfu.bin"
if %errorlevel% neq 0 ( exit /b %errorlevel%)
call:flash-dfu-ifwi ifwib00 "%IFWI_DFU_FILE%-00-dfu.bin"
if %errorlevel% neq 0 ( exit /b %errorlevel%)

call:flash-dfu-ifwi ifwi01 "%IFWI_DFU_FILE%-01-dfu.bin"
if %errorlevel% neq 0 ( exit /b %errorlevel%)
call:flash-dfu-ifwi ifwib01 "%IFWI_DFU_FILE%-01-dfu.bin"
if %errorlevel% neq 0 ( exit /b %errorlevel%)

call:flash-dfu-ifwi ifwi02 "%IFWI_DFU_FILE%-02-dfu.bin"
if %errorlevel% neq 0 ( exit /b %errorlevel%)
call:flash-dfu-ifwi ifwib02 "%IFWI_DFU_FILE%-02-dfu.bin"
if %errorlevel% neq 0 ( exit /b %errorlevel%)

call:flash-dfu-ifwi ifwi03 "%IFWI_DFU_FILE%-03-dfu.bin"
if %errorlevel% neq 0 ( exit /b %errorlevel%)
call:flash-dfu-ifwi ifwib03 "%IFWI_DFU_FILE%-03-dfu.bin"
if %errorlevel% neq 0 ( exit /b %errorlevel%)

call:flash-dfu-ifwi ifwi04 "%IFWI_DFU_FILE%-04-dfu.bin"
if %errorlevel% neq 0 ( exit /b %errorlevel%)
call:flash-dfu-ifwi ifwib04 "%IFWI_DFU_FILE%-04-dfu.bin"
if %errorlevel% neq 0 ( exit /b %errorlevel%)

call:flash-dfu-ifwi ifwi05 "%IFWI_DFU_FILE%-05-dfu.bin"
if %errorlevel% neq 0 ( exit /b %errorlevel%)
call:flash-dfu-ifwi ifwib05 "%IFWI_DFU_FILE%-05-dfu.bin"
if %errorlevel% neq 0 ( exit /b %errorlevel%)

call:flash-dfu-ifwi ifwi06 "%IFWI_DFU_FILE%-06-dfu.bin"
if %errorlevel% neq 0 ( exit /b %errorlevel%)
call:flash-dfu-ifwi ifwib06 "%IFWI_DFU_FILE%-06-dfu.bin"
if %errorlevel% neq 0 ( exit /b %errorlevel%)

echo Flashing U-Boot
call:flash-command --alt u-boot0 -D "%BASE_DIR%u-boot-edison.bin"
if %errorlevel% neq 0 ( exit /b %errorlevel%)

echo Flashing U-Boot Environment
call:flash-command --alt u-boot-env0 -D %VARIANT_FILE%
if %errorlevel% neq 0 ( exit /b %errorlevel%)

echo Flashing U-Boot Environment Backup
call:flash-command --alt u-boot-env1 -D %VARIANT_FILE% -R
if %errorlevel% neq 0 ( exit /b %errorlevel%)
echo Rebooting to apply partiton changes
call:dfu-wait
if %errorlevel% neq 0 ( exit /b %errorlevel%)


echo Flashing boot partition ^(kernel^)
call:flash-command --alt resin-boot -D "%BASE_DIR%resin-image-edison.hddimg"
if %errorlevel% neq 0 ( exit /b %errorlevel%)

echo "Flashing config partition"
call:flash-command --alt resin-conf -D "%BASE_DIR%config.img"
if %errorlevel% neq 0 ( exit /b %errorlevel%)

echo "Flashing data_disk, ^(it can take up to 5 minutes... Please be patient^)"
call:flash-command --alt resin-data -D "%BASE_DIR%data_disk.img"
if %errorlevel% neq 0 ( exit /b %errorlevel%)

echo Flashing rootfs, ^(it can take up to 5 minutes... Please be patient^)
call:flash-command --alt resin-root -D "%BASE_DIR%resin-image-edison.ext3" -R
if %errorlevel% neq 0 ( exit /b %errorlevel% )

echo Rebooting
echo U-boot ^& Kernel System Flash Success...
if %VARIANT_NAME% == %VARIANT_NAME_BLANK% (
	echo Your board needs to reboot to complete the flashing procedure, please do not unplug it for 2 minutes.
)
:skip_flash_kernel

:: ********************************************************************
:: The End
exit /b 0


:print-usage
	echo Usage: %1 [-h] [--help] [--recovery] [--keep-data]
	echo Update all software and restore board to its initial state.
	echo  -h,--help     display this help and exit.
	echo  -v            verbose output
	echo  --recovery    recover the board to DFU mode using a dedicated tool,
	echo                available only on linux and window hosts.
	echo  --keep-data   preserve user data when flashing.
	exit /b 5

:flash-dfu-ifwi
	dfu-util -d %USB_VID%:%USB_PID% -l | findstr "%1" > NUL 2>&1
	if %errorlevel% == 0 (
		call:flash-command --alt %1 -D %2
		exit /b %errorlevel%
	)
	exit /b 0

:flash-command
	set filterout="on"
	if %verbose_output% == 1 ( set filterout="off")

	dfu-util -d %USB_VID%:%USB_PID% %* 2>&1 | cscript.exe /E:JScript //B filter-dfu-out.js %LOG_FILENAME% %filterout%

	set /a err_num=%errorlevel%
	if %err_num% neq 0 echo Flash failed on %*
	exit /b %err_num%

:flash-debug
	echo DEBUG: dfu-util -l
	dfu-util -l
	exit /b

:flash-ifwi
	for %%X in (xfstk-dldr-solo.exe) do (set xfstk_tool_found=%%~$PATH:X)
	for %%X in (cflasher.exe) do (set pft_tool_found=%%~$PATH:X)
	if defined pft_tool_found (
		call:flash-ifwi-pft
		exit /b %errorlevel%
	)
	if defined xfstk_tool_found (
		call:flash-ifwi-xfstk
		exit /b %errorlevel%
	)
	echo !!! You should install xfstk tools, please visit http://xfstk.sourceforge.net/
	exit /b 3

:flash-ifwi-xfstk
	xfstk-dldr-solo.exe --gpflags 0x80000007 --osimage "%BASE_DIR%u-boot-edison.img"  --fwdnx "%BASE_DIR%edison_dnx_fwr.bin" --fwimage "%BASE_DIR%edison_ifwi-dbg-00.bin" --osdnx "%BASE_DIR%edison_dnx_osr.bin"
	set /a err_num=%errorlevel%
	if %err_num% neq 0 echo Ifwi Flash failed
	exit /b %err_num%

:flash-ifwi-pft
	cflasher -f %PFT_XML_FILE%
	set /a err_num=%errorlevel%
	if %err_num% neq 0 echo Ifwi Flash failed
	exit /b %err_num%

:dfu-wait
	setlocal
	set /a currtime=%TIMEOUT%
:start_wait
	dfu-util -l -d %USB_VID%:%USB_PID% | findstr "Found" | findstr "%USB_VID%" > NUL 2>&1
	if %errorlevel% == 0 (
		echo Dfu device found
		exit /b 0
	) else (
		set /a currtime-= 1
		timeout /t 1 /nobreak > nul
		if %currtime% gtr 0 goto:start_wait
	)
	echo Dfu device not found Timeout
	echo Did you plug and reboot your board?
	echo If yes, please try a recovery by calling this script with the --recovery option
	exit /b 3

