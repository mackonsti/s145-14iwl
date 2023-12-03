# DSDT Edits & Improvements

## Version 0

Cleaned-up code and removed some `iasl` comments.

## Version 1

Removed all `Method (_DSM)` entries via MaciASL.

## Version 2

* Add all needed vanilla devices:<br/>
`Device (MCHC)`<br/>
`Device (PGMM)`<br/>
`Device (THRM)`<br/>
`Device (SRAM)`<br/>
`Device (XSPI)`<br/>
`Device (PNLF)`<br/>
`Device (ALS0)`<br/>
`Device (USBX)`<br/>
`Device (SBUS)`<br/>
`Device (SLPB)`<br/>
`Device (DMAC)`<br/>
`Device (FWHD)`<br/>
`Device (PMCR)`<br/>
* Added `Method (SSCN)` and `Method (FMCN)` in `Device (I2C0)` for ELAN polling.
* Added brightness control in `Method (_Q11)` and `Method (_Q12)` of `Scope (EC0)`.
* Added "Darwin" to `Method (_INI)` matching "Windows 2015".

## Version 3

* Verified that all Mutex variables get assigned `(0x00)` value.
* Kept `Device (AWAC)` disabled via `Method (_STA)` where `(STAS)` must be `(Zero)`.
* Kept `Device (RTC)` enabled via `Method (_STA)` where `(STAS)` must be `(One)`.
* Added `Method (_DSM)` property "uart-channel-number" in `Device (UA00)` just like MacBookPro15,2.
* Added `Method (_DSM)` property "acpi-wake-gpe" in `Device (EC0)` just like MacBookPro15,2.
* Added `Method (_DSM)` property "acpi-wake-gpe" in `Device (ADP0)` just like MacBookPro15,2.
* Added `Method (_DSM)` property "acpi-wake-gpe" in `Device (LID0)` just like MacBookPro15,2.
* Removed `Method (_STA)` from `Device (MATH)` just like MacBookPro15,2.
* Added legacy code fix in `Method (_WAK)`.

## Version 4

Experimental changes and modifications, mainly for testing and learning.

## Using Custom DSDT in Clover

Clover allows to distinguish between the computer's native DSDT and a _custom_ DSDT via a single parameter in the configuration.

To keep using the firmware's untouched ACPI Tables (for DSDT) even if a custom **DSDT.aml** is present in the `/ACPI/patched/` folder, the `Name` key in the ACPI → DSDT section of the configuration must point to `BIOS.aml` virtual entry:

```
<dict>
	<key>ACPI</key>
	<dict>
		<key>DSDT</key>
		<dict>
			<key>Name</key>
			<string>BIOS.aml</string>
[...]
```

Alternatively, to force Clover into using the custom **DSDT.aml** file once it is successfully patched and compiled with `iasl` we only need to change the `Name` key to point to our own DSDT file, instead:

```
<dict>
	<key>ACPI</key>
	<dict>
		<key>DSDT</key>
		<dict>
			<key>Name</key>
			<string>DSDT.aml</string>
[...]
```
