#!/bin/bash

# This script runs the kart_project on the RaspberryPi.
# Should be located under '/home/pi'.

counter=0 # Counter how often flutter-pi failed to run.
while [ $counter -lt 10 ]; do
    sudo /home/pi/flutter-pi/build/flutter-pi /home/pi/projects/kart_project | tee /home/pi/logs/log.txt-$(date +"%Y-%m-%d-%T")
    echo "KartProject will be restarted in 3 seconds..."
    sleep 3s
    counter=$(expr $counter + 1)
done

echo "Unable to start the KartProject correctly. The Raspberry will be shutdown in 5 seconds..."
sleep 5s
sudo poweroff
