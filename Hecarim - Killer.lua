if myHero.charName ~= "Hecarim" then return end

local Version = "1.00"

local Author = "LeoFRM"

require 'VPrediction'
require 'SOW'

---------------------------------------------------------------------
--- Vars ------------------------------------------------------------
---------------------------------------------------------------------
-- Vars for Ranges --
	local lastSkin = 0
	local qRange = 350
	local wRange = 525
	local eRange = myHero.range + GetDistance(myHero.minBBox)
	local rRange = 1000
	local rWidth = 300
	local rSpeed = 1200
	local rDelay = 0.250
-- Vars for Abilitys --
	local qName = "Rampage"
	local wName = "Spirit of Dread"
	local eName = "Devastating Charge"
	local rName = "Onslaught of Shadows"
	local qColor = ARGB(100,217,0,163)
	local wColor = ARGB(100,76,255,76)
	local eColor = ARGB(100,153,229,255)
	local rColor = ARGB(100,207,255,191)
	local TargetColor = ARGB(100,76,255,76)
	-- Vars for JungleClear --
	local JungleMobs = {}
	local JungleFocusMobs = {}
	-- Vars for LaneClear --
	local enemyMinions = minionManager(MINION_ENEMY, 500, myHero.visionPos, MINION_SORT_HEALTH_ASC)
-- Vars for TargetSelector --
	local ts
	ts = TargetSelector(TARGET_LESS_CAST_PRIORITY, 1000, DAMAGE_PHYSICAL, true)
	ts.name = "Hecarim: Target"
	local Target = nil
-- Vars for Autolevel --

	local levelSequence = {1,3,1,2,1,4,1,2,1,2,4,2,3,2,3,4,3,3}

-- Vars for Damage Calculations and KilltextDrawing --
	local iDmg = 0
	local qDmg = 0
	local wDmg = 0
	local eDmg = 0
	local dfgDmg = 0
	local hxgDmg = 0
	local bwcDmg = 0
	local botrkDmg = 0
	local sheenDmg = 0
	local lichbaneDmg = 0
	local trinityDmg = 0
	local liandrysDmg = 0
	local KillText = {}
	local KillTextColor = ARGB(250, 255, 38, 1)
	local KillTextList = {		
							"Harass your enemy!", 					-- 01
							"Wait for your CD's!",					-- 02
							"Kill! - Ignite",						-- 03
							"Kill! - (Q)",							-- 04 
							"Kill! - (W)",							-- 05
							"Kill! - (E)",							-- 06
							"Kill! - (Q)+(W)",						-- 07
							"Kill! - (Q)+(E)",						-- 08
							"Kill! - (W)+(E)",						-- 09
							"Kill! - (Q)+(W)+(E)"					-- 10
						}
-- Misc Vars --	
	local enemyHeroes = GetEnemyHeroes()
	local VP = nil
---------------------------------------------------------------------
--- Menu ------------------------------------------------------------
---------------------------------------------------------------------
function OnLoad()
	IgniteCheck()
	JungleNames()
	VP = VPrediction()
	rSOW = SOW(VP)
	AddMenu()
	-- LFC --
	_G.oldDrawCircle = rawget(_G, 'DrawCircle')
	_G.DrawCircle = DrawCircle2
	PrintChat("<font color=\"#FFDFBF\"> Sucessfully loaded! Version: [<u><b>"..Version.."</b></u>]</font>")
end

