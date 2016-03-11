#!/usr/bin/zsh

# Draw the input and model FSTs generated above. Then compose them and project
# the result to keep only output symbols, and draw the resulting FST
# (result.fst). Note that when drawing acceptors (such as ’input’), you can
# optionally use ’fstdraw --acceptor’ to avoid showing the redundant output
# symbols (only showing input ones).
fstdraw --isymbols=isyms.txt --osymbols=isyms.txt --acceptor input.fst | dot -Tps > input.ps
fstdraw --isymbols=isyms.txt --osymbols=osyms.txt model.fst | dot -Tps > model.ps

fstarcsort --sort_type=ilabel model.fst \
  | fstcompose input.fst - \
  | fstproject --project_output - result.fst
fstdraw --isymbols=isyms.txt --osymbols=osyms.txt result.fst | dot -Tps > result.ps

# (i) How many alternative paths exist in the input FST? How many distinct
# strings do these encode?  Which ones of these strings can be accepted by the
# model transducer?

# (ii) How many alternative paths exist in the result FST? How many distinct
# strings do these encode?

# (iii) Now remove epsilon arcs, determinize and minimize the result FST. How
# many alternative paths exist now? How many distinct strings do these encode?
# Why?

# (iv) How many alternative strings are accepted by the model FST? Refer to the
# drawing to support your answer
