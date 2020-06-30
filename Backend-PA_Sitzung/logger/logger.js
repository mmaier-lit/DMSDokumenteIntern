const EventEmitter = require('events');

class Logger extends EventEmitter {
    log(message) {
        this.emit('message', { date: new Date(), message});
    }

    request(type, message) {
        this.emit('request', { date: new Date(), type, message});
    }
}

module.exports = Logger;