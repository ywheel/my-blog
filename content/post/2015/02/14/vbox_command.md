---
categories:
- 技术文章
date: 2015-02-14T15:59:44+08:00
description: ""
keywords:
- xxx
title: vbox command
url: ""
---

## Controlling the VirtualBox VM
Nowthat we have VirtualBox installed and a VM guest created we need to control andmodify the VM

## How to List VM information
### How to show the VirtualBox VM info

```shell
vmadmin$VBoxManage showvminfo <vmname>
```

### How to show the VM Harddrive info

```shell
vmadmin$VBoxManage showhdinfo <filename>
```

### How to list running VM

```shell
vmadmin$VBoxManage list runningvms
```

### How to list available VM

```shell
vmadmin$VBoxManage list vms
```

### How to list available VM Harddrives

```shell
vmadmin$VBoxManage list hdds
```

### How to list available ISO’s

```shell
vmadmin$VBoxManage list dvds
```

## How to Control VM
### How to Start VM

nohupand & to place process in background, so VM continues to run after closingconsole.

```shell
vmadmin$nohup VBoxHeadless –startvm <vmname> &
```

### How to pause VM

```shell
vmadmin$VBoxManage controlvm <vmname> pause
```

### How to resume VM

```shell
vmadmin$VBoxManage controlvm <vmname> resume
```

### How to reset VM

```shell
vmadmin$VBoxManage controlvm <vmname> reset
```

### How to poweroff VM (hard poweroff eg. pull the plug)

```shell
vmadmin$VBoxManage controlvm <vmname> poweroff
```

### How to send poweroff single to VM (tells VM OS to shutdown)

```shell
vmadmin$VBoxManage controlvm <vmname> acpipowerbutton
```

### How to attach a DVD / CD to a running vm

```shell
vmadmin$VBoxManage controlvm <vmname> dvdattach <filename>
```

### How to de-attach a DVD / CD from a running vm

```shell
vmadmin$VBoxManage controlvm <vmname> dvdattach none
```