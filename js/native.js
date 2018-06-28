

var ab2hexstring = function (arr) {
    var result = "";
    for (var i = 0; i < arr.length; i++) {
        var str = arr[i].toString(16);
        str = str.length === 0 ? "00" :
            str.length === 1 ? "0" + str :
                str;
        result += str;
    }
    return result;
};

var hexstring2ab = function (str) {
    var result = [];
    while (str.length >= 2) {
        result.push(parseInt(str.substring(0, 2), 16));
        str = str.substring(2, str.length);
    }

    return result;
};



    var makeWif = function (privateKey, networkPrefix) {
        var networkKey = networkPrefix + privateKey;
        var hashedKey = all_crypto.cryptojs.SHA256(all_crypto.cryptojs.SHA256(networkKey).toString()).toString();
        var checksum = hashedKey.substring(0, 6);
        return all_crypto.base64.Base64.encode(networkKey + checksum);
    };

    var makeAddress = function (publicKey, networkPrefix) {
        var hashedAddress = all_crypto.cryptojs.RIPEMD160(all_crypto.cryptojs.SHA256(publicKey).toString()).toString();
        var networkAddress = networkPrefix + hashedAddress;
        var hashedAddressAgain = all_crypto.cryptojs.SHA256(all_crypto.cryptojs.SHA256(networkAddress).toString()).toString();
        var checksum = hashedAddressAgain.substring(0, 6);
        return all_crypto.base64.Base64.encode(networkAddress + checksum);
    };

    var generateValidKeyPair = function myself() {
        var secp256k1 = new all_crypto.elliptic.ec('secp256k1');
        var keyPair = secp256k1.genKeyPair();
        var privateKey = keyPair.getPrivate().toString(16);
        var publicKeyX = keyPair.getPublic().x.toString(16);
        var publicKeyY = keyPair.getPublic().y.toString(16);
        var publicKey = publicKeyX + publicKeyY;
        if (privateKey.length !== 64 || publicKey.length !== 128) {
            return myself();
        }
        return {
            hexPrivateKey: privateKey,
            hexPublicKey: publicKey,
            hexPublicKeyX: publicKeyX,
            hexPublicKeyY: publicKeyY
        };
    };

    var reverseString = function (string) {
        return string.split("").reverse().join("");
    };

    var mainnet = {prefix: "M0", name: "mainnet"};

    var testnet = {prefix: "T0", name: "testnet"};

    var getPrivateKeyAndNetworkFromWif = function (wif) {
        var decodedWif = all_crypto.base64.Base64.decode(wif);
        var networkPrefix = decodedWif.substring(0, 1);
        var network = networkPrefix === "M0" ? mainnet : testnet;
        var privateKeyHex = decodedWif.substring(2, decodedWif.length - 6);
        return {privateKey: privateKeyHex, network: network};
    };

    var getPublicKeyFromPrivateKey = function (privateKey) {
        var ecparams = all_crypto.ecurve.getCurveByName('secp256k1');
        var curvePt = ecparams.G.multiply(all_crypto.BigInteger.fromBuffer(hexstring2ab(privateKey)));
        var publicKey = curvePt.affineX.toString(16) + curvePt.affineY.toString(16);
        return publicKey;
    };

    // ---------------



    // var generateKeyPair = function () {
    //     try {
    //         return new Ok(generateValidKeyPair())
    //     } catch (e) {
    //       return new Err($KeyPair_Error_KeyPairGenerationError)
    //     }
    // };

    // var generateNewWallet = function (networkPrefix) {
    //     return _elm_lang$core$Native_Scheduler.nativeBinding(function (callback) {
    //         try {
    //
    //             if (["T0", "M0"].indexOf(networkPrefix) === -1) {
    //                 return callback(_elm_lang$core$Native_Scheduler.fail("Error - you must supply a network of either T0 or M0"));
    //             }
    //
    //             var keyPair = generateValidKeyPair();
    //
    //             return callback(_elm_lang$core$Native_Scheduler.succeed({
    //                 public_key: keyPair.hexPublicKey,
    //                 wif: makeWif(keyPair.hexPrivateKey, networkPrefix),
    //                 address: makeAddress(keyPair.hexPublicKey, networkPrefix)
    //             }));
    //         } catch (e) {
    //             return callback(_elm_lang$core$Native_Scheduler.fail("Error something went wrong with: generateNewWallet - here is the error: " + e));
    //         }
    //     });
    // };

    // var encryptWallet = function (wallet, password) {
    //     try {
    //         var address = wallet.address;
    //         return _elm_lang$core$Native_Scheduler.nativeBinding(function (callback) {
    //             all_crypto.bcrypt.genSalt(10, function (err, salt) {
    //                 all_crypto.bcrypt.hash(password, salt, function (err, hash) {
    //                     console.log(err);
    //                     var walletJson = JSON.stringify(wallet);
    //                     var bf = new all_crypto.blowfish(reverseString(hash));
    //                     var ciphertext = ab2hexstring(bf.encode(walletJson));
    //
    //                     var encryptedWallet = {
    //                         source: "sushi",
    //                         ciphertext: ciphertext,
    //                         address: address,
    //                         salt: salt
    //                     };
    //                     return callback(_elm_lang$core$Native_Scheduler.succeed(encryptedWallet));
    //                 });
    //             });
    //         });
    //     } catch (e) {
    //         return callback(_elm_lang$core$Native_Scheduler.fail("Error something went wrong with: encryptWallet - here is the error: " + e));
    //     }
    // };

    var decryptWallet = function (encryptedWallet, password) {
        try {
            return _elm_lang$core$Native_Scheduler.nativeBinding(function (callback) {
                all_crypto.bcrypt.hash(password, encryptedWallet.salt, function (err, hash) {
                    var bf = new all_crypto.blowfish(reverseString(hash));
                    var binaryCipherText = new Uint8Array(hexstring2ab(encryptedWallet.ciphertext));
                    var wallet = JSON.parse(bf.decode(binaryCipherText));
                    return callback(_elm_lang$core$Native_Scheduler.succeed(wallet));
                });

            });
        } catch (e) {
            return callback(_elm_lang$core$Native_Scheduler.fail("Error something went wrong with: decryptWallet - here is the error: " + e));
        }
    };

    var getWalletFromWif = function (wif) {
        try {
            var privateKeyNetwork = getPrivateKeyAndNetworkFromWif(wif);
            var publicKey = getPublicKeyFromPrivateKey(privateKeyNetwork.privateKey);
            var address = makeAddress(publicKey, privateKeyNetwork.network.prefix);
            console.log(publicKey);

            return _elm_lang$core$Result$Ok({
                public_key: publicKey,
                wif: wif,
                address: address
            });
        } catch (e) {
            return _elm_lang$core$Result$Err("Error something went wrong with: getWalletFromWif - here is the error: " + e);
        }
    };

    var getFullWalletFromWif = function (wif) {
        try {
            var privateKeyNetwork = getPrivateKeyAndNetworkFromWif(wif);
            var privateKey = privateKeyNetwork.privateKey;
            var network = privateKeyNetwork.network;
            var publicKey = getPublicKeyFromPrivateKey(privateKeyNetwork.privateKey);
            var address = makeAddress(publicKey, privateKeyNetwork.network.prefix);

            return _elm_lang$core$Result$Ok({
                network: network,
                private_key: privateKey,
                public_key: publicKey,
                wif: wif,
                address: address
            });
        } catch (e) {
            return _elm_lang$core$Result$Err("Error something went wrong with: getFullWalletFromWif - here is the error: " + e);
        }
    };

    var mod_inv = function (a, mod) {
        var lim = new all_crypto.BigInteger("1");
        var him = new all_crypto.BigInteger("0");
        var low = a.mod(mod);
        var high = mod;

        while (low > 1) {
            var ratio = high.divide(low);
            var nm = him.subtract(lim.multiply(ratio));
            var nw = high.subtract(low.multiply(ratio));
            him = lim;
            high = low;
            lim = nm;
            low = nw;
        }

        return lim.mod(mod);
    };

    // privateKey : BigInt, message : String
    var sign = function (privateKey, message) {
        var secp256k1 = new all_crypto.elliptic.ec('secp256k1');
        var _n = new all_crypto.BigInteger(secp256k1.n.toString());
        var hash = new all_crypto.BigInteger.fromHex(all_crypto.cryptojs.SHA256(message).toString());

        var keys = generateValidKeyPair();
        var k = new all_crypto.BigInteger.fromHex(keys.hexPrivateKey);
        var r = new all_crypto.BigInteger.fromHex(keys.hexPublicKeyX);

        var s = (mod_inv(k, _n).multiply(privateKey.multiply(r).add(hash))).mod(_n);

        return [r, s];
    };


    var signTransaction = function (hexPrivateKey, transaction) {
        try {
            var jsTransaction =
                {
                    id: transaction.id,
                    action: transaction.action,
                    senders: _elm_lang$core$Native_List.toArray(transaction.senders),
                    recipients: _elm_lang$core$Native_List.toArray(transaction.recipients),
                    message: transaction.message,
                    prev_hash: transaction.prev_hash,
                    sign_r: transaction.sign_r,
                    sign_s: transaction.sign_s
                };

            var jsTransactionJson = JSON.stringify(jsTransaction);
            var transaction_hash = all_crypto.cryptojs.SHA256(jsTransactionJson).toString();

            var privateKeyBinary = new all_crypto.BigInteger.fromHex(hexPrivateKey);
            var signed = sign(privateKeyBinary, transaction_hash);

            var sign_r = signed[0].toString(16);
            var sign_s = signed[1].toString(16);

            var signedTransaction =
                {
                    id: transaction.id,
                    action: transaction.action,
                    senders: _elm_lang$core$Native_List.fromArray(jsTransaction.senders),
                    recipients: _elm_lang$core$Native_List.fromArray(jsTransaction.recipients),
                    message: transaction.message,
                    prev_hash: transaction.prev_hash,
                    sign_r: sign_r,
                    sign_s: sign_s
                };

            return _elm_lang$core$Result$Ok(signedTransaction);
        } catch (e) {
            return _elm_lang$core$Result$Err("Error something went wrong with: signTransaction - here is the error: " + e);
        }
    };

    var isValidAddress = function (address) {
        try {
            var decodedAddress = all_crypto.base64.Base64.decode(address);
            if (decodedAddress.length !== 48) {
                return _elm_lang$core$Result$Err("Error the supplied address is invalid - expecting length: 48 but was: " + decodedAddress.length);
            }
            var versionAddress = decodedAddress.substring(0, decodedAddress.length - 6);
            var hashedAddress = all_crypto.cryptojs.SHA256(all_crypto.cryptojs.SHA256(versionAddress).toString()).toString();
            var checksum = decodedAddress.substring(decodedAddress.length - 6, decodedAddress.length);
            var res = checksum === hashedAddress.substring(0, 6);
            return _elm_lang$core$Result$Ok(res);
        } catch (e) {
            return _elm_lang$core$Result$Err("Error something went wrong with: isValidAddress - here is the error: " + e);
        }
    };

    var getMnemonic = function (hexPrivateKey) {
        return _elm_lang$core$Native_Scheduler.nativeBinding(function (callback) {
            try {
                var words = _elm_lang$core$Native_List.fromArray(all_crypto.mnemonic.fromHex(hexPrivateKey).toWords());
                return callback(_elm_lang$core$Native_Scheduler.succeed(words));
            } catch (e) {
                return callback(_elm_lang$core$Native_Scheduler.fail("Error something went wrong with: getMnemonic - here is the error: " + e));
            }
        });
    };

    var getKeyFromMnemonic = function (words) {
        return _elm_lang$core$Native_Scheduler.nativeBinding(function (callback) {
            try {
                var pk = all_crypto.mnemonic.fromWords(_elm_lang$core$Native_List.toArray(words)).toHex();
                return callback(_elm_lang$core$Native_Scheduler.succeed(pk));
            } catch (e) {
                return callback(_elm_lang$core$Native_Scheduler.fail("Error something went wrong with: getKeyFromMnemonic - here is the error: " + e));
            }
        });
    };

    // return {
    //     generateKeyPair: generateKeyPair
    //     // generateNewWallet: generateNewWallet,
    //     // encryptWallet: F2(encryptWallet),
    //     // decryptWallet: F2(decryptWallet),
    //     // getWalletFromWif: getWalletFromWif,
    //     // getFullWalletFromWif: getFullWalletFromWif,
    //     // signTransaction: F2(signTransaction),
    //     // isValidAddress: isValidAddress,
    //     // getMnemonic: getMnemonic,
    //     // getKeyFromMnemonic: getKeyFromMnemonic
    // }
