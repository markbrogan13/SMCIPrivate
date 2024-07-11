#!/bin/bash

# Prompt the user for the filename containing BMC credentials
# The format of the file need to follow "BMC_IP BMC_Username BMC_Password" for each system. 
# Each system will need a new line. 
# If you are going to copy & paste the information from different source, be careful with the formatting, as Linux OS might treat format differently. 
#read -p "Enter the filename containing BMC credentials (format: BMC_IP USERNAME PASSWORD per line): " filename

filename=$1

# Ensure the input file exists
if [ ! -f "$filename" ]; then
    echo "Input file '$filename' not found."
    exit 1
fi

# Initialize a counter for successful updates and a list for failed BMC IPs
success_count=0
successful_bmcs=()
failed_bmcs=()

# Loop through each line in the input file
while read -r BMC_IP USERNAME PASSWORD; do

	# Define the URL
	URL_BiosConfiguration="https://$BMC_IP/redfish/v1/Systems/1/Bios"

	# Define the PATCH Data for BIOS configuration
	PATCH_DATA_BiosConfiguration='{"Attributes":{
			"SMTControl#0037":"Disabled",
			"IOMMU#0196":"Disabled",
			"ACSEnable#019B":"Disabled",
            "NUMANodesPerSocket#703E":"NPS2"}
			}'


	# Send PATCH request using curl
	RESPONSE=$(curl -k -s -o /dev/null -w "%{http_code}" -X PATCH -u "$USERNAME:$PASSWORD" -H "Content-Type: application/json" -d "$PATCH_DATA_BiosConfiguration" "$URL_BiosConfiguration")

    # Print the HTTP status code
    # echo "BIOS Setting Update HTTP response code: $RESPONSE"

	# Check the response code
    if [ "$RESPONSE" -eq 200 ] || [ "$RESPONSE" -eq 202 ] || [ "$RESPONSE" -eq 204 ]; then
        echo "$BMC_IP completed BIOS Setting Update"
        successful_bmcs+=("$BMC_IP $USERNAME $PASSWORD")
    else
        echo "$BMC_IP failed BIOS Setting Update"
        failed_bmcs+=("$BMC_IP $USERNAME $PASSWORD")
        continue
        exit 1
    fi

done < "$filename"

# Get the current date and time for the filenames
timestamp=$(date +"%Y%m%d_%H%M%S")

# Save the list of successful BMC IPs and credentials to a file
successful_filename="successful_bmcs_$timestamp.txt"
for BMC in "${successful_bmcs[@]}"; do
    echo "$BMC" >> "$successful_filename"
done

# Save the list of failed BMC IPs and credentials to a file
failed_filename="failed_bmcs_$timestamp.txt"
for BMC in "${failed_bmcs[@]}"; do
    echo "$BMC" >> "$failed_filename"
done

# Print the summary
if [ ${#failed_bmcs[@]} -ne 0 ]; then
    echo "The following BMCs failed to update BIOS settings:"
    cat "$failed_filename"
else
    echo "All BMCs updated successfully."
fi

echo "Successful BMCs saved to $successful_filename"
echo "Failed BMCs saved to $failed_filename"