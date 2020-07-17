Palo Alto Networks PAN-OS v9.1+ Elastic Stack v7.x Configuration

There are several Palo Alto projects for ELK but most seem to be vacated with no updates in the past year.  Also could not find any with PAN-OS 9.1+ expaned logs (SD-Wan).


## Background

Update existing projects to CIM and PAN 9.1
Initial Updates to early projects:
-Added 10 new fields for traffic logs that started with PAN-OS 9.1
     Rule UUID, HTTP/2 Connection, Link Change Count, Policy ID, Link Switches, SD-WAN Cluster, SD-WAN Device Type, SD-WAN Cluster Type, SD-WAN Site, Dynamic User Group Name
     Most will be blank or zero except for Rule UUID unless you use adavcne features of the PA
-Changed attribute names from the default PA field names to Common Information Model (CIM) where applicable.  
     Allow you to import CIM Traffic and Threat visualitzations
-Added DNS filter to provide hostnames noit just the IP

Dashbaord and Visualizations are included  


****************************************************************************************************************************************  
Credit and Contributions

 I have found several older OpenSource GitHub projects on Palo Alto to Elk setups and whish to thank the following early developers.  
 shadow-box - (https://github.com/shadow-box/Palo-Alto-Networks-ELK-Stack)
 sm-biz - (https://github.com/sm-biz/paloalto-elasticstack-viz)


****************************************************************************************************************************************  



## Tutorial

This project was built on Ubuntu 20.04, and adding the ELK repositories so that the ELK stack stays current.  Instrcutions are provided for this OS base + ELK setup.


For those unfamilar with any part of this technology stack, I have created a full tutorial on installing & configuring Elastic Stack, including security the platform & installing the visualisations. :blue_book: The tutorial is [available here](https://github.com/sm-biz/paloalto-elasticstack-viz/wiki)

## Existing Install

Otherwise, if you're comfortable with the technology stack mentioned above, then all you need to do is;

- Download the files from this repo
  - PAN-OS.conf
  - traffic_template_mapping-v1.json
  - threat_template_mapping-v1.json
  - searches-base.json
  - visualisations-base.json
  - dashboards-base.json

- Install Elastic Stack 6.1
  - ElasticSearch
  - Kibana
  - LogStash
- Edit 'PAN-OS.conf'
  - **Set your timezone correctly** *(Very important)*
  - Copy the file into your **conf** directory. For Ubuntu/Debian this is "/etc/logstash/conf.d/", other directories are [available here](https://www.elastic.co/guide/en/logstash/current/dir-layout.html)

- Upload the two pre-built index templates with additional GeoIP fields
```
curl -XPUT http://<your-elasticsearch-server>:9200/_template/panos-traffic?pretty -H 'Content-Type: application/json' -d @traffic_template_mapping-v1.json
curl -XPUT http://<your-elasticsearch-server>:9200/_template/panos-threat?pretty -H 'Content-Type: application/json' -d @threat_template_mapping-v1.json
```    
- Restart Elastic Search & LogStash
- Configure your PANW Firewall(s) to send syslog messages to your Elastic Stack server
  - UDP 5514
  - Format BSD
  - Facility LOG_USER
  
- Ensure that your firewall generates at least one traffic, threat, system & config syslog entry each
  - You may have to trigger a threat log entry. Follow [this guide](https://live.paloaltonetworks.com/t5/Management-Articles/How-to-Test-Threat-Prevention-Using-a-Web-Browser/ta-p/62073) from Palo Alto for instructions
  - After committing to set your syslog server, you will need to do another committ (any change) to actually send a config log message
  
- Once the data is rolling, login to Kibana and create the 4 new index patterns, all with a Time Filter field of '@timestamp'
  - panos-traffic
  - panos-threat
  - panos-system
  - panos-config

- And lastly, import the saved object files (in this orders)
  - searches-base.json
  - visualisations-base.json
  - dashboards-base.json
  
And that's it! Once you have some logs in the system, you should see the dashboards start to fill up
  
 
## References
