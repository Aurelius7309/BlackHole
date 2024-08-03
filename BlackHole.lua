--- STEAMODDED HEADER
--- MOD_NAME: Black Hole
--- MOD_ID: BlackHole
--- PREFIX: blh
--- MOD_AUTHOR: [Aure]
--- MOD_DESCRIPTION: Screen reader mod for Balatro.
--- VERSION: 0.1.0

BlackHole = SMODS.current_mod
BlackHole.save_config = function(self)
    SMODS.save_mod_config(self)
    G.keybind_mapping = {}
    -- Setup keyboard emulation
    for k, v in pairs(self.config.keybinds) do G.keybind_mapping[v] = k end
    function G.CONTROLLER.keyboard_controller.setVibration() end
end
BlackHole:save_config()

tts = SMODS.load_file('Love2talk/Love2talk.lua')()
G.E_MANAGER:add_event(Event{
    func = function()
        if SMODS.booted then
            tts.say(localize { type = 'variable', key = 'tts_welcome', vars = { BlackHole.version } })
            return true
        end
    end
})
local keybind_list = {
    'dpleft',
    'dpright',
    'dpup',
    'dpdown',
    'x',
    'y',
    'a',
    'b',
    'start',
    'triggerleft',
    'triggerright',
    'leftshoulder',
    'rightshoulder',
}
BlackHole.keybind_lookup = {}
for i = 1, #keybind_list do
    BlackHole.keybind_lookup[keybind_list[i]] = keybind_list[i == #keybind_list and 1 or i+1]
end
SMODS.Keybind{
	key = 'welcome',
	key_pressed = '1',
    action = function(controller)
        tts.silence()
        tts.say(localize { type = 'variable', key = 'tts_welcome', vars = { BlackHole.version }})
    end,
}
SMODS.Keybind{
	key = 'game_speed',
	key_pressed = '2',
    action = function(controller)
        local nopeus = (SMODS.Mods.nopeus or {}).can_load
        local sequence = {
            [0.25] = 0.5,
            [0.5] = 1,
            [1] = 2,
            [2] = nopeus and 3 or 4,
            [3] = 4,
            [4] = nopeus and 8 or 0.5,
            [8] = 16,
            [16] = 32,
            [32] = 64,
            [64] = 999,
            [999] = 0.25,
        }
        G.SETTINGS.GAMESPEED = sequence[G.SETTINGS.GAMESPEED]
        tts.silence()
        tts.say(localize { type = 'variable', key = 'tts_game_speed', vars = { G.SETTINGS.GAMESPEED }})
        G:save_settings()
    end,
}
SMODS.Keybind{
    key = 'kc_setup',
    key_pressed = '3',
    action = function(controller)
        tts.silence()
        tts.say(localize('tts_kc_'..(BlackHole.config.keyboard_controller and 'on' or 'off')))
    end
}
SMODS.Keybind{
    key = 'kc_toggle',
    key_pressed = '4',
    action = function(controller)
        BlackHole.config.keyboard_controller = not BlackHole.config.keyboard_controller
        BlackHole:save_config()
        tts.silence()
        tts.say(localize('tts_kc_'..(BlackHole.config.keyboard_controller and 'on' or 'off')))
    end
}
SMODS.Keybind{
    key = 'kc_info',
    key_pressed = '5',
    action = function(controller)
        if not BlackHole.config.keyboard_controller then return end
        if BlackHole.selected_keybind then
            BlackHole.selected_keybind = BlackHole.keybind_lookup[BlackHole.selected_keybind]
        else
            BlackHole.selected_keybind = keybind_list[1]
        end
        tts.silence()
        tts.say(localize {
            type = 'variable',
            key = 'tts_config_keybind',
            vars = { localize(BlackHole.selected_keybind, 'tts_keybinds'), BlackHole.config.keybinds[BlackHole.selected_keybind] }
        })
    end
}

SMODS.Keybind{
    key = 'kc_change',
    key_pressed = '6',
    action = function(controller)
        if not BlackHole.selected_keybind then return end
        BlackHole.awaiting_keypress = BlackHole.selected_keybind
        tts.silence()
        tts.say(localize {
            type = 'variable',
            key = 'tts_assign_keybind',
            vars = { localize(BlackHole.selected_keybind, 'tts_keybinds') }
        })
    end
}

BlackHole.reserved_keys = {}
for i = 1, 6 do BlackHole.reserved_keys[''..i] = true end

-- "to_search" is table of where to start the search
-- "target" is function returning where to start search, 
-- "search_params" is table containing "override" (ignore base search checks) and "search" (function for custom search)
-- "str_manip" is function for string manip after search
function BlackHole.find_strings(t)
    local to_search, target, search_params, str_manip = t.to_search or {}, t.target or function(to_search) return to_search end, t.search_params or {}, t.str_manip or nil
    local final_str = ''
    local function find_strings_recurse(to_search)
        to_search = target(to_search) or {}
        for _, v in ipairs(to_search) do
            local text_to_merge = nil
            if search_params.override then 
                text_to_merge = ""..search_params.search(v, text_to_merge)
            elseif v.config and type(v.config.text) == 'string' then
                text_to_merge = ""..v.config.text
            elseif v.config and v.config.object and v.config.object.string then
                text_to_merge = ""..v.config.object.string
            elseif search_params.search and type(search_params.search) == "function" then
                text_to_merge = ""..search_params.search(v, text_to_merge)
            end
            if text_to_merge then
                if str_manip and type(str_manip) == "function" then text_to_merge = str_manip(text_to_merge) end
                final_str = final_str..text_to_merge..' '
            else
                find_strings_recurse(v)
            end
        end
    end
    find_strings_recurse(to_search)
    return final_str
end

function BlackHole.process_hover(controller)
    local node = controller.hovering.target
    if BlackHole.hover_suppressed then return end
    -- Do not restart speech  when the same node is hovered again
    if BlackHole.last_tts_node == node and BlackHole.hover_time_elapsed <= 3 then return end
    if node:is(Card) and node.area == G.deck then
         --ugly
            node.tts = localize('k_view')..' '..localize('k_deck')
    end
    if node.tts and node.tts ~= '' then
        tts.silence() 
        if node.area ~= G.deck and node.facing == 'back' then 
            node.tts = node.highlighted and localize({
                    type = 'variable',
                    key = 'tts_highlighted',
                    vars = localize('tts_face_down_card')
                }) or
                localize('tts_face_down_card')
        end
        tts.say(node.tts)
        BlackHole.last_tts_node = node 
        BlackHole.hover_time_elapsed = 0
    else
        BlackHole.read_button(node)
        if node.config.h_popup then BlackHole.read_h_popup(node.config.h_popup, node) end
    end
end

function BlackHole.read_h_popup(popup, node)
    local popup_text = ''
    popup_text = BlackHole.find_strings({to_search = popup,
        target = function(to_search) return to_search.nodes end, 
        str_manip = function(text_to_merge)
            if text_to_merge:match('^%$+%+?$') then
                local has_plus = text_to_merge:match('%+$')
                text_to_merge = localize('$')..(text_to_merge:len() - (has_plus and 1 or 0))..(has_plus and ' +' or '')
            end 
            --TODO this is not always what we want, compare blind reward vs. foil tooltip
            if string.find(text_to_merge, '[%d%+]$') then text_to_merge = text_to_merge..' -' end
            return text_to_merge
        end})
    if popup_text ~= '' then 
        --tts.silence()
        tts.say(popup_text)
        BlackHole.last_tts_node = node
    end
end

function BlackHole.read_button(node)
    local q
    local but_text = BlackHole.find_strings({to_search = node,
        target = function(to_search) return to_search.children end, 
        str_manip = function(text_to_merge) --Note: This is using the previous find_strings function logic. Might not be needed in times the function is called
            if text_to_merge:match('^%$%$+%+?$') then
                local has_plus = text_to_merge:match('%+$')
                text_to_merge = localize('$')..(text_to_merge:len() - (has_plus and 1 or 0))..(has_plus and ' +' or '')
            end
            if string.find(text_to_merge, '%d[%d%+]$') then text_to_merge = text_to_merge..' - ' end
            local x_base = localize('k_x_base')
            if text_to_merge:sub(-#x_base) == x_base then text_to_merge = text_to_merge..' - ' end
            return text_to_merge
        end
    })
    local is_blind_select_button = false
    for _, v in ipairs{ "Select", "Skipped", "Current", "Defeated", "Upcoming", "Selected" } do
        if but_text == localize(v, 'blind_states')..' ' then is_blind_select_button = true; break end
    end
    if is_blind_select_button then
        but_text = BlackHole.find_strings({to_search = node.parent.parent.parent,
            target = function(to_search) return to_search.children end, 
            str_manip = function(text_to_merge) --Note: This is using the previous find_strings function logic. Might not be needed in times the function is called
                if text_to_merge:match('^%$%$+%+?$') then
                    local has_plus = text_to_merge:match('%+$')
                    text_to_merge = localize('$')..(text_to_merge:len() - (has_plus and 1 or 0))..(has_plus and ' +' or '')
                end
                if string.find(text_to_merge, '%d[%d%+]$') then text_to_merge = text_to_merge..' - ' end
                local x_base = localize('k_x_base')
                if text_to_merge:sub(-#x_base) == x_base then text_to_merge = text_to_merge..' - ' end
                return text_to_merge
            end
        })
    end
    local is_cashout_button = node.config.id == 'cash_out_button'
    if is_cashout_button then
        but_text = localize {
            type = 'variable',
            key = 'tts_current_money',
            vars = { G.GAME.dollars }
        } .. but_text
        q = true
    end

    local is_tab_shoulders = node.config.id == 'tab_shoulders'
    if is_tab_shoulders then
        but_text = ''
        for _,v in ipairs(node.children) do
            if v.children[1].config.chosen then 
                but_text = but_text..BlackHole.find_strings({to_search = v.children[1],
                    target = function(to_search) return to_search.children end, 
                    str_manip = function(text_to_merge) --Note: This is using the previous find_strings function logic. Might not be needed in times the function is called
                        if text_to_merge:match('^%$%$+%+?$') then
                            local has_plus = text_to_merge:match('%+$')
                            text_to_merge = localize('$')..(text_to_merge:len() - (has_plus and 1 or 0))..(has_plus and ' +' or '')
                        end
                        if string.find(text_to_merge, '%d[%d%+]$') then text_to_merge = text_to_merge..' - ' end
                        local x_base = localize('k_x_base')
                        if text_to_merge:sub(-#x_base) == x_base then text_to_merge = text_to_merge..' - ' end
                        return text_to_merge
                    end
                })
            end
        end
    end
    local is_play_hand = but_text == localize('b_play_hand')..' '
    local is_discard =  but_text == localize('b_discard')..' '
    if is_play_hand or is_discard then
        local amount = G.GAME.current_round[is_play_hand and 'hands_left' or 'discards_left']
        but_text = but_text .. localize {
            type = 'variable',
            key = 'tts_remaining',
            vars = { amount, localize((is_play_hand and 'tts_hand' or 'tts_discard')..(amount ~= 1 and 's' or '')) }
        }
    end
    if is_play_hand and node.config.button then
        if G.boss_throw_hand then
            but_text = but_text.. " - " .. localize('ph_unscored_hand') .. G.GAME.blind:get_loc_debuff_text() .. " - "
        end
        local text,disp_text = G.FUNCS.get_poker_hand_info(G.hand.highlighted)
        local hand = G.GAME.hands[text]
        but_text = but_text .. localize {
            type = 'variable',
            key = 'tts_hand_eval',
            vars = { disp_text, hand.level, hand.chips, hand.mult }
        }
        but_text = but_text .. localize {
            type = 'variable',
            key = 'tts_played_this_run',
            vars = { hand.played, localize('tts_time'..(hand.played ~= 1 and 's' or '')) }
        }
    end
    local is_poker_hand_button = (node.config.on_demand_tooltip and G.GAME.hands[node.config.on_demand_tooltip.filler.args]) and true or nil
    if is_poker_hand_button then
        local poker_hand_info = G.GAME.hands[node.config.on_demand_tooltip.filler.args]
        but_text = localize {
            type = 'variable',
            key = 'tts_hand_eval',
            vars = { localize(node.config.on_demand_tooltip.filler.args, 'poker_hands'), poker_hand_info.level, poker_hand_info.chips, poker_hand_info.mult }
        }
        but_text = but_text .. localize {
            type = 'variable',
            key = 'tts_played_this_run',
            vars = { poker_hand_info.played, localize('tts_time'..(poker_hand_info.played ~= 1 and 's' or '')) }
        }
    end
    if but_text ~= '' then
        if not q then tts.silence() end
        tts.say(but_text)
        BlackHole.last_tts_node = node
    end
end