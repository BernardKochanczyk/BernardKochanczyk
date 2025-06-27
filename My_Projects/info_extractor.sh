#!/bin/bash
# Author: Bernard Kochańczyk
# License: MIT

# Check if a file was passed
if [[ -z "$1" ]]; then
  echo "Usage: $0 <file>"
  exit 1
fi

file_path="$1"

# Check if file exists
if [[ ! -e "$file_path" ]]; then
  echo "Error: File not found: $file_path"
  exit 2
fi

# Detect MIME type
mime_type=$(file --mime-type -b "$file_path")
echo "MIME type: $mime_type"

# Decide how to read the file
if [[ "$mime_type" == text/* || "$mime_type" == application/json || "$mime_type" == application/xml ]]; then
  echo "Reading as text file..."
  content=$(cat "$file_path")
else
  echo "Reading with strings (non-text file)..."
  content=$(strings "$file_path")
fi

# Regular expressions for data types
regex_ipv4='\b([0-9]{1,3}\.){3}[0-9]{1,3}\b'
regex_ipv6='\b([a-fA-F0-9]{0,4}:){2,7}[a-fA-F0-9]{0,4}\b'
regex_mac='\b([0-9a-fA-F]{2}:){5}[0-9a-fA-F]{2}\b'
regex_email='\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}\b'
regex_phone='\b(\+?\d{1,3}[-. ]?)?\(?\d{2,4}\)?[-. ]?\d{3,4}[-. ]?\d{4}\b'
regex_url='\b(https?|ftp)://[^\s"]+\b'

# Function to extract and label matches
extract() {
  label="$1"
  pattern="$2"
  echo ""
  echo "🔍 $label:"
  echo "$content" | grep -oE "$pattern" | sort -u
}

# Perform all extractions
extract "IPv4 Addresses" "$regex_ipv4"
extract "IPv6 Addresses" "$regex_ipv6"
extract "MAC Addresses" "$regex_mac"
extract "Email Addresses" "$regex_email"
extract "Phone Numbers" "$regex_phone"
extract "URLs" "$regex_url"
