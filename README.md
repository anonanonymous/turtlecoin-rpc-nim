![](https://gateway.ipfs.io/ipfs/QmSxM4sRJwggPHvgT8YCJuUsPnhHakY93tGttZzRrVJTfQ)
# TurtleCoin RPC Nim

A nim wrapper for the turtlecoin rpc interface

### Installation
```
nimble install https://github.com/anonanonymous/turtlecoin-rpc-nim
```

### Dependencies
Nim 0.19
* Arch Linux: `sudu pacman -Sy nim nimble`
* Ubuntu / Debian: `sudo apt update; sudo apt install nim nimble`

### Quick Start
Open `example.nim` and initialize a `Wallet` instance using your daemon configuration  
The default host and port are used if they are not specified.  
```let wallet = initWallet(host = "<hostname>", port = <port number>, password = "your password")```  
Compile and run using  `nim c -r -d:release example.nim`  

