#!/bin/bash

# Author: Ashley Cawley // @ashleycawley <-- Say Hi if you use this tool.

# This tool will report the following:
# - Website Type (WordPress, Drupal, Joomla, Magento, Umbraco, PrestaShop etc)
# - Nameservers
# - A Record
# - MX Record

# Further CMS checks I would like to add in future:
# concrete5

# Functions
function DNSTESTS {

	function COMORGWHOIS {
	# WHOIS test performed on .com or .org domains
                echo "Nameserver Records:"
		whois $DOMAIN | awk -F: '/Name Server/{print $2}'
		echo
		}

# Tests to see domain is a .com domain in prep for doing a .com NS Lookup
	echo $DOMAIN | grep -q -i ".com"
	COM=$(echo $?)

	if [ `echo $COM` == '0' ]
	then
		COMORGWHOIS
	fi

# Tests to see domain is a .org
        echo $DOMAIN | grep -q -i ".org"
        ORG=$(echo $?)

        if [ `echo $ORG` == '0' ]
        then
                COMORGWHOIS
        fi

# Tests to see if domain contains ".uk" so this will encompass .co.uk or .uk domains

        echo $DOMAIN | grep -q -i ".uk"
        UK=$(echo $?)


	if [ `echo $UK` == '0' ]
	then
		whois $DOMAIN | grep -A3 servers
		echo
		echo -e "Registrar Tag: \c"
		whois $DOMAIN | grep -i Tag && echo
	fi

# Performs DNS A & MX Record Lookups
	echo -e "A Record:"
	dig +short $DOMAIN A && echo

	echo -e "MX Records:"
	dig +short $DOMAIN MX && echo
}

function DOTCOMNSLOOKUP {
	whois $DOMAIN | awk -F: '/Name Server/{print $2}'
}

function CMSTESTS {

	########## WORDPRESS ##########
# WordPress Test - Retrieves status code from $DOMAIN/wp-login.php and saves into $STATUSCODE
	STATUSCODE=$(curl -L -o /dev/null --silent --head --write-out '%{http_code}\n' http://$DOMAIN/wp-login.php)

# WordPress Test - Checks to see if a licencse.txt file exists and whether it contains the word 'WordPress'
	curl -L --silent http://$DOMAIN/license.txt | grep -q -i "WordPress"
	WPLIC=$(echo $?)

# WordPress Test - Searches the source-code of the homepage to see if it contains the word 'WordPress'
	curl -L --silent http://$DOMAIN/ | grep -q -i "WordPress"
	WPINDEX=$(echo $?)

# WordPress Result - If any of the above WordPress Tests are true then it echos "WordPress has been detected."
	if [ $STATUSCODE == "200" ] || [ $WPLIC == "0" ] || [ $WPINDEX == "0" ]
	then
		echo -e "\e[32mWordPress\c" && echo -e "\e[39m has been detected." && echo

	fi
	
	########## DRUPAL ##########
# Drupal Test - Searches the source-code of the homepage to see if it contains the word 'Drupal'
	wget -q http://$DOMAIN/ -O /tmp/drupal.html && grep -q -i "Drupal" /tmp/drupal.html
	DRUPAL=$(echo $?)
	rm -f /tmp/drupal.html

# Drupal Result - If any of the above Drupal Tests are true this echos "Drupal has been detected."
	if [ $DRUPAL == '0' ]
	then
		echo -e "\e[32mDrupal\c" && echo -e "\e[39m has been detected." && echo
	fi

	########## JOOMLA ##########	
# Joomla Test - Searches the source-code of the homepage to see if it contains the word 'Joomla'
	wget -q http://$DOMAIN/ -O /tmp/joomla.html && grep -q -i "Joomla" /tmp/joomla.html
	JOOMLA=$(echo $?)
	rm -f /tmp/joomla.html

# Joomla Result - If any of the above Joomla Tests are true this echos "Joomla has been detected."
	if [ $JOOMLA == '0' ]
	then
		echo -e "\e[32mJoomla\c" && echo -e "\e[39m has been detected." && echo
	fi

	########## MAGENTO ##########
# Magento Test - Searches the source-code of the home page to see if it contains /skin/frontend/
	curl --silent -L http://$DOMAIN/ | grep -q -i "/skin/frontend/"
        MAGESTATUS=$(echo $?)
	if [ $MAGESTATUS == '0' ]
	then
		echo -e "\e[32mMagento\c" && echo -e "\e[39m has been detected." && echo
	fi
        ########## Umbraco ##########
# Umbraco Test - Checks to see if the default Umbraco login page is present
	# curl -Is http://$DOMAIN/umbraco/login.aspx | grep 'HTTP' | grep -q '200'
	# Old test was showing some false positives: curl --silent -L http://$DOMAIN/umbraco/login.aspx | grep -i -q "umbraco"
	# UMBRACOSTATUS=$(echo $?)
	# if [ `echo $?` == '0' ]
	# then
	#	echo -e "\e[32mUmbraco\c" && echo -e "\e[39m has been detected." && echo
	# fi

        ########## PrestaShop ##########
# PrestaShop Test - Checks to see if the word PrestaShop is present in the homepage source code
        curl --silent -L http://$DOMAIN/ | grep -i -q "prestashop"
        PRESTASHOPSTATUS=$(echo $?)
        if [ $PRESTASHOPSTATUS == '0' ]
        then
                echo -e "\e[32mPrestaShop\c" && echo -e "\e[39m has been detected." && echo
        fi
}

# Script

# Clears the screen for a clean working area
echo -e "\f"

# Test to see if required programs are installed on the system
for p in dig whois wget curl; do 
	hash "$p" &>/dev/null && cat /dev/null ||
	echo "WARNING: $p is not installed - Please install $p so that this script can function correctly."
	hash "$p" &>/dev/null && cat /dev/null ||
	sleep 5
done 

# Performs a test to see if a domains.txt file exists and if it does and it is greater than 5 bytes it uses it
if [ `wc -c domains.txt 2>/dev/null | awk '{print $1}'` -gt '5' ] 2>/dev/null
then

	echo -e "A list of domains has been detected in \e[32mdomains.txt\e[39m" && echo && sleep 2
	echo "=====================================================" && echo

# while loop which takes input from domains.txt (see end of the while-loop by 'done' below)
	while read DOMAIN
	do
		echo "Testing: $DOMAIN ..." && echo

# DNS Tests
		DNSTESTS 

# CMS Tests
		CMSTESTS
		echo "=====================================================" && echo

	done < domains.txt

	echo "Archiving domains.txt file by renaming it to be domains.old ..." && echo && sleep 2
	mv domains.txt domains.old
	exit 0

fi

# Tests to see if an arguement was supplied by user. If not asks for domain, else it uses the supplied arguement
if [ $# -eq 0 ]
then

# Prompt the user for the Domain Name to build a report on
	read -p "Domain Name: " DOMAIN

	echo && echo "Analysing $DOMAIN ..." && echo

# DNS Tests
	DNSTESTS

# CMS Tests
	CMSTESTS

	else

# Inserts the user supplied arguement $1 into the variable $DOMAIN
		DOMAIN=$(echo $1)
		echo && echo "Analysing $DOMAIN ..." && echo

# DNS Tests
	DNSTESTS

# CMS Tests
	CMSTESTS

	exit 0

fi

exit 0
