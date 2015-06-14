local immuneEffects = {
	{'zhonyas_ring_activate.troy', 2.5},
	{'Aatrox_Passive_Death_Activate.troy', 3},
	{'LifeAura.troy', 4},
	{'nickoftime_tar.troy', 7},
	{'eyeforaneye_self.troy', 2},
	{'UndyingRage_buf.troy', 5},
	{'EggTimer.troy', 6},
}

function OnLoad()
	immuneTable = {}
	checkDistance = 3000 * 3000
	PrintChat("<font color='#CCCCCC'>ImmuneCountdown loaded</font>")
end

function OnTick()
	ClearImmuneTable()
end

function OnCreateObj(object)
	if object and object.valid then
		for _, effect in pairs(immuneEffects) do
			if effect[1] == object.name then
				local nearestHero = nil
				for i = 1, heroManager.iCount do
					local hero = heroManager:GetHero(i)
					if nearestHero and nearestHero.valid and hero and hero.valid then
						if GetDistanceSqr(hero, object) < GetDistanceSqr(nearestHero, object) then
							nearestHero = hero
						end
					else
						nearestHero = hero
					end
				end
				immuneTable[nearestHero.networkID] = os.clock() + effect[2]
			end
		end
	end
end

function OnDraw()
	for networkID, time in pairs(immuneTable) do
		local unit = objManager:GetObjectByNetworkId(networkID)
		if unit and unit.valid and not unit.dead and GetDistanceSqr(myHero, unit) <= checkDistance then
			DrawText3D(tostring(math.round(time - os.clock())), unit.x, unit.y, unit.z, 70, RGB(255, 255, 255), true)
		end
	end
end

function ClearImmuneTable()
	for networkID, time in pairs(immuneTable) do
		if os.clock() > time then
			immuneTable[networkID] = nil
		end
	end
end