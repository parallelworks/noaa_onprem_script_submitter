#!/bin/bash
source load_env.sh
source resources/hosts/inputs.sh

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
        log_file_paths=$(${sshcmd} scontrol show job ${jobid} | grep -E "StdOut|StdErr" | awk -F= '{print $2}' | uniq)
        wait_job

        print_slurm_logs "${log_file_paths}"
        echo; echo

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