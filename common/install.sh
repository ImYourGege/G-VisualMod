# Spaces
sp() {
	ui_print " "
	ui_print " "
}

# Functions to check if dirs is mounted (Thanks to @Skittles9823)
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

unmount_rw_stepdir(){
  if [ "$MOUNTPRODUCT" ]; then
    is_mounted_rw " /product" || unmount_rw /product
  elif [ "$OEM" ];then
    is_mounted_rw " /oem" && unmount_rw /oem
    is_mounted_rw " /oem/OP" && unmount_rw /oem/OP
  fi
}

setvars(){
	if [ -d "/product/overlay" ]; then
		PRODUCT=true
		# Yay, magisk supports bind mounting /product now
		MAGISK_VER_CODE=$(grep "MAGISK_VER_CODE=" /data/adb/magisk/util_functions.sh | awk -F = '{ print $2 }')
		if [ $MAGISK_VER_CODE -ge "20000" ]; then
			MOUNTPRODUCT=
			STEPDIR=$MODPATH/system/product/overlay
		else
			if [ $(resetprop ro.build.version.sdk) -ge 29 ]; then
				echo "Magisk v20 is required for users on Android 10"
				echo "Please update Magisk and try again."
				exit 1
			fi
			MOUNTPRODUCT=true
			STEPDIR=/product/overlay
			is_mounted " /product" || mount /product
			is_mounted_rw " /product" || mount_rw /product
		fi
	elif [ -d /oem/OP ];then
		OEM=true
		is_mounted " /oem" || mount /oem
		is_mounted_rw " /oem" || mount_rw /oem
		is_mounted " /oem/OP" || mount /oem/OP
		is_mounted_rw " /oem/OP" || mount_rw /oem/OP
		STEPDIR=/oem/OP/OPEN_US/overlay/framework
	else
		PRODUCT=; OEM=; MOUNTPRODUCT=
		STEPDIR=$MODPATH/system/vendor/overlay
	fi
	if [ "$MOUNTPRODUCT" ]; then
		is_mounted " /product" || mount /product
		is_mounted_rw " /product" || mount_rw /product
	elif [ "$OEM" ];then
		is_mounted " /oem" || mount /oem
		is_mounted_rw " /oem" || mount_rw /oem
		is_mounted " /oem/OP" || mount /oem/OP
		is_mounted_rw " /oem/OP" || mount_rw /oem/OP
	fi
}

#Check whether the unsupported MIUI and OOS
MIUI=$(grep_prop "ro.miui.ui.version.*")
MIUI12=$(grep_prop "ro.miui.ui.version.name")
OOS=$(grep_prop "*Oxygen*")

if [ $MIUI12 = "V12" ]; then
	:
elif [ $MIUI ] && [ -z $MIUI12 ]; then
	sp
	ui_print "  MIUI Detected!"
	ui_print "  Only supported on MIUI 12!"
	sp
	abort "  Sorry!"
fi

# Path-to-install locator
while [ ! -d "$STEPDIR" ]; do
    setvars
    mkdir -p $STEPDIR
done

# Zipname scanner
OIFS=$IFS; IFS=\|
case $(echo $(basename $ZIPFILE) | tr '[:upper:]' '[:lower:]') in
	*t1*) T1=true;;
	*t2*) T2=true;;
	*t3*) T3=true;;
	*w72*) W72=true;;
	*w110*) W110=true;;
	*w160*) W160=true;;
	*imr*) IMR=true;;
	*t1w72*) T1=true; W72=true;;
	*t1w72im*) T1=true; W72=true; IMR=true;;
	*t1w110*) T1=true; W110=true;;
	*t1w110im*) T1=true; W110=true; IMR=true;;
	*t1w160*) T1=true; W160=true;;
	*t1w160im*) T1=true; W160=true; IMR=true;;
	*t1im*) T1=true; IMR=true;;
	*t2w72*) T2=true; W72=true;;
	*t2w72im*) T2=true; W72=true; IMR=true;;
	*t2w110*) T2=true; W110=true;;
	*t2w110im*) T2=true; W110=true; IMR=true;;
	*t2w160*) T2=true; W160=true;;
	*t2w160im*) T2=true; W160=true; IMR=true;;
	*t2im*) T2=true; IMR=true;;
	*t3w72*) T3=true; W72=true;;
	*t3w72im*) T3=true; W72=true; IMR=true;;
	*t3w110*) T3=true; W110=true;;
	*t3w110im*) T3=true; W110=true; IMR=true;;
	*t3w160*) T3=true; W160=true;;
	*t3w160im*) T3=true; W160=true; IMR=true;;
	*t3im*) T3=true; IMR=true;;
	*inv*) INV=true;;