function AddMenu()
	-- Script Menu --
	HecarimMenu = scriptConfig("Killer Hecarim", "Killer Hecarim")
	
	-- Target Selector --
	HecarimMenu:addTS(ts)
	
	-- Create SubMenu --
	HecarimMenu:addSubMenu(""..myHero.charName..": Key Bindings", "KeyBind")
	HecarimMenu:addSubMenu(""..myHero.charName..": Extra", "Extra")
	HecarimMenu:addSubMenu(""..myHero.charName..": Orbwalk", "Orbwalk")
	HecarimMenu:addSubMenu(""..myHero.charName..": SBTW-Combo", "SBTW")
	HecarimMenu:addSubMenu(""..myHero.charName..": Harass", "Harass")
	HecarimMenu:addSubMenu(""..myHero.charName..": KillSteal", "KS")
	HecarimMenu:addSubMenu(""..myHero.charName..": LaneClear", "Farm")
	HecarimMenu:addSubMenu(""..myHero.charName..": JungleClear", "Jungle")
	HecarimMenu:addSubMenu(""..myHero.charName..": Drawings", "Draw")
	
	-- KeyBindings --
	HecarimMenu.KeyBind:addParam("SBTWKey", "SBTW-Combo Key: ", SCRIPT_PARAM_ONKEYDOWN, false, 32)
	HecarimMenu.KeyBind:addParam("HarassKey", "HarassKey: ", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("C"))
	HecarimMenu.KeyBind:addParam("HarassToggleKey", "Toggle Harass: ", SCRIPT_PARAM_ONKEYTOGGLE, false, string.byte("U"))
	HecarimMenu.KeyBind:addParam("ClearKey", "Jungle- and LaneClear Key: ", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("V"))
	
	-- Extra --
	HecarimMenu.Extra:addParam("autoLevel", "Auto level spells", SCRIPT_PARAM_ONOFF, false)
	HecarimMenu.Extra:addParam("skin", "Use custom skin", SCRIPT_PARAM_ONOFF, false)
	HecarimMenu.Extra:addParam("skin1", "Skin changer", SCRIPT_PARAM_SLICE, 1, 1, 5)
	HecarimMenu.Extra:addParam("UseR", "AutoAim your ultimate", SCRIPT_PARAM_ONKEYDOWN, false, string.byte('R'))
	
	-- SOW-Orbwalking --
	rSOW:LoadToMenu(HecarimMenu.Orbwalk)
	
	-- SBTW-Combo --
	HecarimMenu.SBTW:addParam("sbtwItems", "Use Items in Combo: ", SCRIPT_PARAM_ONOFF, true)
	HecarimMenu.SBTW:addParam("sbtwInfo", "", SCRIPT_PARAM_INFO, "")
	HecarimMenu.SBTW:addParam("sbtwInfo", "--- Choose your abilitys for SBTW ---", SCRIPT_PARAM_INFO, "")
	HecarimMenu.SBTW:addParam("sbtwQ", "Use "..qName.." (Q) in Combo: ", SCRIPT_PARAM_ONOFF, true)
	HecarimMenu.SBTW:addParam("sbtwW", "Use "..wName.." (W) in Combo: ", SCRIPT_PARAM_ONOFF, true)
	HecarimMenu.SBTW:addParam("sbtwE", "Use "..eName.." (E) in Combo: ", SCRIPT_PARAM_ONOFF, true)
	HecarimMenu.SBTW:addParam("sbtwR", "Use "..rName.." (R) in Combo: ", SCRIPT_PARAM_ONOFF, true)


	
	-- Harass --
	HecarimMenu.Harass:addParam("harassMode", "Choose your HarassMode: ", SCRIPT_PARAM_LIST, 1, {"Q"})
	HecarimMenu.Harass:addParam("harassInfo", "", SCRIPT_PARAM_INFO, "")
	HecarimMenu.Harass:addParam("harassInfo", "--- Choose your abilitys for SBTW ---", SCRIPT_PARAM_INFO, "")
	HecarimMenu.Harass:addParam("harassQ","Use "..qName.." (Q) in Harass:", SCRIPT_PARAM_ONOFF, true)


	-- KillSteal --
	HecarimMenu.KS:addParam("Ignite", "Use Auto Ignite: ", SCRIPT_PARAM_ONOFF, true)
	HecarimMenu.KS:addParam("smartKS", "Enable smart KS: ", SCRIPT_PARAM_ONOFF, false)
	
	-- Lane Clear --
	HecarimMenu.Farm:addParam("farmInfo", "--- Choose your abilitys for LaneClear ---", SCRIPT_PARAM_INFO, "")
	HecarimMenu.Farm:addParam("farmQ", "Farm with "..qName.." (Q): ", SCRIPT_PARAM_ONOFF, true)
	-- Jungle Clear --
	HecarimMenu.Jungle:addParam("jungleInfo", "--- Choose your abilitys for JungleClear ---", SCRIPT_PARAM_INFO, "")
	HecarimMenu.Jungle:addParam("jungleQ", "Clear with "..qName.." (Q):", SCRIPT_PARAM_ONOFF, true)
	HecarimMenu.Jungle:addParam("jungleW", "Clear with "..wName.." (W):", SCRIPT_PARAM_ONOFF, true)
	HecarimMenu.Jungle:addParam("jungleE", "Clear with "..eName.." (E):", SCRIPT_PARAM_ONOFF, true)
	-- Drawings --
	HecarimMenu.Draw:addParam("drawQ", "Draw (Q) Range:", SCRIPT_PARAM_ONOFF, true)
	HecarimMenu.Draw:addParam("drawW", "Draw (W) Range:", SCRIPT_PARAM_ONOFF, false)
	HecarimMenu.Draw:addParam("drawE", "Draw (E) Range:", SCRIPT_PARAM_ONOFF, false)
	HecarimMenu.Draw:addParam("drawR", "Draw (R) Range:", SCRIPT_PARAM_ONOFF, false)
	HecarimMenu.Draw:addParam("drawKillText", "Draw killtext on enemy: ", SCRIPT_PARAM_ONOFF, true)
	HecarimMenu.Draw:addParam("drawTarget", "Draw current target: ", SCRIPT_PARAM_ONOFF, false)
		-- LFC --
	HecarimMenu.Draw:addSubMenu("LagFreeCircles: ", "LFC")
	HecarimMenu.Draw.LFC:addParam("LagFree", "Activate Lag Free Circles", SCRIPT_PARAM_ONOFF, false)
	HecarimMenu.Draw.LFC:addParam("CL", "Length before Snapping", SCRIPT_PARAM_SLICE, 350, 75, 2000, 0)
	HecarimMenu.Draw.LFC:addParam("CLinfo", "Higher length = Lower FPS Drops", SCRIPT_PARAM_INFO, "")
		-- Permashow --
	--HecarimMenu.Draw:addSubMenu("PermaShow: ", "PermaShow")
	--HecarimMenu.Draw.PermaShow:addParam("info", "--- Reload (Double F9) if you change the settings ---", SCRIPT_PARAM_INFO, "")
	--HecarimMenu.Draw.PermaShow:addParam("UltimateKey", "Show Auto-Ultimate: ", SCRIPT_PARAM_ONOFF, true)
