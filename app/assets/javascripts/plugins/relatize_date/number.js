if (!Number.prototype.inRange) {
	Number.prototype.inRange = function (start, end) {
		var needle = this;

		if (Number !== start.constructor || Number !== end.constructor ||
				Number !== needle.constructor) {
			throw new TypeError();
		} else {
			if (start === end) {
				return needle === start;
			} else if (start < end) {
				return (start <= needle && needle <= end);
			} else if (end < start) {
				return (end <= needle && needle <= start);
			}
		}
	}
}

// Takes Number, returns String. Never returns fewer characters than starting
// count of decimal positions.
//
// Examples:
//     2.pad("0", 1) => "02"
//     30.pad("0", 0) => "30"
if (!Number.prototype.pad) {
	Number.prototype.pad = function (filler, n) {
		var filler_length = 0,
				number = this, // need a layer of indirection to avoid parse error
				number_string = "",
				padded_number = "";

		if (Number !== this.constructor) {
			throw new TypeError();
		} else {
			if ("undefined" === filler || "string" !== typeof filler) {
				filler = "";
			}
			if ("undefined" === n || "number" !== typeof n) {
				n = 0;
			}

			number_string = number.toString(10); // base 10

			if (0 === n) {
				padded_number = number_string;
			} else {
				filler_length = n - number_string.length;
				if (1 > filler_length) {
					padded_number = number_string;
				} else {
					// Loosely equivalent to Ruby's `"a" * 10` => `"aaaaaaaaaa"`.
					// Works by generating an array with `filler_length` cells
					// containing `filler`, then concatenating the results.
					//
					// Note: + 1 because `join` works in pairs.
					padded_number = new Array(filler_length + 1).join(filler) +
							number_string;
				}
			}

			return padded_number;
		}
	}
}
