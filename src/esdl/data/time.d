// Written in the D programming language.

// Copyright: Coverify Systems Technology 2012 - 2014
// License:   Distributed under the Boost Software License, Version 1.0.
//            (See accompanying file LICENSE_1_0.txt or copy at
//            http://www.boost.org/LICENSE_1_0.txt)
// Authors:   Puneet Goel <puneet@coverify.com>

// This file is part of esdl.

module esdl.data.time;

import std.math;		// needed for ^^ operation

protected enum TimeUnit: byte
  {   SEC  = 0,
      MSEC = -3,
      USEC = -6,
      NSEC = -9,
      PSEC = -12,
      FSEC = -15
      }

alias TimeUnit.FSEC FSEC;
alias TimeUnit.PSEC PSEC;
alias TimeUnit.NSEC NSEC;
alias TimeUnit.USEC USEC;
alias TimeUnit.MSEC MSEC;
alias TimeUnit.SEC  SEC;

public struct Time
{
  public ulong _value;
  public byte _unit;

  public this(long value, byte unit) {
    _value = value;
    _unit = unit;
  }

  public Time normalize() {
    if(_unit is 0) return this;
    auto du = _unit % 3;
    if(du != 0 || _value % 1000 == 0) {
      ulong value = _value;
      byte unit = _unit;
      if(du != 0) {
	if(du < 0) du += 3;
	unit -= du;
	value *= 10 ^^ du;
      }
      if(value % 1000 == 0) {
	value /= 1000;
	unit  = cast(byte) (unit + 3);
      }
      return Time(value, unit);
    }
    else return this;
  }
  
  public bool isZero() {
    if(_value is 0) return true;
    else return false;
  }

  public int opCmp(Time other) {
    if(other._unit > this._unit) {
      int p = other._unit - this._unit;
      if(other._value * 10L^^p > this._value) return -1;
      if(other._value * 10L^^p < this._value) return 1;
      return 0;
    }
    else {
      int p = this._unit - other._unit;
      if(other._value > this._value * 10L^^p) return -1;
      if(other._value < this._value * 10L^^p) return 1;
      return 0;
    }
  }

  public bool opEquals(Time other) {
    if(other._unit > this._unit) {
      int p = other._unit - this._unit;
      if(other._value * 10L^^p == this._value) return true;
      else return false;
    }
    else {
      int p = this._unit - other._unit;
      if(other._value == this._value * 10L^^p) return true;
      else return false;
    }
  }

  public Time opBinary(string OP)(Time rhs) {
    TimeUnit unit;
    ulong value;
    Time _lhs = this.normalize();
    Time _rhs = rhs.normalize();
    static if(OP = "+") {
      if(_rhs._unit <= _lhs._unit) {
	unit = _rhs._unit;
	value = _lhs._value * 10L^^(_lhs._unit - _rhs._unit) + _rhs._value;
      }
      else {
	unit = _lhs._unit;
	value = _lhs._value + _rhs._value * 10L^^(_rhs._unit - _lhs._unit);
      }
      return Time(value, unit);
    }
    else static if(OP = "-") {
	if(_rhs._unit <= _lhs._unit) {
	  unit = _rhs._unit;
	  value = _lhs._value * 10L^^(_lhs._unit - _rhs._unit) - _rhs._value;
	}
	else {
	  unit = _lhs._unit;
	  value = _lhs._value - _rhs._value * 10L^^(_rhs._unit - _lhs._unit);
	}
	return Time(value, unit);
      }
  }

  public Time opBinary(string OP)(long rhs) {
    Time _lhs = this.normalize();
    static if(OP == "*") {
      _lhs._value *= rhs;
    }
    return _lhs.normalize();
  }

  public Time opBinaryRight(string OP)(long rhs) {
    Time _lhs = this.normalize();
    static if(OP == "*") {
      _lhs._value *= rhs;
    }
    return _lhs.normalize();
  }

  public S to(S)() if(is(S == string)) {
    import std.conv: to;
    import std.string: toLower;
    Time t = this.normalize();
    string value_ = t._value.to!string;
    string unit_ = (cast(TimeUnit) t._unit).to!string;
    if(t._unit >= -15 && t._unit <= 0) {
      unit_ = unit_.toLower();
    }
    return value_ ~ "." ~ unit_;
  }

  public R to(R)() if(is(R: real)) {
    import std.conv: to;
    return _value * ((cast(R) 10) ^^ _unit);
  }

  public string toString() {
    return this.to!string;
  }
}

public Time fsec(ulong value) {
  return Time(value, FSEC);
}

public Time psec(ulong value) {
  return Time(value, PSEC);
}

public Time nsec(ulong value) {
  return Time(value, NSEC);
}

public Time usec(ulong value) {
  return Time(value, USEC);
}

public Time msec(ulong value) {
  return Time(value, MSEC);
}

public Time sec(ulong value) {
  return Time(value, SEC);
}

unittest {
  assert(10.msec > 10.usec);
  assert(10.usec < 10.msec);
  assert(100.usec < 10.msec);
  assert(10.msec == 10000.usec);
}
