#!/bin/bash
source resources/host/inputs.sh
source load_env.sh

echo; echo; echo "TRANSFER JOB SCRIPT TO CLUSTER"
set -x
rsync -e "${sshcmd}" --rsync-path="mkdir -p ${resource_jobdir} && rsync" job_script ${resource_publicIp}:${resource_jobdir}/job_script
