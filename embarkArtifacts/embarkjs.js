/* eslint-disable */

const EmbarkJS = require("C:/Users/g14m1190/Documents/GitHub/bounty/embarkArtifacts/modules/embarkjs").default;
export default EmbarkJS;
global.EmbarkJS = EmbarkJS

const Web3 = global.__Web3 || require('C:/Users/g14m1190/Documents/GitHub/bounty/embarkArtifacts/modules/web3');
global.Web3 = Web3;/*global Web3*/
const embarkJSConnectorWeb3 = {};

embarkJSConnectorWeb3.init = function(config) {
  global.web3 = config.web3 || global.web3;
  // Check if the global web3 object uses the old web3 (0.x)
  if (global.web3 && typeof global.web3.version !== 'string') {
    // If so, use a new instance using 1.0, but use its provider
    this.web3 = new Web3(global.web3.currentProvider);
  } else {
    this.web3 = global.web3 || new Web3();
  }
  global.web3 = this.web3;
};

embarkJSConnectorWeb3.getInstance = function () {
  return this.web3;
};

embarkJSConnectorWeb3.getAccounts = function () {
  return this.web3.eth.getAccounts(...arguments);
};

embarkJSConnectorWeb3.getNewProvider = function (providerName, ...args) {
  return new Web3.providers[providerName](...args);
};

embarkJSConnectorWeb3.setProvider = function (provider) {
  return this.web3.setProvider(provider);
};

embarkJSConnectorWeb3.getCurrentProvider = function () {
  return this.web3.currentProvider;
};

embarkJSConnectorWeb3.getDefaultAccount = function () {
  return this.web3.eth.defaultAccount;
};

embarkJSConnectorWeb3.setDefaultAccount = function (account) {
  this.web3.eth.defaultAccount = account;
};

embarkJSConnectorWeb3.newContract = function (options) {
  return new this.web3.eth.Contract(options.abi, options.address);
};

embarkJSConnectorWeb3.send = function () {
  return this.web3.eth.sendTransaction(...arguments);
};

embarkJSConnectorWeb3.toWei = function () {
  return this.web3.toWei(...arguments);
};

embarkJSConnectorWeb3.getNetworkId = function () {
  return this.web3.eth.net.getId();
};

EmbarkJS.Blockchain.registerProvider('web3', embarkJSConnectorWeb3);
EmbarkJS.Blockchain.setProvider('web3', {});
if (!global.__Web3) {
  const web3ConnectionConfig = require('C:/Users/g14m1190/Documents/GitHub/bounty/embarkArtifacts/config/blockchain.json');
  EmbarkJS.Blockchain.connect(web3ConnectionConfig, (err) => {if (err) { console.error(err); } });
}
const IpfsApi = global.IpfsApi || require('C:/Users/g14m1190/Documents/GitHub/bounty/embarkArtifacts/modules/ipfs-api');
"use strict";

var _interopRequireDefault = require("@babel/runtime-corejs2/helpers/interopRequireDefault");

var _promise = _interopRequireDefault(require("@babel/runtime-corejs2/core-js/promise"));

/*global IpfsApi*/
const __embarkIPFS = {};
const NoConnectionError = 'No IPFS connection. Please ensure to call Embark.Storage.setProvider()';

__embarkIPFS.setProvider = function (options) {
  const self = this;
  return new _promise.default(function (resolve, reject) {
    try {
      if (!options) {
        self._config = options;
        self._ipfsConnection = IpfsApi('localhost', '5001');
        self._getUrl = "http://localhost:8080/ipfs/";
      } else {
        const ipfsOptions = {
          host: options.host || options.server,
          protocol: 'http'
        };

        if (options.protocol) {
          ipfsOptions.protocol = options.protocol;
        }

        if (options.port && options.port !== 'false') {
          ipfsOptions.port = options.port;
        }

        self._ipfsConnection = IpfsApi(ipfsOptions);
        self._getUrl = options.getUrl || "http://localhost:8080/ipfs/";
      }

      resolve(self);
    } catch (err) {
      console.error(err);
      self._ipfsConnection = null;
      reject(new Error('Failed to connect to IPFS'));
    }
  });
};

