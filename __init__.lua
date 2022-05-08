--[[

dear programmer:
when I rewrote this code, only god and I knew how it worked. now, only god knows it!

therefore, if you are trying to optimize this mod and 
it fails (most likely will break in some place), please increase the variable below to
warn any future people that are interested in touching this mod.

]]--

total_hours_wasted_touching_this_mod = 3

include("utils")
if (not gamename()) then
    print("Unsupported game for doodlebobpack")
    return
end

print("This mod has been rewrote to complete shininess for " .. total_hours_wasted_touching_this_mod .. " hours.")

include("config")

-- dvars
game:setdvar("pm_bouncing", 1)
game:setdvar("scr_player_healthregentime", 5)
game:setdvar("g_playercollision", 0)
game:setdvar("g_playerejection", 0)
game:setdvar("perk_bulletpenetrationmultiplier", 40)
game:setdvar("jump_enablefalldamage", 1)
-- snd/sr
game:setdvar("scr_sd_roundswitch", 0)
game:setdvar("scr_sd_timelimit", select(2.5, 1.5))
game:setdvar("scr_sd_planttime", 1)
game:setdvar("scr_sr_roundswitch", 0)
game:setdvar("scr_sr_timelimit", select(2.5, 1.5))
game:setdvar("scr_sr_planttime", 1)

-- dvars (uninitialized)
game:setdvarifuninitialized("botx", "no")
game:setdvarifuninitialized("boty", "no")
game:setdvarifuninitialized("botz", "no")
game:setdvarifuninitialized("savemap", "no")
game:setdvarifuninitialized("unsetup", "1")

damap = game:getdvar("mapname")

function entity:player_spawned()
    if game:getdvar("g_gametype") ~= select("sr", "sd") then
        self:_iprintlnbold("Please switch game mode to ^:" .. select("Search & Rescue", "Search & Destroy"))
        return
    end

    self:_iprintln("welcome to doodlebob pack")
    self:_iprintln("rewritten and maintained by ^:@mjkzys")
    self:_iprintln("use [{+stance}] and [{+melee_zoom}] to Refill Ammo")
    self:_iprintln("use [{+stance}] and [{+actionslot 1}] to Get Streaks")

    self:setclientomnvar("ui_round_end_match_bonus", math.random(300, 1800))

    if self:ishost() then
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
                local forward = player:gettagorigin("j_head")
                local endvec = game:anglestoforward(self:getplayerangles())
                local endd = endvec:scale(1000000)
                local cross = game:bullettrace(forward, endd, 0, self)["position"]
                game:executecommand("botx " .. cross.x)
                game:executecommand("boty " .. cross.y)
                game:executecommand("botz " .. cross.z)
                game:executecommand("savemap " .. damap)
                game:setdvar("savemap", game:getdvar("mapname"))
                self:_iprintln("bot spawn ^:saved^7, will apply next round")
            elseif self:getstance() == "prone" then
                if (game:getdvar("wtfx") ~= "no") then
                    game:setdvar("wtfx", "no")
                    game:setdvar("wtfy", "no")
                    game:setdvar("wtfz", "no")
                    self:_iprintln("bot spawn ^:cleared^7, will apply next round")
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
            end)
        end)

        self:freezecontrols(false)
        self:setrank(select(59, 49), hostprestige)
    else
        -- sort through guest table and check if we're a guest
        for i = 1, #guests do
            local guest = guests[i]

            if (self.name == guest.name) then
                self:setrank(select(59, 49), select(guest.iw6x_prestige, guest.s1x_prestige))

                if game:getteamscore("axis") == 0 and game:getteamscore("allies") == 0 then
                    self:_iprintlnbold("your status is ^:verified")
                end

                return
            end
        end
    end

    if game:isbot(self) then
        game:oninterval(function()
            self:freezecontrols(true)
        end, 5)

        select_func(function()
            self.playercardpatch = 121
        end, nil)
        self:setrank(select(59, 49), 0)
        if (game:getdvar("savemap") == game:getdvar("mapname") and game:getdvar("botz") ~= "no") then
            local manx = tonumber(game:getdvar("botx"))
            local many = tonumber(game:getdvar("boty"))
            local manz = tonumber(game:getdvar("botz"))
            local savep = vector:new(manx, many, manz)
            self:setorigin(savep)
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
    player:onnotifyonce("spawned_player", function()
        player:player_spawned()
    end)
end)

level:onnotify("player_spawned", setup)

-- damage override
game:onplayerdamage(function(_self, inflictor, attacker, damage, dflags, mod, weapon, point, dir, hitloc)
    if game:weaponclass(weapon) == "sniper" then
        damage = 999
        game:executecommand("jump_enablefalldamage 0")
    elseif weapon == "throwingknife_mp" then
        damage = 999
    elseif mod == "MOD_UNKNOWN" and weapon == "none" then
        damage = 0
    elseif mod == "MOD_FALLING" and weapon == "none" then
        damage = 0
    end
    if attacker.team == "axis" then
        damage = 1
    end
    return damage
end)
