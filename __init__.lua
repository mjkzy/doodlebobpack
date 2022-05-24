include("utils")
if (not gamename()) then
    print("Unsupported game for doodlebob pack")
    return
end

include("config")

players = {}

-- dvars
game:setdvar("pm_bouncing", 1)
game:setdvar("scr_player_healthregentime", 5)
game:setdvar("g_playercollision", 0)
game:setdvar("g_playerejection", 0)
game:setdvar("perk_bulletpenetrationmultiplier", 40)
game:setdvar("jump_enablefalldamage", 1)

-- snd/sr
game:setdvar("scr_sd_roundswitch", 0)
game:setdvar("scr_sd_timelimit", select(2.5, 1.5, 2.5))
game:setdvar("scr_sd_planttime", 1)
-- sr is found on h1, but idrk if its on the game lmfao
game:setdvar("scr_sr_roundswitch", 0)
game:setdvar("scr_sr_timelimit", select(2.5, 1.5, 2.5))
game:setdvar("scr_sr_planttime", 1)

-- dvars (uninitialized)
game:setdvarifuninitialized("botx", "no")
game:setdvarifuninitialized("boty", "no")
game:setdvarifuninitialized("botz", "no")
game:setdvarifuninitialized("savemap", "no")
game:setdvarifuninitialized("unsetup", 1)

damap = game:getdvar("mapname")

