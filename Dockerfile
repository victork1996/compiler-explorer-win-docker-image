ARG BASE=mcr.microsoft.com/windows/servercore:ltsc2022
FROM $BASE AS compiler_explorer_win_base

SHELL [ "powershell" ]

# Install Chocolatey
ENV ChocolateyUseWindowsCompression false
RUN Set-ExecutionPolicy RemoteSigned -Force;\
    iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

# Make refreshenv work
RUN Import-Module "$env:ChocolateyInstall\helpers\chocolateyInstaller.psm1" -Force

# Install Git and node-js
RUN choco install -y --no-progress git.install;\
    choco install -y --no-progress nodejs-lts --version=18.12.1
RUN refreshenv
RUN npm install -g npm@latest


FROM compiler_explorer_win_base

ARG REPO_URL="https://github.com/compiler-explorer/compiler-explorer.git"
ARG REPO_BRANCH="gh-7441"
ARG COMPILER_EXPLORER_DIR="C:\compiler-explorer"
ENV NODE_OPTIONS="--max_old_space_size=4096"
ENV NODE_ENV="production"

RUN $COMPILER_EXPLORER_DIR_WITH_FORWARD_SLASHES = $env:COMPILER_EXPLORER_DIR -replace '\\', '/';\
    git clone -b $env:REPO_BRANCH $env:REPO_URL $env:COMPILER_EXPLORER_DIR --recurse-submodules;\
    git config --global --add safe.directory ${COMPILER_EXPLORER_DIR_WITH_FORWARD_SLASHES}

# COPY "props\WindowsLocal.properties" "$COMPILER_EXPLORER_DIR\etc\config\c++.local.properties"

WORKDIR $COMPILER_EXPLORER_DIR
RUN npm install;\
    npm install webpack -g;\
    npm install webpack-cli -g;\
    npm update webpack

CMD npm start
