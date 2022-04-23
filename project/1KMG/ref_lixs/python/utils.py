from __future__ import print_function
import sys
import re
import datetime
import os, hashlib, base64

#import logzero
#from logzero import logger

class InputStream(object):
    '''This class handles opening either stdin or a gzipped or non-gzipped file'''

    def __init__(self, string = None):
        '''Create a new wrapper around a stream'''
        #self.tempdir = tempdir
        if string in (None, '-', 'stdin') and self.valid(string):
            self.handle = sys.stdin
            return
        if string.startswith('gs:'):
            localpath = self.download_google_file(string)
            string = localpath
        if string.endswith('.gz'):
            import gzip
            self.handle = gzip.open(string, 'rb')
        else:
            self.handle = open(string, 'r')

    def __enter__(self):
        '''Support use of with by passing back the originating handle'''
        return self.handle

    def __exit__(self, *kwargs):
        '''Support use of with by closing on exit of the context'''
        self.handle.close()

    def __iter__(self):
        '''Support use in loops like a normal file object'''
        return self.handle.__iter__()

    def close(self):
        '''Close the underlying handle'''
        return self.handle.close()


class Bedpe(object):
    def __init__(self, bed_list):
        self.c1 = bed_list[0]
        self.s1 = int(bed_list[1])
        self.e1 = int(bed_list[2])
        self.c2 = bed_list[3]
        self.s2 = int(bed_list[4])
        self.e2 = int(bed_list[5])
        self.name = bed_list[6]
        self.score = bed_list[7]
        self.o1 = bed_list[8]
        self.o2 = bed_list[9]
    def checkBedpe(self):
        if self.c1 == self.c2: # if locate in same chr
            if self.s1 < self.s2: # determine order of exon
                if self.s2-self.s1 >= self.e1-self.s1: # non-overlap block 
                    return True
                else:
                    return False
            else:
                if self.s1-self.s2 >= self.e2 - self.s2: # non-overlap block
                    return True
                else:
                    return False

        else:
            return False

class BedpetoBlockedBedConverter(object):
    '''
    Class to convert Bedpe lines to BlockedBed (Bed12)
    '''

    def create_line(self, chrom, start, end, name, score, strand, color, size_tuple=None, start_tuple=None):
        '''
        Create a blockedBed line
        '''
        fields = [
            chrom,
            start,
            end,
            name,
            score,
            strand,
            start,
            end,
            color
            ]
        if size_tuple is not None and start_tuple is not None:
            fields += [
                    '2',
                    ','.join(map(str, size_tuple)),
                    ','.join(map(str,start_tuple))
            ]
        return '\t'.join(map(str,fields))


    def convert(self, bedpe):
        '''
        Convert Bedpe line to a Bed12 line
        '''
        #span = abs(bedpe.e2 - bedpe.s1)
        output_lines = list()
        if bedpe.s1 < bedpe.s2:
            output_lines.append(self.create_line(
                bedpe.c1,
                bedpe.s1,
                bedpe.e2,
                bedpe.name,
                bedpe.score,
                '.',
                "255,255,255",
                (bedpe.e1-bedpe.s1, bedpe.e2-bedpe.s2),
                (0, bedpe.s2 - bedpe.s1)))
        else:
            output_lines.append(self.create_line(
                bedpe.c1,
                bedpe.s2,
                bedpe.e1,
                bedpe.name,
                bedpe.score,
                '.',
                '255,255,255',
                (bedpe.e2 - bedpe.s2, bedpe.e1 - bedpe.s1),
                (0, bedpe.s1 - bedpe.s2)))
        return  output_lines

class exon2bed12(object):

    # Convert exon_dict to transcript anno in bed12 format 
    # Example:
    #  1. Input
    #   gene : gene1
    #   exon_dict: {'1': ['chr1', 100, 200, 100,'-'], '2': ['chr1', 300, 400, 100,'-'], '3': ['chr1', 500, 600, 100,'-'], '4': ['chr1', 700, 800, 100,'-']} (Have to be sorted by exon index)
    #              {exonIndex:[chr,start,end,length,strand]}
    #  2. Output
    #   chr1 100 800 gene1 1000 - 0,0,0 100 800 4 100,100,100,100 0,200,400,600

    def __init__(self,gene,exon_dict):
        self.c1 = exon_dict[next(iter(exon_dict))][0]
        self.s1 = exon_dict[next(iter(exon_dict))][1]
        self.e1 = exon_dict[list(exon_dict.keys())[-1]][2]
        self.name = gene
        self.score = 1000
        self.strand = exon_dict[next(iter(exon_dict))][4]
        self.ts = self.s1
        self.te = self.e1
        self.rgb = "0,0,0"
        self.count = len(exon_dict.keys())
        size = []
        relStart = []
        basepoint = self.s1
        for exonIndex,exonCoord in exon_dict.items():
          size.append(exonCoord[3])
          relStart.append(exonCoord[1] - basepoint)
        self.size = ','.join(str(s) for s in size)
        self.relStart = ','.join(str(rs) for rs in relStart)