function entity:player_spawned()
    if game:getdvar("g_gametype") ~= select("sr", "sd", "sd") then
        self:_iprintlnbold("Please switch game mode to ^:" ..
                               select("Search & Rescue", "Search & Destroy", "Search & Destroy"))
        return
    end

    if game:getteamscore("axis") == 0 and game:getteamscore("allies") == 0 then
        if (gamename() ~= "h1") then
            self:_iprintln("welcome to doodlebob pack")
            self:_iprintln("rewritten and maintained by ^:@mjkzys")
            self:_iprintln("use [{+stance}] and [{+melee_zoom}] to Refill Ammo")
            self:_iprintln("use [{+stance}] and [{+actionslot 1}] to Get Streaks")
            self:_iprintln("use [{+stance}] and [{+actionslot 3}] to Save Bot Position")
        else
            game:ontimeout(function()
                self:_iprintln("rewritten and maintained by ^:@mjkzys")
                game:ontimeout(function()
                    self:_iprintln("use [{+stance}] and [{+melee_zoom}] to Refill Ammo")
                    game:ontimeout(function()
                        self:_iprintln("use [{+stance}] and [{+actionslot 1}] to Get Streaks")
                        game:ontimeout(function()
                            self:_iprintln("use [{+stance}] and [{+actionslot 3}] to Save Bot Position")
                        end, 1000)
                    end, 1000)
                end, 1000)
            end, 1000)
            self:_iprintln("welcome to doodlebob pack")
        end
    end

    -- set match bonus
    self:setclientomnvar("ui_round_end_match_bonus", math.random(300, 1800))

    if self:ishost() then
        if not is_unsetup() then
            self:freezecontrols(false)
        end

        self:setrank(select(59, 49, 55), select(host.iw6x_prestige, host.s1x_prestige, host.h1_prestige))

        if game:getteamscore("axis") == 0 and game:getteamscore("allies") == 0 then
            self:_iprintlnbold("your status is ^:host")
        elseif gamename() == "iw6x" and game:getteamscore("axis") == 3 and game:getteamscore("allies") == 3 then
            self.pers["kills"] = 25
            self.kills = 25
            self.pers["score"] = 2350
            self.score = 2200
            self:givekillstreak("nuke", 25)
            game:executecommand("g_enableElevators 1")
        end

        -- binds below
        self:notifyonplayercommand("savebind", "+actionslot 3")
        self:onnotify("savebind", function()
            if self:getstance() == "crouch" then
                -- set position at crosshair
                local forward = self:gettagorigin("j_head")
                local endvec = game:anglestoforward(self:getplayerangles())
                local endd = endvec:scale(1000000)
                local cross = game:bullettrace(forward, endd, 0, self)["position"]
                game:setdvar("botx", cross.x)
                game:setdvar("boty", cross.y)
                game:setdvar("botz", cross.z)
                game:setdvar("savemap", game:getdvar("mapname"))
                self:_iprintln("next bot spawn ^:saved^7, teleporting bot(s)..")

                -- teleport all current bots to crosshair
                if not is_unsetup() then
                    for index, p in ipairs(players) do
                        if p:_isbot() then
                            p:setorigin(cross)
                        end
                    end
                end
            elseif self:getstance() == "prone" then
                if (game:getdvar("botx") ~= "no") then
                    game:setdvar("botx", "no")
                    game:setdvar("boty", "no")
                    game:setdvar("botz", "no")
                    self:_iprintln("next bot spawn ^:cleared^7")
                end
            end
        end)

        self:notifyonplayercommand("refillbind", "+melee_zoom")
        self:onnotify("refillbind", function()
            if self:getstance() == "crouch" then
                self:givemaxammo(self:getcurrentweapon())
                self:givestartammo(self:getcurrentoffhand())
                self:givemaxammo(self:getoffhandsecondaryclass())
            end
        end)

        self:notifyonplayercommand("streakbind", "+actionslot 1")
        self:onnotify("streakbind", function()
            -- different usage for iw6/s1
            select_func(function()
                self:givekillstreak("deployable_ammo", 6)
            end, function()
                -- questionable streak giving, its from bronx 2.0 so i'll leave here as im lazy - mikey
                if self:getstance() == "prone" and self:adsbuttonpressed() == 1 then
                    if game:getteamscore("axis") == 5 and game:getteamscore("allies") == 5 then
                        levelstruct[21400].nuke(self)
                    else
                        self:iclientprintlnbold("You can only use a ^:DNA Bomb ^7on the last round")
                    end
                elseif self:getstance() == "crouch" then
                    self:giveweapon("iw5_dlcgun1loot0_mp_heatsink_opticsacog2ar_parabolicmicrophone_camo21")
                    self:dropitem("iw5_dlcgun1loot0_mp_heatsink_opticsacog2ar_parabolicmicrophone_camo21")
                else
                    self:giveweapon("turretheadenergy_mp")
                    self:switchtoweapon("turretheadenergy_mp")
                end
            end, function()
                self:_iprintlnbold("not supported yet")
            end)
        end)
    else
        -- sort through guest table and check if we're a guest
        for i = 1, #guests do
            local guest = guests[i]

            if (self.name == guest.name) then
                self:setrank(select(59, 49, 55), select(guest.iw6x_prestige, guest.s1x_prestige, guest.h1_prestige))

                if game:getteamscore("axis") == 0 and game:getteamscore("allies") == 0 then
                    self:_iprintlnbold("your status is ^:verified")
                end

                return
            end
        end
    end

    -- code to run if the player is a bot
    if self:_isbot() then
        -- freeze bot if unsetup
        if not is_unsetup() then
            game:oninterval(function()
                self:freezecontrols(true)
            end, 5)
        end

        -- some calling card thing
        select_func(function()
            self.playercardpatch = 121
        end, nil, nil)

        -- max rank but no prestige
        self:setrank(select(59, 49, 55), host.bot_prestige)

        -- teleport bot to saved spawn if existing
        if (not is_unsetup() and game:getdvar("savemap") == game:getdvar("mapname") and game:getdvar("botz") ~= "no") then
            local position = vector:new(tonumber(game:getdvar("botx")), tonumber(game:getdvar("boty")),
                tonumber(game:getdvar("botz")))
            self:setorigin(position)
        end
    end
end

function vector:scale(scale)
    self.x = self.x * scale
    self.y = self.y * scale
    self.z = self.z * scale
    return self
end

-- connected/player spawned listener
level:onnotify("connected", function(player)
    table.insert(players, player)

    -- spawn listener & disconnect listener
    player:onnotifyonce("spawned_player", function()
        player:player_spawned()
    end)
    player:onnotifyonce("disconnect", function()
        for i, p in ipairs(players) do
            if p == player then
                table.remove(players, i)
                break
            end
        end
    end)
end)

-- damage override
game:onplayerdamage(function(_self, inflictor, attacker, damage, dflags, mod, weapon, point, dir, hitloc)
    if game:weaponclass(weapon) == "sniper" then
        damage = 999
        game:executecommand("jump_enablefalldamage 0")
    elseif weapon == "throwingknife_mp" then
        damage = 999
    elseif mod == "MOD_UNKNOWN" and weapon == "none" then
        damage = 0
    elseif mod == "MOD_FALLING" then
        damage = 0
    end

    if _isplayer(attacker) then
        if attacker:_isbot() then
            damage = 1
        end
    end

    return damage
end)
