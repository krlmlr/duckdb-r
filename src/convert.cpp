#include "include/rapi.hpp"

#include <cpp11.hpp>

// Avoid clash with TRUE and FALSE macros in older rtools
#undef TRUE
#undef FALSE

using namespace cpp11;

namespace duckdb {

// Helper functions to convert string to enum values
ConvertOpts::TzOutConvert string_to_tz_out_convert(const std::string &str) {
	if (str == "with")
		return ConvertOpts::TzOutConvert::WITH;
	if (str == "force")
		return ConvertOpts::TzOutConvert::FORCE;
	rapi_error_with_context("string_to_tz_out_convert", "Invalid tz_out_convert value: " + str);
}

ConvertOpts::BigIntType string_to_bigint_type(const std::string &str) {
	if (str == "numeric")
		return ConvertOpts::BigIntType::NUMERIC;
	if (str == "integer64")
		return ConvertOpts::BigIntType::INTEGER64;
	rapi_error_with_context("string_to_bigint_type", "Invalid bigint value: " + str);
}

ConvertOpts::ArrayConversion string_to_array_conversion(const std::string &str) {
	if (str == "none")
		return ConvertOpts::ArrayConversion::NONE;
	if (str == "matrix")
		return ConvertOpts::ArrayConversion::MATRIX;
	rapi_error_with_context("string_to_array_conversion", "Invalid array value: " + str);
}

ConvertOpts::GeometryConversion string_to_geometry_conversion(const std::string &str) {
	if (str == "blob")
		return ConvertOpts::GeometryConversion::BLOB;
	if (str == "wk")
		return ConvertOpts::GeometryConversion::WK;
	rapi_error_with_context("string_to_geometry_conversion", "Invalid geometry value: " + str);
}

ConvertOpts::MapShape string_to_map_shape(const std::string &str) {
	if (str == "data.frame")
		return ConvertOpts::MapShape::DATA_FRAME;
	if (str == "list_of")
		return ConvertOpts::MapShape::LIST_OF;
	rapi_error_with_context("string_to_map_shape", "Invalid map value: " + str);
}

ConvertOpts::PosixctType string_to_posixct_type(const std::string &str) {
	if (str == "timestamp")
		return ConvertOpts::PosixctType::TIMESTAMP;
	if (str == "timestamptz")
		return ConvertOpts::PosixctType::TIMESTAMPTZ;
	rapi_error_with_context("string_to_posixct_type", "Invalid posixct value: " + str);
}

ConvertOpts::ArrowConversion bool_to_arrow_conversion(bool use_arrow) {
	return use_arrow ? ConvertOpts::ArrowConversion::ENABLED : ConvertOpts::ArrowConversion::DISABLED;
}

ConvertOpts::AllowStreamResult bool_to_allow_stream_result(bool allow_stream_result) {
	return allow_stream_result ? ConvertOpts::AllowStreamResult::ENABLED : ConvertOpts::AllowStreamResult::DISABLED;
}

ConvertOpts::ExperimentalFeatures bool_to_experimental_features(bool use_experimental) {
	return use_experimental ? ConvertOpts::ExperimentalFeatures::ENABLED : ConvertOpts::ExperimentalFeatures::DISABLED;
}

ConvertOpts::StrictRelational bool_to_strict_relational(bool use_strict_relational) {
	return use_strict_relational ? ConvertOpts::StrictRelational::ENABLED : ConvertOpts::StrictRelational::DISABLED;
}

ConvertOpts::ConvertOpts(cpp11::sexp options_nullable) {
	if (options_nullable == R_NilValue) {
		return;
	}

	cpp11::list options(options_nullable);

	// Extract timezone_out
	timezone_out = as_cpp<std::string>(options["timezone_out"]);

	// Extract tz_out_convert
	tz_out_convert = string_to_tz_out_convert(as_cpp<std::string>(options["tz_out_convert"]));

	// Extract bigint
	bigint = string_to_bigint_type(as_cpp<std::string>(options["bigint"]));

	// Extract array
	array = string_to_array_conversion(as_cpp<std::string>(options["array"]));

	// Extract geometry
	geometry = string_to_geometry_conversion(as_cpp<std::string>(options["geometry"]));

	// Extract map
	map = string_to_map_shape(as_cpp<std::string>(options["map"]));

	// Extract posixct; absent or NA, it keeps the documented default, as `duckdb_posixct_type()` does in R
	SEXP posixct_sexp = options["posixct"];
	if (posixct_sexp != R_NilValue && !(TYPEOF(posixct_sexp) == STRSXP && Rf_xlength(posixct_sexp) == 1 &&
	                                    STRING_ELT(posixct_sexp, 0) == NA_STRING)) {
		posixct = string_to_posixct_type(as_cpp<std::string>(posixct_sexp));
	}

	// Extract posixct_naive_columns; set only for a registration that dbAppendTable() or dbWriteTable() makes
	SEXP posixct_naive_columns_sexp = options["posixct_naive_columns"];
	if (posixct_naive_columns_sexp != R_NilValue) {
		for (auto column : cpp11::strings(posixct_naive_columns_sexp)) {
			posixct_naive_columns.push_back(std::string(column));
		}
	}

	// Extract posixct_tz_columns, the counterpart for a column going into a zoned temporal type
	SEXP posixct_tz_columns_sexp = options["posixct_tz_columns"];
	if (posixct_tz_columns_sexp != R_NilValue) {
		for (auto column : cpp11::strings(posixct_tz_columns_sexp)) {
			posixct_tz_columns.push_back(std::string(column));
		}
	}

	// Extract arrow
	arrow = bool_to_arrow_conversion(as_cpp<bool>(options["arrow"]));

	// Extract streaming
	allow_stream_result = bool_to_allow_stream_result(as_cpp<bool>(options["allow_stream_result"]));

	// Extract experimental
	experimental = bool_to_experimental_features(as_cpp<bool>(options["experimental"]));

	// Extract strict_relational
	strict_relational = bool_to_strict_relational(as_cpp<bool>(options["strict_relational"]));
}

} // namespace duckdb
