var ab2hexstring = function(arr) {
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

var hexstring2ab = function(str) {
  var result = [];
  while (str.length >= 2) {
    result.push(parseInt(str.substring(0, 2), 16));
    str = str.substring(2, str.length);
  }

  return result;
};

var makeWif = function(privateKey, networkPrefix) {
  var networkKey = networkPrefix + privateKey;
  var hashedKey = all_crypto.cryptojs.SHA256(all_crypto.cryptojs.SHA256(networkKey).toString()).toString();
  var checksum = hashedKey.substring(0, 6);
  return all_crypto.base64.Base64.encode(networkKey + checksum);
};

var makeAddress = function(publicKey, networkPrefix) {
  var hashedAddress = all_crypto.cryptojs.RIPEMD160(all_crypto.cryptojs.SHA256(publicKey).toString()).toString();
  var networkAddress = networkPrefix + hashedAddress;
  var hashedAddressAgain = all_crypto.cryptojs.SHA256(all_crypto.cryptojs.SHA256(networkAddress).toString()).toString();
  var checksum = hashedAddressAgain.substring(0, 6);
  return all_crypto.base64.Base64.encode(networkAddress + checksum);
};

function toHexString(byteArray) {
  return Array.prototype.map.call(byteArray, function(byte) {
    return ('0' + (byte & 0xFF).toString(16)).slice(-2);
  }).join('');
}

var generateValidKeyPair = function myself() {
  var nacl = all_crypto.tweetnacl;
  var keyPair = nacl.sign.keyPair();
  var fullPrivateKey = toHexString(keyPair.secretKey);
  var publicKey = toHexString(keyPair.publicKey);
  var privateKey = fullPrivateKey.replace(publicKey, "");

  return {
    hexPrivateKey: privateKey,
    hexPublicKey: publicKey
  };
};

var reverseString = function(string) {
  return string.split("").reverse().join("");
};

var mainnet = {
  prefix: "M0",
  name: "mainnet"
};

var testnet = {
  prefix: "T0",
  name: "testnet"
};

var getPrivateKeyAndNetworkFromWif = function(wif) {
  var decodedWif = all_crypto.base64.Base64.decode(wif);
  var networkPrefix = decodedWif.substring(0, 1);
  var network = networkPrefix === "M0" ? mainnet : testnet;
  var privateKeyHex = decodedWif.substring(2, decodedWif.length - 6);
  return {
    privateKey: privateKeyHex,
    network: network
  };
};

var getPublicKeyFromPrivateKey = function(privateKey) {
  var ec = new all_crypto.elliptic.eddsa('ed25519');
  var key = ec.keyFromSecret(privateKey);
  var publicKey = toHexString(key.getPublic());
  return publicKey;
};

// privateKey : BigInt, message : String
var sign = function(privateKey, message) {
  var ec = new all_crypto.elliptic.eddsa('ed25519');
  var key = ec.keyFromSecret(privateKey);
  var signature = key.sign(all_crypto.buffer.Buffer.from(message, 'utf8')).toHex().toLowerCase();
  return signature;
};

// privateKey : String, message : String
var verify = function(publicKey, message, signature) {
  var ec = new all_crypto.elliptic.eddsa('ed25519');
  var key = ec.keyFromPublic(publicKey, 'hex');
  return key.verify(all_crypto.buffer.Buffer.from(message, 'utf8'), signature);
}

var getMnemonic = function(hexPrivateKey) {
  return _elm_lang$core$Native_Scheduler.nativeBinding(function(callback) {
    try {
      var words = _elm_lang$core$Native_List.fromArray(all_crypto.mnemonic.fromHex(hexPrivateKey).toWords());
      return callback(_elm_lang$core$Native_Scheduler.succeed(words));
    } catch (e) {
      return callback(_elm_lang$core$Native_Scheduler.fail("Error something went wrong with: getMnemonic - here is the error: " + e));
    }
  });
};

var getKeyFromMnemonic = function(words) {
  return _elm_lang$core$Native_Scheduler.nativeBinding(function(callback) {
    try {
      var pk = all_crypto.mnemonic.fromWords(_elm_lang$core$Native_List.toArray(words)).toHex();
      return callback(_elm_lang$core$Native_Scheduler.succeed(pk));
    } catch (e) {
      return callback(_elm_lang$core$Native_Scheduler.fail("Error something went wrong with: getKeyFromMnemonic - here is the error: " + e));
    }
  });
};
