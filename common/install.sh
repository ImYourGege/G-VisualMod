#!/system/bin/sh

##################
# Main functions #
##################

sp() {
	ui_print " "
	ui_print " "
}

main_menu() {
	if [ $MLOOP ]; then
		MML=7
	else
		MML=4
	fi
	sp
	ui_print "  #############"
	ui_print "  # MAIN MENU #"
	ui_print "  #############"
	ui_print "  Here are the list of available mods:"
	ui_print "  "
	ui_print "  1. UI Radius"
	ui_print "  2. Pill Gesture"
	ui_print "  3. StatusBar"
	ui_print "  4. NotchKiller"
	[ $MLOOP ] && ui_print "  5. CONTINUE" && ui_print "  6. SELECTED MOD(S)" && ui_print "  7. RESET MOD(S)"
	ui_print "  "
	ui_print "  Vol [+] = Next, Vol [-] = Select"
	ui_print "  Please select your desired mods:"
	sp
	OPTM=1
	while true; do
		ui_print "  $OPTM"
		if chooseport 30; then
			OPTM=$((OPTM + 1))
		else 
			break
		fi
		
		[ $OPTM -gt $MML ] && OPTM=1
	done
	sp
	if [ $OPTM = 1 ] && [ $MIUI ]; then
		sp
		ui_print "  UIRadius not supported on MIUI"
		ui_print "  Press any vol button to go back"
		if chooseport 30; then
			main_menu
		else 
			main_menu
		fi
	fi
	if [ $OPTM = 1 ]; then
		main_urm
		main_menu
	fi
	if [ $OPTM = 2 ]; then
		main_pgm
		main_menu
	fi
	if [ $OPTM = 3 ]; then
		main_shm
		main_menu
	fi
	if [ $OPTM = 4 ]; then
		main_nck
		main_menu
	fi
	if [ $OPTM = 6 ]; then
		mods_check
		sp
		ui_print "  Press any vol button to go back"
		if chooseport 30; then
			main_menu
		else 
			main_menu
		fi
	fi
	if [ $OPTM = 8 ]; then
		mods_reset
		main_menu
	fi
}

main_loop() {
	while true; do
		mods_check
		sp
		ui_print "  Continue or go back?"
		ui_print "  Vol+ = Continue, Vol- = Go back"
		if chooseport 30; then
			break
		else
			main_menu
		fi
	done
}

mods_check() {
	sp
	ui_print "  Mod(s) selected:"
	
	if [ "$OPTS" = "1" ]; then
		if [ $OPTT -gt 3 ]; then
			SST="${T}dp ${STHCK}:"
		else
			SST="${T}dp (${TE}) ${STHCK}:"
		fi
		if [ $OPTW -gt 3 ]; then
			SSW="${W}dp ${SWDTH}:"
		else
			SSW="${W}dp (${WE}) ${SWDTH}:"
		fi
	else
		[ "$OPTS" = "2" ] && SSM="AOSP's Pill:"
		[ "$OPTS" = "3" ] && SSM="OxygenOS's Pill:"
		[ "$OPTS" = "4" ] && SSM="MIUI's Pill:"
		[ "$OPTS" = "5" ] && SSM="IOS's Pill:"
	fi
	ASCLR="${SCLR}:"
	ASCLR1="${SCLR1}:"
	ASCLR2="${SCLR2}:"
	
	MODS=${SR}${SST}${SSW}${SSM}${ASCLR}${ASCLR1}${ASCLR2}${DLTN}${TRNS}${IMRS}${FULL}${SH}${NCK}${MIUIAB}
	while [ -n "$MODS" ]; do
		ARR=${MODS%%:*};
		[ "$ARR" ] && ui_print "-  $ARR selected  -"
		MODS=${MODS#*:};
	done
	unset MODS ARR
}

mods_reset() {
	sp
	ui_print "  Resetting..."
	unset MLOOP R SR T W SST SSW SSM ASCLR ASCLR1 ASCLR2 DLTN DLTN IMRS FULL H SH NCK
}

build_apk() {
	sp
	ui_print "  Creating ${SMOD} overlay..."
	aapt p -f -v -M ${OVDIR}/AndroidManifest.xml \
		-I /system/framework/framework-res.apk -S ${OVDIR}/res/ \
		-F ${OVDIR}/unsigned.apk

	if [ -s ${OVDIR}/unsigned.apk ]; then
		${ZIPPATH}/zipsigner ${OVDIR}/unsigned.apk ${OVDIR}/signed.apk
		cp -rf ${OVDIR}/signed.apk ${MODDIR}/${FAPK}.apk
		[ ! -s ${OVDIR}/signed.apk ] && cp -rf ${OVDIR}/unsigned.apk ${MODDIR}/${FAPK}.apk
		rm -rf ${OVDIR}/signed.apk ${OVDIR}/unsigned.apk
	else
		ui_print "  Overlay not created!"
		abort "  This is generally a rom incompatibility,"
	fi

	cp_ch -r ${MODDIR}/${FAPK}.apk ${STEPDIR}/${DAPK}

	if [ -s ${STEPDIR}/${DAPK}/${FAPK}.apk ]; then
		ui_print "  Overlay successfully copied!"
	else
		abort "  The overlay was not copied, please send logs to the developer."
	fi
	sp
	ui_print "  ${SMOD} overlay created..."
}

pre_install() {
	rm -rf /data/resource-cache/overlays.list
	find /data/resource-cache/ -type f \( -name "*Gestural*" -o -name "*Gesture*" -o -name "*GUI*" -o -name "*GPill*" -o -name "*GStatus*" \) \
		-exec rm -rf {} \;
	ZIPPATH=${MODPATH}/common/addon
	set_perm ${ZIPPATH}/zipsigner 0 0 0755
	set_perm ${ZIPPATH}/zipsigner-3.0-dexed.jar 0 0 0644
}

define_string() {
	SSHPE="Shape"
	STHCK="Thickness"
	SWDTH="Width"
	SIMRS="Immersive"
	SFULL="Fullscreen"
	SCOLR="Color"
	SDBLC="DefaultBlack"
	SDWHT="DefaultWhite"
	SAMTY="Amethyst"
	SAQMR="Aquamarine"
	SCRBN="Carbon"
	SCNMN="Cinnamon"
	SGREN="Green"
	SOCEA="Ocean"
	SORCD="Orchid"
	SPLTT="Palette"
	SPRPL="Purple"
	SSAND="Sand"
	SSPCE="Space"
	STGRN="Tangerine"
	SMIBL="MIUI12"
	SPXBL="PixelBlue"
	SOPRD="OnePlusRed"
	SDLTN="DualTone"
	STRNS="Transparency"
	SVRLY="Overlay"
	SCNFG="Config"
}

set_dir() {
	OVDIR=${MODDIR}/${MOD}
	VALDIR=${OVDIR}/res/values
	DRWDIR=${OVDIR}/res/drawable
}

#########################################
# Mount check (Thanks to @skittles9823) #
#########################################

is_mounted() {
	grep " `readlink -f $1` " /proc/mounts 2>/dev/null
	return $?
}

is_mounted_rw() {
	grep " `readlink -f $1` " /proc/mounts | grep " rw," 2>/dev/null
	return $?
}

mount_rw() {
	mount -o remount,rw $1
	DID_MOUNT_RW=$1
}

unmount_rw() {
	if [ "x$DID_MOUNT_RW" = "x$1" ]; then
		mount -o remount,ro $1
	fi
}

unmount_rw_stepdir() {
	if [ $OEM ]; then
		is_mounted_rw " /oem" && unmount_rw /oem
		is_mounted_rw " /oem/OP" && unmount_rw /oem/OP
	fi
}

###############################################
# Check overlay dir (Thanks to @skittles9823) #
###############################################

incompatibility_check() {
OLDMIUI=$(grep_prop "ro.miui.ui.version.*")
MIUI=$(grep_prop "ro.miui.ui.version.name*")
OOS=$(grep_prop "ro.oxygen.version*")

if [ $OLDMIUI ] && [ -z $MIUI ]; then
	sp
	ui_print "  Older MIUI detected!"
	abort "  Only supported on MIUI 12!"
fi

if [ $OOS ]; then
	sp
	ui_print "  OxygenOS detected!"
	ui_print "  Immersive mode and Pill transparency not supported!"
fi

if [ -d "/product/overlay" ]; then
	MAGISK_VER_CODE=$(grep "MAGISK_VER_CODE=" /data/adb/magisk/util_functions.sh | awk -F = '{ print $2 }')
	PRODUCT=true
	if [ $MAGISK_VER_CODE -ge "20000" ]; then
		STEPDIR=${MODPATH}/system/product/overlay
	else
		ui_print "  Magisk v20 is required for users on Android 10"
		abort "  Please update Magisk and try again."
	fi
elif [ -d /oem/OP ];then
	OEM=true
	is_mounted " /oem" || mount /oem
	is_mounted_rw " /oem" || mount_rw /oem
	is_mounted " /oem/OP" || mount /oem/OP
	is_mounted_rw " /oem/OP" || mount_rw /oem/OP
	STEPDIR=/oem/OP/OPEN_US/overlay/framework
else
	STEPDIR=${MODPATH}/system/vendor/overlay
fi
}

############
# Main URM #
############

urm_zip() {
	OIFS=$IFS; IFS=\|
	case $(basename $ZIPFILE | tr '[:upper:]' '[:lower:]') in
		*rsmall*) R=2;;
		*rmedium*) R=20;;
		*rlarge*) R=32;;
	esac
	IFS=$OIFS
}

