/*
 * This SSDT adds Device (PNLF) for use by WhateverGreen.kext and macOS.
 * Moreover, a fake ambient light sensor Device (ALS0) is added, as it does not exist.
 * The ACPI code below is specific to the Coffee Lake platform and newer.
 *
 * NOTE: Original Device (GFX0) will be renamed to (IGPU) by WhateverGreen.kext.
 * Source: https://github.com/dortania/Getting-Started-With-ACPI/blob/master/extra-files/decompiled/SSDT-PNLF-CFL.dsl
 */

DefinitionBlock ("SSDT-PNLF.aml", "SSDT", 2, "Clover", "PNLF", 0x00000000)
{
    Scope (\_SB)
    {
        Device (PNLF)
        {
            Name (_HID, EisaId ("APP0002"))  // _HID: Hardware ID
            Name (_CID, "backlight")  // _CID: Compatible ID
            Name (_UID, 0x13)  // _UID value depends on PWMMax for different Intel CPU architectures
            Method (_STA, 0, NotSerialized)  // _STA: Status
            {
                If (_OSI ("Darwin"))
                {
                    Return (0x0B)
                }
                Else
                {
                    Return (Zero)
                }
            }
        }

        Device (ALS0)
        {
            Name (_HID, "ACPI0008" /* Ambient Light Sensor Device */)  // _HID: Hardware ID
            Name (_CID, "smc-als")  // _CID: Compatible ID
            Name (_ALI, 0x012C)  // _ALI: Ambient Light Illuminance
            Name (_ALR, Package (0x01)  // _ALR: Ambient Light Response
            {
                Package (0x02) {0x64, 0x012C}  // Value 0x012C is 300 Lux
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

