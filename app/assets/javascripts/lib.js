window.findById = function (obj, id) {
  return _.find(obj, function (val) {
    return val.id == id
  })
}

Array.prototype.split = function (n) {
    var len = this.length,out = [], i = 0;
    while (i < len) {
        var size = Math.ceil((len - i) / n--);
        out.push(this.slice(i, i + size));
        i += size;
    }
    return out;
}

window.pickTrue = function (obj) {
    return _.keys(_.pick(obj, function (v, k) {
        return v;
    }))
}

window.getRandomArbitrary = function (min, max) {
    return Math.random() * (max - min) + min;
}

window.guid = function () {
  function s4() {
    return Math.floor((1 + Math.random()) * 0x10000)
      .toString(16)
      .substring(1);
  }
  return s4() + s4() + '-' + s4() + '-' + s4() + '-' +
    s4() + '-' + s4() + s4() + s4();
}

window.htmlToPlaintext = function (text) {
  return String(text).replace(/<[^>]+>/gm, '');
}