--	HecarimMenu.Draw.PermaShow:addParam("HarassMode", "Show HarassMode: ", SCRIPT_PARAM_ONOFF, true)
	--HecarimMenu.Draw.PermaShow:addParam("HarassToggleKey", "Show HarassToggleKey: ", SCRIPT_PARAM_ONOFF, true)
	
	-- Other --
	HecarimMenu:addParam("Version", "Version", SCRIPT_PARAM_INFO, Version)
	HecarimMenu:addParam("Author", "Author", SCRIPT_PARAM_INFO, Author)
	
	-- PermaShow --
	--if HecarimMenu.Draw.PermaShow.UltimateKey
	--	then HecarimMenu.KeyBind:permaShow("UltimateKey") 
	--end
	--if HecarimMenu.Draw.PermaShow.HarassMode
	--	then HecarimMenu.Harass:permaShow("harassMode") 
	--end
	--if HecarimMenu.Draw.PermaShow.HarassToggleKey
--		then HecarimMenu.KeyBind:permaShow("HarassToggleKey") 
	--end
	
end
---------------------------------------------------------------------
--- On Tick ---------------------------------------------------------
---------------------------------------------------------------------
function OnTick()
	if myHero.dead then return end
	ts:update()
	Target = ts.target 
	Check()
	LFCfunc()
	KeyBindings()
	DamageCalculation()
	if Target
		then
			if HecarimMenu.KS.Ignite then AutoIgnite(Target) end
	end

	if UltimateKey then HecarimsUltimate() end
	if SBTWKey then SBTW() end
	if HarassKey then Harass() end
	if HarassToggleKey then Harass() end
	if ClearKey then LaneClear() JungleClear() end
	if HecarimMenu.KS.smartKS then smartKS() end
	--[[ Auto Level ]]--
	if HecarimMenu.Extra.autoLevel then
		autoLevelSetSequence(levelSequence)
	end

	if HecarimMenu.Extra.skin and skinChanged() then
		GenModelPacket("Hecarim", HecarimMenu.Extra.skin1)
		lastSkin = HecarimMenu.Extra.skin1
	end
    if GetGame().isOver then
	UpdateWeb(false, ScriptName, id, HWID)
	-- This is a var where I stop executing what is in my OnTick()
	startUp = false;
end

	if RREADY and HecarimMenu.Extra.UseR then
	AimTheR(enemy) end

end


---------------------------------------------------------------------
--- Function KeyBindings for easier KeyManagement -------------------
---------------------------------------------------------------------
function KeyBindings()
	UltimateKey = HecarimMenu.KeyBind.UltimateKey
	SBTWKey = HecarimMenu.KeyBind.SBTWKey
	HarassKey = HecarimMenu.KeyBind.HarassKey
	HarassToggleKey = HecarimMenu.KeyBind.HarassToggleKey
	ClearKey = HecarimMenu.KeyBind.ClearKey
