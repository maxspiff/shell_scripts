#!/bin/sh
# script for tcpdump
# by Massimo 23/12/2016
# version 1.0

#variables
PORTPAR=$2
IFPAR=$1
FSYS=/var/tmp
HST="`hostname`"
TCPDUMP_PID=0
TCPDUMP_PID_FILE=$FSYS/tcpdump.pid


check_intf_par () {
        if [ $IFPAR ] 
        then {
#                echo "Interface par = $IFPAR"
                INTF=`ifconfig -a |grep $IFPAR |awk '{print $1}'`
#                echo "interface par after check =$INTF"
            if [ $INTF ]
                then {
                        INTF=$IFPAR
                        echo "found interface $INTF"
                } else {
                        echo "interface $IFPAR does not exist Exiting"
                        exit
                }
                fi
        } else {
                echo "Missing interface parameter exiting"
                exit
        }
        fi
}

check_port () {
        NPORT=`netstat -an |grep LISTEN |grep -v LISTENING|grep ${PORTPAR} |wc -l`

#       echo "in check port PORTPAR=$NPORT"
        if [ $NPORT -eq 0 ]
        then {
                echo "Port $PRT is not listening exiting"
                exit
        }
        fi
}

check_port_par () {
        if [ $PORTPAR ] 
        then {
                PRT=$PORTPAR
                check_port
        } else {
                LOG_FILE="$FSYS/tcpdump_INTF_`date +%d%m%y`.pcap"
                PRT=0
        }
        fi
}


check_fs () {
        RESFS=$(df -h $FSYS |tail -1|awk '{print $5}'|tr -d %)
        echo "in check_fs par=$RESFS"
        if [ $RESFS -gt 85 ] 
        then {
                echo "File system $FSYS is $RESFS% tcpdump will not start"
                exit
        } 
        fi
}



start_tcp () {
        echo "in start tcp"
        if [ $PRT -eq 0 ] 
        then {
                FNAME="${FSYS}/${HST}_tcpdump_${INTF}_`date +%d%m%y_%H%M`.pcap"
                echo "Starting tcpdump on interface ${INTF}, File system ${FSYS} is ${RESFS}%"
                2>/dev/null 1>&2 tcpdump -i ${INTF} -s0 -C 100 -w "$FNAME" &
                TCPDUMP_PID=$!
                echo "file created : $FNAME with PID=${TCPDUMP_PID}"
                echo "$TCPDUMP_PID">$TCPDUMP_PID_FILE

        } else {
                echo "in else start_tcp"
                FNAME="${FSYS}/${HST}_tcpdump_${INTF}_port_${PRT}_`date +%d%m%y_%H%M`.pcap"
                echo "file name to be created $FNAME"
                echo "Starting tcpdump on  port $PRT  and interface $INTF. File system $FSYS is $RESFS%"
                2>/dev/null 1>&2 tcpdump -i $INTF -s0 -vv -C 100 -w "$FNAME" &   
                #TCPDUMP_PID=$!
                TCPDUMP_PID=`ps -ef |grep tcpdump|grep -v grep |awk '{print $2}'`
                echo "pid=$TCPDUMP_PID"
                if [ ${TCPDUMP_PID} ] 
                then {

                        echo "file created : $FNAME with PID=${TCPDUMP_PID}"
                        echo "${TCPDUMP_PID}">${TCPDUMP_PID_FILE}
                } else {
                        echo "something went wrong pid does not exist"
                }
                fi

        }
        fi
}





#main

check_intf_par
check_port_par
check_fs
start_tcp