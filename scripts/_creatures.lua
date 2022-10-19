local Self = require('openmw.self')
local Actor = require('openmw.types').Actor
local AI = require('openmw.interfaces').AI
local Nearby = require('openmw.nearby')
local Creature = require('openmw.types').Creature

local scriptVersion = 1
local adjusted = false

local relayAttackMaxDistance = 5000
local wanderMaxDistance = 10000
local attackCreatureMaxDistance = 3000

local allowedFor = {
    ["alit"] = true,
    ["alit_diseased"] = true,
    ["alit_blighted"] = true,
    ["mudcrab"] = true,
    ["mudcrab-diseased"] = true,
    ["mr_rockcrab"] = true,
    ["dreugh"] = true,
    ["guar_feral"] = true,
    ["kagouti"] = true,
    ["kagouti_diseased"] = true,
    ["kagouti_blighted"] = true,
    ["scrib"] = true,
    ["mr_swamp_scrib"] = true,
    ["scrib diseased"] = true,
    ["scrib blighted"] = true,
    ["kwama forager"] = true,
    ["cliff racer"] = true,
    ["cliff racer_diseased"] = true,
    ["cliff racer_blighted"] = true,
    ["nix-hound"] = true,
    ["nix_hound"] = true,
    ["mr_diseased_nix_hound"] = true,
    ["rat"] = true,
    ["rat_diseased"] = true,
    ["rat_blighted"] = true,
    ["slaughterfish_small"] = true,
    ["slaughterfish"] = true,
    ["mr_bull_netch_swamp"] = true,
    ["mr_betty_netch_swamp"] = true,
    ["netch_bull"] = true,
    ["netch_betty"] = true,
    ["shalk"] = true,
    ["mr_shalk_greenback"] = true
}

local packCreatures = {
    ["alit"] = true,
    ["cliff"] = true,
    --["fish"] = true,
    ["guar"] = true,
    ["kagouti"] = true,
    ["hound"] = true,
    ["rat"] = true,
}

