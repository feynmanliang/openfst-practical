#!/usr/bin/zsh

SYMBOLS=$DIR/table1.txt
source 0-source-me.zsh

# Minimize the Q1 FSTs
for fst in '1a' '1b' '1c' '1d'; do
  epsdetmin $fst
done

# 2. Using the automata in Question 1 as the building blocks, use appropriate
# FST operations on them to create an automaton that: For each case, give the
# number of states and arcs before and after applying epsilon removal,
# determinization and minimization to the resulting automata.

# (a) Accepts zero or more capitalized words followed by spaces.
fstclosure --closure_plus 1b.min.fst \
  | fstconcat 1c.min.fst - \
  | fstclosure - \
  > 2a.fst
epsdetmin '2a'
draw '2a'

# (b) Accepts a word beginning or ending in a capitalized letter.
fstreverse 1c.min.fst \
  | fstunion 1c.min.fst - \
  > 2b.fst
epsdetmin '2b'
draw '2b'

# (c) Accepts a word that is capitalized and contains the letter a.
fstintersect 1c.min.fst 1d.min.fst \
  > 2c.fst
epsdetmin '2c'
draw '2c'

# (d) Accepts a word that is capitalized or does not contain an a.
word_fst=$(fstdifference 1a.min.fst 1b.min.fst \
  | fstclosure)
no_a_fst=$(fstdifference <(echo $word_fst) 1d.min.fst)
fstunion 1c.min.fst <(echo $no_a_fst) \
  > 2d.fst
epsdetmin '2d'
draw '2d'

# (e) Accepts a word that is capitalized or does not contain an a without using fstunion.
# de-morgan's law, cap OR no_a <=> NOT ((NOT cap) AND a)
not_cap_fst=$(fstdifference <(echo $word_fst) 1c.min.fst)
fstintersect <(echo $not_cap_fst) 1d.min.fst \
  | fstrmepsilon \
  | fstdeterminize \
  | fstdifference <(echo $word_fst) - \
  > 2e.fst
epsdetmin '2e'
draw '2e'
