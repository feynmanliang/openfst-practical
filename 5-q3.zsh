#!/usr/bin/zsh

SYMBOLS=$DIR/table3.txt
source 0-source-me.zsh

# 3. Given the alphabet L = {0, 1, ...9}, create a transducer that maps numbers (in the range 00000
# to 99999) represented as strings of 5 digits to their English read form, e.g.
# 0 0 0 0 1 → one
# 0 0 8 0 7 → eight hundred seven
# 1 3 2 5 5 → thirteen thousand two hundred fifty five
# A complete symbol table file has already been created for you in $DIR/table3.txt. Please
# try to define basic transducers as building blocks and use as many FST operations as possible
# to create the final transducer.

cat > nonzero.txt <<EOF
0 1 1 one
0 1 2 two
0 1 3 three
0 1 4 four
0 1 5 five
0 1 6 six
0 1 7 seven
0 1 8 eight
0 1 9 nine
1
EOF
compile_and_draw 'nonzero'

cat > zero.txt <<EOF
0 1 0 <eps>
1
EOF
compile_and_draw 'zero'

fstunion zero.fst nonzero.fst digits.fst

cat > teens1.txt <<EOF
0 1 1 <eps>
1
EOF
compile_and_draw 'teens1'

cat > teens2.txt <<EOF
0 1 0 ten
0 1 1 eleven
0 1 2 twelve
0 1 3 thirteen
0 1 4 fourteen
0 1 5 fifteen
0 1 6 sixteen
0 1 7 seventeen
0 1 8 eighteen
0 1 9 nineteen
1
EOF
compile_and_draw 'teens2'

fstconcat teens1.fst teens2.fst \
  > teens.fst

cat > tens1.txt <<EOF
0 1 2 twenty
0 1 3 thirty
0 1 4 forty
0 1 5 fifty
0 1 6 sixty
0 1 7 seventy
0 1 8 eighty
0 1 9 ninety
1
EOF
compile_and_draw 'tens1'

fstconcat tens1.fst digits.fst \
  > tens.fst

# recognizes all two consecutive digits except 00
pair_nonzero_fst=$(fstunion \
  teens.fst \
  <(fstconcat zero.fst nonzero.fst) \
  | fstunion - tens.fst)
# recognizes 00
pair_zero_fst=$(fstconcat zero.fst zero.fst)

cat > append_thousand.txt <<EOF
0 1 <eps> thousand
1
EOF
compile_and_draw 'append_thousand'

# only append 'thousand' if nonzero
fstconcat <(echo $pair_nonzero_fst) <(cat append_thousand.fst) \
  | fstunion - <(echo $pair_zero_fst) \
  > thousand.fst

cat > append_hundred.txt <<EOF
0 1 <eps> hundred
1
EOF
compile_and_draw 'append_hundred'

# only append 'hundred' if nonzero
fstconcat nonzero.fst append_hundred.fst \
  | fstunion - zero.fst \
  > hundred.fst

(echo $pair_nonzero_fst) \
  > ten.fst

cat > zero_explicit.txt <<EOF
0 1 0 zero
1
EOF
compile_and_draw 'zero_explicit'
fstconcat zero.fst zero.fst \
  | fstconcat - zero.fst \
  | fstconcat - zero.fst \
  | fstconcat - zero_explicit.fst \
  > all_zero.fst

input_fst=$(printf "%s\n" \
  "0 1 1 1"\
  "1 2 0 0"\
  "2 3 3 3"\
  "3 4 2 2"\
  "4 5 0 0"\
  "5" \
  | fstcompile --isymbols=$SYMBOLS --osymbols=$SYMBOLS -)

model_fst=$(fstconcat thousand.fst hundred.fst \
  | fstconcat - ten.fst \
  | fstunion - all_zero.fst)

result_fst=$(fstcompose <(echo $input_fst) <(echo $model_fst) \
  | fstproject --project_output)

print "Input:"
fstprint --isymbols=$SYMBOLS --osymbols=$SYMBOLS <(echo $input_fst)
print "Model:"
fstprint --isymbols=$SYMBOLS --osymbols=$SYMBOLS <(echo $model_fst)
print "Result:"
fstprint --isymbols=$SYMBOLS --osymbols=$SYMBOLS <(echo $result_fst)
