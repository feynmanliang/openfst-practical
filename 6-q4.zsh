#!/usr/bin/zsh

SYMBOLS=$DIR/table4.txt
source 0-source-me.zsh

#4. Given the alphabet L = {a, b, ...z,hspacei,.,,} (includes period and comma), for which a symbol
#table file can be found in $DIR/table4.txt:
#cat $SYMBOLS

#(a) Create a transducer that implements the rot13 cipher: a → n , b → o , ... , m → z , n → a
#, o → b , ... , z → m.
cat > rot13.txt <<EOF
0 0 a n
0 0 b o
0 0 c p
0 0 d q
0 0 e r
0 0 f s
0 0 g t
0 0 h u
0 0 i v
0 0 j w
0 0 k x
0 0 l y
0 0 m z
0 0 n a
0 0 o b
0 0 p c
0 0 q d
0 0 r e
0 0 s f
0 0 t g
0 0 u h
0 0 v i
0 0 w j
0 0 x k
0 0 y l
0 0 z m
0 0 <space> <space>
0 0 . .
0 0 , ,
0
EOF
compile_and_draw 'rot13'
#fstprint --isymbols=$SYMBOLS --osymbols=$SYMBOLS rot13.fst

#(b) Encode and decode the message ’my secret message’ (assume hspacei → hspacei,
#. → . and ,→,).
message="my secret message"
if [[ -e message.txt ]]; then
  rm message.txt
