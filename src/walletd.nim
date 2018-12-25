import httpclient, json

type
    Wallet = ref object
        client: HttpClient
        host: string
        port: string
        password: string

const MIXIN = 3 # anonymity mixin level

#[
    initWallet - creates a Wallet object to communicate with walletd
    host -> the walletd rpc host
    port -> the walletd rpc port 
    Usage:
    wallet = initWallet(host = "localhost", port = 420, password = "hunter2")
]#
proc initWallet*(host="127.0.0.1", port="8070", password: string): Wallet =
    var wallet = new(Wallet)

    wallet.client = newHttpClient()
    wallet.client.headers = newHttpHeaders({"Content-Type": "application/json"})
    wallet.host = host
    wallet.port = port
    wallet.password = password

    return wallet


#[
    walletPost - posts a command to walletd and returns the json response
    data -> rpc payload
]#
method walletPost(w: Wallet, data: string): JsonNode {.base.} =
    let resp = w.client.request("http://" & w.host & ":" & w.port & "/json_rpc",
                                 httpMethod = HttpPost,
                                 body = data)
    return parseJSON(resp.body)


#[
    doRequest - helper function for building rpc payloads
    methodd -> the rpc command
    params -> command parameters
]#
method doRequest(w: Wallet, methodd, params=""): JsonNode {.base.} =
    let body = %*{
        "jsonrpc": "2.0",
        "password": w.password,
        "method": methodd
    }
    if params != "":
        body["params"] = parseJSON(params)

    return w.walletPost($body)


#[
    reset - allows you to re-sync your wallet
    Usage:
    wallet.reset(viewSpendKey = "<64 char hex>")
]#
method reset*(w: Wallet, scanHeight=0, viewSecretKey=""): JsonNode {.base.} =
    var params = %*{"scanHeight": scanHeight}

    if viewSecretKey != "":
        params["viewSecretKey"] = %viewSecretKey

    return w.doRequest("reset", $params)


#[
    save - allows you to save your wallet by request
    Usage:
    wallet.save()
]#
method save*(w: Wallet): JsonNode {.base.} =
    return w.doRequest("save")


#[
    getViewKey - returns your view key
    Usage:
    wallet.getViewKey()
]#
method getViewKey*(w: Wallet): JsonNode {.base.} =
    return w.doRequest("getViewKey")


#[
    getSpendKeys - returns your spend keys
    Usage:
    wallet.getSpendKeys()
]#
method getSpendKeys*(w: Wallet, address: string): JsonNode {.base.} =
    let params = %*{"address": address}
    return w.doRequest("getSpendKeys", $params)


#[
    getMnemonicSeed - returns the mnemonic seed for the given deterministic address
    Usage:
    wallet.getMnemonicSeed()
]#
method getMnemonicSeed*(w: Wallet, address: string): JsonNode {.base.} =
    let params = %*{"address": address}
    return w.doRequest("getMnemonicSeed", $params)


#[
    getStatus - returns information about the current RPC Wallet state:
    block count, known block count, last block hash and peer count
    Usage:
    wallet.getStatus()
]#
method getStatus*(w: Wallet): JsonNode {.base.} =
    return w.doRequest("getStatus")


#[
    getAddresses - returns an array of your RPC Wallet's addresses
    Usage:
    wallet.getAddresses()
]#
method getAddresses*(w: Wallet): JsonNode {.base.} =
    return w.doRequest("getAddresses")


#[
    createAddress - creates an additional address in your wallet
    Usage:
    wallet.createAddress(secretSpendKey = "<64 char hex>",
                         publicSpendKey = "<64 char hex>")
]#
method createAddress*(w: Wallet, secretSpendKey="", publicSpendKey="",
                      scanHeight=0, newAddress=true): JsonNode {.base.} =
    var params = %*{
        "newAddress": newAddress
    }
    if secretSpendKey != "":
        params["secretSpendKey"] = %secretSpendKey
    if publicSpendKey != "":
        params["publicSpendKey"] = %publicSpendKey
    if secretSpendKey != "" and publicSpendKey != "":
        params["scanHeight"] = %scanHeight

    return w.doRequest("createAddress", $params)


