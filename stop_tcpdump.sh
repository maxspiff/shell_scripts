#!/bin/sh
#stop tcpdump
# by massimo iannelli
# last modified 25122016
# version 1.0

FPID=/var/tmp/tcpdump.pid



stop_tcpdump () {
        PIDPAR=$1

        echo "Stopping tcpdump.pid=$TCPDUMP_PID"
        kill "${PIDPAR}"
        sleep 1
        PSCHK=`ps -ef |grep tcpdump|grep -v grep |awk '{print $2}'`
        if [ ${PSCHK} ]
        then {
                kill -9 "${PID_PAR}"
        } else {
                echo "tcpdump stopped!"
                rm $FPID
        }
    fi
}

check_tcpdump () {

        echo "in check tcpdump"
        if [ -e ${FPID} ]
        then {
                echo "in if file with pid found"
                TCPDUMP_PID=`cat ${FPID}`
                echo "pid from file=$TCPDUMP_PID"
                if [ -e /proc/${TCPDUMP_PID} ] && [ ${TCPDUMP_PID} ]
                then {
                        echo "found proc pid tcpdump running with pid=${TCPDUMP_PID} stopping it"
                        kill -9 "${TCPDUMP_PID}"
                        sleep 1
                        echo "checking for more processes in memory"
                        PSCHK=`ps -ef |grep tcpdump|grep -v grep |awk '{print $2}'`
                        if  [ ${PSCHK} ]
                        then {
                          echo "found pid with ps=$PSCHK"
                          stop_tcpdump "${PSCHK}" 
                        } else {
                          echo "no more processes in memory, removing pid file"
                          rm "${FPID}"
                        } fi
                } else {
                  echo "in file pid else no proc processes found"
                  PSCHK=`ps -ef |grep tcpdump|grep -v grep |awk '{print $2}'`
                  if  [ ${PSCHK} ]
                  then {
                    echo "found pid with ps=$PSCHK"
                    stop_tcpdump "${PSCHK}" 
                  } else {
                    echo "no more processes in memory, removing pid file"
                    rm "${FPID}"
                  } fi
                } fi

        } else {
                echo "in else no pid "
                echo "file with pid not found searching running processes"
                PSCHK1=`ps -ef |grep tcpdump|grep -v grep |awk '{print $2}'|head -1`
                if [ $PSCHK1 ]
                then {
                        echo "res ps =$PSCHK1"
                        kill $PSCHK1
                } else {
                  echo "nothing to do"
                }
                fi
        }
        fi
}

check_tcpdump