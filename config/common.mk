PRODUCT_BRAND ?= VM12

ifneq ($(TARGET_SCREEN_WIDTH) $(TARGET_SCREEN_HEIGHT),$(space))
# determine the smaller dimension
TARGET_BOOTANIMATION_SIZE := $(shell \
  if [ $(TARGET_SCREEN_WIDTH) -lt $(TARGET_SCREEN_HEIGHT) ]; then \
    echo $(TARGET_SCREEN_WIDTH); \
  else \
    echo $(TARGET_SCREEN_HEIGHT); \
  fi )

# get a sorted list of the sizes
bootanimation_sizes := $(subst .zip,, $(shell ls vendor/vm12/prebuilt/common/bootanimation))
bootanimation_sizes := $(shell echo -e $(subst $(space),'\n',$(bootanimation_sizes)) | sort -rn)

# find the appropriate size and set
define check_and_set_bootanimation
$(eval TARGET_BOOTANIMATION_NAME := $(shell \
  if [ -z "$(TARGET_BOOTANIMATION_NAME)" ]; then
    if [ $(1) -le $(TARGET_BOOTANIMATION_SIZE) ]; then \
      echo $(1); \
      exit 0; \
    fi;
  fi;
  echo $(TARGET_BOOTANIMATION_NAME); ))
endef
$(foreach size,$(bootanimation_sizes), $(call check_and_set_bootanimation,$(size)))

ifeq ($(TARGET_BOOTANIMATION_HALF_RES),true)
PRODUCT_BOOTANIMATION := vendor/vm12/prebuilt/common/bootanimation/halfres/$(TARGET_BOOTANIMATION_NAME).zip
else
PRODUCT_BOOTANIMATION := vendor/vm12/prebuilt/common/bootanimation/$(TARGET_BOOTANIMATION_NAME).zip
endif
endif

PRODUCT_BUILD_PROP_OVERRIDES += BUILD_UTC_DATE=0

ifeq ($(PRODUCT_GMS_CLIENTID_BASE),)
PRODUCT_PROPERTY_OVERRIDES += \
    ro.com.google.clientidbase=android-google
else
PRODUCT_PROPERTY_OVERRIDES += \
    ro.com.google.clientidbase=$(PRODUCT_GMS_CLIENTID_BASE)
endif

PRODUCT_PROPERTY_OVERRIDES += \
    keyguard.no_require_sim=true \
    ro.url.legal=http://www.google.com/intl/%s/mobile/android/basic/phone-legal.html \
    ro.url.legal.android_privacy=http://www.google.com/intl/%s/mobile/android/basic/privacy.html \
    ro.com.android.wifi-watchlist=GoogleGuest \
    ro.setupwizard.enterprise_mode=1 \
    ro.com.android.dateformat=MM-dd-yyyy \
    ro.com.android.dataroaming=false

PRODUCT_PROPERTY_OVERRIDES += \
    ro.build.selinux=0

# Thank you, please drive thru!
PRODUCT_PROPERTY_OVERRIDES += persist.sys.dun.override=0

ifneq ($(TARGET_BUILD_VARIANT),eng)
# Enable ADB authentication
ADDITIONAL_DEFAULT_PROPERTIES += ro.adb.secure=0
endif

# Copy over the changelog to the device
PRODUCT_COPY_FILES += \
    vendor/vm12/CHANGELOG.mkdn:system/etc/CHANGELOG-RR.txt

# Backup Tool
ifneq ($(WITH_GMS),true)
PRODUCT_COPY_FILES += \
    vendor/vm12/prebuilt/common/bin/backuptool.sh:install/bin/backuptool.sh \
    vendor/vm12/prebuilt/common/bin/backuptool.functions:install/bin/backuptool.functions \
    vendor/vm12/prebuilt/common/bin/50-cm.sh:system/addon.d/50-cm.sh \
    vendor/vm12/prebuilt/common/bin/blacklist:system/addon.d/blacklist
endif

# Signature compatibility validation
PRODUCT_COPY_FILES += \
    vendor/vm12/prebuilt/common/bin/otasigcheck.sh:install/bin/otasigcheck.sh

# init.d support
PRODUCT_COPY_FILES += \
    vendor/vm12/prebuilt/common/etc/init.d/00banner:system/etc/init.d/00banner \
    vendor/vm12/prebuilt/common/bin/sysinit:system/bin/sysinit

# userinit support
PRODUCT_COPY_FILES += \
    vendor/vm12/prebuilt/common/etc/init.d/90userinit:system/etc/init.d/90userinit

# VM12-specific init file
PRODUCT_COPY_FILES += \
    vendor/vm12/prebuilt/common/etc/init.local.rc:root/init.cm.rc

# Gesture Typing 
PRODUCT_COPY_FILES += \
    vendor/vm12/prebuilt/common/lib/libjni_latinimegoogle.so:system/lib/libjni_latinimegoogle.so

