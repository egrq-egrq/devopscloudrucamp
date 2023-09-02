#!/usr/bin/env bash

CLOUDRU_INVENTORY_FILE_PATH="./hosts.ini"
CLOUDRU_PLAYBOOK_PATH="./playbook.yml"

CLOUDRU_PLAYBOOK_FORKS="5"
CLOUDRU_PLAYBOOK_TAGS=""

# Display the help menu
print_help() {
    echo "Usage: $0 [-i INVENTORY] [-p PLAYBOOK] [-f CLOUDRU_PLAYBOOK_FORKS] [-t CLOUDRU_PLAYBOOK_TAGS]"
    echo ""
    echo "Options:"
    echo "    -i, --inventory    Specify the path to the Ansible inventory host file. The default is './hosts.ini'."
    echo "    -p, --playbook     Specify the path to the Ansible playbook file. The default is './playbook.yml'."
    echo "    -f, --forks        Specify the number of parallel processes to use while executing the playbook. This option is passed to the 'ansible-playbook' command using the '--forks' flag. The default is unset."
    echo "    -t, --tags         Run specific tasks that are tagged with the provided comma-separated list of tags. This option is passed to the 'ansible-playbook' command using the '--tags' flag. The default is unset."
    echo "    -h, --help         Display this help message."
    exit 1
}

# Parse command-line arguments
while [ $# -gt 0 ]; do
    case "$1" in
        -i|--inventory)
            CLOUDRU_INVENTORY_FILE_PATH="$2"
            shift 2
            ;;
        -p|--playbook)
            CLOUDRU_PLAYBOOK_PATH="$2"
            shift 2
            ;;
        -f|--forks)
            if [ -n "$2" ]; then
                CLOUDRU_PLAYBOOK_FORKS="$2"
            else
                CLOUDRU_PLAYBOOK_FORKS=""
            fi
            shift 2
            ;;
        -t|--tags)
            if [ -n "$2" ]; then
                CLOUDRU_PLAYBOOK_TAGS="$2"
            else
                CLOUDRU_PLAYBOOK_TAGS=""
            fi
            shift 2
            ;;
        -h|--help)
            print_help
            ;;
        *)
            echo "Unknown option: $1"
            print_help
            ;;
    esac
done

echo "Using inventory file: $CLOUDRU_INVENTORY_FILE_PATH"
echo "Using playbook file: $CLOUDRU_PLAYBOOK_PATH"
echo "Using forks: ${CLOUDRU_PLAYBOOK_FORKS:-unset}"
echo "Using tags: ${CLOUDRU_PLAYBOOK_TAGS:-unset}"

# Check for Ansible installation and inventory file existence
if ! command -v ansible &>/dev/null; then
    echo "Ansible not found. Please install it and try again."
    exit 1
fi

if [ ! -f "$CLOUDRU_INVENTORY_FILE_PATH" ]; then
    echo "$CLOUDRU_INVENTORY_FILE_PATH not found. Aborting."
    exit 1
fi

# Check playbook path existence
if [ ! -f "$CLOUDRU_PLAYBOOK_PATH" ]; then
    echo "$CLOUDRU_PLAYBOOK_PATH not found. Aborting."
    exit 1
fi

# Put extra args in an array
ARGUMENTS=()

if [ -n "$CLOUDRU_PLAYBOOK_FORKS" ]; then
    ARGUMENTS+=("--forks" "$CLOUDRU_PLAYBOOK_FORKS")
fi

if [ -n "$CLOUDRU_PLAYBOOK_TAGS" ]; then
    ARGUMENTS+=("--tags" "$CLOUDRU_PLAYBOOK_TAGS")
fi


# Run the playbook
ansible-playbook "$CLOUDRU_PLAYBOOK_PATH" -i "$CLOUDRU_INVENTORY_FILE_PATH" "${ARGUMENTS[@]}" --diff --force-handlers
