# MDMTools #
### AgentLaunch ##
Executes a .ps1 script in powershell by calling it through AgentExecutor - handy for making sure the script executes as it should on the device, free from Intune involvement. If it works here but not through Intune, something is going on between Intune and the device, if it doesn't work here either, then the device should be suspicious. Anti-viruses will sometimes sandbox AgentExecutor and make it think it succeeded when it didn't execute anything. Run through here, review .error and .output, and look and AgentExecutor logs to figure out what happened in the attempt.

### AutoAutopilot ##
Pretty much run and wait - it'll gather the hash, save it to CSV, upload it to Intune, assign the user and group as required, then if you'd like it uses sysprep to force the device back to OOBE to do the autopilot enrollment without resetting windows. Using sysprep to do this is not recommended. I don't suggest ever letting it do so, but it's handy when testing with a VM you don't have access to reset and only moderately care about.

### AutopilotAssigner ###
After using a profile that targets a device for Autopilot Conversion, the autopilot object doesn't create the AAD object until something targets for having a ZTDID tag. This means that whatever profile is applied to the generic **contains ztdid** group is the profile these devices will get, and things like model information can't be used for targeting until after a join is done on the new AAD object, so you end up needed to do OOBE twice if you want a specific profile targeted by something like model info to apply to the device.

This script will pull all devices that have no OrderID assigned, only ZTDID. After that, you can modify the CSV to add the order ID representing the Autopilot Profile you actually want the device to get, then you "press any key" and that CSV is reapplied, adding the OrderID to the device.

This way, instead of enrolling twice, you target the device for conversion, create a generic autopilot profile that targets devices that contain ZTDID to generate the AAD object, then run this and assign the necessary OrderID so that the correct dynamic group picks it up, so the proper profile applies. Then reset the device and only have to OOBE once.

### PSVPP ##
Lets you query VPP directly using the VPP token provided by Apple - handy for troubleshooting issues syncing VPP licenses. If the changes don't come out with this either, the issue is with Apple not providing updated information. If the changes are here but not in your MDM, the MDM isn't updating with the info Apple sends.
