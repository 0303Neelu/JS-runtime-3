#!/bin/bash

# Set thresholds for sudo attempts
UNLIMITED_THRESHOLD=99999
LIMITED_THRESHOLD=1

# Log file to monitor sudo commands
LOG_FILE="/var/log/sudo-access.log"

# Email address to which you want to send notifications
ADMIN_EMAIL="gautham22poy@gmail.com"

# Extract users from /etc/passwd
ALL_USERS=$(awk -F: '$3 >= 1000 && $3 != 65534 {print $1}' /etc/passwd)

# Loop through the users
for USER in $ALL_USERS; do
    # Determine threshold based on username
    if [[ $USER =~ .*SH$ ]]; then
        THRESHOLD=$UNLIMITED_THRESHOLD
    elif [[ ! $USER =~ [A-Z] ]]; then
        THRESHOLD=$LIMITED_THRESHOLD
    else
        THRESHOLD=$UNLIMITED_THRESHOLD
    fi

    # Count sudo command attempts
    SUDO_COUNT=$(grep -c "$USER : user NOT in sudoers" "$LOG_FILE")

    # Check if attempts exceed threshold
    if [ $SUDO_COUNT -gt $THRESHOLD ]; then
        # Send email notification
        echo "Threshold reached. Mailing about - $USER"
        SUBJECT="Excessive sudo attempts by $USER"
        BODY="The user $USER has attempted to use sudo commands $SUDO_COUNT times."
        echo "$BODY" | mail -s "$SUBJECT" "$ADMIN_EMAIL"
    fi
done
