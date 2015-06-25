#!/bin/sh
#Finding cpuinfo
echo $'\t=== CPU ==='
SplitString=$(cat /proc/cpuinfo | egrep "(model name|cpu cores|cpu MHz)")
IFS=$'\n' read -d '' -r -a CPU <<<"$SplitString"
echo "${CPU[0]}"
echo "${CPU[1]}"
echo "${CPU[2]}"
echo $'\t=== CPU ==='
#end finding cpuinfo

#Finding meminfo
#dmidecode | perl -e 'undef $/; for ( split /(?<=\n)\n+/, <> ) { print if /RAM socket|Memory Device/ && !/(Not|No Module) Installed/ }'
echo $'\t === Memory'
SplitString=$(dmidecode -t 17 | egrep "(Handle |Size)" | awk '{print $2}')
IFS=$'\n' read -d '' -r -a Mem <<< "$SplitString"
sum=0
for ((idx=0;idx<"${#Mem[@]}";idx+=2))
do
    for ((ide=idx+2;ide<"${#Mem[@]}";ide+=2))
    do
	a="${Mem[idx]}"
	b="${Mem[ide]}"
	if [ "$a" = "$b" ]
	then
	    Mem[ide+1]=0
	fi
    done
done
for ((idx=0;idx<"${#Mem[@]}";idx+=2))
do
    ((sum+="${Mem[idx+1]}"))
done
echo "$sum MB"
echo $'\t === Memory'
#end finding meminfo

#Finding harddrives
echo $'\t=== HDD ==='
SplitString=$(lsblk -l | grep disk)
IFS=$'\n' read -d '' -r -a Drives <<< "$SplitString"
declare -a DriveNames
echo "Found $((${#Drives[@]}-1)) drives"
for Drive in "${Drives[@]}"
do
    IFS=' ' read -a DriveNames <<<"$Drive"
    smartctl -i -H "/dev/${DriveNames[0]}" | egrep "(==|Model Family|Device Model|Serial Number|Firmware Version|User Capacity|Rotation Rate|ATA|SATA|SMART)"
done
echo $'\t=== HDD ==='
#end finding harddrives