fi
for ((i=1; i <= ${#message}; i++)); do
  if [[ $message[i] == ' ' ]]; then
    echo $((i-1)) $i "<space>" "<space>" >> message.txt
  else
    echo $((i-1)) $i $message[i] $message[i] >> message.txt
  fi
done
echo $((i-1)) >> message.txt
# cat message.txt
compile_and_draw 'message'

print "Encode:"
fstcompose message.fst rot13.fst \
  > encode.fst
fstprint --isymbols=$SYMBOLS --osymbols=$SYMBOLS encode.fst

print "Decode:"
fstcompose encode.fst rot13.fst \
  > decode.fst
fstprint --isymbols=$SYMBOLS --osymbols=$SYMBOLS decode.fst


#(c) We wish to decipher the message that can be found in the file
#$DIR/4.encoded1.fst
#knowing that in order to do so, we must simultaneously allow two transductions, namely
#rot13 and rot16 (a → q , b → r , ...), so that a can either encode an original n or q. Build
#a suitable decoding transducer, apply it to the encoded message and examine the resulting
#FST (after projecting onto the output symbols). How many states and arcs does it contain?
#How many states and arcs after removing epsilons, determinizing and minimizing it? How
#many distinct strings does it represent?
cat > rot16.txt <<EOF
0 0 a q
0 0 b r
0 0 c s
0 0 d t
0 0 e u
0 0 f v
0 0 g w
0 0 h x
0 0 i y
0 0 j z
0 0 k a
0 0 l b
0 0 m c
0 0 n d
0 0 o e
0 0 p f
0 0 q g
0 0 r h
0 0 s i
0 0 t j
0 0 u k
0 0 v l
0 0 w m
0 0 x n
0 0 y o
0 0 z p
0 0 <space> <space>
0 0 . .
0 0 , ,
0
EOF
compile_and_draw 'rot16'

rot1316_decoder=$(fstunion rot13.fst rot16.fst \
  | fstclosure \
  | fstrmepsilon)
#fstprint --isymbols=$SYMBOLS --osymbols=$SYMBOLS <(echo $rot1316_decoder)

encoded=$DIR/4.encoded1.fst
fstcompose $encoded <(echo $rot1316_decoder) \
  | fstproject --project_output \
  > result.fst
printstrings.O2 --label-map=$SYMBOLS --input=$encoded -w 2> /dev/null

print "Before rmepsilon, determinize, minimize:"
fstinfo result.fst

print "After rmepsilon, determinize, minimize:"
fstrmepsilon result.fst | fstdeterminize | fstminimize - result2.fst
#printstrings.O2 --label-map=$SYMBOLS --input=result2.fst -n 10000 -w 2> /dev/null | wc -l
fstinfo result2.fst


#(d) We now know that the original text belongs to Charles Dickens’ David Copperfield novel.
#Accordingly, a language model has been implemented as an unweighted automaton that
#accepts any sentence contained in this novel. This can be found in
#$DIR/4.lm.fst
#Compose your resulting FST from question (c) with this language model. What was the
#original text?

LM=$DIR/4.lm.fst

fstcompose result2.fst $LM \
  > result_lm.fst
printstrings.O2 --label-map=$SYMBOLS --input=result_lm.fst -n 10 -w 2> /dev/null

# whether i shall turn out to be the hero of my own life or whether
# that station will be held by anybody else, these pages must show. to
# begin my life with the beginning of my life, i record that i was born as
# i have been informed and believe on a friday, at twelve oclock at night.
# it was remarked that the clock began to s trike and i began to cry,
# simultaneously.

# w h e t h e r <space> i <space> s h a l l <space> t u r n <space> o u t
# <space> t o <space> b e <space> t h e <space> h e r o <space> o f <space> m y
# <space> o w n <space> l i f e , <space> o r <space> w h e t h e r <space> t h
# a t <space> s t a t i o n <space> w i l l <space> b e <space> h e l d <space>
# b y <space> a n y b o d y <space> e l s e , <space> t h e s e <space> p a g e
# s <space> m u s t <space> s h o w . <space> t o <space> b e g i n <space> m y
# <space> l i f e <space> w i t h <space> t h e <space> b e g i n n i n g
# <space> o f <space> m y <space> l i f e , <space> i <space> r e c o r d
# <space> t h a t <space> i <space> w a s <space> b o r n <space> a s <space> i
# <space> h a v e <space> b e e n <space> i n f o r m e d <space> a n d <space>
# b e l i e v e <space> o n <space> a <space> f r i d a y , <space> a t <space>
# t w e l v e <space> o c l o c k <space> a t <space> n i g h t . <space> i t
# <space> w a s <space> r e m a r k e d <space> t h a t <space> t h e <space> c
# l o c k <space> b e g a n <space> t o <space> s t r i k e , <space> a n d
# <space> i <space> b e g a n <space> t o <space> c r y , <space> s i m u l t a
# n e o u s l y.


#(e) Similarly result2 a second text belonging to the same novel has been encoded in the file
#$DIR/4.encoded2.fst
#by applying the rot13 cipher and allowing some pairs of consecutive letters to be swapped
#(excluding hspacei or punctuation). Build a suitable decoding transducer2
#, apply it to
#the encoded message and compose your answer with the language model. What was the
#original text?

encoded=$DIR/4.encoded2.fst

python swap_letter_fst.py 'letter_swap'
compile_and_draw 'letter_swap'

#(cat letter_swap.fst) \
  #| fstprint --isymbols=$SYMBOLS --osymbols=$SYMBOLS

(cat $encoded) \
  | fstcompose -  rot13.fst \
  | fstcompose - <(fstclosure letter_swap.fst) \
  | fstproject --project_output \
  | fstrmepsilon result.fst | fstdeterminize | fstminimize - \
  | fstcompose - $LM \
  > result2_lm.fst
printstrings.O2 --label-map=$SYMBOLS --input=result2_lm.fst -n 10 -w 2> /dev/null

# w h e t h e r <space> i <space> s h a l l <space> t u r n <space> o u t
# <space> t o <space> b e <space> t h e <space> h e r o <space> o f <space> m y
# <space> o w n <space> l i f e , <space> o r <space> w h e t h e r <space> t h
# a t <space> s t a t i o n <space> w i l l <space> b e <space> h e l d <space>
# b y <space> a n y b o d y <space> e l s e , <space> t h e s e <space> p a g e
# s <space> m u s t <space> s h o w . <space> t o <space> b e g i n <space> m y
# <space> l i f e <space> w i t h <space> t h e <space> b e g i n n i n g
# <space> o f <space> m y <space> l i f e , <space> i <space> r e c o r d
# <space> t h a t <space> i <space> w a s <space> b o r n <space> a s <space> i
# <space> h a v e <space> b e e n <space> i n f o r m e d <space> a n d <space>
# b e l i e v e <space> o n <space> a <space> f r i d a y , <space> a t <space>
# t w e l v e <space> o c l o c k <space> a t <space> n i g h t . <space> i t
# <space> w a s <space> r e m a r k e d <space> t h a t <space> t h e <space> c
# l o c k <space> b e g a n <space> t o <space> s t r i k e , <space> a n d
# <space> i <space> b e g a n <space> t o <space> c r y , <space> s i m u l t a
# n e o u s l y .         0
