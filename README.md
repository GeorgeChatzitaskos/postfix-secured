# postfix-secured


# :mailbox: Postfix Configuration Script 

This script `postfix-secured.sh` configures the Postfix SMTP server on a Plesk server with best security practices.

---

## :rocket: Usage 

1. **Download the script:**

    ```bash
    wget https://github.com/GeorgeChatzitaskos/postfix-secured.git
    ```

2. **Make the script executable:**

    ```bash
    chmod +x configure_postfix.sh
    ```

3. **Run the script as root:**

    ```bash
    sudo ./configure_postfix.sh
    ```

---

## :bulb: What does this script do? 

This script automatically retrieves the public IP of the server, checks for the existence of SSL certificates, and ensures that only necessary changes to the Postfix configuration are made. A backup of the original configuration is created before any changes are applied.

---

## :warning: Disclaimer 

Always test scripts in a non-production environment first. Monitor your server's performance and error logs after making changes. Adjust as necessary based on your specific circumstances.