esac
IFS=$OIFS

# Volume chooser
if [ -z $T2 ] || [ -z $T3 ] || [ -z $W110 ] || [ -z $W160 ] || [ -z $IMR ] || [ -z $INV ]; then
	if [ -z $VKSEL ]; then
		sp
		ui_print "  Options not specified in zipname!"
		abort "  Either use vol. button or zipname method!"
	else
		sp
		ui_print "  Customize manually or pick a template"
		ui_print "  Vol [+] = Next, Vol [-] = Select"
		ui_print "  "
		ui_print "  1. Manual Mode"
		ui_print "  2. IOS Pill"
		ui_print "  3. OOS Pill"
		ui_print "  4. AOSP Pill"
		ui_print "  5. Immersive Mode"
		ui_print "  6. Invisible Mode"
		ui_print "  Invisible Mode only available on this dialog!"
		ui_print "  "
		ui_print "  Select:"
		OPT=1
		while true; do
			ui_print "  $OPT"
			sp
			if $VKSEL; then
			OPT=$((OPT + 1))
			else 
				break
			fi
			
			if [ $OPT -gt 6 ]; then
				OPT=1
			fi
		done
		
		if [ $OPT = 2 ]; then
			ui_print "-  IOS Pill Selected  -"
			T3=true
			W160=true
			if [ $OOS ]; then
				sp
				ui_print "  Oxygen OS Detected!"
				ui_print "  Bottom padding will stay default!"
			fi
		elif [ $OPT = 3 ]; then
			ui_print "-  OOS Pill Selected  -"
			T2=true
			W110=true
		elif [ $OPT = 4 ]; then
			ui_print "-  AOSP Pill Selected  -"
			T1=true
			W72=true
		elif [ $OPT = 5 ]; then
			ui_print "-  Immersive Mode Selected  -"
			IMR=true
		elif [ $OPT = 6 ]; then
			ui_print "-  Invisible Mode Selected  -"
			INV=true
		fi
		
		if [ $OPT = 1 ]; then
			ui_print "-  Manual Mode Selected  -"
			if [ -z $T1 ] || [ -z $T2 ] || [ -z $T3 ]; then
				sp
				ui_print "  Change the pill's thickness?"
				ui_print "  Vol+ = Yes, Vol- = No"
				sp
				if $VKSEL; then
					ui_print "  How thick?"
					ui_print "  Vol [+] = Next, Vol [-] = Select"
					ui_print "  "
					ui_print "  1. 1dp (AOSP)"
					ui_print "  2. 2dp (OOS & MIUI 12)"
					ui_print "  3. 3dp (IOS)"
					ui_print "  "
					ui_print "  Select:"
					sp
					OPTM=1
					while true; do
						ui_print "  $OPTM"
						sp
						if $VKSEL; then
						OPTM=$((OPTM + 1))
						else 
							break
						fi
						
						if [ $OPTM -gt 3 ]; then
							OPTM=1
						fi
					done
					
					if [ $OPTM = 1 ]; then
						ui_print "-  1dp (AOSP) Selected  -"
						T1=true
					elif [ $OPTM = 2 ]; then
						ui_print "-  2dp (OOS & MIUI 12) Selected  -"
						T2=true
					elif [ $OPTM = 3 ]; then
						ui_print "-  3dp (IOS) Selected  -"
						T3=true
					fi
				fi
			else
				ui_print "  Pill's Thickness options specified in zipname!"
			fi
			
			if [ -z $W110 ] || [ -z $W160 ]; then
				sp
				ui_print "  Change the pill's width?"
				ui_print "  Vol+ = Yes, Vol- = No"
				sp
				if $VKSEL; then
					ui_print "  How wide?"
					ui_print "  Vol [+] = Next, Vol [-] = Select"
					ui_print "  "
					ui_print "  1. 72dp (AOSP)"
					ui_print "  2. 110dp (OOS)"
					ui_print "  3. 160dp (IOS & MIUI 12)"
					ui_print "  "
					ui_print "  Select:"
					sp
					OPTM=1
					while true; do
						ui_print "  $OPTM"
						sp
						if $VKSEL; then
						OPTM=$((OPTM + 1))
						else 
							break
						fi
						
						if [ $OPTM -gt 3 ]; then
							OPTM=1
						fi
					done
					
					if [ $OPTM = 1 ]; then
						ui_print "-  72dp (AOSP) Selected  -"
						W72=true
					elif [ $OPTM = 2 ]; then
						ui_print "-  110dp (OOS) Selected  -"
						W110=true
					elif [ $OPTM = 3 ]; then
						ui_print "-  160dp (IOS & MIUI 12) Selected  -"
						W160=true
					fi
				fi
			else
				ui_print "  Pill's Width options specified in zipname!"
			fi
		fi

		if [ $INV ] && [ $OPT -ne 5 ]; then
			ui_print "  Immersive options specified in zipname!"
		elif [ -z $INV ]; then
			sp
			ui_print "  Activate Immersive Mode?"
			ui_print "  Vol+ = Yes, Vol- = No"
			sp
			if $VKSEL; then
				ui_print "-  Immersive Mode Selected  -"
				IMR=true
			else
				ui_print "-  Immersive Mode Skipped  -"
			fi
		fi
	fi
