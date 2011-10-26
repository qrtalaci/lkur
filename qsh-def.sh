#!/bin/bashTH}.t
qsh()  {
  echo "`date` $@" >> ~/.qsh_history
  HOST=$1
  RINST=/tmp/$$qsh.sh
# test that the PublicKey authentication set properly
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
    echo "Public key authentication does not work properly, public key installation required."
  fi
}
export -f qsh
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
  echo "chown root ${XATH}.t" >> /tmp/q$BPID
  echo "rm -f ${XATH}.t" >> /tmp/q$BPID
  echo "export THISFILE='$THISFILE'" >> /tmp/q$BPID
  echo "source \$THISFILE" >> /tmp/q$BPID

  if [ $# -gt 0 ]; then
    echo "bash -c \"$@\"" >> /tmp/q$BPID
  else
    echo "bash -i" >> /tmp/q$BPID
  fi
  sudo /bin/bash /tmp/q$BPID
  rm -f /tmp/q$BPID
}
export -f ss
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
