/*
 * Starting with macOS 10.15 an Ambient Light Sensor presence is required for backlight functioning.
 * This SSDT adds a fake ambient light sensor ACPI Device (ALS0) which can be used by SMCLightSensor
 * kext to report either dummy (when no device is present) or valid values through the SMC interface.
 */

DefinitionBlock ("SSDT-ALSD.aml", "SSDT", 2, "OC", "_ALSD", 0x00000000)
{
    Scope (\_SB)
    {
        Device (ALS0)
        {
            Name (_HID, "ACPI0008")  // _HID: Hardware ID
            Name (_CID, "smc-als")  // _CID: Compatible ID
            Name (_ALI, 0x012C)  // _ALI: Ambient Light Illuminance
            Name (_ALR, Package (0x01)  // _ALR: Ambient Light Response
            {
                Package (0x02) {0x64, 0x012C}  // Value 0x012C corresponds to 300 Lux
            })
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

