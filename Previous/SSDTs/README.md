# Custom SSDTs

**SSDT-APPLE.aml**<br/>
Adds native vanilla `Device (DMAC)` and `Device (FWHD)` like a real Mac.

**SSDT-AWAC.aml**<br/>
Bypass the newer BIOS real-time clock `Device (AWAC)` that is meant as a replacement of `(RTC)`, by setting **STAS** variable to `One`. This is a much cleaner solution compared to any DSDT "hot-patching" that _replaces_ bytes in a specific sequence.

**SSDT-BRIGHT.aml**<br/>
Injects keyboard shortcuts so that screen brightness can be natively controlled via F11 or F12 keys on this laptop model; DSDT patching is needed by replacing `_Q11` and `_Q12` with `XQ11` and `XQ12` respectively.

**SSDT-GPRW.aml**<br/>
Despite being a replacement method for the power-focused `Method (GPRW)` that targets better sleep, with the newer BIOS update and latest Catalina update, it seems that sleep is now working as expected _without_ this SSDT.

**SSDT-HPTE.aml**<br/>
Although most modern Macs do not show `Device (HPET)` in the IORegistry, it was discovered by accident that disabling "HPET" via this SSDT on this laptop causes **problems** with the replacement Broadcom WLAN adapter (the PCI device was somewhat not accessible). Ever since leaving "HPET" in its original state, the Broadcom WLAN adapter is detected upon every boot.

**SSDT-I2C0.aml**<br/>
Adds the two needed missing `Method (SSCN)` and `Method (FMCN)` that would enable this laptop's **ELAN0629** touchpad to work via polling method.

**SSDT-NAMES.aml**<br/>
This injects device names to otherwise unnamed IORegistry devices, simply because they are not defined in the original DSDT of the BIOS. Although not needed for a functional macOS, these are mainly done for aesthetic reasons.

**SSDT-PMCR.aml**<br/>
Injects the native vanilla `Device (PMCR)` that is accessed by the **AppleIntelPCHPMC** driver and unlocks the use of NVRAM if otherwise not already done by the BIOS.

**SSDT-PNLF.aml**<br/>
Injects the needed panel `Device (PNLF)` and the ambient light sensor `Device (ALS0)` just like in real MacBook Pro laptops.

**SSDT-SBUS.aml**<br/>
To simulate a real Mac, two sub-devices are injected in the existing SMBus device, namely `(BUS0)` and `(BUS1)`. Although these do _not_ appear in IORegistry, they do exist in the original DSDT of a modern Mac.

**SSDT-SLPB.aml**<br/>
Despite a simple code injection of the non-existent sleep-button `Device (SLPB)` this seems to cause the panel `PNLF` device to _not_ activate once the boot process completes and after **WhateverGreen** kicks-in, so it was therefore dropped.

**SSDT-USBX.aml**<br/>
The required `Device (USBX)` is injected to define the USB port(s) power supply and current limit values, as found in real MacBook Pro laptops.

**SSDT-XOSI.aml**<br/>
Combined with the needed DSDT patching (replacing `_OSI` with `XOSI` in DSDT) this allows to emulate a Windows system running, thus getting increased compatibility in general (e.g. the trackpad).