local foodChainTable = {
    ["alit"] = {
        ["scrib"] = true,
        ["mr_swamp_scrib"] = true,
        ["scrib diseased"] = true,
        ["kwama forager"] = true,
        ["rat"] = true,
        ["rat_diseased"] = true,
        ["rat_blighted"] = true,
        ["guar_feral"] = true,
        ["nix-hound"] = true,
        ["mr_diseased_nix_hound"] = true
    },
    ["alit_diseased"] = {
        ["scrib"] = true,
        ["mr_swamp_scrib"] = true,
        ["scrib diseased"] = true,
        ["kwama forager"] = true,
        ["rat"] = true,
        ["rat_diseased"] = true,
        ["rat_blighted"] = true,
        ["guar_feral"] = true,
        ["nix-hound"] = true,
        ["mr_diseased_nix_hound"] = true
    },
    ["alit_blighted"] = {
        ["scrib"] = true,
        ["mr_swamp_scrib"] = true,
        ["scrib diseased"] = true,
        ["kwama forager"] = true,
        ["rat"] = true,
        ["rat_diseased"] = true,
        ["rat_blighted"] = true,
        ["guar_feral"] = true,
        ["nix-hound"] = true,
        ["mr_diseased_nix_hound"] = true
    },
    ["cliff racer"] = {
        ["scrib"] = true,
        ["mr_swamp_scrib"] = true,
        ["scrib diseased"] = true,
        ["kwama forager"] = true,
        ["rat"] = true,
        ["rat_diseased"] = true,
        ["rat_blighted"] = true,
        ["guar_feral"] = true,
        ["nix-hound"] = true,
        ["mr_diseased_nix_hound"] = true,
        ["mr_bull_netch_swamp"] = true,
        ["mr_betty_netch_swamp"] = true,
        ["netch_bull"] = true,
        ["netch_betty"] = true
    },
    ["cliff racer_diseased"] = {
        ["scrib"] = true,
        ["mr_swamp_scrib"] = true,
        ["scrib diseased"] = true,
        ["kwama forager"] = true,
        ["rat"] = true,
        ["rat_diseased"] = true,
        ["rat_blighted"] = true,
        ["guar_feral"] = true,
        ["nix-hound"] = true,
        ["mr_diseased_nix_hound"] = true,
        ["mr_bull_netch_swamp"] = true,
        ["mr_betty_netch_swamp"] = true,
        ["netch_bull"] = true,
        ["netch_betty"] = true
    },
    ["cliff racer_blighted"] = {
        ["scrib"] = true,
        ["mr_swamp_scrib"] = true,
        ["scrib diseased"] = true,
        ["kwama forager"] = true,
        ["rat"] = true,
        ["rat_diseased"] = true,
        ["rat_blighted"] = true,
        ["guar_feral"] = true,
        ["nix-hound"] = true,
        ["mr_diseased_nix_hound"] = true,
        ["mr_bull_netch_swamp"] = true,
        ["mr_betty_netch_swamp"] = true,
        ["netch_bull"] = true,
        ["netch_betty"] = true
    },
    ["kagouti"] = {
        ["scrib"] = true,
        ["mr_swamp_scrib"] = true,
        ["scrib diseased"] = true,
        ["kwama forager"] = true,
        ["rat"] = true,
        ["rat_diseased"] = true,
        ["rat_blighted"] = true,
        ["guar_feral"] = true,
        ["nix-hound"] = true,
        ["mr_diseased_nix_hound"] = true,
        ["alit"] = true,
        ["alit_diseased"] = true,
        ["alit_blighted"] = true
    },
    ["kagouti_diseased"] = {
        ["scrib"] = true,
        ["mr_swamp_scrib"] = true,
        ["scrib diseased"] = true,
        ["kwama forager"] = true,
        ["rat"] = true,
        ["rat_diseased"] = true,
        ["rat_blighted"] = true,
        ["guar_feral"] = true,
        ["nix-hound"] = true,
        ["mr_diseased_nix_hound"] = true,
        ["alit"] = true,
        ["alit_diseased"] = true,
        ["alit_blighted"] = true   
    },
    ["kagouti_blighted"] = {
        ["scrib"] = true,
        ["mr_swamp_scrib"] = true,
        ["scrib diseased"] = true,
        ["kwama forager"] = true,
        ["rat"] = true,
        ["rat_diseased"] = true,
        ["rat_blighted"] = true,
        ["guar_feral"] = true,
        ["nix-hound"] = true,
        ["mr_diseased_nix_hound"] = true,
        ["alit"] = true,
        ["alit_diseased"] = true,
        ["alit_blighted"] = true
    },
    ["nix-hound"] = {
        ["scrib"] = true,
        ["mr_swamp_scrib"] = true,
        ["scrib diseased"] = true,
        ["kwama forager"] = true,
        ["rat"] = true,
        ["rat_diseased"] = true,
        ["rat_blighted"] = true      
    },
    ["mr_diseased_nix_hound"] = {
        ["scrib"] = true,
        ["mr_swamp_scrib"] = true,
        ["scrib diseased"] = true,
        ["kwama forager"] = true,
        ["rat"] = true,
        ["rat_diseased"] = true,
        ["rat_blighted"] = true      
    },
    ["rat"] = {
        ["scrib"] = true,
        ["mr_swamp_scrib"] = true,
        ["scrib diseased"] = true,
        ["kwama forager"] = true,
        ["mudcrab"] = true,
        ["mudcrab-diseased"] = true,
        ["mr_rockcrab"] = true,
    },
    ["rat_diseased"] = {
        ["scrib"] = true,
        ["mr_swamp_scrib"] = true,
        ["scrib diseased"] = true,
        ["kwama forager"] = true,
        ["mudcrab"] = true,
        ["mudcrab-diseased"] = true,
        ["mr_rockcrab"] = true,
    },
    ["rat_blighted"] = {
        ["scrib"] = true,
        ["mr_swamp_scrib"] = true,
        ["scrib diseased"] = true,
        ["kwama forager"] = true,
        ["mudcrab"] = true,
        ["mudcrab-diseased"] = true,
        ["mr_rockcrab"] = true,
    },
}

