#!/bin/bash
source load_env.sh
source resources/hosts/inputs.sh

echo; echo; echo "TRANSFER JOB SCRIPT TO CLUSTER"
${sshcmd} "mkdir -p ${resource_jobdir}"
scp job_script ${resource_publicIp}:${resource_jobdir}/job_script