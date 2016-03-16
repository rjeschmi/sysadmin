#!/usr/bin/env python

import os
import sys
import re
import codecs
import pprint
import base64
import argparse
from sqlalchemy.ext.automap import automap_base
from sqlalchemy.orm import Session, relationship, subqueryload, joinedload
from sqlalchemy import create_engine, ForeignKey, Column, Integer

DEBUG = False

pp = pprint.PrettyPrinter(indent=4)

Base = automap_base()

class Job(Base):
    __tablename__ = 'job'

    files = relationship("File", backref="job_ref", lazy="joined" )

class File(Base):
    __tablename__ = 'file'

    jobid = Column(ForeignKey("job.jobid"))
    filenameid = Column(ForeignKey("filename.filenameid"))
    pathid = Column(ForeignKey("path.pathid"))

    filename = relationship("FileName", back_populates="files", lazy="joined")
    path = relationship("Path", back_populates="files", lazy="joined")
    job = relationship("Job", lazy="joined")

class FileName(Base):
    __tablename__ = 'filename'
    
    filenameid = Column(Integer, primary_key=True)
    files = relationship("File", back_populates="filename")
    

class Path(Base):
    __tablename__ = 'path'

    pathid = Column(Integer, primary_key=True)
    files = relationship("File", back_populates="path")

    
engine = create_engine('postgresql://bacula_ro:bacula_ro@127.0.0.1/bacula',client_encoding='utf8')
Base.prepare(engine, reflect=True)


parser = argparse.ArgumentParser(description='Compare md5sum output to bacula database')
parser.add_argument('--tape', dest='tape', help='the tape number (1001-2000 for now)')
parser.add_argument('md5sumfiles', nargs="+", help='the input file to compare')
args = parser.parse_args()

session = Session(engine)


TapeJob = session.query(Job).filter(Job.name=='Tape-%s' % args.tape)
FileNameSession=session.query(File).\
            join(Path).\
            join(FileName).\
            join(Job).\
            filter(Job.name=='Tape-%s' % args.tape)

tape_files=FileNameSession.all()
tape_dict={}
for file in tape_files:
    path=file.path.path
    filename=file.filename.name
    try:
        if DEBUG:
            print u"fileid: {0} filename: {1}".format(file.fileid, filename).encode('utf-8')
    except UnicodeEncodeError:
        sys.stderr.write("fileid: {0}\n".format(file.fileid))
        if isinstance(filename, unicode):
            sys.stderr.write("the filename is unicode\n")
        else:
            sys.stderr.write("the filename is not unicode\n")

    tape_dict[os.path.join(path,filename)]=file

split_md5_re = re.compile(r'([a-f0-9]+)\s+(\./.*)$')
good_md5 = 0

for md5sumfile in args.md5sumfiles:
  archive_path = md5sumfile.split('/')
  subvol_path = archive_path[0]
  with codecs.open(md5sumfile, encoding='utf-8') as f:
    for line in f:
        line=line.rstrip()
        line_match=split_md5_re.match(line)
        if line_match is None:
            print "line doesn't match: %s" % line
            continue
        md5=line_match.group(1).decode('hex')
        md5_base64=base64.encodestring(md5).rstrip().rstrip('=')
        filepath=line_match.group(2).split('/')
        path_like = '/ohri/archive/tapes/%s/%s/%s' % (args.tape, subvol_path, '/'.join(filepath[1:]))
        try:
            file=tape_dict[path_like]
        except KeyError: 
            print "not in DB path_like: %s" % path_like
            continue
        if file.md5 != md5_base64 and filepath[-2] != '.archive-metadata':
                try:
                    print "archive: %s %s  " % (line_match.group(2), line_match.group(1))
                    print "line: %s : %s " % (file.md5, md5_base64)
                    print "file: %s name: %s path: %s " % (file.fileid, file.filenameid, file.pathid)
                    print "path: bacula: %s %s archive: %s " % (file.path.path, file.filename.name, line_match.group(2))
                except UnicodeDecodeError:
                    print "caught a unicode error"
                    print "file: %s name: %s path: %s " % (file.fileid, file.filenameid, file.pathid)
                    
        else:
            good_md5 = good_md5+1



print "found %s good md5s in tape %s" % (good_md5, args.tape)
