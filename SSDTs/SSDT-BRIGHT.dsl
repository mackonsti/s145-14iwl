/*
 * Intel ACPI Name Space Architecture for Lenovo IdeaPad S145-14iWL
 *
 * NOTES:
 * Adding brightness control keyboard shortcuts to the correct Device (EC) Methods, matching F11/F12 on keyboard.
 *
 * WARNING:
 * Catalina requires original Device (EC0) to be renamed as Device (EC) via Clover hot-patching and is respected in the code below.
 * In the event where the keyboard shortcuts do not work, delete ~/Library/Preferences/com.apple.symbolichotkeys.plist and reboot.
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

DefinitionBlock ("SSDT-BRIGHT.aml", "SSDT", 2, "OC", "_BRIGHT", 0x00000000)
{
    External (_SB_.PCI0.LPCB.EC, DeviceObj)
    External (_SB_.PCI0.LPCB.EC.XQ11, MethodObj)
    External (_SB_.PCI0.LPCB.EC.XQ12, MethodObj)
    External (_SB_.PCI0.LPCB.PS2K, DeviceObj)

    Scope (\_SB.PCI0.LPCB.EC)
    {
        Method (_Q11, 0, NotSerialized)  // _Qxx: EC Query, xx=0x00-0xFF
        {
            If (_OSI ("Darwin"))
            {
                Notify (\_SB.PCI0.LPCB.PS2K, 0x0405)  // Brightness Down
            }
            Else
            {
                \_SB.PCI0.LPCB.EC.XQ11()
            }
        }

        Method (_Q12, 0, NotSerialized)  // _Qxx: EC Query, xx=0x00-0xFF
        {
            If (_OSI ("Darwin"))
            {
                Notify (\_SB.PCI0.LPCB.PS2K, 0x0406)  // Brightness Up
            }
            Else
            {
                \_SB.PCI0.LPCB.EC.XQ12()
            }
        }
    }
}

