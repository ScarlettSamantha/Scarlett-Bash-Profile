#!/bin/bash

certbot_add_domain(){
    # Check if at least one domain is provided
    if [ $# -eq 0 ]; then
        echo "Usage: $0 domain1.com domain2.com ..."
        exit 1
    fi

    # Construct the -d arguments for certbot
    DOMAINS=$(printf -- '-d %s ' "$@")

    # Run certbot with the constructed arguments
    sudo certbot --nginx "$DOMAINS"
}

create_alias "certbot_add_domain" "certbot_add_domain" "yes" 'Add one or more domains to an existing certbot certificate.'
create_alias "certbot_add_domain" "cb_ad" "yes" 'Add one or more domains to an existing certbot certificate.'