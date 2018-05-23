#!/bin/bash

# Things I would like it to report:
# - Website Type (WordPress, Drupal etc)
# - Nameservers
# - A Record
# - MX Record

# Variables

# Functions
function DNSTESTS {
echo -e "Nameserver Records:"
dig +short $DOMAIN NS && echo

echo -e "A Record: \c"
dig +short $DOMAIN A && echo

echo -e "MX Record: \c"
dig +short $DOMAIN MX && echo
}

function LOOKUPWPSCODE {
# Retrieves the status code from visiting $DOMAIN/wp-login.php and saves it into a variable called $STATUSCODE
STATUSCODE=$(curl -o /dev/null --silent --head --write-out '%{http_code}\n' http://$DOMAIN/wp-login.php)
}

function LOOKUPLIC {
# Checks to see if a licencse.txt file exists and whether it contains the word WordPress
curl --silent http://$DOMAIN/license.txt | grep -q "WordPress"
WPLIC=$(echo $?)
}

function LOOKUPWPINDEX {
# Checks to see if a licencse.txt file exists and whether it contains the word WordPress
curl --silent http://$DOMAIN/ | grep -q "WordPress"
WPINDEX=$(echo $?)
}

function WORDPRESSRESULT {
if [ $STATUSCODE == "200" ] || [ $WPLIC == "0" ] || [ $WPINDEX == "0" ]
        then
                echo -e "\e[32mWordPress\c" && echo -e "\e[39m has been detected." && echo

        fi
}

function DRUPALGREP {
# Checks to see if "Drupal" exists on the frontpage
wget -q http://$DOMAIN/ -O /tmp/drupal.html && grep -q "Drupal" /tmp/drupal.html
DRUPAL=$(echo $?)
rm -f /tmp/drupal.html
}

function DRUPALRESULT {
if [ $DRUPAL == '0' ]
then
	echo -e "\e[32mDrupal\c" && echo -e "\e[39m has been detected." && echo
fi
}

# Script

# Test to see if required programs are installed on the system
for p in dig whois wget curl; do 
    hash "$p" &>/dev/null && cat /dev/null ||
                 echo "WARNING: $p is not installed - Please install $p so that this script can function correctly."
	hash "$p" &>/dev/null && cat /dev/null ||
                 sleep 5
done 

# Clears the screen for a clean working area
echo -e "\f"

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

		# WordPress Tests
		LOOKUPWPSCODE
		LOOKUPLIC
		LOOKUPWPINDEX
		WORDPRESSRESULT

		# Drupal Tests
		DRUPALGREP
		DRUPALRESULT

		echo "=====================================================" && echo

	done < domains.txt

	echo "Archiving domains.txt file by renaming it to be domains.old ..." && echo && sleep 2
	mv domains.txt domains.old
	exit 0

fi

# Prompt the user for the Domain Name to build a report on
read -p "Domain Name: " DOMAIN

echo && echo "Analysing $DOMAIN ..." && echo

# To understand the functions below see the functions and their comments toward the top of this file
DNSTESTS

# WordPress Tests
LOOKUPWPSCODE
LOOKUPLIC
LOOKUPWPINDEX
WORDPRESSRESULT

# Drupal Tests
DRUPALGREP
DRUPALRESULT

exit 0