# Sloth Walls
PRODUCT_COPY_FILES += \
    vendor/vm12/prebuilt/common/slothwalls/com.nocturnal.sloth.apk:system/app/SlothWalls/com.nocturnal.sloth.apk

# Bring in camera effects
PRODUCT_COPY_FILES +=  \
    vendor/vm12/prebuilt/common/media/LMprec_508.emd:system/media/LMprec_508.emd \
    vendor/vm12/prebuilt/common/media/PFFprec_600.emd:system/media/PFFprec_600.emd

# Enable SIP+VoIP on all targets
PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.software.sip.voip.xml:system/etc/permissions/android.software.sip.voip.xml

# Enable wireless Xbox 360 controller support
PRODUCT_COPY_FILES += \
    frameworks/base/data/keyboards/Vendor_045e_Product_028e.kl:system/usr/keylayout/Vendor_045e_Product_0719.kl

# This is VM12Based!
PRODUCT_COPY_FILES += \
    vendor/vm12/config/permissions/com.cyanogenmod.android.xml:system/etc/permissions/com.cyanogenmod.android.xml

# T-Mobile theme engine
include vendor/vm12/config/themes_common.mk

# Required VM12 packages
PRODUCT_PACKAGES += \
    Development \
    LatinIME \
    BluetoothExt \
    Profiles

# Optional VM12 packages
PRODUCT_PACKAGES += \
    VoicePlus \
    Basic \
    libemoji \
    Terminal

# Custom VM12 packages
PRODUCT_PACKAGES += \
    Launcher3 \
    Trebuchet \
    AudioFX \
    Eleven \
    LockClock

# CM Platform Library
PRODUCT_PACKAGES += \
    org.cyanogenmod.platform-res \
    org.cyanogenmod.platform \
    org.cyanogenmod.platform.xml

# CM Hardware Abstraction Framework
PRODUCT_PACKAGES += \
    org.cyanogenmod.hardware \
    org.cyanogenmod.hardware.xml

# Extra tools in VM12
PRODUCT_PACKAGES += \
    libsepol \
    e2fsck \
    mke2fs \
    tune2fs \
    bash \
    nano \
    htop \
    powertop \
    lsof \
    mount.exfat \
    fsck.exfat \
    mkfs.exfat \
    mkfs.f2fs \
    fsck.f2fs \
    fibmap.f2fs \
    ntfsfix \
    ntfs-3g \
    gdbserver \
    micro_bench \
    oprofiled \
    sqlite3 \
    strace

# Openssh
PRODUCT_PACKAGES += \
    scp \
    sftp \
    ssh \
    sshd \
    sshd_config \
    ssh-keygen \
    start-ssh

# rsync
PRODUCT_PACKAGES += \
    rsync

# Stagefright FFMPEG plugin
PRODUCT_PACKAGES += \
    libstagefright_soft_ffmpegadec \
    libstagefright_soft_ffmpegvdec \
    libFFmpegExtractor \
    libnamparser

# These packages are excluded from user builds
ifneq ($(TARGET_BUILD_VARIANT),user)
PRODUCT_PACKAGES += \
    procmem \
    procrank \
    su
endif

PRODUCT_PROPERTY_OVERRIDES += \
    persist.sys.root_access=0

PRODUCT_PACKAGE_OVERLAYS += vendor/vm12/overlay/common

PRODUCT_VERSION_MAJOR = VM12
PRODUCT_VERSION_MINOR = 1.1
PRODUCT_VERSION_MAINTENANCE = 0-RC0

# Set VM12_BUILDTYPE from the env RELEASE_TYPE, for jenkins compat

ifndef VM12_BUILDTYPE
    ifdef RELEASE_TYPE
        # Starting with "VM12_" is optional
        RELEASE_TYPE := $(shell echo $(RELEASE_TYPE) | sed -e 's|^VM12_||g')
        VM12_BUILDTYPE := $(RELEASE_TYPE)
    endif
endif

# Filter out random types, so it'll reset to UNOFFICIAL
ifeq ($(filter RELEASE NIGHTLY SNAPSHOT EXPERIMENTAL,$(VM12_BUILDTYPE)),)
    VM12_BUILDTYPE :=
endif

ifdef VM12_BUILDTYPE
    ifneq ($(VM12_BUILDTYPE), SNAPSHOT)
        ifdef VM12_EXTRAVERSION
            # Force build type to EXPERIMENTAL
            VM12_BUILDTYPE := EXPERIMENTAL
            # Remove leading dash from VM12_EXTRAVERSION
            VM12_EXTRAVERSION := $(shell echo $(VM12_EXTRAVERSION) | sed 's/-//')
            # Add leading dash to VM12_EXTRAVERSION
            VM12_EXTRAVERSION := -$(VM12_EXTRAVERSION)
        endif
    else
        ifndef VM12_EXTRAVERSION
            # Force build type to EXPERIMENTAL, SNAPSHOT mandates a tag
            VM12_BUILDTYPE := EXPERIMENTAL
        else
            # Remove leading dash from VM12_EXTRAVERSION
            VM12_EXTRAVERSION := $(shell echo $(VM12_EXTRAVERSION) | sed 's/-//')
            # Add leading dash to VM12_EXTRAVERSION
            VM12_EXTRAVERSION := -$(VM12_EXTRAVERSION)
        endif
    endif
