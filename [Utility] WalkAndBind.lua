if myHero.charName ~= "Morgana" then print("Please use this script with Morgana") return end
require "DivinePred"

--[[
DivinePrediction Test

This test will check ever 500 ms (1/2 a second) for a target to shoot, it chooses the target of the least health and skillshots it if it could

@Author NaderSl (Divine)
]]--


local processTime  = os.clock()*1000
local enemyChamps = {}
local dp = DivinePred() -- create an instance of the DivinePred class
local mySkillShot = LineSS(1200,1300,80,250,0)
local minHitDistance = 50


function OnLoad() -- Store enemy Champs
cfg = scriptConfig("Morgana Walk&Bind","wab")
cfg:addParam("bind", "bind Binding", SCRIPT_PARAM_ONKEYDOWN, false, string.byte('T'))

 for i = 1, heroManager.iCount do
    local hero = heroManager:GetHero(i)
		if hero.team ~= myHero.team then enemyChamps[""..hero.networkID] = DPTarget(hero) end
	end
	print("This script wiill demonstrate Divine Prediction [Beta] version by targeting enemy champs in range with the least health, you can either allow automatic mode which will try to hit the detected champ whever 'Q' is available or you can turn that off and bind a key to bind instead of automatic mode")
end


function OnTick()
	if cfg.bind and predict then bind() ; predict = false  end
	if not cfg.bind then predict = true end
end

function bind()
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
	   --- if DivinePred.debugMode  then print("Prediction Calculation Cost: "..math.floor((os.clock() *1000- processTime)).." ms") end
		if state == SkillShot.STATUS.SUCCESS_HIT then -- if it was of a SUCCESS_HIT state, then cast spell on the predicted target.
			CastSpell(_Q,hitPos.x,hitPos.z)
		end
	end
end