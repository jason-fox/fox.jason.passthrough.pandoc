--
--	This file is part of the DITA Pandoc project.
--	See the accompanying LICENSE file for applicable licenses.
-- 

-------------------------------------------------------------------
--
--  Module level varaibles used for DITA processing
--
-------------------------------------------------------------------

-- Variable to store footnotes, so they can be included after the end of a paragraph.
local footnote = nil
local note = false
local topics = {[0] = {elem = {}, open = true}}
local abstract0 = {elem = {}, open = true}
local abstract1 = {elem = {}, open = true}
local parent = {0, 0, 0, 0, 0, 0}
local level = {{}, {}, {}, {}, {}, {}}
local doctitle = nil
local codeblockCount = 0
local codephCount = 0
local topicCount = 0
local topicClosure = 0
local p = nil
local note_types = {'note', 'tip', 'fastpath', 'restriction', 'important', 'remember', 'attention', 'caution', 'notice', 'danger', 'warning', 'trouble', 'other'}



-------------------------------------------------------------------
--
--  Local functions used for DITA processing
--
-------------------------------------------------------------------


-- Character escaping
local function escape(s, in_attribute)
  return s:gsub("[<>&\"']",
    function(x)
      if x == '<' then
        return '&lt;'
      elseif x == '>' then
        return '&gt;'
      elseif x == '&' then
        return '&amp;'
      elseif x == '"' then
        return '&quot;'
      elseif x == "'" then
        return '&#39;'
      else
        return x
      end
    end)
end

local function has_value (tab, val)
    for index, value in ipairs(tab) do
        if value == val then
            return true
        end
    end
    return false
end


-- Adds a DITA  element to an arbitrary topic
local function pushElementToTopic (index, s)
   table.insert(topics[index].elem, s)
end


