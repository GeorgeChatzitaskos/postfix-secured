#!/bin/bash

# Backup existing Postfix configuration
cp /etc/postfix/main.cf /etc/postfix/main.cf.bak

# Retrieve the public IP of the server
public_ip=$(curl -s ifconfig.me)

# Get SSL certificate and key file paths from the existing Postfix configuration
cert_file=$(grep -Po '^smtpd_tls_cert_file=\K.*' /etc/postfix/main.cf)
key_file=$(grep -Po '^smtpd_tls_key_file=\K.*' /etc/postfix/main.cf)

# Check if the SSL certificate file exists
if test -f "$cert_file"; then
    echo "$cert_file found."
else
    echo "SSL certificate file not found at $cert_file. Please specify the correct path."
    exit 1
fi

# Check if the SSL key file exists
if test -f "$key_file"; then
    echo "$key_file found."
else
    echo "SSL key file not found at $key_file. Please specify the correct path."
    exit 1
fi

# Array of Postfix settings to be added or modified
declare -A settings
settings=(
    ["smtpd_banner"]="$myhostname ESMTP"
    ["biff"]="no"
    ["append_dot_mydomain"]="no"
    ["readme_directory"]="no"
    ["smtpd_use_tls"]="yes"
    ["smtpd_tls_session_cache_database"]="btree:${data_directory}/smtpd_scache"
    ["smtp_tls_session_cache_database"]="btree:${data_directory}/smtp_scache"
    ["smtpd_relay_restrictions"]="permit_mynetworks permit_sasl_authenticated defer_unauth_destination"
    ["myhostname"]=$public_ip
    ["alias_maps"]="hash:/etc/aliases"
    ["alias_database"]="hash:/etc/aliases"
    ["myorigin"]="/etc/mailname"
    ["mydestination"]="$myhostname, $public_ip, localhost.$public_ip, , localhost"
    ["relayhost"]=""
    ["mynetworks"]="127.0.0.0/8 [::ffff:127.0.0.0]/104 [::1]/128"
    ["mailbox_size_limit"]="0"
    ["recipient_delimiter"]="+"
    ["inet_interfaces"]="all"
    ["inet_protocols"]="all"
    ["smtpd_helo_required"]="yes"
    ["smtpd_helo_restrictions"]="permit_mynetworks, reject_invalid_helo_hostname, reject_non_fqdn_helo_hostname, reject_unknown_helo_hostname"
    ["smtpd_recipient_restrictions"]="permit_sasl_authenticated, permit_mynetworks, reject_unauth_destination"
)

# Modify Postfix configuration to improve security
for setting in "${!settings[@]}"; do
    # Check if the setting already exists in the configuration file
    if ! grep -q "^$setting" /etc/postfix/main.cf; then
        # If the setting does not exist, add it
        postconf -e "$setting=${settings[$setting]}"
    fi
done

# Reload postfix configuration
service postfix reload
