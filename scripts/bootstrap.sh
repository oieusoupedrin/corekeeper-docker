#!/bin/bash

main() {
    install_corekeeper
    run_corekeeper
    exec /bin/bash
}

install_corekeeper() {
    info "Installing Corekeeper"
    cd / \
        && su - corekeeper -c "/opt/steamcmd/steamcmd.sh +login anonymous +app_update 1007 +app_update 1963720 corekeeper +quit" 
}

run_corekeeper() {
    cd /home/corekeeper/Steam/steamapps/common/Core\ Keeper\ Dedicated\ Server/ \
    && chmod +x _launch.sh \
    && ./_launch.sh
}

main