
# On-Prem Script Submitter
The workflow submits a specified script to a chosen On-Prem cluster resource either through SSH for execution in the controller node or for submission to a SLURM partition.

For the **SLURM partition**, the input form provides various SLURM directives which are automatically translated into a SLURM header. This header is then used to construct the job script, comprising the user's specified shebang, SLURM SBATCH directives from the form, and the user's script. Additional SLURM directives may exist at the top of the user's script, and more directives can be exposed in the input form upon request.

Regarding SLURM job execution, users have the option to either wait for completion or proceed without waiting. If waiting is chosen:
- The PW job actively monitors the SLURM job's status.
- Cancellation of the PW job also cancels the SLURM job.
- If the SLURM job fails, the PW job's status reflects an error.

For execution on the **controller**, the job script is created by adding the user's shebang to their script and then submitted via SSH. The PW job's status aligns with the script's exit status.