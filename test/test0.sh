# read lines from stdin
# and detect an endless sequence of lines containing
# "error: encountered on this token->"
# where endless means more than 10 occurrences

# when an endless sequence is detected exit with status 1
# else exit with status 0

COUNT=0

# read reads a line from stdin into the variable REPLY
# and it chops off the newline
while read
do
    if [[ "${REPLY}" == "error: encountered on this token->" ]]
    then
	let COUNT+=1
    fi
    if (( ${COUNT} > 5 ))
    then
	exit 1
    fi
done
exit 0
