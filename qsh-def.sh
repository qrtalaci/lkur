#!/bin/bash

PS1='\d@\t\n\u@\h:\!:\#:\w$ '
export HISTIGNORE="&:[ ]*:exit"
program_name="qsh"

alias svnlkc='svn --config-dir=/home/lkurta/.subversion commit -m'
export svnlkc
alias svnlku='svn --config-dir=/home/lkurta/.subversion update'
export svnlku
alias svnlkco='svn --config-dir=/home/lkurta/.subversion checkout'
export svnlkco

s()  {
  echo "`date` $@" >> ~/.qsh_history
  HOST=$1
  RINST=/tmp/$$qsh.sh
  HIDBE=$(whoami)"@"$(hostname)
  # test that the PublicKey authentication set properly
  ssh -o PasswordAuthentication=no $HOST "echo 1 >/dev/null"
  PK=$?
  if [ $PK -eq 0 ]; then
    # init the remote instance
    #echo "PublicKey authentication is OK."
    scp -q $THISFILE $HOST:$RINST
    if [ $# -gt 1 ]; then
      shift
      PPAR="-c \"$@\""
    else
      PPAR="";
    fi

    if [ -n "$QKEY" ]; then
      QENV="QKEY=\""$QKEY"\" S_ID_HISTORY=\""$HIDBE";"$S_ID_HISTORY"\""
    else
      QENV="S_ID_HISTORY=\""$HIDBE";"$S_ID_HISTORY"\""
    fi

    # do the job
    ssh -X -t -t -o ForwardAgent=yes $HOST "source /tmp/$$qsh.sh; env THISFILE=\"/tmp/$$qsh.sh\" $QENV bash $PPAR"
    # destroy the remote instance
    ssh -t -t $HOST sudo rm -f $RINST 2>/dev/null
  else
    echo "Public key authentication does not work properly, public key installation required."
    if [ -n "$QKEY" ]; then
      echo "Copying key..."
      echo "$QKEY" >> /tmp/$$key.pub
      ssh-copy-id -i /tmp/$$key.pub $HOST
    else
      echo "Try to use standard keys..."
      if [ -e ~/.ssh/id_rsa.pub ]; then
        echo "id_rsa.pub exists"
        ssh-copy-id -i ~/.ssh/id_rsa.pub $HOST
      elif [ -e ~/.ssh/id_dsa.pub ]; then
        echo "id_dsa.pub exists"
        ssh-copy-id -i ~/.ssh/id_dsa.pub $HOST
      else
        echo "There is no key to use."
      fi
    fi  
    ssh -o PasswordAuthentication=no $HOST "echo 1 >/dev/null"
    PK=$?
    if [ $PK -eq 0 ]; then
      # init the remote instance
      scp -q $THISFILE $HOST:$RINST
      if [ $# -gt 1 ]; then
        shift
        PPAR="-c \"$@\""
      else
        PPAR="";
      fi
      # do the job
      ssh -X -t -o ForwardAgent=yes $HOST "source /tmp/$$qsh.sh; env THISFILE=\"/tmp/$$qsh.sh\" bash $PPAR"
      # destroy the remote instance
      ssh $HOST rm -f $RINST
    else
      echo "Key installation failed."
    fi  
  fi
}
export -f s

ss() {
  
  # detecting NOPASSWD sudo configuration
  echo "fiwogfhfpwxew" | sudo -S echo 1 >/dev/null
  SC=$?

  if [ $SC -eq 0 ]; then
    BPID=$$
    QTMPFILE=/tmp/q$BPID
    rm -f $QTMPFILE
    TDISPLAY=$DISPLAY
    XATH="$HOME/.Xauthority"
    cp $XATH ${XATH}.t
    chmod 644 ${XATH}.t
    echo "export DISPLAY='$TDISPLAY'" >>$QTMPFILE
    echo "export SSH_AUTH_SOCK=$SSH_AUTH_SOCK" >>$QTMPFILE
    echo "export XAUTHORITY=/root/.Xauthority" >>$QTMPFILE
    echo "xauth merge ${XATH}.t" >>$QTMPFILE
    echo "export THISFILE='$THISFILE'" >>$QTMPFILE
    echo "export QKEY='$QKEY'" >>$QTMPFILE
    echo "export S_ID_HISTORY='$(whoami)@$(hostname);$S_ID_HISTORY'" >>$QTMPFILE
    echo "source \$THISFILE" >>$QTMPFILE

    if [ $# -gt 0 ]; then
      echo "bash -c \"$@\"" >>$QTMPFILE
    else
      echo "bash -i" >>$QTMPFILE
    fi
    sudo /bin/bash $QTMPFILE
    rm -f $QTMPFILE
    rm -f $XATH.t
  else
    echo "sudo is not configured properly"
  fi
}
export -f ss

sm() {
  if [ "`whoami`" != "root" ]; then
    echo "non-root"
    quser=$1
    shift
    BPID=$$
    sudo rm -f /tmp/q$BPID
    TDISPLAY=$DISPLAY
    XATH="$HOME/.Xauthority"
    sudo rm -f /tmp/.Xauthority.t
    cp $XATH /tmp/.Xauthority.t
    sudo chown $quser:$quser /tmp/.Xauthority.t
    sudo chmod 644 /tmp/.Xauthority.t
    sudo chown $quser $THISFILE

    sudo chown $quser $SSH_AUTH_SOCK
    sudo chown $quser $(dirname $SSH_AUTH_SOCK)

    echo "export DISPLAY='$TDISPLAY'" >> /tmp/q$BPID
    echo "export SSH_AUTH_SOCK=$SSH_AUTH_SOCK" >> /tmp/q$BPID
    echo "export XAUTHORITY=\$HOME/.Xauthority" >> /tmp/q$BPID
    echo "xauth merge /tmp/.Xauthority.t" >> /tmp/q$BPID
    echo "export THISFILE='$THISFILE'" >> /tmp/q$BPID
    echo "export QKEY='$QKEY'" >> /tmp/q$BPID
    echo "source \$THISFILE" >> /tmp/q$BPID

    if [ $# -gt 0 ]; then
      echo "bash -c \"$@\"" >> /tmp/q$BPID
    else
      echo "bash -i" >> /tmp/q$BPID
    fi
    sudo -H -u $quser /bin/bash /tmp/q$BPID

    sudo rm -f /tmp/q$BPID
    sudo rm -f /tmp/.Xauthority.t
  fi
}
export -f sm

sqsh() {
  HOST=$1
  shift
  maradek=$@
  screen -t $HOST bash -c "export THISFILE=$THISFILE && qsh $HOST $maradek" 
}
export -f sqsh 

qshh() {
  grep "$1" ~/.qsh_history
}
export -f qshh

sreload() {
  source $THISFILE
}
export -f sreload

se() {
  vim $THISFILE
}
export -f se

h() {
  history | grep $1
}
export -f h

hh() {
  cat ~/.qsh_history | grep $1
}
export -f hh

shelp() {
  echo "Usage:

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
  "
}
export -f shelp

sdump() {
  echo "s version 0.01"
  echo "Current user is: "$(whoami)
  echo "Current host is: "$(hostname)
  echo "Current dir is: "$(pwd)
  echo ""
  echo "ENVIRONMENT:"
  echo "DISPLAY="$DISPLAY
  echo "THISFILE="$THISFILE
  ls -al $THISFILE
  echo "SSH_AUTH_SOCK="$SSH_AUTH_SOCK
  ls -al $SSH_AUTH_SOCK 
  echo "QKEY="$QKEY
  echo "S_SSH_OPTS="$S_SSH_OPTS
  echo "S_ID_HISTORY"=$S_ID_HISTORY
}
export -f sdump

: <<=cut
=pod
=head1 NAME

  qsh-def.sh - time saver shell script aliases

  Dependencies: OpenSSH

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 ENVIRONMENT



=head1 AUTHOR

B<I> qrtalaci@qrtalaci.com

=cut
