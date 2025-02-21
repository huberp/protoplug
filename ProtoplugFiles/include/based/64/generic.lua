local base64 = {}

function base64.decode(lookup, input, mode)
	if mode == "string" or mode == nil then
		local buffer = {}
		local length = math.floor(#input*6/8)
		local bits = length*8 - #input*6
		local acc = 0
		local buffer_pointer = length
		for i=#input, 1, -1 do
			local word6 = lookup[input:byte(i)]
			if not word6 then
				return nil, "Invalid character: " .. tostring(input:sub(i, i))
			end
			word6 = word6 * 2^bits
			bits = bits + 6
			acc = acc + word6
			if bits >= 8 then
				local b256 = acc % 256
				acc = math.floor(acc/256)
				bits = bits - 8
				buffer[buffer_pointer] = string.char(b256)
				buffer_pointer = buffer_pointer-1
			end
		end
		return table.concat(buffer)
	elseif mode == "number" then
		local number = 0
		for i=1, #input do
			number = number * 64 + lookup[input:byte(i)]
		end
		return number
	else
		error("Cannot decode type, supported are 'string' (default) and 'number', got " .. mode)
	end
end

function base64.encode(lookup, binary, length)
	local buffer = {}
	if type(binary) == "string" then
		local length = math.ceil(#binary*8/6)
		local acc = 0
		local bits = length*6 - #binary*8
		local buffer_pointer = length
		for i=#binary, 1, -1 do
			local byte = binary:byte(i)
			acc = acc + byte * 2^bits
			bits = bits + 8
			while bits >=6 do
				local b64 = (acc % 64)+1
				acc = math.floor(acc / 64)
				bits = bits - 6
				buffer[buffer_pointer] = lookup:sub(b64, b64)
				buffer_pointer = buffer_pointer-1
			end
		end
	elseif type(binary) == "number" then
		length = length or math.floor(math.log(binary, 64))+1
		for i=length, 1, -1 do
			local modulo = binary % 64
			buffer[i] = lookup:sub(modulo + 1, modulo + 1)
			binary = (binary - modulo) / 64
		end
	else
		error("Cannot encode type, supported are 'string' and 'number', got " .. type(binary))
	end
	return table.concat(buffer)
end

return base64
