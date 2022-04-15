#!/bin/bash


CTIME=$(date +%d-%m-%Y-%H:%M-%S)
process() {

#mpstat ### CPU PROCESS


	cpu_idle=$(top -b -n 1 | grep Cpu | awk '{print $8}'|cut -f 1 -d ".")
	cpu_use=$(expr 100 - $cpu_idle)
	echo "cpu utilization: $cpu_use %"


	free -t | awk 'NR == 2 {printf("Current Memory Utilization is : %.2f%\n"), $3/$2*100}' #### Memory Utilization
	ramusage=$(free -t | awk 'NR == 2 {printf("Current Memory Utilization is : %.2f%\n"), $3/$2*100}')
	Available=$(df -P / | awk '/%/ {print 100 -$5}')
	Availableperc=$(df -P / | awk '/%/ {print 100 -$5 "%"}')
	UsedDisk=$(expr 100 - $Available)
	echo "Disk usage Available:$Availableperc Used:$UsedDisk %"

	curl ifconfig.me
	PubIp=$(curl ifconfig.me)
#serverip=$(curl ifconfig.me)

	cachehit=$(varnishstat -1 | grep "cache_hit " |awk '{print $2}') #### dont forget to start varnishd.
	cachemiss=$(varnishstat -1 | grep "cache_miss" |awk '{print $2}')

	totalcache=$(expr $cachehit + $cachemiss)

	echo "( $cachehit / $totalcache )" | bc -l 

#totalhit=( $cachehit / $totalcache ) | bc - l 

#echo "  $totalcache "
	div $cachehit $totalcache
	totalhit=$(div $cachehit $totalcache)

##hitrate=$(div $cachehit $totalcache)

#echo $hitrate | bc -l

	slackmessenger "Date & TIme: $CTIME \n CPU USAGE:$cpu_use % \n $ramusage \n useddisk: $UsedDisk % \n Varnish Hit Rate:$totalhit \n Public IP: $PubIp"

}


function div {
  local _d=${3:-2}
  local _n=0000000000
  _n=${_n:0:$_d}
  local _r=$(($1$_n/$2))
  _r=${_r:0:-$_d}.${_r: -$_d}
  echo "   $_r"
}

slackmessenger(){

	curl -X POST -H 'Content-type: application/json' --data '{"text":"'"$1"'"}'  https://hooks.slack.com/services/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

}


process

#slackmessenger "process"
