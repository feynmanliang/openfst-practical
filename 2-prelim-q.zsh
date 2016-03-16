#!/usr/bin/zsh

source 0-source-me.zsh



# Draw the input and model FSTs generated above. Then compose them and project
# the result to keep only output symbols, and draw the resulting FST
# (result.fst). Note that when drawing acceptors (such as 'input'), you can
# optionally use `fstdraw --acceptor` to avoid showing the redundant output
# symbols (only showing input ones).
fstdraw --isymbols=isyms.txt --osymbols=isyms.txt --acceptor input.fst | dot -Tps > input.ps
fstdraw --isymbols=isyms.txt --osymbols=osyms.txt model.fst | dot -Tps > model.ps
ps2pdf input.ps output/input.pdf
ps2pdf model.ps output/model.pdf

fstarcsort --sort_type=ilabel model.fst \
  | fstcompose input.fst - \
  | fstproject --project_output - result.fst
fstdraw --isymbols=osyms.txt --osymbols=osyms.txt --acceptor result.fst | dot -Tps > result.ps
ps2pdf result.ps output/result.pdf

# (i) How many alternative paths exist in the input FST? How many distinct
# strings do these encode?  Which ones of these strings can be accepted by the
# model transducer?
# A: 4 paths, encoding 4 strings, 3 of which get accepted by the model ('a b c
# a' is not)
printstrings.O2 --label-map=isyms.txt --input=input.fst -n 10 -w 2> /dev/null

# (ii) How many alternative paths exist in the result FST? How many distinct
# strings do these encode?
# A: 4 paths, encoding 3 distinct strings
printstrings.O2 --label-map=osyms.txt --input=result.fst -n 10 -w 2> /dev/null

# (iii) Now remove epsilon arcs, determinize and minimize the result FST. How
# many alternative paths exist now? How many distinct strings do these encode?
# Why?
# A: 3 paths, encoding 3 distinct strings. This is because determinization
# leaves one distinct path per string.
fstrmepsilon result.fst | fstdeterminize | fstminimize - result2.fst
printstrings.O2 --label-map=osyms.txt --input=result2.fst -n 10 -w 2> /dev/null
fstdraw --isymbols=osyms.txt --osymbols=osyms.txt --acceptor result2.fst | dot -Tps > result2.ps
ps2pdf result2.ps output/result2.pdf

# (iv) How many alternative strings are accepted by the model FST? Refer to the
# drawing to support your answer
# A: An infinite number of strings, because the loop at state 3 accepts any
# unlimited sequence of 'a' labels.
