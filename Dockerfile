FROM mcr.microsoft.com/powershell:latest as installer

ENV POWERSHELL_TELEMETRY_OPTOUT="1"
SHELL ["pwsh", "-Command"]
USER ContainerAdministrator

ADD InstallNode.ps1 /InstallNode.ps1
RUN /InstallNode.ps1

ENTRYPOINT node.exe