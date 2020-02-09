#!/usr/bin/env bash

set -e # abort on error
set -u # abort on undefined variable

USER=$(whoami) # use the same local username, as it relates to $HOME for user running the scripts
# TODO: Get username from terraform output to match configured user

###############################################################################
# Set variables from terraform output
###############################################################################

LOCAL_SSH_PUB_KEY_PATH=$(cat output.json | python3 -c 'import json,sys;obj=json.load(sys.stdin);print (obj["ssh_pub_key_path"]["value"])')
LOCAL_SSH_PRV_KEY_PATH=$(cat output.json | python3 -c 'import json,sys;obj=json.load(sys.stdin);print (obj["ssh_prv_key_path"]["value"])')

[ "$LOCAL_SSH_PUB_KEY_PATH" ] || ( echo "ERROR: LOCAL_SSH_PUB_KEY_PATH is empty" && exit 1 )
[ "$LOCAL_SSH_PRV_KEY_PATH" ] || ( echo "ERROR: LOCAL_SSH_PRV_KEY_PATH is empty" && exit 1 )

EPIC_DL_URL="$(cat output.json | python3 -c 'import json,sys;obj=json.load(sys.stdin);print (obj["bluedata_image_url"]["value"])')"
EPIC_FILENAME="$(echo ${EPIC_DL_URL##*/} | cut -d? -f1)"

echo EPIC_DL_URL=$EPIC_DL_URL
echo EPIC_FILENAME=$EPIC_FILENAME

[ "$EPIC_DL_URL" ] || ( echo "ERROR: EPIC_DL_URL is empty" && exit 1 )
[ "$EPIC_FILENAME" ] || ( echo "ERROR: EPIC_FILENAME is empty" && exit 1 )


SELINUX_DISABLED="$(cat output.json | python3 -c 'import json,sys;obj=json.load(sys.stdin);print (obj["selinux_disabled"]["value"])')"
echo SELINUX_DISABLED=$SELINUX_DISABLED
[ "$SELINUX_DISABLED" ] || ( echo "ERROR: SELINUX_DISABLED is empty" && exit 1 )


CTRL_PRV_IP=$(cat output.json | python3 -c 'import json,sys;obj=json.load(sys.stdin);print (obj["controller_private_ip"]["value"])') 
CTRL_PUB_IP=$(cat output.json | python3 -c 'import json,sys;obj=json.load(sys.stdin);print (obj["controller_public_ip"]["value"])') 

echo CTRL_PRV_IP=$CTRL_PRV_IP
echo CTRL_PUB_IP=$CTRL_PUB_IP

[ "$CTRL_PRV_IP" ] || ( echo "ERROR: CTRL_PRV_IP is empty" && exit 1 )
[ "$CTRL_PUB_IP" ] || ( echo "ERROR: CTRL_PUB_IP is empty" && exit 1 )

GATW_PRV_IP=$(cat output.json | python3 -c 'import json,sys;obj=json.load(sys.stdin);print (obj["gateway_private_ip"]["value"])') 
GATW_PUB_IP=$(cat output.json | python3 -c 'import json,sys;obj=json.load(sys.stdin);print (obj["gateway_public_ip"]["value"])') 

echo GATW_PRV_IP=$GATW_PRV_IP
echo GATW_PUB_IP=$GATW_PUB_IP

[ "$GATW_PRV_IP" ] || ( echo "ERROR: GATW_PRV_IP is empty" && exit 1 )
[ "$GATW_PUB_IP" ] || ( echo "ERROR: GATW_PUB_IP is empty" && exit 1 )

WRKR_PRV_IPS=$(cat output.json | python3 -c 'import json,sys;obj=json.load(sys.stdin);print (*obj["workers_private_ip"]["value"], sep=" ")') 

[ "$WRKR_PRV_IPS" ] || ( echo "ERROR: WRKR_PRV_IPS is empty" && exit 1 )

