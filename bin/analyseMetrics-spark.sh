#!/bin/bash

# Analyse logs and output the workload type and the analysis result.
# So input of workload type is needed.

# Workload type consists of: TODO


function usage() {
	echo "analyseLogs-spark.sh [metric_type]"
}

if [ $# -lt 1 ]; then
	usage
	exit
fi

this="${BASH_SOURCE-$0}"
thisdir=$(cd -P -- "$(dirname -- "$this")" && pwd -P)
thisdir=`readlink -f $thisdir`

# user settings
SPARK_MASTER="http://centos1:8080"
USER=zc
METRICS_OUTDIR=$thisdir/../result/analyseResult
mkdir -p METRICS_OUTDIR
#

METRICS_TYPE=$1

SOURCELOG=$thisdir/../result/sparkMetrics_zc

OUTPUTFILE=result_${METRICS_TYPE}

OPTS="${SPARK_MASTER} ${SOURCELOG}"

if [ ! -d ${METRICS_OUTDIR} ]; then
	mkdir ${METRICS_OUTDIR}
fi

java -Xmx512m -classpath $thisdir/../lib/scala.jar MetricResolver $OPTS > ${METRICS_OUTDIR}/$OUTPUTFILE
