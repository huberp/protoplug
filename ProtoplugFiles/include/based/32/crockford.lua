--- Implements Crockford's Base32 encoding

local generic = require 'based.32.generic'

local crockford = {}

crockford.encode_lookup = "0123456789ABCDEFGHJKMNPQRSTVWXYZ"
crockford.decode_lookup = {
	nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,
	nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,
	nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,
	nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,
	nil, nil, nil, nil, nil, nil, nil,   0,   1,   2,
	  3,   4,   5,   6,   7,   8,   9, nil, nil, nil,
	nil, nil, nil, nil,  10,  11,  12,  13,  14,  15,
	 16,  17,   1,  18,  19,   1,  20,  21,   0,  22,
	 23,  24,  25,  26, nil,  27,  28,  29,  30,  31,
	nil, nil, nil, nil, nil, nil,  10,  11,  12,  13,
	 14,  15,  16,  17,   1,  18,  19,   1,  20,  21,
	  0,  22,  23,  24,  25,  26, nil,  27,  28,  29,
	30, 31
}

--- Encodes a value into Base32.
-- Supported types are `string` and `number`.
-- Strings will be encoded byte-wise with padding bits at the end, while
-- numbers will be encoded all at once with leading zeroes at the start.
-- @tparam string data A string treated as binary data
-- @treturn string The Base32 encoded input data
function crockford.encode(data)
	return generic.encode(crockford.encode_lookup, data)
end

--- Decodes a Base32-encoded value.
-- @tparam string data Base32 encoded data
-- @tparam[opt="string"] string mode Either 'string' or 'number' to specify what type to decode as
-- @return The decoded input data
function crockford.decode(data, mode)
	return generic.decode(crockford.decode_lookup, data, mode)
end

return crockford
