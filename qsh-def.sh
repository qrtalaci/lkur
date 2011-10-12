#!/bin/bash
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
  #echo "Number of parameters: $#"
  #echo "Parameters value: $@"
  if [ $# -gt 0 ]; then
    PPAR='-c '"\"$@\""
    eval "sudo env SSH_AUTH_SOCK=$SSH_AUTH_SOCK /bin/bash $PPAR"
  else
    PPAR="";
    sudo env SSH_AUTH_SOCK=$SSH_AUTH_SOCK /bin/bash $PPAR
  fi
}
export -f ss
sqsh() {
  HOST=$1
  shift
  maradek=$@
  screen -t $HOST bash -c "export THISFILE=$THISFILE && qsh $HOST $maradek" 
}
export -f sqsh 