read -r -a WRKR_PRV_IPS <<< "$WRKR_PRV_IPS"

echo WRKR_PRV_IPS=${WRKR_PRV_IPS[@]}

###############################################################################
# Test SSH connectivity to VMs from local machine
###############################################################################

# Azure creates VM OS disk 30GB by default, need to resize
declare -a SERVERS=(${CTRL_PUB_IP} ${GATW_PUB_IP})

for SRV in ${SERVERS[@]}; do
   ssh -o StrictHostKeyChecking=no -i ${LOCAL_SSH_PRV_KEY_PATH} -T ${USER}@${SRV} -n 'bash -s' < ./server-prepare-fdisk.sh

   echo "Waiting for ${SRV} ssh session "
   while ! nc -w5 -z ${SRV} 22; do printf "." -n ; done;
   echo "${SRV}: now checking updates"

   ssh -o StrictHostKeyChecking=no -i ${LOCAL_SSH_PRV_KEY_PATH} -T ${USER}@${SRV} -n 'bash -s' < ./server-prepare-yum.sh
done

###############################################################################
# Setup SSH keys for passwordless SSH
###############################################################################

# if ssh key doesn't exist on controller EC instance then create one
ssh -o StrictHostKeyChecking=no -i ${LOCAL_SSH_PRV_KEY_PATH} -T ${USER}@${CTRL_PUB_IP} << ENDSSH
if [ -f ~/.ssh/id_rsa ]
then
   echo CONTROLLER: Found existing ~/.ssh/id.rsa so moving on...
else
   ssh-keygen -t rsa -N "" -f ~/.ssh/id_rsa
   echo CONTROLLER: Created ~/.ssh/id_rsa
fi
# BlueData controller installer requires this - TODO only add if it doesn't already exist
cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
ENDSSH

# I need this to connect to workers temporarily
scp -o StrictHostKeyChecking=no -i ${LOCAL_SSH_PRV_KEY_PATH} ${HOME}/.ssh/id_rsa ${USER}@${CTRL_PUB_IP}:/home/${USER}/.ssh/id_rsa.global

#
# Controller -> Gateway
#

# We have password SSH access from our local machines, so we can utiise this to copy the Controller SSH key to the Gateway
ssh -o StrictHostKeyChecking=no -i ${LOCAL_SSH_PRV_KEY_PATH} -T ${USER}@${CTRL_PUB_IP} "cat /home/${USER}/.ssh/id_rsa.pub" | \
  ssh -o StrictHostKeyChecking=no -i ${LOCAL_SSH_PRV_KEY_PATH} -T ${USER}@${GATW_PUB_IP} "cat >> /home/${USER}/.ssh/authorized_keys" 

# test passwordless SSH connection from Controller to Gateway
ssh -o StrictHostKeyChecking=no -i ${LOCAL_SSH_PRV_KEY_PATH} -T ${USER}@${CTRL_PUB_IP} << ENDSSH
echo CONTROLLER: Connecting to GATEWAY ${GATW_PRV_IP}...
ssh -o ConnectTimeout=10 -o StrictHostKeyChecking=no -i ~/.ssh/id_rsa -T ${USER}@${GATW_PRV_IP} "echo Connected!"
ENDSSH

#
# Controller -> Workers
#

# We don't have password SSH access from our local machines to all VMs, so we should copy the Controller SSH key to each Worker locally
for WRKR in ${WRKR_PRV_IPS[@]}; do 
   ssh -o StrictHostKeyChecking=no -i ${LOCAL_SSH_PRV_KEY_PATH} -T ${USER}@${CTRL_PUB_IP} "cat /home/${USER}/.ssh/id_rsa.pub | \
      ssh -o StrictHostKeyChecking=no -i /home/${USER}/.ssh/id_rsa.global -T ${USER}@${WRKR} \"cat >> /home/${USER}/.ssh/authorized_keys\" " 
done

