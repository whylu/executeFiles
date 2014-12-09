
Configuration:
-------------
Go to executeFiles folder

edit "executeFile.sh" file

set the first line to the path you want to monitor

let executeFile.sh be executable
>chmod +x executeFile.sh

Run:
----
>./executeFile.sh

Stop:
----
pid of process is in ./pid_running folder

Kill the process and clear the pid folder
> kill -TERM $(ls pid_running) && rm -f pid_running/*


Working
-------------------------
to be continue...
