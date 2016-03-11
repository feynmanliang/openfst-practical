#!/usr/bin/zsh

# arc format: src dest ilabel olabel [weight]
# final state format: state [weight]
# lines may occur in any order except initial state must be first line
# unspecified weights default to 0.0 (for the library-default Weight type)
# (or use a text editor)
cat >eg1.txt <<EOF
0 1 a x .5
0 1 b y 1.5
1 2 c z 2.5
2 3.5
EOF

cat >isyms.txt <<EOF
<eps> 0
a 1
b 2
c 3
EOF
cat >osyms.txt <<EOF
<eps> 0
x 1
y 2
z 3
EOF

# Creates binary Fst from text file.
# The symbolic labels will be converted into integers using the symbol table files.
fstcompile --isymbols=isyms.txt --osymbols=osyms.txt eg1.txt eg1.fst

# Print FST using symbol table files.
fstprint --isymbols=isyms.txt --osymbols=osyms.txt eg1.fst

# Draw FST using symbol table files and Graphviz dot:
fstdraw --isymbols=isyms.txt --osymbols=osyms.txt eg1.fst eg1.dot
dot -Tps eg1.dot > eg1.ps

fstinfo eg1.fst

# Print the N shortest paths (-n 10), showing their cost (-w)
# and the strings they encode in the input labels (--label-map isym.txt)
printstrings.O2 --label-map=isyms.txt --input=eg1.fst -n 10 -w

# Print the N shortest paths (-n 10), showing their cost (-c)
# and the strings they encode in the output labels (--label-map osym.txt)
fstproject eg1.fst eg1o.fst
printstrings.O2 --label-map=osyms.txt --input=eg1o.fst -n 10 -w 2> /dev/null

# Create an input transducer in text format:
# When input and output labels are equal, it is an acceptor
cat > input.txt <<EOF
0 1 a a
1 2 b b
2 3 c c
3 4 a a 0.4
2 5 a a 0.2
5 6 a a
2 1.0
3
4
6 0.1
EOF
# Compile as binary file (using same input/output table):
fstcompile --isymbols=isyms.txt --osymbols=isyms.txt input.txt input.fst

# Create a weighted transducer in text format
cat > model.txt <<EOF
0 1 a x 0.2
0 1 b y 1.2
0 1 c z 3
1 2 b y 0.5
1 4 b z 0.1
2 3 c x
2 4 a <eps> 0.5
4 4 a x 0.1
3
4
EOF
# Compile as binary file (using same input/output table):
fstcompile --isymbols=isyms.txt --osymbols=osyms.txt model.txt model.fst

# Creates the composed FST.
# This might FAIL because FSTs must be sorted along dimension composed, and `input.txt` is not
# fstcompose input.fst model.fst comp.fst

# Compose with a previous arc sorting step:
# fstarcsort --sort_type=olabel input.fst input_sorted.fst
# fstarcsort --sort_type=ilabel model.fst model_sorted.fst
# fstcompose input_sorted.fst model_sorted.fst comp.fst

# Just keeps the output label
# fstproject --project_output comp.fst result.fst

# Do it all in a single command line.
fstarcsort --sort_type=ilabel model.fst | fstcompose input.fst - |\
  fstproject --project_output - result.fst
