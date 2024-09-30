#!/bin/bash

# Define a cleanup function
cleanup() {
    ./cancel.sh 2>&1 | tee clean_and_exit.out
}

# Set the trap to call cleanup on script exit
trap cleanup EXIT

./input_form_resource_wrapper.sh 2>&1 | tee input_form_resource_wrapper.out || exit 1
./create_job_script.sh 2>&1 | tee create_job_script.out || exit 1
./transfer_job_script.sh 2>&1 | tee transfer_job_script.out || exit 1
./submit_job_and_wait.sh 2>&1 | tee submit_job_and_wait.out || exit 1
