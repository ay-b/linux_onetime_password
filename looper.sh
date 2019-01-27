#! /bin/bash
# This is a script for having one-time passwords to connect to the servers from the places you're not sure are safe.
# https://github.com/ay-b/linux_onetime_password/

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
