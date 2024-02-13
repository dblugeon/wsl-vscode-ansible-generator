#!/bin/bash
URL_VSCODE="https://code.visualstudio.com/sha/download?build=stable&os=win32-x64-archive"
VS_UNCOMPRES_DIR=dist/vs_uncrompress
rm -rf dist
mkdir -p dist/extensions

(cd dist && curl $URL_VSCODE --location --remote-name --remote-header-name)
RC_CURL=$?
if [ $RC_CURL -ne 0 ]
then
    echo "[ERROR] during download vscode executable"
    exit $RC_CURL
fi
echo "extracting vscode"
vscode_zip_name=$(ls dist/VSC*.zip)
RC_LS=$?
if [ $RC_LS -ne 0 ]
then
    echo "[ERROR] during search vscode's zip file"
    exit $RC_LS
fi
unzip $vscode_zip_name -d $VS_UNCOMPRES_DIR
RC_UNZIP=$?
if [ $RC_UNZIP -ne 0 ]
then
    echo "[ERROR] during unzip vscode"
    exit $RC_UNZIP
fi
echo "extract commit ref from $name's content"
commit_ref=$(cat $VS_UNCOMPRES_DIR/resources/app/product.json | jq -r '.commit')
RC_COMMIT_REF=$?
if [ $RC_COMMIT_REF -ne 0 ]
then
    echo "[ERROR] during extract commit ref of $name"
    exit $RC_UNZIP
fi
echo "download vscode server linux for $commit_ref"