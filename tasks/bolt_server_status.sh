#!/bin/bash

number_bolt_processes_running=$(ps -ef | grep "ruby.*bolt plan run" | grep -v grep | wc -l);
free_memory=$(free -m -w | xargs | awk '{print"[{\"type\": \"RAM\",\""$1"\": "$9",\""$2"\": "$10",\""$3"\": "$11",\""$4"\": "$12",\""$5"\": "$13",\""$6"\": "$14",\""$7"\": "$15"},{\"type\": \"Swap\",\""$1"\": "$17",\""$2"\": "$18",\""$3"\": "$19"}]"}')

printf '{"number_bolt_processes":"%s","free_memory":"%s"}' "$number_bolt_processes_running" "$free_memory"