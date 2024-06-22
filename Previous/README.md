# Clover Configuration Files

## BIOS Revision Flashed

ASCN51WW [(Release Notes)](../BIOS/ASCN51WW.txt)

## Clover Version Installed

These files have been running without issues on the official Clover **r5123.1** release on [GitHub](https://github.com/CloverHackyColor/CloverBootloader/releases). Since Clover **r5129** was released, an updated configuration structure was required as Clover now expects "Quirks" to be defined; the "Quirks" section has been added at the bottom of the Clover configuration file and is _specific_ to the laptop's chipset/platform.

**N.B.** Despite following the "Quirks" [Dortania Guide to OpenCore](https://dortania.github.io/OpenCore-Install-Guide/config-laptop.plist/coffee-lake.html) for Whiskey Lake laptops, booting could _not_ be achieved. A member of the [InsanelyMac thread for Clover](https://www.insanelymac.com/forum/topic/284656-clover-general-discussion/) suggested to use the **default "Quirks" found in the sample configuration file** of the Clover release, and this has solved booting.

## Generating Personalised SMBIOS

It is important to generate a personalised SMBIOS using `MacBookPro15,2` as target model. To complete the Clover configuration section for SMBIOS (namely `MLB`, `BoardSerialNumber`, `SerialNumber` and `SmUUID` keys) it is advised to use [GenSMBIOS](https://github.com/corpnewt/GenSMBIOS) scripts and add the generated values in the respective places in `config.plist` file.

**Important Note:** Clover's automatic MAC address retrieval via `UseMacAddr0` for the `ROM` key in **RtVariables** section will _not_ work, as this laptop does _not_ have an Ethernet/LAN port and the WLAN's MAC address in boot-time is _not_ acquired. This is also evident when checking `preboot.log` in Clover via F2 on keyboard; this means that the user must manually add it.

Since a _unique_ number is required for this parameter in **RtVariables** the recommended method is to take the 12 digits from the **en0** network controler (without the colons) and convert them to [Base64](https://cryptii.com/pipes/hex-to-base64) for use as `<data>` under `<key>ROM</key>` in the Clover configuration file. Read more over at [Dortania](https://dortania.github.io/OpenCore-Post-Install/universal/iservices.html#fixing-rom).

To confirm that the injected value works persistently across reboots, one can either run in Terminal [iMessageDebug](https://mac.softpedia.com/get/System-Utilities/iMessageDebug.shtml) or the command:<br/>
`nvram -x 4D1EDE05-38C7-4A6A-9CC6-4BCCA8B38C14:ROM` and verify the output.

## Current Clover Configuration

Most of the configuration keys are set to **false** thus making a minimum needed set of patches, besides any device renaming. Most notably, the following keys are considered:

**Enabled ACPI/Boot/Kernel/System Options**

* `AddMCHC` → no longer used; creates `MCHC` device in IORegistry but this fix has now moved across in **SSDT-APPLE.aml** instead
* `AddPNLF` → key is set to `false` explicitly as we want to use **SSDT-PNLF.aml** instead
* `DeleteUnused` → no longer used; it normally deletes legacy devices from ACPI tables
* **`FixHeaders`** → sanitizes all ACPI headers to avoid kernel panics related to unprintable characters
* `FixRegions` → no longer used; it fixes `OperationRegion` addresses assigned by the BIOS dynamically when custom DSDTs are used
* `DisableASPM` → no longer used; affects Apple's ASPM management if not working e.g. on non-supported chipsets
* `FixMCFG` → not used; fixes MCFG table instead of dropping it; MCFG describes the location of PCI Express configuration space
* `HaltEnabler` → not used; this UEFI boot-time fix concerns problems shutting down or going to sleep
* `PatchAPIC` → not used; the system boots without the need for argument `cpus=1` due to a bad MADT table
* `APLF` and `APSN` → not used; these are only needed to tamper with Intel SpeedStep, needing `PStates` also set to true
* **`PluginType`** → allows native CPU power management by macOS on IvyBridge and newer
* **`NeverHibernate`** → improves overall sleep behaviour as it disables the hibernation state detection
* **`NoEarlyProgress`** → hides any verbose pre-boot output on the screen
* `XMPDetection` → no longer used; detects XMP profiles of installed RAM at boot-time; this is also BIOS-dependent
* **`HWPEnable`** → enables Intel Speed Shift technology, known as Hardware P-State or Hardware Controlled Performance
* `UseARTFrequency` → key is set to `false` explicitly as Clover does _not_ need to calculate the correct Skylake new base frequency
* `HDMIInjection` → key is set to `false` explicitly as we need to disable the injection of HDMI device properties
* `LANInjection` → by default, Clover injects the `built-in` property of a LAN card, but we need to prevent this
* `NoDefaultProperties` → key set to `false` explicitly; we wish to inject own `Properties` outside the scope of Clover's `FakeID` key
* `SetIntelBacklight` → not used; this replaces the need for IntelBacklight and ACPIBacklight kexts to control screen brightness
* `SetIntelMaxBacklight` → not used; if `true` this sets a defined `IntelMaxValue` key value as the laptop screen brightness
* `FixOwnership` → not relevant for UEFI booting; gives USB ownership to the OS instead, as BIOS usually retains control
* `UseIntelHDMI` → not used; injects `hda-gfx=onboard-1` in `GFX0` and `HDEF` devices already done by **AppleALC** and **WhateverGreen**
* **`ProvideConsoleGop`** → ensures that Graphics Output Protocol or 'GOP' is available on the console handle
* `AppleIntelCPUPM` → not used; prevents kernel panics and allows native power management on older CPUs with MSR `0xE2` locked
* `AppleRTC` → not used; fixes BIOS CMOS issues where each wake after sleep and reboot results to a reset, while losing BIOS settings
* `DellSMBIOSPatch` → no longer used; fixes the issue where the UEFI BIOS tampers with the finished SMBIOS and prevents system boot
* `EightApple` → not needed; attempts to fix the boot screen Apple logo that may break at some point to multiple logos on-screen
* `KernelLapic` → not used; mostly for HP notebooks with Local APIC problems, otherwise solved by using the boot argument `cpus=1`
* **`KernelPm`** → the only patch needed in `KernelAndKextPatches` category as MSR `0xE2` cannot be unlocked on this computer
* `KernelXCPM` → not used; as XCPM support for IvyBridge processors has been discontinued in 10.12, this setting brings back XCPM
* **`PanicNoKextDump`** → avoids kext-dumping in a panic situation for diagnosing problems
* **`RtVariables`** → defines a custom ROM value as Clover's auto-detection fails in our case
* **`InjectKexts`** → needed to be `true` as all kexts reside in EFI partition now
* **`InjectSystemID`** → sets the SmUUID as the 'system-id' at boot-time

**N.B.** To overcome the MSR `0xE2` (Cfg Lock) issue, we use `KernelPM` as it deals with Ivy Bridge CPUs (in XCPM mode) and newer, whereas `AppleIntelCPUPM` deals with older CPU generations up to IvyBridge.

**Note:** User [slice](https://www.insanelymac.com/forum/profile/112217-slice/) (one of the Clover developers) confirmed that `DeleteUnused` deletes such legacy devices as `CRT_`, `DVI_`, `SPKR`, `ECP_`, `LPT_`, `FDC_` that _no longer_ exist in modern motherboards, including this laptop.

**Clover Device Properties**

* Define graphics `AAPL,ig-platform-id` and `device-id` for Intel UHD Graphics 620
* Define `AAPL,slot-name` and `brcmfx-country` for Broadcom BCM4350 WLAN Adapter
* Define audio `layout-id` for Realtek ALC230 Audio Controller
* Define an `acpi-wake-type` value for the Intel XHCI controller
* Define a compatible SATA controller (`pci8086,9d03` as "Intel 10 Series Chipset")

**N.B.** The original idea of defining a compatible Thermal Controller device (such as `pci8086,9d21` for detected Intel device [[8086:9df9]](https://pci-ids.ucw.cz/read/PC/8086/9df9)) was _dropped_ as there appears no real compatibility.

**Renamed Devices**

* `_DSM` to `XDSM`
* `_OSI` to `XOSI` → used in conjunction with **SSDT-XOSI.aml**
* `_Q11` to `XQ11` → used in conjunction with **SSDT-BRIGHT.aml**
* `_Q12` to `XQ12` → used in conjunction with **SSDT-BRIGHT.aml**
* `EC0` to `EC` → macOS needed device and an absolute _must_ for a successful boot :warning:
* `GFX0` to `IGPU` → although **WhateverGreen** can do that, too
* `GPRW` to `XPRW` → used in conjunction with **SSDT-GPRW.aml**
* `HDAS` to `HDEF` → although **AppleALC** can do that, too
* `HECI` to `IMEI` → although **WhateverGreen** can do that, too
* `SAT0` to `SATA`
* `_SB.PCI0.RP13.PXSX` to `SSD0` → renames the internal **NVMe** device

**Note:** Since Clover r5131 the `RenameDevices` section of **config.plist** requires an `<array>` with `<dict>` entries per device. Subsequent Clover releases will understand the previous **config.plist** layout; however do _not_ use this newer **config.plist** layout with older Clover releases as this may cause Clover to crash.

## Current SSDTs Used :white_check_mark:

**SSDT-APPLE.aml**<br/>
Adds native vanilla `Device (DMAC)` and `Device (FWHD)` like a real Mac.

**SSDT-AWAC.aml**<br/>
Bypasses the newer BIOS real-time clock `Device (AWAC)` that is meant as a replacement of `Device (RTC)` by injecting **STAS** value as **One**. This is a cleaner solution to any DSDT hot-patching by replacing bytes in a specific sequence.

**SSDT-BRIGHT.aml**<br/>
Injects keyboard shortcuts so that screen brightness can be natively controlled via F11 or F12 keys on this laptop model; DSDT patching is needed by replacing `_Q11` and `_Q12` with `XQ11` and `XQ12` respectively.

**SSDT-I2C0.aml**<br/>
Adds the two needed missing `Method (SSCN)` and `Method (FMCN)` that would enable this laptop's **ELAN0629** touchpad to work via polling method.

**SSDT-NAMES.aml**<br/>
This injects device names to otherwise unnamed IORegistry devices, simply because they are not defined in the original DSDT of the BIOS. Although not needed for a functional macOS, these are mainly done for aesthetic reasons.

**SSDT-PMCR.aml**<br/>
Injects the native vanilla `Device (PMCR)` that is accessed by the **AppleIntelPCHPMC** driver and unlocks, as reported, the use of NVRAM if otherwise not already done by the BIOS.

**SSDT-PNLF.aml**<br/>
Injects the needed panel `Device (PNLF)` and the ambient light sensor `Device (ALS0)` just like in real MacBook Pro laptops.

**SSDT-SBUS.aml**<br/>
To simulate a real Mac, two sub-devices are injected in the existing SMBus device, namely `Device (BUS0)` and `Device (BUS1)`. Although these do _not_ appear in IORegistry Explorer, they do exist in the original DSDT of a modern Mac.

**SSDT-USBX.aml**<br/>
The needed `Device (USBX)` is injected to define the USB port(s) power supply and current limit values, as found in real MacBook Pro laptops.

**SSDT-XOSI.aml**<br/>
Combined with the needed DSDT patching (replacing `_OSI` with `XOSI`) this allows to emulate a Windows system running, thus getting increased compatibility in general.

## Dropped SSDTs :warning:

The following SSDTs were _dropped_ as they are no longer needed or proved incompatible:

**SSDT-GPRW.aml**<br/>
Despite being a replacement method for the power-focused `Method (GPRW)` that targets better sleep, with the newer BIOS update and latest Catalina update, it seems that sleep is now working as expected _without_ this SSDT.

**SSDT-HPTE.aml**<br/>
Although most modern Macs do not show `Device (HPET)` in the IORegistry, it was discovered by accident that disabling "HPET" via this SSDT on this laptop causes **problems** with the replacement Broadcom WLAN adapter (the PCI device was somewhat not accessible). Ever since leaving "HPET" in its original state, the Broadcom WLAN adapter is detected upon every boot.

**SSDT-SLPB.aml**<br/>
Despite a simple code injection of the non-existent sleep-button `Device (SLPB)` this seems to cause the panel `PNLF` device to _not_ activate after the boot process completes and after **WhateverGreen** kicks-in, so it was therefore dropped.

## Important Notes

### USBPorts.kext generated with Hackintool

This laptop has **three** visible USB ports on the right-hand side: 1 x USB 2.0 and 2 x USB 3.0 connectors. The generated **USBPorts.kext** therefore contains and defines both **HSxx** and **SS0x** types of ports as being of `UsbConnector` type "0" and "3" respectively, because it reflects the actual *electrical* connector.

### :warning: Wireless card detection

The replacement Broadcom BCM4350 wireless card was causing crashes and other issues with older versions of [AirportBrcmFixup](https://github.com/acidanthera/AirportBrcmFixup) as the device ID was not _natively_ recognised by the kext, therefore a compatibility ID was needed to be defined in the bootloader's configuration in order to successfully boot to macOS **Catalina** 10.15.7:

```
<key>PciRoot(0x0)/Pci(0x1d,0x0)/Pci(0x0,0x0)</key>
<dict>
	<key>AAPL,slot-name</key>
	<string>WLAN</string>
	<key>brcmfx-country</key>
	<string>FR</string>
	<key>compatible</key>
	<string>pci14e4,4353</string>
	<key>device_type</key>
	<string>AirPort Extreme</string>
	<key>name</key>
	<string>AirPort</string>
	<key>pci-aspm-default</key>
	<integer>0</integer>
	<key>model</key>
	<string>Broadcom BCM4350 Wireless Network Adapter</string>
</dict>
```

The vendor and device IDs were reported to the developer(s) and since 2.0.8 release of **AirportBrcmFixup**, this compatibility ID injection was no longer needed as the card worked without problems, whatsoever.

The arrival of macOS Big Sur brought many changes according to this [OSXLatitude thread](https://osxlatitude.com/forums/topic/11322-broadcom-bcm4350-cards-under-high-sierramojavecatalinabig-surmonterey/), as it was found that `AirPortBrcm4360.kext` was absent, resulting to the **lack of support** for Broadcom BCM4331 and BCM43324 chipsets. A workaround proposed was to re-inject a `compatible` key but this time with a different value, namely `pci14e4,43a0` for BCM4360 or `pci14e4,43ba` for BCM43602 emulation:

```
<key>PciRoot(0x0)/Pci(0x1d,0x0)/Pci(0x0,0x0)</key>
<dict>
	<key>AAPL,slot-name</key>
	<string>WLAN</string>
	<key>brcmfx-country</key>
	<string>FR</string>
	<key>compatible</key>
	<string>pci14e4,43a0</string>
	<key>device_type</key>
	<string>AirPort Extreme</string>
	<key>name</key>
	<string>AirPort</string>
	<key>pci-aspm-default</key>
	<integer>0</integer>
	<key>model</key>
	<string>Broadcom BCM4350 Wireless Network Adapter</string>
</dict>
```

On this specific laptop, however, there were problems detecting this wireless card with _either_ new key value during every boot, so it was totally abandonned in favour of the Wireless-AC 9260 card.
