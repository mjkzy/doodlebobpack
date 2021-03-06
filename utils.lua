-- iw6x/s1x/h1 compatibility utils
function gamename()
    if (gamename_) then
        return gamename_
    end

    gamename_ = nil
    local version = game:getdvar("version")

    if (version:match("IW6x")) then
        gamename_ = "iw6x"
    elseif (version:match("S1x")) then
        gamename_ = "s1x"
    elseif (version:match("H1 MP 1.15")) then
        gamename_ = "h1"
    end

    return gamename_
end

function select(iw6x, s1x, h1)
    if (gamename() == "iw6x") then
        return iw6x
    elseif (gamename() == "s1x") then
        return s1x
    elseif (gamename() == "h1") then
        return h1
    end
end

function select_func(iw6x, s1x, h1)
    if (gamename() == "iw6x") then
        if iw6x then
            return iw6x()
        end
    elseif (gamename() == "s1x") then
        if s1x then
            return s1x()
        end
    elseif (gamename() == "h1") then
        if h1 then
            return h1()
        end
    end
end

-- custom functions to make code look nicer in __init__
function entity:_iprintln(string)
    select_func(function()
        self:iprintln(string)
    end, function()
        self:iclientprintln(string)
    end, function()
        self:clientiprintln(string)
    end)
end

function entity:_iprintlnbold(string)
    select_func(function()
        self:iprintlnbold(string)
    end, function()
        self:iclientprintlnbold(string)
    end, function()
        self:clientiprintlnbold(string)
    end)
end

local function starts_with(str, start)
    return str:sub(1, #start) == start
end

function entity:_isbot()
    if (starts_with(self:getguid(), "bot")) then
        return true
    end
    return false
end

function _isplayer(entity)
    -- a non-valid entity in the context of damage callbacks are empty tables
    if type(entity) == "table" then return false end

    -- use actual game function to double check
    if not game:isplayer(entity) then return false end

    return true
end

function is_unsetup()
    return tonumber(game:getdvar("unsetup")) == 1
end

-- iw6x give killstreak func
function entity:givekillstreak(killstreak, val)
    if (gamename() ~= "iw6x") then
        return
    end

    self:scriptcall("maps/mp/killstreaks/_killstreaks", "_ID15602", killstreak, false, true, self)
    self:scriptcall("maps/mp/gametypes/_hud_message", "_ID19270", killstreak, val)
end
