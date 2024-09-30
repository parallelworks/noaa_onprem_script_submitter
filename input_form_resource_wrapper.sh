#!/bin/bash
source load_env.sh
source resources/hosts/inputs.sh


if [ -z "${workflow_utils_branch}" ]; then
    # If empty, clone the main default branch
    git clone https://github.com/parallelworks/workflow-utils.git
else
    # If not empty, clone the specified branch
    git clone -b "$workflow_utils_branch" https://github.com/parallelworks/workflow-utils.git
fi

python workflow-utils/input_form_resource_wrapper.py

if [ $? -ne 0 ]; then
    echo "ERROR - Resource wrapper failed"
    exit 1
fi