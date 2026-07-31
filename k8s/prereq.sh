#!/bin/bash

# deploy_cenm.sh with colorized output

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

echo -e "${YELLOW}Starting deployment process...${NC}"

# Step 1: Create namespace 'cenm'
echo -e "${YELLOW}Step 1: Creating namespace 'cenm'...${NC}"
kubectl create namespace cenm
if [[ $? -ne 0 ]]; then
  error_exit "Failed to create namespace 'cenm'"
else
  echo -e "${GREEN}Namespace 'cenm' created successfully.${NC}"
fi

# Step 2: Set the current context to use namespace 'cenm'
echo -e "${YELLOW}Step 2: Setting the current context to namespace 'cenm'...${NC}"
kubectl config set-context "$(kubectl config current-context)" --namespace=cenm
if [[ $? -ne 0 ]]; then
  error_exit "Failed to set context to namespace 'cenm'"
else
  echo -e "${GREEN}Context set to namespace 'cenm' successfully.${NC}"
fi

## Step 3: Apply StorageClass configuration (taken care with the first GKE deployment scripts - here only for debugging purpose)
#echo -e "${YELLOW}Step 3: Applying StorageClass configuration...${NC}"
#kubectl apply -f storage-class-googlecloud.yaml -n cenm
#if [[ $? -ne 0 ]]; then
#  error_exit "Failed to apply StorageClass configuration from storage-class-googlecloud.yaml"
#else
#  echo -e "${GREEN}StorageClass configuration applied successfully.${NC}"
#fi

# Step 4: Deploy cenm resources
echo -e "${YELLOW}Step 4: Deploying cenm resources...${NC}"
kubectl apply -f cenm.yaml
if [[ $? -ne 0 ]]; then
  error_exit "Failed to apply cenm deployment from cenm.yaml"
else
  echo -e "${GREEN}cenm deployment applied successfully.${NC}"
fi

# Step 5: Initialize Helm deployment
echo -e "${YELLOW}Step 5: Initializing Helm deployment...${NC}"
cd helm || error_exit "Failed to change directory to 'helm'"
./bootstrap.cenm --ACCEPT_LICENSE Y --auto
if [[ $? -ne 0 ]]; then
  error_exit "Helm bootstrap failed"
else
  echo -e "${GREEN}Helm deployment compled successfully.${NC}"
fi

echo -e "${GREEN}Deployment process completed successfully.${NC}"
