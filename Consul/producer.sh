#!/bin/bash
consumer="$(ifconfig eth0 | awk -F ' *|:' '/inet addr/{print $4}')"
echo will send to $consumer
echo send hello