-- Adds a DITA block-level element to the current topic
local function pushElementToCurrentTopic (s)
  if (#topics == 1) then
     table.insert(abstract1.elem, s)
  end
  if (#topics == 0) then
     table.insert(abstract0.elem, s)
  else
    pushElementToTopic(#topics, s)
  end
end


-- Returns the latest block element added to the current topic
local function getLastTopicElement()
  return topics[#topics].elem[#topics[#topics].elem]
end


-- Removes a block element from the current topic.
-- This function is called when an element has been added in the wrong place.
local function popElementFromCurrentTopic ()
  if (#topics == 1) then
     table.remove(abstract1.elem, #abstract1.elem)
  end
  if (#topics == 0) then
     table.remove(abstract0.elem, #abstract0.elem)
  else
    table.remove(topics[#topics].elem, #topics[#topics].elem)
  end
end


-- Reverses the direction of an array
-- This is needed for <ol> and <ul> processing since we could have added <li><p> 
-- elements to the topic directly and we need to unwind them from the stack
local function reverseArray (arr)
  local i, j = 1, #arr

  while i < j do
    arr[i], arr[j] = arr[j], arr[i]

    i = i + 1
    j = j - 1
  end
end


-- Helper function to convert an attributes table into
-- a string that can be put into HTML tags.
local function attributes(attr)
  local attr_table = {}
  for x,y in pairs(attr) do
    if y and y ~= "" then
      y = string.gsub(y, '_', '-')
      y =  string.lower(y)

      if x == "class" then
        table.insert(attr_table, ' outputclass="' .. escape(y,true) .. '"')
      else
        table.insert(attr_table, ' ' .. x .. '="' .. escape(y,true) .. '"')
      end
    end
  end
  return table.concat(attr_table)
end


-- Run cmd on a temporary file containing inp and return result.
-- local function pipe(cmd, inp)
--  local tmp = os.tmpname()
--  local tmph = io.open(tmp, "w")
--  tmph:write(inp)
--  tmph:close()
--  local outh = io.popen(cmd .. " " .. tmp,"r")
--  local result = outh:read("*all")
--  outh:close()
--  os.remove(tmp)
--  return result
--end


-- Check used to determine if links are internal to the document.
function string.starts(String,Start)
   return string.sub(String,1,string.len(Start))==Start
end


-- Check used to split an input string used for <keyword> processing
function string.split(String, sep)
  if sep == nil then
    sep = "%s"
  end
  local t={} ; i=1
  for str in string.gmatch(String, "([^"..sep.."]+)") do
    t[i] = str
    i = i + 1
  end
  return t
end

-- The Document title can come from either the meta data or from the command line.
-- Use a default title for the root topic if no title is provided
local function getRootTopicTitle(metadata)
  local title = 'Document'
  if metadata.title ~= nil then
    title = metadata.title
  end
  if doctitle ~= nil then
    title = doctitle
  end
  return title
end


-- Convert pandoc alignment to something DITA can use.
-- align is AlignLeft, AlignRight, AlignCenter, or AlignDefault.
-- Used by <table> elements.
local function dita_align(align)
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


-- Close the existing topic body if it is still open.
-- i.e. this topic has no further subtopics.
local function closeTopicBody (index)
  if(topics[index].open == true ) then

    if ((topics[index].type == 'section')) then
      -- nothing
    elseif (not (index == #topics)) then
      if(not (topics[index+1].type == 'section') and topicCount ~= 1) then
        pushElementToTopic(index, "</body>")
      end
    else
      pushElementToTopic(index, "</body>")
    end 
     topics[index].open = false
  end 
end 


-- Element manipulation to ensure that DITA <topics> are
-- nested and closed properly
local function nestTopicWithinParent (index, parent)

  -- Close the existing topic body if it is still open.
  -- i.e. this topic has no subtopics.
  closeTopicBody(index)
  pushElementToTopic(index, "</" .. topics[index].name .. ">\n")
  topicClosure = topicClosure + 1

  if (topics[index].type == 'section') then
    if not (index == #topics) then
      if not (topics[index+1].type == 'section') then
         pushElementToTopic(index, "</body>\n")
         topics[parent].open = false 
      end
    elseif (topicCount == 1 or topicClosure > topicCount) then
       pushElementToTopic(index, "</body>\n")
    elseif (index == #topics and parent > 1) then
        pushElementToTopic(index, "</body>\n")
    else
      pushElementToTopic(index, "</" .. topics[parent].name .. ">\n")
    end
  end




  -- Close the existing parent body if it is still open
  closeTopicBody(parent)

  -- Add to parent if it is a subtopic - otherwise add to the root topic
  if (index > 1) then
    if (parent == 1) then
      -- Close the root topic body if it is still open
      closeTopicBody(0)
      pushElementToTopic(0, table.concat( topics[index].elem ,'\n'))
    else
      pushElementToTopic(parent, table.concat( topics[index].elem ,'\n'))
    end
  end
end


-------------------------------------------------------------------
--
--  All functions from here are called directly by Pandoc
--
--------------------------------------------------------------------

-- Blocksep is used to separate block elements.
function Blocksep()
  return "\n\n"
end


-- This function is called once for the whole document. Parameters:
-- body is a string, metadata is a table, variables is a table.
-- This gives you a fragment.  You could use the metadata table to
-- fill variables in a custom lua template.  Or, pass `--template=...`
-- to pandoc, and pandoc will add do the template processing as
-- usual.
function Doc(body, metadata, variables)
  local buffer = {}
  local function add(s)
    table.insert(buffer, s)
  end

  if (#level[1] > 1) then
    io.stderr:write("Multiple Root Nodes detected.")
  end

  if (#topics > 0) then
    -- Iterate across h1 to h6 topics and add to the associated
    -- parent topic.
    for i = 6, 1, -1 do 
      for j = 1,  #level[i] do
        -- The +1 here is because LUA defaults to using 1 based arrays
        -- The topic[0] has been added as a root element so the counting is out
        nestTopicWithinParent (level[i][j].index + 1, level[i][j].parent + 1)
      end
    end
    -- Just in case we have a document with no headers, check to close the 
    -- root topic body as it may still be open.
  
    closeTopicBody(0)
  end

  -- Now we start to create the real output
  


  -- Add a title to the root DITA topic - this should have a reasonable 
  -- default as a fallback.
  local rootTopicTitle = getRootTopicTitle(metadata)

  -- rootTopicTitle = string.gsub(rootTopicTitle, '_', '-')
   rootTopicId = string.gsub(rootTopicTitle, "[#_;<>&\"']", '-')
   rootTopicId = string.lower(rootTopicId)
  
  -- Add all the elements contained within the root DITA topic, then close it
  if (#level[1] == 0) then
    add('<topic class="- topic/topic " domains="(topic abbrev-d) a(props deliveryTarget) (topic equation-d) (topic hazard-d) (topic hi-d) (topic indexing-d) (topic markup-d) (topic mathml-d) (topic pr-d) (topic relmgmt-d) (topic sw-d) (topic svg-d) (topic ui-d) (topic ut-d) (topic markup-d xml-d)" id="' .. string.gsub(rootTopicId, ' ', '-') .. '">')

  
    add('<title class="- topic/title " >' .. rootTopicTitle .. '</title>')
    if (tablelength(metadata) > 1) then
      add(createProlog (metadata))
    end
    add('<body class="- topic/body " >')
    add(table.concat( abstract0.elem ,'\n'))
    if (#topics == 0) then
      add('</body>\n')
    end

  elseif (#level[1] == 1) then
    local preBuffer = {}
    local postBuffer = {}

    for idx, elem in ipairs(abstract1.elem) do
      if (idx < 2) then
        table.insert(preBuffer, elem)
      else
        table.insert(postBuffer, elem)
      end
    end

    add(table.concat( preBuffer ,'\n'))
    if (tablelength(metadata) > 1) then
      add(createProlog (metadata))
    end
    add(table.concat( postBuffer ,'\n'))
    --add(table.concat( abstract1.elem ,'\n'))
    --add('</body>\n')
  else
    add('<topic class="- topic/topic " domains="(topic abbrev-d) a(props deliveryTarget) (topic equation-d) (topic hazard-d) (topic hi-d) (topic indexing-d) (topic markup-d) (topic mathml-d) (topic pr-d) (topic relmgmt-d) (topic sw-d) (topic svg-d) (topic ui-d) (topic ut-d) (topic markup-d xml-d)" id="' .. string.gsub(rootTopicId, ' ', '-') .. '">')
    add('<title class="- topic/title " >' .. rootTopicTitle .. '</title>')
    if (tablelength(metadata) > 1) then
      add(createProlog (metadata))
    end
    add('<body class="- topic/body " >')
  end


 

  add(table.concat( topics[0].elem ,'\n'))
  if (topicCount == 1 and #topics == 1) then
    add('</body>\n')
  end
  add('</topic>\n')

  return table.concat(buffer,'\n') .. '\n'
end


function  createProlog (metadata)
  local buffer = {}
  local author = {}
  local source = nil
  local permissions = nil
  local publisher = nil
  local audience = nil
  local category = nil
  local keywords = {}
  local resourceids = {}
  local unknowns = {}
  local addMetadata = false

  local function add(s)
    table.insert(buffer, s)
  end

  if(tablelength (metadata) > 0) then

    if (metadata.shortdesc ~= nil) then
      add('<shortdesc class="- topic/shortdesc ">' .. metadata.shortdesc .. '</shortdesc>')
    end
    add('<prolog class="- topic/prolog ">\n')
    for k, v in pairs(metadata) do
      if (k =='author') then
        if type(v) == "table" then
          for k, v in pairs(v) do
            add('<author class="- topic/author ">' .. v .. '</author>')
          end
        else
          add('<author class="- topic/author ">' .. v .. '</author>')
        end
      elseif (k =='source') then
        source = '<source class="- topic/source ">' .. v .. '</source>'
      elseif (k =='publisher') then
        publisher = '<publisher class="- topic/publisher ">' .. v .. '</publisher>'
      elseif (k =='permissions') then
        permissions = '<permissions class="- topic/permissions" view="' .. v .. '"/>'
      elseif (k =='shortdesc') then
        -- Nothing
      elseif (k =='title') then
        -- Nothing
      elseif (k =='audience') then
        addMetadata = true
        audience ='<audience audience="' .. v .. '" class="- topic/audience "/>'
      elseif (k =='category') then
        addMetadata = true
        category = '<category class="- topic/category ">' .. v .. '</category>'
      elseif (k =='keyword') then
        addMetadata = true
        if type(v) == "table" then
          for k, v in pairs(v) do
            table.insert(keywords, '<keyword class="- topic/keyword ">' .. v .. '</keyword>')
          end
        else
          table.insert(keywords, '<keyword class="- topic/keyword ">' .. v .. '</keyword>')
        end  
      elseif (k =='resourceid') then
        if type(v) == "table" then
          for k, v in pairs(v) do
            table.insert(resourceids, '<resourceid appid="' .. v .. '" ux-source-priority="topic-and-map" class="- topic/resourceid "/>')
          end
        else
          table.insert(resourceids, '<resourceid appid="' .. v .. '" ux-source-priority="topic-and-map" class="- topic/resourceid "/>')
        end
      else
        table.insert(unknowns, '<data name="'.. k .. '" value="' .. v .. '" class="- topic/data "/>')
      end
    end


    if (source ~= nil) then
      add(source)
    end
    if (publisher ~= nil) then
      add(publisher)
    end
    if (permissions ~= nil) then
      add(permissions)
    end
    if (addMetadata == true) then
      add('<metadata class="- topic/metadata ">')
      if (audience ~= nil) then
        add(audience)
      end
      if (category ~= nil) then
        add(category)
      end
      if (tablelength (keywords) > 0) then
        add('<keywords class="- topic/keywords ">')
        for k, v in pairs(keywords) do
          add(v)
        end
        add('</keywords>')
      end
      add('</metadata>')
    end
    if (tablelength (resourceids) > 0) then
      for k, v in pairs(resourceids) do
        add(v)
      end
    end
    if (tablelength (unknowns) > 0) then
      for k, v in pairs(unknowns) do
        add(v)
      end
    end
    add('</prolog>')
  end
  return table.concat(buffer,'\n')
end


function tablelength(T)
  local count = 0
  for _ in pairs(T) do count = count + 1 end
  return count
end

-- The functions that follow render corresponding pandoc elements.
-- s is always a string, attr is always a table of attributes, and
-- items is always an array of strings (the items in a list).
-- Comments indicate the types of other variables.


function Str(s)
  return escape(s)
end


function Space()
  return " "
end


-- Linebreak does not translate directly to a DITA element
-- Add a carriage return
function LineBreak()
  return "\n"
end


-- Emph is an inline element that translates to <i>
function Emph(s)
  return "<i class='+ topic/ph hi-d/i '>" .. s .. "</i>"
end


-- Strong is an inline element that translates to <b>
function Strong(s)
  return "<b class='+ topic/ph hi-d/b '>" .. s .. "</b>"
end


-- Subscript is an inline element that translates to <sub>
function Subscript(s)
  return "<sub class='+ topic/ph hi-d/sub '>" .. s .. "</sub>"
end


-- Superscript is an inline element that translates to <sup>
function Superscript(s)
  return "<sup class='+ topic/ph hi-d/sup '>" .. s .. "</sup>"
end


-- SmallCaps does not translate dirctly to a DITA element
-- Annotate an inline <ph> element with an outputclass attibute
function SmallCaps(s)
  return '<ph class="- topic/ph " outputclass="small-caps">' .. s .. '</ph>'
end


-- SmallCaps does not translate dirctly to a DITA element
-- Annotate an inline <ph> element with an outputclass attibute
function Strikeout(s)
  return '<ph class="+ topic/ph   hi-d/line-through " outputclass="strikeout">' .. s .. '</ph>'
end


function SoftBreak()
  return "\n"
end

function DoubleQuoted(s)
  return "&quot;"  .. s .. "&quot;" 
end


-- Link is an inline element that translates to <xref>
-- We need to differenciate between internal and external links
function Link(s, src, tit)
   src = string.gsub(src, '_', '-')
   src = string.gsub(src, '%%20', ' ')
   src =  string.lower(src)
  if string.starts(src,'#') then
    return '<xref class="- topic/xref " href="' .. escape(src,true) .. '" format="dita">' .. s .. '</xref>'
  else
    if string.match(src,' ') then
      index = string.find(src, "[^ ]*$")
      src = string.sub(src, index)
    end
    if src == "" then
      return s
    else
      return '<xref class="- topic/xref " href="' .. escape(src,true) .. '" format="html" scope="external">' .. s .. '</xref>'
    end
  end
end


-- Image is an inline element that translates to <image>
function Image(s, src, tit)
 
  if tit == nil then
    return '<image class="- topic/image " href="' .. escape(src,true) .. '"/>'
  else
    return '<image class="- topic/image " scalefit="yes" href="' .. escape(src,true) .. '">' ..
      '<alt class="- topic/alt ">' .. tit .. '</alt>' ..
      '</image>'
  end
end


-- Code is an inline element that translates to <codeph>
function Code(s, attr)
  codephCount = codephCount + 1
  return '<codeph class="+ topic/ph pr-d/codeph "'  .. attributes(attr) .. '  xtrc="codeph:' .. 
    codephCount ..'" xtrf="">' .. escape(s) .. '</codeph>'
end


function InlineMath(s)
  return "\\(" .. escape(s) .. "\\)"
end


function DisplayMath(s)
  return "\\[" .. escape(s) .. "\\]"
end


-- Pandoc Note translates to a DITA  <fn> element. This is usually a footnote,
-- but we can add an additional block element after the closure of the current paragraph.

-- Currently only simple single paragraph notes are supported.
function Note(s)
  
  if s ~= "" then
    -- This is a plain text list item
    footnote = '<fn class="- topic/fn ">\n\t' .. s .. '\n</fn>'
  else
    -- If the item is empty this is a paragraph within the <fn>
    -- remove the <p> previously processed from the topic and add it to the list items
    footnote = '<fn class="- topic/fn ">\n\t' .. getLastTopicElement() .. '</fn>' 
    popElementFromCurrentTopic()
  end

  return ""
end


-- Span is an inline element that translates to <ph>
function Span(s, attr)
  return '<ph class="- topic/ph "' .. attributes(attr) .. ">" .. s .. "</ph>"
end


-- Cite is an inline element that translates to <cite>
function Cite(s, cs)
  return "<cite class='- topic/cite '>" .. s .. "</cite>"
end


function Plain(s)
  return s
end

function RawBlock(format, str)
  if format == "html" then
    if str == "<br/>" then
      return '\n'
    elseif str == "<br>" then
      return '\n'
    end
  end
  return ''
end


function RawInline(format, str)
  if format == "html" then
    if str == "<br/>" then
      return '\n'
    elseif str == "<br>" then
      return '\n'
    end
  end
  return ''
end

-- Para is an block level element that translates to <p>
function Para(s)
  p = s
  pushElementToCurrentTopic('<p class="- topic/p " >\n\t' .. s .. "\n</p>")
  -- Place any <fn> after the closed paragraph
  if footnote ~= nil then
     pushElementToCurrentTopic(footnote)
     footnote = nil
  end
  return "" 
end


-- Header is a special element that gives the document structure
-- and trasnlates to a <topic> with <title>, <body> and include sub elements

-- We need to remember the parentage of the <topic> so we can rebuild a structured
-- DITA  document later

-- lev is an integer, the header level.
function Header(lev, s, attr)

  if (has_value(note_types, attr.class)) then
    note = true

    if has_value(note_types, string.lower(s)) then
      pushElementToCurrentTopic ('<note class="- topic/note " type="' .. string.lower(s) .. '">\n\t')
    else
      pushElementToCurrentTopic ('<note class="- topic/note " type="other" othertype="' .. s .. '">\n\t')
    end
    return ""
  end

  if (note == true) then
     pushElementToCurrentTopic ('</note>')
     note = false
  end

  for i = lev+1, #parent do
    parent[i]= #topics
  end

  level[lev][#level[lev]+1] =  {
    index = #topics,
    parent =  parent[lev]
  }

 -- Uncomment this line to see the structure of the document.
 -- print (#topics .. ' ' .. lev .. ' ' .. parent[lev] .. ' ' .. level[lev][#level[lev]].parent .. ' '.. s  )

  if #topics == 0 then
    doctitle = s
  end

  if (attr.class == 'section') then
      topics[#topics + 1 ] = {elem = {}, open = true, type = "section", name = "section"}
      pushElementToCurrentTopic ('<section class="- topic/section " ' ..  attributes(attr) .. 
     '>\n<title class="- topic/title " >' .. s .. '</title>\n')
  elseif (attr.class == 'example') then
      topics[#topics + 1 ] = {elem = {}, open = true, type = "section", name = "example"}
      pushElementToCurrentTopic ('<example class="- topic/example " ' ..  attributes(attr) .. 
     '>\n<title class="- topic/title " >' .. s .. '</title>\n')

  else
    topicCount = topicCount + 1
    topics[#topics + 1 ] = {elem = {}, open = true, type = "topic", name="topic", body="body"}
    pushElementToCurrentTopic ('<topic class="- topic/topic " domains="(topic abbrev-d) a(props deliveryTarget) (topic equation-d) (topic hazard-d) (topic hi-d) (topic indexing-d) (topic markup-d) (topic mathml-d) (topic pr-d) (topic relmgmt-d) (topic sw-d) (topic svg-d) (topic ui-d) (topic ut-d) (topic markup-d xml-d)" ' ..  attributes(attr) .. 
     '>\n<title class="- topic/title " >' .. s .. '</title>')
    pushElementToCurrentTopic ('<body class="- topic/body " >')
  end

  return ""
end


-- Blockquote is an inline element that translates to <q>
function BlockQuote(s)
  return "<q class='- topic/q '>\n" .. s .. "\n</q>"
end


-- HorizontalRule does not translate directly to a DITA element
-- Add a carriage return
function HorizontalRule()

  if (note == true) then
    pushElementToCurrentTopic ('</note>')
    note = false
  end
  return "\n"
end


-- LineBlock is an inline element that translates to <lines>
function LineBlock(ls)
  return '<lines class="- topic/lines ">' .. table.concat(ls, '\n') .. '</lines>'
end


-- Codeblock is an block level element that translates to <codeblock>
function CodeBlock(s, attr)

  codeblockCount = codeblockCount + 1

  pushElementToCurrentTopic ('<codeblock class="+ topic/pre pr-d/codeblock " '
      .. attributes(attr) .. '  xtrc="codeblock:' .. codeblockCount ..'" xtrf="">' .. escape(s) .. '</codeblock>')
  return ""
end


-- BulletList is an block level element that translates to <ul> with <li> sub elements
function BulletList(items)
  local buffer = {}
  local reverse = false
  for _, item in pairs(items) do
    if item ~= "" then
      -- This is a plain text list item
      table.insert(buffer, '\t<li class="- topic/li ">' .. item .. "</li>\n")
    else
      -- If the item is empty this is a paragraph within the <li>
      -- remove the <p> previously processed from the topic and add it to the list items
       table.insert(buffer, '\t<li class="- topic/li ">' .. getLastTopicElement()  .. "</li>\n")
       popElementFromCurrentTopic()
      -- To maintainorder we'll need to reverse the order
      -- Hopefully all the items in the list can be processed the same way
       reverse = true
    end
  end

  -- If we've been picking from the end we'll need to reverse the order.
  if reverse == true then
    reverseArray(buffer)
  end


  pushElementToCurrentTopic ('<ul class="- topic/ul ">\n' .. table.concat(buffer, "") .. "</ul>")
  return ""
end


-- OrderedList is an block level element that translates to <ol> with <li> sub elements
function OrderedList(items)
  local buffer = {}
  local reverse = false
  for _, item in pairs(items) do
    if item ~= "" then
       -- This is a plain text list item
      table.insert(buffer, '\t<li class="- topic/li ">' .. item .. "</li>\n")
    else
       -- If the item is empty this is a paragraph within the <li>
       -- remove the <p> previously processed from the topic and add it to the list items
       table.insert(buffer, '\t<li class="- topic/li ">' .. getLastTopicElement() .. "</li>\n")
       popElementFromCurrentTopic()
       reverse = true
    end
  end

  if reverse == true then
    reverseArray(buffer)
  end

  pushElementToCurrentTopic('<ol class="- topic/ol ">\n' .. table.concat(buffer, "") .. "</ol>")
  return ""
end


-- DefinitionList is an block level element that translates to <dl> with <dlentry> sub elements
function DefinitionList(items)
  local buffer = {}
  for _,item in pairs(items) do
    for k, v in pairs(item) do
      table.insert(buffer,"\n\t<dlentry class='- topic/dlentry '>\n\t\t<dt class='- topic/dt '>" .. k .. "</dt>\n\t\t<dd class='- topic/dd '>" ..
                        table.concat(v,"</dd>\n\t\t<dd class='- topic/dd '>") .. "</dd>\n\t</dlentry>")
    end
  end
  pushElementToCurrentTopic("<dl class='- topic/dl '>" .. table.concat(buffer, "\n") .. "\n</dl>")
  return ""
end


-- CaptionedImage is an block level element that translates to <fig> with <title> abd <image> sub elements
function CaptionedImage(src, tit, caption)
  pushElementToCurrentTopic('<fig class="- topic/fig ">\n\t<title class="- topic/title ">' .. caption .. '</title>\n' ..
      '\t<image class="- topic/image " scalefit="yes" href="' .. escape(src,true) .. '">\n' ..
      '\t\t<alt class="- topic/alt ">' .. tit .. '</alt>\n\t</image>\n</fig>')
  return ""
end


-- Table is an block level element that translates to <table> complex sub elements
-- Caption is a string, aligns is an array of strings,
-- widths is an array of floats, headers is an array of
-- strings, rows is an array of arrays of strings.
function Table(caption, aligns, widths, headers, rows)
  local buffer = {}
  local width_total = 0
  local max_cols = 0
  local function add(s)
    table.insert(buffer, s)
  end

  for _, row in pairs(rows) do
    max_cols = math.max(max_cols, #row)
  end

  add("<table class='- topic/table '>")
  if caption ~= "" then
    add("\t<title class='- topic/title '>" .. caption .. "</title>")
  end
  add('\t<tgroup class="- topic/tgroup " cols="' .. max_cols .. '">')
  if widths and widths[1] ~= 0 then
    
    for _, w in pairs(widths) do
      width_total = width_total + w
    end
    for _, w in pairs(widths) do
      add('\t\t<colspec class="- topic/colspec " colname="c' .. _ .. '" colnum="' .. _ .. '" colwidth="' .. string.format("%d%%", math.floor((w / width_total) * 100)) .. '"/>')
    end
  else
    for _, w in pairs(widths) do
      add('\t\t<colspec class="- topic/colspec " colname="c' .. _ .. '" colnum="' .. _ .. '"/>')
    end
  end
  local header_row = {}
  local empty_header = true
  for i, h in pairs(headers) do
    local align = dita_align(aligns[i])
    table.insert(header_row,'\t\t\t\t<entry class="- topic/entry " colname="c' .. i .. '" align="' .. align ..  '">' .. h .. '</entry>')
    empty_header = empty_header and h == ""
  end
  if empty_header then
    head = ""
  else
    add('\t\t<thead class="- topic/thead ">')
    add('\t\t\t<row class="- topic/row ">')
    for _,h in pairs(header_row) do
      add(h)
    end
    add('\t\t\t</row>')
    add('\t\t</thead>')
  end
  add('\t\t<tbody class="- topic/tbody ">')
  for _, row in pairs(rows) do
    add('\t\t\t<row class="- topic/row ">')
    addLines = false
    for i,c in pairs(row) do
      c = c:gsub("&#13;", "\n")
      c = c:gsub("&#xD;", "\n")
      if (string.match(c,'\n')) then
        addLines = true
      end
    end
    for i,c in pairs(row) do
      local align = dita_align(aligns[i])
      if (addLines == true) then
        c = '<lines class="- topic/lines ">' .. c  .. '</lines>'
      end
      add('\t\t\t\t<entry class="- topic/entry " colname="c' .. i 
        .. '" align="' .. align ..  '">' .. c .. '</entry>')
    end
    add('\t\t\t</row>')
  end
  add('\t\t</tbody>')
  add('\t</tgroup>')
  add('</table>')

  local table_xml = table.concat(buffer,'\n')

  pushElementToCurrentTopic(table.concat(buffer,'\n'))
  return ""
end


function Div(s, attr)
  
  if (attr.class == "admonition-title") then
    if (p ~= nil) then
      if has_value(note_types, string.lower(p)) then
        popElementFromCurrentTopic()
      end
    end      
  end

  if (has_value(note_types, attr.class)) then
    div_note = '<note class="- topic/note " type="' .. attr.class .. '">\n\t' .. getLastTopicElement() .. '</note>' 
    popElementFromCurrentTopic()
    pushElementToCurrentTopic(div_note)
  end

  --  pushElementToCurrentTopic("<div class='- topic/div '" .. attributes(attr) .. ">\n" .. s .. "</div>")
  return "" -- "<div class='- topic/div '" .. attributes(attr) .. ">\n" .. s .. "</div>"
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

