#include "duckdb/parser/expression/parameter_expression.hpp"

#include "duckdb/common/exception.hpp"
#include "duckdb/common/field_writer.hpp"
#include "duckdb/common/types/hash.hpp"
#include "duckdb/common/to_string.hpp"

#include "duckdb/common/serializer/format_serializer.hpp"
#include "duckdb/common/serializer/format_deserializer.hpp"

namespace duckdb {

ParameterExpression::ParameterExpression()
    : ParsedExpression(ExpressionType::VALUE_PARAMETER, ExpressionClass::PARAMETER) {
}

string ParameterExpression::ToString() const {
	return "$" + identifier;
}

unique_ptr<ParsedExpression> ParameterExpression::Copy() const {
	auto copy = make_uniq<ParameterExpression>();
	copy->identifier = identifier;
	copy->CopyProperties(*this);
	return std::move(copy);
}

bool ParameterExpression::Equal(const ParameterExpression &a, const ParameterExpression &b) {
	return StringUtil::CIEquals(a.identifier, b.identifier);
}

hash_t ParameterExpression::Hash() const {
	hash_t result = ParsedExpression::Hash();
	return CombineHash(duckdb::Hash(identifier.c_str(), identifier.size()), result);
}

void ParameterExpression::Serialize(FieldWriter &writer) const {
	writer.WriteString(identifier);
}

unique_ptr<ParsedExpression> ParameterExpression::Deserialize(ExpressionType type, FieldReader &reader) {
	auto expression = make_uniq<ParameterExpression>();
	expression->identifier = reader.ReadRequired<string>();
	return std::move(expression);
}

} // namespace duckdb