end
---------------------------------------------------------------------
--- Function Checks for Spells and Forms ----------------------------
---------------------------------------------------------------------
function Check()
	-- Cooldownchecks for Abilitys and Summoners -- 
	QREADY = (myHero:CanUseSpell(_Q) == READY)
	WREADY = (myHero:CanUseSpell(_W) == READY)
	EREADY = (myHero:CanUseSpell(_E) == READY)
	RREADY = (myHero:CanUseSpell(_R) == READY)
	IREADY = (ignite ~= nil and myHero:CanUseSpell(ignite) == READY)
	
	-- Check if items are ready -- 
		dfgReady		= (dfgSlot		~= nil and myHero:CanUseSpell(dfgSlot)		== READY) -- Deathfire Grasp
		hxgReady		= (hxgSlot		~= nil and myHero:CanUseSpell(hxgSlot)		== READY) -- Hextech Gunblade
		bwcReady		= (bwcSlot		~= nil and myHero:CanUseSpell(bwcSlot)		== READY) -- Bilgewater Cutlass
		botrkReady		= (botrkSlot	~= nil and myHero:CanUseSpell(botrkSlot)	== READY) -- Blade of the Ruined King
		sheenReady		= (sheenSlot 	~= nil and myHero:CanUseSpell(sheenSlot) 	== READY) -- Sheen
		lichbaneReady	= (lichbaneSlot ~= nil and myHero:CanUseSpell(lichbaneSlot) == READY) -- Lichbane
		trinityReady	= (trinitySlot 	~= nil and myHero:CanUseSpell(trinitySlot) 	== READY) -- Trinity Force
		lyandrisReady	= (liandrysSlot	~= nil and myHero:CanUseSpell(liandrysSlot) == READY) -- Liandrys 
		tmtReady		= (tmtSlot 		~= nil and myHero:CanUseSpell(tmtSlot)		== READY) -- Tiamat
		hdrReady		= (hdrSlot		~= nil and myHero:CanUseSpell(hdrSlot) 		== READY) -- Hydra
		youReady		= (youSlot		~= nil and myHero:CanUseSpell(youSlot)		== READY) -- Youmuus Ghostblade
	
	-- Set the slots for item --
		dfgSlot 		= GetInventorySlotItem(3128)
		hxgSlot 		= GetInventorySlotItem(3146)
		bwcSlot 		= GetInventorySlotItem(3144)
		botrkSlot		= GetInventorySlotItem(3153)							
		sheenSlot		= GetInventorySlotItem(3057)
		lichbaneSlot	= GetInventorySlotItem(3100)
		trinitySlot		= GetInventorySlotItem(3078)
		liandrysSlot	= GetInventorySlotItem(3151)
		tmtSlot			= GetInventorySlotItem(3077)
		hdrSlot			= GetInventorySlotItem(3074)	
		youSlot			= GetInventorySlotItem(3142)
end
---------------------------------------------------------------------
--- ItemUsage -------------------------------------------------------
---------------------------------------------------------------------
function UseItems()
	if not enemy then enemy = Target end
	if ValidTarget(enemy) then
		if dfgReady		and GetDistance(enemy) <= 750 then CastSpell(dfgSlot, enemy) end
		if hxgReady		and GetDistance(enemy) <= 700 then CastSpell(hxgSlot, enemy) end
		if bwcReady		and GetDistance(enemy) <= 450 then CastSpell(bwcSlot, enemy) end
		if botrkReady	and GetDistance(enemy) <= 450 then CastSpell(botrkSlot, enemy) end
		if youReady		and GetDistance(enemy) <= 185 then CastSpell(youSlot) end
	end
end


---------------------------------------------------------------------
--- Draw Function ---------------------------------------------------
---------------------------------------------------------------------	
function OnDraw()
	if myHero.dead then return end 
-- Draw SpellRanges only when our champ is alive and the spell is ready --
	-- Draw Q + W + E + R --
		if QREADY and HecarimMenu.Draw.drawQ then DrawCircle(myHero.x, myHero.y, myHero.z, qRange, qColor) end
		if WREADY and HecarimMenu.Draw.drawW then DrawCircle(myHero.x, myHero.y, myHero.z, wRange, wColor) end
		if EREADY and HecarimMenu.Draw.drawE then DrawCircle(myHero.x, myHero.y, myHero.z, eRange, eColor) end
		if EREADY and HecarimMenu.Draw.drawEmax then DrawCircle(myHero.x, myHero.y, myHero.z, eRange*2, eColor) end
		if RREADY and HecarimMenu.Draw.drawR then DrawCircle(myHero.x, myHero.y, myHero.z, rRange, rColor) end
	-- Draw Target --
	if Target ~= nil and HecarimMenu.Draw.drawTarget
		then DrawCircle(Target.x, Target.y, Target.z, (GetDistance(Target.minBBox, Target.maxBBox)/2), TargetColor)
	end
	-- Draw KillText --
	if HecarimMenu.Draw.drawKillText then
			for i = 1, heroManager.iCount do
				local enemy = heroManager:GetHero(i)
				if ValidTarget(enemy) and enemy ~= nil then
					local barPos = WorldToScreen(D3DXVECTOR3(enemy.x, enemy.y, enemy.z))
					local PosX = barPos.x - 60
					local PosY = barPos.y - 10
					DrawText(KillTextList[KillText[i]], 16, PosX, PosY, KillTextColor)
				end
			end
		end
end
---------------------------------------------------------------------
--- Cast Functions for Spells ---------------------------------------
---------------------------------------------------------------------
-- Hecarim Q --
function CastTheQ(enemy)
		if not enemy then enemy = Target end
		if (not QREADY or (GetDistance(enemy) > qRange))
			then return false
		end
		if ValidTarget(enemy)
			then CastSpell(_Q)
			return true
		end
		return false
end
-- Hecarim W --
function CastTheW(enemy)
		if not enemy then enemy = Target end
		if (not WREADY or (GetDistance(enemy) > wRange))
			then return false
		end
		if ValidTarget(enemy)
			then CastSpell(_W, enemy)
			myHero:Attack(enemy)
			return true
		end
		return false
end
-- Hecarim E --
function CastTheE(enemy)
		if not enemy then enemy = Target end
		if (not EREADY or (GetDistance(enemy) > eRange))
			then return false
		end
		if ValidTarget(enemy)
			then CastSpell(_E, enemy)
			myHero:Attack(enemy)
			return true
		end
		return false
