#!/bin/sh

#  '\033[1;30m' # Bold Grey
GREY='\033[1;37m' # Bold White
YELLOW='\033[1;33m'
GREEN='\033[1;32m'
ORANGE='\033[91m'
RED='\033[1;31m'
NC='\033[0m' # No Color

if [ ! -e .env ]; then
  if [ -e .env.sample ]; then
    cp .env.sample .env
    printf "Cannot find .env file, ${YELLOW}creating from .env.sample, please fill it properly${NC} and make sure .env is set\n"
  else
    printf "Cannot find .env file, please run from ${YELLOW}{PROJECT_ROOT}/contract${NC} and make sure .env is set\n"
  fi
  exit 1
fi

# Load .env
export $(grep -v '^#' .env | xargs)

DEPLOY_RPC=
DEPLOY_CONTRACT=
DRY_RUN=1

printHelp() {
  printf "\nOptions:\n\n"
  printf "   ${GREEN}-h --help${NC}            ; ${GREY}shows this screen and exits${NC}\n"
  printf "   ${GREEN}-r --run${NC}             ; ${GREY}turns dry-run off (dry-run is on by default)${NC}\n"
  printf "   ${GREEN}-m --master${NC}          ; ${GREY}deploys the Master Vault${NC}\n"
  printf "   ${GREEN}-s --satellite${NC}       ; ${GREY}deploys the Satellite Vault${NC}\n"
  printf "   ${GREEN}-l --local${NC}           ; ${GREY}deploys locally (localhost)${NC}\n"
  printf "   ${GREEN}-t --testnet <CHAIN>${NC} ; ${GREY}deploys on <CHAIN> testnet from .env RPC, requires one the following parameter${NC}\n"
  printf "      ${GREY}CHAIN can be:${NC}\n"
  printf "        - ${GREEN}SEPOLIA${NC}       ; ${GREY}deploys on Sepolia:${NC}\n"
  printf "        - ${GREEN}ARBITRUM${NC}      ; ${GREY}deploys on Arbitrum testnet:${NC}\n"
  printf "      ${GREEN}--mainnet <CHAIN>${NC} ; ${GREY}deploys on <CHAIN> mainnet from .env RPC, requires one the following parameter${NC}\n"
  printf "      ${GREY}CHAIN can be:${NC}\n"
  printf "        - ${GREEN}ETH${NC}           ; ${GREY}deploys on Ethereum mainnet${NC}\n"
  printf "        - ${GREEN}ARBITRUM${NC}      ; ${GREY}deploys on Arbitrum mainnet${NC}\n"
  exit 0
}

args=("$@")

# Check args for --help flag first. We want to only print help and exit if that happens.
for arg in "${args[@]}"; do
  if [ "$arg" == "--help" ]; then
    printHelp
    exit 0
  fi
done

while (( $# )); do
  case "$1" in
    -r|--run)
      printf "${GREY}Selected \t\t\t${YELLOW}run mode (de-activating dry-run)${NC}\n"
      DRY_RUN=0
      shift 1
      ;;
    -m|--master)
      printf "${GREY}Selected contract: \t\t${GREEN}DeployZKBridgeMasterVault${NC}\n"
      DEPLOY_CONTRACT=script/DeployZKBridgeMasterVault.s.sol
      shift 1
      ;;
    -s|--satellite)
      printf "\n${GREY}Selected contract: \t\t${GREEN}DeployZKBridgeSatellite${NC}\n"
      DEPLOY_CONTRACT=script/DeployZKBridgeSatellite.s.sol
      shift 1
      ;;
    -l|--local)
      printf "\n${GREY}Selected local deployment \t${GREEN}${LOCAL_RPC}${NC}\n"
      DEPLOY_RPC=${LOCAL_RPC}
      shift 1
      ;;
    -t|--testnet)
      if [ -n $2 ] && [ $2 != -* ]; then
        case "$2" in
          SEPOLIA)
            DEPLOY_RPC=${TESTNET_ETH_SEPOLIA_RPC}
            printf "\n${GREY}Selected SEPOLIA deployment \t${GREEN}${DEPLOY_RPC}${NC}\n"
            ;;
          ARBITRUM)
            DEPLOY_RPC=${TESTNET_ARBITRUM_RPC}
            printf "\n${GREY}Selected ARBITRUM deployment \t${GREEN}${DEPLOY_RPC}${NC}\n"
            ;;
          *)
            printf "\n${YELLOW}Unknown network passed as an argument to ${GREEN}--testnet ($2)${YELLOW}, we will use localhost${NC}\n"
            DEPLOY_RPC=${LOCAL_RPC}
            ;;
        esac
        shift 2
      else
        printf "No network passed as an argument to --testnet ($2), we will use localhost\n"
        DEPLOY_RPC=${LOCAL_RPC}
        shift 1
      fi
      ;;
    --mainnet)
      if [ -n $2 ] && [ $2 != -* ]; then
        case "$2" in
          ETH)
            DEPLOY_RPC=${MAINNET_ETH_RPC}
            printf "\n${GREY}Selected ETH deployment \t${GREEN}${DEPLOY_RPC}${NC}\n"
            ;;
          ARBITRUM)
            DEPLOY_RPC=${MAINNET_ARBITRUM_RPC}
            printf "\n${GREY}Selected ARBITRUM deployment \t${GREEN}${DEPLOY_RPC}${NC}\n"
            ;;
          *)
            printf "No network passed as an argument to --mainnet ($2), exiting\n"
            exit 1
            ;;
        esac
        shift 2
      else
        printf "No network passed as an argument to --mainnet ($2), exiting\n"
        exit 1
      fi
      ;;
    *)
      printf "${YELLOW}Unknown flag $1 ${NC}\n"
      shift 1
      ;;
  esac
done

if [ -z "${DEPLOY_RPC}" ]; then
  printf "\n${RED}DEPLOY_RPC is empty${NC}, you need to choose en environment, either local, testnet + chain or mainnet + chain, see ${GREEN}--help${NC} for options\n"
  exit 1
fi

if [ -z "${DEPLOY_CONTRACT}" ]; then
  printf "\n${RED}DEPLOY_CONTRACT is empty${NC}, you need to specify what contract you want to deploy, either master or satellite, see ${GREEN}--help${NC} for more options\n"
  exit 1
fi

if [ -z "${PRIVATE_KEY}" ]; then
  printf "\n${RED}PRIVATE_KEY is empty${NC}, you need to specify the private keys to use to deploy, pass ${GREEN}PRIVATE_KEY${NC} as an environment variable or add it to the ${GREEN}.env${NC} file, see ${GREEN}--help${NC} for more options\n"
  exit 1
fi

printf "\n${YELLOW}Deploying the following parameters${NC}: \n - ${GREY}script${NC}: \t\t${GREEN}$DEPLOY_CONTRACT${NC} \n - ${GREY}fork-url${NC}: \t\t${GREEN}$DEPLOY_RPC${NC} \n - ${GREY}private-key${NC}: \t${GREEN}{...} ${NC}\n"

if [ ! ${DRY_RUN} -eq 0 ]; then
  printf "\n${YELLOW}dry-run only mode${NC}. If you are ready to go, pass -r or --run to execute. Dry-run is on by default, see ${GREEN}--help${NC} for more options\n"
else
  printf "\n\n ${GREEN}Running${NC}: \n\n\n"
  forge script $DEPLOY_CONTRACT --fork-url $DEPLOY_RPC --private-key $PRIVATE_KEY --broadcast
fi

printf "\n${GREY}done${NC}\n"