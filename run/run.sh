#!/bin/bash

## This script runs the kart_project on the RaspberryPi.

# Counter how often flutter-pi failed to run.
counter=0
while [ $counter -lt 10 ]
do
    sudo ~/sdks/flutter-pi/out/flutter-pi ~/projects/kart_project | tee ~/logs/log.txt-$(date +"%Y-%m-%d-%T")
    echo "KartProject will be restarted in 3 seconds..."
    sleep 3s
    counter=`expr $counter + 1`
done

echo "Unable to start the KartProject correctly. The Raspberry will be shutdown in 5 seconds..."
sleep 5s
sudo poweroff