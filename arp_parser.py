"""
    find all the IPs and their MAC addresses
    
    ./ping_all.sh
    arp -an >> arp_out.txt
    run this python script
    ./Redfish_API_Change_BIOS_Settings_Only.sh 
    this will return:

    ? (10.10.13.1) at 70:a7:41:66:90:62 [ether] on enp3s0
    ? (10.10.13.58) at 80:b9:89:8f:53:e5 [ether] on enp3s0
        
    split @ "at":
    ["? (10.10.13.1)", "70:a7:41:66:90:62 [ether] on enp3s0"]
    split[0]
"""

import re
import os
from tqdm import tqdm
import platform
import subprocess

ARP_FILE_NAME = "/Users/mbrogan/Downloads/DallasORI/Parser/arp_out.txt"
MAC_BMC_PASS = "/Users/mbrogan/Downloads/DallasORI/Parser/mac_pass.txt"
ARP_DICTIONARY = []
MAC_DICTIONARY = []

def ping_all(subnet):
    iterations = 255
    ping_result = subprocess.Popen(['./ping_all.sh', subnet], stdout=subprocess.PIPE, text=True)
    
    progress_bar = tqdm(total=iterations)
    while True:
        ping_output = ping_result.stdout.readline()
        if ping_output == '' and ping_result.poll() is not None:
            break
        if ping_output:
            progress_bar.update(1)
    progress_bar.close()

def arp_out():
    os.remove("arp_out.txt")
    with open("arp_out.txt", "w") as arp_file:
        command = "arp -an"
        arp_an = subprocess.run(command, shell=True, capture_output=True, text=True)
        arp_file.write(arp_an.stdout)
        
        arp_file.close()

def read_arp():
    with open(ARP_FILE_NAME, "r") as arps:
        for line in arps.readlines():
            line_arp_arr = line.split('at')
            #print(line_arp_arr)                 # debug
            ARP_DICTIONARY.append(regExHelper(line_arp_arr))
            #print(ARP_DICTIONARY)
        
        arps.close()

def regExHelper(arp_arr):
    text = arp_arr[0].strip()
    match = re.search(r'\((.*?)\)', text)

    if match:
        oob_ip = match.group(1)
        #print(oob_ip)  # Output: 10.10.13.1
    else:
        print("No match found")

    mac_text = arp_arr[1].strip()
    mac_address = ''

    match = re.search(r'([0-9a-fA-F]{2}[:-]){5}([0-9a-fA-F]{2})', mac_text)
    if match:
        mac_address = match.group().replace(':', '').upper()
        print(mac_address)  # Output: 80B9898F53E5
    else:
        #print("No MAC address found")
        random = 42
    if mac_address == '':
        random = 43
    else:
        return [mac_address, oob_ip]

def match_mac_to_input():
    with open(MAC_BMC_PASS, "r") as mac_pass:
        for line in mac_pass.readlines():
            new_line = line[:-1]
            MAC_DICTIONARY.append(new_line.split(' '))
    mac_pass.close()

    with open("input_file.txt", "w") as input_file:
        for sub_arp_arr in ARP_DICTIONARY:
            if sub_arp_arr is None or len(sub_arp_arr) < 2:
                continue  # Skip if sub_arp_arr is None or doesn't have at least two elements
            for sub_mac_pass_arr in MAC_DICTIONARY:
                if sub_mac_pass_arr is None or len(sub_mac_pass_arr) < 2:
                    continue  # Skip if sub_mac_pass_arr is None or doesn't have at least two elements
                if sub_arp_arr[0] == sub_mac_pass_arr[0]:
                    added_line = f'{sub_arp_arr[1]} ADMIN {sub_mac_pass_arr[1]}\n'
                    input_file.write(added_line)
        
        input_file.close()


def update_BIOS(input_file):
    line_count = 0
    with open(input_file, 'r') as file:
        line_count = sum(1 for line in file)

    BIOS_settings = subprocess.Popen(["./Redfish_API_Change_BIOS_Settings_Only.sh", input_file], stdout=subprocess.PIPE, text=True)
    progress_bar = tqdm(total=line_count)

    while True:
        bios_output = BIOS_settings.stdout.readline()
        if bios_output == '' and BIOS_settings.poll() is not None:
            break
        if bios_output:
            progress_bar.update(1)
    progress_bar.close()


if __name__ == "__main__":
    if os.name is "nt":
        print("Windows cannot run this script without being on Linux/Mac env")
    else:  
        print(f"OS Name: {os.name}\n" +
              f"Operating System: {platform.system()}\n" +
              f"Version: {platform.version()}\n")  
        ping_all(subnet="192.168.8")
        arp_out()
        read_arp()
        match_mac_to_input()
        update_BIOS(input_file="input_file.txt")