#!/bin/bash

#$ -q centos6.q
#$ -j y

ml load Python

supervisord -n 
