/*
 * This SSDT adds Device (PNLF) for use by WhateverGreen.kext and macOS.
 * NOTE: Original existing Device (GFX0) will be later renamed to (IGPU) by WhateverGreen.kext.
 *
 * Guide: https://dortania.github.io/Getting-Started-With-ACPI/Laptops/backlight.html
 * Source: https://github.com/acidanthera/OpenCorePkg/blob/master/Docs/AcpiSamples/Source/SSDT-PNLF.dsl
 *
 * This is a modified PNLF version originally taken from RehabMan's repository:
 * https://github.com/RehabMan/OS-X-Clover-Laptop-Config/blob/master/hotpatch/SSDT-PNLF.dsl
 * Licensed under GNU General Public License v2.0:
 * https://github.com/RehabMan/OS-X-Clover-Laptop-Config/blob/master/License.md
 */

#define FBTYPE_SANDYIVY     0x01
#define FBTYPE_HSWPLUS      0x02
#define FBTYPE_CFL          0x03

#define SANDYIVY_PWMMAX     0x0710
#define HASWELL_PWMMAX      0x0AD9
#define SKYLAKE_PWMMAX      0x056C
#define CUSTOM_PWMMAX_07A1  0x07A1
#define CUSTOM_PWMMAX_1499  0x1499
#define COFFEELAKE_PWMMAX   0xFFFF

