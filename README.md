# Linux user one time password script

This is a script for having one-time passwords to connect to the servers from the places you're not sure are safe. Or in case you are away from the computer with the ssh-keys that server knows.  
By default script uses user "looper" — change it to your desired username.  
By default it uses simple function to generate a somewhat random number, combine it with the current system time and hash it twice then to get as most random sequence as possible without any dependencies.  
You're free to code any function you prefer to get any random character sequence.  
The resulting hash is the password.  
Your secret is the username used to login.  
Script gives you 10 seconds to enter the revealed password, then resets it again.  

Second variant to generate one-time password and don't expose it in plain text:
```bash
	PW=$((RANDOM % 1234567890 * $((RANDOM % 1234567890))))
	echo "looper:$PW" | chpasswd
	echo $(($PW * 123)) | sed ':a;s/\B[0-9]\{3\}\>/ &/;ta' > /tmp/pw
```

Note the '123' multiplier — this is a "second secret" which you have to use to get real password.
So you have to divide the exposed number by 123 to know the one-time password (keep in mind 20 seconds countdown to next reset)

You can enchance security even more, by placing the script to another server thus it will change the password over ssh-connection
Change the line 28 to:
ssh user@yourserver.somewhere "echo \"looper:$PW\" | chpasswd"
Just don't forget to add key from originating server to the host and use correct user.

How to use:
Place this script to any accessible path, e.g. /usr/share/bin
`chmod +x` on it
Add script with the full path to the `/etc/rc.local` to launch it at every boot.

Have fun.