end

-- Hecarim R --
function AimTheR(enemy)
	if not enemy then enemy = Target end
	local CastPosition, HitChance, Position = VP:GetLineCastPosition(enemy, rDelay, rWidth, rRange, rSpeed, myHero, false)
	if HitChance >= 2 and GetDistance(enemy) <= rRange and RREADY
		then CastSpell(_R,CastPosition.x,CastPosition.z)
	end
end

-- Herarim R --
function CastR(Target)
    if RREADY then
                local ultPos = GetAoESpellPosition(300, Target)
                if ultPos and GetDistance(ultPos) <= rRange then
                        if CountEnemies(ultPos, 300) > 2 then
                                CastSpell(_R, ultPos.x, ultPos.z)
                        end
                end
        end
end

-- Count Enemies --
function CountEnemies(point, range)
        local ChampCount = 0
        for j = 1, heroManager.iCount, 1 do
                local enemyhero = heroManager:getHero(j)
				if myHero.team ~= enemyhero.team and ValidTarget(enemyhero, range+400) then
                        if GetDistance(enemyhero, point) <= range then
                                ChampCount = ChampCount + 1
                        end
                end
        end            
        return ChampCount
end

---------------------------------------------------------------------
--- SBTW Functions --------------------------------------------------
---------------------------------------------------------------------
function SBTW()
	if ValidTarget(Target)
		then 
			if HecarimMenu.SBTW.sbtwE then CastTheE(Target) end
			if HecarimMenu.SBTW.sbtwW then CastTheW(Target) end
			if HecarimMenu.SBTW.sbtwQ then CastTheQ(Target) end
			if HecarimMenu.SBTW.sbtwR and GetDistance(Target) <= rRange then CastR(Target) end
			if HecarimMenu.SBTW.sbtwItems then UseItems() end
	end
end


---------------------------------------------------------------------
--- Harass Functions ------------------------------------------------
---------------------------------------------------------------------
function Harass()
	if Target
			then
				if HecarimMenu.Harass.harassMode == 1
					then 
						if HecarimMenu.Harass.harassQ then CastTheQ(Target) end
				end
end
end
---------------------------------------------------------------------
--- OnProcessSpell --------------------------------------------------
---------------------------------------------------------------------
function OnProcessSpell(object, spell)
end
---------------------------------------------------------------------
--- KillSteal Functions ---------------------------------------------
---------------------------------------------------------------------
function AutoIgnite(enemy)
		if enemy.health <= iDmg and GetDistance(enemy) <= 600 and ignite ~= nil
			then
				if IREADY then CastSpell(ignite, enemy) end
		end
end
-- Checks the Summonerspells for ignite (OnLoad) --
function IgniteCheck()
	if myHero:GetSpellData(SUMMONER_1).name:find("SummonerDot") then
			ignite = SUMMONER_1
	elseif myHero:GetSpellData(SUMMONER_2).name:find("SummonerDot") then
			ignite = SUMMONER_2
	end
end
function smartKS()
	for _, enemy in pairs(enemyHeroes) do
		if enemy ~= nil and ValidTarget(enemy) then
		local distance = GetDistance(enemy)
		local hp = enemy.health
			if hp <= qDmg and QREADY and (distance <= qRange)
				then CastTheQ(enemy)
			elseif hp <= wDmg and WREADY and (distance <= wRange) 
				then CastTheW(enemy)
			elseif hp <= eDmg and EREADY and (distance <= eRange) 
				then CastTheE(enemy)
			elseif hp <= (qDmg + wDmg) and QREADY and WREADY and (distance <= qRange)
				then CastTheW(enemy)
			elseif hp <= (qDmg + eDmg) and QREADY and EREADY and (distance <= qRange)
				then CastTheE(enemy)
			elseif hp <= (wDmg + eDmg) and WREADY and EREADY and (distance <= wRange)
				then CastTheE(enemy)
			elseif hp <= (qDmg + wDmg + eDmg) and QREADY and WREADY and EREADY and (distance <= qRange)
				then CastTheE(enemy)
			end
		end
	end
