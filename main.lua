
require 'lfs'

print "Hello, this is a Lua program.\n"
print(string.format("Current time: %s.\n", os.time()))


-- Deprecated function
function enumrateDir(dirPath)

	for file in lfs.dir(dirPath) do
	    local mode = lfs.attributes(file, "mode")

	    if mode == "file" then
	        print("Found file, " .. file)
	    elseif mode == "directory" then
	        print("Found directory, " .. file)
	    else
	        print("Unknown mode of item: " .. file .. ", mode:" .. (mode or "nil"))
	    end
	end
end

function isSourceFile(file)
	-- print(file)

    local idx = string.find(file, "[.]+") or 0
    -- print(string.format("idx: %d", idx))

    local subfile = string.sub(file, idx, idx + string.len(file) - idx)
    -- print("subfile: " .. subfile)

    local validExt = {".m", ".mm", ".c", ".cpp", ".h"}
    for i, v in pairs(validExt) do
    	if v == subfile then
    		return true
    	end
    end
    return false
end

function isVaildCodeLine(strline)
	local newLine = string.gsub(strline, " ", "")
	-- print(newLine)

	if newLine == "" then
		return false
	elseif string.len(newLine) == 1 then
		return false
	else
		local idx = string.find(newLine, "//")
		-- print(idx)
		if not idx and idx ~= 1 then
			-- print(newLine)
			return true
		end
	end
end

function isMethodDelcare(strline)
	local newLine = string.find(strline, " ", "")
	-- print(newLine)

	if newLine == "" then
		return false
	else
		local subLine = string.sub(newLine, 1, 1)
		if subLine == "+" or subLine == "-" then
			print(subLine)
			return true
		end
	end
end

function isDir(name)
    if type(name)~="string" then 
    	return false 
    end
    
    local cd = lfs.currentdir()
    local is = lfs.chdir(name) and true or false
    lfs.chdir(cd)
    return is
end

function searchFileInDir(dirPath)
	local total = 0

	for file in lfs.dir(dirPath) do
    	local fullPath = string.format("%s/%s", dirPath, file)
	    local mode = lfs.attributes(fullPath, "mode")

	    if mode ~= "directory" and isSourceFile(file) then

	        local rfile = io.open(fullPath, 'r')
	        assert(rfile)

	        local icount = 0
	        for line in rfile:lines() do
	        	-- print(line)
	        	if isVaildCodeLine(line) then
	        		icount = icount + 1
	        	end

	        	-- if isMethodDelcare(line) then
	        	-- 	icount = icount + 1
	        	-- end
	       	end

	        print(string.format("File: %s, count: %d", file, icount, dirPath))
	       	total = total + icount
	   	elseif mode == "directory" then
	    	-- print("subDir: " .. fullPath)

	    	if file ~= "." and file ~= ".." and file ~= ".DS_Store" then
		    	total = searchFileInDir(fullPath) + total
		    end
		end
	end

    -- print("---------------------------------------------------")
	return total
end


--- Main ---

local srcRoot = arg[1]

if not srcRoot then
	print("Please give me a project directory's full path: ")
	local srcRoot = io.read("*line")
	print(srcRoot)
end

repeat
	local fvalid = isDir(srcRoot)
	if not fvalid then
		print("Invalid directory path, try again.\nNew path:")
		srcRoot = io.read("*line")
	end
until fvalid

local totalCount = searchFileInDir(srcRoot)
print(string.format("\nTotal valid source code line count: %d, directory: %s.\n", totalCount, srcRoot))

