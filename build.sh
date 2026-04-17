#!/bin/bash
set -e

# Check if USD_INSTALL_DIR is defined
if [ -z "$USD_INSTALL_DIR" ]; then
    echo "Error: USD_INSTALL_DIR environment variable is not set."
    echo "Please set it to the path where USD is installed."
    echo "Example: export USD_INSTALL_DIR=/path/to/usd/install"
    exit 1
fi

# Create build directory
mkdir -p build
cd build

# Configure with CMake
cmake .. \
  -DUSD_INSTALL_DIR=${USD_INSTALL_DIR} \
  -DCMAKE_BUILD_TYPE=RelWithDebInfo

# Build
if [ "$(uname)" == "Darwin" ]; then
    # macOS
    cmake --build . -j$(sysctl -n hw.ncpu)
else
    # Linux and others
    cmake --build . -j$(nproc)
fi

# Install to local addons directory
cmake --install . --prefix=../

echo "Build completed successfully!"
echo "The plugin has been installed to the 'addons/godot-usd' directory."
echo "To use the plugin, copy the 'addons' directory to your Godot project."

# If test_project exists, copy the library there automatically for testing
if [ -d "../test_project/lib" ]; then
    echo "Copying library to test_project/lib for testing..."
    cp ../lib/libgodot-usd.dylib ../test_project/lib/libgodot-usd.dylib
    echo "Library copied to test_project."
fi
