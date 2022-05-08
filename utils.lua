-- iw6x/s1x compatibility utils
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
    elseif (version:match("H1")) then -- only supports the old version using h1-mod
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

function entity:_setclientomnvar(var, val)
    select_func(function()
        self:setclientomnvar(var, val)
    end, function()
        self:setclientomnvar(var, val)
    end, function()
        -- not named properly on h1-mod but this is "setclientomnvar" (_meth_82F8)
        self:stoplocalsound(var, val)
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

-- iw6x give killstreak func
function entity:givekillstreak(killstreak, val)
    if (gamename() ~= "iw6x") then
        return
    end

    self:scriptcall("maps/mp/killstreaks/_killstreaks", "_ID15602", killstreak, false, true, self)
    self:scriptcall("maps/mp/gametypes/_hud_message", "_ID19270", killstreak, val)
end
