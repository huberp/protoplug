--- Implements url 4648 Base64

local generic = require 'based.64.generic'

local url = {}

url.encode_lookup = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_"
url.decode_lookup = {
	 nil,  nil,  nil,  nil,  nil,  nil,  nil,  nil,
	 nil,  nil,  nil,  nil,  nil,  nil,  nil,  nil,
	 nil,  nil,  nil,  nil,  nil,  nil,  nil,  nil,
	 nil,  nil,  nil,  nil,  nil,  nil,  nil,  nil,
	 nil,  nil,  nil,  nil,  nil,  nil,  nil,  nil,
	 nil,  nil,  nil,  nil, 0x3e,  nil,  nil, 0x34,
	0x35, 0x36, 0x37, 0x38, 0x39, 0x3a, 0x3b, 0x3c,
	0x3d,  nil,  nil,  nil,  nil,  nil,  nil,  nil,
	0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07,
	0x08, 0x09, 0x0a, 0x0b, 0x0c, 0x0d, 0x0e, 0x0f,
	0x10, 0x11, 0x12, 0x13, 0x14, 0x15, 0x16, 0x17,
	0x18, 0x19,  nil,  nil,  nil,  nil, 0x3f,  nil,
	0x1a, 0x1b, 0x1c, 0x1d, 0x1e, 0x1f, 0x20, 0x21,
	0x22, 0x23, 0x24, 0x25, 0x26, 0x27, 0x28, 0x29,
	0x2a, 0x2b, 0x2c, 0x2d, 0x2e, 0x2f, 0x30, 0x31,
	0x32, 0x33
}
-- for i = 1, 255 do
-- 	local position = encode_lookup:find(string.char(i), 1, true)
-- 	io.write(position and string.format("0x%02x", position-1) or ' nil')
-- 	io.write(i%8==0 and ",\n" or ", ")
-- end

--- Encodes a value into URL-Safe Base64.
-- Supported types are `string` and `number`.
-- Strings will be encoded byte-wise with padding bits at the end, while
-- numbers will be encoded all at once with leading zeroes at the start.
-- @tparam string data A string treated as binary data
-- @treturn string The Base64 encoded input data
function url.encode(data)
	local output, err = generic.encode(url.encode_lookup,  data)
	if output then
		return output .. string.rep("=", (4 - #output) % 4)
	else
		return nil, err
	end
end

--- Decodes an URL-Safe Base64-encoded value.
-- @tparam string data Base64 encoded data
-- @tparam[opt="string"] string mode Either 'string' or 'number' to specify what type to decode as
-- @return The decoded input data
-- @treturn boolean `true` if the input data was correctly padded, `false` otherwise
function url.decode(data, mode)
	local first_pad = data:find("=", 1, true)

	if first_pad then
		data = data:sub(1, first_pad - 1)
	end

	local result, err = generic.decode(url.decode_lookup, data, mode)
	if result then
		return result, #data % 4 == 0
	else
		return result, err
	end
end

return url
