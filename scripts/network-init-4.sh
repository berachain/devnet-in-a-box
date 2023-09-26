# SPDX-License-Identifier: BUSL-1.1
#
# Copyright (C) 2023, Berachain Foundation. All rights reserved.
# Use of this software is govered by the Business Source License included
# in the LICENSE file of this repository and at www.mariadb.com/bsl11.
#
# ANY USE OF THE LICENSED WORK IN VIOLATION OF THIS LICENSE WILL AUTOMATICALLY
# TERMINATE YOUR RIGHTS UNDER THIS LICENSE FOR THE CURRENT AND ALL OTHER
# VERSIONS OF THE LICENSED WORK.
#
# THIS LICENSE DOES NOT GRANT YOU ANY RIGHT IN ANY TRADEMARK OR LOGO OF
# LICENSOR OR ITS AFFILIATES (PROVIDED THAT YOU MAY USE A TRADEMARK OR LOGO OF
# LICENSOR AS EXPRESSLY REQUIRED BY THIS LICENSE).
#
# TO THE EXTENT PERMITTED BY APPLICABLE LAW, THE LICENSED WORK IS PROVIDED ON
# AN “AS IS” BASIS. LICENSOR HEREBY DISCLAIMS ALL WARRANTIES AND CONDITIONS,
# EXPRESS OR IMPLIED, INCLUDING (WITHOUT LIMITATION) WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, NON-INFRINGEMENT, AND
# TITLE.

eval $(cat .env)

CONTAINER0="berad-node0"
CONTAINER1="berad-node1"
CONTAINER2="berad-node2"
CONTAINER3="berad-node3"

HOMEDIR="/root/.berad"
SCRIPTS="/scripts"

rm -rf ${MOUNT_PATH}
mkdir ${MOUNT_PATH}
mkdir ${MOUNT_PATH}/seed0
mkdir ${MOUNT_PATH}/seed1
mkdir ${MOUNT_PATH}/seed2
mkdir ${MOUNT_PATH}/seed3
touch ${MOUNT_PATH}/genesis.json

# init step 1 
docker exec $CONTAINER0 bash -c "$SCRIPTS/seed0-init-step1.sh"
docker exec $CONTAINER1 bash -c "$SCRIPTS/seed1-init-step1.sh seed-1"
docker exec $CONTAINER2 bash -c "$SCRIPTS/seed1-init-step1.sh seed-2"
docker exec $CONTAINER3 bash -c "$SCRIPTS/seed1-init-step1.sh seed-3"

# Overwrite config files
for CONTAINER in $CONTAINER0 $CONTAINER1 $CONTAINER2 $CONTAINER3
do
    docker cp config/app.toml $CONTAINER:$HOMEDIR/config/app.toml
    docker cp config/config.toml $CONTAINER:$HOMEDIR/config/config.toml
done

docker exec $CONTAINER0 bash -c "$SCRIPTS/set-moniker.sh seed-0"
docker exec $CONTAINER1 bash -c "$SCRIPTS/set-moniker.sh seed-1"
docker exec $CONTAINER2 bash -c "$SCRIPTS/set-moniker.sh seed-2"
docker exec $CONTAINER3 bash -c "$SCRIPTS/set-moniker.sh seed-3"


# copy genesis.json from seed-0 to seed-1
docker cp $CONTAINER0:$HOMEDIR/config/genesis.json ${MOUNT_PATH}/genesis.json
docker cp ${MOUNT_PATH}/genesis.json $CONTAINER1:$HOMEDIR/config/genesis.json

# init step 2
docker exec $CONTAINER1 bash -c "$SCRIPTS/seed1-init-step2.sh seed-1"

# copy genesis.json from seed-1 to seed-2
docker cp $CONTAINER1:$HOMEDIR/config/genesis.json ${MOUNT_PATH}/genesis.json
docker cp ${MOUNT_PATH}/genesis.json $CONTAINER2:$HOMEDIR/config/genesis.json

# init step 2
docker exec $CONTAINER2 bash -c "$SCRIPTS/seed1-init-step2.sh seed-2"

# copy genesis.json from seed-2 to seed-3
docker cp $CONTAINER2:$HOMEDIR/config/genesis.json ${MOUNT_PATH}/genesis.json
docker cp ${MOUNT_PATH}/genesis.json $CONTAINER3:$HOMEDIR/config/genesis.json

# init step 2
docker exec $CONTAINER3 bash -c "$SCRIPTS/seed1-init-step2.sh seed-3"


# copy genesis.json from seed-3 to seed-0
docker cp $CONTAINER3:$HOMEDIR/config/genesis.json ${MOUNT_PATH}/genesis.json
docker cp ${MOUNT_PATH}/genesis.json $CONTAINER0:$HOMEDIR/config/genesis.json

# copy gentx
docker cp $CONTAINER1:$HOMEDIR/config/gentx ${MOUNT_PATH}
docker cp $CONTAINER2:$HOMEDIR/config/gentx ${MOUNT_PATH}
docker cp $CONTAINER3:$HOMEDIR/config/gentx ${MOUNT_PATH}
docker cp ${MOUNT_PATH}/gentx $CONTAINER0:$HOMEDIR/config 

# init step 2
docker exec $CONTAINER0 bash -c "$SCRIPTS/seed0-init-step2.sh"

# copy genesis.json from seed-0 to seed-1,2,3
docker cp $CONTAINER0:$HOMEDIR/config/genesis.json ${MOUNT_PATH}/genesis.json
docker cp ${MOUNT_PATH}/genesis.json $CONTAINER1:$HOMEDIR/config/genesis.json
docker cp ${MOUNT_PATH}/genesis.json $CONTAINER2:$HOMEDIR/config/genesis.json
docker cp ${MOUNT_PATH}/genesis.json $CONTAINER3:$HOMEDIR/config/genesis.json

# start
# docker exec -it berad-node0 bash -c "/scripts/seed-start.sh"
# docker exec -it berad-node1 bash -c "/scripts/seed-start.sh"
# docker exec -it berad-node2 bash -c "/scripts/seed-start.sh"
# docker exec -it berad-node3 bash -c "/scripts/seed-start.sh"
