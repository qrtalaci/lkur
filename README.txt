
lkur is set of bash functions which provides a powerful frontend to OpenSSH's useful features

Installation:
-------------

Put it into your ~/.bashrc:
--------o<--------
# lkur installation
if [ ! -f "$THISFILE" ]; then
  THISFILE=<location of qsh-def.sh>
fi
if [ -f "$THISFILE" ]; then
  source "$THISFILE"
fi
--------o<--------


Usage:
------

    s [user]@hostname [command(s)]
      It provides passphraseless (by RSA/DSA public keys) login with lot of automations: self copy installation and configuration on the destination, X11 forwarding, ssh agent forwarding, breadcrumb management, environment transfer
      Omitted command results bash invocation.
      On exit it removes its footprint (only one file in the /tmp directory)

    ss [command(s)]
      sudo with the s's functionality (X11 forwarding, ...)

    sm user [command()s]

    h <word> 
      grep word in in bash history file

    hh <word>
      search in local ${program_name} history

    sreload
      reload the definition script

    se
      edit definition script

    sdump
      print ${program_name} status variables

Tested with:
  Ubuntu 
  Debian GNU Linux
  RedHat Enterprise Linux >4.x

Prerequsities:
  (most of it are part of default minimal installation of different distros)
  ...

László Kurta E-mail:qrtalaci@qrtalaci.com
