-- This is a sample custom writer for pandoc.  It produces output
-- that is very similar to that of pandoc's HTML writer.
-- There is one new feature: code blocks marked with class 'dot'
-- are piped through graphviz and images are included in the HTML
-- output using 'data:' URLs. The image format can be controlled
-- via the `image_format` metadata field.
--
-- Invoke with: pandoc -t sample.lua
--
-- Note:  you need not have lua installed on your system to use this
-- custom writer.  However, if you do have lua installed, you can
-- use it to test changes to the script.  'lua sample.lua' will
-- produce informative error messages if your code contains
-- syntax errors.

local pipe = pandoc.pipe
local stringify = (require "pandoc.utils").stringify

-- The global variable PANDOC_DOCUMENT contains the full AST of
-- the document which is going to be written. It can be used to
-- configure the writer.
local meta = PANDOC_DOCUMENT.meta

-- Choose the image format based on the value of the
-- `image_format` meta value.
local image_format = meta.image_format
  and stringify(meta.image_format)
  or "png"
local image_mime_type = ({
    jpeg = "image/jpeg",
    jpg = "image/jpeg",
    gif = "image/gif",
    png = "image/png",
    svg = "image/svg+xml",
  })[image_format]
  or error("unsupported image format `" .. image_format .. "`")

-- Character escaping
local function escape(s, in_attribute)
  return s
  -- return s:gsub("[<>&\"']",
  --  function(x)
  --    if x == '<' then
  --      return '&lt;'
  --    elseif x == '>' then
  --      return '&gt;'
  --    elseif x == '&' then
  --      return '&amp;'
  --    elseif in_attribute and x == '"' then
  --      return '&quot;'
  --    elseif in_attribute and x == "'" then
  --      return '&#39;'
  --    else
  --      return x
  --    end
  --  end)
end

-- Helper function to convert an attributes table into
-- a string that can be put into HTML tags.
local function attributes(attr)
  local attr_table = {}
  for x,y in pairs(attr) do
    if y and y ~= "" then
      table.insert(attr_table, ' ' .. x .. '="' .. escape(y,true) .. '"')
    end
  end
  return table.concat(attr_table)
end

-- Convert header level to size
local function header_level_to_size(level)
  local MAX_SIZE = 7
  local MIN_SIZE = 5
  local size = MAX_SIZE - level + 1
  if size < MIN_SIZE then
    size = MIN_SIZE
  end
  return size
end

-- Table to store footnotes, so they can be included at the end.
local notes = {}

-- Blocksep is used to separate block elements.
function Blocksep()
  return "\n\n"
end

-- This function is called once for the whole document. Parameters:
-- body is a string, metadata is a table, variables is a table.
-- This gives you a fragment.  You could use the metadata table to
-- fill variables in a custom lua template.  Or, pass `--template=...`
-- to pandoc, and pandoc will do the template processing as usual.
function Doc(body, metadata, variables)
  local buffer = {}
  local function add(s)
    table.insert(buffer, s)
  end
  add(body)
  return table.concat(buffer, '\n') .. '\n'
end

-- The functions that follow render corresponding pandoc elements.
-- s is always a string, attr is always a table of attributes, and
-- items is always an array of strings (the items in a list).
-- Comments indicate the types of other variables.

function Str(s)
  return s
end

function Space()
  return " "
end

function SoftBreak()
  return ' '
end

function LineBreak()
  return '\n'
end

function Emph(s)
  return '[i]' .. s .. '[/i]'
end

function Strong(s)
  return '[b]' .. s .. '[/b]'
end

function Subscript(s)
  return '[sub]' .. s .. '[/sub]'
end

function Superscript(s)
  return '[sup]' .. s .. '[/sup]'
end

function SmallCaps(s)
  -- return '<span style="font-variant: small-caps;">' .. s .. '</span>'
  return s
end

function Strikeout(s)
  return '[s]' .. s .. '[/s]'
end

function Link(s, src, tit, attr)
  return '[url=' .. escape(src, true) ..']' .. s .. '[/url]'
end

function Image(s, src, tit, attr)
  return '[img]' .. escape(src, true) .. '[/img]'
end

function Code(s, attr)
  return '[code' .. attributes(attr) .. ']' .. escape(s) .. '[/code]'
end

function InlineMath(s)
  return '[latex]' .. escape(s) .. '[/latex]'
end

function DisplayMath(s)
  return '[latex]' .. escape(s) .. '[/latex]'
end

function SingleQuoted(s)
  return "'" .. s .. "'"
end

function DoubleQuoted(s)
  return '"' .. s .. '"'
end

function Note(s)
  -- local num = #notes + 1
  -- -- insert the back reference right before the final closing tag.
  -- s = string.gsub(s,
  --         '(.*)</', '%1 <a href="#fnref' .. num ..  '">&#8617;</a></')
  -- -- add a list item with the note to the note table.
  -- table.insert(notes, '<li id="fn' .. num .. '">' .. s .. '</li>')
  -- -- return the footnote reference, linked to the note.
  -- return '<a id="fnref' .. num .. '" href="#fn' .. num ..
  --           '"><sup>' .. num .. '</sup></a>'
  return s
end

function Span(s, attr)
  -- return "<span" .. attributes(attr) .. ">" .. s .. "</span>"
  return s
end

function RawInline(format, str)
  if format == "html" then
    return str
  else
    return ''
  end
end

