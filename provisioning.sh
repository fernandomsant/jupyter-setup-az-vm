#!/bin/bash

BASE_NAME=$(tr -dc 0-9a-z < /dev/urandom | head -c 10)

RESOURCE_GROUP="${BASE_NAME}_ResourceGroup"
LOCATION="eastus"
VM_NAME="${BASE_NAME}_VM"
ZONE="3"
SIZE="Standard_B2s"
IMAGE="Ubuntu2204"
USERNAME="azureuser"
SSH_KEY_NAME="${BASE_NAME}_key"
SSH_KEY_PATH="$HOME/.ssh/$SSH_KEY_NAME"

#az login

az group create --name $RESOURCE_GROUP --location $LOCATION

if [ ! -f "$SSH_KEY_PATH" ]; then
    ssh-keygen -t ed25519 -f "$SSH_KEY_PATH" -N ""
fi

IP_ADDRESS=$(az vm create \
  --resource-group $RESOURCE_GROUP \
  --name $VM_NAME \
  --image $IMAGE \
  --size $SIZE \
  --admin-username $USERNAME \
  --ssh-key-values "${SSH_KEY_PATH}.pub" \
  --zone $ZONE \
  --query publicIpAddress \
  -o tsv)

az vm open-port --resource-group $RESOURCE_GROUP --name $VM_NAME --port 22,8888

az vm extension set \
  --resource-group $RESOURCE_GROUP \
  --vm-name $VM_NAME \
  --name customScript \
  --publisher Microsoft.Azure.Extensions \
  --settings '{"fileUris": ["https://gist.githubusercontent.com/fernandomsant/91ca6d7a231760fa9c4167b48af0da2d/raw/93d1408694ce5c0ea2f384bf67b4568008652870/jupyter_setup.sh"], "commandToExecute": "./jupyter_setup.sh"}'

ssh-keyscan -H $IP_ADDRESS >> ~/.ssh/known_hosts

SERVER_LIST="$(ssh -i ${SSH_KEY_PATH} azureuser@${IP_ADDRESS} '$HOME/conda/bin/conda run -n jupyter_env jupyter server list')"
echo ${SERVER_LIST/"${BASE_NAME}VM"/${IP_ADDRESS}}