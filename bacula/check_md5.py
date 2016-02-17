#!/usr/bin/env python

import os
import re
import pprint
import base64
import argparse
from sqlalchemy.ext.automap import automap_base
from sqlalchemy.orm import Session, relationship, subqueryload, joinedload
from sqlalchemy import create_engine, ForeignKey, Column, Integer

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

    
engine = create_engine('postgresql://bacula_ro:bacula_ro@127.0.0.1/bacula')
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
    tape_dict[os.path.join(path,filename)]=file

split_md5_re = re.compile(r'([a-f0-9]+)\s+(\./.*)$')

for md5sumfile in args.md5sumfiles:
  archive_path = md5sumfile.split('/')
  subvol_path = archive_path[0]
  with open(md5sumfile) as f:
    for line in f:
        line=line.rstrip()
        line_match=split_md5_re.match(line)
        md5=line_match.group(1).decode('hex')
        md5_base64=base64.encodestring(md5).rstrip().rstrip('=')
        filepath=line_match.group(2).split('/')
        #filenames=FileNameSession.filter(FileName.name==filepath[-1]).all()
        path_like = '/ohri/archive/tapes/%s/%s/%s' % (args.tape, subvol_path, '/'.join(filepath[1:]))
        try:
            file=tape_dict[path_like]
        except KeyError: 
            print "path_like: %s" % path_like
        if file.md5 != md5_base64 and filepath[-2] != '.archive-metadata':
                print "path_like: %s" % path_like
                print "archive: %s %s  " % (line_match.group(2), line_match.group(1))
                print "line: %s : %s " % (file.md5, md5_base64)
                print "file: %s name: %s path: %s " % (file.fileid, file.filenameid, file.pathid)
                print "path: bacula: %s %s archive: %s " % (file.path.path, file.filename.name, line_match.group(2))
   
exit(0)
 
print "file:"

pp.pprint(File1.files)

first10=File1.files.limit(10)
for file in first10:
    pp.pprint(file.__dict__)
