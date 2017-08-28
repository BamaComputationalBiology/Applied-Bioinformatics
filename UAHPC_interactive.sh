# UAHPC interactive session

# --qos = quality of service, here jlfierst
# -p    = partition, here owners
# -t    = wall clock, here two hours **note that the wall clock is computed against threads*time so a 4 core job given two hours will kill itself after 30 mins
# -n    = number of tasks
# --pty = which shell you want, here bash

srun --qos jlfierst -p owners -t 02:00:00 -n 1 --pty bash -l
