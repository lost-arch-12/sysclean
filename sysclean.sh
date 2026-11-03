#!/bin/bash

# This script updates and cleans up system packages, detects installed services, and updates them.
# Location: /usr/local/bin/sysclean

echo "====== BEGINNING UPDATE ======"
sudo apt update && sudo apt upgrade -y

echo "====== CLEANING UP ======"
sudo apt autoremove -y 

echo "====== SCANNING FOR SYSTEM SERVICES ======"
FOUND_SERVICES=()

# Check for Pi-hole
if command -v pihole &> /dev/null; then
    FOUND_SERVICES+=("Pi-hole")
fi

# Check for Docker
if command -v docker &> /dev/null; then
    FOUND_SERVICES+=("Docker")
fi

# Check for Home Assistant CLI
if command -v ha &> /dev/null; then
    FOUND_SERVICES+=("Home Assistant")
fi

# Display findings
if [ ${#FOUND_SERVICES[@]} -eq 0 ]; then
    echo "No matching third-party services found."
else
    echo "Found the following services installed on this system:"
    for service in "${FOUND_SERVICES[@]}"; do
        echo "  -> $service"
    done
    echo ""
    
    read -p "Do you want to update these detected services? (y/n): " response
    response=$(echo "$response" | tr '[:upper:]' '[:lower:]')

    if [ "$response" = "yes" ] || [ "$response" = "y" ]; then
        for service in "${FOUND_SERVICES[@]}"; do
            if [ "$service" == "Pi-hole" ]; then
                echo "====== UPDATING PI-HOLE ======"
                sudo pihole -up
            elif [ "$service" == "Docker" ]; then
                echo "====== CLEANING DOCKER IMAGES ======"
		echo ""
		echo "WARNING: continuing with this command will remove any stored docker images"
                sudo docker image prune 
            elif [ "$service" == "Home Assistant" ]; then
                echo "====== UPDATING HOME ASSISTANT ======"
                ha core update
            fi
        done
    else 
        echo "Service updates cancelled by user."
    fi
fi

echo "====== SCRIPT COMPLETE ======"