else
    # If VM12_BUILDTYPE is not defined, set to UNOFFICIAL
    VM12_BUILDTYPE := 3.0.0
    VM12_EXTRAVERSION :=
endif

ifeq ($(VM12_BUILDTYPE), UNOFFICIAL)
    ifneq ($(TARGET_UNOFFICIAL_BUILD_ID),)
        VM12_EXTRAVERSION := -$(TARGET_UNOFFICIAL_BUILD_ID)
    endif
endif

ifeq ($(VM12_BUILDTYPE), RELEASE)
    ifndef TARGET_VENDOR_RELEASE_BUILD_ID
        VM12_VERSION := $(PRODUCT_VERSION_MAJOR).$(PRODUCT_VERSION_MINOR).$(PRODUCT_VERSION_MAINTENANCE)$(PRODUCT_VERSION_DEVICE_SPECIFIC)-$(VM12_BUILD)
    else
        ifeq ($(TARGET_BUILD_VARIANT),user)
            VM12_VERSION := $(PRODUCT_VERSION_MAJOR).$(PRODUCT_VERSION_MINOR)-$(TARGET_VENDOR_RELEASE_BUILD_ID)-$(VM12_BUILD)
        else
            VM12_VERSION := $(PRODUCT_VERSION_MAJOR).$(PRODUCT_VERSION_MINOR).$(PRODUCT_VERSION_MAINTENANCE)$(PRODUCT_VERSION_DEVICE_SPECIFIC)-$(VM12_BUILD)
        endif
    endif
else
    ifeq ($(PRODUCT_VERSION_MINOR),0)
        VM12_VERSION := $(PRODUCT_VERSION_MAJOR)-$(shell date -u +%Y%m%d)-$(VM12_BUILDTYPE)$(VM12_EXTRAVERSION)-$(VM12_BUILD)
    else
        VM12_VERSION := $(PRODUCT_VERSION_MAJOR).$(PRODUCT_VERSION_MINOR)-$(shell date -u +%Y%m%d)-$(VM12_BUILDTYPE)$(VM12_EXTRAVERSION)-$(VM12_BUILD)
    endif
endif

PRODUCT_PROPERTY_OVERRIDES += \
  ro.vm12.version=$(VM12_BUILD) \
  ro.vm12.releasetype=$(VM12_BUILDTYPE) \
  ro.vm12_modversion=$(VM12_BUILDTYPE) \
  ro.VM12legal.url=https://cyngn.com/legal/privacy-policy

-include vendor/VM12-priv/keys/keys.mk

VM12_DISPLAY_VERSION := $(VM12_VERSION)

ifneq ($(PRODUCT_DEFAULT_DEV_CERTIFICATE),)
ifneq ($(PRODUCT_DEFAULT_DEV_CERTIFICATE),build/target/product/security/testkey)
  ifneq ($(VM12_BUILDTYPE), UNOFFICIAL)
    ifndef TARGET_VENDOR_RELEASE_BUILD_ID
      ifneq ($(VM12_EXTRAVERSION),)
        # Remove leading dash from VM12_EXTRAVERSION
        VM12_EXTRAVERSION := $(shell echo $(VM12_EXTRAVERSION) | sed 's/-//')
        TARGET_VENDOR_RELEASE_BUILD_ID := $(VM12_EXTRAVERSION)
      else
        TARGET_VENDOR_RELEASE_BUILD_ID := $(shell date -u +%Y%m%d)
      endif
    else
      TARGET_VENDOR_RELEASE_BUILD_ID := $(TARGET_VENDOR_RELEASE_BUILD_ID)
    endif
    VM12_DISPLAY_VERSION=$(PRODUCT_VERSION_MAJOR).$(PRODUCT_VERSION_MINOR)-$(TARGET_VENDOR_RELEASE_BUILD_ID)
  endif
endif
endif

# by default, do not update the recovery with system updates
PRODUCT_PROPERTY_OVERRIDES += persist.sys.recovery_update=false

PRODUCT_PROPERTY_OVERRIDES += \
  ro.VM12.display.version=$(VM12_DISPLAY_VERSION)

-include $(WORKSPACE)/build_env/image-auto-bits.mk

-include vendor/cyngn/product.mk

$(call prepend-product-if-exists, vendor/extra/product.mk)