main_urm() {
	sp
	ui_print "  ###################"
	ui_print "  # G-UI RADIUS MOD #"
	ui_print "  ###################"
	ui_print "  Pick radius"
	ui_print "  "
	ui_print "  1. Small (Almost square)"
	ui_print "  2. Medium"
	ui_print "  3. Large"
	ui_print "  4. BACK"
	ui_print "  "
	ui_print "  Vol [+] = Next, Vol [-] = Select"
	ui_print "  Please select your desired mods:"
	sp
	OPTA=1
	while true; do
		ui_print "  $OPTA"
		if chooseport 30; then
			OPTA=$((OPTA + 1))
		else 
			break
		fi
		
		[ $OPTA -gt 4 ] && OPTA=1
	done
	sp
	[ $OPTA = 1 ] && R=2 && RE=Small
	[ $OPTA = 2 ] && R=20 && RE=Medium
	[ $OPTA = 3 ] && R=32 && RE=Large
	[ $R ] && ui_print "-  ${RE} radius selected  -" && SR="${RE} radius:"
	if [ -z $MIUI ] && [ $R ]; then
		sp
		ui_print "  Apply radius to all icon shapes?"
		ui_print "  (Might add new iconshapes haha)"
		ui_print "  (Also buggy name but shapes are fine)"
		ui_print "  "
		ui_print "  Vol [+] = Yes, Vol [-] = No"
		ui_print "  Select:"
		sp
		if chooseport 30; then
			ui_print "-  Okay, will apply  -"
			IS=true
		else
			ui_print "-  Okay, wont apply  -"
		fi
	fi
	[ $R ] && MLOOP=true
}