else
	ui_print "  Options specified in zipname!"
fi

# Copying mods
sp
ui_print "  Installing..."
MODDIR=$MODPATH/mods

if [ $T1 ]; then
	cp_ch -r $MODDIR/G-PGM-T1.apk $STEPDIR/G-PGM-T
fi

if [ $T2 ]; then
	cp_ch -r $MODDIR/G-PGM-T2.apk $STEPDIR/G-PGM-T
fi

if [ $T3 ]; then
	cp_ch -r $MODDIR/G-PGM-T3.apk $STEPDIR/G-PGM-T
	cp -r -f $MODDIR/FTL/Nav* $STEPDIR
fi

if [ $W72 ]; then
	cp_ch -r $MODDIR/G-PGM-W72.apk $STEPDIR/G-PGM-W
fi

if [ $W110 ]; then
	cp_ch -r $MODDIR/G-PGM-W110.apk $STEPDIR/G-PGM-W
fi

if [ $W160 ]; then
	cp_ch -r $MODDIR/G-PGM-W160.apk $STEPDIR/G-PGM-W
fi

if [ $IMR ]; then
	cp -r -f $MODDIR/FHD/Nav* $STEPDIR
fi

if [ $INV ]; then
	cp_ch -r $MODDIR/G-PGM-IN.apk $STEPDIR/G-PGM-IN
	cp -r -f $MODDIR/FHD/Nav* $STEPDIR
fi

# Can't fix bottom padding on OOS yet
if [ $OOS ]; then
	rm -r $STEPDIR/Nav*
fi

# Checking if mod(s) are copied
if [ -z "$(ls -A $STEPDIR/G-PGM*)" ] || [ -z "$(ls -A $STEPDIR/Nav*)" ] ; then
	echo "The overlays was not copied, please send logs to the developer."
	exit 1
else
	:
fi

unmount_rw_stepdir
