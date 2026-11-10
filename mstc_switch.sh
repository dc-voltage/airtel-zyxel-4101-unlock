#!/bin/sh 

CHECKVERSION=/tmp/GREEN
	## M2M config
	##if [ -f $CHECKVERSION ]; then
	
	##	echo "Run M2M default SW config.." > /dev/console
	echo "Run default SW config.." > /dev/console
		#swconfig dev switch0 set reset 1
		#switch an8855 acl clear rule
		#switch an8855 acl clear udfRule
		#switch an8855 acl clear action
		switch_airoha an8855 vlan destroy 0-4095
		swconfig dev switch0 set enable_vlan 1
		swconfig dev switch0 port 0 set pvid 1
		swconfig dev switch0 port 1 set pvid 1
		swconfig dev switch0 port 2 set pvid 3
		swconfig dev switch0 port 3 set pvid 3
		swconfig dev switch0 port 4 set pvid 3
		swconfig dev switch0 port 5 set pvid 1
	
		swconfig dev switch0 vlan 1 set vid 1
		swconfig dev switch0 vlan 1 set ports '5 0 1'
	
		swconfig dev switch0 vlan 3 set vid 3
		swconfig dev switch0 vlan 3 set ports '5t 2t 3t 4t'
	
		swconfig dev switch0 vlan 1999 set vid 1999
		swconfig dev switch0 vlan 1999 set ports '5t 0t 1t'
		swconfig dev switch0 set apply
	
		# set port matrix
		switch_airoha an8855 port set matrix 0 0x20
		switch_airoha an8855 port set matrix 1 0x20
		switch_airoha an8855 port set matrix 2 0x20
		switch_airoha an8855 port set matrix 3 0x20
		switch_airoha an8855 port set matrix 4 0x20
		switch_airoha an8855 port set matrix 5 0x3f
		
		# set port mode security
		switch_airoha an8855 port set vlanMode 0 3 
		switch_airoha an8855 port set vlanMode 1 3
		switch_airoha an8855 port set vlanMode 2 3
		switch_airoha an8855 port set vlanMode 3 3
		switch_airoha an8855 port set vlanMode 4 3
		switch_airoha an8855 port set vlanMode 5 3
		
		# set vlan Attr user
		switch_airoha an8855 vlan set portVlanAttr 0 0
		switch_airoha an8855 vlan set portVlanAttr 1 0
		switch_airoha an8855 vlan set portVlanAttr 2 0
		switch_airoha an8855 vlan set portVlanAttr 3 0
		switch_airoha an8855 vlan set portVlanAttr 4 0		
		switch_airoha an8855 vlan set portVlanAttr 5 0

		# disable p5 mac learning
		switch an8855 reg w 10208a0c 80010
		
		### Just CPU port flooding unknown unicast pkts
		#switch an8855 sec set fldMode 5 2 1
		#switch an8855 sec set fldMode 0 2 0
		#switch an8855 sec set fldMode 1 2 0
		switch an8855 reg w 102000B4 20
		
		# extand mac addr age
		switch an8855 l2 set macAddrAgeOut 500000
		brctl setageing br0 500000
	
		# enable acl : TCP ACK 
		switch an8855 acl set en 0
		switch an8855 acl set portEn 0 0
		switch an8855 acl set portEn 1 0
		switch an8855 acl set portEn 5 0
		# udf rule匹配 tcp ack 封包
		switch an8855 acl set udfRule 0 0 0010 0010 5 6 0100011
		# acl rule 挂載 udf rule
		switch an8855 acl set rule 120 1 0 1 0100011 2 udf 1 1
		# 匹配上的封包優先級調至pri 7
		switch an8855 acl set action 120 priority 7
		
		## /********************************
		##  * Set acl rules
		##  * port0 : base 100
		##  *			isolation  : 100 ~ 105
		##  *			
		##  * port1 : base 110
		##  *			isolation  : 110 ~ 115
		##  *
		##  * tcp ack : base 120 - udf[0] 
		##  ********************************/
		## check switch an8855 : Found: switch0 - AN8855
		##echo "Run M2M SW config done.." > /dev/console
		echo "Run default SW config done.." > /dev/console

