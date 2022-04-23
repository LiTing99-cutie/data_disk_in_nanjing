import argparse
import sys
import os
import logzero
import utils
from utils import InputStream
from utils import exon2bed12

def description():
    return("Convert exon annotation in BED+ (bed + transcriptName, exonIndex) to transcript annotation in BED12 format." + '\n' + 
    "NOTE: this script need python version >=3.6.")

def epilog():
    return 'The input BEDPE file may be gzipped. If the input file is omitted then input is read from stdin. Output is written to  stdout.'


def add_arguments_to_parser(parser):
    parser.add_argument('-i', '--input', metavar='<BED+>', default=None, help='Exon BED+ input file (BED + transcriptName, exonIndex)')
    parser.add_argument('-o', '--output', metavar='<BED12>', type=argparse.FileType('w'), default=sys.stdout,
                       help='Output Transcript BED12 to write (default: stdout)')
    parser.set_defaults(entry_point=run_from_args)

def command_parser():
    parser = argparse.ArgumentParser(description=description(), epilog=epilog())
    add_arguments_to_parser(parser)
    return parser

def run_from_args(args):
    result = {}
    # Read in exon into dictionary
    with InputStream(args.input) as exon:
        for line in exon:
            lineLst = line.rstrip().split('\t')
            if lineLst[6] in result.keys():
                result[lineLst[6]].update({lineLst[7]: [lineLst[0], int(lineLst[1]), int(lineLst[2]),
                                                       int(lineLst[2]) - int(lineLst[1]), lineLst[5]]})
            else:
                result[lineLst[6]] = {lineLst[7]: [lineLst[0], int(lineLst[1]), int(lineLst[2]), int(lineLst[2]) - int(lineLst[1]),lineLst[5]]}
    # Convert to transcript annotation in bed12 format
    for gene,exon in result.items():
        exon_int = {int(k):v for k,v in exon.items()}
        cdna = exon2bed12(gene, dict(sorted(exon_int.items()))) # this command needs python version >=3.6
        l = [
            cdna.c1, cdna.s1, cdna.e1, cdna.name, cdna.score, cdna.strand, cdna.ts, cdna.te, cdna.rgb,cdna.count,cdna.size,cdna.relStart
        ]
        args.output.write('\t'.join([str(x) for x in l]) + '\n')
        #print(dict(sorted(exon_int.items())))

if __name__ == "__main__":
   parser = command_parser()
   args = parser.parse_args()
   sys.exit(args.entry_point(args))
