export const CONTACT_ADDRESS = '0xe93e3B649d4E01e47dd2170CAFEf0651477649Da'

export const CONTACT_ABI = [
    {
      "anonymous": false,
      "inputs": [
        {
          "indexed": true,
          "internalType": "address",
          "name": "previousOwner",
          "type": "address"
        },
        {
          "indexed": true,
          "internalType": "address",
          "name": "newOwner",
          "type": "address"
        }
      ],
      "name": "OwnershipTransferred",
      "type": "event"
    },
    {
      "inputs": [],
      "name": "explore",
      "outputs": [
        {
          "internalType": "contract ApiQueryClient",
          "name": "",
          "type": "address"
        }
      ],
      "stateMutability": "view",
      "type": "function",
      "constant": true
    },
    {
      "inputs": [],
      "name": "explorer",
      "outputs": [
        {
          "internalType": "contract ExplorerClient",
          "name": "",
          "type": "address"
        }
      ],
      "stateMutability": "view",
      "type": "function",
      "constant": true
    },
    {
      "inputs": [],
      "name": "hunt",
      "outputs": [
        {
          "internalType": "contract ApiQueryClient",
          "name": "",
          "type": "address"
        }
      ],
      "stateMutability": "view",
      "type": "function",
      "constant": true
    },
    {
      "inputs": [],
      "name": "owner",
      "outputs": [
        {
          "internalType": "address",
          "name": "",
          "type": "address"
        }
      ],
      "stateMutability": "view",
      "type": "function",
      "constant": true
    },
    {
      "inputs": [],
      "name": "renounceOwnership",
      "outputs": [],
      "stateMutability": "nonpayable",
      "type": "function"
    },
    {
      "inputs": [],
      "name": "train",
      "outputs": [
        {
          "internalType": "contract ApiQueryClient",
          "name": "",
          "type": "address"
        }
      ],
      "stateMutability": "view",
      "type": "function",
      "constant": true
    },
    {
      "inputs": [
        {
          "internalType": "address",
          "name": "newOwner",
          "type": "address"
        }
      ],
      "name": "transferOwnership",
      "outputs": [],
      "stateMutability": "nonpayable",
      "type": "function"
    },
    {
      "inputs": [
        {
          "internalType": "address",
          "name": "explorerAddress",
          "type": "address"
        }
      ],
      "name": "setExplorer",
      "outputs": [],
      "stateMutability": "nonpayable",
      "type": "function"
    },
    {
      "inputs": [
        {
          "internalType": "address",
          "name": "trainAddress",
          "type": "address"
        }
      ],
      "name": "setTrain",
      "outputs": [],
      "stateMutability": "nonpayable",
      "type": "function"
    },
    {
      "inputs": [
        {
          "internalType": "address",
          "name": "exploreAddress",
          "type": "address"
        }
      ],
      "name": "setExplore",
      "outputs": [],
      "stateMutability": "nonpayable",
      "type": "function"
    },
    {
      "inputs": [
        {
          "internalType": "address",
          "name": "huntAddress",
          "type": "address"
        }
      ],
      "name": "setHunt",
      "outputs": [],
      "stateMutability": "nonpayable",
      "type": "function"
    },
    {
      "inputs": [
        {
          "internalType": "uint256",
          "name": "tokenId",
          "type": "uint256"
        }
      ],
      "name": "queryByTokenId",
      "outputs": [
        {
          "components": [
            {
              "internalType": "uint8",
              "name": "status",
              "type": "uint8"
            },
            {
              "internalType": "bool",
              "name": "isDone",
              "type": "bool"
            },
            {
              "internalType": "uint8",
              "name": "mapId",
              "type": "uint8"
            },
            {
              "internalType": "uint8",
              "name": "occupation",
              "type": "uint8"
            },
            {
              "internalType": "uint256",
              "name": "startTime",
              "type": "uint256"
            },
            {
              "internalType": "uint256",
              "name": "reward",
              "type": "uint256"
            },
            {
              "internalType": "uint256",
              "name": "tokenId",
              "type": "uint256"
            },
            {
              "components": [
                {
                  "internalType": "uint8",
                  "name": "body",
                  "type": "uint8"
                },
                {
                  "internalType": "uint8",
                  "name": "eyes",
                  "type": "uint8"
                },
                {
                  "internalType": "uint8",
                  "name": "mouse",
                  "type": "uint8"
                },
                {
                  "internalType": "uint8",
                  "name": "pigtail",
                  "type": "uint8"
                },
                {
                  "internalType": "uint8",
                  "name": "helm",
                  "type": "uint8"
                },
                {
                  "internalType": "uint8",
                  "name": "weapon",
                  "type": "uint8"
                },
                {
                  "internalType": "uint8",
                  "name": "clothes",
                  "type": "uint8"
                },
                {
                  "internalType": "uint8",
                  "name": "feet",
                  "type": "uint8"
                },
                {
                  "internalType": "uint8",
                  "name": "back",
                  "type": "uint8"
                },
                {
                  "internalType": "uint16",
                  "name": "ability",
                  "type": "uint16"
                },
                {
                  "internalType": "uint16",
                  "name": "level",
                  "type": "uint16"
                },
                {
                  "internalType": "uint32",
                  "name": "lvlProgress",
                  "type": "uint32"
                }
              ],
              "internalType": "struct Explorers",
              "name": "explorer",
              "type": "tuple"
            }
          ],
          "internalType": "struct Api.Item",
          "name": "items",
          "type": "tuple"
        }
      ],
      "stateMutability": "view",
      "type": "function",
      "constant": true
    },
    {
      "inputs": [
        {
          "internalType": "bool",
          "name": "isAll",
          "type": "bool"
        },
        {
          "internalType": "enum Status",
          "name": "status",
          "type": "uint8"
        }
      ],
      "name": "queryByStatus",
      "outputs": [
        {
          "components": [
            {
              "internalType": "uint8",
              "name": "status",
              "type": "uint8"
            },
            {
              "internalType": "bool",
              "name": "isDone",
              "type": "bool"
            },
            {
              "internalType": "uint8",
              "name": "mapId",
              "type": "uint8"
            },
            {
              "internalType": "uint8",
              "name": "occupation",
              "type": "uint8"
            },
            {
              "internalType": "uint256",
              "name": "startTime",
              "type": "uint256"
            },
            {
              "internalType": "uint256",
              "name": "reward",
              "type": "uint256"
            },
            {
              "internalType": "uint256",
              "name": "tokenId",
              "type": "uint256"
            },
            {
              "components": [
                {
                  "internalType": "uint8",
                  "name": "body",
                  "type": "uint8"
                },
                {
                  "internalType": "uint8",
                  "name": "eyes",
                  "type": "uint8"
                },
                {
                  "internalType": "uint8",
                  "name": "mouse",
                  "type": "uint8"
                },
                {
                  "internalType": "uint8",
                  "name": "pigtail",
                  "type": "uint8"
                },
                {
                  "internalType": "uint8",
                  "name": "helm",
                  "type": "uint8"
                },
                {
                  "internalType": "uint8",
                  "name": "weapon",
                  "type": "uint8"
                },
                {
                  "internalType": "uint8",
                  "name": "clothes",
                  "type": "uint8"
                },
                {
                  "internalType": "uint8",
                  "name": "feet",
                  "type": "uint8"
                },
                {
                  "internalType": "uint8",
                  "name": "back",
                  "type": "uint8"
                },
                {
                  "internalType": "uint16",
                  "name": "ability",
                  "type": "uint16"
                },
                {
                  "internalType": "uint16",
                  "name": "level",
                  "type": "uint16"
                },
                {
                  "internalType": "uint32",
                  "name": "lvlProgress",
                  "type": "uint32"
                }
              ],
              "internalType": "struct Explorers",
              "name": "explorer",
              "type": "tuple"
            }
          ],
          "internalType": "struct Api.Item[]",
          "name": "items",
          "type": "tuple[]"
        },
        {
          "components": [
            {
              "internalType": "uint16",
              "name": "heroes",
              "type": "uint16"
            },
            {
              "internalType": "uint16",
              "name": "huntDone",
              "type": "uint16"
            },
            {
              "internalType": "uint16",
              "name": "raidDone",
              "type": "uint16"
            },
            {
              "internalType": "uint256",
              "name": "unclaimed",
              "type": "uint256"
            }
          ],
          "internalType": "struct Api.StatisticsInfo",
          "name": "statisticsInfo",
          "type": "tuple"
        }
      ],
      "stateMutability": "view",
      "type": "function",
      "constant": true
    },
    {
      "inputs": [
        {
          "internalType": "enum Status",
          "name": "status",
          "type": "uint8"
        },
        {
          "internalType": "uint256",
          "name": "mapId",
          "type": "uint256"
        }
      ],
      "name": "queryByMapId",
      "outputs": [
        {
          "components": [
            {
              "internalType": "uint8",
              "name": "status",
              "type": "uint8"
            },
            {
              "internalType": "bool",
              "name": "isDone",
              "type": "bool"
            },
            {
              "internalType": "uint8",
              "name": "mapId",
              "type": "uint8"
            },
            {
              "internalType": "uint8",
              "name": "occupation",
              "type": "uint8"
            },
            {
              "internalType": "uint256",
              "name": "startTime",
              "type": "uint256"
            },
            {
              "internalType": "uint256",
              "name": "reward",
              "type": "uint256"
            },
            {
              "internalType": "uint256",
              "name": "tokenId",
              "type": "uint256"
            },
            {
              "components": [
                {
                  "internalType": "uint8",
                  "name": "body",
                  "type": "uint8"
                },
                {
                  "internalType": "uint8",
                  "name": "eyes",
                  "type": "uint8"
                },
                {
                  "internalType": "uint8",
                  "name": "mouse",
                  "type": "uint8"
                },
                {
                  "internalType": "uint8",
                  "name": "pigtail",
                  "type": "uint8"
                },
                {
                  "internalType": "uint8",
                  "name": "helm",
                  "type": "uint8"
                },
                {
                  "internalType": "uint8",
                  "name": "weapon",
                  "type": "uint8"
                },
                {
                  "internalType": "uint8",
                  "name": "clothes",
                  "type": "uint8"
                },
                {
                  "internalType": "uint8",
                  "name": "feet",
                  "type": "uint8"
                },
                {
                  "internalType": "uint8",
                  "name": "back",
                  "type": "uint8"
                },
                {
                  "internalType": "uint16",
                  "name": "ability",
                  "type": "uint16"
                },
                {
                  "internalType": "uint16",
                  "name": "level",
                  "type": "uint16"
                },
                {
                  "internalType": "uint32",
                  "name": "lvlProgress",
                  "type": "uint32"
                }
              ],
              "internalType": "struct Explorers",
              "name": "explorer",
              "type": "tuple"
            }
          ],
          "internalType": "struct Api.Item[]",
          "name": "items",
          "type": "tuple[]"
        }
      ],
      "stateMutability": "view",
      "type": "function",
      "constant": true
    }
  ]