// Return the distance of time in words between two `Date`s, e.g.
// `"5 days ago"`, `"environ un an"`.
//
// Options:
//   `from_time`: `Date`
//   `to_time`: `Date`
//   `include_seconds`: `Boolean`
//   `translation`: `Object`; a `$relatizeDateTranslation`
var distance_of_time_in_words = function (from_time, to_time, include_seconds,
				translation) {
			var delta = 0,
					distance_in_seconds = 0,
					distance_in_minutes = 0,
					distance_in_years = 0,
					minute_offset_for_leap_year = 0,
					remainder = 0,
					distance = "";

			if (from_time.isValid() && to_time.isValid()) {
				// from_time and to_time come in as millisecond offsets from Unix epoch
				delta = Math.abs(to_time.unixTimestamp() - from_time.unixTimestamp());

				distance_in_minutes = Math.round(delta / 60);
				distance_in_seconds = Math.round(delta);

				if (distance_in_minutes.inRange(0, 1)) {
					if (!include_seconds) {
						return (0 === distance_in_minutes) ?
								translation.less_than_x_minute :
								translation.x_minutes.replace("%d", distance_in_minutes);
					} else {
						if (distance_in_seconds.inRange(0, 4)) {
							return translation.less_than_x_seconds.replace("%d", 5);
						} else if (distance_in_seconds.inRange(5, 9)) {
							return translation.less_than_x_seconds.replace("%d", 10);
						} else if (distance_in_seconds.inRange(10, 19)) {
							return translation.less_than_x_seconds.replace("%d", 20);
						} else if (distance_in_seconds.inRange(20, 39)) {
							return translation.half_a_minute;
						} else if (distance_in_seconds.inRange(40, 59)) {
							return translation.less_than_x_minute;
						} else {
							return translation.x_minute;
						}
					}
				} else if (distance_in_minutes.inRange(2, 44)) {
					return translation.x_minutes.replace("%d", distance_in_minutes);
				} else if (distance_in_minutes.inRange(45, 89)) {
					return translation.about_x_hour;
				} else if (distance_in_minutes.inRange(90, 1439)) {
					return translation.x_hours.replace("%d",
							Math.round(distance_in_minutes.toFixed(1) / 60.0));
				} else if (distance_in_minutes.inRange(1440, 2519)) {
					return translation.x_day;
				} else if (distance_in_minutes.inRange(2520, 43199)) {
					return translation.x_days.replace("%d",
							Math.round(distance_in_minutes.toFixed(1) / 1440.0));
				} else if (distance_in_minutes.inRange(43200, 86399)) {
					return translation.about_x_month;
				} else if (distance_in_minutes.inRange(86400, 525599)) {
					return translation.x_months.replace("%d",
							Math.round(distance_in_minutes.toFixed(1) / 43200.0));
				} else {
					distance_in_years = Math.round(distance_in_minutes / 525600);
					minute_offset_for_leap_year = (distance_in_years / 4) * 1440;
					remainder = ((distance_in_minutes - minute_offset_for_leap_year) %
							525600);

					if (remainder < 131400) {
						return translation.about_x_years.replace("%d",
								distance_in_years);
					} else if (remainder < 394200) {
						return translation.over_x_years.replace("%d", distance_in_years);
					} else {
						return translation.almost_x_years.replace("%d",
								(distance_in_years + 1));
					}
				}
			}
		},

		// Convenience method for calling `distance_of_time_in_words` relative to
		// the current timestamp.
		//
		// Options:
		//   `include_seconds`: `Boolean`
		//   `translation`: `Object`; a `$relatizeDateTranslation`
		time_ago_in_words = function (from_time, include_seconds, translation) {
			var to_time = new Date();

			if (from_time.isValid()) {
				return distance_of_time_in_words(from_time, to_time, include_seconds,
						translation);
			}
		},

		distance_of_time_in_words_to_now = time_ago_in_words;

/*****************************************************************************/

if (!Date.prototype.isValid) {
	Date.prototype.isValid = function() {
		if (Date !== this.constructor) {
			throw new TypeError();
		} else {
			return !isNaN(this) && 0 < this;
		}
	};
}

if (!Date.prototype.strftime) {
	Date.prototype.strftime = function (format, translation) {
		var date = this,
				day = date.getDay(),
				month = date.getMonth(),
				hours = date.getHours(),
				minutes = date.getMinutes();

		if (date.isValid()) {
			// note: destructively modifies `format`
			return format.replace(/\%([aAbBcdeHImMpSwyY])/g, function (key) {
				switch (key[1]) {
					// l10n abbreviated day name
					case "a": return translation.abbr_day_names[day];
					// l10n full day name
					case "A": return translation.day_names[day];
					// l10n abbreviated month name
					case "b": return translation.abbr_month_names[month + 1];
					// l10n full month name
					case "B": return translation.month_names[month + 1];
					// l10n datetime
					case "c": return date.toString();
					// day of month, 01-31 (leading zero)
					case "d": return date.getDate().pad("0", 2);
					// day of month,  1-31 (leading space)
					case "e": return date.getDate().pad(" ", 2);
					// l10n abbreviated month name
					case "h": return translation.abbr_month_names[month + 1];
					// 24-hour, 00-23
					case "H": return hours.pad("0", 2);
					// 12-hour, 01-12
					case "I":
						if (0 === (hours + 12) % 12) {
							return 12;
						} else {
							return (hours + 12) % 12;
						}
					// month, 01-12
					case "m": return (month + 1).pad("0", 2);
					// minutes, 00-59
					case "M": return minutes.pad("0", 2);
					// l10n "am"/"pm"
					case "p": return hours > 12 ? "PM" : "AM";
					// seconds, 00-60
					case "S": return date.getSeconds().pad("0", 2);
					// day of week, 0-6
					case "w": return day;
					// last two digits of year, 00-99
					case "y": return (date.getFullYear() % 100).pad("0", 2);
					// year
					case "Y": return date.getFullYear().toString();
				}
			});
		} else {
			// xxx not sure what the appropriate return value is here (/jordan)
			return date;
		}
	};
}

if (!Date.prototype.unixTimestamp) {
	Date.prototype.unixTimestamp = function () {
		if (Date !== this.constructor) {
			throw new TypeError();
		} else {
			return Math.round(this.getTime() / 1000);
		}
	}
}
