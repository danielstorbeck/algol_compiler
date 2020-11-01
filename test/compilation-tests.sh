# remove compiler output if present
function remove-compiler-output ()
{
    [ -f code1.asm ] && rm code1.asm
}

# for each of the asm files in the folder generated-asm
# generate them again from the algol test files and compare them
# to the originals in the folder generated-asm
for NUMBER in $(seq 1 9)
do
    remove-compiler-output
    # generate asm file again but throw away stdout output
    ../a.out algol/test${NUMBER}.algol > /dev/null
    # check that asm output has been generated
    [ -f code1.asm ] \
	|| echo "!test ${NUMBER} FAILED: no asm code generated"
    # check that asm output is identical to original
    [ $( diff code1.asm generated-asm/test${NUMBER}.asm 2>&1 | wc -l ) == "0" ] \
	&& echo "test ${NUMBER} passed: asm code identical to original" \
		|| echo "!test ${NUMBER} FAILED: asm code not identical to original"
done
remove-compiler-output
