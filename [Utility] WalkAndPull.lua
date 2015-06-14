if myHero.charName ~= "Blitzcrank" then print("Please use this script with Blitzcrank") return end
require "DivinePred"

--[[
DivinePrediction Test (Blitzcrank: Walk & pull) for the  DivinePred lib.

This test will check ever 500 ms (1/2 a second) for a target to shoot, it chooses the target of the least health and skillshots it if it could

@Author NaderSl (Divine)
]]--


DivinePred.debugMode = false --basically for me to debug some stuff as i develop it.
local processTime  = os.clock()*1000
local enemyChamps = {}
local dp = DivinePred() -- create an instance of the DivinePred class
local mySkillShot = SkillShot.PRESETS['RocketGrab'] -- 
local predictionCD = 400 -- prediction cooldown, attempts every every x ms 
local minHitDistance = 75
local lastTimeStamp = nil
local predict = true

function OnLoad() -- Store enemy Champs
cfg = scriptConfig("Blitzcrank Walk&Pull","wap")
cfg:addParam("autopull","Pull enemy champs on Q ready",SCRIPT_PARAM_ONOFF,true)
cfg:addParam("pull", "pull Binding", SCRIPT_PARAM_ONKEYDOWN, false, string.byte('T'))

 for i = 1, heroManager.iCount do
    local hero = heroManager:GetHero(i)
		if hero.team ~= myHero.team then enemyChamps[""..hero.networkID] = DPTarget(hero) end
	end
	print("This script wiill demonstrate Divine Prediction [Beta] version by targeting enemy champs in range with the least health, you can either allow automatic mode which will try to hit the detected champ whever 'Q' is available or you can turn that off and bind a key to pull instead of automatic mode")
end


function OnTick()
	if cfg.pull and predict then pull() ; predict = false  end
	if not cfg.pull then predict = true end
	if  not cfg.autopull or (lastTimeStamp and  os.clock()*1000 - lastTimeStamp < predictionCD) or   myHero:CanUseSpell(_Q) ~= READY then return end 
	pull()
	lastTimeStamp = os.clock()*1000
end

function pull()
	local target = nil
	-- Sort by health the visible and living enemy champs, which are  within my skillshot range.
	for k,v in pairs(enemyChamps) do
		if v.unit.visible and (not v.unit.dead) then 
			local dist = GetDistance(myHero,v.unit) 
			if dist <= mySkillShot.range  and dist >=  minHitDistance then
			if not target then target = v elseif v.unit.health  < target.unit.health  then target = v end
		end
	end
end
	if target then
		processTime  = os.clock()*1000
		local state,hitPos,perc = dp:predict(target,mySkillShot) 
	   -- if DivinePred.debugMode  then print("Prediction Calculation Cost: "..math.floor((os.clock() *1000- processTime)).." ms") end
		if state == SkillShot.STATUS.SUCCESS_HIT then -- if it was of a SUCCESS_HIT state, then cast spell on the predicted target.
			CastSpell(_Q,hitPos.x,hitPos.z)
		end
	end
end