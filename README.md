# Sentinel-Logstash VMSS ARM Template

Before running the VMSS ARM template:
1. Create a DCR/DCE as needed based on the DCR template included in this repo
2. Consider replacing the cloudinit commands in the VMSS ARM Template that use wget and sed against this repo's logstash.conf. Instead point this to your own logstash.conf

After running the VMSS ARM template:
1. Ensure the identity for the VMSS is added to the "Monitoring Metrics Publisher" role for the DCR
2. To SSH to one of the VMs, modify the NSG to allow SSH from your machine for TCP 22

# Additional Testing of Logstash
1. Build the dockerfile:
```
docker build -t logstash-custom:v1 .
```
2. Create a local copy of logstash.conf (this repo includes a template)
3. Run a standalone docker container instance:
```
docker run -v ${PWD}/logstash.conf:/usr/share/logstash/pipeline/logstash.conf -p 514:514 logstash-custom:v1
```
4. From another terminal on the same docker host, send some Syslog and CEF test messages:
```
echo "<34>Jul 15 22:14:15 mymachine myapp: test error message" | nc -N localhost 514
echo "CEF:0|Device Vendor|Device Product|Device Version|DeviceEventClassID|Name|Severity|shost=sourceHost smac=00:0C:29:AC:BE:D2 sntdom=sourceNTDomain" | nc -N localhost 514
```

# Troubleshooting:
- Does your managed identity have "Monitoring Metrics Publisher" role for the DCR? (This can take over an hour to apply)
- Did you create your DCE or a change to your DCR recently? (A DCE can take several hours to fully create)
- Use the stdout output plugin to examine the console of the logstash process to debug how messages are received and parsed
- If you are struggling with managed identity, try testing with a new registered AppID and Client Secret
- More technical info about the output plugin here: https://www.rubydoc.info/gems/microsoft-sentinel-log-analytics-logstash-output-plugin/
