"use strict";

Array.prototype.index = function(val) {
  for(var i = 0, l = this.length; i < l; i++) {
    if(this[i] == val) return i;
  }
  return null;
};

Array.prototype.include = function(val) {
  return this.index(val) !== null;
};

Array.prototype.remove = function(index) {
  this.splice(index, 1);
  return this;
};

Array.prototype.compare = function(other) {
  return this.join('') == other.join('');
};

Array.prototype.each = function(callback) {
  for(var i = 0, l = this.length; i < l; i++) {
    callback(i, this[i]);
  }
  return this;
}

Array.prototype.map = function(callback) {
  for(var i = 0, l = this.length; i < l; i++) {
    this[i] = callback(i, this[i]);
  }
  return this;
}