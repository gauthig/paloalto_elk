#!/bin/bash 
#paloalto_elk-objects.sh
# Install paloalto log objects into ELK 7.8
#
# Assumptions
#   Must be ran as sudo 
#   
#   ELK 7.8 is fully installed and running
#   logstash pipeline configuration is isntalled at
#       /etc/logstash/conf.d
#   No existing objects with prefix of panos- are in your ELK instance, this will overwite them
#   If running as an upgrade to the paloalto_elk library, it will overwrite your customizations
#      if you did noit rename the objects withour the panos- prefix
#
#
# Optimization Considerations
#   Defaults to installing on single node with 1 shard which is good performacne for 
#   a couple of PAN devices.  If you have a larger environment or other busy logs
#   in your ELK environment, think about changing the number of shards in the panos-template.json file
#   or update it later in the index management screen
#
# 8/4/2020 gauthig - Add index template import
# 7/23/2020 gauthig - initial saved object load

echo "Stopping logstash service"
systemctl stop logstash
echo "logstash stopped"
echo "/n"
echo "Copy pan-os.conf to /etc/logstash/conf.d"
cp elk-pipeline/pan-os.conf /etc/logstash/conf.d/pan-os.conf
echo "/n"
echo "Importing index template"
curl -XPUT http://localhost:9200/_template/panos-template?pretty -H 'Content-Type: application/json' -d @elk-pipeline/panos-template.json
echo "/n"
echo "Importing all saved objects (indexes, visualizations, dashboards)"
curl -X POST localhost:5601/api/saved_objects/_import?overwrite=true -H 'kbn-xsrf: true' --form 'file=@import/panos-objects.ndjson' -H 'kbn-xsrf: true'
echo "/n"
echo "Starting logstash"
systemctl start logstash
echo "*****"
echo "paloalto_elk installed on local ELK instance"

