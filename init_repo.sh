#!/usr/bin/env bash
# Initialize a new repository with a structure that the import.tcl script accepts
# If an argument is provided that will be taken as the folder name for the new
# repository, otherwise the current folder will be used

PROJ_SUBFOLDERS=("src" "sim" "bd" "ip_repo" "waves")
PROJ_FOLDER="."
if [[ -n $1  ]]; then
    PROJ_FOLDER="$1"
fi
PROJ_FOLDER=$(readlink -f "$PROJ_FOLDER")
if ! mkdir -p "$PROJ_FOLDER"; then
    echo "Cannot create $PROJ_FOLDER"
    exit 1
fi
cd "$PROJ_FOLDER" || eval "echo \"cannot access $PROJ_FOLDER\"; exit 1"
if ! [[ -d "$PROJ_FOLDER/.git" ]]; then
    git init
fi
if ! [[ -e .gitignore ]] || ! grep -Fxq "*.vivado/**" .gitignore; then
    echo "" >> .gitignore
    echo "*.vivado/**" >> .gitignore
    git add .gitignore
fi
for PROJ_SUBFOLDER in "${PROJ_SUBFOLDERS[@]}"; do
    if ! mkdir -p "$PROJ_FOLDER/$PROJ_SUBFOLDER"; then
        echo "Cannot create $PROJ_FOLDER/$PROJ_SUBFOLDER"
        exit 1
    fi
done