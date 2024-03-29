pico-8 cartridge // http://www.pico-8.com
version 34
__lua__
-- const
debug=true
debug_car=true
debug_circuit=true
-- ihm
clipping=20 -- bordure du bas

cars={}

function _init()
	_draw=drawinterlude
end

function _update()
	--race:update()
end

function _draw()
	cls()
	drawinterlude(1)
	
	--race:draw()
end

--[[
function sprite_zoom(x,y,scale,pixoffsetx,pixoffsety,sizex,sizey)
	local xp,yp,col=0
	for xos=0,sizex*scale do
		for yos=0,sizey*scale do
			xp=xos/scale
			yp=yos/scale--(yos-40)/scale
			col=sget(pixoffsetx+xp,pixoffsety+yp)
			if(col!=0)pset(x+xos,y+yos,col)
		end
	end
end]]

function print_speed()
	local car=cars[1]
	print("pos: "..player.position.."/"..#cars,cam.x+2,cam.y+109,7)
	print("lap: "..car.lap.."/"..circuit.lap,cam.x+2,cam.y+118,7)
	print("spd: "..flr(car.speed*350/4.4),cam.x+42,cam.y+109,7)
	print("dam: ",cam.x+42,cam.y+118,7)
	player:draw(cam.x+60,cam.y+117)
	print(player.car_stamina,cam.x+64,cam.y+118,0)

	local chrono=ceil(time()-race.starttime)
	if((race.starttime>0)and(car.finish>0)) chrono=race.chrono
	print("time: "..chrono,cam.x+82,cam.y+109,7)

	--print(race.rival, cars[race.rival].x,cars[race.rival].y-10,7)
	if (race.rival) then
		print("rival", cars[race.rival].x-10,cars[race.rival].y-14,10)
		print("rival", cars[race.rival].x-10,cars[race.rival].y-13,7)
	end
end
-->8
-- car
-- distance
ia_dist_cp=14
plyr_dist_cp=40
max_dist_cp=126
-- speed
max_speed=4.4
acc=.1
brk=.2
nth=.06
rear=.4
-- speed variation
sv1=.05
sv2=.08
sv3=.1
-- ia
vstrong={a=1,r=.8}
strong={a=.94,r=.7}
normalp={a=.88,r=.6}
normal={a=.82,r=.5}
normalm={a=.76,r=.4}
weak={a=.7,r=.3}
vweak={a=.64,r=.2}

--[[function car:init(player)
	self.player=player
 if(self.model==0)then
 	-- hero
 	self.sosx=8
 	--self.sosy=8
 end
end]]

function make_car(isPlayer,x,y,col,hcol,name,level)
	car={
		player=isPlayer,
		helmetColor=hcol,
		name=name,
		cchkpnt=0,
		chkpntchanded=false, -- evaluate which way
		worst=false, -- which way ?
		DistToChkpnt=0,
		lap=0,finish=0,
		x=x,y=y, -- real coordinates
		celx=0,cely=0,
		iaLevel=level,
		--xos=0,yos=0, -- coordinates on tile
		angle=.75,speed=0,
		hbl=-3,hbt=-2,hbr=2,hbb=3, -- hitbox
		collision=false,
		arc=0,dx=0,dy=0,
		-- animations
		crash=0,
		rotation=.75, -- crash animation
		particles={},
		part={},
		sparking=false,
		tiresanim=0,
		-- spritesheet offset
		sosx=8,sosy=0, 
		sosw=8,sosh=8,
		col=col,-- couleur voiture
	}
	return car
end

------------
-- update --
------------
function car_update(c)
	if(c.player==true)then
		car_player_update(c)
		if(player.car_stamina<=0)then
			--fire
			add(c.particles,add_particle(c.x+rnd(8)-4,c.y+rnd(8)-4,0,-.5,2,-.03,30,fire_colors))
		elseif(player.car_stamina<15)then
			--smoke
			add(c.particles,add_particle(c.x+rnd(6)-3,c.y+rnd(6)-3,cos(c.angle+mid(.35,.65,rnd(.5)+.25)),-sin(c.angle+mid(.35,.65,rnd(.5)+.25)),1,.05,40,smoke_colors))
		end
	else
		car_ia_update(c)
	end

	if((rnd(1)>.96)and(c.speed>4))then
		for i=1,5 do
			add(c.particles,add_particle(c.x+rnd(4)-2,c.y+rnd(4)-2,cos(c.angle+mid(.35,.65,rnd(.5)+.25))*.1,-sin(c.angle+mid(.35,.65,rnd(.5)+.25))*.1,1,0,14,spark_colors))
		end
	end

	update_particles(c)

	-- ligne d'arrivee
	if(c.lap==circuit.lap)and(c.cchkpnt==0)and
		(c.x>circuit.startline.x0)and
		(c.x<circuit.startline.x1)and
		(c.y<=circuit.startline.y0)and
		(c.y>circuit.startline.y0-max_speed)
		then
			race.finish+=1
			c.finish=race.finish
			if(c.player) player.position=race.finish
	end
end

------------
--  draw  --
------------
function car_draw(c)
	palt(0, false)
	palt(14,true)
	mset(0,16,1+time()*c.speed*4%4)
	draw_tline(c.x,c.y,c.angle,0,16,1,c.col)
	--draw_rotation(x,y,c)
	palt()
	-- fx
	draw_particles(c)
	car_debug(c)	
end

function car_ia_update(c)
	local arc=car_getchckpnt(c)
	local diffangle=c.angle-arc
	if(diffangle<-.49)then c.angle-=.01
	elseif(diffangle<.01)then c.angle+=.01
	elseif(diffangle<.51)then c.angle-=.01
	else c.angle+=.01		
	end
	c.angle=abs(c.angle%1)
	c.rotation=c.angle
	-- speed
	local sv=car_speed_variation(c) 
	local action=circuit.chkpnts[c.cchkpnt+1].p
	if(action=="a")and(c.speed<max_speed)then
		c.speed+=(acc*c.iaLevel.a)
	elseif(action=="n")and(c.speed>3.2)then
		c.speed-=nth
	elseif(action=="b")and(c.speed>2)then
		c.speed-=brk
	end
	c.speed=max(.2,c.speed-sv)
	c.collision=false
	
	-- new coordinates
	c.x+=cos(c.angle)*c.speed
	c.y-=sin(c.angle)*c.speed
end

function car_player_update(c)
	car_getchckpnt(c)
	---- speed variation
	local speed=0
	local sv=car_speed_variation(c) 
	-- commands
	if(c.crash==0)and(player.car_stamina>0)then
		if (btn(0))then -- turn left
		 c.angle-=.01
		elseif (btn(1))then -- turn right
		 c.angle+=.01
		end
		-- speed
		if(btn(4)and c.speed<=max_speed)then
			--player.nokeys=false
			-- accell
			if(sv==0) c.speed=min(max_speed,c.speed+acc)
			c.speed-=sv
			if(c.speed<rear) c.speed=rear
		elseif btn(5)then
			--player.nokeys=false
			-- brake
			if(c.speed>brk)then
				c.speed-=(brk+sv)
			elseif(c.speed>0)then
				c.speed=0
			else
				c.speed=-rear
			end
		else
			player.nokeys=true
		end
	else
		player.nokeys=true
	end

	-- nokeys
	if(player.nokeys)then
		if(c.speed>nth)then
			c.speed=max(0,c.speed-(nth+sv))
		else
			c.speed=0
		end
		player.nokeys=false
	end

	-- other
	if (btn(2)) c.x,c.y=64,80

	
	-- circuit bounds
	if((c.x<=0)or(c.x>=circuit.realwidth)
		or(c.y<=0)or(c.y>=circuit.realheigh))then
		c.crash=1--atan2(cos(c.angle),sin(c.angle))
	end

	-- Damage
	if(c.finish==0)then
		-- ground
		if(player.car_stamina>0)and(c.speed>0)then
			if(sv==sv1)then player.car_stamina-=LightDamage
			elseif(sv==sv2)then player.car_stamina-=MediumDamage
			elseif(sv==sv3)then player.car_stamina-=HardDamage
			end
		end
		-- crash
		if(c.crash>0)then 
			c.angle+=.5
			c.speed=min(2,c.speed/2+1)
			c.crash=0
			player.car_stamina-=VHDamage
		end
		-- collisions
		if(c.collision)then 
			c.speed=c.speed/2
			c.collision=false
			player.car_stamina-=VHDamage
		end
	end

 	-- result
	c.angle=c.angle%1
	c.x+=cos(c.angle)*c.speed
	c.y-=sin(c.angle)*c.speed

	-- Position
	if(c.finish==0)then
		player.position=1
		for i=2,#cars do
			if(cars[i].lap>c.lap)then player.position+=1
			elseif(cars[i].lap==c.lap)and(cars[i].cchkpnt>c.cchkpnt)then player.position+=1
			elseif(cars[i].lap==c.lap)and(cars[i].cchkpnt==c.cchkpnt)and(cars[i].DistToChkpnt<c.DistToChkpnt)then player.position+=1
			end
		end
	end
end

function car_getchckpnt(c)
	local dx,dy,arc
	if(c.player==false and c.chkpntchanded and(rnd()>c.iaLevel.r)) c.worst=true 

	if(c.worst)and(circuit.chkpnts[c.cchkpnt+1].wp)then
		dx=circuit.chkpnts[c.cchkpnt+1].wp.x-c.x
		dy=circuit.chkpnts[c.cchkpnt+1].wp.y-c.y
	else
		dx=circuit.chkpnts[c.cchkpnt+1].op.x-c.x
		dy=circuit.chkpnts[c.cchkpnt+1].op.y-c.y
	end
	--distance
	car_chckpnt(c,dx,dy)
	-- angle
	arc=atan2(dx,-dy)
	return arc
end

-- manage car checkpoints
function car_chckpnt(c,dx,dy)
	local dist_limit_cp
	
	if c.player then dist_limit_cp=plyr_dist_cp
	else dist_limit_cp=ia_dist_cp
	end
	
	if(abs(dx)>max_dist_cp)or(abs(dy)>max_dist_cp)then
		c.DistToChkpnt=max_dist_cp
	else
		c.DistToChkpnt=sqrt(dx*dx+dy*dy)
	end
	
	if(c.DistToChkpnt<dist_limit_cp)then
		c.chkpntchanded=true
		c.worst=false
		c.cchkpnt+=1 
 	if(c.cchkpnt==1) c.lap+=1
 	if(c.cchkpnt>=#circuit.chkpnts) c.cchkpnt=0
	else
		c.chkpntchanded=false
	end
end

-- Manager collisions between cars
function car_collision()
	local c1, c2, c3, c4

	for i=1,#cars-1 do
		for j=i+1,#cars do
			c1=cars[i].y+cars[i].hbt<=cars[j].y+cars[j].hbb
			c2=cars[i].y+cars[i].hbb>=cars[j].y+cars[j].hbt
			c3=cars[i].x+cars[i].hbl<=cars[j].x+cars[j].hbr
			c4=cars[i].x+cars[i].hbr>=cars[j].x+cars[j].hbl
			if c1 and c2 and c3 and c4 
				and (not cars[i].collision)
				and (not cars[j].collision) then
				cars[i].collision=true
				cars[j].collision=true
			end
		end
	end
end

function car_speed_variation(c)
	local sum,nb=0,36--(c.hbr-c.hbl)+(c.hbb-c.hbt)+2
	local col
	--for i=c.hbl,c.hbr do
	 --for j=c.hbt,c.hbb do
	for i=-3,2 do
		for j=-2,3 do
			col=circuit:where_am_i(c,i,j)
	 	if((col==5)or(col==7)or(col==8)) sum+=1
	 end
	end 	

	local result=sum/nb
	if(result<.25)then
 		return sv3
	elseif(result<.5)then
 		return sv2
	elseif(result<.8)then
 		return sv1
	else
 		return 0
 	end 
end

function car_debug(c)
	if(debug_car)and(c.player)then
		local x,y,s=c.x,c.y,c.speed
		-- origins
		line(x-2,y,x+2,y,10)
		line(x,y-2,x,y+2,10)
		-- vector 
		line(x,y,x+cos(c.angle)*s*5,y-sin(c.angle)*s*5,7)
		circ(x+cos(c.angle)*s*5,y-sin(c.angle)*s*5,1,10)
	 -- bounding box
	 --rect(x-self.hbl,y-self.hbt,x+self.hbr,y+self.hbb,7)
		--  
		rectfill(cam.x+104,cam.y+64,cam.x+111,cam.y+71,12)
	 -- hbl=-3,hbt=-2,hbr=2,hbb=3, -- hitbox
		for i=-3,2 do
	 		for j=-2,3 do
	 			pset(cam.x+108+i,cam.y+67+j,circuit:where_am_i(c,i,j))
	 		end
		end 
		
		print("a:"..c.angle.." s:"..c.speed,cam.x+2,cam.y+1,7)
		print("x:"..c.x.." y:"..c.y,cam.x+2,cam.y+9,7)
		print("cam.x "..cam.x..", cam.y "..cam.y,cam.x+2,cam.y+16,7)
		print(c.cchkpnt.."-"..race.finish,cam.x+2,cam.y+30,7)	
	 --print("cel "..c.celx.."-"..c.cely.."-fget "..tostr(fget(mget(c.celx,c.cely))),cam.x+2,cam.y+30,7)	
	end	
end

-->8
-- circuit
circuit={
	model=0,
	x=0,y=0,-- on the spritesheet - px
	width=0,heigh=0,-- on the spritesheet - px
	realwifdth=0,realheigh=0, -- on screen - px
	chkpnts,
	startline,
	lap=3 -- nb de tour de la course
}
	
function circuit:init(m)
	self.model=m
	
 if(self.model==0)then
  self.x,self.y=0,32
  self.width,self.heigh=24,16
  self.realwidth,self.realheigh=960,640 -- realwidth = width* tile_width (5) * 8 pixels each
  self.chkpnts=circuit0
  self.startline=line_circuit0
 end
 if(self.model==1)then
  self.x,self.y=24,32
  self.width,self.heigh=24,16
  self.realwidth,self.realheigh=960,640 -- realwidth = width* tile_width (5) * 8 pixels each
  self.chkpnts=circuit0
  self.startline=line_circuit0
 end
 if(self.model==2)then -- ring
  self.x,self.y=0,48
  self.width,self.heigh=24,16
  self.realwidth,self.realheigh=960,640 -- realwidth = width* tile_width (5) * 8 pixels each
  self.chkpnts=circuit2
  self.startline=line_circuit2
 end
end

-- on circuit map
function circuit:where_am_i_on_map(x,y)
	local ssx,ssy=x/(8*tile_width),y/(8*tile_heigh)
	ssx+=self.x
	ssy+=self.y
	local col=sget(flr(ssx),flr(ssy))
	--print(ssx..", "..ssy..": "..col,cam.x+30,cam.y+40,7)
	return col
end

-- on the real circuit
function circuit:where_am_i(c,i,j)
	local x,y=c.x+i,c.y+j
	-- which segment on the map?
	local col=circuit:where_am_i_on_map(x,y)
	local xs,ys=x%(8*tile_width),y%(8*tile_heigh)
	local celx,cely
	local celw,celh
	-- which sprite on this segment?
	local found=false
	local k=1

	-- xs: position on the tile
	-- which tile ?
	repeat
	 	if(tiles[k].c==col)then
	  		celx,cely=tiles[k].x,tiles[k].y
			celw,celh=tiles[k].w,tiles[k].h
			found=true
	 	else
	  		k+=1
	 end
	until found==true
 	-- which subtile ?
 	local stx=flr(xs/8)
 	local sty=flr(ys/8)
	c.celx=celx+stx
	c.cely=cely+sty
	local sprnb=mget(c.celx,c.cely)
	-- how is the flag of the sprite ?
	if(fget(sprnb,0)) c.crash=1
	if(fget(sprnb,1)) c.crash=2
 	-- which color on this sprite?
 	return get_color(sprnb,flr(x%8),flr(y%8))
end

function circuit:draw()
 local sizex=self.x+self.width
 local sizey=self.y+self.heigh
 --print(sizex..", "..sizey,60,60,7)
 
 -- draw tiles
 for i=self.x,sizex do
 	for j=self.y,sizey do
		local col=sget(i,j)
		draw_tile(i-self.x,j-self.y,col)
	end
 end
 --
	if(debug_circuit)then 
 		foreach(self.chkpnts,drawchk)
 		line(self.startline.x0,self.startline.y0,self.startline.x1,self.startline.y1,8)
	end
end

function drawchk(t)
	print(t.i,t.op.x-1,t.op.y-2,8)--cam.x+2,cam.y+40,8)
	circ(t.op.x,t.op.y,4,8)
	if(t.wp)then
		print(t.i,t.wp.x-1,t.wp.y-2,0)--cam.x+2,cam.y+40,8)
		circ(t.wp.x,t.wp.y,4,0)
	end