#[
    deleteAddress - deletes a specified address
    Usage:
    wallet.deleteAddress("TRTL..")
]#
method deleteAddress*(w: Wallet, address: string): JsonNode {.base.} =
    let params = %*{"address": address}
    return w.doRequest("deleteAddress", $params)


#[
    getBalance - returns a balance for a specified address
    Usage:
    wallet.getBalance("TRTL..")
]#
method getBalance*(w: Wallet, address: string): JsonNode {.base.} =
    let params = %*{"address": address}
    return w.doRequest("getBalance", $params)


#[
    getBlockHashes - returns an array of block hashes for a specified block range
    Usage:
    wallet.getBlockHashes(1000, 1000)
]#
method getBlockHashes*(w: Wallet, firstBlockIndex, blockCount: int): JsonNode {.base.} =
    let params = %*{
        "firstBlockIndex": firstBlockIndex,
        "blockCount": blockCount
    }

    return w.doRequest("getBlockHashes", $params)


#[
    getTransactionHashes - returns an array of block and transaction hashes
    Usage:
    wallet.getTransactionHashes(@["TRTL..", "TRTL..."], 1000, 1000)
]#
method getTransactionHashes*(w: Wallet, addresses: seq[string] = @[], blockHash="",
                            firstBlockIndex=0, blockCount: int,
                            paymentId=""): JsonNode {.base.} =
    var params = %*{"blockCount": blockCount}

    if addresses.len > 0:
        params["address"] = %addresses

    if blockHash != "":
        params["blockHash"] = %blockHash
    else:
        params["firstBlockIndex"] = % firstBlockIndex

    if paymentId != "":
        params["paymentId"] = %paymentId

    return w.doRequest("getTransactionHashes", $params)


#[
    getTransactions - returns an array of block and transaction hashes
    Usage:
    wallet.getTransactions(@["TRTL..", "TRTL..."], 1000, 1000)
]#
method getTransactions*(w: Wallet, addresses: seq[string] = @[], blockHash="",
                       firstBlockIndex=0, blockCount: int,
                       paymentId=""): JsonNode {.base.} =
    var params = %*{"blockCount": blockCount}
    if addresses.len > 0:
        params["address"] = %addresses

    if blockHash != "":
        params["blockHash"] = %blockHash
    else:
        params["firstBlockIndex"] = % firstBlockIndex

    if paymentId != "":
        params["paymentId"] = %paymentId

    return w.doRequest("getTransactionHashes", $params)


#[
    getUnconfirmedTransactionHashes - returns information about the current unconfirmed
                                      transaction pool or for a specified addresses
    Usage:
    wallet.getUnconfirmedTransactionHashes(@["TRTL...", "TRTL..."])
]#
method getUnconfirmedTransactionHashes*(w: Wallet, addresses: seq[string] = @[]): JsonNode {.base.} =
    var params = %*{}

    if addresses.len > 0:
        params["addresses"] = %addresses

    return w.doRequest("getUnconfirmedTransactionHashes", $params)


#[
    getTransaction - returns information about a particular transaction
    Usage:
    wallet.getTransaction("<64 char hex string>")
]#
method getTransaction*(w: Wallet, transactionHash: string): JsonNode {.base.} =
    let params = %*{"transactionHash": transactionHash}
    return w.doRequest("getTransaction", $params)


#[
    sendTransaction - allows you to send transaction(s) to one or several addresses
    Usage:
    wallet.sendTransaction(addresses = @["TRTL...", "TRTL..."],
                                    transfers = %*[{"address": "TRTL..", "amount":420}],
                                    changeAddress = "TRTL...")
]#
method sendTransaction*(w: Wallet, addresses: seq[string] = @[],
                       transfers: JsonNode, fee=10, unlockTime=0,
                       anonymity=MIXIN, extra="", paymentId="",
                       changeAddress=""): JsonNode {.base.} =

    if extra != "" and paymentId != "":
        raise newException(ValueError, "cannot set paymentId and extra together")

    var params = %*{
        "transfers": transfers,
        "fee": fee,
        "anonymity": anonymity,
        "unlockTime": unlockTime
    }

    if addresses.len > 0:
        params["addresses"] = %addresses
    if extra != "":
        params["extra"] = %extra
    if paymentId != "":
        params["paymentId"] = %paymentId
    if changeAddress != "":
        params["changeAddress"] = %changeAddress

    return w.doRequest("sendTransaction", $params)


