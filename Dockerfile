FROM mcr.microsoft.com/windows/servercore:ltsc2022 AS compiler_explorer_win_base

SHELL [ "powershell" ]

# Install Chocolatey
ENV ChocolateyUseWindowsCompression false
RUN Set-ExecutionPolicy RemoteSigned -Force
RUN iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

# Make refreshenv work
RUN Import-Module "$env:ChocolateyInstall\helpers\chocolateyInstaller.psm1" -Force

# Install Git and node-js
RUN choco install -y --no-progress git.install
RUN choco install -y --no-progress nodejs-lts
RUN refreshenv
CMD [ "powershell" ]

FROM compiler_explorer_win_base

ARG REPO_URL=https://github.com/compiler-explorer/compiler-explorer.git
ARG COMPILER_EXPLORER_DIR="c:\compiler-explorer"

RUN git clone $env:REPO_URL $env:COMPILER_EXPLORER_DIR --recurse-submodules
RUN git config --global --add safe.directory $env:COMPILER_EXPLORER_DIR
COPY "props\WindowsLocal.properties" "$COMPILER_EXPLORER_DIR\etc\config\c++.local.properties"

WORKDIR $COMPILER_EXPLORER_DIR
RUN npm install
RUN npm install webpack -g
RUN npm install webpack-cli -g
RUN npm update webpack
CMD npm start
