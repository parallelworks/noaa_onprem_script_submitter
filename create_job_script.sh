#!/bin/bash
source load_env.sh
source resources/host/inputs.sh

echo; echo; echo "CREATING JOB SCRIPT"
echo "Path: ${PWD}/job_script"
echo ${script_shebang} > job_script
chmod +x job_script

if [[ ${jobschedulertype} == "SLURM" ]]; then
    cat resources/host/batch_header.sh | grep SBATCH >> job_script
fi
jq -r '.script.text' inputs.json | sed 's/\\n/\n/g' >> job_script