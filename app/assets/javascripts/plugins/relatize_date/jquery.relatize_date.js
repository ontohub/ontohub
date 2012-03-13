(function ($) {
	$.fn.relatizeDate = function (options) {
		// Options:
		//   `defaultLanguage`: String; locale name (e.g. `"sv-SV"`, `"ru"`); used
		//      if we're unable to determine user's preferred locale or there's no
		//      translation for the preferred locale
		//   `fromTitle`: Boolean; whether to generate relative time from title of
		//      `$(this)` or from its text (default)
		//   `include_seconds`: `Boolean`
		//   `language`: String; forcibly set which locale to use
		//   `titleize`: Boolean; whether to set `title` attribute of `$(this)` to
		//      original timestamp text in `$(this)`
		var settings = $.extend({
					defaultLanguage: "",
					fromTitle: false,
					include_seconds: false,
					language: "",
					titleize: false
				}, options),
				format = "",
				locale = "",
				preferred_language = "",
				preferred_locales = [],
				translation = {};

		if ("string" === typeof settings.language && "" !== settings.language) {
			preferred_language = settings.language;
		} else if ("undefined" === typeof navigator.browserLanguage) {
			preferred_language = navigator.language;
		} else {
			preferred_language = navigator.browserLanguage;
		}

		// `"en-us"` => `["en_us", "en", "-us"]`
		// `"en"` => `["en", "en", undefined]`
		preferred_locales = preferred_language.toLowerCase().
				match(/(\w+)(\-\w+)?/);

		// e.g. `"fr-fr"`
		if ($relatizeDateTranslation[preferred_locales[0]]) {
			locale = preferred_locales[0];
		// e.g. `"fr"`
		} else if ($relatizeDateTranslation[preferred_locales[1]]) {
			locale = preferred_locales[1];
		} else {
			locale = settings.defaultLanguage;
		}

		translation = $relatizeDateTranslation[locale];
		if ("undefined" !== typeof translation) {
			if ("undefined" !== typeof translation.default_date_fmt) {
				format = translation.default_date_fmt;
			} else {
				format = "%B %d, %Y %I:%M %p";
			}
		}

		return this.each(function () {
			var date;

			if (settings.fromTitle) {
				date = new Date($(this).attr("title"));
			} else {
				date = new Date($(this).text());
			}

			// If the date or translation is invalid, leave the text as-is.
			if (date.isValid() && "undefined" !== typeof translation) {
				if (settings.titleize) {
					$(this).attr("title", date.strftime(format, translation));
				}

				$(this).data("timestamp", $(this).text()).
						text(time_ago_in_words(date, settings.include_seconds,
								translation));
			}
		});
	};
})(jQuery);
