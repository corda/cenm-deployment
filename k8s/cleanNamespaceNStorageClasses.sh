#!/bin/bash

# cleanup_cenm.sh with colorized output

# Define color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No color

# Function to print error messages in red and exit
error_exit() {
  echo -e "${RED}Error: $1${NC}"
  exit 1
}

echo -e "${YELLOW}Starting cleanup process...${NC}"

# Step 1: Delete the 'cenm-shared' StorageClass
echo -e "${YELLOW}Step 1: Deleting StorageClass 'cenm-shared'...${NC}"
kubectl delete storageclass cenm-shared
if [[ $? -ne 0 ]]; then
  error_exit "Failed to delete StorageClass 'cenm-shared'"
else
  echo -e "${GREEN}StorageClass 'cenm-shared' deleted successfully.${NC}"
fi

# Step 2: Delete the 'cenm' StorageClass
echo -e "${YELLOW}Step 2: Deleting StorageClass 'cenm'...${NC}"
kubectl delete storageclass cenm
if [[ $? -ne 0 ]]; then
  error_exit "Failed to delete StorageClass 'cenm'"
else
  echo -e "${GREEN}StorageClass 'cenm' deleted successfully.${NC}"
fi

# Step 3: Delete the 'cenm' namespace
echo -e "${YELLOW}Step 3: Deleting namespace 'cenm'...${NC}"
kubectl delete namespace cenm
if [[ $? -ne 0 ]]; then
  error_exit "Failed to delete namespace 'cenm'"
else
  echo -e "${GREEN}Namespace 'cenm' deleted successfully.${NC}"
fi

echo -e "${GREEN}Cleanup process completed successfully.${NC}"