end

----------------
-- checkpoint --
----------------

-- index,x,y,speed
line_circuit0={
	x0=70,y0=245,
	x1=130,y1=245
}

circuit0={
 {i=1,op={x=88,y=160},wp={x=80,y=164},p="a"},
 {i=2,op={x=112,y=110},wp=nil,p="n"},
 {i=3,op={x=210,y=92},wp={x=210,y=78},p="a"},
 {i=4,op={x=310,y=126},wp={x=310,y=146},p="n"},
 {i=5,op={x=430,y=110},wp={x=430,y=90},p="a"},
 {i=6,op={x=810,y=88},wp={x=810,y=98},p="a"},
 {i=7,op={x=852,y=115},wp=nil,p="b"}, 
 {i=8,op={x=870,y=200},wp=nil,p="a"}, 
 {i=9,op={x=842,y=280},wp=nil,p="a"}, 
 {i=10,op={x=760,y=306},wp=nil,p="n"}, 
 {i=11,op={x=710,y=316},wp=nil,p="n"},
 {i=12,op={x=700,y=368},wp=nil,p="b"},
 {i=13,op={x=818,y=380},wp={x=818,y=370},p="a"},
 {i=14,op={x=860,y=404},wp=nil,p="b"},
 {i=15,op={x=866,y=490},wp=nil,p="a"},
 {i=16,op={x=842,y=526},wp={x=842,y=546},p="b"},
 {i=17,op={x=374,y=544},wp={x=374,y=564},p="a"},
 {i=18,op={x=254,y=473},wp={x=254,y=453},p="a"},
 {i=19,op={x=150,y=454},wp=nil,p="a"},
 {i=20,op={x=114,y=440},wp={x=84,y=440},p="b"},
}

