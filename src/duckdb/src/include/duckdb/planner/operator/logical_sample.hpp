//===----------------------------------------------------------------------===//
//                         DuckDB
//
// duckdb/planner/operator/logical_sample.hpp
//
//
//===----------------------------------------------------------------------===//

#pragma once

#include "duckdb/planner/logical_operator.hpp"
#include "duckdb/parser/parsed_data/sample_options.hpp"

namespace duckdb {

//! LogicalSample represents a SAMPLE clause
class LogicalSample : public LogicalOperator {
public:
	static constexpr const LogicalOperatorType TYPE = LogicalOperatorType::LOGICAL_SAMPLE;

public:
	LogicalSample(unique_ptr<SampleOptions> sample_options_p, unique_ptr<LogicalOperator> child);

	//! The sample options
	unique_ptr<SampleOptions> sample_options;

public:
	vector<ColumnBinding> GetColumnBindings() override;
	idx_t EstimateCardinality(ClientContext &context) override;

	void Serialize(FieldWriter &writer) const override;
	static unique_ptr<LogicalOperator> Deserialize(LogicalDeserializationState &state, FieldReader &reader);

	void FormatSerialize(FormatSerializer &serializer) const override;
	static unique_ptr<LogicalOperator> FormatDeserialize(FormatDeserializer &deserializer);

protected:
	void ResolveTypes() override;

private:
	LogicalSample();
};

} // namespace duckdb
