from utils import Bedpe
from utils import InputStream
from utils import BedpetoBlockedBedConverter
import sys
import argparse


def description():
   return 'convert a BEDPE file to BED12 format for viewing in IGV or the UCSC browser'


def epilog():
   return 'The input BEDPE file may be gzipped. If the input file is omitted then input is read from stdin. Output is written to     stdout.'


def add_arguments_to_parser(parser):
   parser.add_argument('-i', '--input', metavar='<BEDPE>', default=None, help='BEDPE input file')
   parser.add_argument('-o', '--output', metavar='<BED12>', type=argparse.FileType('w'), default=sys.stdout,
                       help='Output BED12 to write (default: stdout)')
   parser.set_defaults(entry_point=run_from_args)


def run_from_args(args):
   with InputStream(args.input) as stream:
      #outBed12 = open(args.output, 'w')
      processBEDPE(stream, args.output)
      # print(stream);
      # print(mu.add(1,1));


def processBEDPE(bed_stream, output_handle):
   converter = BedpetoBlockedBedConverter()
   for line in bed_stream:
      lineList = line.rstrip().split('\t')
      bedpe = Bedpe(lineList)
      if bedpe.checkBedpe() == True:
        output_handle.write('\n'.join(converter.convert(bedpe)) + '\n')


def command_parser():
   parser = argparse.ArgumentParser(description=description(), epilog=epilog())
   add_arguments_to_parser(parser)
   return parser


if __name__ == "__main__":
   '''
   converter = BedpetoBlockedBedConverter()
   with InputStream(string='testBed') as stream:
      for line in stream:
         lineList = line.rstrip().split(' ')
         bedpe = Bedpe(lineList)
         #print(bedpe.c1,bedpe.c2)
         print(converter.convert(bedpe))

         out = argparse.FileType('w')
         out.write('\n'.join(converter.convert(bedpe)) + '\n')
   '''

   parser = command_parser()
   args = parser.parse_args()
   sys.exit(args.entry_point(args))