line_circuit2={
	x0=70,y0=325,
	x1=130,y1=325
}

circuit2={
 {i=1,op={x=112,y=240},wp=nil,p="a"},
 {i=2,op={x=240,y=114},wp=nil,p="a"},
 {i=3,op={x=520,y=100},wp={x=520,y=80},p="a"},
 {i=4,op={x=715,y=114},wp=nil,p="a"},
 {i=5,op={x=845,y=240},wp=nil,p="a"},
 {i=6,op={x=845,y=400},wp=nil,p="a"},
 {i=7,op={x=715,y=526},wp=nil,p="a"},
 {i=8,op={x=520,y=540},wp={x=520,y=560},p="a"},
 {i=9,op={x=240,y=526},wp=nil,p="a"},
}
--[[function checkpoint_init(array)
	checkpoint={
	 bckgrnd=(array.c==0),
	 lap=(array.c==7),
		apex={x=array.ax,y=array.ay},
		box={x=array.bx,y=array.by,w=array.bw,h=array.bh}
	} 
 return checkpoint
end 	

function checkpoint_draw(x,y,c)
	if(c.bckgrnd==false)then
		local osx=x*tile_width*8
		local osy=y*tile_heigh*8
		--print(osx..", "..osy,cam.x+30,cam.y+30,7)
		circfill(c.apex.x+osx,c.apex.y+osy,2,8)
		--rect(c.box.x+osx,c.box.y+osy,c.box.w,c.box.h,8)
	end	
end]]

