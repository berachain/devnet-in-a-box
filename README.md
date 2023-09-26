# How to run a 4-node local network



To run a 4 nodes test:
1. edit .env file
2. in terminal window 1: sh scripts/start_docker_compose.sh
3. in terminal window 2: sh scripts/network-init-4.sh
4. in terminal window 2: docker exec -it berad-node0 bash -c ./scripts/seed-start.sh
5. in terminal window 3: docker exec -it berad-node1 bash -c ./scripts/seed-start.sh
6. in terminal window 4: docker exec -it berad-node2 bash -c ./scripts/seed-start.sh
7. in terminal window 5: docker exec -it berad-node3 bash -c ./scripts/seed-start.sh

note: added "-it" in steps 4-7, so that ctrl+c can kill the process
