#!/usr/bin/zsh

SYMBOLS=$DIR/table1.txt
source 0-source-me.zsh

# 2. Using the automata in Question 1 as the building blocks, use appropriate
# FST operations on them to create an automaton that: For each case, give the
# number of states and arcs before and after applying epsilon removal,
# determinization and minimization to the resulting automata.

# (a) Accepts zero or more capitalized words followed by spaces.
fstclosure --closure_plus 1b.fst \
  | fstconcat 1c.fst - \
  | fstclosure - \
  > 2a.fst
draw '2a'

# (b) Accepts a word beginning or ending in a capitalized letter.
fstreverse 1c.fst \
  | fstunion 1c.fst - \
  > 2b.fst
draw '2b'

# (c) Accepts a word that is capitalized and contains the letter a.
fstintersect 1c.fst 1d.fst \
  > 2c.fst
draw '2c'

# (d) Accepts a word that is capitalized or does not contain an a.
word_fst=$(fstdifference 1a.fst 1b.fst \
  | fstclosure \
  | fstrmepsilon \
  | fstdeterminize \
  | fstminimize)
a_fst=$(cat 1d.fst \
  | fstrmepsilon \
  | fstdeterminize \
  | fstminimize)
no_a_fst=$(fstdifference <(echo $word_fst) <(echo $a_fst))
fstunion 1c.fst <(echo $no_a_fst) \
  > 2d.fst
draw '2d'

# (e) Accepts a word that is capitalized or does not contain an a without using fstunion.
cap_fst=$(cat 1c.fst \
  | fstrmepsilon \
  | fstdeterminize \
  | fstminimize)
not_cap_fst=$(fstdifference <(echo $word_fst) <(echo $cap_fst))
# de-morgan's law, cap OR no_a <=> NOT ((NOT cap) AND a)
fstintersect <(echo $not_cap_fst) <(echo $a_fst) \
  | fstdifference <(echo $word_fst) - \
  > 2e.fst
draw '2e'
