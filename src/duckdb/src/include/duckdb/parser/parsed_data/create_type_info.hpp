//===----------------------------------------------------------------------===//
//                         DuckDB
//
// duckdb/parser/parsed_data/create_type_info.hpp
//
//
//===----------------------------------------------------------------------===//

#pragma once

#include "duckdb/parser/parsed_data/create_info.hpp"
#include "duckdb/parser/column_definition.hpp"
#include "duckdb/parser/constraint.hpp"
#include "duckdb/parser/statement/select_statement.hpp"

namespace duckdb {

struct CreateTypeInfo : public CreateInfo {
	CreateTypeInfo();
	CreateTypeInfo(string name_p, LogicalType type_p);

	//! Name of the Type
	string name;
	//! Logical Type
	LogicalType type;
	//! Used by create enum from query
	unique_ptr<SQLStatement> query;

public:
	unique_ptr<CreateInfo> Copy() const override;

	DUCKDB_API static unique_ptr<CreateTypeInfo> Deserialize(Deserializer &deserializer);

	DUCKDB_API void FormatSerialize(FormatSerializer &serializer) const override;
	DUCKDB_API static unique_ptr<CreateInfo> FormatDeserialize(FormatDeserializer &deserializer);

protected:
	void SerializeInternal(Serializer &) const override;
};

} // namespace duckdb
