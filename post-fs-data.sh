#!/system/bin/sh

MODDIR=${0%/*}
SCRIPT="$MODDIR/system/bin/boot_script.sh"

# Check if the script exists
if [ -f "$SCRIPT" ]; then
    echo "Script exists: $SCRIPT"

    # Change ownership and check for errors
    if chown 0:0 "$SCRIPT"; then
        echo "Successfully changed ownership of the script"
    else
        echo "Failed to change ownership for $SCRIPT" >&2
        exit 1
    fi

    # Change permissions and check for errors
    if chmod 775 "$SCRIPT"; then
        echo "Successfully changed permissions of the script"
    else
        echo "Failed to change permissions for $SCRIPT" >&2
        exit 1
    fi

    # Execute the script and check for errors
    if "$SCRIPT"; then
        echo "Script executed successfully"
       sh  $SCRIPT
    else
        echo "Script execution failed" >&2
        exit 1
    fi
else
    echo "Script does not exist: $SCRIPT" >&2
    exit 1
fi