urm_script() {
	SMOD=UIRadiusAndroid
	MOD=ANDR
	set_dir
	INFIX=Android
	DAPK=${PREFIX}${INFIX}
	FAPK=${PREFIX}${INFIX}${SVRLY}
	XML="config:dimens:dimens-material:"
	while [ -n "$XML" ]; do
		ARR=${XML%%:*};
		sed -i "s|<val>|$R|" ${VALDIR}/${ARR}.xml
		XML=${XML#*:};
	done
	build_apk

	SMOD=UIRadiusSystem
	MOD=SYUI
	set_dir
	INFIX=SystemUI
	DAPK=${PREFIX}${INFIX}
	FAPK=${PREFIX}${INFIX}${SVRLY}
	sed -i "s|<val>|$R|" ${VALDIR}/dimens.xml
	[ $API -ge 29 ] && find ${DRWDIR} ! -name 'rounded_ripple.xml' -type f -exec rm -f {} +
	build_apk
	
	if [ $IS ]; then
		PREFIX=IconShape
		IS="Heart:Pebble:RoundedRect:Square:Squircle:Tapered:Teardrop:Vessel:"
		while [ -n "$IS" ]; do
			SUFFIX=${IS%%:*};
			SMOD=${PREFIX}${SUFFIX}
			DAPK=${PREFIX}${SUFFIX}
			FAPK=${PREFIX}${SUFFIX}${SVRLY}
			MOD="IconShape/${SUFFIX}"
			set_dir
			sed -i "s|<val>|$R|" ${VALDIR}/config.xml
			build_apk
			IS=${IS#*:};
		done
		unset IS SUFFIX
	fi
}

############
# Main PGM #
############

pgm_zip() {
	OIFS=$IFS; IFS=\|
	case $(basename $ZIPFILE | tr '[:upper:]' '[:lower:]') in
		*aosp*) T=1; W=72;;
		*aosp:imrs*) T=1; W=72; IMRS=true;;
		*oos*) T=1.5; W=110;;
		*oos:imrs*) T=1.5; W=110; IMRS=true;;
		*miui*) T=1.5; W=160;;
		*miui:imrs*) T=1.5; W=160; IMRS=true;;
		*ios*) T=2.5; W=160;;
		*ios:imrs*) T=2.5; W=160; IMRS=true;;
		*full*) FULL=true;;
		*imrs*) IMRS=true;;
		*amty*) SCLR=$SAMTY;;
		*aqmr*) SCLR=$SAQMR;;
		*crbn*) SCLR=$SCRBN;;
		*cnmn*) SCLR=$SCNMN;;
		*gren*) SCLR=$SGREN;;
		*ocea*) SCLR=$SOCEA;;
		*orcd*) SCLR=$SORCD;;
		*pltt*) SCLR=$SPLTT;;
		*prpl*) SCLR=$SPRPL;;
		*sand*) SCLR=$SSAND;;
		*spce*) SCLR=$SSPCE;;
		*tgrn*) SCLR=$STGRN;;
		*mibl*) SCLR=$SMIBL;;
		*pxbl*) SCLR=$SPXBL;;
		*oprd*) SCLR=$SOPRD;;
		*amty,dt*) SCLR=$SAMTY; DLTN=true;;
		*aqmr,dt*) SCLR=$SAQMR; DLTN=true;;
		*crbn,dt*) SCLR=$SCRBN; DLTN=true;;
		*cnmn,dt*) SCLR=$SCNMN; DLTN=true;;
		*gren,dt*) SCLR=$SGREN; DLTN=true;;
		*ocea,dt*) SCLR=$SOCEA; DLTN=true;;
		*orcd,dt*) SCLR=$SORCD; DLTN=true;;
		*pltt,dt*) SCLR=$SPLTT; DLTN=true;;
		*prpl,dt*) SCLR=$SPRPL; DLTN=true;;
		*sand,dt*) SCLR=$SSAND; DLTN=true;;
		*spce,dt*) SCLR=$SSPCE; DLTN=true;;
		*tgrn,dt*) SCLR=$STGRN; DLTN=true;;
		*mibl,dt*) SCLR=$SMIBL; DLTN=true;;
		*pxbl,dt*) SCLR=$SPXBL; DLTN=true;;
		*oprd,dt*) SCLR=$SOPRD; DLTN=true;;
		*10*) TRP=E6; IMRS=true;;
		*20*) TRP=CC; IMRS=true;;
		*30*) TRP=B3; IMRS=true;;
		*40*) TRP=99; IMRS=true;;
		*50*) TRP=80; IMRS=true;;
		*60*) TRP=66; IMRS=true;;
		*70*) TRP=4D; IMRS=true;;
		*80*) TRP=33; IMRS=true;;
		*90*) TRP=1A; IMRS=true;;
	esac
	IFS=$OIFS
}

main_pgm() {
	sp
	ui_print "  #######################"
	ui_print "  # G-PILL GESTURE MODS #"
	ui_print "  #######################"
	ui_print "  Here are the list of available mods:"
	ui_print "  "
	ui_print "  1. Change shape"
	ui_print "  2. Change color"
	ui_print "  3. Change transparency"
	ui_print "  4. Enable ${SIMRS} or ${SFULL} mode"
	ui_print "  5. BACK"
	ui_print "  "
	ui_print "  Vol [+] = Next, Vol [-] = Select"
	ui_print "  Please select your desired mods:"
	sp
	OPTM=1
	while true; do
		ui_print "  $OPTM"
		if chooseport 30; then
			OPTM=$((OPTM + 1))
		else 
			break
		fi
		
		[ $OPTM -gt 5 ] && OPTM=1
	done
	sp
	if [ $OPTM = 1 ] && [ -z "$FULL" ]; then
		main_shape
		main_pgm
	elif [ $OPTM = 1 ] && [ "$FULL" ]; then
		ui_print "  You selected ${SFULL} mode before,"
		ui_print "  why would you change the ${SSHPE}?"
		ui_print "  or"
		ui_print "  Do you want to unselect ${SFULL} mode"
		ui_print "  and continue?"
		ui_print "  Vol+ = Yes, Vol- = No"
		sp
		if chooseport 30; then
			ui_print "-  ${SFULL} unselected  -"
			sp
			unset FULL MLOOP
			main_shape
			main_pgm
		else
			main_pgm
		fi
	fi
	
	if [ $OPTM = 2 ] && [ -z "$FULL" ]; then
		main_color
		main_pgm
	elif [ $OPTM = 2 ] && [ "$FULL" ]; then
		ui_print "  You selected ${SFULL} mode before,"
		ui_print "  why would you change the ${SCOLR}?"
		ui_print "  or"
		ui_print "  Do you want to unselect ${SFULL} mode"
		ui_print "  and continue?"
		ui_print "  Vol+ = Yes, Vol- = No"
		sp
		if chooseport 30; then
			ui_print "-  ${SFULL} unselected  -"
			sp
			unset FULL MLOOP
			main_color
			main_pgm
		else
			main_pgm
		fi
	fi
	if [ $OPTM = 3 ] && [ $OOS ]; then
		sp
		ui_print "  ${STRNS} not supported on OxygenOS"
		ui_print "  Press any vol button to go back"
		if chooseport 30; then
			main_pgm
		else 
			main_pgm
		fi
	fi
	if [ $OPTM = 3 ] && [ -z "$FULL" ]; then
		main_transparency
		main_pgm
	elif [ $OPTM = 3 ] && [ "$FULL" ]; then
		ui_print "  You selected ${SFULL} mode before,"
		ui_print "  why would you change the ${STRNS}?"
		ui_print "  or"
		ui_print "  Do you want to unselect ${SFULL} mode"
		ui_print "  and continue?"
		ui_print "  Vol+ = Yes, Vol- = No"
		sp
		if chooseport 30; then
			ui_print "-  ${SFULL} unselected  -"
			sp
			unset FULL MLOOP
			main_transparency
			main_pgm
		else
			main_pgm
		fi
	fi
	if [ $OPTM = 4 ]; then
		main_mode
		main_pgm
	fi
}

