pico-8 cartridge // http://www.pico-8.com
version 15
__lua__
bck={}
stars={}
t = {}

----------
-- init --
function _init()
	--add_bck()
	--create_bck()
	create_stars()
end
		
function add_bck()
	local b={}
	b.x=10
	b.y=10
	add(bck,b)
end

function create_bck()
	for i=1,20 do
	 --add_bck()
		local b = {}
		b.x = 10
		b.y = 10
		add(bck,b)
 end
end

function create_stars()
	for i=1,20 do
		local s = {}
		s.x = rnd(127)
		s.y = rnd(127)
		s.dy = 0.5 + (rnd(100) * 0.01)
		if s.dy>1.45 then
			s.dy=4
		end
		if s.dy < 1.2 then
			s.col=1
 	else
 		s.col=7
		end
		add(stars,s)
	end
end

function draw_bck()
	for b in all(bck) do
		print(b.x,10,10)
	end
end

function draw_stars()
	for s in all(stars) do
	 sy2=s.y-(s.dy+2*0.3)*2
	 c=s.col
		line(s.x,s.y,s.x,sy2,c)
	end
end

------------
-- update --
function _update()
	--add_bck()
	--add(t,#background)
end

----------
-- draw --
function _draw()
	cls()
	draw_stars()
	--draw_bck()
	foreach(bck,function(b)
		print(b.x,10,10)
	end) 
	--for b in all(bck) do
	--	print(b.x,10,10)
	--end
	foreach(t, print)
end


__gfx__
00000000e000000e00000000000000000022220002222220000ddddd000ccc000000000000000000000000000000000000000000000000000000000000000000
0000000000666000000000000000000002eeee202efffff200d1112000ccccc00000000000000000000000000000000000000000000000000000000000000000
007007006655cc7000000090000000902ee00fe22eeeeef20112112000cc6cc00000000000000000000000000000000000000000000000000000000000000000
00077000f5555cc5004099aa0000089a2e0000e2022222201181215600c686c00000000000000000000000000000000000000000000000000000000000000000
00077000f55665550009aa9a000499aa2e0000e2000000001111215500cc6cc00000000000000000000000000000000000000000000000000000000000000000
007007000066f00000000890000004902ee00ee200000000011211200ccccccc0000000000000000000000000000000000000000000000000000000000000000
000000000fff0000000000000000000002eeee2000000000001112000c00000c0000000000000000000000000000000000000000000000000000000000000000
00000000e000000e000000000000000000222200000000000001200000c000c00000000000000000000000000000000000000000000000000000000000000000
09999990000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
9ffffff9099999900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
9aaaaaf99ffffff90000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
099999909faaaff90000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000009aaaaaf90000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000009faaaaa90000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000099999900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
55555555555555550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
550b77b0550000b70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
50505b505050005b0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
50055005500505000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
50005000500050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
55555555555550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
60006000600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
66666666666666660000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00999900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
09aaaa90000990000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
9a7777a9009aa9000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
9a7777a909a77a900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
9a7777a909a77a900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
9a7777a9009aa9000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
09aaaa90000990000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00999900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0ba00ba000bbba0000bbba0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
b33bb5370b3333700b53337000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
b53bb35bb35bb33ab33bb33a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
b33ab33bb33ab53bb3335bb000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0b3335b0b535333b0bb3353a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00b35b00b35bb35bb35bb33b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00b53b00b33bb53b0b3335b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000bb0000bb00bb000bbbb0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
55557555556555655555555555575555000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
55575500556555565555565500556555000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
55755000565555555565556500055655000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
57550000555565555565565500005565000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
57500000556655555556555500000565000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
57500000555655565555566500000565000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
65500000555555655555556500000556000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
55000000655555655565555500000055000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000006660000000000000000000000006600000000006600066000000000000000000000000000000000000000000000000000000000000000000000000000
00000066666000000000000000066660066660000000066600000000000000000000000000000000000000000000000000000000000000000000000000000000
00000666666600660000000000666666666666600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00006666666666666600000006666666666666660066000000000600000000000000000000000000000000000000000000000000000000000000000000000000
00006666666666666660000066666666666666660666666000666660000000000000000000000000000000000000000000000000000000000000000000000000
06666666666666666666600066666666666666666666666606666666000000000000000000000000000000000000000000000000000000000000000000000000
66666666666666666666666006666666666666660000066066666600000000000000000000000000000000000000000000000000000000000000000000000000
66666666666666666666666600666666600666600000000006660000000000000000000000000000000000000000000000000000000000000000000000000000
66666666666666666666666600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
66666666666666666666666600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
06666666666666666666666000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00666666660066666660000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00066666600006666600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000666000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__label__
88888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888
88888888888888888888888888888888888888888888888888888888888888888888888888888888888ff8ff8888228822888222822888888822888888228888
8888888888888888888888888888888888888888888888888888888888888888888888888888888888ff888ff888222222888222822888882282888888222888
8888888888888888888888888888888888888888888888888888888888888888888888888888888888ff888ff888282282888222888888228882888888288888
8888888888888888888888888888888888888888888888888888888888888888888888888888888888ff888ff888222222888888222888228882888822288888
8888888888888888888888888888888888888888888888888888888888888888888888888888888888ff888ff888822228888228222888882282888222288888
88888888888888888888888888888888888888888888888888888888888888888888888888888888888ff8ff8888828828888228222888888822888222888888
88888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888
55555555555556555555565555655656556556565655577755c55555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555556655555566655655666556556565666555555c55555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555556555555555655655656556556565556577755c55555555555555555555555555555555555555555555555555555555555555555555555555555
5555555555555666557556655565565655655566566555555ccc5555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
5555555555555bbb5bbb5b5555755575555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
5555555555555b5b5b5b5b5557555557555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
5555555555555bbb5bbb5b5557555557555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
5555555555555b555b5b5b5557555557555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
5555555555555b555b5b5bbb55755575555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
555555555eee5e5555ee5eee55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
555555555e555e555e555e5555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
555555555ee55e555eee5ee555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
555555555e555e55555e5e5555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
555555555eee5eee5ee55eee55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
5555555555555666555555665666566656665656556655555ccc5555555555555555555555555555555555555555555555555555555555555555555555555555
5555555555555655555556555565565655655656565557775c5c5555555555555555555555555555555555555555555555555555555555555555555555555555
5555555555555665555556665565566655655656566655555c5c5555555555555555555555555555555555555555555555555555555555555555555555555555
5555555555555655555555565565565655655656555657775c5c5555555555555555555555555555555555555555555555555555555555555555555555555555
5555555555555666557556655565565655655566566555555ccc5555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
5555555555555eee55ee5eee5555566655555cc555555cc55ccc55555ee555ee5555555555555555555555555555555555555555555555555555555555555555
5555555555555e555e5e5e5e55555565577755c5555555c55c5555555e5e5e5e5555555555555555555555555555555555555555555555555555555555555555
5555555555555ee55e5e5ee555555565555555c5555555c55ccc55555e5e5e5e5555555555555555555555555555555555555555555555555555555555555555
5555555555555e555e5e5e5e55555565577755c5557555c5555c55555e5e5e5e5555555555555555555555555555555555555555555555555555555555555555
5555555555555e555ee55e5e5555566555555ccc57555ccc5ccc55555eee5ee55555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555eee5eee55755666565657555ccc55755eee5e5e5eee5ee55555556655665655555556655666566656665666565557755666557755555555
555555555555555555e55e555755565556565575555c555755e55e5e5e555e5e5555565556565655577756565655565656565656565557555565555755555555
555555555555555555e55ee557555665566655575ccc555755e55eee5ee55e5e5555565556565655555556565665566556665666565557555565555755555555
555555555555555555e55e5557555655555655755c55555755e55e5e5e555e5e5555565556565655577756565655565656555656565557555565555755555555
55555555555555555eee5e5555755666566657555ccc557555e55e5e5eee5e5e5555556656655666555556665666565656555656566657755665557755555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555eee5e5555ee5eee55555566556656555555566556665666565557755666557755555eee5ee55ee555555555555555555555555555555555
55555555555555555e555e555e555e5555555655565656555777565656565656565557555565555755555e555e5e5e5e55555555555555555555555555555555
55555555555555555ee55e555eee5ee555555655565656555555565656665666565557555565555755555ee55e5e5e5e55555555555555555555555555555555
55555555555555555e555e55555e5e5555555655565656555777565656555656565557555565555755555e555e5e5e5e55555555555555555555555555555555
55555555555555555eee5eee5ee55eee55555566566556665555566656555656566657755665557755555eee5e5e5eee55555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555bbb5bbb5b555575566655555cc5555555665566565555755555555555555555555555555555555555555555555555555555555555555555
55555555555555555b5b5b5b5b5557555565555555c5555556555656565555575555555555555555555555555555555555555555555555555555555555555555
55555555555555555bbb5bbb5b5557555565577755c5555556555656565555575555555555555555555555555555555555555555555555555555555555555555
55555555555555555b555b5b5b5557555565555555c5557556555656565555575555555555555555555555555555555555555555555555555555555555555555
55555555555555555b555b5b5bbb5575566555555ccc575555665665566655755555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555588888555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
5555555555555eee5ee55ee588888555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
5555555555555e555e5e5e5e88888555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
5555555555555ee55e5e5e5e88888555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
5555555555555e555e5e5e5e88888555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
5555555555555eee5e5e5eee88888555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
5555555555555bbb5bbb5b555bbb55755ccc55555ccc5ccc5c5c5ccc557555555555555555555555555555555555555555555555555555555555555555555555
5555555555555b5b5b5b5b5555b557555c5c555555c51c5c5c5c5c55555755555555555555555555555555555555555555555555555555555555555555555555
5555555555555bbb5bbb5b5555b557555c5c555555c171c55c5c5cc5555755555555555555555555555555555555555555555555555555555555555555555555
5555555555555b555b5b5b5555b557555c5c557555c1771c5c5c5c55555755555555555555555555555555555555555555555555555555555555555555555555
5555555555555b555b5b5bbb55b555755ccc575555c1777155cc5ccc557555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555551777715555555555555555555555555555555555555555555555555555555555555555555555555555555
555555555eee5ee55ee5555555555555555555555551771155555555555555555555555555555555555555555555555555555555555555555555555555555555
555555555e555e5e5e5e555555555555555555555555117155555555555555555555555555555555555555555555555555555555555555555555555555555555
555555555ee55e5e5e5e555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
555555555e555e5e5e5e555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
555555555eee5e5e5eee555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555556656665666566656665666555556665566556656665575566655555656555556665555565655555666565655555ccc5c5555555ccc557555555555
55555555565556565656556555655655555555565656565656665755565555555656555556555555565655555655565655555c555c5555555c5c555755555555
55555555566656665665556555655665555555655656565656565755566555555565555556655555566655555665566655555ccc5ccc55555c5c555755555555
5555555555565655565655655565565555555655565656565656575556555555565655755655555555565575565555565575555c5c5c55755c5c555755555555
55555555566556555656566655655666566656665665566556565575566655755656575556665575566657555666566657555ccc5ccc57555ccc557555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555eee5e5555ee5eee555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555e555e555e555e55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555ee55e555eee5ee5555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555e555e55555e5e55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555eee5eee5ee55eee555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
555555555555555555555ddd5ddd5ddd5ddd55dd5d5d5ddd55dd5ddd555555dd5ddd5ddd5dd55dd55ddd5ddd5dd5555555555555555555555555555555555555
555555555555555555555d5d5d555d5555d55d555d5d5d5d5d555d5555555d5555d55d5d5d5d5d5d5d5d5d5d5d5d555555555555555555555555555555555555
555555555ddd5ddd55555ddd5dd55dd555d55d555ddd5ddd5d555dd555555ddd55d55ddd5d5d5d5d5ddd5dd55d5d555555555555555555555555555555555555
555555555555555555555d5d5d555d5555d55d555d5d5d5d5d5d5d555555555d55d55d5d5d5d5d5d5d5d5d5d5d5d555555555555555555555555555555555555
555555555555555555555d5d5d555d555ddd55dd5d5d5d5d5ddd5ddd55555dd555d55d5d5d5d5ddd5d5d5d5d5ddd555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
5555555555bb5bbb5bbb557556665555556655555666555556565555566655555656557555555555555555555555555555555555555555555555555555555555
555555555b555b5b5b5b575556555555565555555655555556565555565555555656555755555555555555555555555555555555555555555555555555555555
555555555bbb5bbb5bb5575556655555566655555665555555655555566555555666555755555555555555555555555555555555555555555555555555555555
55555555555b5b555b5b575556555555555655755655555556565575565555555556555755555555555555555555555555555555555555555555555555555555
555555555bb55b555b5b557556665575566557555666557556565755566655755666557555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555eee5ee55ee55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555e555e5e5e5e5555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555ee55e5e5e5e5555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555e555e5e5e5e5555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555eee5e5e5eee5555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
5eee5ee55ee555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
5e555e5e5e5e55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
5ee55e5e5e5e55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
5e555e5e5e5e55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
5eee5e5e5eee55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
5ddd5ddd5ddd5ddd5ddd5ddd5ddd5ddd5ddd5ddd5ddd5ddd5ddd5ddd5ddd55555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
88888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888
82888222822882228888822282888288888282828222822288888888888888888888888888888888888888888882288222822282228882822282288222822288
82888828828282888888888282888288882882828288828288888888888888888888888888888888888888888888288282888282888828828288288282888288
82888828828282288888822282228222882882228222822288888888888888888888888888888888888888888888288222888282228828822288288222822288
82888828828282888888828882828282882888828882828288888888888888888888888888888888888888888888288282888288828828828288288882828888
82228222828282228888822282228222828888828222822288888888888888888888888888888888888888888882228222888282228288822282228882822288
88888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888

__map__
2020202100000000000000400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