end
---------------------------------------------------------------------
-- Jungle Mob Names -------------------------------------------------
---------------------------------------------------------------------
function JungleNames()
-- JungleMobNames are the names of the smaller Junglemobs --
	JungleMobNames =
{
	-- Blue Side --
		-- Blue Buff --
		["YoungLizard1.1.2"] = true, ["YoungLizard1.1.3"] = true,
		-- Red Buff --
		["YoungLizard4.1.2"] = true, ["YoungLizard4.1.3"] = true,
		-- Wolf Camp --
		["wolf2.1.2"] = true, ["wolf2.1.3"] = true,
		-- Wraith Camp --
		["LesserWraith3.1.2"] = true, ["LesserWraith3.1.3"] = true, ["LesserWraith3.1.4"] = true,
		-- Golem Camp --
		["SmallGolem5.1.1"] = true,
	-- Purple Side --
		-- Blue Buff --
		["YoungLizard7.1.2"] = true, ["YoungLizard7.1.3"] = true,
		-- Red Buff --
		["YoungLizard10.1.2"] = true, ["YoungLizard10.1.3"] = true,
		-- Wolf Camp --
		["wolf8.1.2"] = true, ["wolf8.1.3"] = true,
		-- Wraith Camp --
		["LesserWraith9.1.2"] = true, ["LesserWraith9.1.3"] = true, ["LesserWraith9.1.4"] = true,
		-- Golem Camp --
		["SmallGolem11.1.1"] = true,
}
-- FocusJungleNames are the names of the important/big Junglemobs --
	FocusJungleNames =
{
	-- Blue Side --
		-- Blue Buff --
		["AncientGolem1.1.1"] = true,
		-- Red Buff --
		["LizardElder4.1.1"] = true,
		-- Wolf Camp --
		["GiantWolf2.1.1"] = true,
		-- Wraith Camp --
		["Wraith3.1.1"] = true,		
		-- Golem Camp --
		["Golem5.1.2"] = true,		
		-- Big Wraith --
		["GreatWraith13.1.1"] = true, 
	-- Purple Side --
		-- Blue Buff --
		["AncientGolem7.1.1"] = true,
		-- Red Buff --
		["LizardElder10.1.1"] = true,
		-- Wolf Camp --
		["GiantWolf8.1.1"] = true,
		-- Wraith Camp --
		["Wraith9.1.1"] = true,
		-- Golem Camp --
		["Golem11.1.2"] = true,
		-- Big Wraith --
		["GreatWraith14.1.1"] = true,
	-- Dragon --
		["Dragon6.1.1"] = true,
	-- Baron --
		["Worm12.1.1"] = true,
}
	for i = 0, objManager.maxObjects do
		local object = objManager:getObject(i)
		if object ~= nil then
			if FocusJungleNames[object.name] then
				table.insert(JungleFocusMobs, object)
			elseif JungleMobNames[object.name] then
				table.insert(JungleMobs, object)
			end
		end
	end
end
---------------------------------------------------------------------
--- Jungle Clear with different forms -------------------------------
---------------------------------------------------------------------
function JungleClear()
	JungleMob = GetJungleMob()
		if JungleMob ~= nil then
			if HecarimMenu.Jungle.jungleQ then CastTheQ(JungleMob) end
			if HecarimMenu.Jungle.jungleW then CastTheW(JungleMob) end
			if HecarimMenu.Jungle.jungleE then CastTheE(JungleMob) end
		end
end
-- Get Jungle Mob --
function GetJungleMob()
        for _, Mob in pairs(JungleFocusMobs) do
                if ValidTarget(Mob, qRange) then return Mob end
        end
        for _, Mob in pairs(JungleMobs) do
                if ValidTarget(Mob, qRange) then return Mob end
        end
end
---------------------------------------------------------------------
--- Lane Clear with different forms ---------------------------------
---------------------------------------------------------------------
function LaneClear()
	enemyMinions:update()
	for _, minion in pairs(enemyMinions.objects) do
		if ValidTarget(minion) and minion ~= nil and not rSOW:CanAttack()
			then 
				if HecarimMenu.Farm.farmQ then CastTheQ(minion) end
		end
	end
end
---------------------------------------------------------------------
-- Object Handling Functions ----------------------------------------
-- Checks for objects that are created and deleted
---------------------------------------------------------------------
function OnCreateObj(obj)
	if obj ~= nil then
		if obj.name:find("TeleportHome.troy") then
			if GetDistance(obj) <= 70 then
				Recalling = true
			end
		end 
		if FocusJungleNames[obj.name] then
			table.insert(JungleFocusMobs, obj)
		elseif JungleMobNames[obj.name] then
            table.insert(JungleMobs, obj)
		end
	end
end
function OnDeleteObj(obj)
	if obj ~= nil then
		if obj.name:find("TeleportHome.troy") then
			if GetDistance(obj) <= 70 then
				Recalling = false
			end
		end 
		for i, Mob in pairs(JungleMobs) do
			if obj.name == Mob.name then
				table.remove(JungleMobs, i)
			end
		end
		for i, Mob in pairs(JungleFocusMobs) do
			if obj.name == Mob.name then
				table.remove(JungleFocusMobs, i)
			end
		end
	end
end
---------------------------------------------------------------------
-- Recalling Functions ----------------------------------------------
-- Checks if our champion is recalling or not and sets the var Recalling based on that
-- Other functions can check Recalling to not interrupt it
---------------------------------------------------------------------
function OnRecall(hero, channelTimeInMs)
	if hero.networkID == player.networkID then
		Recalling = true
	end
end
function OnAbortRecall(hero)
	if hero.networkID == player.networkID
		then Recalling = false
	end
end
function OnFinishRecall(hero)
	if hero.networkID == player.networkID
		then Recalling = false
	end
