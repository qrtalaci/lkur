#!/bin/bash
s()  {
  echo "`date` $@" >> ~/.qsh_history
  HOST=$1
  RINST=/tmp/$$qsh.sh
  # test that the PublicKey authentication set properly
  ssh -o PasswordAuthentication=no $HOST "echo 1 >/dev/null"
  PK=$?
  if [ $PK -eq 0 ]; then
# init the remote instance
    echo "PublicKey authentication is OK."
    scp -q $THISFILE $HOST:$RINST
    if [ $# -gt 1 ]; then
      shift
      PPAR="-c \"$@\""
    else
      PPAR="";
    fi

    if [ -n "$QKEY" ]; then
      QENV="QKEY=\""$QKEY"\""
    fi
    # do the job
    ssh -X -t -o ForwardAgent=yes $HOST "source /tmp/$$qsh.sh; env THISFILE=\"/tmp/$$qsh.sh\" $QENV bash $PPAR"
    # destroy the remote instance
    ssh $HOST rm $RINST
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
      ssh $HOST rm $RINST
    else
      echo "Key installation failed."
    fi  
  fi
}
export -f s
ss() {
  BPID=$$
  rm -f /tmp/q$BPID
  TDISPLAY=$DISPLAY
  XATH="$HOME/.Xauthority"
  cp $XATH ${XATH}.t
  chmod 644 ${XATH}.t
  echo "export DISPLAY='$TDISPLAY'" >> /tmp/q$BPID
  echo "export SSH_AUTH_SOCK=$SSH_AUTH_SOCK" >> /tmp/q$BPID
  echo "export XAUTHORITY=/root/.Xauthority" >> /tmp/q$BPID
  echo "xauth merge ${XATH}.t" >> /tmp/q$BPID
  echo "export THISFILE='$THISFILE'" >> /tmp/q$BPID
  echo "export QKEY='$QKEY'" >> /tmp/q$BPID
  echo "source \$THISFILE" >> /tmp/q$BPID

  if [ $# -gt 0 ]; then
    echo "bash -c \"$@\"" >> /tmp/q$BPID
  else
    echo "bash -i" >> /tmp/q$BPID
  fi
  sudo /bin/bash /tmp/q$BPID
  rm -f /tmp/q$BPID
  rm -f $XATH.t
}
export -f ss

sm() {
  if [ "`whoami`" != "root" ]; then
    echo "non-root"
    quser=$1
    shift
    BPID=$$
    rm -f /tmp/q$BPID
    TDISPLAY=$DISPLAY
    XATH="$HOME/.Xauthority"
    cp $XATH /tmp/.Xauthority.t
    chmod 644 /tmp/.Xauthority.t
    echo "export DISPLAY='$TDISPLAY'" >> /tmp/q$BPID
    echo "export SSH_AUTH_SOCK=$SSH_AUTH_SOCK" >> /tmp/q$BPID
    echo "export XAUTHORITY=/home/$quser/.Xauthority" >> /tmp/q$BPID
    echo "xauth merge /tmp/.Xauthority.t" >> /tmp/q$BPID
    echo "export THISFILE='$THISFILE'" >> /tmp/q$BPID
    echo "export QKEY='$QKEY'" >> /tmp/q$BPID
    echo "source \$THISFILE" >> /tmp/q$BPID

    if [ $# -gt 0 ]; then
      echo "bash -c \"$@\"" >> /tmp/q$BPID
    else
      echo "bash -i" >> /tmp/q$BPID
    fi
    sudo -u $quser /bin/bash /tmp/q$BPID
    rm -f /tmp/q$BPID
    rm -f /tmp/.Xauthority.t
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
