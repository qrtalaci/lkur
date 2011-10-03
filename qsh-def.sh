#!/bin/bash
qsh()  {
  ssh -X -t -o ForwardAgent=yes $@ "/bin/bash"
}
qshr()  {
  ssh -X -t -o ForwardAgent=yes $@ "env SSH_AUTH_SOCK=\$SSH_AUTH_SOCK sudo su"
}
export -f qsh
