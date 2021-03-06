require("data")

STATEMENU = 0
STATEGAME = 1
STATEWIN = 2
STATEFAIL = 3
STATESTAT = 4

-- Aliases
local Draw = love.graphics.draw
local PauseAllAudio = love.audio.pause
local Print = love.graphics.print

function Playx(x)
	x:rewind()
	love.audio.play(x)
end
local Play = love.audio.play

function Img(p)
	local r
	r = love.graphics.newImage(p)
	return r
end

function Music(p)
	local s
	s = love.audio.newSource(p, "stream")
	return s
end

function Sfx(p)
	local s
	s = love.audio.newSource(p, "static")
	return s
end

function to01(a,x,b)
	return x-a/(b-a)
end

function from01(a,x,b)
	return (b-a)*x + a
end

function wrap01(x)
	local r
	r = x
	while r > 1 do
		r = r - 1
	end
	while r < 0 do
		r = r + 1
	end
	return r
end

-----------------------------------------------------------------------------------------
-- Startup
local state = STATEMENU

local stats = {}

function ResetStats()
	stats.xpgained = 0
	stats.levelsgained = 0
	
	stats.monsterskilled = 0
	stats.branchesdodged = 0
	stats.stonesjumped = 0
	stats.damagetaken = 0
end

ResetStats()

function SetState(x)
	PauseAllAudio()
	state = x
	Setup()
end

function love.load()
	love.graphics.setFont(love.graphics.newFont("PressStart2P.ttf", 20))
	math.randomseed( tonumber(tostring(os.time()):reverse():sub(1,6)) )
	Setup()
end

-----------------------------------------------------------------------------------------

-- Sounds
local foresta = Music("music/foresta.ogg")
local forestb = Music("music/forestb.ogg")
local forestc = Music("music/forestc.ogg")
foresta:setLooping(true)
forestb:setLooping(true)
forestc:setLooping(true)

local cavea = Music("music/cavea.ogg")
local caveb = Music("music/caveb.ogg")
local cavec = Music("music/cavec.ogg")
cavea:setLooping(true)
caveb:setLooping(true)
cavec:setLooping(true)

local haunteda = Music("music/haunteda.ogg")
local hauntedb = Music("music/hauntedb.ogg")
local hauntedc = Music("music/hauntedc.ogg")
haunteda:setLooping(true)
hauntedb:setLooping(true)
hauntedc:setLooping(true)

local titlemusic = Music("music/title.ogg")
local failmusic = Music("music/defeat.ogg")
local winmusic = Music("music/victory.ogg")
local statmusic = Music("music/stat.ogg")
statmusic:setLooping(true)

local sfxhurt = Sfx("sfx/Hurt.ogg")
local sfxjump = Sfx("sfx/Jump.ogg")
local sfxslash = Sfx("sfx/Slash.ogg")
local sfxslide = Sfx("sfx/Slide.ogg")

-- Graphics
local title = Img("gfx/title.png")
local cavestatbg = Img("gfx/stats/cave.png")
local foreststatbg = Img("gfx/stats/forest.png")
local hauntedstatbg = Img("gfx/stats/haunted.png")
local winbg = Img("gfx/win.png")
local failbg = Img("gfx/fail.png")
local forestbg = Img("gfx/world/forest.png")
local cavebg = Img("gfx/world/cave.png")
local hauntedbg = Img("gfx/world/haunted.png")
local player = {Img("gfx/knight/run0.png"),Img("gfx/knight/run1.png"),Img("gfx/knight/run2.png"),Img("gfx/knight/run3.png"),Img("gfx/knight/run4.png"),Img("gfx/knight/run5.png"),Img("gfx/knight/run6.png"),Img("gfx/knight/run7.png")}
local goblin = Img("gfx/goblin/idle.png")
local goblindead = Img("gfx/goblin/dead.png")
local goblinhappy = Img("gfx/goblin/happy.png")
local playerslide = {Img("gfx/knight/slide0.png"), Img("gfx/knight/slide1.png")}
local playerjump = Img("gfx/knight/jump0.png")
local playerattack = {Img("gfx/knight/attack0.png"),Img("gfx/knight/attack1.png"),Img("gfx/knight/attack2.png"),Img("gfx/knight/attack3.png"),Img("gfx/knight/attack4.png"),Img("gfx/knight/attack5.png"),Img("gfx/knight/attack6.png"),Img("gfx/knight/attack7.png")}
local stone = Img("gfx/stone/normal.png")
local stonebroken = Img("gfx/stone/broken.png")
local cavetree = Img("gfx/tree/cave.png")
local hauntedtree = Img("gfx/tree/haunted.png")
local foresttree = Img("gfx/tree/forest.png")