main_shape() {
	ui_print "  ################"
	ui_print "  # CHANGE SHAPE #"
	ui_print "  ################"
	ui_print "  Customize manually or pick a template"
	ui_print "  "
	ui_print "  1. Manual Mode"
	ui_print "  2. AOSP's Pill"
	ui_print "  3. OxygenOS's Pill"
	ui_print "  4. MIUI's Pill"
	ui_print "  5. IOS's Pill"
	ui_print "  6. BACK"
	ui_print "  "
	ui_print "  Vol [+] = Next, Vol [-] = Select"
	ui_print "  Select:"
	sp
	OPTS=1
	while true; do
		ui_print "  $OPTS"
		if chooseport 30; then
			OPTS=$((OPTS + 1))
		else 
			break
		fi
		
		[ $OPTS -gt 6 ] && OPTS=1
	done
	sp
	if [ $OPTS = 1 ]; then
		shape_manual
	elif [ $OPTS = 2 ]; then
		ui_print "-  AOSP's Pill selected  -"
		T=1
		W=72
	elif [ $OPTS = 3 ]; then
		ui_print "-  OxygenOS's Pill selected  -"
		T=1.5
		W=137
	elif [ $OPTS = 4 ]; then
		ui_print "-  MIUI's Pill selected  -"
		T=1.5
		W=160
	elif [ $OPTS = 5 ]; then
		ui_print "-  IOS's Pill selected  -"
		T=2.5
		W=160
	fi
	
	if [ $OPTS -ne 6 ]; then
		sp
		ui_print "  Apply width to landscape mode too?"
		ui_print "  "
		ui_print "  Vol [+] = Yes, Vol [-] = No"
		ui_print "  Select:"
		sp
		if chooseport 30; then
			ui_print "-  Okay, will apply  -"
			LAND=true
		else
			ui_print "-  Okay, wont apply  -"
		fi
	fi
	
	[ $T ] && [ $W ] && MLOOP=true
}

shape_manual() {
	ui_print "  #############"
	ui_print "  # Thickness #"
	ui_print "  #############"
	ui_print "  How thick?"
	ui_print "  "
	ui_print "  1. 1.0dp (AOSP)"
	ui_print "  2. 1.5dp (OxygenOS & MIUI 12)"
	ui_print "  3. 2.5dp (IOS)"
	ui_print "  4. 3.0dp"
	ui_print "  "
	ui_print "  Vol [+] = Next, Vol [-] = Select"
	ui_print "  Select:"
	sp
	OPTT=1
	while true; do
		ui_print "  $OPTT"
		if chooseport 30; then
			OPTT=$((OPTT + 1))
		else 
			break
		fi
		
		[ $OPTT -gt 4 ] && OPTT=1
	done
	sp
	if [ $OPTT = 1 ]; then
		T=1
		TE="AOSP"
	elif [ $OPTT = 2 ]; then
		T=1.5
		TE="OxygenOS & MIUI 12"
	elif [ $OPTT = 3 ]; then
		T=2.5
		TE="IOS"
	fi
	
	[ $OPTT = 4 ] && T=3.0
	
	if [ $OPTT -gt 3 ]; then
		ui_print "-  ${T}dp ${STHCK} selected  -"
	else
		ui_print "-  ${T}dp (${TE}) ${STHCK} selected  -"
	fi
	
	sp
	ui_print "  #########"
	ui_print "  # Width #"
	ui_print "  #########"
	ui_print "  How wide?"
	ui_print "  "
	ui_print "  1. 72dp (AOSP)"
	ui_print "  2. 110dp (OxygenOS)"
	ui_print "  3. 160dp (IOS & MIUI 12)"
	ui_print "  4. 180dp"
	ui_print "  5. 200dp"
	ui_print "  "
	ui_print "  Vol [+] = Next, Vol [-] = Select"
	ui_print "  Select:"
	sp
	OPTW=1
	while true; do
		ui_print "  $OPTW"
		if chooseport 30; then
			OPTW=$((OPTW + 1))
		else 
			break
		fi
		
		[ $OPTW -gt 5 ] && OPTW=1
	done
	sp
	if [ $OPTW = 1 ]; then
		W=72
		WE="AOSP"
	elif [ $OPTW = 2 ]; then
		W=110
		WE="OOS"
	elif [ $OPTW = 3 ]; then
		W=160
		WE="IOS & MIUI 12"
	fi
	
	[ $OPTW = 4 ] && W=180
	[ $OPTW = 5 ] && W=200
	
	if [ $OPTW -gt 3 ]; then
		ui_print "-  ${W}dp ${SWDTH} selected  -"
	else
		ui_print "-  ${W}dp (${WE}) ${SWDTH} selected  -"
	fi
}