local function isAllowedFor(creature)
    return allowedFor[creature.recordId]
end

local function isPackCreture(creature)
    for id, _ in pairs(packCreatures) do
        if (string.find(creature.recordId, id)) then
            return true
        end
    end

    return false
end

local function isPrey(predator, prey)
    local foodChain = foodChainTable[predator.recordId]
    if (foodChain and foodChain[prey.recordId]) then
        return true
    end

    return false
end

local function isSameSpecies(creatureFirst, creatureSecond)
    for id, _ in pairs(packCreatures) do
        if (string.find(creatureFirst.recordId, id) and string.find(creatureSecond.recordId, id)) then
            return true
        end
    end

    return false
end

local skip = 0

local function onUpdate()
    if (not adjusted) then
        local package = AI.getActivePackage()
        if (package) then
            AI.removePackages(package.type)
        end

        AI.startPackage({type = 'Wander', distance = wanderMaxDistance })
        adjusted = true
    end

    skip = skip + 1
    if (skip < 100) then return end
    skip = 0

    local currentTarget = AI.getActiveTarget('Combat')
    if (currentTarget and isPackCreture(Self)) then
        if (not Actor.canMove(currentTarget)) then
            print("STOP ATTACKING PREY: "..Self.recordId.." - "..currentTarget.recordId)
            AI.removePackages('Combat')
            AI.startPackage({type = 'Wander', distance = wanderMaxDistance })
            return
        end
        Self:sendEvent("OnCombat", { source = Self.object, target = currentTarget })
        return 
    end
    
    for _, actor in ipairs(Nearby.actors) do
        if (actor.type == Creature and Actor.canMove(actor)) then
            local distance = (Self.position - actor.position):length()
            --if (Self.recordId == "rat_diseased" and actor.recordId == "scrib diseased") then print(actor.recordId.." DIST: "..distance) end
            if (distance < attackCreatureMaxDistance and isPrey(Self, actor)) then
                print("ATTACL PREY: "..Self.recordId.." - "..actor.recordId)
                AI.startPackage({type = 'Combat', target = actor})
                return 
            end
        end
    end

end

local function onCombatEventHandler(e)
    --print("onCombatEventHandler: "..tostring(e.source.recordId))

    for _, actor in ipairs(Nearby.actors) do
        if (e.source ~= actor and e.source.type == Creature and Actor.canMove(e.source)) then
            if (isSameSpecies(e.source, actor)) then
                local distance = (e.source.position - actor.position):length()
                if (distance <= relayAttackMaxDistance) then
                    -- print(actor.recordId.." DIST: "..distance)

                    actor:sendEvent("AddTarget", { 
                        source = Self.object,
                        target =  e.target,
                    })

                end
            end
        end
    end
end

local function addTargetEventHandler(e)
    --print("addTargetEventHandler: "..tostring(e.source.recordId))

    local currentTarget = AI.getActiveTarget('Combat')
    if (currentTarget) then
        return -- Do not set new target
    end

    print("START COMBAT: "..Self.recordId.." TARGET: "..e.target.recordId)
    AI.startPackage({type = 'Combat', target = e.target})
end

local function onSave()
    print("***onSave()***")
    return {
        version = scriptVersion,
        adjusted = adjusted
    }
end

local function onLoad(data)
    print("***onLoad()***")
    if (not data or not data.version or data.version < scriptVersion) then
        print('Was saved with an old version of the script, initializing to default')
        adjusted = false
        return
    end

    if (data.version > scriptVersion) then
        error('Required update to a new version of the script')
    end

    adjusted = data.adjusted
end

return {
    engineHandlers = {
        onUpdate = function()
            if (Actor.canMove(Self) and isAllowedFor(Self)) then
                onUpdate()
            end
        end,
        onSave = onSave,
        onLoad = onLoad
    },
    eventHandlers = { 
        OnCombat = onCombatEventHandler,
        AddTarget = addTargetEventHandler
    }
}

