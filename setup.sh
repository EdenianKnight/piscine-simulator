#!/bin/bash

# Get the absolute path of the current simulator directory
INSTALL_DIR=$(pwd)

echo "--- STARTING SIMULATOR SETUP ---"

# 1. Remove the simulator's .git folder to make it a clean workspace
if [ -d ".git" ]; then
    rm -rf .git
    echo "[OK] Cleaned simulator environment."
fi

# 2. Set execution permissions for all internal scripts
chmod +x checker
chmod +x .piscine-grader/simulate.sh
echo "[OK] Set execution permissions."

# 3. Create the system-wide symlink (Requires sudo)
echo "Installing 'checker' to /usr/local/bin (requires sudo)..."
sudo ln -sf "$INSTALL_DIR/checker" /usr/local/bin/checker

if [ $? -eq 0 ]; then
    echo "[OK] Checker installed successfully."
    echo ""
    echo -e "\033[1;32m############################################################"
    echo -e "# SETUP COMPLETE!                                          #"
    echo -e "# PLEASE FOLLOW THE INSTRUCTIONS ON THE PISCINE WEBSITE    #"
    echo -e "# TO SET UP YOUR 'piscine-go' REPOSITORY.                  #"
    echo -e "# YOU CAN NOW RUN 'checker' FROM ANYWHERE IN YOUR WORKSPACE#"
    echo -e "############################################################\033[0m"
else
    echo -e "\033[31m[ERROR] Installation failed. Try running: sudo ./setup.sh\033[0m"
fi                                                                                                                                                                                                                                                                                                      