/*
 * Intel ACPI Name Space Architecture for Lenovo IdeaPad S145-14iWL
 *
 * NOTES:
 * Adding needed polling information to Device (I2C0) so that ELAN touchpad can be detected successfully.
 *
 * KEXT REFERENCES:
 * VoodooI2C.kext / VoodooI2CELAN.kext
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

DefinitionBlock ("SSDT-I2C0.aml", "SSDT", 2, "OC", "_I2C0", 0x00000000)
{
    External (SSH0, FieldUnitObj)
    External (SSL0, FieldUnitObj)
    External (SSD0, FieldUnitObj)
    External (FMH0, FieldUnitObj)
    External (FML0, FieldUnitObj)
    External (FMD0, FieldUnitObj)

    External (_SB_.PCI0.I2C0, DeviceObj)

    Scope (\_SB.PCI0.I2C0)  // Intel Serial I/O I2C Host Controller
    {
        Method (SSCN, 0, NotSerialized)
        {
            Return (Package (0x03) {SSH0, SSL0, SSD0})
        }

        Method (FMCN, 0, NotSerialized)
        {
            Return (Package (0x03) {FMH0, FML0, FMD0})
        }
    }
}