end
---------------------------------------------------------------------
--- Lag Free Circles ------------------------------------------------
---------------------------------------------------------------------
function LFCfunc()
	if not HecarimMenu.Draw.LFC.LagFree then _G.DrawCircle = _G.oldDrawCircle end
	if HecarimMenu.Draw.LFC.LagFree then _G.DrawCircle = DrawCircle2 end
end
function DrawCircleNextLvl(x, y, z, radius, width, color, chordlength)
    radius = radius or 300
  quality = math.max(8,round(180/math.deg((math.asin((chordlength/(2*radius)))))))
  quality = 2 * math.pi / quality
  radius = radius*.92
    local points = {}
    for theta = 0, 2 * math.pi + quality, quality do
        local c = WorldToScreen(D3DXVECTOR3(x + radius * math.cos(theta), y, z - radius * math.sin(theta)))
        points[#points + 1] = D3DXVECTOR2(c.x, c.y)
    end
    DrawLines2(points, width or 1, color or 4294967295)
end
function round(num) 
 if num >= 0 then return math.floor(num+.5) else return math.ceil(num-.5) end
end
function DrawCircle2(x, y, z, radius, color)
    local vPos1 = Vector(x, y, z)
    local vPos2 = Vector(cameraPos.x, cameraPos.y, cameraPos.z)
    local tPos = vPos1 - (vPos1 - vPos2):normalized() * radius
    local sPos = WorldToScreen(D3DXVECTOR3(tPos.x, tPos.y, tPos.z))
    if OnScreen({ x = sPos.x, y = sPos.y }, { x = sPos.x, y = sPos.y }) then
        DrawCircleNextLvl(x, y, z, radius, 1, color, HecarimMenu.Draw.LFC.CL) 
    end
end

---------------------------------------------------------------------
--- Function Damage Calculations for Skills/Items/Enemys --- 
---------------------------------------------------------------------
function DamageCalculation()
	for i=1, heroManager.iCount do
		local enemy = heroManager:GetHero(i)
			if ValidTarget(enemy) and enemy ~= nil
				then
				aaDmg 		= ((getDmg("AD", enemy, myHero)))
				qDmg 		= ((getDmg("Q", enemy, myHero)) or 0)	
				wDmg		= ((getDmg("W", enemy, myHero)) or 0)	
				eDmg		= ((getDmg("E", enemy, myHero)) or 0)	
				iDmg 		= ((ignite and getDmg("IGNITE", enemy, myHero)) or 0)	-- Ignite
				dfgDmg 		= ((dfgReady and getDmg("DFG", enemy, myHero)) or 0)	-- Deathfire Grasp
				hxgDmg 		= ((hxgReady and getDmg("HXG", enemy, myHero)) or 0)	-- Hextech Gunblade
				bwcDmg 		= ((bwcReady and getDmg("BWC", enemy, myHero)) or 0)	-- Bilgewater Cutlass
				botrkDmg 	= ((botrkReady and getDmg("RUINEDKING", enemy, myHero)) or 0)	-- Blade of the Ruined King
				sheenDmg	= ((sheenReady and getDmg("SHEEN", enemy, myHero)) or 0)	-- Sheen
				lichbaneDmg = ((lichbaneReady and getDmg("LICHBANE", enemy, myHero)) or 0)	-- Lichbane
				trinityDmg 	= ((trinityReady and getDmg("TRINITY", enemy, myHero)) or 0)	-- Trinity Force
				liandrysDmg = ((liandrysReady and getDmg("LIANDRYS", enemy, myHero)) or 0)	-- Liandrys 
				local extraDmg 	= iDmg + dfgDmg + hxgDmg + bwcDmg + botrkDmg + sheenDmg + trinityDmg + liandrysDmg + lichbaneDmg 
				local abilityDmg = qDmg + wDmg + eDmg
				local totalDmg = abilityDmg + extraDmg
	-- Set Kill Text --	
					-- "Kill! - Ignite" --
					if enemy.health <= iDmg
						then
							 if IREADY then KillText[i] = 3
							 else KillText[i] = 2
							 end
					-- "Kill! - (Q)" --
					elseif enemy.health <= qDmg
						then
							if QREADY then KillText[i] = 4
							else KillText[i] = 2
							end
					--	"Kill! - (W)" --
					elseif enemy.health <= wDmg
						then
							if WREADY then KillText[i] = 5
							else KillText[i] = 2
							end
					-- "Kill! - (E)" --
					elseif enemy.health <= eDmg
						then
							if EREADY then KillText[i] = 6
							else KillText[i] = 2
							end
					-- "Kill! - (Q)+(W)" --
					elseif enemy.health <= qDmg+wDmg
						then
							if QREADY and WREADY then KillText[i] = 7
							else KillText[i] = 2
							end
					-- "Kill! - (Q)+(E)" --
					elseif enemy.health <= qDmg+eDmg
						then
							if QREADY and EREADY then KillText[i] = 8
							else KillText[i] = 2
							end
					-- "Kill! - (W)+(E)" --
					elseif enemy.health <= wDmg+eDmg
						then
							if WREADY and EREADY then KillText[i] = 9
							else KillText[i] = 2
							end
					-- "Kill! - (Q)+(W)+(E)" --
					elseif enemy.health <= qDmg+wDmg+eDmg
						then
							if QREADY and WREADY and EREADY then KillText[i] = 10
							else KillText[i] = 2
							end
					-- "Harass your enemy!" -- 
					else KillText[i] = 1				
					end
			end
		end
end



--[[ 
        AoE_Skillshot_Position 2.0 by monogato
        
        GetAoESpellPosition(radius, main_target, [delay]) returns best position in order to catch as many enemies as possible with your AoE skillshot, making sure you get the main target.
        Note: You can optionally add delay in ms for prediction (VIP if avaliable, normal else).
]]

function GetCenter(points)
        local sum_x = 0
        local sum_z = 0
        
        for i = 1, #points do
                sum_x = sum_x + points[i].x
                sum_z = sum_z + points[i].z
        end
        
        local center = {x = sum_x / #points, y = 0, z = sum_z / #points}
        
        return center
end

function ContainsThemAll(circle, points)
        local radius_sqr = circle.radius*circle.radius
        local contains_them_all = true
        local i = 1
        
        while contains_them_all and i <= #points do
                contains_them_all = GetDistanceSqr(points[i], circle.center) <= radius_sqr
                i = i + 1
        end
        
        return contains_them_all
end

-- The first element (which is gonna be main_target) is untouchable.
function FarthestFromPositionIndex(points, position)
        local index = 2
        local actual_dist_sqr
        local max_dist_sqr = GetDistanceSqr(points[index], position)
        
        for i = 3, #points do
                actual_dist_sqr = GetDistanceSqr(points[i], position)
                if actual_dist_sqr > max_dist_sqr then
                        index = i
                        max_dist_sqr = actual_dist_sqr
                end
        end
        
        return index
end

function RemoveWorst(targets, position)
        local worst_target = FarthestFromPositionIndex(targets, position)
        
        table.remove(targets, worst_target)
        
        return targets
end

function GetInitialTargets(radius, main_target)
        local targets = {main_target}
        local diameter_sqr = 4 * radius * radius
        
        for i=1, heroManager.iCount do
                target = heroManager:GetHero(i)
                if target.networkID ~= main_target.networkID and ValidTarget(target) and GetDistanceSqr(main_target, target) < diameter_sqr then table.insert(targets, target) end
        end
        
        return targets
end

function GetPredictedInitialTargets(radius, main_target, delay)
        if VIP_USER and not vip_target_predictor then vip_target_predictor = TargetPredictionVIP(nil, nil, delay/1000) end
        local predicted_main_target = VIP_USER and vip_target_predictor:GetPrediction(main_target) or GetPredictionPos(main_target, delay)
        local predicted_targets = {predicted_main_target}
        local diameter_sqr = 4 * radius * radius
        
        for i=1, heroManager.iCount do
                target = heroManager:GetHero(i)
                if ValidTarget(target) then
                        predicted_target = VIP_USER and vip_target_predictor:GetPrediction(target) or GetPredictionPos(target, delay)
                        if target.networkID ~= main_target.networkID and GetDistanceSqr(predicted_main_target, predicted_target) < diameter_sqr then table.insert(predicted_targets, predicted_target) end
                end
        end
        
        return predicted_targets
end

-- I don't need range since main_target is gonna be close enough. You can add it if you do.
function GetAoESpellPosition(radius, main_target, delay)
        local targets = delay and GetPredictedInitialTargets(radius, main_target, delay) or GetInitialTargets(radius, main_target)
        local position = GetCenter(targets)
        local best_pos_found = true
        local circle = Circle(position, radius)
        circle.center = position
        
        if #targets > 2 then best_pos_found = ContainsThemAll(circle, targets) end
        
        while not best_pos_found do
                targets = RemoveWorst(targets, position)
                position = GetCenter(targets)
                circle.center = position
                best_pos_found = ContainsThemAll(circle, targets)
        end
        
        return position, #targets
end

function GenModelPacket(champ, skinId)
	p = CLoLPacket(0x97)
	p:EncodeF(myHero.networkID)
	p.pos = 1
	t1 = p:Decode1()
	t2 = p:Decode1()
	t3 = p:Decode1()
	t4 = p:Decode1()
	p:Encode1(t1)
	p:Encode1(t2)
	p:Encode1(t3)
	p:Encode1(bit32.band(t4,0xB))
	p:Encode1(1)--hardcode 1 bitfield
	p:Encode4(skinId)
	for i = 1, #champ do
		p:Encode1(string.byte(champ:sub(i,i)))
	end
	for i = #champ + 1, 64 do
		p:Encode1(0)
	end
	p:Hide()
	RecvPacket(p)
end

function skinChanged()
	return HecarimMenu.Extra.skin1 ~= lastSkin
end

function OnBugsplat()
	UpdateWeb(false, ScriptName, id, HWID)
end