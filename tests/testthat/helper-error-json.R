# Make snapshots of an engine error independent of the platform.
#
# An engine error reaches R as a JSON object: `exception_type`, `exception_message`,
# then the extra info such as `type`, `name`, `candidates` and `error_subtype`.
# The engine keeps the extra info in a hash map, so its order differs between platforms
# (macOS and Linux disagree), and a snapshot recorded on one fails on the other.
# This transform keeps the two leading keys in place and sorts the rest by key.
# It handles the flat object of string values the engine emits, and leaves any other line alone.
sort_error_json_keys <- function(x) {
  pair <- '"((?:[^"\\\\]|\\\\.)*)":"((?:[^"\\\\]|\\\\.)*)"'
  object <- paste0("^(.*! )\\{(", pair, "(?:,", pair, ")*)\\}$")
  vapply(
    x,
    function(line) {
      match <- regmatches(line, regexec(object, line, perl = TRUE))[[1]]
      if (length(match) == 0) {
        return(line)
      }
      pairs <- regmatches(match[[3]], gregexpr(pair, match[[3]], perl = TRUE))[[
        1
      ]]
      keys <- sub(paste0("^", pair, "$"), "\\1", pairs, perl = TRUE)
      lead <- match(c("exception_type", "exception_message"), keys)
      lead <- lead[!is.na(lead)]
      rest <- setdiff(seq_along(pairs), lead)
      rest <- rest[order(keys[rest], method = "radix")]
      paste0(match[[2]], "{", paste(pairs[c(lead, rest)], collapse = ","), "}")
    },
    character(1),
    USE.NAMES = FALSE
  )
}
