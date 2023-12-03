/*
 * Intel ACPI Name Space Architecture for Lenovo IdeaPad S145-14iWL
 *
 * NOTES:
 * Systems using an SMBIOS newer than iMac7,1 or MacBook13,1 should add a device named 'USBX' under scope _SB.
 * Missing this device may result to USB devices not being recognized or macOS giving a prompt "USB Accessory
 * Needs Power". Once fantom or unnecessary USB ports are identified and eliminated via USBInjectAll.kext or
 * Hackintool, this device must be injected together with a valid or fake Device (EC) as well.
 *
 * KEXT REFERENCES:
 * /System/Library/Extensions/AppleBusPowerController.kext/Contents/Info.plist
 *
 * DefinitionBlock (AMLFileName, TableSignature, ComplianceRevision, OEMID, TableID, OEMRevision)
 *
 *    AMLFileName = Name of the AML file (string); can be a null string too;
 *    TableSignature = Signature of the AML file (DSDT or SSDT) (4-character string);
 *    ComplianceRevision = 1 or less for 32-bit arithmetic; 2 or greater for 64-bit arithmetic (8-bit unsigned integer);
 *    OEMID = ID of the Original Equipment Manufacturer of this ACPI table (6-character string);
 *    TableID = A specific identifier for the table (8-character string);
 *    OEMRevision = A revision number set by the OEM (32-bit number).
 */

DefinitionBlock ("SSDT-USBX.aml", "SSDT", 2, "OC", "_USBX", 0x00000000)
{
    Scope (\_SB)
    {
        Device (USBX)
        {
            Name (_ADR, Zero)  // _ADR: Address
            Method (_DSM, 4, NotSerialized)  // _DSM: Device-Specific Method
            {
                If ((Arg2 == Zero))
                {
                    Return (Buffer (One) {0x03})
                }

                Return (Package (0x08)
                {
                    "kUSBSleepPortCurrentLimit", 0x0834,  // 2100mA
                    "kUSBSleepPowerSupply",      0x13EC,  // 5100mA
                    "kUSBWakePortCurrentLimit",  0x0834,  // 2100mA
                    "kUSBWakePowerSupply",       0x13EC   // 5100mA
                })
            }

            Method (_STA, 0, NotSerialized)  // _STA: Status
            {
                If (_OSI ("Darwin"))
                {
                    Return (0x0F)
                }
                Else
                {
                    Return (Zero)
                }
            }
        }
    }
}

