#!/usr/bin/zsh

SYMBOLS=$DIR/table1.txt
source 0-source-me.zsh

# 1. Given the alphabet L = {a, b, ...z, A, B, ...Z,<space>}, for which a
# symbol table file can be  found in $SYMBOLS, create an automaton that:

# (a) Accepts a letter in L (including space).
if [[ -f 1a.txt ]]; then
  rm 1a.txt
fi

cat $SYMBOLS \
  | cut -d ' ' -f 1 \
  | sed '/<eps>/d' \
  | sed -r 's/.*/0 1 & &/' \
  > 1a.txt
echo 1 >> 1a.txt
compile_and_draw '1a'


# (b) Accepts a single space.
if [[ -f 1b.txt ]]; then
  rm 1b.txt
fi
cat > 1b.txt <<EOF
0 1 <space> <space>
1
EOF
compile_and_draw '1b'

# (c) Accepts a capitalized word (where a word is a string of letters in L
# excluding space and a capitalized word has its initial letter uppercase and
# remaining letters lowercase)
upper_fst=$((cat $SYMBOLS \
  | cut -d ' ' -f 1 \
  | sed '/^[A-Z]/!d' \
  | sed -r 's/.*/0 1 & &/' \
  ; echo '1') \
  | fstcompile --isymbols=$SYMBOLS --osymbols=$SYMBOLS -)
lower_star_fst=$((cat $SYMBOLS \
  | cut -d ' ' -f 1 \
  | sed '/^[a-z]/!d' \
  | sed -r 's/.*/1 2 & &/' \
  ; echo '2') \
  | fstcompile --isymbols=$SYMBOLS --osymbols=$SYMBOLS - \
  | fstclosure -)
fstconcat <(echo $upper_fst) <(echo $lower_star_fst) > 1c.fst
draw '1c'

# (d) Accepts a word containing the letter a
if [[ -f 1d.txt ]]; then
  rm 1d.txt
fi

word_fst=$(fstdifference 1a.fst 1b.fst \
  | fstclosure)
a_fst=$(echo '0 1 a a\n1' \
  | fstcompile --isymbols=$SYMBOLS --osymbols=$SYMBOLS -)
fstconcat <(echo $a_fst) <(echo $word_fst) \
  | fstconcat <(echo $word_fst) - \
  > 1d.fst
draw '1d'
