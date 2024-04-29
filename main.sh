#!/bin/bash
source /etc/profile.d/parallelworks.sh
source /etc/profile.d/parallelworks-env.sh
source /pw/.miniconda3/etc/profile.d/conda.sh
conda activate

source inputs.sh

if [ -z "${workflow_utils_branch}" ]; then
    # If empty, clone the main default branch
    git clone https://github.com/parallelworks/workflow-utils.git
else
    # If not empty, clone the specified branch
    git clone -b "$workflow_utils_branch" https://github.com/parallelworks/workflow-utils.git
fi

source workflow-utils/workflow-libs.sh

python workflow-utils/input_form_resource_wrapper.py

if [ $? -ne 0 ]; then
    echo "ERROR - Resource wrapper failed"
    exit 1
fi

source resources/host/inputs.sh
export sshcmd="ssh  -o StrictHostKeyChecking=no ${resource_publicIp}"

echo; echo; echo "CREATING JOB SCRIPT"
echo "Path: ${PWD}/job_script"
echo ${script_shebang} > job_script
chmod +x job_script

if [[ ${jobschedulertype} == "SLURM" ]]; then
    cat resources/host/batch_header.sh | grep SBATCH >> job_script
fi
jq -r '.script.text' inputs.json | sed 's/\\n/\n/g' >> job_script

echo; echo; echo "TRANSFER JOB SCRIPT TO CLUSTER"
${sshcmd} "mkdir -p ${resource_jobdir}"
scp job_script ${resource_publicIp}:${resource_jobdir}/job_script


if [[ ${jobschedulertype} == "SLURM" ]]; then
    echo; echo; echo "SUBMITTING SLURM JOB"
    job_submit_cmd="${sshcmd} ${submit_cmd} ${resource_jobdir}/job_script"
    echo "${job_submit_cmd}"
    export jobid=$(${job_submit_cmd} | tail -1 | awk -F ' ' '{print $4}')

    if [[ -z ${jobid} ]]; then
        echo; echo;
        echo "Failed to submit job to the scheduler with command:"
        echo "${job_submit_cmd}"
        echo; echo "Exiting workflow."
        exit 1
    fi

    if [[ ${script_wait} == "true" ]]; then
        echo "${sshcmd} ${cancel_cmd} ${jobid}" >> cancel.sh
        wait_job

        ${sshcmd} "sacct -j ${jobid}" 
        if ${sshcmd} "sacct -j ${jobid} --format=State" | grep -q "FAILED"; then
            exit 1
        else
            exit 0
        fi
    fi
else
    echo; echo; echo "EXECUTING JOB ON SCHEDULER NODE"
    echo "${sshcmd} ${resource_jobdir}/job_script"
    ${sshcmd} ${resource_jobdir}/job_script
fi