local cavetreebroken = Img("gfx/tree/cavebroken.png")
local hauntedtreebroken = Img("gfx/tree/hauntedbroken.png")
local foresttreebroken = Img("gfx/tree/forestbroken.png")

local heartgfx = Img("gfx/heart.png")

local worldindex = 1

local godmode = false
local currentlevel = 1

function BeginPrint()
	if worldindex == 1 then
		love.graphics.setColor(0, 0, 0)
	end
end

function EndPrint()
	love.graphics.setColor(255, 255, 255)
end

-----------------------------------------------------------------------------------------

local cheatcode = {"up", "down", "up", "down" , "left", "right", "left", "right", "b", "a", "s"}
local cheatindex = 1
local cheattimer = 0

function title_onkey(key)
	if key == cheatcode[cheatindex] then
		cheatindex = cheatindex + 1
		if cheatindex > #cheatcode then
			--Playx(titlemusic)
			Play(sfxjump)
			--Play(sfxslash)
			Play(sfxslide)
			godmode = true
			cheatindex = 1
			cheattimer = 0
		else
			cheattimer = 0.6
		end
	else
		cheatindex = 1
		cheattimer = 0
	end
	
	if key == " " then
		worldindex = 1
		ResetStats()
		currentxp = 0
		currentlevel = 1
		SetState(STATEGAME)
	end
end
function title_draw()
	Draw(title, 0,0)
end
function title_update(dt)
	if cheattimer > 0 then
		cheattimer = cheattimer - dt
		if cheattimer <= 0 then
			cheattimer = -1
			cheatindex = 1
			Play(sfxhurt)
		end
	end
end
function title_setup()
	godmode = false
	Playx(titlemusic)
end

-----------------------------------------------------------------------------------------
function win_onkey(key)
	if key == " " then
		SetState(STATEMENU)
	end
end
function win_draw()
	Draw(winbg, 0,0)
end
function win_update(dt)
end
function win_setup()
	Playx(winmusic)
end

-----------------------------------------------------------------------------------------
function fail_onkey(key)
	if key == " " then
		SetState(STATEMENU)
	end
end
function fail_draw()
	Draw(failbg, 0,0)
end
function fail_update(dt)
end
function fail_setup()
	Playx(failmusic)
end


-----------------------------------------------------------------------------------------

function Enemy()
	local s
	s = {}
	s.pos = 600
	return s
end
local enemies = {}

local leveldata = FORESTDATA
local levelindex = 1
local jumptimer = 0
local isjumping = false
local gametimer = 0
local enemytype = 4
local actiontype = 1

local levelmusica
local levelmusicb
local levelmusicc

local currentxp = 0
local collided = false
local jumpedstone = false
local health = MAXHEALTH
local actionmade = false
local gotacstat = false
local baselevel = 1

local gamebkg = forestbg
local tree = foresttree
local animindex = 1
local animtimer = 0
local treebroken = foresttreebroken