function Cite(s, cs)
  -- local ids = {}
  -- for _,cit in ipairs(cs) do
  --   table.insert(ids, cit.citationId)
  -- end
  -- return "<span class=\"cite\" data-citation-ids=\"" .. table.concat(ids, ",") ..
  --   "\">" .. s .. "</span>"
  return s
end

function Plain(s)
  return s
end

function Para(s)
  -- return "<p>" .. s .. "</p>"
  return s
end

-- lev is an integer, the header level.
function Header(lev, s, attr)
  -- return "<h" .. lev .. attributes(attr) ..  ">" .. s .. "</h" .. lev .. ">"
  return '[b][size=' .. header_level_to_size(lev) .. ']' .. s .. '[/size][/b]'
end

function BlockQuote(s)
  -- return "<blockquote>\n" .. s .. "\n</blockquote>"
  return '[quote]' .. '[/quote]'
end

function HorizontalRule()
  return '[hr][/hr]'
end

function LineBlock(ls)
  return '[indent]' .. table.concat(ls, '\n') .. '[/indent]'
end

function CodeBlock(s, attr)
  -- -- If code block has class 'dot', pipe the contents through dot
  -- -- and base64, and include the base64-encoded png as a data: URL.
  -- if attr.class and string.match(' ' .. attr.class .. ' ',' dot ') then
  --   local img = pipe("base64", {}, pipe("dot", {"-T" .. image_format}, s))
  --   return '<img src="data:' .. image_mime_type .. ';base64,' .. img .. '"/>'
  -- -- otherwise treat as code (one could pipe through a highlighter)
  -- else
  --   return "<pre><code" .. attributes(attr) .. ">" .. escape(s) ..
  --          "</code></pre>"
  -- end
  return '[code' .. attributes(attr) .. ']' .. escape(s) .. '[/code]'

end

function BulletList(items)
  local buffer = {}
  for _, item in pairs(items) do
    table.insert(buffer, '[*]' .. item .. '\n')
  end
  return '[list]\n' .. table.concat(buffer, '') .. '[/list]'
end

function OrderedList(items)
  local buffer = {}
  for _, item in pairs(items) do
    table.insert(buffer, '[*]' .. item .. '\n')
  end
  return '[list=1]\n' .. table.concat(buffer, '') .. '\n[/list]'
end

-- Revisit association list StackValue instance.
function DefinitionList(items)
  local buffer = {}
  for _,item in pairs(items) do
    for k, v in pairs(item) do
      table.insert(buffer,'[b]' .. k .. '[/b]\n[indent]' ..
                        table.concat(v,'\n') .. '[/indent]')
    end
  end
  return '\n' .. table.concat(buffer, '\n') .. '\n'
end

-- Convert pandoc alignment to something HTML can use.
-- align is AlignLeft, AlignRight, AlignCenter, or AlignDefault.
local function html_align(align)
  if align == 'AlignLeft' then
    return 'left'
  elseif align == 'AlignRight' then
    return 'right'
  elseif align == 'AlignCenter' then
    return 'center'
  else
    return 'left'
  end
end

function CaptionedImage(src, tit, caption, attr)
   return '[img]' .. escape(src, true) ..
      '[/img]\n' ..
      '[i]' .. caption .. '[/i]\n'
end

-- Caption is a string, aligns is an array of strings,
-- widths is an array of floats, headers is an array of
-- strings, rows is an array of arrays of strings.
-- TODO: Implement
function Table(caption, aligns, widths, headers, rows)
  -- local buffer = {}
  -- local function add(s)
  --   table.insert(buffer, s)
  -- end
  -- add("<table>")
  -- if caption ~= "" then
  --   add("<caption>" .. caption .. "</caption>")
  -- end
  -- if widths and widths[1] ~= 0 then
  --   for _, w in pairs(widths) do
  --     add('<col width="' .. string.format("%d%%", w * 100) .. '" />')
  --   end
  -- end
  -- local header_row = {}
  -- local empty_header = true
  -- for i, h in pairs(headers) do
  --   local align = html_align(aligns[i])
  --   table.insert(header_row,'<th align="' .. align .. '">' .. h .. '</th>')
  --   empty_header = empty_header and h == ""
  -- end
  -- if empty_header then
  --   head = ""
  -- else
  --   add('<tr class="header">')
  --   for _,h in pairs(header_row) do
  --     add(h)
  --   end
  --   add('</tr>')
  -- end
  -- local class = "even"
  -- for _, row in pairs(rows) do
  --   class = (class == "even" and "odd") or "even"
  --   add('<tr class="' .. class .. '">')
  --   for i,c in pairs(row) do
  --     add('<td align="' .. html_align(aligns[i]) .. '">' .. c .. '</td>')
  --   end
  --   add('</tr>')
  -- end
  -- add('</table')
  -- return table.concat(buffer,'\n')
  return ''
end

-- TODO: Implement
function RawBlock(format, str)
  -- if format == "html" then
  --   return str
  -- else
  --   return ''
  -- end
  return ''
end

function Div(s, attr)
  -- return "<div" .. attributes(attr) .. ">\n" .. s .. "</div>"
  return s
end

-- The following code will produce runtime warnings when you haven't defined
-- all of the functions you need for the custom writer, so it's useful
-- to include when you're working on a writer.
local meta = {}
meta.__index =
  function(_, key)
    io.stderr:write(string.format("WARNING: Undefined function '%s'\n",key))
    return function() return "" end
  end
setmetatable(_G, meta)
