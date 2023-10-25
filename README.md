# NodeJS-DockerImages
Docker images for Node.JS (ideally for Windows Server Nano)


Requires PowerShell.\
Run `.\Build.ps1 -PowerShellImageTag "lts-nanoserver-1809"` to build on Windows 10.\
The `-PowerShellImageTag` must be one of these: https://hub.docker.com/_/microsoft-powershell

You can also specify the new image prefix using `-ImagePrefix`, this is useful if you want to make you images named "myname/node", for example.


The `.\Build.ps1` script will create a `installNode.ps1` script inside the `Temp` directory.\
This downloads the latest version a of particular "major" version of Node.JS.\
In order to provide multiple Node.JS versions, the NodeVersions.json file is used to specify which versions of Node.JS are built.\
So, if you have "18" and "20" in that file, if you run `.\Build.ps1` you'll get 2 images: one with the latest version of Node.JS v18 and one with v20.