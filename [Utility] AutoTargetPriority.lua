local priorityTable = {
    p5 = {"Alistar", "Amumu", "Blitzcrank", "Bard", "Braum","ChoGath", "DrMundo", "Garen", "Gnar", "Hecarim", "Janna", "JarvanIV", "Leona", "Lulu", "Malphite", "Nami", "Nasus", "Nautilus", "Nunu","Olaf", "Rammus", "Renekton", "Sejuani", "Shen", "Shyvana", "Singed", "Sion", "Skarner", "Sona","Soraka", "Taric", "Thresh", "Volibear", "Warwick", "MonkeyKing", "Yorick", "Zac", "Zyra"},
    p4 = {"Aatrox", "Darius", "Elise", "Evelynn", "Galio", "Gangplank", "Gragas", "Irelia", "Jax","LeeSin", "Maokai", "Morgana", "Nocturne", "Pantheon", "Poppy", "Rengar", "Rumble", "Ryze", "Swain","Trundle", "Tryndamere", "Udyr", "Urgot", "Vi", "XinZhao", "RekSai"},
    p3 = {"Akali", "Diana", "Fiddlesticks", "Fiora", "Fizz", "Heimerdinger", "Jayce", "Kassadin","Kayle", "KhaZix", "Lissandra", "Mordekaiser", "Nidalee", "Riven", "Shaco", "Vladimir", "Yasuo","Zilean"},
    p2 = {"Ahri", "Anivia", "Annie", "Azir","Brand",  "Cassiopeia", "Ekko", "Karma", "Karthus", "Katarina", "Kennen", "LeBlanc",  "Lux", "Malzahar", "MasterYi", "Orianna", "Syndra", "Talon",  "TwistedFate", "Veigar", "VelKoz", "Viktor", "Xerath", "Zed", "Ziggs" },
    p1 = {"Ashe", "Caitlyn", "Corki", "Draven", "Ezreal", "Graves", "Jinx", "Kalista", "KogMaw", "Lucian", "MissFortune", "Quinn", "Sivir", "Teemo", "Tristana", "Twitch", "Varus", "Vayne"},
}
function _SetPriority(table, hero, priority)
    for i=1, #table, 1 do
        if hero.charName:find(table[i]) ~= nil then
            TS_SetHeroPriority(priority, hero.charName)
        end
    end
end
function _arrangePrioritys()
     local priorityOrder = {
                [1] = {1,1,1,1,1},
        [2] = {1,1,2,2,2},
        [3] = {1,1,2,2,3},
        [4] = {1,1,2,3,4},
        [5] = {1,2,3,4,5},
    }
    local enemies = #GetEnemyHeroes()
    if enemies > 0 then
    	for i, enemy in ipairs(GetEnemyHeroes()) do
    	    _SetPriority(priorityTable.p1, enemy, priorityOrder[enemies][1])
    	    _SetPriority(priorityTable.p2, enemy, priorityOrder[enemies][2])
    	    _SetPriority(priorityTable.p3,  enemy, priorityOrder[enemies][3])
    	    _SetPriority(priorityTable.p4,  enemy, priorityOrder[enemies][4])
    	    _SetPriority(priorityTable.p5,  enemy, priorityOrder[enemies][5])
    	end
		print("<font color=\"#6699ff\"><b>" .. "Target Selector" .. ":</b></font> <font color=\"#FFFFFF\">" .. "Auto Priority Loaded :)" .. "</font>")
    end
end

function OnLoad()
	TargetSelector(TARGET_LESS_CAST_PRIORITY, 0)
	DelayAction(_arrangePrioritys, 5)
end