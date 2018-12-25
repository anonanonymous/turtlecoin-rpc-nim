#[
    To run these tests, make sure you have walletd running and fully synced.
To run these tests, simply execute `nimble test`.

]#

import unittest
include "../src/walletd.nim"

let wallet = initWallet(password="pass")
let privsk = "522189e5f64519d87a82981a99c48b1d149c08d660c4ab37c77b64e3f3572300"
let privvk = "66a73b90665cbee550f3c9e4e9390aa93ff2ff2290989b47f9c1abc630d37b0c"
let pubsk = "42b660f308e767d755845181b09b35eebffbbf15b175123a83f2c3fc11e021ed"
var tempAddr: string

test "getStatus":
    let resp = wallet.getStatus
    echo resp

test "save":
    echo wallet.save

test "getViewKey":
    echo wallet.getViewKey

test "getSpendKeys":
    echo wallet.getSpendKeys("TRTLuzqKu5LJFc9YfdYESRW2xHXGDLLEfY2ZwH6VTgbo8JcUGVa4uzxX9vamnUcG35BkQy6VfwUy5CsV9YNomioPGGyVhHBTHGU")

test "getMnemonicSeed":
    echo wallet.getMnemonicSeed("TRTLuzqKu5LJFc9YfdYESRW2xHXGDLLEfY2ZwH6VTgbo8JcUGVa4uzxX9vamnUcG35BkQy6VfwUy5CsV9YNomioPGGyVhHBTHGU")

test "getAddresses":
    echo wallet.getAddresses

test "createAddress":
    let resp = wallet.createAddress(secretSpendKey=privsk, newAddress=true)
    echo resp
    tempAddr = resp["result"]["address"].getStr()
    echo tempAddr

test "deleteAddress":
    echo wallet.deleteAddress(tempAddr)

test "getBalance":
    echo wallet.getBalance("TRTLuzqKu5LJFc9YfdYESRW2xHXGDLLEfY2ZwH6VTgbo8JcUGVa4uzxX9vamnUcG35BkQy6VfwUy5CsV9YNomioPGGyVhHBTHGU")

test "getBlockHashes":
    echo wallet.getBlockHashes(firstBlockIndex=1000000, blockCount=10)

test "getTransactionHashes":
    echo wallet.getTransactionHashes(@["TRTLuzqKu5LJFc9YfdYESRW2xHXGDLLEfY2ZwH6VTgbo8JcUGVa4uzxX9vamnUcG35BkQy6VfwUy5CsV9YNomioPGGyVhHBTHGU"], firstBlockIndex=1000000, blockCount=10)

test "getTransactions":
    echo wallet.getTransactions(firstBlockIndex=1000000, blockCount=10)

test "getUnconfirmedTransactionHashes":
    echo wallet.getUnconfirmedTransactionHashes()

test "getTransaction":
    echo wallet.getTransaction("83d01977b82ff3e07693ac74f09464b19d432bfa03fdc1afbeb2bd9c6925bc04")
#[
test "reset":
    echo wallet.reset
]# 
