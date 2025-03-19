#!/bin/bash

# Define colors
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 11)
CYAN=$(tput setaf 6)
WHITE=$(tput setaf 15)
RESET=$(tput sgr0) # Reset color

# Function to display script usage
display_usage() {

# Check if figlet is installed
if ! command -v figlet &> /dev/null; then
 echo "Figlet is not installed. Installing..."
 # Install figlet
 sudo apt-get update
 sudo apt-get install -y figlet
else
 color_code="\033[31m" # Red color code
 reset_color="\033[0m" # Reset color code

 figlet_text=$(figlet "Precon")
 colored_text="${color_code}${figlet_text}${reset_color}"
 echo -e "$colored_text"

 echo "${YELLOW}# Coded by Tahir Mujawar${RESET}"
 echo
fi
 
 echo "Precon is a subdomain discovery bash script that discovers subdomains for websites passively by using various Tools."
 
 echo -e "Usage: $0 [options]"
 echo
 echo "Options:"
 echo " -h, --help Display this help message"
 echo " -d, --domain <name> Specify a single domain name to enumerate it's subdomains"
 echo " -dL, --domain-list Specify a file containing a list of domain names"
 echo " -o, --output <directory> Specify output directory"
 echo
 echo "Example: $0 -d example.com -o /path/to/output"
 exit 1
}

# Function for logging
log() {
 local log_file="recon.log"
 local timestamp=$(date +"%Y-%m-%d %T")
 echo "[$timestamp] $1" >> "$log_file"
 local message="$1"
 local color="$2"
}

# Default output filename is domain name
output_file=""

# Default domain name and domain list file
domain=""
domain_list=""

# Default output directory is empty (current directory)
output_dir=""

# Parse command line options
while [[ $# -gt 0 ]]; do
 key="$1"
 case $key in
 -h|--help)
 display_usage
 ;;
 -d|--domain)
 domain="$2"
 shift
 ;;
 -dL|--domain-list)
 domain_list="$2"
 shift
 ;;
 -o|--output)
 output_dir="$2"
 shift
 ;;
 *)
 echo -e "${RED}Unknown option: $1 ${RESET}"
 display_usage
 ;;
 esac
 shift
done

# Enable immediate exit on error
set -e

# Validate input parameters
if [ -z "$domain" ] && [ -z "$domain_list" ]; then
 log "${RED}Error: You must specify either a domain name or a domain list file.${RESET}"
 display_usage
fi

# Convert relative paths to absolute paths
if [ -n "$domain_list" ]; then
 domain_list="$(realpath "$domain_list")"
fi

# Create output directory if provided
if [ -n "$output_dir" ]; then
 mkdir -p "$output_dir" || { log "${RED}Error: Could not create output directory: $output_dir ${RESET}"; exit 1; }
 cd "$output_dir" || { log "${RED}Error: Could not change directory to: $output_dir ${RESET}"; exit 1; }
fi

