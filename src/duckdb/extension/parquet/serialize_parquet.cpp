//===----------------------------------------------------------------------===//
// This file is automatically generated by scripts/generate_serialization.py
// Do not edit this file manually, your changes will be overwritten
//===----------------------------------------------------------------------===//

#include "duckdb/common/serializer/format_serializer.hpp"
#include "duckdb/common/serializer/format_deserializer.hpp"
#include "parquet_reader.hpp"

namespace duckdb {

void ParquetOptions::FormatSerialize(FormatSerializer &serializer) const {
	serializer.WriteProperty(100, "binary_as_string", binary_as_string);
	serializer.WriteProperty(101, "file_row_number", file_row_number);
	serializer.WriteProperty(102, "file_options", file_options);
}

ParquetOptions ParquetOptions::FormatDeserialize(FormatDeserializer &deserializer) {
	ParquetOptions result;
	deserializer.ReadProperty(100, "binary_as_string", result.binary_as_string);
	deserializer.ReadProperty(101, "file_row_number", result.file_row_number);
	deserializer.ReadProperty(102, "file_options", result.file_options);
	return result;
}

} // namespace duckdb