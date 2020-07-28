#!/bin/sh
#------------------------------------------------------------------------------
# script name: cert_csr.sh
#
#

#------------------------------------------------------------------------------
# Usage Functions
#------------------------------------------------------------------------------
usage (){
  echo "USAGE: cert_csr.sh -e <PRD|UAT> -n <Common Name>"
  exit 1
}

#+--------------------------------------------------------------------------+
#| checkerr:                                                                |
#| This function will check the return code and abort the script if the rc  |
#| is non zero.                                                             |
#+--------------------------------------------------------------------------+
checkerr()  {
  if [ $? -ne 0 ]; then
    echo "Error on scripts"
    exit 1
  fi
}

#------------------------------------------------------------------------------
# VARIABLE DEFINE AND PARAMETER RETRIEVE
#------------------------------------------------------------------------------

BINDIR=`dirname $0`
if [[ $BINDIR = "." ]]
then
  BINDIR=`pwd`
fi
LOGDIR=`echo $BINDIR | sed s/bin$/log/g`
TIMESTAMP=`date +%Y%m%d-%H%M`
CSRDIR=$BINDIR

ENV=
CN=

# read the options
optstr=`getopt -o e:,n: -n 'test.sh' -- "$@"`
eval set -- "$optstr"

# extract options and their arguments into variables.
while true ; do
    case "$1" in
        -e)            ENV=$2; shift 2 ;;
        -n)            CN=$2; shift 2 ;;
        --)            shift; break ;;
        *) usage ;;
    esac
done


if [ -z ${ENV} ]
then
  echo "Environment not set - aborting"
  usage
else
  if [ ${ENV} != "PRD" -a ${ENV} != "UAT" ]
  then
    usage
  fi
fi
if [ -z ${CN} ]
then
  echo "Common Name not set - aborting"
  usage
fi

#------------------------------------------------------------------------------
# Main
#------------------------------------------------------------------------------
# Send all stdout and stderr to the logfile

#echo ENV=$ENV
#echo CN=$CN
#echo BINDIR=$BINDIR

REQDIR=$BINDIR/${ENV}/req
CSRDIR=$BINDIR/${ENV}/csr
KEYDIR=$BINDIR/${ENV}/keys

REQFN=${CN}.req
CSRFN=${CN}.csr
KEYFN=${CN}.key

if [ ! -r ${REQDIR}/${REQFN} ]
then
  echo "Request Configuration file does not exist or readable: ${REQDIR}/${REQFN}"
  exit 2
fi

if [ -f ${KEYDIR}/${KEYFN} ]
then
  echo "Key file already exist: ${KEYDIR}/${KEYFN}"
  exit 2
fi

openssl req -nodes -new -out ${CSRDIR}/${CSRFN} -keyout ${KEYDIR}/${KEYFN} -config ${REQDIR}/${REQFN}
checkerr

if [ -f ${CSRDIR}/${CSRFN} ]
then
  echo "CSR file is created successfully: ${CSRDIR}/${CSRFN}"
  echo ""
  echo ""
  openssl req -in ${CSRDIR}/${CSRFN} -noout -text
  exit 0
fi


exit 2