-------------
--  tiles  --
-------------
tile_width=5
tile_heigh=5

tiles={
	{c=0,x=10,y=0,w=5,h=5},-- grass
	{c=1,x=0,y=0,w=5,h=5},-- verticaly
	{c=2,x=5,y=0,w=5,h=5},-- horizontaly
	{c=3,x=0,y=5,w=5,h=5},-- up left corner
	{c=4,x=5,y=5,w=5,h=5},-- up right croner
	{c=5,x=0,y=10,w=5,h=5},-- bottom left corner
	{c=6,x=5,y=10,w=5,h=5},-- bottom right corner
	{c=7,x=15,y=0,w=5,h=5},
	{c=8,x=10,y=5,w=5,h=5},-- slope down up
	{c=9,x=10,y=10,w=5,h=5},-- slope down bottom
	{c=10,x=15,y=5,w=5,h=5},-- slope down up
	{c=11,x=15,y=10,w=5,h=5},-- slope down bottom
	{c=12,x=20,y=15,w=5,h=5},-- border h
	{c=13,x=20,y=0,w=5,h=5},-- border h
	{c=14,x=20,y=5,w=5,h=5},-- border h
	{c=15,x=20,y=10,w=5,h=5},-- border h
}

function draw_tile(x,y,c)
	local found=false
	local	i=1

	repeat
	 if(tiles[i].c==c)then
	  celx,cely=tiles[i].x,tiles[i].y
		 celw,celh=tiles[i].w,tiles[i].h
		 found=true
	 else
	  i+=1
	 end
	until found==true

	map(celx,cely,x*celw*8,y*celh*8,celw,celh)
end
-->8
-- graphics

function draw_tline(x,y,
								sw_rot,mx,my,r,col)    
 local cs,ss= cos(sw_rot), -sin(sw_rot)
 local ssx,ssy= mx-0.3, my-0.3
 --ssx=-.3
 local cx,cy= mx+r/2, my+r/2    
 --cx=.5
 ssy-=cy
 ssx-=cx
 --ssx=-.8
 local sx=cs*ssx+cx
 local sy=-ss*ssx+cy
 local delta_px=-ssx*8
	-- color
 local ocol,ncol
 local xcol,ycol=16,7+col
 
 pal(4,sget(xcol,ycol))
 pal(15,sget(xcol+1,ycol))
  
 for py=y-delta_px,y+delta_px do
  tline(x-delta_px, py, 
  x+delta_px, py, 
  sx+ss*ssy, sy+cs*ssy, 
  cs/8, -ss/8)
		
		--[[for px=x-delta_px,x+delta_px do
			ocol=pget(px,py)
			if ocol==4 then
				ncol=sget(xcol,ycol)
			elseif ocol==15 then
				ncol=sget(xcol+1,ycol)
			elseif ocol==10 then
				ncol=10
			--elseif ocol==14 then -- tires
				--1 2 5 6
				--[[local i=xp%5
				local ct=0
				if(c.speed!=0)then	
					ct=sget(16+i+c.tiresanim,0)
				 pset(x+xo,y+yo,ct)
				elseif(col!=15)then
					pset(x+xo,y+yo,c.col)
			 end]]
			 --ncol=ocol	
			else
				ncol=ocol	
			end
			pset(px,py,ncol)
		end]]
		--print(px,cam.x+60,cam.y+60,7)
 
  ssy+=1/8
	end
	pal()
end

---------------
-- particles --
---------------
spark_colors={7}
smoke_colors={1,6,7}
fire_colors={1,10,9,8}

function add_particle(x,y,dx,dy,r,grow,ttl,col_table)
	local particle={
		x=x,
		y=y,
		dx=dx,
		dy=dy,
		r=r,
		grow=grow,
		t=ttl,
		ttl=ttl,
		col_table=col_table
	}
	
	return particle
end

