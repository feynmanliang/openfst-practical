#!/usr/bin/python

def make_fst(fstName):
    with open(fstName + '.txt', 'w') as f:
        f.write("""0 99 <space> <space>
0 99 . .
0 99 , ,
""")
        for i,c in enumerate([chr(k) for k in range(ord('a'), ord('z')+1)]):
            f.write("0 {0} {1} {1}\n".format(99, c)) # pass-through
            f.write("0 {0} {1} <eps>\n".format(i+1, c)) # swap
            for d in [chr(k) for k in range(ord('a'), ord('z')+1)]:
                f.write("{0} {1} {2} {3}\n".format(i+1, i+100, d, d))
                f.write(" {0} 99 <eps> {1}\n".format(i+100, c))
        f.write("99\n")

if __name__ == "__main__":
    import argparse

    parser = argparse.ArgumentParser(description='Generate FST description for swapping letters')
    parser.add_argument('fstName', metavar='N', type=str,
                               help='name of the .txt file to output')
    args = parser.parse_args()
    make_fst(args.fstName)
