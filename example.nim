import json, walletd, turtlecoind

let wallet = initWallet(password = "<password>")
let turtle_daemon = initTurtlecoind(host = "val.turtlenode.online")

echo(wallet.getStatus)
echo(turtle_daemon.getCurrencyId)