function update_particles(c)
	for p in all(c.particles) do
		p.x+=p.dx
		p.y+=p.dy
		p.r+=p.grow
		if(p.t/p.ttl<1/#p.col_table)then
  			p.c=p.col_table[1]
		elseif(p.t/p.ttl<2/#p.col_table)then
  			p.c=p.col_table[2]
		elseif(p.t/p.ttl<3/#p.col_table)then
  			p.c=p.col_table[3]
		else
			p.c=p.col_table[4]
		end
		p.t-=.5
		if(p.t<0) del(c.particles,p)
	end
end

function draw_particles(c)
	for p in all(c.particles) do
		if(p.r<=1)then 
			pset(p.x,p.y,p.c)
		else
			fillp(0b1010010110100101.1)
			circfill(p.x,p.y,p.r,p.c)
			fillp()
		end
	end
end

---------------
---------------
---------------
function draw_rotation(x,y,c)
 local angle=-c.rotation
 local spritex,spritey=c.sosx,c.sosy
 local spritewidth,spriteheigh=c.sosw,c.sosh
	
	local ca,sa=cos(angle),sin(angle)
	local scale=1
	local midw=spritewidth/2
 local midh=spriteheigh/2

	local xp=0
	local yp=0
	for xo=-midw,midw-1 do
		for yo=-midh,midh-1 do
			xp=((xo*ca+yo*sa)+(4*scale))/scale
			yp=((-xo*sa+yo*ca)+(4*scale))/scale
			if((xp>=0)and(xp<8)
					and(yp>=0)and(yp<8))then
				col=sget(spritex+xp,spritey+yp)
				if(col==14)then -- tires
				 --1 2 5 6
				 local i=xp%5
				 local ct=0
				 if(c.speed!=0)	ct=sget(16+i+c.tiresanim,0)
				 pset(x+xo,y+yo,ct)
				elseif(col!=15)then
					pset(x+xo,y+yo,c.col)
			 end
			end
		end
	end
	
	c.tiresanim+=c.speed/10
	if(c.tiresanim>6) c.tiresanim=0
end

-- get the sprite_nb's color at x,y
-- -- 0..15
-- 16..31
function get_color(sprite_nb,x,y)
	local sx,sy=0,0
	
	sx=(sprite_nb%16)*8+x
	sy=flr(sprite_nb/16)*8+y
	--print(sprite_nb.."-"..x.."-"..y,cam.x+50,cam.y+30,7)	
	--print(sx.."-"..sy,cam.x+50,cam.y+40,7)	
	return sget(sx,sy)
end
-->8
-- player & cam

-- player
player={
	position=1, -- player position
	car_stamina=100, -- damage
	nokeys=true,
	rival=5 -- index of the rival
}

LightDamage=.1
MediumDamage=.2
HardDamage=.4
VHDamage=3

function player:draw(x,y)
	local xf=0
	rectfill(x-1,y-1,x+21,y+7,5)
	if(self.car_stamina>75)then xf=20
	elseif(self.car_stamina>50)then xf=15
	elseif(self.car_stamina>25)then xf=10
	elseif(self.car_stamina>0)then xf=5
	end
	rectfill(x,y,x+xf,y+6,7)
end

-- cam
cam={
	initx=64,inity=64,
	x=0,y=0,
	pov=16,povclip=16, -- decalage
}
	
function cam:update()
	local car=cars[1]
	--if(car.angle<.50) self.povclip=self.pov+clipping

	self.x=car.x-self.initx+cos(car.angle)*self.pov
	self.y=car.y-self.inity-sin(car.angle)*self.povclip
	--self.x=car.x-self.initx+sin(car.angle)*self.pov
	--self.y=car.y-self.inity+cos(car.angle)*self.povclip

	if(car.x<self.initx-cos(car.angle)*self.pov)then 
		self.x=0
	end
	if(car.x>circuit.realwidth-self.initx-cos(car.angle)*self.pov)then	
		self.x=circuit.realwidth-128
	end
	if(car.y<self.inity+sin(car.angle)*self.povclip)then 
		self.y=0
	end
	if(car.y>circuit.realheigh-self.inity+sin(car.angle)*self.povclip+clipping)then 
		self.y=circuit.realheigh-128+clipping
	end
	camera(self.x,self.y)
end

function cam:draw()
	local x,y=self.x,self.y
	if(debug==1)then
		line(x-3,y,x+3,y,10)
		line(x,y-3,x,y+3,10)
	end
end
-->8
-- game
game={
	si=1, --story index
	ss=1 --story sequence 1:sb, 2:race, 3:sa
}

function game:next()
	local gsi=game.si
	local gss=game.ss
	
	gss+=1
	
	if(gss==2)then
		race:init(races[story[gsi].race])
		_update=race:update()
		_draw=race:draw()
	end
end	

-- speech
charx=10
chary=20
speechx=40
speechy=20
speechsize=12

story={
	-- sb:speech index before the event, 
	-- c:circuit nb, r:rival nb, p: minimum finish place,
	-- saok:speech after if ok, iaok: index of the next event if ok
	-- sako:speech after if ko, iako: index of the next event if ko
	{sb=1,race=1,saok=3,iaok=1,sako=2,iako=1}, -- begin

}

speeches={
	"my pilot is injured.    would you   like to racefor me ?",
	"well, perhaps you should try another hobby",
	"hey, pretty good"
}

function drawinterlude()
	local index=1--game.si
	
	cls()
	sspr(56,0,16,16,charx,chary)
	sspr(40,0,16,16,charx+speechx+speechsize*4,chary,16,16,true,false)
	if (speech(index,speechx,speechy,7))then
		print("press a key",speechx,100,7)
		if(btn(4)or btn(5))then
			-- next race
			game:next()
		end
	end
end

function speech(index,x,y,col)
	local length=flr(t()*12)
	local tlength=#speeches[index]/speechsize
	local printed=false
	
	if(length>#speeches[index])then
	 length=#speeches[index]
	 printed=true
	end	 

	rect(x-2,y-6,x+(speechsize*4),y+(1+tlength)*8,col)
	for i=0,1+tlength do
 	local endsize=min(length,(i+1)*speechsize)
		print(sub(speeches[index],1+i*speechsize,endsize),x,y+i*8,col)
	end
	
	return printed
end



-->8
-- race
races={
	{c=2,r=nil,p=4,
		o1={110,262,4,1,"basile",weak},
		o2={92,270,8,2,"basile",weak},
		o3={110,278,9,3,"basile",vweak},
		o4={92,286,9,1,"basile",vweak},
		o5={110,294,8,1,"basile",vweak},
		o6={92,302,4,2,"basile",vweak},
		o7={110,310,4,3,"basile",vweak}
	}
}

race={
	circuit=c,--circuit number
	rival=r,--rival number
	place=p,--place
	countd=5,
	chrono=0,
	finish=0,
	starttime=0,
}

function race:init(r)
	self.circuit=r.c
	self.rival=r.r
	self.place=r.p
	
	circuit:init(r.c)
	add(cars,make_car(true,92,254,1,10,"moi",1))
	add(cars,make_car(false,r.o1[1],r.o1[2],r.o1[3],r.o1[4],r.o1[5],r.o1[6]))
	add(cars,make_car(false,92,270,3,10,"Georges",strong))
	add(cars,make_car(false,110,278,4,10,"Daniel",normalp))
 add(cars,make_car(false,92,286,5,10,"Lance",normal))
	add(cars,make_car(false,100,294,6,10,"Lance",normalm))
	add(cars,make_car(false,92,302,7,10,"Lance",weak))
	add(cars,make_car(false,100,310,8,10,"Lance",vweak))
end

function race:update()
	if(race.starttime>0)then
		-- cars
		for c in all(cars) do
			car_update(c)
		end
	
		car_collision()
	end

	-- cam
	--local povclip=cam.pov
	--if(car.angle<.50) povclip=cam.pov+clipping
	if(cars[1].finish==0) cam:update()
end

function race:draw()
	cls()
	clip(0,0,128,128-clipping)
	circuit:draw()
	
	for c in all(cars) do
		car_draw(c)
	end

	cam:draw()
	clip()
	print_speed()

	if(race.starttime==0) race:countdown()

	if(debug)then
		print("mem "..flr(stat(0)),cam.x+74,cam.y+1,7)
		print("cpu "..flr(stat(1)),cam.x+104,cam.y+1,7)
		print("cam.x "..cam.x..", cam.y "..cam.y,cam.x+2,cam.y+16,7)
	 --print(circuit.chkpnts[c.cchkpnt+1].x.."-"..circuit.chkpnts[c.cchkpnt+1].y.." - "..c.cchkpnt.." - "..c.arc,cam.x+2,cam.y+30,7)
	 
	 line(cam.x+60,cam.y+63,cam.x+66,cam.y+63,7)
	 line(cam.x+63,cam.y+60,cam.x+63,cam.y+66,7)
	end
end

function race:countdown()
	if(t()%2==0) self.countd-=1

	print(t(),cam.x+59,cam.y+20,10)

	print(self.countd,cam.x+59,cam.y+40,10)
	print(self.countd,cam.x+60,cam.y+39,10)
	print(self.countd,cam.x+61,cam.y+40,10)
	print(self.countd,cam.x+60,cam.y+41,10)
	print(self.countd,cam.x+60,cam.y+40,7)

	if(self.count==0)then
		self.starttime=t()
	end
end

---------------
-- opponent --
---------------
__gfx__
00000000e00ee00ee00ee00ee06ee06ee60ee60e0000777777770000000111111111100000000000000000000000000000000000000000000000000000000000
00000000ff0ee00fff0ee00fff6ee06fff0ee60f0007777777777000001d11111111100000000000000000000000000000000000000000000000000000000000
00700700ffe444efffe444efffe444efffe444ef007777777777770001d11d1ddd1dd00000000000000000000000000000000000000000000000000000000000
00077000ff44aa44ff44aa44ff44aa44ff44aa440777777777777770011dd1111111110000000000000000000000000000000000000000000000000000000000
00077000ff44aa44ff44aa44ff44aa44ff44aa44077777777777777001111ee5655ee11000000000000000000000000000000000000000000000000000000000
00700700ffe444efffe444efffe444efffe444ef07777177777777100011ee53ee35e50000000000000000000000000000000000000000000000000000000000
00000000ff0ee00fff0ee00fff6ee06fff0ee60f0777111c11c11c100055eee3ee3ee50000000000000000000000000000000000000000000000000000000000
00000000e00ee00ee00ee00ee06ee06ee60ee60e0777111111c16c10005e5eeeeeeee00000000000000000000000000000000000000000000000000000000000
0550000005600000e80000000000000000000000077771111c116c7000eeeeeeeeeee00000000000000000000000000000000000000000000000000000000000
06500650056005603b0000000000000000000000077777111c11c77000eeeee5565ee00000000000000000000000000000000000000000000000000000000000
880ee008880ee0081c000000000000000000000007777771c11c7770000eee565555e00000000000000000000000000000000000000000000000000000000000
88eeeee888eeeee89a000000000000000000000000777777777777700000eeeeeeeee00000000000000000000000000000000000000000000000000000000000
88eeeee888eeeee82d000000000000000000000000077777777777000001eeeeeeeee00000000000000000000000000000000000000000000000000000000000
880ee008880ee0087000000000000000000000000088887777777800001d1eeeeeee100000000000000000000000000000000000000000000000000000000000
0650065005600560b600000000000000000000000888888888888880001d11eeeee11d0000000000000000000000000000000000000000000000000000000000
05500000056000004c000000000000000000000008888888888888801111d1111111d11000000000000000000000000000000000000000000000000000000000
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
dddddddddddddddddddddddd00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000328000000032222222800000000000000000000000000000000000000000000000000000000000000000000000000000000000
0032222800a222222222240000109800000058000000980000000000000000000000000000000000000000000000000000000000000000000000000000000000
0010000922b000000000010000100980000009800000098000000000000000000000000000000000000000000000000000000000000000000000000000000000
00100000000000000000010000100098000000100000001000000000000000000000000000000000000000000000000000000000000000000000000000000000
0010eccccccccccf0000010000100009222222600000001000000000000000000000000000000000000000000000000000000000000000000000000000000000
0070e0000000000f0000010000100000000000000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000
0010e0000000000f0322260000700000000000000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000
0010e0000000000f0100000000100000000000000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000
0010eddddddddddf0522240000100000000000000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000100001000000000000000000ab000000000000000000000000000000000000000000000000000000000000000000000000000000000
00522280000000000000010000103222240000000000ab0000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000009800000000000001000010100005222222240ab00000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000922222222222226000052600000000000052b000000000000000000000000000000000000000000000000000000000000000000000000000000000000
cccccf00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000ff00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
dddddddddddddddddddddddd00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
f0000000000000000000000e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
f0000a22222222222280000e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
f000ab00000000000098000e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
f00ab000000000000009800e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
f0ab0000000000000000980e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
f0100000000000000000010e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
f0100000000000000000010e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
f0700000000000000000010e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
f0100000000000000000010e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
f0980000000000000000ab0e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
f009800000000000000ab00e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
f00098000000000000ab000e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
f00009222222222222b0000e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
f0000000000000000000000e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
cccccccccccccccccccccccc00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
755555555555555788778877555555555555555500000000833b333b3b333b370000000000000000000000000000000055555533000000000000000000000000
75555555555555575555555555555555555555550000000058333333333b33750000000000000000000000000000000070707433000000000000000000000000
85555555555555585555555555555555555555550000000055733b333b3338550000000000000000000000000000000007070433000000000000000000000000
855555555555555855555555555555555555555500000000555733333b3385550000000000000000000000000000000070707043000000000000000000000000
7555555555555557555555555555555555555555000000005555833b333755550000000000000000000000000000000055555543000000000000000000000000
75555555555555575555555555555555555555550000000055555833b37555550000000000000000000000000000000066666643000000000000000000000000
85555555555555585555555555555555555555550000000055555573385555550000000000000000000000000000000055555533000000000000000000000000
85555555555555585555555588778877555555550000000055555557855555550000000000000000000000000000000055555533000000000000000000000000
33b3337788333b335555555785555555577777757555555585555555555555570000000000000000000000000000000000000000000000000000000000000000
b3338855557733335555555555555555575555757555555538555555555555730000000000000000000000000000000000000000000000000000000000000000
3b3755555555833b5555555555555555555555558555555533755555555558330000000000000000000000000000000000000000000000000000000000000000
338555555555573355555555555555555555555587777777b33755555555833b0000000000000000000000000000000000000000000000000000000000000000
3755555555555583555555555555555555555555777777773333855555573b330000000000000000000000000000000000000000000000000000000000000000
37555555555555835555555555555555555555557555555533b338555573b3330000000000000000000000000000000000000000000000000000000000000000
8555555555555557555555555555555555555555855555553b33337558b333b30000000000000000000000000000000000000000000000000000000000000000
85555555555555575555555555555555555555558555555533b33b378333b3330000000000000000000000000000000000000000000000000000000000000000
55555555555555557555555555555558555555555555555755555555333b33330000000000000000000000000000000000000000000000000000000000000000
55555555555555557555555555555558555555555555555755555555b3333b3b0000000000000000000000000000000000000000000000000000000000000000
555555555555555538555555555555735555555555555558555555553b3333330000000000000000000000000000000000000000000000000000000000000000
555555555555555538555555555555737777777777777778555555553333b33b0000000000000000000000000000000000000000000000000000000000000000
5555555555555555337555555555583377777777777777775555555533b333330000000000000000000000000000000000000000000000000000000000000000
5555555555555555b33855555555733b5555555555555557555555553b333b330000000000000000000000000000000000000000000000000000000000000000
55555555555555553333775555883b335555555555555558555555553333333b0000000000000000000000000000000000000000000000000000000000000000
555555587555555533b33388773b33b3555555555555555855555555333b33330000000000000000000000000000000000000000000000000000000000000000
333b3333333b3333333f33f333553553388388330000000078888877000000000000000000000000000000000000000000000000000000000000000000000000
b3333b3bb333333bb3999b88b50050058008008b0000000078878877000000000000000000000000000000000000000000000000000000000000000000000000
3b33333366666666fb333f3336556556688688630000000078787877000000000000000000000000000000000000000000000000000000000000000000000000
3333b33b555555556633fcfb30560560086086030000000077888777000000000000000000000000000000000000000000000000000000000000000000000000
33b33333666666663fbee3dd36556056688608630000000078888877000000000000000000000000000000000000000000000000000000000000000000000000
3b333b333533353388f33b3335655665868866830000000078888877000000000000000000000000000000000000000000000000000000000000000000000000
3333333b3333b3333f993f3b30550550088088030000000077777777000000000000000000000000000000000000000000000000000000000000000000000000
333b33333b3333b3cc3b6663330030033003003300000000a9999a9a000000000000000000000000000000000000000000000000000000000000000000000000
00555555555005555555550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
05566666555005555555555000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
55655555555005555550055500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
56666666555005555550005500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
56555555555005555550005500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
56500000555005555550055500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
56555550555005555555555000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
55666650555005555555550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
05555565555005555555550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000565555005555555555000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
55555565555005555550555000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
66666665555005555550555000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
55555565555555555550055500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
55555655555555555550055500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
66666550055555505550055500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
55555500000550005550055500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__label__
88888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888
88888eeeeee888777777888eeeeee888eeeeee888eeeeee888eeeeee888eeeeee888888888888888888ff8ff8888228822888222822888888822888888228888
8888ee888ee88778877788ee888ee88ee888ee88ee8e8ee88ee888ee88ee8eeee88888888888888888ff888ff888222222888222822888882282888888222888
888eee8e8ee8777787778eeeee8ee8eeeee8ee8eee8e8ee8eee8eeee8eee8eeee88888e88888888888ff888ff888282282888222888888228882888888288888
888eee8e8ee8777787778eee888ee8eeee88ee8eee888ee8eee888ee8eee888ee8888eee8888888888ff888ff888222222888888222888228882888822288888
888eee8e8ee8777787778eee8eeee8eeeee8ee8eeeee8ee8eeeee8ee8eee8e8ee88888e88888888888ff888ff888822228888228222888882282888222288888
888eee888ee8777888778eee888ee8eee888ee8eeeee8ee8eee888ee8eee888ee888888888888888888ff8ff8888828828888228222888888822888222888888
888eeeeeeee8777777778eeeeeeee8eeeeeeee8eeeeeeee8eeeeeeee8eeeeeeee888888888888888888888888888888888888888888888888888888888888888
1616161116111777111111c111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1666161116111111111111c111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1616161116111777111111c111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
161611661166111111c11ccc11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
166616661616111111111ccc11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
16161616161617771111111c11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
166116611661111111111ccc11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
161616161616177711111c1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
166616161616111111c11ccc11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
166116661616111111111ccc1c111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
161611611616177711111c1c1c111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
161611611666111111111c1c1ccc1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
161611611616177711111c1c1c1c1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
161611611616111111c11ccc1ccc1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1666166616661666111111111c1c1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1616161116161616177711111c1c1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1661166116661661111111111ccc1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
161616111616161617771111111c1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1616166616161616111111c1111c1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111dd1ddd1ddd1ddd1dd111111d1d1ddd1ddd1ddd1ddd1ddd1ddd11dd1dd111111111111111111111111111111111111111111111111111111111
1111111111111d111d1d1d111d111d1d11111d1d1d1d1d1d11d11d1d11d111d11d1d1d1d11111111111111111111111111111111111111111111111111111111
1ddd1ddd11111ddd1ddd1dd11dd11d1d11111d1d1ddd1dd111d11ddd11d111d11d1d1d1d11111111111111111111111111111111111111111111111111111111
111111111111111d1d111d111d111d1d11111ddd1d1d1d1d11d11d1d11d111d11d1d1d1d11111111111111111111111111111111111111111111111111111111
1111111111111dd11d111ddd1ddd1ddd111111d11d1d1d1d1ddd1d1d11d11ddd1dd11d1d11111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
116616161661111111111ccc1ccc1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
161116161161177711111c1c1c111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
166616161161111111111c1c1ccc1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
111616661161177711111c1c111c1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
166111611666111111c11ccc1ccc1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
116616161666111111111ccc1ccc1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
161116161116177711111c1c1c1c1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
166616161666111111111c1c1ccc1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
111616661611177711111c1c1c1c1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
166111611666111111c11ccc1ccc1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
116616161666111111111cc111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1611161611161777111111c111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1666161611661111111111c111111111111111111111111111111111111111111111111111111111111111111111111111111111111117111111111111111111
1116166611161777111111c111111111111111111111111111111111111111111111111111111111111111111111111111111111111117711111111111111111
166111611666111111c11ccc11111111111111111111111111111111111111111111111111111111111111111111111111111111111117771111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111117777111111111111111
1111111111111ddd1ddd111111111111111111111111111111111111111111111111111111111111111111111111111111111111111117711111111111111111
11111111111111d11d1d111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111171111111111111111
1ddd1ddd111111d11ddd111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111d11d1d111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1111111111111ddd1d1d111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
aaaaaaaaaaaaaaaaaaaaaaaaa1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
aa66a666a666aa66a66aaa66a1111cc1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
a6aaaa6aa6a6a6a6a6a6a6aaa77711c1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
a666aa6aa66aa6a6a6a6a6aaa11111c1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
aaa6aa6aa6a6a6a6a6a6a6a6a77711c1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
a66aaa6aa6a6a66aa6a6a666a1111ccc111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
166111661666166616661611111111111ccc11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
161616161616166616161611177711111c1c11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
161616161661161616661611111111111ccc11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
16161616161616161616161117771111111c11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
161616611616161616161666111111c1111c11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1616166616661616111111111ccc1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1616161116161616177711111c1c1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1616166116661661111111111ccc1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1666161116161616177711111c1c1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1666166616161616111111c11ccc1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
111111111dd11dd11ddd1d1d1dd111dd1ddd1ddd11dd1dd1111111dd1ddd1ddd11111ddd1dd11ddd1ddd11d11ddd1d111ddd1d1d1ddd1ddd11d1111111111111
111111111d111d111d111d1d1d1d1d1111d111d11d1d1d1d11111d111d1d1d1d11d111d11d1d11d111d11d111d1d1d111d1d1d1d1d111d1d111d111111111111
1ddd1ddd1d111d111dd11d1d1d1d1d1111d111d11d1d1d1d11111d111ddd1dd1111111d11d1d11d111d11d111ddd1d111ddd1ddd1dd11dd1111d111111111111
111111111d111d111d111d1d1d1d1d1111d111d11d1d1d1d11111d111d1d1d1d11d111d11d1d11d111d11d111d111d111d1d111d1d111d1d111d111111111111
111111111dd11dd11d1111dd1d1d11dd11d11ddd1dd11d1d111111dd1d1d1d1d11111ddd1d1d1ddd11d111d11d111ddd1d1d1ddd1ddd1d1d11d1111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
111111dd1ddd1d111ddd11111ddd1d111ddd1d1d1ddd1ddd11111ddd1d111ddd1d1d1ddd1ddd1111111111111111111111111111111111111111111111111111
11111d111d111d111d1111111d1d1d111d1d1d1d1d111d1d1ddd1d1d1d111d1d1d1d1d111d1d1111111111111111111111111111111111111111111111111111
11111ddd1dd11d111dd111111ddd1d111ddd1ddd1dd11dd111111ddd1d111ddd1ddd1dd11dd11111111111111111111111111111111111111111111111111111
1111111d1d111d111d1111111d111d111d1d111d1d111d1d1ddd1d111d111d1d111d1d111d1d1111111111111111111111111111111111111111111111111111
11111dd11ddd1ddd1d1111d11d111ddd1d1d1ddd1ddd1d1d11111d111ddd1d1d1ddd1ddd1d1d1111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111ddd1ddd11d111dd1ddd1d111ddd11111ddd11dd1dd11ddd1d11111111111ddd11d11ddd1d1d1ddd1dd11111111111111111111111111111111111111111
111111d11d111d111d111d111d111d1111111ddd1d1d1d1d1d111d111ddd1ddd1d1d111d11d11d1d1d111d1d1111111111111111111111111111111111111111
111111d11dd11d111ddd1dd11d111dd111111d1d1d1d1d1d1dd11d11111111111d1d111d11d11ddd1dd11d1d1111111111111111111111111111111111111111
111111d11d111d11111d1d111d111d1111111d1d1d1d1d1d1d111d111ddd1ddd1d1d111d11d11d1d1d111d1d1111111111111111111111111111111111111111
11111ddd1d1111d11dd11ddd1ddd1d1111d11d1d1dd11ddd1ddd1ddd111111111ddd11d111d11d1d1ddd1d1d1111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
111111111111111111111d1d1ddd1ddd11dd11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
111111111111111111111d1d1d111d1d1d1d11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
111111111ddd1ddd11111ddd1dd11dd11d1d11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
111111111111111111111d1d1d111d1d1d1d11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
111111111111111111111d1d1ddd1d1d1dd111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1111111111dd1ddd1d111ddd111111dd11dd11dd1d1d11111ddd1111111111111111111111111111111111111111111111111111111111111111111111111111
111111111d111d111d111d1111111d111d1d1d111d1d1ddd1d1d1111111111111111111111111111111111111111111111111111111111111111111111111111
111111111ddd1dd11d111dd111111ddd1d1d1ddd11d111111ddd1111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111d1d111d111d111111111d1d1d111d1d1d1ddd1d1d1111111111111111111111111111111111111111111111111111111111111111111111111111
111111111dd11ddd1ddd1d1111d11dd11dd11dd11d1d11111ddd1111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
88888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888
82888222822882228888822882228882822282828222888888888888888888888888888888888888888888888228888882228822828282228228882288866688
82888828828282888888882888828828888282828882888888888888888888888888888888888888888888888828888888288282828282888282828888888888
82888828828282288888882888828828882282228222888888888888888888888888888888888888888888888828888888288282822882288282822288822288
82888828828282888888882888828828888288828288888888888888888888888888888888888888888888888828888888288282828282888282888288888888
82228222828282228888822288828288822288828222888888888888888888888888888888888888888888888222888888288228828282228282822888822288
88888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888

__gff__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001000102000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
80848484818282828282b0b0b0b0b095a4a4a4a5b2b2b2b2b200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
80848484818484848484b0b0b0b0b08094848481b2b2b2b2b200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
80848484818484848484b0b0b0b0b08084849481b2b2b2b2b200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
80848484818484848484b0b0b0b0b08094848481b2b2b2b2b200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
80848484818383838383b0b0b0b0b08084849481b1b1b1b1b100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
9082828282828282829186a7b0b0b0b0b0b0a787b4b3b3b3b300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
808484848484848484818486a7b0b0b0b0a787a6b4b4b3b3b300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
80848484848484848481848486a7b0b0a7878484b4b4b0b3b300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
8084848484848484848184848486a7a787848484b4b4b3b3b300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
80848484a0a184848481a6848484868784848484b4b3b3b3b300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
8084848492938484848196a6a6a6a6a6a6a6a697b3b3b3b3b400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
80848484848484848481a796a6a6a6a6a6a697a7b3b3b3b4b400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
80848484848484848481b0a796a6a6a6a697a7b0b3b3b0b4b400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
80848484848484848481b0b0a796a6a697a7b0b0b3b3b3b4b400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
a28383838383838383a3b0b0b0a79697a7b0b0b0b3b3b3b3b400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000b3b3b3b3b300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0100000000000000000000000000000000000000b3b3b3b3b300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000b1b1b1b1b100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000b0b0b0b0b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000b0b0b0b0b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