main_color() {
	ui_print "  ################"
	ui_print "  # CHANGE COLOR #"
	ui_print "  ################"
	CLRC="a"
	SNDLTN=" (No DualTone)"
	SDLCLR="DualColor"
	CVLMT=17
	color_list
	ui_print "  16. Dual Color (choose twice)"
	ui_print "  17. BACK"
	ui_print "  "
	ui_print "  Vol [+] = Next, Vol [-] = Select"
	ui_print "  Select:"
	sp
	color_vol
	if [ $OPTC -ne 17 ]; then
		color_pick
		[ $OPTC = 16 ] && DLCLR=true && SCLR=$SDLCLR
		ui_print "-  ${SCLR} selected  -"
		sp
		if [ $OPTC = 16 ]; then
			unset SNDLTN
			CLRC="light theme"
			CVLMT=16
			color_list
			ui_print "  16. DefaultBlack"
			ui_print "  "
			ui_print "  Vol [+] = Next, Vol [-] = Select"
			ui_print "  Select:"
			sp
			color_vol
			color_pick
			[ $OPTC = 16 ] && SCLR=$SDBLC
			SCLR1=$SCLR
			ui_print "-  ${SCLR1} selected  -"
			sp
			[ $OPTC = 16 ] && unset SCLR1
			
			CLRC="dark theme"
			CVLMT=15
			color_list
			[ $SCLR != $SDBLC ] && ui_print "  16. DefaultWhite" && CVLMT=16
			ui_print "  "
			ui_print "  Vol [+] = Next, Vol [-] = Select"
			ui_print "  Select:"
			sp
			color_vol
			color_pick
			[ $OPTC = 16 ] && SCLR=$SDWHT
			SCLR2=$SCLR
			ui_print "-  ${SCLR2} selected  -"
			[ $OPTC = 16 ] && unset SCLR2
			unset SCLR
		fi
		
		if [ $OPTC -le 12 ] && [ -z $DLCLR ]; then
			sp
			ui_print "  #############"
			ui_print "  # DUAL TONE #"
			ui_print "  #############"
			ui_print "  Pill gesture will slighty changes color-"
			ui_print "  between light and dark theme"
			ui_print "  Enable ${SDLTN} mode?"
			ui_print "  Vol+ = Yes, Vol- = No"
			sp
			if chooseport 30; then
				ui_print "-  ${SDLTN} mode selected  -"
				DLTN="${SDLTN} mode:"
			else
				ui_print "-  ${SDLTN} mode skipped  -"
			fi
		fi
	fi
	[ $SCLR ] && MLOOP=true || [ $DLCLR ] && MLOOP=true
}

color_list () {
	ui_print "  Pick ${CLRC} color"
	ui_print "  "
	ui_print "  1. ${SAMTY}"
	ui_print "  2. ${SAQMR}"
	ui_print "  3. ${SCRBN}"
	ui_print "  4. ${SCNMN}"
	ui_print "  5. ${SGREN}"
	ui_print "  6. ${SOCEA}"
	ui_print "  7. ${SORCD}"
	ui_print "  8. ${SPLTT}"
	ui_print "  9. ${SPRPL}"
	ui_print "  10. ${SSAND}"
	ui_print "  11. ${SSPCE}"
	ui_print "  12. ${STGRN}"
	ui_print "  13. ${SMIBL}${SNDLTN}"
	ui_print "  14. ${SPXBL}${SNDLTN}"
	ui_print "  15. ${SOPRD}${SNDLTN}"
}

color_vol() {
	OPTC=1
	while true; do
		ui_print "  $OPTC"
		if chooseport 30; then
			OPTC=$((OPTC + 1))
		else 
			break
		fi
		
		[ $OPTC -gt $CVLMT ] && OPTC=1
	done
	sp
}

color_pick() {
	[ $OPTC = 1 ] && SCLR=$SAMTY
	[ $OPTC = 2 ] && SCLR=$SAQMR
	[ $OPTC = 3 ] && SCLR=$SCRBN
	[ $OPTC = 4 ] && SCLR=$SCNMN
	[ $OPTC = 5 ] && SCLR=$SGREN
	[ $OPTC = 6 ] && SCLR=$SOCEA
	[ $OPTC = 7 ] && SCLR=$SORCD
	[ $OPTC = 8 ] && SCLR=$SPLTT
	[ $OPTC = 9 ] && SCLR=$SPRPL
	[ $OPTC = 10 ] && SCLR=$SSAND
	[ $OPTC = 11 ] && SCLR=$SSPCE
	[ $OPTC = 12 ] && SCLR=$STGRN
	[ $OPTC = 13 ] && SCLR=$SMIBL
	[ $OPTC = 14 ] && SCLR=$SPXBL
	[ $OPTC = 15 ] && SCLR=$SOPRD
}

light_color() {
	[ $ARRCLR = $SAMTY ] && LCLR="A03EFF"
	[ $ARRCLR = $SAQMR ] && LCLR="23847D"
	[ $ARRCLR = $SCRBN ] && LCLR="434E58"
	[ $ARRCLR = $SCNMN ] && LCLR="AF6050"
	[ $ARRCLR = $SGREN ] && LCLR="1B873B"
	[ $ARRCLR = $SOCEA ] && LCLR="0C80A7"
	[ $ARRCLR = $SORCD ] && LCLR="C42CC9"
	[ $ARRCLR = $SPLTT ] && LCLR="c01668"
	[ $ARRCLR = $SPRPL ] && LCLR="725AFF"
	[ $ARRCLR = $SSAND ] && LCLR="795548"
	[ $ARRCLR = $SSPCE ] && LCLR="47618A"
	[ $ARRCLR = $STGRN ] && LCLR="C85125"
	[ $ARRCLR = $SMIBL ] && LCLR="0D84FF"
	[ $ARRCLR = $SPXBL ] && LCLR="1A73E8"
	[ $ARRCLR = $SOPRD ] && LCLR="EB0028"
}

