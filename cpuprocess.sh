#!/bin/bash


SLACK_WEBHOOK_URL=https://hooks.slack.com/services/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
send_notification() {
  local color='good'
  if [ $1 == 'ERROR' ]; then
    color='danger'
  elif [ $1 == 'WARN' ]; then
    color = 'warning'
  fi
  local message="payload={\"channel\": \"#$SLACK_CHANNEL\",\"attachments\":[{\"pretext\":\"$2\",\"text\":\"$3\",\"color\":\"$color\"}]}"

  curl -X POST --data-urlencode "$message" ${SLACK_WEBHOOK_URL}
}



prevstat=0 ###does not check

cpuusage() {
	
	threshold=80
	cpuusage=$(mpstat 5 1 | grep -i average| awk '{print 100-$12}') ### This gives an average 5 second usage od cpu
	cpui=${cpuusage%.*}
#	prevstat=1	

Filered=/var/www/MigrationScripts/testscripts/flagred.txt
Filegreen=/var/www/MigrationScripts/testscripts/flaggreen.txt

if [ $cpui -ge $threshold ]
 then
    echo "Hello, Brother"
    if [ -f "$Filered" ]
     then
        echo "No alert flag exist"
     else
        send_notification "ERROR" "WARNING STATUS" "$cpui is the load of your cpu"
        echo "creating flag"
        touch $Filered
        rm $Filegreen
    fi

fi
cpuw=$(mpstat 5 1 |grep -i average| awk '{print 100-$12}')
cpui=${cpuw%.*}

if [ $cpui -lt $threshold ]
 then
    if [ -f "$Filegreen" ]
     then
        echo "No alert flag exist"
#	send_notification "ERROR" "welcome STATUS" "$cpui idsadsasadsas now the loadyour cpu"
     else
        send_notification "good" "welcome STATUS" "$cpui is now the loadyour cpu"
	echo "creating flag"
        touch $Filegreen
        rm $Filered
    fi
 fi

cpuw=$(mpstat 5 1 |grep -i average| awk '{print 100-$12}')
cpui=${cpuw%.*}
a=0


}


cpuusage