# Function to run recon tools for a domain
run_recon() {
# Check if figlet is installed
if ! command -v figlet &> /dev/null; then
 echo "Figlet is not installed. Installing..."
 # Install figlet
 sudo apt-get update
 sudo apt-get install -y figlet
else
 color_code="\033[31m" # Red color code
 reset_color="\033[0m" # Reset color code

 figlet_text=$(figlet "Precon")
 colored_text="${color_code}${figlet_text}${reset_color}"
 echo -e "$colored_text"

 echo "${YELLOW}# Coded by Tahir Mujawar${RESET}"
 echo
fi

 local current_domain="$1"
 log "${WHITE}Enumerating Subdomains for domain: $current_domain ${RESET}" 
 local domain_output_dir="$current_domain"
 mkdir -p "$domain_output_dir"
 cd "$domain_output_dir" || { log "${RED}Error: Could not change directory to: $domain_output_dir ${RESET}"; exit 1; }

 #Run recon tools for the domain
 echo -e "${WHITE}Enumerating Subdomains for domain: $current_domain ${RESET}"
 log "${WHITE}Enumerating Subdomains for domain: $current_domain ${RESET}" 
 
 # Run each recon tool sequentially for the domain
 echo "Enumerating subdomains using Assetfinder"
 log "Running assetfinder for domain: $current_domain"
 assetfinder "$current_domain" > assetfinder_Tool.txt 2>/dev/null || true
 
 echo "Enumerating subdomains using Subfinder"
 log "Running subfinder for domain: $current_domain"
 subfinder -d "$current_domain" > subfinder_Tool.txt 2>/dev/null || true
 
 echo "Enumerating subdomains using Sublist3r"
 log "Running sublist3r for domain: $current_domain"
 sublist3r -d "$current_domain" -o sublist3r_Tool.txt > /dev/null 2>&1 || true
 
 echo "Enumerating subdomains using Chaos"
 log "Running chaos for domain: $current_domain"
 chaos -d "$current_domain" -silent -key {YOUR_CHAOS_API_KEY_HERE} -o chaos_Tool.txt > /dev/null 2>&1 || true
 
 echo "Enumerating subdomains using Crtsh"
 log "Running crtsh for domain: $current_domain"
 curl -s "https://crt.sh/?q=%.$current_domain" | sed 's/<[^>]*>//g' | grep -Eo "[a-zA-Z0-9._-]+\.$current_domain" | sed '/^$/d' > crtsh_Tool.txt
 
 echo "Enumerating subdomains using Crobat"
 log "Running crobat for domain: $current_domain"
 crobat -s "$current_domain" -o crobat_Tool.txt 2>/dev/null || true
 
 echo "Enumerating subdomains using Findomain"
 log "Running findomain for domain: $current_domain"
 findomain -t "$current_domain" -u findomain_Tool.txt > /dev/null 2>&1 || true
 
 echo "Enumerating subdomains using Knockpy"
 log "Running knockpy for domain: $current_domain"
 knockpy.py -d "$current_domain" > knockpy_Tool.txt 2>/dev/null || true
 
 echo "Enumerating subdomains using amass"
 log "Running amass for domain: $current_domain"
 amass enum -passive -d "$current_domain" > amass_Tool.txt 2>/dev/null || true
 #add more tools according to your preferences

 # Concatenate and sort unique subdomains
 cat *_Tool.txt | sort -u > $current_domain-subdomains.txt
 #Remove messy files generated by tools 
 rm *_Tool.txt
 # Check if any .json files exist in the directory usually generated by crtsh 
 if ls *.json >/dev/null 2>&1; then
 # Remove all .json files
 rm *.json
 echo "Removed all .json files from the directory."
 fi
 
 #Display Completion Message
 if [ -z "$output_dir" ]; then
 echo -e "${WHITE}Precon completed. Output saved to: $current_domain ${RESET}"
 log "${WHITE}Precon completed. Output saved to: $current_domain ${RESET}" 
else
 echo -e "${WHITE}Precon Completed. Output saved to: $output_dir ${RESET}"
 log "${WHITE}Precon completed. Output saved to: $output_dir ${RESET}" 
fi
 
 # Move back to the output directory
 cd .. || { log "${RED}Error: Could not change directory to: $output_dir ${RESET}"; exit 1; }
}

# Run recon for a single domain if provided
if [ -n "$domain" ]; then
 run_recon "$domain"
 current_domain="$domain"
fi

# Run recon for domains listed in the domain list file if provided
if [ -n "$domain_list" ]; then
 if [ ! -f "$domain_list" ]; then
 log "${RED}Error: Domain list file not found: $domain_list ${RESET}"
 log "${YELLOW}Please make sure the domain list file exists and provide the correct file name.${RESET}"
 exit 1
 fi

 # Read domains from the file and run recon for each domain in sequence
 while IFS= read -r line; do
 run_recon "$line"
 current_domain="$line"
 done < "$domain_list"
 # Cleanup: Remove *.txt files after all domains are processed usually generated by crtsh
 rm -f *_Tool.txt
 if ls *.json >/dev/null 2>&1; then
 # Remove all .json files
 rm *.json
 echo "Removed all .json files from the directory."
 fi
 
fi

 #Send Notifications - ( This part is optional ) you can remove if you sit in front of your beast and do all the work :)
 
 # Get current date and time
 current_datetime=$(date +"%Y-%m-%d %H:%M:%S")

 # Your message
 message="Precon for $current_domain Completed $current_datetime"

 # Webhook URL
 webhook_url="YOUR_WEBHOOK_URL_HERE"

 # Send message to Discord silently
 response=$(curl -s -o /dev/null -w "%{http_code}" -X POST -H "Content-Type: application/json" -d "{\"content\":\"$message\"}" "$webhook_url" 2>/dev/null)

 # Check for any errors
 if [[ $response == "200" || $response == "204" ]]; then
 echo "Notification sent successfully to Discord server for $current_domain."
 else
 echo "Failed to send notification to Discord server. HTTP Error code: $response"
 fi

 #Send Notification to Telegram Bot
 # Telegram Bot API token
 telegram_token="YOUR_TELEGRAM_BOT_TOKEN_HERE"

 # Telegram chat ID
 chat_id="YOUR_TELEGRAM_CHAT_ID_HERE"

 # Your message for Telegram Bot 
 message="Precon completed for $current_domain at $current_datetime"

 # Send message to Telegram Bot
 telegram_response=$(curl -s -X POST "https://api.telegram.org/bot$telegram_token/sendMessage" -d "chat_id=$chat_id" -d "text=$message")
 # Check for any errors
 if [[ $telegram_response =~ "\"ok\":true" ]]; then
 echo "Notification sent successfully to Telegram Bot for $current_domain"
 else
 echo "Failed to send message. Error: $telegram_response"
 fi