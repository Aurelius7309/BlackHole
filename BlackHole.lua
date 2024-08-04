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
G.E_MANAGER:add_event(Event {
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
    BlackHole.keybind_lookup[keybind_list[i]] = keybind_list[i == #keybind_list and 1 or i + 1]
end
SMODS.Keybind {
    key = 'welcome',
    key_pressed = '1',
    action = function(controller)
        tts.silence()
        tts.say(localize { type = 'variable', key = 'tts_welcome', vars = { BlackHole.version } })
    end,
}
SMODS.Keybind {
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
        tts.say(localize { type = 'variable', key = 'tts_game_speed', vars = { G.SETTINGS.GAMESPEED } })
        G:save_settings()
    end,
}
SMODS.Keybind {
    key = 'kc_setup',
    key_pressed = '3',
    action = function(controller)
        tts.silence()
        tts.say(localize('tts_kc_' .. (BlackHole.config.keyboard_controller and 'on' or 'off')))
    end
}
SMODS.Keybind {
    key = 'kc_toggle',
    key_pressed = '4',
    action = function(controller)
        BlackHole.config.keyboard_controller = not BlackHole.config.keyboard_controller
        BlackHole:save_config()
        tts.silence()
        tts.say(localize('tts_kc_' .. (BlackHole.config.keyboard_controller and 'on' or 'off')))
    end
}
SMODS.Keybind {
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

SMODS.Keybind {
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
for i = 1, 6 do BlackHole.reserved_keys['' .. i] = true end

-- "to_search" is table of where to start the search
-- "target" is function returning where to start search,
-- "search_params" is table containing "override" (ignore base search checks) and "search" (function for custom search)
-- "str_manip" is function for string manip after search
function BlackHole.find_strings(t)
    local to_search, target, search_params, str_manip = t.to_search or {},
        t.target or function(to_search) return to_search end, t.search_params or {}, t.str_manip or nil
    local final_str = ''
    local function find_strings_recurse(to_search)
        to_search = target(to_search) or {}
        for _, v in ipairs(to_search) do
            local text_to_merge = nil
            if search_params.override then
                text_to_merge = "" .. (search_params.search(v, text_to_merge) or '')
            elseif v.config and type(v.config.text) == 'string' then
                text_to_merge = "" .. v.config.text
            elseif v.config and v.config.object and v.config.object.string then
                text_to_merge = ""..v.config.object.string
            elseif search_params.search and type(search_params.search) == "function" and search_params.search(v, text_to_merge) ~= nil then
                text_to_merge = ""..search_params.search(v, text_to_merge)
            end
            if text_to_merge then
                if str_manip and type(str_manip) == "function" then text_to_merge = str_manip(text_to_merge) end
                final_str = final_str .. text_to_merge .. ' '
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
    if BlackHole.hover_suppressed then
        if G.STATE == G.STATES.GAME_OVER then -- stupid, game over deletes the event that's meant to kill the suppression
            BlackHole.hover_suppressed = false
        else return end
    end
    -- Do not restart speech  when the same node is hovered again
    if BlackHole.last_tts_node == node and BlackHole.hover_time_elapsed <= 3 then return end
    if node:is(Card) and node.area == G.deck then
        --ugly
        node.tts = localize('k_view') .. ' ' .. localize('k_deck')
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
    popup_text = BlackHole.find_strings({
        to_search = popup,
        target = function(to_search) return to_search.nodes end,
        str_manip = function(text_to_merge)
            if text_to_merge:match('^%$+%+?$') then
                local has_plus = text_to_merge:match('%+$')
                text_to_merge = localize('$') .. (text_to_merge:len() - (has_plus and 1 or 0)) ..
                (has_plus and ' +' or '')
            end
            --TODO this is not always what we want, compare blind reward vs. foil tooltip
            if string.find(text_to_merge, '[%d%+]$') then text_to_merge = text_to_merge .. ' -' end
            return text_to_merge
        end
    })
    if popup_text ~= '' then
        --tts.silence()
        tts.say(popup_text)
        BlackHole.last_tts_node = node
    end
end

function BlackHole.read_button(node)
    local q
    local but_text = BlackHole.find_strings({
        to_search = node,
        target = function(to_search) return to_search.children end,
        str_manip = function(text_to_merge) --Note: This is using the previous find_strings function logic. Might not be needed in times the function is called
            if text_to_merge:match('^%$%$+%+?$') then
                local has_plus = text_to_merge:match('%+$')
                text_to_merge = localize('$') .. (text_to_merge:len() - (has_plus and 1 or 0)) ..
                (has_plus and ' +' or '')
            end
            if string.find(text_to_merge, '%d[%d%+]$') then text_to_merge = text_to_merge .. ' - ' end
            local x_base = localize('k_x_base')
            if text_to_merge:sub(-#x_base) == x_base then text_to_merge = text_to_merge..' - ' end
            if text_to_merge:match(localize('b_skip_blind')) then text_to_merge = localize('tts_skip_blind') end
            if text_to_merge:match(localize('b_new_run')) or text_to_merge:match(localize('b_start_new_run')) then
                text_to_merge = localize('tts_new_run')
                if node.config.id == 'from_game_over' then text_to_merge = localize('ph_game_over').. ' ... ' .. text_to_merge; q = true end
                if node.config.id == 'from_game_won' then text_to_merge = localize('ph_you_win') .. text_to_merge; q = true end
            end
            return text_to_merge
        end
    })
    local is_blind_select_button = false
    for _, v in ipairs { "Select", "Skipped", "Current", "Defeated", "Upcoming", "Selected" } do
        if but_text == localize(v, 'blind_states') .. ' ' then
            is_blind_select_button = true; break
        end
    end
    if is_blind_select_button then
        but_text = BlackHole.find_strings({
            to_search = node.parent.parent.parent,
            target = function(to_search) return to_search.children end,
            str_manip = function(text_to_merge) --Note: This is using the previous find_strings function logic. Might not be needed in times the function is called
                if text_to_merge:match('^%$%$+%+?$') then
                    local has_plus = text_to_merge:match('%+$')
                    text_to_merge = localize('$') ..
                    (text_to_merge:len() - (has_plus and 1 or 0)) .. (has_plus and ' +' or '')
                end
                if string.find(text_to_merge, '%d[%d%+]$') then text_to_merge = text_to_merge .. ' - ' end
                local x_base = localize('k_x_base')
                if text_to_merge:sub(-#x_base) == x_base then text_to_merge = text_to_merge..' - ' end
                if text_to_merge:match(localize('b_skip_blind')) then text_to_merge = localize('tts_skip_blind') end
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
        for _, v in ipairs(node.children) do
            if v.children[1].config.chosen then
                but_text = but_text .. BlackHole.find_strings({
                    to_search = v.children[1],
                    target = function(to_search) return to_search.children end,
                    str_manip = function(text_to_merge) --Note: This is using the previous find_strings function logic. Might not be needed in times the function is called
                        if text_to_merge:match('^%$%$+%+?$') then
                            local has_plus = text_to_merge:match('%+$')
                            text_to_merge = localize('$') ..
                            (text_to_merge:len() - (has_plus and 1 or 0)) .. (has_plus and ' +' or '')
                        end
                        if string.find(text_to_merge, '%d[%d%+]$') then text_to_merge = text_to_merge .. ' - ' end
                        local x_base = localize('k_x_base')
                        if text_to_merge:sub(- #x_base) == x_base then text_to_merge = text_to_merge .. ' - ' end
                        return text_to_merge
                    end
                })
            end
        end
    end
    local is_play_hand = but_text == localize('b_play_hand') .. ' '
    local is_discard = but_text == localize('b_discard') .. ' '
    if is_play_hand or is_discard then
        local amount = G.GAME.current_round[is_play_hand and 'hands_left' or 'discards_left']
        but_text = but_text .. localize {
            type = 'variable',
            key = 'tts_remaining',
            vars = { amount, localize((is_play_hand and 'tts_hand' or 'tts_discard') .. (amount ~= 1 and 's' or '')) }
        }
    end
    if is_play_hand and node.config.button then
        if G.boss_throw_hand then
            but_text = but_text .. " - " .. localize('ph_unscored_hand') .. G.GAME.blind:get_loc_debuff_text() .. " - "
        end
        local text, disp_text = G.FUNCS.get_poker_hand_info(G.hand.highlighted)
        local hand = G.GAME.hands[text]
        but_text = but_text .. localize {
            type = 'variable',
            key = 'tts_hand_eval',
            vars = { disp_text, hand.level, hand.chips, hand.mult }
        }
        but_text = but_text .. localize {
            type = 'variable',
            key = 'tts_played_this_run',
            vars = { hand.played, localize('tts_time' .. (hand.played ~= 1 and 's' or '')) }
        }
    end
    local is_poker_hand_button = (node.config.on_demand_tooltip and G.GAME.hands[node.config.on_demand_tooltip.filler.args]) and
    true or nil
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
            vars = { poker_hand_info.played, localize('tts_time' .. (poker_hand_info.played ~= 1 and 's' or '')) }
        }
    end
    local function check_parents(node, uie_id)
        if node:is(UIBox) and node:get_UIE_by_ID(uie_id) then return node:get_UIE_by_ID(uie_id)
        elseif node.parent then return check_parents(node.parent, uie_id) 
        else return nil end
    end
    local node_with_tag_container = check_parents(node, 'tag_container')
    if node_with_tag_container and but_text:match(localize('b_skip_blind')) then
        -- TODO: un-scuff, assuming you even can
        local tag, tag_sprite = node_with_tag_container.children[2].children[2].Mid.config.ref_table, node_with_tag_container.children[2].children[2].Mid.config.ref_table.tag_sprite
        local tag_tts, tag_AUT = '', tag_sprite.ability_UIBox_table
        if tag_AUT == nil then tag:get_uibox_table(tag_sprite); tag_AUT = tag_sprite.ability_UIBox_table end

        if tag_AUT.name and type(tag_AUT.name) == 'table' then
            if tag_AUT.name[1].config.object then
                tag_tts = tag_tts..tag_AUT.name[1].config.object.string.. ' - '
            else
                local name_text = ''
                for _, v in ipairs(tag_AUT.name) do
                    if v.config and type(v.config.text) == 'string' then name_text = name_text..v.config.text end
                end
                tag_tts = tag_tts .. name_text .. ' - '
            end
        end
        local desc_text = ''
        for _, v in ipairs(tag_AUT.main) do
            desc_text = desc_text..BlackHole.find_strings({to_search = v,
                search_params = {
                    override = true,
                    search = function(to_search, text_to_merge)
                        if to_search.config and type(to_search.config.text) == 'string' then
                            text_to_merge = to_search.config.text
                        elseif to_search.config and to_search.config.object and to_search.config.object.string then
                            local str = to_search.config.object.string
                            if type(str) == 'table' then
                                text_to_merge = table.concat(str, ' ')
                            else
                                text_to_merge = str
                            end
                        elseif to_search.nodes and to_search.nodes[1] and to_search.nodes[1].config and type(to_search.nodes[1].config.text) == 'string' then
                            text_to_merge = to_search.nodes[1].config.text
                        end
                        return text_to_merge
                    end
                }
            })..' '
        end
        tag_tts = tag_tts..desc_text..'- '

        for _, v in ipairs(tag_AUT.info) do
            tag_tts = tag_tts..v.name..' - '

            local tooltip_desc_text = ""
            tooltip_desc_text = BlackHole.find_strings({to_search = v,
                search_params = {
                    search = function(to_search, text_to_merge)
                        if to_search.nodes and to_search.nodes[1] and to_search.nodes[1].config and type(to_search.nodes[1].config.text) == 'string' then
                            text_to_merge = to_search.nodes[1].config.text
                        end
                        return text_to_merge
                    end
                },
                str_manip = function(text_to_merge)
                    if text_to_merge:match('^%$+%+$') then
                        text_to_merge = localize('$')..(text_to_merge:len() - 1)..' +'
                    end
                    if string.find(text_to_merge, '[%d%+]$') then text_to_merge = text_to_merge..' -' end
                    return text_to_merge
                end
            })

            tag_tts = tag_tts..tooltip_desc_text .. ' - '
        end

        but_text = but_text..tag_tts
    end
    if but_text ~= '' then
        if not q then tts.silence() end
        tts.say(but_text)
        BlackHole.last_tts_node = node
    end
end

function BlackHole.read_back_info()
    local center = G.GAME.viewed_back.effect.center
    local name_text = center.unlocked and
        localize { type = 'name_text', set = 'Back', key = center.key } or 
        localize { type = 'name_text', set = 'Other', key = 'locked' }
    local desc_text = BlackHole.find_strings({
        to_search = G.GAME.viewed_back:generate_UI(),
        target = function(to_search) return to_search.nodes end,
    })
    return name_text .. ' - ' .. desc_text
end
function BlackHole.read_stake_info()
    if not G.GAME.viewed_back.effect.center.unlocked then return '' end
    local stake = G.viewed_stake
    for _, v in ipairs(G.P_CENTER_POOLS.Stake) do
        if v.stake_level == stake then stake = v; break end
    end
    if type(stake) ~= 'table' then return '' end
    local name_text = localize { type = 'name_text', set = 'Stake', key = stake.key }
    local desc_text = table.concat(localize { type = 'raw_descriptions', set = 'Stake', key = stake.key }, ' ')
    return name_text .. ' - ' .. desc_text
end

function BlackHole.run_setup_controller(button)
    if button == 'start' then
        BlackHole.capture_controller = nil; return
    end
    local n = BlackHole.capture_controller
    if n == 1 then
        tts.silence()
        BlackHole.capture_controller = 2
        -- remove continue option if starting from run
        if G.FUNCS.can_continue({ config = { func = true } }) and G.STAGE == G.STAGES.MAIN_MENU then
            tts.say(localize('tts_select_run_choice'))
        else
            BlackHole.run_setup_controller('a')
        end
    elseif n == 2 then
        if button == 'a' then
            if not G.SAVED_GAME then
                G.SAVED_GAME = get_compressed(G.SETTINGS.profile .. '/' .. 'save.jkr')
                if G.SAVED_GAME ~= nil then G.SAVED_GAME = STR_UNPACK(G.SAVED_GAME) end
            end

            G.SETTINGS.current_setup = 'New Run'
            G.GAME.viewed_back = Back(get_deck_from_name(G.PROFILES[G.SETTINGS.profile].MEMORY.deck))

            G.PROFILES[G.SETTINGS.profile].MEMORY.stake = G.PROFILES[G.SETTINGS.profile].MEMORY.stake or 1
            G.viewed_stake = G.PROFILES[G.SETTINGS.profile].MEMORY.stake or 1
            G.FUNCS.change_stake({to_key = G.viewed_stake})
            for k, v in ipairs(G.P_CENTER_POOLS.Back) do
              if v.name == G.GAME.viewed_back.name then BlackHole.viewed_deck_idx = k end
            end
            BlackHole.viewed_stake_idx = 1
            for k, v in ipairs(G.P_CENTER_POOLS.Stake) do
                if v.stake_level == G.viewed_stake then BlackHole.viewed_stake_idx = k; break end
            end
            tts.silence()
            tts.say(localize('tts_init_deck_select'))
            tts.say(BlackHole.read_back_info())
            tts.say(BlackHole.read_stake_info())
            BlackHole.capture_controller = 4
        elseif button == 'b' then
            if not G.SAVED_GAME then
                G.SAVED_GAME = get_compressed(G.SETTINGS.profile .. '/' .. 'save.jkr')
                if G.SAVED_GAME ~= nil then G.SAVED_GAME = STR_UNPACK(G.SAVED_GAME) end
            end

            G.SETTINGS.current_setup = 'Continue'
            G.GAME.viewed_back = Back(get_deck_from_name(G.PROFILES[G.SETTINGS.profile].MEMORY.deck))

            G.PROFILES[G.SETTINGS.profile].MEMORY.stake = G.PROFILES[G.SETTINGS.profile].MEMORY.stake or 1
            G.viewed_stake = 1
            if G.SAVED_GAME ~= nil then
                saved_game = G.SAVED_GAME
                local viewed_deck = 'b_red'
                for k, v in pairs(G.P_CENTERS) do
                    if v.name == saved_game.BACK.name then viewed_deck = k end
                end
                G.GAME.viewed_back:change_to(G.P_CENTERS[viewed_deck])
                G.viewed_stake = saved_game.GAME.stake or 1
            end
            tts.silence()
            tts.say(localize {
                type = 'variable',
                key = 'tts_confirm_continue',
                vars = {
                    localize { type = 'name_text', set = 'Back', key = G.GAME.viewed_back.effect.center.key },
                    tostring(saved_game.GAME.round),
                    tostring(saved_game.GAME.round_resets.ante),
                    localize('$') .. format_ui_value(saved_game.GAME.dollars),
                    number_format(saved_game.GAME.round_scores.hand.amt)
                }
            })
            BlackHole.capture_controller = 3
        end
    elseif n == 3 then
        if button == 'a' then
            tts.silence()
            tts.say(localize('tts_continuing_run'))
            BlackHole.capture_controller = nil
            if G.STATE == G.STATES.SPLASH then G:main_menu(true) end
            G.FUNCS.start_setup_run()
        end
    elseif n == 4 then
        if button == 'dpleft' then
            local new_idx = BlackHole.viewed_deck_idx - 1
            if new_idx == 0 then new_idx = #G.P_CENTER_POOLS.Back end
            BlackHole.viewed_deck_idx = new_idx
            G.GAME.viewed_back:change_to(G.P_CENTER_POOLS.Back[new_idx])
            local max_stake = get_deck_win_stake(G.GAME.viewed_back.effect.center.key) or 0
            G.viewed_stake = math.min(G.viewed_stake, max_stake + 1)
            G.PROFILES[G.SETTINGS.profile].MEMORY.deck = G.GAME.viewed_back.effect.center.name
            G.FUNCS.change_stake({to_key = G.viewed_stake})
            tts.silence()
            tts.say(BlackHole.read_back_info())
            tts.say(BlackHole.read_stake_info())
        elseif button == 'dpright' then
            local new_idx = BlackHole.viewed_deck_idx + 1
            if new_idx == #G.P_CENTER_POOLS.Back+1 then new_idx = 1 end
            BlackHole.viewed_deck_idx = new_idx
            G.GAME.viewed_back:change_to(G.P_CENTER_POOLS.Back[new_idx])
            local max_stake = get_deck_win_stake(G.GAME.viewed_back.effect.center.key) or 0
            G.viewed_stake = math.min(G.viewed_stake, max_stake + 1)
            G.PROFILES[G.SETTINGS.profile].MEMORY.deck = G.GAME.viewed_back.effect.center.name
            G.FUNCS.change_stake({to_key = G.viewed_stake})
            tts.silence()
            tts.say(BlackHole.read_back_info())
            tts.say(BlackHole.read_stake_info())
        elseif button == 'leftshoulder' then
            local max_stake = get_deck_win_stake(G.GAME.viewed_back.effect.center.key)
            if G.PROFILES[G.SETTINGS.profile].all_unlocked then max_stake = #G.P_CENTER_POOLS['Stake'] end
            local stake_options = {}
            for i = 1, math.min(max_stake+1, #G.P_CENTER_POOLS['Stake']) do
              stake_options[i] = i
            end
            local new_idx = BlackHole.viewed_stake_idx - 1
            if new_idx == 0 then new_idx = #stake_options end
            if new_idx ~= BlackHole.viewed_stake_idx then
                G.viewed_stake = new_idx
                BlackHole.viewed_stake_idx = new_idx
                G.FUNCS.change_stake({to_key = G.viewed_stake})
                tts.silence()
                tts.say(BlackHole.read_stake_info())
                tts.say(BlackHole.read_back_info())
            end
        elseif button == 'rightshoulder' then
            local max_stake = get_deck_win_stake(G.GAME.viewed_back.effect.center.key)
            if G.PROFILES[G.SETTINGS.profile].all_unlocked then max_stake = #G.P_CENTER_POOLS['Stake'] end
            local stake_options = {}
            for i = 1, math.min(max_stake+1, #G.P_CENTER_POOLS['Stake']) do
              stake_options[i] = i
            end
            local new_idx = BlackHole.viewed_stake_idx + 1
            if new_idx == #stake_options+1 then new_idx = 1 end
            if new_idx ~= BlackHole.viewed_stake_idx then
                G.viewed_stake = new_idx
                G.FUNCS.change_stake({to_key = G.viewed_stake})
                BlackHole.viewed_stake_idx = new_idx
                tts.silence()
                tts.say(BlackHole.read_stake_info())
                tts.say(BlackHole.read_back_info())
            end
        elseif button == 'a' then
            if not G.GAME.viewed_back.effect.center.unlocked then 
                tts.silence()
                tts.say(localize('tts_locked_deck'))
                return
            end
            tts.silence()
            tts.say(localize('tts_starting_run'))
            BlackHole.capture_controller = nil
            if G.STATE == G.STATES.SPLASH then G:main_menu(true) end
            G.FUNCS.start_setup_run()
        end
    end
end