__embarkIPFS.isAvailable = function () {
  return new _promise.default(resolve => {
    if (!this._ipfsConnection) {
      return resolve(false);
    }

    this._ipfsConnection.id().then(id => {
      resolve(Boolean(id));
    }).catch(err => {
      console.error(err);
      resolve(false);
    });
  });
};

__embarkIPFS.saveText = function (text) {
  const self = this;
  return new _promise.default(function (resolve, reject) {
    if (!self._ipfsConnection) {
      return reject(new Error(NoConnectionError));
    }

    self._ipfsConnection.add(self._ipfsConnection.Buffer.from(text), function (err, result) {
      if (err) {
        return reject(err);
      }

      resolve(result[0].path);
    });
  });
};

__embarkIPFS.get = function (hash) {
  const self = this; // TODO: detect type, then convert if needed
  //var ipfsHash = web3.toAscii(hash);

  return new _promise.default(function (resolve, reject) {
    if (!self._ipfsConnection) {
      var connectionError = new Error(NoConnectionError);
      return reject(connectionError);
    }

    self._ipfsConnection.get(hash, function (err, files) {
      if (err) {
        return reject(err);
      }

      resolve(files[0].content.toString());
    });
  });
};

__embarkIPFS.uploadFile = function (inputSelector) {
  const self = this;
  const file = inputSelector[0].files[0];

  if (file === undefined) {
    throw new Error('no file found');
  }

  return new _promise.default(function (resolve, reject) {
    if (!self._ipfsConnection) {
      return reject(new Error(NoConnectionError));
    }

    const reader = new FileReader();

    reader.onloadend = function () {
      const buffer = self._ipfsConnection.Buffer.from(reader.result);

      self._ipfsConnection.add(buffer, function (err, result) {
        if (err) {
          return reject(err);
        }

        resolve(result[0].path);
      });
    };

    reader.readAsArrayBuffer(file);
  });
};

__embarkIPFS.getUrl = function (hash) {
  return (this._getUrl || "http://localhost:8080/ipfs/") + hash;
};

__embarkIPFS.resolve = function (name, callback) {
  callback = callback || function () {};

  if (!this._ipfsConnection) {
    return callback(new Error(NoConnectionError));
  }

  this._ipfsConnection.name.resolve(name).then(res => {
    callback(null, res.Path);
  }).catch(() => {
    callback(name + " is not registered");
  });
};

__embarkIPFS.register = function (addr, callback) {
  callback = callback || function () {};

  if (!this._ipfsConnection) {
    return new Error(NoConnectionError);
  }

  if (addr.length !== 46 || !addr.startsWith('Qm')) {
    return callback('String is not an IPFS hash');
  }

  this._ipfsConnection.name.publish("/ipfs/" + addr).then(res => {
    callback(null, res.Name);
  }).catch(() => {
    callback(addr + " could not be registered");
  });
};
//# sourceMappingURL=embarkjs.js.map
EmbarkJS.Storage.registerProvider('ipfs', __embarkIPFS);
var whenEnvIsLoaded = function(cb) {
  if (typeof document !== 'undefined' && document !== null && !/comp|inter|loaded/.test(document.readyState)) {
      document.addEventListener('DOMContentLoaded', cb);
  } else {
    cb();
  }
}

var whenEnvIsLoaded = function(cb) {
  if (typeof document !== 'undefined' && document !== null && !/comp|inter|loaded/.test(document.readyState)) {
      document.addEventListener('DOMContentLoaded', cb);
  } else {
    cb();
  }
}
whenEnvIsLoaded(function() {
  
EmbarkJS.Storage.setProviders([{"provider":"ipfs","host":"localhost","port":5001,"getUrl":"http://localhost:8080/ipfs/"}]);
});

var whenEnvIsLoaded = function(cb) {
  if (typeof document !== 'undefined' && document !== null && !/comp|inter|loaded/.test(document.readyState)) {
      document.addEventListener('DOMContentLoaded', cb);
  } else {
    cb();
  }
}
"use strict";

const ws = new WebSocket(`${location.protocol === 'https:' ? 'wss' : 'ws'}://${location.hostname}:${location.port}`);
ws.addEventListener('message', evt => {
  if (evt.data === 'outputDone') {
    location.reload(true);
  }
});
//# sourceMappingURL=reload-on-change.js.map
/* eslint-enable */