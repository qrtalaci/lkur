#!/bin/bash
qsh()  {
  echo "`date` $@" >> ~/.qsh_history
  HOST=$1
  scp -q $THISFILE $HOST:/tmp/$$qsh.sh
  if [ $# -gt 1 ]; then
    shift
    PPAR="-c \"$@\""
  else
    PPAR="";
  fi
  ssh -X -t -o ForwardAgent=yes $HOST "source /tmp/$$qsh.sh; env THISFILE=\"/tmp/$$qsh.sh\" bash $PPAR"
  ssh $HOST rm /tmp/$$qsh.sh
}
qshr()  {
  ssh -X -t -o ForwardAgent=yes $@ "sudo su root -c \"env SSH_AUTH_SOCK=\$SSH_AUTH_SOCK bash\""
}
ss() {
  echo "Number of parameters: $#"
  echo "Parameters value: $@"
  if [ $# -gt 0 ]; then
    PPAR='-c '"\"$@\""
    eval "sudo env SSH_AUTH_SOCK=$SSH_AUTH_SOCK /bin/bash $PPAR"
  else
    PPAR="";
    sudo env SSH_AUTH_SOCK=$SSH_AUTH_SOCK /bin/bash $PPAR
  fi
}
export -f ss
export -f qshr
export -f qsh