#[
    createDelayedTransaction - creates a delayed transaction
    Usage:
    wallet.createDelayedTransaction(addresses = @["TRTL...", "TRTL..."],
                                    transfers = %*[{"address": "TRTL..", "amount":420}],
                                    changeAddress = "TRTL...")
]#
method createDelayedTransaction*(w: Wallet, addresses: seq[string] = @[],
                       transfers: JsonNode, fee=10, unlockTime=0,
                       anonymity=MIXIN, extra="", paymentId="",
                       changeAddress=""): JsonNode {.base.} =
    if extra != "" and paymentId != "":
        raise newException(ValueError, "cannot set paymentId and extra together")

    var params = %*{
        "transfers": transfers,
        "fee": fee,
        "anonymity": anonymity,
        "unlockTime": unlockTime
    }

    if addresses.len > 0:
        params["addresses"] = %addresses
    if extra != "":
        params["extra"] = %extra
    if paymentId != "":
        params["paymentId"] = %paymentId
    if changeAddress != "":
        params["changeAddress"] = %changeAddress

    return w.doRequest("createDelayedTransaction", $params)


#[
    getDelayedTransactionHashes - returns hashes of delayed transactions
    Usage:
    wallet.getDelayedTransactionHashes()
]#
method getDelayedTransactionHashes*(w: Wallet): JsonNode {.base.} =
    return w.doRequest("getDelayedTransactionHashes")


#[
    deleteDelayedTransaction - deletes the specified delayed transaction
    Usage:
    wallet.deleteDelayedTransaction("<64 char hex string>")
]#
method deleteDelayedTransaction*(w: Wallet, transactionHash: string): JsonNode {.base.} =
    let params = %*{"transactionHash": transactionHash}
    return w.doRequest("deleteDelayedTransaction", $params)


#[
    sendDelayedTransaction - sends a specified delayed transaction
    Usage:
    wallet.sendDelayedTransaction("<64 char hex string>")
]#
method sendDelayedTransaction*(w: Wallet, transactionHash: string): JsonNode {.base.} =
    let params = %*{"transactionHash": transactionHash}
    return w.doRequest("sendDelayedTransaction", $params)
    

#[
    sendFusionTransaction - allows you to send a fusion transaction,
                            by taking funds from selected addresses and transferring them
                            to the destination address
    Usage:
    wallet.sendFusionTransaction(threshold = 420, addresses = @["TRTL..."],
                                 destinationAddr = "TRTL..")
]#
method sendFusionTransaction*(w: Wallet, threshold, anonymity=MIXIN,
                             addresses: seq[string] = @[],
                             destinationAddr=""): JsonNode {.base.} =
    var params = %*{
        "threshold": threshold,
        "anonymity": anonymity,
    }
    if addresses.len > 0:
        params["addresses"] = %addresses
    if destinationAddr != "":
        params["destinationAddress"] = %destinationAddr

    return w.doRequest("sendFusionTransaction", $params)


#[
    estimateFusion - counts the number of unspent outputs of the
                     specified addresses and returns how many of those
                     outputs can be optimized
    Usage:
    wallet.estimateFusion(threshold = 420, addresses = @["TRTL.."])
    
]#
method estimateFusion*(w: Wallet, threshold: int,
                      addresses: seq[string] = @[]): JsonNode {.base.} =
    var params = %*{"threshold": threshold}
    if addresses.len > 0:
        params["addresses"] = %addresses

    return w.doRequest("estimateFusion", $params)


#[
    createIntegratedAddress - allows you to create a combined address,
                              containing a standard address and a paymentId
    Usage:
    wallet.createIntegratedAddress("TRTL..", "<64 char hex string>")
]#
method createIntegratedAddress*(w: Wallet, address, paymentId: string): JsonNode {.base.} =
    let params =  %*{
        "address": address,
        "paymentId": paymentId
    }

    return w.doRequest("createIntegratedAddress", $params)


#[
    getFeeInfo - retrieves the fee and address (if any) that
                 TurtleCoind walletd is connecting to is using
    Usage:
    wallet.getFeeInfo()
]#
method getFeeInfo*(w: Wallet): JsonNode {.base.} =
    return w.doRequest("getFeeInfo")
