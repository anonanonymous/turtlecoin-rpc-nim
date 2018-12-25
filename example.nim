include "src/walletd.nim", "src/turtlecoind.nim"

let wallet = initWallet(password = "<your password>")
let turtle_daemon = initTurtlecoind(host = "turtlenode.online")

echo wallet.getStatus
echo turtle_daemon.getCurrencyId