function game_logic()
	-- jumpheight less than 60 = player collide with stone & x between -10 and 160
	local enemypos = 0
	-- 0.68 = player placing
	-- was wrap01(gametimer-0.38)
	enemypos = from01(-256, gametimer, 800)
	local col = false
	if enemypos > -1 and enemypos < 160 then
		col = true
	else
		col = false
	end
	
	local dojump = isjumping
	
	if col and jumpedstone then
		dojump = true
	end
	
	local jumpheight = 0
	if dojump then
		jumpheight = 180
	else
		jumpheight = 0
	end
	
	return jumpheight,enemypos,col,dojump
end

function currentsprite(animlist)
	return animlist[(animindex % #animlist)+1]
end

function game_draw()
	local jumpheight,enemypos,col,dojump = game_logic()
	Draw(gamebkg, 0,0)
	
	if enemytype == 1 then
		if collided then
			Draw(stonebroken, enemypos, 370)
		else
			Draw(stone, enemypos, 370)
		end
	elseif enemytype == 2 then
		if collided then
			Draw(treebroken, enemypos, 80)
		else
			Draw(tree, enemypos, 80)
		end
	elseif enemytype == 3 then
		if collided then
			Draw(goblinhappy, enemypos, 350)
		elseif jumpedstone then
			Draw(goblindead, enemypos, 350)
		else
			Draw(goblin, enemypos, 350)
		end
	elseif enemytype == 4 then
		-- no enemy here
	else
		BeginPrint()
		love.graphics.print("Unknown enemytype" .. enemytype, enemypos, 340)
		EndPrint()
	end
	
	if actiontype == 1 then
		if jumpheight > 10 then
			Draw(playerjump, 72,350 - jumpheight)
		else
			Draw(currentsprite(player), 72,350 - jumpheight)
		end
	elseif actiontype == 2 then
		if dojump then
			Draw(currentsprite(playerslide), 72,350)
		else
			Draw(currentsprite(player), 72,350)
		end
	elseif actiontype == 3 then
		if dojump then
			Draw(currentsprite(playerattack), 72,350)
		else
			Draw(currentsprite(player), 72,350)
		end
	elseif actiontype == 4 then
		-- no enemy here
		Draw(currentsprite(player), 72,350 - jumpheight)
	else
		BeginPrint()
		love.graphics.print("Unknown actiontype" .. actiontype, 72, 300)
		EndPrint()
	end
	
	if collided then
		BeginPrint()
		love.graphics.print("Bad!", INFOX, INFOY)
		EndPrint()
	end
	
	if jumpedstone then
		BeginPrint()
		love.graphics.print("Good!", INFOX, INFOY)
		EndPrint()
	end
	
	-- logic in draw function? - don't complain, this is a gamejam!
	if col then
		if jumpheight < 60 or enemytype~=actiontype then
			if jumpedstone==false then
				if collided == false then
					if enemytype ~= 4 then
						collided = true
						Play(sfxhurt)
						stats.damagetaken = stats.damagetaken + 1
						
						if godmode == false then
							health = health - 1
							if health == 0 then
								SetState(STATEFAIL)
							end
						end
					end
				end
			end
		else
			if collided == false then -- jumping over the stone
				jumpedstone = true
			end
		end
	end
	
	if not collided and jumpedstone and gotacstat==false then
		gotacstat = true
		
		if enemytype == 1 then
			stats.stonesjumped = stats.stonesjumped + 1
		elseif enemytype == 2 then
			stats.branchesdodged = stats.branchesdodged + 1
		elseif enemytype == 3 then
			stats.monsterskilled = stats.monsterskilled + 1
		end
	end
	
	-- hud
	BeginPrint()
	love.graphics.printf("Experience: " .. currentxp .. " & Level: " .. currentlevel, 0, 20, 780, "right")
	EndPrint()
	for i=1,health do
		Draw(heartgfx, HEARTX + (i-1)*SPACEBETWEENHEARTS, HEARTY)
	end
end
function game_onkey(key)
end
function game_update(dt)
	animtimer = animtimer + dt
	if animtimer > ANIMSPEED then
		animindex = animindex + 1
		animtimer = animtimer - ANIMSPEED
	end
	gametimer = gametimer - dt * (90/60)/2
	if gametimer < 0 then
		gametimer = gametimer + 1
		local leveltype
		local lastenemy = 0
		lastenemy = enemytype
		if levelindex > leveldata:len() then
			enemytype = 4
			SetState(STATESTAT)
		else
			leveltype = string.sub(leveldata, levelindex,levelindex)
			if leveltype == "-" then
				enemytype = 2
			elseif leveltype == "o" then
				enemytype = 1
			elseif leveltype == "8" then
				enemytype = 3
			elseif leveltype == " " then
				enemytype = 4
			elseif leveltype == "r" then
				enemytype = math.random(3)
			else
				print("Unknown level character " .. leveltype)
				enemytype = 1
			end
		end
		
		levelindex = levelindex + 1
		
		if collided == false and lastenemy~=4 then
			print("Gaining some xp")
			currentxp = currentxp + 1
			stats.xpgained = stats.xpgained + 1
			if currentxp >= XPLEVEL then
				currentxp = 0
				print("newlevel")
				currentlevel = currentlevel + 1
				stats.levelsgained = stats.levelsgained + 1
				levelmusic()
			end
		end
		collided = false
		jumpedstone = false
		actionmade = false
		gotacstat = false
	end
	
	if actionmade == false then
		actiontype = 0
		handleActionType(dt, JUMPKEY, 1)
		handleActionType(dt, SLIDEKEY, 2)
		handleActionType(dt, SWORDKEY, 3)
	end
	
	if actionmade == false and actiontype ~= 0 and jumptimer < REACTIONTIME then
		if actiontype == 1 then
			Play(sfxjump)
		elseif actiontype == 2 then
			Play(sfxslide)
		elseif actiontype == 3 then
			Play(sfxslash)
			animindex = 1
		elseif actiontype == 4 then
			Play(sfxjump)
		else
			print("Unknown actiontype" .. actiontype)
		end
		actionmade = true
	end
	
	if actiontype ~= 0 then
		if jumptimer < REACTIONTIME then
			jumptimer = jumptimer + dt
			isjumping = true
		else
			isjumping = false
			actionmade = false
		end
	else
		actiontype = 1
		isjumping = false
		jumptimer = 0
	end
end

function handleActionType(dt, currentactionkey, t)
	if love.keyboard.isDown(currentactionkey) then
		actiontype = t
	end
end

function game_setup()
	-- someone smart might place this into a array, but meh... who got the time anyway
	if worldindex == 1 then
		leveldata = FORESTDATA
		levelmusica = foresta
		levelmusicb = forestb
		levelmusicc = forestc
		gamebkg = forestbg
		tree = foresttree
		treebroken = foresttreebroken
	elseif worldindex == 2 then
		leveldata = CAVEDATA
		levelmusica = cavea
		levelmusicb = caveb
		levelmusicc = cavec
		gamebkg = cavebg
		tree = cavetree
		treebroken = cavetreebroken
	else
		leveldata = HAUNTEDDATA
		levelmusica = haunteda
		levelmusicb = hauntedb
		levelmusicc = hauntedc
		gamebkg = hauntedbg
		tree = hauntedtree
		treebroken = hauntedtreebroken
	end
	
	baselevel = currentlevel
	levelindex = 1
	jumptimer = 0
	isjumping = false
	gametimer = 0
	enemytype = 4
	collided = false
	jumpedstone = false
	health = MAXHEALTH
	actionmade = false
	gotacstat = false

	Playx(levelmusica)
	Playx(levelmusicb)
	Playx(levelmusicc)
	levelmusica:setVolume(0)
	levelmusicb:setVolume(0)
	levelmusicc:setVolume(0)
	
	levelmusic()
	print("Base level", baselevel, currentlevel)
end
function levelmusic()
	levelmusica:setVolume(0)
	levelmusicb:setVolume(0)
	levelmusicc:setVolume(0)
	
	local add
	add = 1
	-- change every other at third level
	if worldindex == 3 then
		add = 3
	end
	
	if currentlevel >= baselevel+add*2 then
		print("setting music c", currentlevel, baselevel)
		levelmusicc:setVolume(1)
	elseif currentlevel >= baselevel+add then
		print("setting music b", currentlevel, baselevel)
		levelmusicb:setVolume(1)
	else
		print("setting music a", currentlevel, baselevel)
		levelmusica:setVolume(1)
	end
end

-----------------------------------------------------------------------------------------
local statbg = foreststatbg
function stat_onkey(key)
	if key == " " then
		worldindex = worldindex + 1
		if worldindex == 4 then
			SetState(STATEWIN)
		else
			SetState(STATEGAME)
		end
		ResetStats()
	end
end
function stat_draw()
	Draw(statbg, 0,0)
	
	BeginPrint()
	Print(stats.xpgained,        STATXP, STATY + STATDIFF*0)
	Print(stats.levelsgained,    STATXP, STATY + STATDIFF*1)
	Print(stats.monsterskilled,  STATXP, STATY + STATDIFF*2)
	Print(stats.branchesdodged,  STATXP, STATY + STATDIFF*3)
	Print(stats.stonesjumped,    STATXP, STATY + STATDIFF*4)
	Print(stats.damagetaken,     STATXP, STATY + STATDIFF*5)
	
	Print("Experience gained: ", STATX, STATY + STATDIFF*0)
	Print("Levels gained: ",     STATX, STATY + STATDIFF*1)
	Print("Monsters killed:",    STATX, STATY + STATDIFF*2)
	Print("Branches dodged:",    STATX, STATY + STATDIFF*3)
	Print("Stones jumped:",      STATX, STATY + STATDIFF*4)
	Print("Damage taken:",       STATX, STATY + STATDIFF*5)
	EndPrint()
end
function stat_update(dt)
end
function stat_setup()
	if worldindex == 1 then
		statbg = foreststatbg
	elseif worldindex == 2 then
		statbg = cavestatbg
	else
		statbg = hauntedstatbg
	end
	Playx(statmusic)
end

-----------------------------------------------------------------------------------------
function Setup()
	if state == STATEMENU then title_setup()
	elseif state == STATEGAME then game_setup()
	elseif state == STATEWIN then win_setup()
	elseif state == STATEFAIL then fail_setup()
	elseif state == STATESTAT then stat_setup()
	else
		print("unknown gamestate " .. state)
	end
end

function love.draw()
	if state == STATEMENU then title_draw()
	elseif state == STATEGAME then game_draw()
	elseif state == STATEWIN then win_draw()
	elseif state == STATEFAIL then fail_draw()
	elseif state == STATESTAT then stat_draw()
	else
		BeginPrint()
		love.graphics.print("unknown gamestate " .. state, 400, 300)
		EndPrint()
	end
end

function love.keyreleased(key)
	if key == "escape" then
		love.event.push("quit")   -- actually causes the app to quit
	end
	
	if state == STATEMENU then title_onkey(key)
	elseif state == STATEGAME then game_onkey(key)
	elseif state == STATEWIN then win_onkey(key)
	elseif state == STATEFAIL then fail_onkey(key)
	elseif state == STATESTAT then stat_onkey(key)
	else
		print("unknown gamestate " .. state)
	end
end

function love.update(dt)
	if state == STATEMENU then title_update(dt)
	elseif state == STATEGAME then game_update(dt)
	elseif state == STATEWIN then win_update(dt)
	elseif state == STATEFAIL then fail_update(dt)
	elseif state == STATESTAT then stat_update(dt)
	else
		print("unknown gamestate " .. state)
	end
end