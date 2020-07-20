#!/sbin/sh
#
# ADDOND_VERSION=2
#
# BiTGApps Unified addon.d script
#

. /tmp/backuptool.functions

if [ -z $backuptool_ab ]; then
  SYS=$S
  TMP=/tmp
else
  SYS=/postinstall/system
  TMP=/postinstall/tmp
fi;

list_files() {
cat << EOF
app/FaceLock/FaceLock.apk
app/GoogleCalendarSyncAdapter/GoogleCalendarSyncAdapter.apk
app/GoogleContactsSyncAdapter/GoogleContactsSyncAdapter.apk
app/GoogleExtShared/GoogleExtShared.apk
app/MarkupGoogle/MarkupGoogle.apk
app/SoundPickerPrebuilt/SoundPickerPrebuilt.apk
priv-app/ConfigUpdater/ConfigUpdater.apk
priv-app/GoogleBackupTransport/GoogleBackupTransport.apk
priv-app/GoogleExtServices/GoogleExtServices.apk
priv-app/GoogleLoginService/GoogleLoginService.apk
priv-app/GoogleRestore/GoogleRestore.apk
priv-app/GoogleServicesFramework/GoogleServicesFramework.apk
priv-app/Phonesky/Phonesky.apk
priv-app/PrebuiltGmsCore/PrebuiltGmsCore.apk
priv-app/PrebuiltGmsCorePi/PrebuiltGmsCorePi.apk
priv-app/PrebuiltGmsCorePix/PrebuiltGmsCorePix.apk
priv-app/PrebuiltGmsCorePix/PrebuiltGmsCoreQt.apk
priv-app/SetupWizard/SetupWizard.apk
priv-app/Velvet/Velvet.apk
priv-app/WellbeingPrebuilt/WellbeingPrebuilt.apk
etc/default-permissions/default-permissions.xml
etc/default-permissions/opengapps-permissions.xml
etc/permissions/com.google.android.dialer.support.xml
etc/permissions/com.google.android.maps.xml
etc/permissions/com.google.android.media.effects.xml
etc/permissions/privapp-permissions-google.xml
etc/permissions/split-permissions-google.xml
etc/preferred-apps/google.xml
etc/sysconfig/dialer_experience.xml
etc/sysconfig/google.xml
etc/sysconfig/google_build.xml
etc/sysconfig/google_exclusives_enable.xml
etc/sysconfig/google-hiddenapi-package-whitelist.xml
etc/sysconfig/pixel_experience_2017.xml
etc/sysconfig/pixel_experience_2018.xml
etc/sysconfig/pixel_experience_2019_midyear.xml
etc/sysconfig/pixel_experience_2019.xml
etc/sysconfig/whitelist_com.android.omadm.service.xml
etc/g.prop
framework/com.google.android.dialer.support.jar
framework/com.google.android.maps.jar
framework/com.google.android.media.effects.jar
lib/libfilterpack_facedetect.so
lib/libfrsdk.so
lib/libsketchology_native.so
lib64/libfacenet.so
lib64/libfilterpack_facedetect.so
lib64/libfrsdk.so  
lib64/libjni_latinimegoogle.so
lib64/libsketchology_native.so
xbin/pm.sh
EOF
}

# Get ROM SDK from installed GApps
API="$(cd $SYS; grep "^ro.build.version.sdk" build.prop | cut -d '=' -f 2)"

case "$1" in
  backup)
    list_files | while read -r FILE DUMMY; do
      backup_file "$S"/"$FILE"
    done
  ;;
  restore)
    list_files | while read -r FILE REPLACEMENT; do
      R=""
      [ -n "$REPLACEMENT" ] && R="$S/$REPLACEMENT"
      [ -f "$C/$S/$FILE" ] && restore_file "$S"/"$FILE" "$R"
    done
  ;;
  pre-backup)
    # Stub
  ;;
  post-backup)
    # Stub
  ;;
  pre-restore)
    # Stub
    rm -rf $SYS/product/app/ManagedProvisioning
    rm -rf $SYS/product/app/Provision
    rm -rf $SYS/product/priv-app/ManagedProvisioning
    rm -rf $SYS/product/priv-app/Provision
    rm -rf $SYS/app/ExtShared
    rm -rf $SYS/app/ManagedProvisioning
    rm -rf $SYS/app/Provision
    rm -rf $SYS/priv-app/ExtServices
    rm -rf $SYS/priv-app/ManagedProvisioning
    rm -rf $SYS/priv-app/Provision
  ;;
  post-restore)
    # Stub
    for i in $(list_files); do
      chown root:root "$SYS/$i"
      chmod 644 "$SYS/$i"
      chmod 755 "$(dirname "$SYS/$i")"
    done
    if [ "$API" -ge "26" ]; then # Android 8.0+ uses 0600 for its permission on build.prop
      chmod 600 "$SYS/build.prop"
    fi
    if [ "$API" == "27" ] || [ "$API" == "25" ]; then
      mkdir $SYS/app/FaceLock/lib
      mkdir $SYS/app/FaceLock/lib/arm64
      chmod 0755 $SYS/app/FaceLock/lib
      chmod 0755 $SYS/app/FaceLock/lib/arm64
      ln -sfnv /system/lib64/libfacenet.so /system/app/FaceLock/lib/arm64/libfacenet.so
    fi;
  ;;
esac
