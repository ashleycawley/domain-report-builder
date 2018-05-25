#!/bin/bash

# Things I would like it to report:
# - Website Type (WordPress, Drupal etc)
# - Nameservers
# - A Record
# - MX Record

# Variables

# Functions
function DNSTESTS {

# Tests to see domain is a .com domain in prep for doing a .com NS Lookup
	echo $DOMAIN | grep -q -i ".com"
	COM=$(echo $?)

	if [ `echo $COM` == '0' ]
	then
		echo "Nameserver Records:"
		whois $DOMAIN | awk -F: '/Name Server/{print $2}'
		echo
	fi

# Tests to see if domain is a .co.uk domain in prep for doing a .co.uk NS Lookup
	echo $DOMAIN | grep -q -i ".co.uk"
	COUK=$(echo $?)
	if [ `echo $COUK` == '0' ]
	then
		whois $DOMAIN | grep -A3 servers
	fi

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
	STATUSCODE=$(curl -o /dev/null --silent --head --write-out '%{http_code}\n' http://$DOMAIN/wp-login.php)

	# WordPress Test - Checks to see if a licencse.txt file exists and whether it contains the word 'WordPress'
	curl --silent http://$DOMAIN/license.txt | grep -q "WordPress"
	WPLIC=$(echo $?)

	# WordPress Test - Searches the source-code of the homepage to see if it contains the word 'WordPress'
	curl --silent http://$DOMAIN/ | grep -q "WordPress"
	WPINDEX=$(echo $?)

	# WordPress Result - If any of the above WordPress Tests are true then it echos "WordPress has been detected."
	if [ $STATUSCODE == "200" ] || [ $WPLIC == "0" ] || [ $WPINDEX == "0" ]
	then
		echo -e "\e[32mWordPress\c" && echo -e "\e[39m has been detected." && echo

	fi
	
	########## DRUPAL ##########
	# Drupal Test - Searches the source-code of the homepage to see if it contains the word 'Drupal'
	wget -q http://$DOMAIN/ -O /tmp/drupal.html && grep -q "Drupal" /tmp/drupal.html
	DRUPAL=$(echo $?)
	rm -f /tmp/drupal.html

	# Drupal Result - If any of the above Drupal Tests are true this echos "Drupal has been detected."
	if [ $DRUPAL == '0' ]
	then
		echo -e "\e[32mDrupal\c" && echo -e "\e[39m has been detected." && echo
	fi

	########## JOOMLA ##########	
	# Joomla Test - Searches the source-code of the homepage to see if it contains the word 'Joomla'
	wget -q http://$DOMAIN/ -O /tmp/joomla.html && grep -q "Joomla" /tmp/joomla.html
	JOOMLA=$(echo $?)
	rm -f /tmp/joomla.html

	# Joomla Result - If any of the above Joomla Tests are true this echos "Joomla has been detected."
	if [ $JOOMLA == '0' ]
	then
		echo -e "\e[32mJoomla\c" && echo -e "\e[39m has been detected." && echo
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

	while read DOMAIN
	do
		
		echo "Testing: $DOMAIN ..." && echo

		# To understand the functions below see the functions and their comments toward the top of this file
		DNSTESTS 

		# CMS Tests
		CMSTESTS
		echo "=====================================================" && echo

	done < domains.txt

	echo "Archiving domains.txt file by renaming it to be domains.old ..." && echo && sleep 2
	mv domains.txt domains.old
	exit 0

fi

# Tests to see if an arguement was provided by the user to the script
if [ $# -eq 0 ]
then

	# Prompt the user for the Domain Name to build a report on
	read -p "Domain Name: " DOMAIN

	echo && echo "Analysing $DOMAIN ..." && echo

	# To understand the functions below see the functions and their comments toward the top of this file
	DNSTESTS

        # CMS Tests
	CMSTESTS

	else

		DOMAIN=$(echo $1)
		echo && echo "Analysing $DOMAIN ..." && echo

	# To understand the functions below see the functions and their comments toward the top of this file
	DNSTESTS

        # CMS Tests
	CMSTESTS

	exit 0

fi

exit 0