DefinitionBlock ("SSDT-PNLF.aml", "SSDT", 2, "OC", "_PNLF", 0x00000000)
{
    External (RMCF.BKLT, IntObj)
    External (RMCF.FBTP, IntObj)
    External (RMCF.GRAN, IntObj)
    External (RMCF.LEVW, IntObj)
    External (RMCF.LMAX, IntObj)
    External (_SB_.PCI0.GFX0, DeviceObj)

    If (_OSI ("Darwin"))
    {
        Scope (\_SB.PCI0.GFX0)
        {
            OperationRegion (RMP3, PCI_Config, Zero, 0x14)

            Device (PNLF)
            {
                Name (_HID, EisaId("APP0002"))  // _HID: Hardware ID
                Name (_CID, "backlight")  // _CID: Compatible ID
                Name (_STA, 0x0B)  // _STA: Status
                Name (_UID, 0x00)  // _UID: Unique ID

                // Note: This _UID value depends on PWMMax for different Intel CPU architectures
                // However, it should match profiles found in WhateverGreen.kext here:
                // https://github.com/acidanthera/WhateverGreen/blob/1.5.5/WhateverGreen/kern_weg.cpp#L34
                //
                //   0x0E: Sandy/Ivy          0x0710
                //   0x0F: Haswell/Broadwell  0x0ad9
                //   0x10: Skylake/KabyLake   0x056c
                //   0x11: Custom LMAX        0x07a1
                //   0x12: Custom LMAX        0x1499
                //   0x13: CoffeeLake         0xffff
                //   0x63: Other              Requires custom profile

                Field (^RMP3, AnyAcc, NoLock, Preserve)
                {
                    Offset (0x02),
                    GDID,   16,
                    Offset (0x10),
                    BAR1,   32
                }

                // IGPU PWM Backlight Register description:
                //   LEV2 not currently used
                //   LEVL level of backlight in Sandy/Ivy Bridge
                //   P0BL counter; when zero is vertical blank
                //   GRAN see description below in INI1 method
                //   LEVW should be initialized to 0xC0000000
                //   LEVX is PWMMax except FBTYPE_HSWPLUS combo of max/level (Sandy/Ivy Bridge stored in MSW)
                //   LEVD level of backlight for CoffeeLake
                //   PCHL not currently used

                OperationRegion (RMB1, SystemMemory, BAR1 & ~0xF, 0xE1184)
                Field (RMB1, AnyAcc, Lock, Preserve)
                {
                    Offset (0x48250),
                    LEV2,   32,
                    LEVL,   32,
                    Offset (0x70040),
                    P0BL,   32,
                    Offset (0xC2000),
                    GRAN,   32,
                    Offset (0xC8250),
                    LEVW,   32,
                    LEVX,   32,
                    LEVD,   32,
                    Offset (0xE1180),
                    PCHL,   32
                }

                // Intel Open Source HD Graphics, Intel Iris Graphics, and Intel Iris Pro Graphics
                // Programmer's Reference Manual
                // For the 2015-2016 Intel Core Processors, Celeron Processors and Pentium Processors based on the "Skylake" Platform
                // Volume 12: Display (May 2016, Revision 1.0)
                //
                // Source: https://01.org/sites/default/files/documentation/intel-gfx-prm-osrc-skl-vol12-display.pdf

                Method (INI1, 1, NotSerialized)  // Common code used by FBTYPE_HSWPLUS and FBTYPE_CFL platforms
                {
                    // Page 189: Backlight Enabling Sequence
                    // Description:
                    //   1. Set frequency and duty cycle in SBLC_PWM_CTL2 Backlight Modulation Frequency and Backlight Duty Cycle
                    //   2. Set granularity in 0xC2000 bit 0 (0=16, 1=128)
                    //   3. Enable PWM output and set polarity in SBLC_PWM_CTL1 PWM PCH Enable and Backlight Polarity
                    //   4. Change duty cycle as needed in SBLC_PWM_CTL2 Backlight Duty Cycle
                    //
                    // This 0xC value comes from looking at how macOS initializes this register
                    // after display sleep (using ACPIDebug / ACPIPoller)

                    If ((0x00 == (0x02 & Arg0)))
                    {
                        Local5 = 0xC0000000
                        If (CondRefOf (\RMCF.LEVW)) { If ((Ones != \RMCF.LEVW)) { Local5 = \RMCF.LEVW } }
                        ^LEVW = Local5
                    }
                    If ((0x04 & Arg0))
                    {
                        If (CondRefOf (\RMCF.GRAN)) { ^GRAN = \RMCF.GRAN }
                        Else { ^GRAN = Zero }
                    }
                }

                Method (_INI, 0, NotSerialized)  // _INI: Initialize
                {
                    Local4 = One
                    If (CondRefOf (\RMCF.BKLT)) { Local4 = \RMCF.BKLT }
                    If (!(One & Local4)) { Return (Zero) }

                    // Adjustment required when using WhateverGreen.kext
                    Local0 = ^GDID
                    Local2 = Ones
                    If (CondRefOf (\RMCF.LMAX)) { Local2 = \RMCF.LMAX }

                    // Determine framebuffer type (for PWM register layout)
                    Local3 = Zero
                    If (CondRefOf (\RMCF.FBTP)) { Local3 = \RMCF.FBTP }

                    // Now fix the backlight PWM depending on the framebuffer type
                    // At this point:
                    //   Local4 is RMCF.BLKT value, if specified (default is 1)
                    //   Local0 is the device-id for IGPU
                    //   Local2 is LMAX, if specified (Ones means it is based on device-id)
                    //   Local3 is the framebuffer type

                    // First, check for Sandy/Ivy Bridge
                    If (((FBTYPE_SANDYIVY == Local3) || (Ones != Match (Package (0x10)
                    {
                        // Arrandale
                        0x0042,
                        0x0046,
                        // Sandy Bridge
                        0x0102,
                        0x0106,
                        0x010B,
                        0x0112,
                        0x0116,
                        0x0122,
                        0x0126,
                        0x1106,
                        0x1601,
                        // Ivy Bridge
                        0x0152,
                        0x0156,
                        0x0162,
                        0x0166,
                        0x016A
                    }, MEQ, Local0, MTR, Zero, Zero))))
                    {
                        If ((Ones == Local2)) { Local2 = SANDYIVY_PWMMAX }
                        // Change/scale only if different than current...
                        Local1 = (^LEVX >> 0x10)

                        If (!Local1) { Local1 = Local2 }
                        If ((!(0x08 & Local4) && (Local2 != Local1)))
                        {
                            // Set new backlight PWMMax but retain current backlight level by scaling
                            Local0 = ((^LEVL * Local2) / Local1)
                            Local3 = (Local2 << 0x10)

                            If ((Local2 > Local1))
                            {
                                // PWMMax is getting larger... store new PWMMax first
                                ^LEVX = Local3
                                ^LEVL = Local0
                            }
                            Else
                            {
                                // Otherwise store new brightness level, followed by new PWMMax
                                ^LEVL = Local0
                                ^LEVX = Local3
                            }
                        }
                    }

                    // Check Coffee/Whiskey/Comet/IceLake
                    ElseIf (((FBTYPE_CFL == Local3) || (Ones != Match (Package (0x19)
                    {
                        // CoffeeLake and WhiskeyLake
                        0x3E91,
                        0x3E92,
                        0x3E98,
                        0x3E9B,
                        0x3EA0,
                        0x3EA5,
                        0x3EA6,
                        // CometLake
                        0x9B21,
                        0x9B41,
                        0x9BA4,
                        0x9BC4,
                        0x9BC5,
                        0x9BC8,
                        0x9BCA,
                        // IceLake
                        0x8A51,
                        0x8A52,
                        0x8A53,
                        0x8A56,
                        0x8A5A,
                        0x8A5B,
                        0x8A5C,
                        0x8A5D,
                        0x8A70,
                        0x8A71,
                        0xFF05
                    }, MEQ, Local0, MTR, Zero, Zero))))
                    {
                        If ((Ones == Local2)) { Local2 = COFFEELAKE_PWMMAX }
                    }

                    // Otherwise must be Haswell/Broadwell/Skylake/KabyLake/KabyLake-R (i.e. FBTYPE_HSWPLUS)
                    Else
                    {
                        If ((Ones == Local2))
                        {
                            // Check Haswell and Broadwell as they both have same PWMMax (for most common ig-platform-id values)
                            If ((Ones != Match (Package (0x15)
                            {
                                // Haswell
                                0x0412,
                                0x0416,
                                0X041A,
                                0x041E,
                                0x0A16,
                                0x0A1E,
                                0x0A26,
                                0x0A2E,
                                0x0D22,
                                0x0D26,
                                // Broadwell
                                0x0BD1,
                                0x0BD2,
                                0x0BD3,
                                0x1606,
                                0x160E,
                                0x1612,
                                0x1616,
                                0x161E,
                                0x1622,
                                0x1626,
                                0x162B
                            }, MEQ, Local0, MTR, Zero, Zero)))
                            {
                                Local2 = HASWELL_PWMMAX
                            }
                            Else
                            {
                                // Now assume Skylake/KabyLake/KabyLake-R that have same PWMMax
                                //
                                // Skylake
                                //   0x1902,
                                //   0x1912,
                                //   0x1916,
                                //   0x1917,
                                //   0x191B,
                                //   0x191E,
                                //   0x1926,
                                //   0x1927,
                                //   0x1932,
                                //   0x193B,
                                // KabyLake
                                //   0x5912,
                                //   0x5916,
                                //   0x591B,
                                //   0x591C,
                                //   0x591E,
                                //   0x5923,
                                //   0x5926,
                                //   0x5927
                                Local2 = SKYLAKE_PWMMAX
                            }
                        }

                        INI1 (Local4)
                        // Change/scale only if different than current...
                        Local1 = (^LEVX >> 0x10)

                        If (!Local1) { Local1 = Local2 }
                        If ((!(0x08 & Local4) && (Local2 != Local1)))
                        {
                            // Set new backlight PWMMax but retain current backlight level by scaling
                            Local0 = ((((^LEVX & 0xFFFF) * Local2) / Local1) | (Local2 << 0x10))
                            ^LEVX = Local0
                        }
                    }

                    // Now that Local2 is the new PWMMax we set _UID accordingly
                    // The _UID selects the correct entry in WhateverGreen.kext

                        If ((Local2 == SANDYIVY_PWMMAX))    { _UID = 0x0E }
                    ElseIf ((Local2 == HASWELL_PWMMAX))     { _UID = 0x0F }
                    ElseIf ((Local2 == SKYLAKE_PWMMAX))     { _UID = 0x10 }
                    ElseIf ((Local2 == CUSTOM_PWMMAX_07A1)) { _UID = 0x11 }
                    ElseIf ((Local2 == CUSTOM_PWMMAX_1499)) { _UID = 0x12 }
                    ElseIf ((Local2 == COFFEELAKE_PWMMAX))  { _UID = 0x13 }
                      Else                                  { _UID = 0x63 }
                }
            }
        }
    }
}