dark_color() {
	[ $ARRCLR = $SAMTY ] && DCLR="BD78FF"
	[ $ARRCLR = $SAQMR ] && DCLR="1AFFCB"
	[ $ARRCLR = $SCRBN ] && DCLR="3DDCFF"
	[ $ARRCLR = $SCNMN ] && DCLR="C3A6A2"
	[ $ARRCLR = $SGREN ] && DCLR="84C188"
	[ $ARRCLR = $SOCEA ] && DCLR="28BDD7"
	[ $ARRCLR = $SORCD ] && DCLR="E68AED"
	[ $ARRCLR = $SPLTT ] && DCLR="ffb6d9"
	[ $ARRCLR = $SPRPL ] && DCLR="B5A9FC"
	[ $ARRCLR = $SSAND ] && DCLR="c8ac94"
	[ $ARRCLR = $SSPCE ] && DCLR="99ACCC"
	[ $ARRCLR = $STGRN ] && DCLR="F19D7D"
	[ $ARRCLR = $SMIBL ] && DCLR="0D84FF"
	[ $ARRCLR = $SPXBL ] && DCLR="1A73E8"
	[ $ARRCLR = $SOPRD ] && DCLR="EB0028"
}

main_transparency() {
	ui_print "  ################"
	ui_print "  # TRANSPARENCY #"
	ui_print "  ################"
	ui_print "  Applying this will have ${SIMRS} mode enabled!"
	ui_print "  How transparent?"
	ui_print "  "
	ui_print "  1. 10%"
	ui_print "  2. 20%"
	ui_print "  3. 30%"
	ui_print "  4. 40%"
	ui_print "  5. 50%"
	ui_print "  6. 60%"
	ui_print "  7. 70%"
	ui_print "  8. 80%"
	ui_print "  9. 90%"
	ui_print "  10. BACK"
	ui_print "  "
	ui_print "  Vol [+] = Next, Vol [-] = Select"
	ui_print "  Select:"
	sp
	OPTR=1
	while true; do
		ui_print "  $OPTR"
		if chooseport 30; then
			OPTR=$((OPTR + 1))
		else 
			break
		fi
		
		if [ $OPTR -gt 10 ]; then
			OPTR=1
		fi
	done
	sp
	if [ $OPTR -ne 10 ]; then
		[ $OPTR = 1 ] && TRP=E6 && STRP="10%"
		[ $OPTR = 2 ] && TRP=CC && STRP="20%"
		[ $OPTR = 3 ] && TRP=B3 && STRP="30%"
		[ $OPTR = 4 ] && TRP=99 && STRP="40%"
		[ $OPTR = 5 ] && TRP=80 && STRP="50%"
		[ $OPTR = 6 ] && TRP=66 && STRP="60%"
		[ $OPTR = 7 ] && TRP=4D && STRP="70%"
		[ $OPTR = 8 ] && TRP=33 && STRP="80%"
		[ $OPTR = 9 ] && TRP=1A && STRP="90%"
		ui_print "-  $STRP ${STRNS} mode selected  -"
		IMRS="${SIMRS} mode:"
		TRNS="${STRNS} mode:"
	fi
	[ "$TRNS" ] && MLOOP=true
}

main_mode() {
	ui_print "  #################"
	ui_print "  # ACTIVATE MODE #"
	ui_print "  #################"
	ui_print "  Pick a mode"
	ui_print "  "
	ui_print "  1. ${SIMRS} mode"
	ui_print "  2. ${SFULL} mode"
	ui_print "  3. Back"
	ui_print "  "
	ui_print "  Vol [+] = Next, Vol [-] = Select"
	ui_print "  Select:"
	sp
	OPTD=1
	while true; do
		ui_print "  $OPTD"
		if chooseport 30; then
			OPTD=$((OPTD + 1))
		else 
			break
		fi
		
		if [ $OPTD -gt 3 ]; then
			OPTD=1
		fi
	done
	sp
	if [ $OPTD = 1 ] && [ $OOS ]; then
		sp
		ui_print "  ${SIMRS} not supported on OxygenOS"
		ui_print "  Press any vol button to go back"
		if chooseport 30; then
			main_mode
		else 
			main_mode
		fi
	fi
	if [ $OPTD = 1 ]; then
		ui_print "-  ${SIMRS} mode selected  -"
		IMRS="${SIMRS} mode:"
	elif [ $OPTD = 2 ]; then
		ui_print "-  ${SFULL} mode selected  -"
		FULL="${SFULL} mode:"
	fi
	[ "$IMRS" ] || [ "$FULL" ] && MLOOP=true
}

