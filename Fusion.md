# Using SATA SDD in VMware

Instead of dual-booting that was not working well for some reason, as the Lenovo BIOS kept switching to the Windows EFI partition each time NVRAM parameters were cleared via OpenCore, it was decided to try installing Windows on that SATA SSD via VMware Fusion instead, thus keeping only one bootable disk (the NVMe one) for the main OS via OpenCore, in this case Big Sur.

To allow an existing virtual machine in VMware Fusion to accept the physical SATA disk as a target, the [following article/guide](https://kb.vmware.com/s/article/2097401) was used.

Open **Terminal.app** on the Mac and check the disk partitions:

```
~% diskutil list
```

The output should be something like this:

```
/dev/disk0 (internal, physical):
   #:                       TYPE NAME                     SIZE       IDENTIFIER
   0:      GUID_partition_scheme                         *512.1 GB   disk0
   1:                        EFI EFI                      209.7 MB   disk0s1
   2:                 Apple_APFS Container disk1          511.9 GB   disk0s2

/dev/disk1 (synthesized):
   #:                       TYPE NAME                     SIZE       IDENTIFIER
   0:      APFS Container Scheme -                       +511.9 GB   disk1
                                 Physical Store disk0s2
   1:                APFS Volume Big Sur - Data           5.9 GB     disk1s1
   2:                APFS Volume Preboot                  283.8 MB   disk1s2
   3:                APFS Volume Recovery                 619.2 MB   disk1s3
   4:                APFS Volume VM                       1.1 MB     disk1s4
   5:                APFS Volume Intel NVMe               15.3 GB    disk1s5
   6:              APFS Snapshot com.apple.os.update...   15.3 GB    disk1s5s1

/dev/disk2 (internal, physical):
   #:                       TYPE NAME                     SIZE       IDENTIFIER
   0:     FDisk_partition_scheme                         *240.1 GB   disk2
   1:               Windows_NTFS                          240.1 GB   disk2s1
```

**Note:** When erasing both NVMe and SATA SSDs via PartedMagic, an MBR partition was created on the SATA disk, formatted with NTFS as a single partition, hence the result of `diskutil list` above.

Next, we select the physical disk that should be used in WMware Fusion and list the partitions recognized by `rawdiskCreator` via this Terminal command:

```
/Applications/VMware\ Fusion.app/Contents/Library/vmware-rawdiskCreator print /dev/disk#
```

The parameter `disk#` should be one of the disk identifiers shown by `diskutil list` earlier, so in the case above with `disk2` being used (and with only one partition) the output should be like this:

```
~% /Applications/VMware\ Fusion.app/Contents/Library/vmware-rawdiskCreator print /dev/disk2

Nr      Start       Size Type Id Sytem
-- ---------- ---------- ---- -- ------------------------
 1       2048  468858880 BIOS  7 HPFS/NTFS
```

The next step would be to crete a `vmdk` file referencing the physical disk and save it _inside_ the virtual machine bundle via this Terminal command:

```
/Applications/VMware\ Fusion.app/Contents/Library/vmware-rawdiskCreator create /dev/disk# <partNums> <virtDiskPath> ide
```

* `disk#` is the physical disk selected;
* `<partNums>` can be a comma-separated list of partitions to allow access to e.g. "2" or "2,3". The numbers should **match the output** of the `rawdiskCreator` command run earlier. Otherwise, to access the full disk, specify "fullDevice" instead of partition numbers;
* `<virtDiskPath>` should be a path inside the virtual machine bundle followed by a filename prefix such as `~/Documents/AnyVirtualMachineName.vmwarevm/rawDiskFile`

With the physical disk identifier `disk2` and Virtual Machine location `Windows 10 (x64).vmwarevm` known, we are ready to bind it:

```
cd ~/Documents/Virtual\ Machines.localized/Windows\ 10\ \(x64\).vmwarevm

/Applications/VMware\ Fusion.app/Contents/Library/vmware-rawdiskCreator create /dev/disk2 fullDevice ~/Virtual\ Machines.localized/Windows\ 10\ x64.vmwarevm/rawDiskFile ide
```

This command should create `rawDiskFile.vmdk` and `rawDiskFile-pt.vmdk` for partitioned disks, in case there was such a parameter earlier.

Finally, we just need to edit the virtual machine configuration (.vmx) file of the virtual machine itself and add the following lines:

```
sata0:0.present = "TRUE"
sata0:0.fileName = "rawDiskFile.vmdk"
sata0:0.deviceType = "rawDisk"
suspend.disabled = "TRUE"
```

Be sure to check that there are no other lines using `sata0:0` in the virtual machine configuration!

Once the configuration is saved, run VMware Fusion and check the **Settings** of the virtual machine to confirm the drive `sata` is present in the Hard Disk section. The virtual machine is now ready to install Windows on the physical disk itself.

Final Notes (per VMware's article):

* If the virtual machine already has a disk at `sata0:0` we can use another port such as `sata0:1`, `sata:0` or `sata:1` while being careful at the same time to not create a conflict with CD-ROM drive that is usually assigned as`sata0:1`;
* It is also possible to use `scsi#:#` or `ide#:#` entries if the virtual machine has a SCSI or IDE controller, instead of a SATA controller;
* The following entry `suspend.disabled = "TRUE"` is necessary to prevent the virtual machine from suspending and getting out of sync with the physical disk;
* The virtual machine requires the partitions (or full disk) to be **unmounted** before the virtual machine can be powered on.

## Example Configuration File

The following configuration is an example of a successful use of the SATA drive (with the method above) by the Windows 10 virtual machine; note the two connected `sata` drives (CD-ROM and HDD):

```
.encoding = "UTF-8"
annotation = "Windows 10 (x64)"
bios.bootOrder = "CDROM"
bios.hddOrder = "sata0:0"
cleanShutdown = "TRUE"
config.version = "8"
cpuid.coresPerSocket = "4"
displayName = "Windows 10 (x64)"
ehci.pciSlotNumber = "34"
ehci.present = "TRUE"
ethernet0.addressType = "generated"
ethernet0.connectionType = "nat"
ethernet0.generatedAddress = "0a:0b:0c:0d:0e:0f"
ethernet0.generatedAddressOffset = "0"
ethernet0.linkStatePropagation.enable = "TRUE"
ethernet0.pciSlotNumber = "160"
ethernet0.present = "TRUE"
ethernet0.virtualDev = "e1000e"
extendedConfigFile = "Windows 10 (x64).vmxf"
floppy0.present = "FALSE"
guestOS = "windows9-64"
gui.fitGuestUsingNativeDisplayResolution = "TRUE"
hpet0.present = "TRUE"
mem.hotadd = "TRUE"
memsize = "8192"
mks.enable3d = "TRUE"
monitor.phys_bits_used = "45"
numvcpus = "4"
nvme0.pciSlotNumber = "-1"
nvme0.present = "FALSE"
nvram = "Windows 10 (x64).nvram"
pciBridge0.pciSlotNumber = "17"
pciBridge0.present = "TRUE"
pciBridge4.functions = "8"
pciBridge4.pciSlotNumber = "21"
pciBridge4.present = "TRUE"
pciBridge4.virtualDev = "pcieRootPort"
pciBridge5.functions = "8"
pciBridge5.pciSlotNumber = "22"
pciBridge5.present = "TRUE"
pciBridge5.virtualDev = "pcieRootPort"
pciBridge6.functions = "8"
pciBridge6.pciSlotNumber = "23"
pciBridge6.present = "TRUE"
pciBridge6.virtualDev = "pcieRootPort"
powerType.powerOff = "soft"
powerType.powerOn = "soft"
powerType.reset = "soft"
powerType.suspend = "soft"
proxyApps.publishToHost = "FALSE"
sata0.pciSlotNumber = "36"
sata0.present = "TRUE"
sata0:0.deviceType = "rawDisk"
sata0:0.fileName = "rawDiskFile.vmdk"
sata0:0.present = "TRUE"
sata0:1.autodetect = "TRUE"
sata0:1.deviceType = "cdrom-raw"
sata0:1.fileName = "auto detect"
sata0:1.present = "TRUE"
sata0:1.startConnected = "FALSE"
sensor.location = "pass-through"
serial0.fileName = "thinprint"
serial0.fileType = "thinprint"
serial0.present = "TRUE"
serial0.startConnected = "FALSE"
softPowerOff = "TRUE"
sound.autoDetect = "TRUE"
sound.fileName = "-1"
sound.pciSlotNumber = "33"
sound.present = "TRUE"
sound.virtualDev = "hdaudio"
suspend.disabled = "TRUE"
svga.graphicsMemoryKB = "8388608"
svga.guestBackedPrimaryAware = "TRUE"
svga.vramSize = "268435456"
tools.remindInstall = "FALSE"
tools.syncTime = "TRUE"
tools.upgrade.policy = "upgradeAtPowerCycle"
toolsInstallManager.lastInstallError = "0"
toolsInstallManager.updateCounter = "1"
usb.pciSlotNumber = "32"
usb.present = "TRUE"
usb:1.deviceType = "hub"
usb:1.parent = "-1"
usb:1.port = "1"
usb:1.present = "TRUE"
usb:1.speed = "2"
usb_xhci.pciSlotNumber = "192"
usb_xhci.present = "TRUE"
usb_xhci:4.deviceType = "hid"
usb_xhci:4.parent = "-1"
usb_xhci:4.port = "4"
usb_xhci:4.present = "TRUE"
vhv.enable = "TRUE"
virtualHW.productCompatibility = "hosted"
virtualHW.version = "18"
vmci0.id = "-374501799"
vmci0.pciSlotNumber = "35"
vmci0.present = "TRUE"
vmotion.checkpointFBSize = "4194304"
vmotion.checkpointSVGAPrimarySize = "268435456"
vmotion.svga.baseCapsLevel = "9"
vmotion.svga.bc67 = "9"
vmotion.svga.dxMaxConstantBuffers = "15"
vmotion.svga.dxProvokingVertex = "0"
vmotion.svga.graphicsMemoryKB = "8388608"
vmotion.svga.lineStipple = "0"
vmotion.svga.logicBlendOps = "0"
vmotion.svga.logicOps = "1"
vmotion.svga.maxPointSize = "189"
vmotion.svga.maxTextureAnisotropy = "16"
vmotion.svga.maxTextureSize = "16384"
vmotion.svga.maxVolumeExtent = "2048"
vmotion.svga.mobMaxSize = "1073741824"
vmotion.svga.msFullQuality = "1"
vmotion.svga.multisample2x = "1"
vmotion.svga.multisample4x = "1"
vmotion.svga.multisample8x = "1"
vmotion.svga.sm41 = "1"
vmotion.svga.sm5 = "1"
vmotion.svga.supports3D = "1"
```

N.B. The keys for this configuration were sorted alphabetically for easier visual reference.
