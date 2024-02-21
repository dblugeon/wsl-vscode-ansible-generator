#!/bin/bash
# requirement on ubuntu wsl, if you want launch the shell script
# sudo apt install -y unzip zip jq
set -o pipefail
URL_VSCODE="https://code.visualstudio.com/sha/download?build=stable&os=win32-x64-archive"
VS_UNCOMPRES_DIR=dist/vs_uncompress

# extensions wanted list
EXTENSIONS_ID="redhat.vscode-yaml redhat.ansible ms-vscode-remote.vscode-remote-extensionpack natizyskunk.sftp \
johnstoncode.svn-scm gitlab.gitlab-workflow"

#clean up for testing 
rm -r dist $HOME/.vscode-server &> /dev/null
mkdir -p dist &> /dev/null

echo "Download the latest version of vscode for windows..."
(cd dist && curl $URL_VSCODE --location --remote-name --remote-header-name)
RC_CURL=$?
if [ $RC_CURL -ne 0 ]
then
    echo "[ERROR] during download vscode executable"
    exit $RC_CURL
fi
echo "[OK]"

echo "Extracting vscode..."
vscode_zip_name=$(ls dist/VSC*.zip)
RC_LS=$?
if [ $RC_LS -ne 0 ]
then
    echo "[ERROR] during search vscode's zip file"
    exit $RC_LS
fi
echo "[OK]"

echo "Unzip vscode..."
unzip $vscode_zip_name resources/app/product.json -d $VS_UNCOMPRES_DIR
RC_UNZIP=$?
if [ $RC_UNZIP -ne 0 ]
then
    echo "[ERROR] during unzip vscode"
    exit $RC_UNZIP
fi
echo "[OK]"

echo "Extract commit ref from $name's content..."
commit_ref=$(cat $VS_UNCOMPRES_DIR/resources/app/product.json | jq -r '.commit')
RC_COMMIT_REF=$?
if [ $RC_COMMIT_REF -ne 0 ]
then
    echo "[ERROR] during extract commit ref of $name"
    exit $RC_UNZIP
fi
echo "commit_ref=$commit_ref" >> "$GITHUB_OUTPUT"    
echo "[ok]"

echo "Extract version tag $name's content..."
version_ref=$(cat $VS_UNCOMPRES_DIR/resources/app/product.json | jq -r '.version')
RC_VERSION_REF=$?
if [ $RC_VERSION_REF -ne 0 ]
then
    echo "[ERROR] during extract commit ref of $name"
    exit $RC_VERSION_REF
fi
echo "version_ref=$version_ref" >> "$GITHUB_OUTPUT"
echo "[ok]"

# source https://stackoverflow.com/questions/56718453/using-remote-ssh-in-vscode-on-a-target-machine-that-only-allows-inbound-ssh-co
echo "Download vscode server linux for commit $commit_ref..."
(cd dist && curl --location --remote-name --remote-header-name "https://update.code.visualstudio.com/commit:${commit_ref}/server-linux-x64/stable" )
RC_SERVER_LINUX=$?
if [ $RC_SERVER_LINUX -ne 0 ]
then
    echo "[ERROR] fail during download linux vscode server"
    exit $RC_SERVER_LINUX=$?
fi
echo "[ok]"

echo "Untar vscode server..."
( cd dist && tar -xvzf vscode-server-linux-x64.tar.gz )
RC_UNTAR=$?
if [ $RC_UNTAR -ne 0 ]
then
    echo "[ERROR] fail during untar linux vscode server"
    exit $RC_UNTAR=$?
fi
echo "[ok]"

echo "Installing extension in vscode server"
for ext in $EXTENSIONS_ID
do
    dist/vscode-server-linux-x64/bin/code-server --install-extension $ext
done
echo "[OK]"

echo "Prepare vscode server final version"
mv $HOME/.vscode-server dist/vscode-server && \
mkdir dist/vscode-server/bin && \
mv dist/vscode-server-linux-x64 dist/vscode-server/bin/${commit_ref} && \
rm dist/vscode-server-linux-x64.tar.gz

if [ $? -ne 0 ]
then
    echo "[ERROR] during preparation first stage"
    exit -1
fi

echo "Update $vscode_zip_name: enable portable mode"
mkdir -p dist/data/extensions
if [ $? -ne 0 ]
then
    echo "[ERROR] during preparation of dest directory"
    exit -1
fi

cp -lr dist/vscode-server/extensions/* dist/data/extensions/
if [ $? -ne 0 ]
then
    echo "[ERROR] during copy in hardlink  of extensions"
    exit -1
fi
(cd dist && zip -r $(basename $vscode_zip_name) data)
if [ $? -ne 0 ]
then
    echo "[ERROR] during update of $vscode_zip_name"
    exit -1
fi

echo "Download wsl2-ssh-bridge"
(cd dist && curl --location --remote-name --remote-header-name https://github.com/KerickHowlett/wsl2-ssh-bridge/releases/download/latest/wsl2-ssh-bridge.exe)
if [ $? -ne 0 ]
then
    echo "[ERROR] unable download wsl2-ssh-bridge"
    exit -1
fi

echo "[ok]"