pgm_script() {
	if [ $T ] && [ $W ]; then
		SMOD=$SSHPE
		MOD=SHPE
		set_dir
		DAPK=${PREFIX}${SMOD}${SUFFIX}
		FAPK=${PREFIX}${SMOD}${SUFFIX}${SVRLY}
		[ $T = 1.5 ] && T2=6
		[ "$( echo "$T >= 2.5" | bc )" = 1 ] && T2=9
		if [ "$( echo "$T >= 1.5" | bc )" = 1 ]; then
			TPLUS=true
			sed -i "s|<val2>|$T2|" ${VALDIR}/dimens.xml
		else
			sed -i "4d" ${VALDIR}/dimens.xml
		fi
		sed -i "s|<val>|$T|" ${VALDIR}/dimens.xml
		sed -i "s|<val3>|$W|" ${VALDIR}/dimens.xml
		[ $LAND ] && cp_ch -r ${VALDIR}/dimens.xml ${OVDIR}/res/values-land
		build_apk
	fi

	if [ $SCLR ] || [ $TRP ] || [ $DLCLR ]; then
		SMOD=$SCOLR
		MOD=COLR
		set_dir
		INFIX=${SCLR}${SCLR1}${SCLR2}
		DAPK=${PREFIX}${INFIX}
		FAPK=${PREFIX}${INFIX}${SVRLY}
		
		ARCLR="$SCLR:$SCLR1:$SCLR2:"
		
		ATT=1
		while [ -n "$ARCLR" ]; do
			ARRCLR=${ARCLR%%:*};
			if [ $ATT = 1 ]; then
				light_color
				dark_color
			elif [ $ATT = 2 ]; then
				dark_color
				[ $DLCLR ] && [ -z $ARRCLR ] && unset DCLR
			elif [ $ATT = 3 ]; then
				light_color
				[ $DLCLR ] && [ -z $ARRCLR ] && unset LCLR
			fi
			ATT=$((ATT+1))
			ARCLR=${ARCLR#*:};
		done
		unset ARRCLR ARCLR

		if [ -z $TRP ]; then
			LTRP=EB
			DTRP=99
		else
			LTRP=$TRP
			DTRP=$TRP
		fi
		
		[ -z $LCLR ] && LCLR="FFFFFF" && DLTN=true
		[ -z $DCLR ] && DCLR="000000" && DLTN=true
		[ $DLCLR ] && DLTN=true
		[ -z "$DLTN" ] && DCLR=$LCLR
		[ -z $MIUI ] && VAR="bar_home_"
		sed -i "s|<var>|$VAR|" ${VALDIR}/colors.xml
		sed -i "s|<lclr>|$LCLR|" ${VALDIR}/colors.xml
		sed -i "s|<dclr>|$DCLR|" ${VALDIR}/colors.xml
		sed -i "s|<ltrp>|$LTRP|" ${VALDIR}/colors.xml
		sed -i "s|<dtrp>|$DTRP|" ${VALDIR}/colors.xml
		build_apk
	fi

	if [ -z $MIUI ]; then
		if [ $PRODUCT ] || [ $OEM ]; then
			:
		else
			ui_print "  I'm not sure it'll work in current OS..."
		fi
		MOD="/CNFG/AOSP"
		set_dir
		PREFIX="NavigationBarModeGestural"
		[ $API -ge 30 ] && TSUFFIX=":" || TSUFFIX=":NarrowBack:WideBack:ExtraWideBack:"
	else
		MOD="/CNFG/MIUI"
		set_dir
		DAPK=${PREFIX}${SCNFG}
		FAPK=${PREFIX}${SCNFG}${SVRLY}
	fi

	if [ -z $MIUI ]; then
		DEF2=48
		DEF3=32
	else
		DEF2=16
		if [ "$FULL" ] || [ $TPLUS ] && [ -z "$IMRS" ]; then
			sed -i "5,6d" ${VALDIR}/dimens.xml
		fi
	fi

	if [ "$FULL" ]; then
		SVAL=0
		SVAL2=0
		SVAL3=20
	fi

	if [ "$IMRS" ]; then
		if [ -z $MIUI ]; then
			SVAL=0
			SVAL2=$DEF2
			SVAL3=$DEF3
		else
			SVAL=0.1
			[ $TPLUS ] && SVAL2=24 || SVAL2=$DEF2
		fi
	elif [ $TPLUS ]; then
		SVAL=24
		SVAL2=$DEF2
		SVAL3=$DEF3
	fi

	if [ $SVAL ]; then
		SMOD=$SCNFG
		sed -i "s|<val>|$SVAL|" ${VALDIR}/dimens.xml
		sed -i "s|<val2>|$SVAL2|" ${VALDIR}/dimens.xml
		if [ -z $MIUI ]; then
			sed -i "s|<val3>|$SVAL3|" ${VALDIR}/dimens.xml
			[ $API = 29 ] && ACODE=10
			[ $API = 30 ] && ACODE=11
			sed -i "s|<vapi>|$API|" ${OVDIR}/AndroidManifest.xml
			sed -i "s|<vcde>|$ACODE|" ${OVDIR}/AndroidManifest.xml
			while [ -n "$TSUFFIX" ]; do
				SUFFIX=${TSUFFIX%%:*};
				DAPK=${PREFIX}${SUFFIX}
				FAPK=${PREFIX}${SVRLY}${SUFFIX}
				[ -z $SUFFIX ] && SVAL=24 && CHNG="<valc>" && WTH="$SVAL" && SVALS="gestural" && CHNG1="<vals>" && WTH1="$SVALS"
				[ $SUFFIX = "NarrowBack" ] && SVAL1=18 && CHNG="$SVAL" WTH="$SVAL1" && SVALS1="gestural_narrow_back" && CHNG1="$SVALS" && WTH1="$SVALS1"
				[ $SUFFIX = "WideBack" ] && SVAL2=32 && CHNG="$SVAL1" WTH="$SVAL2" && SVALS2="gestural_wide_back" && CHNG1="$SVALS1" && WTH1="$SVALS2"
				[ $SUFFIX = "ExtraWideBack" ] && SVAL3=40 && CHNG="$SVAL2" WTH="$SVAL3" && SVALS3="gestural_extra_wide_back" && CHNG1="$SVALS2" && WTH1="$SVALS3"
				sed -i "s|$CHNG|$WTH|" ${VALDIR}/config.xml
				sed -i "s|$CHNG1|$WTH1|" ${OVDIR}/AndroidManifest.xml
				build_apk
				TSUFFIX=${TSUFFIX#*:};
			done
		else
			build_apk
			ui_print "  Copying special files for MIUI..."
			[ $SVAL = 0 ] && GLO=FULL
			[ $SVAL = 0.1 ] && GLO=IMRS
			[ $SVAL = 24 ] && GLO=TPLUS
			mv ${MODDIR}/MIUI/*$GLO.apk ${MODDIR}/MIUI/GestureLineOverlay.apk
			cp_ch -r ${MODDIR}/MIUI/*Overlay.apk ${MODPATH}/system/vendor/overlay
			ui_print "  Files copied..."
		fi
	fi
}

############
# Main SHM #
############

shm_zip() {
	OIFS=$IFS; IFS=\|
	case $(basename $ZIPFILE | tr '[:upper:]' '[:lower:]') in
		*hmedium*) R=34;;
		*hlarge*) R=40;;
		*hxlarge*) R=48;;
	esac
	IFS=$OIFS
}

main_shm() {
	if [ $MIUI ] && [ -z "$MIUIAB" ]; then
		sp
		ui_print "  ########################"
		ui_print "  # G-STATUSBAR MIUI FIX #"
		ui_print "  ########################"
		ui_print "  Fix bottom margin?"
		ui_print "  "
		ui_print "  Vol [+] = Yes, Vol [-] = No"
		ui_print "  Select:"
		sp
		if chooseport 30; then
			ui_print "-  Okay, will fix  -"
			MIUIAB="MIUI bottom margin fix:"
		else
			ui_print "-  Okay, wont fix  -"
		fi
	fi
	sp
	ui_print "  ##########################"
	ui_print "  # G-STATUSBAR HEIGHT MOD #"
	ui_print "  ##########################"
	ui_print "  Pick height"
	ui_print "  "
	ui_print "  1. Medium"
	ui_print "  2. Large"
	ui_print "  3. XLarge"
	ui_print "  4. BACK"
	ui_print "  "
	ui_print "  Vol [+] = Next, Vol [-] = Select"
	ui_print "  Please select your desired mods:"
	sp
	OPTH=1
	while true; do
		ui_print "  $OPTH"
		if chooseport 30; then
			OPTH=$((OPTH + 1))
		else 
			break
		fi
		
		[ $OPTH -gt 4 ] && OPTH=1
	done
	sp
	[ $OPTH = 1 ] && H=34 && HE=Medium
	[ $OPTH = 2 ] && H=40 && HE=Large
	[ $OPTH = 3 ] && H=48 && HE=XLarge

	[ $H ] && ui_print "-  ${HE} height selected  -" && SH="${HE} height:" && MLOOP=true
	[ "$MIUIAB" ] && ui_print "-  MIUI bottom margin fix selected  -" && MLOOP=true
}

shm_script() {
	if [ -z $MIUI ]; then
		SMOD=StatusbarHeight
		MOD=HGHT
		set_dir
		INFIX=StatusBar
		DAPK=${PREFIX}${INFIX}
		FAPK=${PREFIX}${INFIX}${SVRLY}
		sed -i "s|<val>|$H|" ${VALDIR}/dimens.xml
		build_apk
	else
		ui_print "  Copying special files for MIUI..."
		MOD=HMIUI
		set_dir
		[ -f /system/media/theme/default/framework-res ] && ui_print "  Overwriting default theme..."
		cp_ch -r ${OVDIR}/framework-res_$H ${MODPATH}/system/media/theme/default
		mv ${MODPATH}/system/media/theme/default/framework-res_$H ${MODPATH}/system/media/theme/default/framework-res
		if [ "$MIUIAB" ]; then
			[ -f /system/media/theme/default/com.android.systemui ] && ui_print "  Overwriting default theme..."
			cp_ch -r ${OVDIR}/com.android.systemui ${MODPATH}/system/media/theme/default
		fi
		ui_print "  Files copied..."
	fi
}

############
# Main NCK #
############

nck_zip() {
	OIFS=$IFS; IFS=\|
	case $(basename $ZIPFILE | tr '[:upper:]' '[:lower:]') in
		*nck*) NCK=true;;
	esac
	IFS=$OIFS
}

main_nck() {
	sp
	ui_print "  #################"
	ui_print "  # G-NotchKiller #"
	ui_print "  #################"
	ui_print "  "
	ui_print "  Activate NotchKiller?"
	ui_print "  "
	ui_print "  Vol [+] = Yes, Vol [-] = Go back"
	sp
	if chooseport 30; then
		NCK="NotchKiller:"
		SNCK="NotchKiller"
	else
		main_menu
	fi
	sp
	[ $NCK ] && ui_print "-  ${SNCK} selected  -" && MLOOP=true
}

nck_script() {
	SMOD=NotchKiller
	MOD=NCKR
	set_dir
	INFIX=NotchKiller
	DAPK=${PREFIX}${INFIX}
	FAPK=${PREFIX}${INFIX}${SVRLY}
	build_apk
}

incompatibility_check
pre_install
define_string
urm_zip
pgm_zip
shm_zip

##############
# User input #
##############
if [ -z $T ] && [ -z $W ] || [ -z $CLR ] || [ -z $IMRS ] || [ -z $FULL ] ; then
	if [ chooseport = false ]; then
	sp
	ui_print "  Options not specified in zipname!"
	abort "  Either use vol. button or zipname method!"
	else
		ui_print "  Welcome to..."
		ui_print "    ___     _  _ __ ____ _  _  __  __      _  _  __ ____ "
		ui_print "   / __)___/ )( (  / ___/ )( \\/ _\\(  )    ( \\/ )/  (    \\"
		ui_print "  ( (_ (___\\ \\/ /)(\\___ ) \\/ /    / (_/\\  / \\/ (  O ) D ("
		ui_print "   \\___/    \\__/(__(____\\____\\_/\\_\\____/  \\_)(_/\\__(____/"
#		ui_print "	 / __)___/ )( (  / ___/ )( \\/ _\\(  )  "
#		ui_print "	( (_ (___\\ \\/ /)(\\___ ) \\/ /    / (_/\\"
#		ui_print "	 \\___/    \\__/(__(____\\____\\_/\\_\\____/"
#		ui_print "	 _  _  __ ____ "
#		ui_print "	( \\/ )/  (    \\"
#		ui_print "	/ \\/ (  O ) D ("
#		ui_print "	\\_)(_/\\__(____/"
		main_menu
		main_loop
	fi
else
	ui_print "  Options specified in zipname!"
fi


#####################
# Creating Overlays #
#####################
sp
ui_print "  Overlays will be copied to ${STEPDIR}"

if [ $R ]; then
	MODSEL=URM
	MODDIR=${MODPATH}/mods/${MODSEL}
	PREFIX="G-UIRadius"
	SUFFIX="Mods"
	urm_script
fi

if [ $T ] && [ $W ] || [ $SCLR ] || [ $TRP ] || [ $DLCLR ] || [ "$FULL" ] || [ "$IMRS" ]; then
	MODSEL=PGM
	MODDIR=${MODPATH}/mods/${MODSEL}
	PREFIX="G-PillGesture"
	SUFFIX="Mods"
	pgm_script
fi

if [ $H ] || [ "$MIUIAB" ]; then
	MODSEL=SHM
	MODDIR=${MODPATH}/mods/${MODSEL}
	PREFIX="G-Statusbar"
	SUFFIX="Mods"
	shm_script
fi

if [ $NCK ]; then
	MODSEL=NCK
	MODDIR=${MODPATH}/mods/${MODSEL}
	PREFIX="DisplayCutoutEmulation"
	nck_script
fi

#############
# Finishing #
#############
rm -rf $MODPATH/mods
sp
ui_print "  Done..."
unmount_rw_stepdir
