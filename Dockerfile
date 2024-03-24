FROM mcr.microsoft.com/powershell:lts-nanoserver-1809 AS installer-env

# Arguments for installing PowerShell, must be defined in the container they are used
ARG PS_VERSION=7.4.1
# disable telemetry
ENV POWERSHELL_TELEMETRY_OPTOUT="1"

SHELL ["pwsh", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

ADD https://github.com/PowerShell/PowerShell/releases/download/v$PS_VERSION/PowerShell-$PS_VERSION-win-x64.zip /powershell.zip
RUN Expand-Archive /powershell.zip -DestinationPath \PowerShell

FROM mcr.microsoft.com/windows/servercore:1809 AS servercore

FROM mcr.microsoft.com/windows/nanoserver:ltsc2019

# Set environment variables
ENV JAVA_HOME C:\\jdk
ENV MAVEN_HOME C:\\apache-maven
ENV ACTIONS_RUNNER_CONTAINER_HOOKS C:\\runner-container-hooks-docker\\index.js
ENV ACTIONS_RUNNER_HOOK_JOB_STARTED C:\\actions-runner-hook\\Job-Started.ps1
ENV ACTIONS_RUNNER_HOOK_JOB_COMPLETED C:\\actions-runner-hook\\Job-Completed.ps1
ENV PROGRAM_FILES "C:\Program Files"

USER ContainerAdministrator
# USER ContainerUser
COPY --from=installer-env ["/PowerShell", "C:/Program Files/PowerShell"]
COPY --from=servercore /Windows/System32/NetApi32.dll /Windows/System32/NetApi32.dll
COPY --from=servercore ["/Windows/System32/WindowsPowerShell/v1.0/powershell.exe", "C:/Program Files/PowerShell/powershell.exe"]

# Setup
RUN setx /M PATH "%PATH%;%JAVA_HOME%\bin;%MAVEN_HOME%\bin;%PROGRAM_FILES%\PowerShell;C:\actions-runner\bin;C:\nodejs\bin;" \
  & mkdir C:\actions-runner \
  & mkdir C:\actions-runner-hook \
  & mkdir C:\runner-container-hooks-docker

SHELL ["pwsh.exe", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

# Download and install Java
ADD https://aka.ms/download-jdk/microsoft-jdk-21.0.2-windows-x64.zip C:\\jdk.zip
RUN Expand-Archive jdk.zip -DestinationPath C:\ ; \
  Move-Item -Path C:\jdk-21.0.2+13 -Destination $Env:JAVA_HOME ; \
  Remove-Item -Path jdk.zip

# Download and install Maven
# ADD https://archive.apache.org/dist/maven/maven-3/3.6.3/binaries/apache-maven-3.6.3-bin.zip C:\\maven.zip
ADD https://dlcdn.apache.org/maven/maven-3/3.9.6/binaries/apache-maven-3.9.6-bin.zip C:\\maven.zip
RUN Expand-Archive maven.zip -DestinationPath C:\ ; \
  Move-Item -Path C:\apache-maven* -Destination $Env:MAVEN_HOME ; \
  Remove-Item -Path maven.zip

# Download Self-hosted-runner
ADD https://github.com/actions/runner/releases/download/v2.314.1/actions-runner-win-x64-2.314.1.zip \
  C:\\actions-runner\\actions-runner-win.zip
RUN cd actions-runner; \
  if((Get-FileHash -Path actions-runner-win.zip -Algorithm SHA256).Hash.ToUpper() -ne '2e1d73c3fe00ad37c359e4f48bd09aa88ef09a46fca16d6f1e94776ccf67fc27'.ToUpper()){ throw 'Computed checksum did not match' } ; \
  Add-Type -AssemblyName System.IO.Compression.FileSystem ; [System.IO.Compression.ZipFile]::ExtractToDirectory(\"$PWD/actions-runner-win.zip\", \"$PWD\") ; \
  Remove-Item -Path actions-runner-win.zip

# Download runner-container-hooks
ADD https://github.com/actions/runner-container-hooks/releases/download/v0.6.0/actions-runner-hooks-docker-0.6.0.zip \
  runner-container-hooks.zip
RUN Expand-Archive -Path runner-container-hooks.zip -DestinationPath C:\runner-container-hooks-docker\ ; \
  Remove-Item -Path runner-container-hooks.zip

# Download nodejs
ADD https://nodejs.org/dist/v20.11.1/node-v20.11.1-win-x64.zip nodejs.zip
RUN Expand-Archive -Path nodejs.zip -DestinationPath C:\nodejs\ ; \
  Remove-Item -Path nodejs.zip ; \
  Rename-Item C:\nodejs\node-v20.11.1-win-x64 C:\nodejs\bin

WORKDIR C:\\actions-runner

COPY scripts/Startup.ps1 .
COPY scripts/Job-Started.ps1 C:\\actions-runner-hook\\Job-Started.ps1
COPY scripts/Job-Completed.ps1 C:\\actions-runner-hook\\Job-Completed.ps1

ENTRYPOINT ["pwsh", "-File", "Startup.ps1"]
# ENTRYPOINT ["pwsh", "-Command", "Start-Sleep", "-Seconds", "2147483"]