# test passwordless SSH connection from Controller to Workers
for WRKR in ${WRKR_PRV_IPS[@]}; do 
    ssh -o StrictHostKeyChecking=no -i ${LOCAL_SSH_PRV_KEY_PATH} -T ${USER}@${CTRL_PUB_IP} << ENDSSH
        echo CONTROLLER: Connecting to WORKER ${WRKR}...
        ssh -o ConnectTimeout=10 -o StrictHostKeyChecking=no -i ~/.ssh/id_rsa -T ${USER}@${WRKR} "echo Connected!"
ENDSSH
done

# If all keys are copied successfully for paswordless SSH, then safe to delete private key
ssh -o StrictHostKeyChecking=no -i ${LOCAL_SSH_PRV_KEY_PATH} -T ${USER}@${CTRL_PUB_IP} "rm /home/${USER}/.ssh/id_rsa.global"


#
# Workers
#
echo 'Waiting for Controller ssh session '
while ! nc -w5 -z ${CTRL_PUB_IP} 22; do printf "." -n ; done;
echo 'Controller checking worker connections...'

for WRKR in ${WRKR_PRV_IPS[@]}; do 
   ssh -o StrictHostKeyChecking=no -i ${LOCAL_SSH_PRV_KEY_PATH} -T ${USER}@${CTRL_PUB_IP} -n "bash -s" ssh ${USER}@${WRKR} -n <<EOF
      sudo xfs_growfs /dev/sda2
      yum check-update
      if [ $? == 100 ]; then
         echo "Installing updates"
         sudo yum -y update
         nohup sudo reboot </dev/null &
         echo "$(hostname) rebooting..."
      else
         echo "No updates pending..."
      fi
EOF

echo "Updated worker ${WRKR}..."

done


###############################################################################
# Install Controller
###############################################################################

echo "Starting image download and installation..."

ssh -o StrictHostKeyChecking=no -i ${LOCAL_SSH_PRV_KEY_PATH} -T ${USER}@${CTRL_PUB_IP} << ENDSSH
   curl -s -o ${EPIC_FILENAME} "${EPIC_DL_URL}"
   chmod +x ${EPIC_FILENAME}
   # install EPIC
   ./${EPIC_FILENAME} --skipeula
   # install application workbench
   sudo yum install -y epel-release
   sudo yum install -y python-pip
   sudo pip install --upgrade pip
   sudo pip install --upgrade setuptools
   sudo pip install --upgrade bdworkbench
ENDSSH

###############################################################################
# Manually configure Controller with Workers and Gateway
###############################################################################

# retrive controller ssh private key and save it locally
ssh -o StrictHostKeyChecking=no -i ${LOCAL_SSH_PRV_KEY_PATH} ${USER}@${CTRL_PUB_IP} 'cat ~/.ssh/id_rsa' > generated/controller.prv_key

cat << EOF
*********************************************************
*      BlueData installation completed successfully     *
*********************************************************
SSH Private key has been downloaded to 'generated/controller.prv_key'
** PLEASE KEEP IT SECURE **
INSTRUCTIONS for completing the BlueData installation ...
0. In your browser, navigate to the Controller URL: http://${CTRL_PUB_IP}"
1. At the setup screen, click 'Submit'
2. At the login screen, use 'admin/admin123'
3. Naviate to Settings -> License:
   1. Request a license from your BlueData sales engineer contact
   2. Upload the license
4. Navigate to Installation tab:
   1. Add workers private ips "$(echo ${WRKR_PRV_IPS[@]} | sed -e 's/ /,/g')"
   2. Add gateway private ip "${GATW_PRV_IP}" and public dns "${GATW_PUB_DNS}"
   3. Upload generated/controller.prv_key
   4. Click Add hosts (enter site lock down when prompted)
   # After a few minutes, you should see Gateway 'Installed' and Workers 'Bundle completed'
   5. Select each Worker
   6. Click 'Install'
   7. Wait a few minutes
EOF
