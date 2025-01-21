# Sentinel-Logstash VMSS ARM Template
This project includes a VMSS ARM template that auto-scales and load-balances based on Logstash and the new output plugin for Log Analytics using managed identities.
It also includes a dockerfile for quick logstash debugging efforts.

This project draws heavy inspiration from: https://github.com/Azure/Azure-Sentinel/tree/master/DataConnectors/Logstash-VMSS
But this project improves upon it by not requiring shared secrets nor OMS/AMA. It also supports a complete mapping (dozens of columns) of the native Microsoft-Syslog and Microsoft-CommonSecurityEvent tables and of course Custom Tables from any ingestion source that logstash supports (json, syslog, cef, ect...)

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
- More technical info about the output plugin here: https://www.rubydoc.info/gems/microsoft-sentinel-logstash-output/1.2.3
- Did the user running logstash able to obtain a bearer token?
- ```
  sudo usermod -aG himds <username>
  CHALLENGE_TOKEN_PATH=$(curl -s -D - -H Metadata:true "http://127.0.0.1:40342/metadata/identity/oauth2/token?api-version=2019-11-01&resource=https%3A%2F%2Fmanagement.azure.com" | grep Www-Authenticate | cut -d "=" -f 2 | tr -d "[:cntrl:]") 
  CHALLENGE_TOKEN=$(cat $CHALLENGE_TOKEN_PATH) 
  curl -s -H Metadata:true -H "Authorization: Basic $CHALLENGE_TOKEN" "http://127.0.0.1:40342/metadata/identity/oauth2/token?api-version=2019-11-01&resource=https%3A%2F%2Fmanagement.azure.com"
```
