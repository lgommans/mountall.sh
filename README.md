## mountall.sh

A little script to mount all partitions from a disk image

**Usage**

    ./mountall.sh my_disk_image.img

Attempts to mount all partitions from the disk in subdirectories,
mounting them as read-only.


**What does it do?**

Say `fdisk -l sdb.img` would give me this output:

    Disk sdb.img: 7.4 GiB, 7948206080 bytes, 15523840 sectors
	Units: sectors of 1 * 512 = 512 bytes
	Sector size (logical/physical): 512 bytes / 512 bytes
	I/O size (minimum/optimal): 512 bytes / 512 bytes
	Disklabel type: dos
	Disk identifier: 0x00000000

	Device    Boot Start      End  Sectors  Size Id Type
	sdb.img1        8192 15523839 15515648  7.4G  b W95 FAT32

Then what `mountall.sh` does is find the sector size (512 bytes), create a
directory called `mnt-sdb.img1`, setup a loop device with the offset `8192*512`,
and mount that loop device in the created directory.

You can then `cd` into the new directory to read the files on that partition.

To mount the partition as read-write, remove the `-o ro` flag from the `mount`
command near the bottom of the script.


**To do**

- Detect whether fdisk and other requirements are installed

- Test with older versions of fdisk (an older Kali machine didn't seem to have
  color output by default, it might die on that --color=never option)

- Add options (e.g. mounting not read-only)
