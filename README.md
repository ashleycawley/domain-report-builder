# domain-report-builder
A tool which gives you a very straight-forward DNS report and attempts to detect the CMS (WordPress, Drupal, Joomla etc) that is running on the website.

It utilises tools like dig and whois to show you the main DNS Records like:
- DNS A Record
- DNS MX Record
- Nameserver Records

And can detected a range of different CMS types. A typical output from the program might look like this:

```
Domain Name: drupal.com

Analysing drupal.com ...

Nameserver Records:
 DAMON.NS.CLOUDFLARE.COM
 TEGAN.NS.CLOUDFLARE.COM

A Record: 104.16.70.228
104.16.73.228
104.16.71.228
104.16.69.228
104.16.72.228

MX Record: 20 alt1.aspmx.l.google.com.
50 aspmx3.googlemail.com.
40 aspmx2.googlemail.com.
10 aspmx.l.google.com.
30 alt2.aspmx.l.google.com.

Drupal has been detected.
```
## Using This Tool
For your ease I have created three different ways in which you can use this tool:
### Run the script
Simply run the script by typing `./report.sh` and then it will ask you for the domain name you would like a report on.
### Run the script and supply the domain as an argument
Run `./report.sh domain.com` and the program will immediately start processing a report for that domain name.
### Supply a list
You can create a `domains.txt` document which contains a list of domain names (each domain on its own line) and providing the that file is in the same folder as this script it will automatically detect and use that file.
