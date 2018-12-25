include "src/walletd.nim"

let wallet = initWallet(password = "password")
echo wallet.getStatus()
