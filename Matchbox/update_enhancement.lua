--- STEAMODDED HEADER
--- MOD_NAME: update_enhancement
--- MOD_ID: Updateenhancement
--- MOD_AUTHOR: [Nrio]
--- MOD_DESCRIPTION: Updating enhancements from enhancement.api
----------------------------------------------
------------MOD CODE -------------------------
  
function get_best_table_number(value, rows)
  local composites = {2, 3, 4, 5, 6, 8, 9, 10, 12, 14, 15}
  for _, v in ipairs(composites) do
    if v >= value and v % rows == 0 then
      return v
    end
  end
  return 15
end

local create_UIBox_your_collection_enhancements_ref = create_UIBox_your_collection_enhancements
function create_UIBox_your_collection_enhancements(exit)
  local deck_tables = {}
  local rows, cols = 0, 0
  local page = 0

  rows = 2
  cols = 4
  local count = math.min(10, #G.P_CENTER_POOLS["Enhanced"])
  local table_amount = get_best_table_number(10, 2)
  local enhanced = {}
  for k, v in pairs(G.P_CENTERS) do
    if (v.set == "Enhanced") then
	  table.insert(enhanced,v)
	end
  end
  table.sort(enhanced, function(a,b) return a.order < b.order end)
  G.your_collection = {}
  for j = 1, rows do
    G.your_collection[j] = CardArea(
      G.ROOM.T.x + 0.2*G.ROOM.T.w/rows,0.4*G.ROOM.T.h,
      4.65*G.CARD_W,
      1.23*G.CARD_H,
      {card_limit = cols, type = 'title', highlight_limit = 0})
    table.insert(deck_tables,
    {n=G.UIT.R, config={align = "cm", padding = 0, no_fill = true}, nodes={
      {n=G.UIT.O, config={object = G.your_collection[j]}}
    }}
    )
  end
  local offset = 0
  local index = 1+(rows*cols*page)
  for j = 1, rows do
    for i = 1, cols do
      if count%rows > 0 and j < rows and i == cols then
        offset = offset + 1
        break
      end
      local center = enhanced[index]
	  
      local card = Card(G.your_collection[j].T.x + G.your_collection[j].T.w/rows*1.75, G.your_collection[j].T.y, G.CARD_W, G.CARD_H, G.P_CARDS.empty, center)
	  card:set_sprites(center)
	  if center.config.display_rank ~= false then
	    card.children.front = nil
	  end
	  G.your_collection[j]:emplace(card)
	  index = index + 1
    end
	if index > count then break end
  end

  local enhance_options = {}

  local t = create_UIBox_generic_options({ infotip = localize('ml_edition_seal_enhancement_explanation'), back_func = exit or 'your_collection', snap_back = true, contents = {
            {n=G.UIT.R, config={align = "cm", minw = 2.5, padding = 0.1, r = 0.1, colour = G.C.BLACK, emboss = 0.05}, nodes=deck_tables},
          }})

  if #G.P_CENTER_POOLS["Enhanced"] > rows * cols then
    for i = 1, math.ceil(#G.P_CENTER_POOLS.Enhanced/(rows*cols)) do
      table.insert(enhance_options, localize('k_page')..' '..tostring(i)..'/'..tostring(math.ceil(#G.P_CENTER_POOLS.Enhanced/(rows*cols))))
    end
    t = create_UIBox_generic_options({ infotip = localize('ml_edition_seal_enhancement_explanation'), back_func = exit or 'your_collection', snap_back = true, contents = {
            {n=G.UIT.R, config={align = "cm", minw = 2.5, padding = 0.1, r = 0.1, colour = G.C.BLACK, emboss = 0.05}, nodes=deck_tables},
            {n=G.UIT.R, config={align = "cm"}, nodes={
                    create_option_cycle({options = enhance_options, w = 4.5, cycle_shoulders = true, opt_callback = 'your_collection_enhancements_page', focus_args = {snap_to = true, nav = 'wide'},current_option = 1, r = rows, c = cols, colour = G.C.RED, no_pips = true})
                  }}
          }})
  end
  return t
end

G.FUNCS.your_collection_enhancements_page = function(args)
  if not args or not args.cycle_config then return end
  local rows = 2
  local cols = 4
  local page = args.cycle_config.current_option
  if page > math.ceil(#G.P_CENTER_POOLS.Enhanced/(rows * cols)) then
    page = page - math.ceil(#G.P_CENTER_POOLS.Enhanced/(rows * cols))
  end
  sendDebugMessage(page.." / "..math.ceil(#G.P_CENTER_POOLS.Enhanced/(rows * cols)))
  local count = rows * cols
  local offset = (rows * cols)*(page-1)
  sendDebugMessage("Page offset: "..tostring(offset))

  for j=1, #G.your_collection do
    for i=#G.your_collection[j].cards,1,-1 do
      if G.your_collection[j] ~= nil then
        local c = G.your_collection[j]:remove_card(G.your_collection[j].cards[i])
        c:remove()
        c = nil
      end
    end
  end

  for j = 1, rows do
    for i = 1, cols do
      if count%rows > 0 and i <= count%rows and j == cols then
        offset = offset - 1
        break
      end
      local idx = i+(j-1)*cols+offset
      if idx > #G.P_CENTER_POOLS["Enhanced"] then
        sendDebugMessage("End of Enhancement table.")
        return
      end
      sendDebugMessage("Loading Enhancement "..tostring(idx))
      local center = G.P_CENTER_POOLS["Enhanced"][idx]
      sendDebugMessage("Enhancement "..((center and "loaded") or "did not load").." successfuly.")
      local card = Card(G.your_collection[j].T.x + G.your_collection[j].T.w/2, G.your_collection[j].T.y, G.CARD_W, G.CARD_H, G.P_CARDS.empty, center)
	  card:set_sprites(center)
      card:start_materialize(nil, i>1 or j>1)
      G.your_collection[j]:emplace(card)
    end
  end
  sendDebugMessage("All Enhancements of Page "..page.." loaded.")
end
----------------------------------------------
------------MOD CODE END----------------------