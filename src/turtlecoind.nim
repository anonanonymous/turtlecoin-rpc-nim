import httpclient, json

type
    Daemon = ref object
        client: HttpClient
        host: string
        port: string


# initTurtlecoind - creates a Daemon object to communicate with Turtlecoind
proc initTurtlecoind*(host = "localhost", port = "11898"): Daemon =
    var turtle = new(Daemon)

    turtle.client = newHttpClient()
    turtle.client.headers = newHttpHeaders({"Content-Type": "application/json"})
    turtle.host = host
    turtle.port = port
    return turtle


#[
    daemonPost - posts a command to Turtlecoind and returns the json response
    data -> rpc payload
]#
method daemonPost(dd: Daemon, data: string): JsonNode {.base.} =
    echo data
    let resp = dd.client.request("http://" & dd.host & ":" & dd.port & "/json_rpc",
                                 httpMethod = HttpPost,
                                 body = data)
    return parseJSON(resp.body)


#[
    doRequest - helper function for building rpc payloads
    methodd -> the rpc command
    params -> command parameters
]#
method doRequest(dd: Daemon, methodd, params=""): JsonNode {.base.} =
    let body = %*{
        "jsonrpc": "2.0",
        "method": methodd
    }
    if params != "":
        body["params"] = parseJSON(params)

    return dd.daemonPost($body)


# getBlockCount - gets the current chain height
method getBlockCount*(dd: Daemon): JsonNode {.base.} =
    return dd.doRequest("getblockcount", "{}")


# getBlockHash - returns block hash for a given height off by one
method getBlockHash*(dd: Daemon, height: int): JsonNode {.base.} =
    return dd.doRequest("on_getblockhash", "[" & $height & "]")


# getBlockTemplate - returns blocktemplate with an empty hole for nonce
method getBlockTemplate*(dd: Daemon, reserveSize: int, walletAddress: string): JsonNode {.base.} =
    let params = %*{
        "reserve_size": reserveSize,
        "wallet_address": walletAddress
    }
    
    return dd.doRequest("getblocktemplate", $params)


# submitBlock - submits mined block
method submitBlock*(dd: Daemon, blockBlob: string): JsonNode {.base.} =
    return dd.doRequest("submitblock", "[" & blockBlob & "]")


# getLastBlockHeader - returns last block header
method getLastBlockHeader*(dd: Daemon): JsonNode {.base.} =
    return dd.doRequest("getlastblockheader", "{}")


# getLastBlockHeaderByHash - returns last block header with the given hash
method getBlockHeaderByHash*(dd: Daemon, blockHash: string): JsonNode {.base.} =
    let params = %*{"hash": blockHash}
    return dd.doRequest("getblockheaderbyhash", $params)


# getBlockHeaderByHeight - returns last block header with the given height
method getBlockHeaderByHeight*(dd: Daemon, blockHeight: int): JsonNode {.base.} =
    let params = %*{"height": blockHeight}
    return dd.doRequest("getblockheaderbyheight", $params)


# getCurrencyId - returns unique currency identifier
method getCurrencyId*(dd: Daemon): JsonNode {.base.} =
    return dd.doRequest("getcurrencyid")


# getBlocks - returns information on the last 30 blocks from height
method getBlocks*(dd: Daemon, blockHeight: int): JsonNode {.base.} =
    let params = %*{"height": blockHeight}
    return dd.doRequest("f_blocks_list_json", $params)


# getBlock - returns information on a single block
method getBlock*(dd: Daemon, blockHash: string): JsonNode {.base.} =
    let params = %*{"hash": blockHash}
    return dd.doRequest("f_block_json", $params)


# getTransaction - returns information on a single transaction
method getTransaction*(dd: Daemon, blockHash: string): JsonNode {.base.} =
    let params = %*{"hash": blockHash}
    return dd.doRequest("f_transaction_json", $params)


# getTransactionPool - returns the list if transaction hashes present in the mempool
method getTransactionPool*(dd: Daemon): JsonNode {.base.} =
    return dd.doRequest("f_on_transactions_pool_json", "{}")

