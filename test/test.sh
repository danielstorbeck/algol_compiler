# system tests

# test0.algo contains the character '
# this provokes an endless loop in the parser
# the error messages appear on stderr
# they are redirected to stdout using 2>&1
# the idiom "cmd1 < <( cmd2 ) directs the output of cmd2
# into cmd1 without using a pipe
# therefore cmd1 can stop processing without waiting for cmd2 to end
bash detect-loop.sh < <( ../a.out algol/test0.algol 2>&1 )
# detect-loop.sh's exit status is waiting in the variable '?'
if (( ${?} == 1 ))
then
    echo "test 0 passed: the endless loop still occurs"
else if (( ${?} == 0 ))
     then
	 echo "!test 0 FAILED: the endless loop doesn't occur any more"
     fi
fi
