#! /bin/bash
# This is a script for having one-time passwords to connect to the servers from the places you're not sure are safe.
# By default it uses user "looper" — change it to your desired username
# By default it uses simple function to generate a somewhat random number, combine it with the current system time and hash it twice then. 
# You're free to code any function you prefer to get any random character sequence.
# The resulting hash is the password. 
# Your secret is the username used to login
# Script gives you 20 seconds to enter the revealed password, then resets it again.

# Second variant to generate one-time password and don't expose it in plain text:
# 	PW=$((RANDOM % 1234567890 * $((RANDOM % 1234567890))))
#	echo "looper:$PW" | chpasswd
#	echo $(($PW * 123)) | sed ':a;s/\B[0-9]\{3\}\>/ &/;ta' > /tmp/pw

# Note the '123' multiplier — this is a "second secret" which you have to use to get real password.
# So you have to divide the exposed number by 123 to know the one-time password

# You can enchance security even more, by placing the script to another server thus it will change the password over ssh-connection
# Change the line 45 to:
# ssh user@yourserver.somewhere "echo \"looper:$PW\" | chpasswd"
# Just don't forget to add key from originating server to the host and use correct user.

# How to use:
# Place this script to any accessible path, e.g. /usr/share/bin
# `chmod +x` on it
# Add script with the full path to the /etc/rc.local to launch it at every boot.

if ! which nc 
then
	echo "nc not found in the PATH. Need to fix."
	exit 1
fi

if ! which md5sum 
then
	echo "md5sum not found in the PATH. Need to fix."
	exit 1
fi

if ! which sha1sum 
then
	echo "sha1sum not found in the PATH. Need to fix."
	exit 1
fi

echo "Access denied" > /tmp/pw

while true 
do
	PW="$(echo $((RANDOM % 1234567890 * $((RANDOM % 1234567890 * $((RANDOM % 1234567890))))))$(date +%Y%m%d%HH%MM) | md5sum | sha1sum | cut -d " " -f 1)"
	echo "looper:$PW" | chpasswd
	echo $PW > /tmp/pw
	{ echo -ne "HTTP/1.0 200 OK\r\n\r\n"; cat /tmp/pw; } | nc -l -p 8765
	sleep 10
done