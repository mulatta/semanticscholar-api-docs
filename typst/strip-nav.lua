-- PDF conversion filter: strip navigation footers and convert inter-file links

-- Remove navigation footer paragraphs (← prev | index | next →)
function Para(el)
  local text = pandoc.utils.stringify(el)
  if text:match("^←") and text:match("목차") then
    return {}
  end
  return nil
end

-- Convert inter-file .md links to plain text (no targets in single PDF)
function Link(el)
  local target = el.target
  -- If link points to another .md file, convert to plain text
  if target:match("%.md") then
    return el.content
  end
  -- Keep external links and same-file anchors
  return nil
end
