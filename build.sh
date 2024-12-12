#!/usr/bin/env bash

CORES=$(nproc --all)
SED_CMD="sed -i  -E -e"

BE_PATH=/binexport
BN_PATH=/binja
BN_API_PATH=/binaryninja-api
BINARY_HASH=$(sed 's/^.*\///' < $BN_PATH/api_REVISION.txt 2>/dev/null)

echo "Configuration:"
echo "  BE_PATH: $BE_PATH"
echo "  BN_API_PATH: $BN_API_PATH"
echo "  BN_PATH: $BN_PATH"
echo "  BINARY_HASH: $BINARY_HASH"

if [ -z "$BINARY_HASH" ]
then
  echo "Failed to find appropriate hash for Binary Ninja"
  exit 1
fi

git clone https://github.com/google/binexport.git $BE_PATH
git clone --recursive --branch dev https://github.com/Vector35/binaryninja-api.git $BN_API_PATH

pushd $BN_API_PATH
if git fetch --all
then
  if git checkout "$BINARY_HASH"
  then
    git pull
    echo "Binary Ninja API exists, repo updated"
  else
    echo Not a repo or could not match binary hash
    exit
  fi
fi
popd

echo "\u001b[36m[+] Updating the git hash..."
echo "\u001b[0m"
$SED_CMD "s/(1bd42a73e612f50c68d802acda674c21a30e980c|6e2b374dece03f6fb48a1615fa2bfee809ec2157)/$BINARY_HASH/g" $BE_PATH/cmake/BinExportDeps.cmake
$SED_CMD "s/2023-05-18/2023-09-24/g" $BE_PATH/cmake/BinExportDeps.cmake

echo "\u001b[36m[+] Running regenerate-api-stubs..."
echo "\u001b[0m"
pushd $BE_PATH/binaryninja/stubs/
./regenerate-api-stubs.sh $BN_API_PATH
popd

pushd $BE_PATH

echo "\u001b[36m[+] Building BinExport..."
echo "\u001b[0m"
rm -rf build && mkdir build && cd build
cmake .. -G Ninja -DCMAKE_CXX_FLAGS="-D_LIBCPP_ENABLE_CXX17_REMOVED_UNARY_BINARY_FUNCTION" -DBINEXPORT_BINARYNINJA_CHANNEL=DEV -DCMAKE_BUILD_TYPE=Release "-DCMAKE_INSTALL_PREFIX=$PWD" -DBINEXPORT_ENABLE_IDAPRO=OFF -DBINEXPORT_ENABLE_BINARYNINJA=ON
cmake --build . --config Release -- "-j$CORES"

popd

cp $BE_PATH/build/binaryninja/binexport12_binaryninja.so /so/binexport12_binaryninja.so
