local lapis = require 'lapis'
local util = require 'lapis.util'
local respond_to = require("lapis.application").respond_to
local lfs = require 'lfs'
local markdown = require 'markdown'


local function block_scripts(input)
	input = input:gsub('<script', '&lt;script')
	input = input:gsub('</script', '&lt;/script')
	return input
end

local function read_page(filename)
	local f = io.open(filename, 'r')
	if f then
		local content = f:read("*all")
		f:close()
		return content
	else
		return ''
	end
end

local function write_page(filename, content, mode)
	mode = mode or 'w'
	local f = assert(io.open(filename, mode))
	f:write(content)
	f:close()
end

local function load_page(filename)
	local content = read_page('content/pages/' .. filename)
	content = markdown.renderString(content)
	-- Should be redundant as we run this before saving content
	content = block_scripts(content)
	content = '<div class="content">\n' .. content .. '\n</div>'
	return content
end

local function save_edit_history(filename, content)
	content = '<h2 class="edit-date">' .. os.date() .. '</h2>' .. 
				'\n<pre class="edit-history">'.. content .. '\n</pre>\n\n'
	write_page('content/histories/' .. filename, content, 'a+')
end

local function pages_sorted_by_modification_time()
	local pages = {}
	for path in lfs.dir('content/pages') do
		if path ~= '.' and path ~= '..' then
			table.insert(pages, {name = path,  time = lfs.attributes('content/pages/' .. path).modification})
		end
	end
	table.sort(pages, function(a,b)
		return a.time > b.time
	end)
	return pages
end


local app = lapis.Application()
app:enable("etlua")
app.layout = require 'views.layout'


app:get("/", function(self)
	self.pages = pages_sorted_by_modification_time()
	return {render = 'homepage'}
end)

app:get('/view/:page', function(self)
	self.content = load_page(self.params.page)
	return {render = 'view_page'}
end)

app:get('/history/:page', function(self)
	self.content = read_page('content/histories/' .. self.params.page)
	return {render = 'history_page'}
end)

app:match('edit', '/edit/:page', respond_to({
	GET = function(self)
		self.raw_content = read_page('content/pages/' .. self.params.page)
		return {render = 'edit_page'}
	end,
	
	POST = function(self)
		local content = self.params.page_content
		content = block_scripts(content)
		write_page('content/pages/' .. self.params.page, content)
		
		save_edit_history(self.params.page, content)
		return { redirect_to = '/view/' .. self.params.page }
	end
}))

app:match('new', '/new', respond_to({
	GET = function(self)
		return {render = 'new_page'}
	end,
	
	POST = function(self)
		local page_title = self.params.new_page
		page_title = block_scripts(page_title)
		page_title = util.escape(page_title)
		page_title = page_title:gsub('%%20', '-')
		return { redirect_to = '/edit/' .. page_title}
	end
}))

return app
