#!/bin/sh

# 10tb hdd
qm set 100 -scsi1 /dev/disk/by-id/ata-WDC_WD101EFBX-68B0AN0_VH1X8LJM,serial=VH1X8LJM
qm set 100 -scsi2 /dev/disk/by-id/ata-WDC_WD101EFBX-68B0AN0_VH1XRHSM,serial=VH1XRHSM
qm set 100 -scsi3 /dev/disk/by-id/ata-WDC_WD101EFBX-68B0AN0_VH26JWLM,serial=VH26JWLM
qm set 100 -scsi4 /dev/disk/by-id/ata-WDC_WD101EFBX-68B0AN0_VH26YD8M,serial=VH26YD8M

# 4tb ssd
qm set 100 -scsi5 /dev/disk/by-id/ata-Samsung_SSD_870_EVO_4TB_S6BBNS0W109714T,serial=S6BBNS0W109714T,ssd=1
qm set 100 -scsi6 /dev/disk/by-id/ata-Samsung_SSD_870_QVO_4TB_S5STNJ0W101328K,serial=S5STNJ0W101328K,ssd=1
qm set 100 -scsi7 /dev/disk/by-id/ata-Samsung_SSD_870_EVO_4TB_S6BBNS0W109721B,serial=S6BBNS0W109721B,ssd=1
qm set 100 -scsi8 /dev/disk/by-id/ata-Samsung_SSD_870_QVO_4TB_S5STNJ0W100332Z,serial=S5STNJ0W100332Z,ssd=1

# 2tb nvme
qm set 100 -scsi9 /dev/disk/by-id/nvme-Samsung_SSD_980_PRO_2TB_S6B0NL0W406605J,serial=S6B0NL0W406605J,ssd=1

# 4tb hdd
qm set 100 -scsi10 /dev/disk/by-id/ata-WDC_WD40EZRZ-00GXCB0_WD-WCC7K1HK00TY,serial=WD-WCC7K1HK00TY
qm set 100 -scsi11 /dev/disk/by-id/ata-WDC_WD40EZRZ-00GXCB0_WD-WCC7K4CS6200,serial=WD-WCC7K4CS6200
qm set 100 -scsi12 /dev/disk/by-id/ata-WDC_WD40EZRZ-00GXCB0_WD-WCC7K5ZZD9RV,serial=WD-WCC7K5ZZD9RV
qm set 100 -scsi13 /dev/disk/by-id/ata-WDC_WD40EZRZ-00GXCB0_WD-WCC7K6HNY938,serial=WD-WCC7K6HNY938
