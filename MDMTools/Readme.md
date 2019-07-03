# MDMTools #

### AppleVPPTools ##
Functions to pull VPP info from Apple directly to troubleshoot issues with VPP deployments. Uses the token file downloaded from the VPP portal to make REST calls against Apple's servers.

### AutoAutopilot ##
Pretty much run and wait - it'll gather the hash, save it to CSV, upload it to Intune, assign the user and group as required, then if you'd like it uses sysprep to force the device back to OOBE to do the autopilot enrollment without resetting windows. Using sysprep to do this is not recommended. I don't suggest ever letting it do so, but it's handy when testing with a VM you don't have access to reset.
