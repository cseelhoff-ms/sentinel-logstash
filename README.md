# VMSS ARM Template

Before running the VMSS ARM template:
1. Create a DCR/DCE as needed based on the DCR template included in this repo

After running the VMSS ARM template:
1. Ensure the identity for the VMSS is added to the "Monitoring Metrics Publisher" role for the DCR
2. To SSH to one of the VMs, modify the NSG to allow SSH from your machine for TCP 22

# Additional Testing
1. To run a standalone docker instance of logstash with Microsoft Sentinel Output plugin:
```
docker run -v ${PWD}/logstash.conf:/usr/share/logstash/pipeline/logstash.conf -p 514:514 logstash
```
