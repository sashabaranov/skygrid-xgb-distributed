#!/bin/bash
consumer=$(curl localhost:8500/v1/catalog/nodes | grep "node2" | awk 'BEGIN { FS = "[\[{:,}\]\"]+" } { print $5 }')
echo will send to $consumer
echo hello | nc $consumer 1027
echo send hello