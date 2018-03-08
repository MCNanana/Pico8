pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
timer=0 -- timer
debug=0
level="title"
-- score
score=0
missnb=0
miss={}
c_missclock=20
c_draw_score=100

camx,camy=0,0
uborder=10
bborder=6
palarray={}
-- graphic elements
background={} -- stage backgrounds
expl={} -- explosions
enemies={} -- enemies
hero={} -- hero's ship
-- flags
gameover=false -- affiche le gameover
boss=false -- vs boss ?
boss_done_clock=0 -- when is the boss defeated ?
starting=false -- print go
warning=false -- print warning
-- animation
shaking={2,1,-3,-3,1,2}
shakeindex=1
fadeclock=0
c_fade=40
--palette
opal    ={[0]=0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15}
enemypal={[0]=0,1,2,3,2,0,5,6,2,8,9,3,1,1,2,14}
dpal=    {[0]=0,0,1,1,2,1,5,6,2,4,9,3,1,1,2,5}
derpal={0,1,1,2,1,13,6,4,4,9,3,13,1,13,14}
--starfield
str={}
strc={1,2,9,10}
--rotation
--tr,scale,angle=0,1,1

----------
-- init --
function _init()
	make_hero()
 --_update=update_title
	--_draw=draw_title
	_update=update_game
	_draw=draw_game
	level="l1"
	evtindex=11
	timer=2450--1270--1999--800
	boss_done_clock=2450--;boss=true
	debug=1

	if(level=="title")then
	 for i=0,100 do
		 str[i]={}
		 str[i].x=rnd(128)
		 str[i].y=rnd(128)
		 str[i].s=rnd(5)
		 str[i].c=strc[flr(str[i].s)]
		 str[i].s/=5
	 end
 end
end

------------
-- update --
function update_game()
	if(debug==1)or(gameover==false)then
	 timer+=1
	 if(boss==false)score+=.1
	
	 update_hero()
	
	 foreach(enemies,update_enemies)
	
	 if(level=="il1")then	update_intro_lvl1()
	 elseif(level=="l1")then update_lvl1()
	 elseif(level=="l2")then update_lvl2()
	 end
	
	-- resolution tir
	foreach(enemies,function(e)
		--cas des zoom ici
		if(e.status==1)then
			-- hero-enemy
			if intersection(hero,e) then
			 gameover=true
			else
				-- hero.m-enemy
				foreach(hero.missiles,function(m) 
					if intersection(m,e) then
						del(hero.missiles,m)
						e.hit=1
					end
				end)
				-- hero-enemy.missile
				foreach(e.missiles,function(em)
					if intersection(hero,em) then
			 		gameover=true
					end
				end)
			end	
		end
	end)
	
  foreach(expl,update_expl)
 end
end

----------
-- draw --
function draw_game()
	cls()
	pal()
	
	-- niveau
	if(level=="il1")then	draw_intro_lvl1()
	elseif(level=="l1")then draw_lvl1()
	elseif(level=="l2")then draw_lvl2()
	end

	-- hero
	draw_hero()
	foreach(miss,draw_missiles)
	-- ennemies
	pal()
	foreach(enemies,draw_enemies)	
	-- explosions
	pal()
	foreach(expl,draw_expl)
	-- border
	rectfill(camx,0,camx+127,uborder,5)
	--spr(75,camx,camy)
	--spr(77,camx+120,camy)
	rectfill(camx,128-bborder,camx+127,127,5)
	-- printing
	print("score "..flr(score),camx+4,camy+3,7)
	print("missed "..missnb,camx+44,camy+3,7)
	foreach(miss,function(m)
		if(m.clock>0)then
		 print("-10",camx+34,camy+1+c_missclock-m.clock)
		 print("oh no!",camx+m.x,camy+m.y)
   m.clock-=1
  else
   del(miss,m)
  end 	
	end)	
	if(gameover)then print_swap("go",50,60)
 else
 	if(starting)	print_swap("s",55,60)
 	if(warning)	print_swap("w",45,60)
 	if(boss_done_clock>0)and(timer-boss_done_clock>c_draw_score)then
 	 draw_score()
  end 
 end 
	if(boss==true)then
	 print("boss ",camx+84,camy+3,7)
 	draw_stamina(camx+104,camy+4,bosslife)
	end

	-- debug
	if(debug==1)then
	 print("mem "..stat(0),camx+2,122,7)
	 print("cpu "..stat(1),camx+80,122,7)
		print(timer,2,13,7)
		print(evtindex,2,25,7)
		--print(bborder..", "..bborder-8,2,19)
		--[[foreach(enemies,function(e)
		 if(#e.missiles>0)then
		  print(#e.missiles,camx+2,19,7)
		  print(e.life,camx+2,25,7)
		 end
		end)]]
		--print("hero.x "..hero.x.."- hero.y "..hero.y,2,25,7)
	end
end

---------------
--   score   --
---------------
function manage_score(e)
 if(e.t==10)and(e.life==0)then
  score+=100
 else
  newmiss={}
  newmiss.x=e.x+10
  newmiss.y=e.y
  newmiss.clock=c_missclock
  add(miss,newmiss)
  missnb+=1
  score-=10
  if(score<0) score=0
 end 
end

function	draw_score()
 if(btn(4)) fadeout()

	local lvl
	fillp(23130.5)
 rectfill(24,30,104,104,6)
 fillp()
 if(level=="l1")then
  lvl="level 1"
 end
 print(lvl.." completed",29,49,0)
 print(lvl.." completed",30,50,7)
 print("score "..flr(score),39,69,0)
 print("score "..flr(score),40,70,7)
 print("aliens defeated "..(lvlenemynumber-missnb),29,79,0)
 print("aliens defeated "..(lvlenemynumber-missnb),30,80,7)
 spr(110,20,30)
 spr(111,101,30)
 spr(109,20,100)
 spr(125,101,100)
 sspr(112,56,8,4,28,30,73,4)
 sspr(112,56,8,4,28,104,73,4)
 sspr(120,56,4,8,20,38,4,62)
 sspr(120,56,4,8,105,38,4,62)
 sspr(112,60,8,4,28,110,73,4)
end

---------------
-- starfield --
function draw_starfield()
	foreach(str,
		function(v)
				pset(v.x,v.y,v.c)
			v.x-=v.s
			if(v.x<0) then
				v.x+=128
				v.y=rnd(128)
			end
		end)
end

----------------
--    title   --
----------------
function update_title()
 if(btn(4))then
  --_update=update_intro_lvl1
  --_draw=draw_intro_lvl1
  --_update=update_game
  --_draw=draw_game
	 --level="l1"--"il1"
	 fadeclock=timer
	 --timer=0
	end 
end

--timerts=0
function draw_title()
 timer+=.6
 if(fadeclock>0)then
  fadeout()
  --_update=update_intro_lvl1
  --_draw=draw_intro_lvl1
  _update=update_game
  _draw=draw_game
	 level="l1"--"il1"
	 timer=0
 else
  cls()
 draw_starfield()
	index=flr(timer%48)
	for j=0,15 do
		if(index+j>47)then c1=0;c2=0
		else
		 c1=sget(index+j,44)
		 c2=sget(index+j,40)
		end 
		for i=0,39 do
			c=sget(i,48+j)
			if((c==7)and(c1!=0))then
				pset(50+i,40+j,c1)
			elseif((c==8)and(c2!=0))then
				pset(50+i,40+j,c2)
			end
  end
 end
	print("made with love by mcnanana",camx+15,camy+80,6)
	print("press a button",camx+40,camy+90,6) 	
end
end

-----------
-- tools --
-----------
function intersection(a,b)
	return ((a.x<b.x+b.oswidth+b.width)and 
   (a.x+a.oswidth+a.width>b.x)and
   (a.y<b.y+b.osheight+b.height)and
   (a.height+a.osheight+a.y>b.y))
	--[[return ((a.x<b.x+b.width)and 
   (a.x+a.width>b.x)and
   (a.y<b.y+b.height)and
   (a.height+a.y>b.y))]]
end

-----------
-- camera --
function shake_camera()
	camx+=shaking[shakeindex]
	shakeindex+=1
	camy+=shaking[shakeindex]
	shakeindex+=1
	if(shakeindex==7) shakeindex=1
end

function reset_camera()
 camx=0
 camy=0
end

function print_number(n,x,y)
 n1=flr((n/10)%10)
 n2=n%10
 spr(86+n1,x,y)
 spr(86+n2,x+8,y)
end

function print_swap(t,x,y)
	if(t=="w")then
	 sx=0;sy=32;c2i=42;isize=39
	elseif(t=="s")then
	 sx=72;sy=32;c2i=42;isize=15
	elseif(t=="go")then
	 sx=40;sy=32;c2i=46;isize=31
	end
	index=timer%40--flr(t)%128
	for j=0,7 do
		c1=sget(index+j,44)
		c2=sget(index+j,c2i)
		for i=0,isize do
			c=sget(sx+i,sy+j)
			if((c==7)and(c1!=0))then
				pset(x+i,y+j,c1)
			elseif((c==8)and(c2!=0))then
				pset(x+i,y+j,c2)
			end
  end
 end
 --map(5,1,45,60,5,1)
end

function fadein()
	for i=0,15 do
		pal(i,opal[i],1)
	end
end

function fadeout()
 for i=1,c_fade do
  for j=1,15 do
   col=j
   for k=1,(i/4+(j%2))do
    col=dpal[col]
   end
   pal(j,col,1)
  end
  flip()
 end
end

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
end

function draw_zoom(pixoffsetx,pixoffsety)
	local x=0
	local y=0
	local xp=0
	local yp=0
	tr+=0.001
	scale=cos(tr*3)*8+1
--	if(scale==1)
	for x=0,64 do
		for y=40,104 do
			xp=x/scale
			yp=(y-40)/scale
			if((xp>=0)and(xp<8)and(yp>=0)and(yp<8))then
				pset(x,y,sget(pixoffsetx+xp,pixoffsety+yp))
			end
		end
	end
end

function draw_rotation(x,y,angle,pixoffsetx,pixoffsety)
	--angle,tr=0,0
	ca,sa=cos(angle),sin(angle)
	--tr+=.001
	scale=1

	local xp=0
	local yp=0
	for xo=-4,7 do
		for yo=-4,7 do
			xp=((xo*ca+yo*sa)+(4*scale))/scale
			yp=((-xo*sa+yo*ca)+(4*scale))/scale
			if((xp>=0)and(xp<8)
					and(yp>=0)and(yp<8))then
				col=sget(pixoffsetx+xp,pixoffsety+yp)
				if(col!=0)	pset(x+xo,y+yo,col)
			end
		end
	end
end

function print_cube(xoffset,yoffset,x,y)
	if(x<0)then x=0;xoffset+=1
	else x-=t
	end
	print(x..", "..xoffset,40,10,7)
	-- 0,80
	for i=xoffset,xoffset+80 do
		for j=yoffset,yoffset+7 do
			if(sget(i,j)==3)then
 			spr(179,x+((i-xoffset)*8),y+((j-yoffset)*8))
 		else	
 			spr(176,x+((i-xoffset)*8),y+((j-yoffset)*8))
 		end
		end	
	end 
end
-->8
------------------------------
-- lvl -----------------------
------------------------------
evtlevel1={
										1,-- init
										100,280,460,640,-- wave4
										960,-- expl(6)
										1280, -- wave5
										1480, -- wave6()
										1910, -- wave7
										2240 --(10)
										}
evtindex=1
c_evtexpl=6	
c_evtboss=10
lvlenemynumber=0
									
-- level 1 --
function init_lvl1(step)
	if(step==1)then -- init
	 starting=true
	 lvlenemynumber=28
		background={
								-- clouds
								{x=11,y=60,velx=0.6,t=0},
								{x=70,y=20,velx=0.6,t=0},
								{x=40,y=40,velx=1,t=1},
								{x=120,y=70,velx=1,t=1},
								{x=26,y=30,velx=1.3,t=2},
								{x=81,y=94,velx=1.3,t=2},
								{x=102,y=75,velx=1.8,t=3},
								-- buildings
								{x=4,y=108,velx=2.2,t=6},			
								{x=68,y=108,velx=2.2,t=6},
								{x=132,y=108,velx=2.2,t=6},
								{x=0,y=114,velx=2.2,t=4},			
								{x=64,y=114,velx=2.2,t=4},
								{x=128,y=114,velx=2.2,t=4},
							}
		ss={
								x=0,y=0,
								xssanim=0,yssanim=0,
								xvanim=0,yvanim=0
							}					
	elseif(step==2)then -- wave 1
		starting=false
		add(enemies,make_enemies(1,128,70))
	elseif(step==3)then -- wave 2
		add(enemies,make_enemies(1,127,40))
		add(enemies,make_enemies(1,140,50))
		add(enemies,make_enemies(1,153,30))
	elseif(step==4)then -- wave 3
		add(enemies,make_enemies(1,127,90))
		add(enemies,make_enemies(1,140,100))
		add(enemies,make_enemies(1,153,80))
	elseif(step==5)then -- wave 4
		add(enemies,make_enemies(1,127,65))
		add(enemies,make_enemies(1,140,95))
		add(enemies,make_enemies(1,153,35))
	elseif(step==7)then -- wave 5
		add(enemies,make_enemies(1,130,50))
		add(enemies,make_enemies(1,142,30))
		add(enemies,make_enemies(1,154,45))
		add(enemies,make_enemies(1,166,60))
		add(enemies,make_enemies(1,178,75))
		add(enemies,make_enemies(1,190,90))
		add(enemies,make_enemies(1,202,110))
	elseif(step==8)then -- wave 6
 	add(enemies,make_enemies(2,100,40))
 	add(enemies,make_enemies(2,120,40))
 	add(enemies,make_enemies(2,140,40))
 	add(enemies,make_enemies(2,160,40))
 	add(enemies,make_enemies(2,180,40))
 	add(enemies,make_enemies(2,200,40))
	elseif(step==9)then -- wave 7
		add(enemies,make_enemies(3,148,70))
		add(enemies,make_enemies(1,130,60))
		add(enemies,make_enemies(1,130,75))
		add(enemies,make_enemies(1,130,90))
	elseif(step==10)then
 	-- boss buildings
		add(background,{x=160,y=106,velx=2.2,t=10})
  e=make_enemies(10,130,106,10,1)
 	e.anim_begin=timer
 	e.status=0
 	add(enemies,e)
 	boss=true
 	bosslife=e.life
	end		
end

function update_lvl1()
	if(timer==evtlevel1[evtindex])then 
		init_lvl1(evtindex)
		evtindex+=1
	elseif(timer==evtlevel1[c_evtexpl]+190)then
	 foreach(background,function(b)
   if(b.t==4)then
    b.t=5
    reset_camera()
   end	
   if(b.t==6) del(background,b)	 
	 end)	
	elseif(timer>evtlevel1[9]-100)then
	 foreach(enemies,function(e)
	  if((e.t==2)and(e.y<50))then
	   e.animation=2
    e.status=1	 
   end	 
	 end)
	end

	foreach(background,function(b)
		if(b.t==3)then
			if(b.x<-23) b.x=127
		elseif(b.t==2)then
		 if(b.x<-15) b.x=127
		elseif(b.t>3)then
		 if(b.x<-64) b.x=127
		else
			if(b.x<-7) b.x=127
		end	
		if(boss==true)then
   if(b.velx<0.12)then
    b.velx=0
   else
 			b.velx-=b.velx*0.03
   end  
		end
		b.x-=b.velx
	end)
 --foreach(smoke,update_smoke)
 --end	
end

function get_boss_background(e)
	foreach(background,function(b)
		if(b.t==10)then
 		e.x=b.x+4
 		e.y=b.y-4
 		return
		end 
 end)
end

function draw_bosslvl1_animation(e)
	diff=timer-e.anim_begin
	if(diff<150)then
		foreach(background,function(b)
			if(b.t==10)then
 			e.x=b.x+3
 			e.y=b.y-8
 			pal(8,5)
 			return
			end 
 	end)
 elseif(diff<200)then
  pal(8,8+timer%8)
 else
  e.y-=.2
  if(e.y<80)then
   e.animation=0
   e.status=1
  end 
 end	
end

function draw_lvl1()
	cls(1)
	pal()
	--
	fillp(0b1111000011110000.1)
	rectfill(0,90,127,127,12)
	fillp()
 -- starship animation
 if(ss!=nil)then
  if(timer<evtlevel1[c_evtexpl]+200)then
   if(timer<evtlevel1[c_evtexpl])then
    ss[1]=100+(timer/100)
	   ss[2]=86
	   ss[3]=0
	   ss[4]=flr(cos(timer/150)*2)
	  else -- leave
	   ss[3]+=.5
	   ss[4]+=.2
	  end 
	  -- draw ss
	  spr(11,ss[1]-8,ss[2]+ss[4])
		 if(timer%10<5)pal(9,10)
 	 spr(12,ss[1],ss[2]+ss[4])
		 pal()
	 end	
  if(timer<evtlevel1[c_evtexpl])then
	 -- launching ships	
		 if(timer%110==1)then
	 	 rad=3
	 	 ss[5]=0
	 	 ss[6]=ss[4]+2
		 end
		 sspr(88,8,2,3,ss[1]+ss[5],ss[2]+ss[6]+4)
		 fillp(0b0101101001011010.1)
		 circfill(ss[1]+ss[5],ss[2]+ss[6]+4,rad,6)
		 fillp()
	  ss[5]+=.3;ss[6]+=.1;rad-=.1
	 elseif(timer==evtlevel1[c_evtexpl])then
	  rad=6;ss[5]=-6;ss[6]=ss[4]-5
	 elseif(timer<evtlevel1[c_evtexpl]+95)then
	  -- missile
	  fillp(0b0101101001011010.1)
	  if(timer%20>10) pal(6,7)
	  circfill(ss[1]+ss[5]+4,ss[2]+ss[6]+8,rad,6)
	  fillp()
	  if(timer%20<10) pal(14,15)
	  sprite_zoom(ss[1]+ss[5],ss[2]+ss[6]+4,(timer-evtlevel1[c_evtexpl])/40,88,12,4,4)
   --sspr(88,12,4,4,x+xvanim,y+yvanim+4)
	  pal()
	  fillp(0b0101101001011010.1)
	  circfill(ss[1],ss[2]+4,rad,6)
	  fillp()
	  ss[5]-=.3;ss[6]-=.4;rad-=.04
	 end
	end
	-- background
	foreach(background,function(b)
		if(b.t==3) then
			map(0,1,b.x,b.y,3,2)
		elseif(b.t==2)then
			map(3,1,b.x,b.y,2,1)
		elseif(b.t==4)then
			map(3,2,b.x,b.y,9,1)
		elseif(b.t==5)then
			map(3,3,b.x,b.y,9,1)
		elseif(b.t==6)then
			map(3,6,b.x,b.y,9,1)
		elseif(b.t==10)then
			map(0,3,b.x,b.y,2,2)
		else
			spr(133+b.t,b.x,b.y)
		end
	end)
	--scripts
	if((timer>(evtlevel1[c_evtexpl]+95))
		and(timer<evtlevel1[c_evtexpl]+220))then
		if(timer%5==0)then
			pal(7,10)
			shake_camera()
		end	
		circfill(60,80,timer-860,7)
		make_expl(10+rnd(110),30+rnd(80))
		pal()
	elseif((timer>evtlevel1[c_evtboss])and(timer<evtlevel1[c_evtboss]+100))then
		--boss
		warning=true
	elseif(timer>evtlevel1[c_evtboss]+100)then
	 warning=false
	end
end

-- intro_lvl --
function update_intro_lvl1()
	timer+=1
	
	if(timer<30)then
	 hero.x=10
	else
	 camx+=1
	end
	hero.y=44
	camera(camx,camy)
	--[[			if(b.x<-23) b.x=127

	if(t>160)then
 	hero.x+=8
 	if(t%4==0) add(explosions,make_expl(290-rnd(14),80-rnd(8),10+rnd(4)-3))
 elseif(t>120)then
  camx+=4
  hero.x+=3.9
 elseif(t>90)then
  camx+=2
  hero.x+=2
	elseif(t>50)then
  camx+=1
  hero.x+=1
	end]]
end

function draw_intro_lvl1()
	local x
	cls()
	print(camx,camx+50,20,7)
	for i=0,136,8 do
  if(i+8<camx%128)then
  	x=i+(128*(flr(camx/128)+1))
  else
   x=i+(128*(flr(camx/128)))
  end
	 spr(32,x,50)
	end
	if(timer%30<10)then
	 pal(11,3)
	 pal(7,11)
	else
	 pal()
	end 
end

-- level 2 --
function init_lvl2()
	--starfield
	for i=0,100 do
		str[i]={}
		str[i].x=rnd(128)
		str[i].y=rnd(128)
		str[i].s=rnd(5)
		str[i].c=strc[flr(str[i].s)]
		str[i].s/=5
	end
end

function update_lvl2()
	if(timer==10)then
		for i=0,1,0.1 do 
			add(enemies,make_enemies(2,i+t,i+t))
		end
	end
	for e in all(enemies) do
		update_enemies(e)
	end
end

function draw_lvl2()
	draw_starfield()
end

-->8
--------------
-- ennemies --
-- t: type d'ennemies
-- 1:basique
-- 2:cercle
-- 3:homein
-- 10:boss1
function make_enemies(te,x,y)
	enemy={}
	enemy.t=te
	enemy.x=x
	enemy.y=y
	enemy.xy=x
	enemy.width=7
	enemy.height=8
	enemy.oswidth=0
	enemy.osheight=0
	enemy.missiles={}
	enemy.animation=1 -- anim ou jeu
	enemy.anim_begin=0 -- debut d'anim
	enemy.status=1 -- jouable
	enemy.shoot=0 -- a virer !!!! 
	enemy.hit=0 -- is enemy hit ?
	enemy.life=1 -- life
	if(te==1)then
		enemy.sprite=8
	elseif(te==2)then
		enemy.sprite=7
	elseif(te==3)then
		enemy.sprite=23
	elseif(te==10)then
		enemy.life=20
	 enemy.width=8
	 enemy.height=16
	 enemy.phase=0
	 enemy.phasecnt=0
	end

	return enemy
end

function update_enemies(e)
	foreach(e.missiles,function(m)
		update_missiles(m)
		if(m.status==0)then
		 if(m.t==2) make_expl(m.x,m.y)
		 del(e.missiles,m)
		end 
	end)
	
	if(e.hit==1)then
	 e.life-=1
	 e.hit=0
	end
	
 if(e.x<-7)or(e.life<1)then
 	if(e.life==0)then
  	--dead
 		make_expl(e.x,e.y)
 		e.life-=1
 		if(e.t==10)then
	 		boss_done_clock=timer
 	 	manage_score(e)
 		end
 	elseif(e.status==1)then
 	 --outside screen
 	 manage_score(e)
 	end	
 	--clean
 	e.status=0
 	if(#e.missiles==0) del(enemies,e)
 else
		--shooting and moving
		if(e.t==1)then 
			e.x-=.6
			e.y+=sin((e.x*.5+timer)/80)*.3--*cos(t/100)
			if((e.x<127)and(timer%80==0))then
				e.shoot=1
				add(e.missiles,make_missile(e.x-7,e.y+2,0.5,1,1))
			end
		elseif(e.t==2)then
			if(e.animation==2)then
			 e.x-=1
			elseif(e.animation==1)then
			 e.x-=1
			 if(e.x<64)then
			  e.animation=0
			  e.anim_begin=timer
			 end
			else
				if(e.y<50)then e.status=1
				else e.status=0
				end
 			e.x=64+cos((52+timer-e.anim_begin)/200)*48
	  	e.y=64+sin((52+timer-e.anim_begin)/200)*24 
	 	end	
		elseif(e.t==3)then
			e.x-=.6
			if((e.x>5)and(e.x<124)and(#e.missiles==0))then
				e.shoot=1
				add(e.missiles,make_missile(e.x-7,e.y+2,0.5,2,2))
			else
			 e.shoot=0
			end
		elseif(e.t==10)then
		 -- boss1
			if(e.animation==0)then
				local t=timer/100		
	 		e.y=60+20*(sin(t)+sin(3*t)/3)
				if((e.phase%2==0)and(timer%26==0))then
					e.shoot=1
					add(e.missiles,make_missile(e.x-7,e.y+2,.1,1,3))
					add(e.missiles,make_missile(e.x-7,e.y+2,.2,1,3))
					add(e.missiles,make_missile(e.x-7,e.y+2,1,1,3))
					add(e.missiles,make_missile(e.x-7,e.y+2,.8,1,3))
					add(e.missiles,make_missile(e.x-7,e.y+2,.9,1,3))
   	elseif((e.phase%2==1)and(timer%8==0))then
					e.shoot=1
					add(e.missiles,make_missile(e.x-7,e.y+2,0.5,1,1))
 				e.phasecnt+=3
   	end	
				e.phasecnt+=1
 			if(e.phasecnt>200)then
				 e.phase+=1
				 e.phasecnt=0
				end 
   end		
		end
	end
end

function draw_enemies(e)
	if((boss==true)and((shakeindex>1)or(e.hit==1)))	shake_camera()
	
	if(e.life>0)then
		if((e.t==2)and(e.animation==0))then
			local col=0
			local ey=e.y/40
			if(e.status==0)then
				for j=1,15 do
				 col=enemypal[j]
					pal(j,enemypal[j])
				end
			end
			sprite_zoom(e.x,e.y,ey,56,0,7,7)
			pal()
		elseif(e.t==10)then 
		 -- boss
   if(e.animation==1)then
				draw_bosslvl1_animation(e)
			else
		 	if((e.hit==1)and(e.life>0)) pal(11,8)
			end
			map(2,3,camx+e.x,camy+e.y,1,2)
		else
			-- affichage standard
			spr(e.sprite,camx+e.x,camy+e.y)
   if(e.t==3)then
			 print(e.x,40,40,7)
			 print(e.shoot,40,60,7)
   end
			--[[if(e.shoot>0)then
			 circfill(e.x+1,e.y+5,1-e.shoot,2)
			 circfill(e.x+3,e.y+6,2-e.shoot,14)
			 circfill(e.x+5,e.y+4,1-e.shoot,2)
			 e.shoot-=.1
			end]]
		end
	end
	
	foreach(e.missiles,draw_missiles)
end

-- draw boss stamina
function draw_stamina(x,y,life)
 local current=0
 foreach(enemies,function(e) 
		if(e.t==10) current=e.life
	end)
	
	local xo,c
	for i=life,0,-1 do
	 if(i>current)then c=3
	 else c=11
	 end
	 xo=x+i
	 rectfill(xo,y,xo+1,y+2,c)
	end
 if(current>0)and(timer%1==0)then
  xo=timer%life
  if(xo<=current)rectfill(x+xo,y,x+xo+1,y+2,10)
 end
end

-->8
----------------
-- explosions --
function make_expl(xs,ys)
	add(expl,{x=xs,y=ys,velx=-.1,vely=-.1,r=2.6,c=10,t=0,alive=true})
	add(expl,{x=xs,y=ys,velx=.1,vely=.1,r=2.6,c=10,t=0,alive=true})
	add(expl,{x=xs,y=ys,velx=0,vely=0,r=2.6,c=7,t=0,alive=true})
	add(expl,{x=xs,y=ys,velx=-.2,vely=.5,r=3.4,c=9,t=1,alive=true})
	add(expl,{x=xs,y=ys,velx=-.3,vely=.1,r=3.4,c=9,t=1,alive=true})
	add(expl,{x=xs,y=ys,velx=.5,vely=-.2,r=3.4,c=9,t=1,alive=true})
	sfx(1)
end

function update_expl(e)
	if(e.alive==true)then
		e.x+=e.velx
		e.y+=e.vely

		if(e.t==0)then 
			e.r+=.2
			if(e.r>5) e.alive=false
		else
			e.r-=.2
			if(e.r<0) e.alive=false
		end
	else del(expl,e)
	end
end

function draw_expl(e)
	if(e.t==0)then 
		circfill(e.x,e.y,e.r,e.c)
	else
		fillp(0b0101101001011010.1)
		circfill(e.x,e.y,e.r,e.c)
		fillp()
	end
end

-->8
--------------
-- missiles --
-- 0:hero
-- 1:basique
-- 2:homein
-- 3:manic
c_m_animate=10
c_p_color={2,14,15}
c_p_h_color={9,10,7}

function make_missile(x,y,a,s,t)
	m={}
	m.x=x;m.y=y
	m.sx=x;m.sy=y -- for hero
	m.angle=a
	m.speed=s
	m.width=6
	m.oswidth=1
	if(t==3)then
		m.height=6
		m.osheight=1
	else
		m.height=4
		m.osheight=2
	end	
	m.t=t
	m.clock=timer -- for homein
	m.status=1
	if(m.t==0)then
 	m.animate={x=m.x,y=m.y+m.height/2,r=2,c=0}
	 sfx(0)
	else
 	m.animate={x=m.x+m.width,y=m.y+m.height/2,r=2,c=0}
	end
	return m
end

function update_missiles(m)
 if((timer<m.clock+c_m_animate)and(timer%2==0))then
  m.animate.x+=rnd(2)-1
  m.animate.y+=rnd(2)-1
  m.animate.r-=.2
  if(m.t==0)then
  	m.animate.c=c_p_h_color[flr(rnd(3)+1)]  
  else
  	m.animate.c=c_p_color[flr(rnd(3)+1)]
  end
 end
 
	if(m.t==0)then
		m.x+=3
		if((m.x>126)or(m.x-m.sx>80)) del(hero.missiles,m)
		if((m.x>126)or(m.x-m.sx>80)) del(hero.missiles,m)
	elseif(m.t==1)then
		if(m.x<0)then
		 m.status=0 --del
		else
			m.x-=m.speed--+=cos(m.angle)
		--m.y+=sin(m.angle)
		end
	elseif(m.t==2)then -- homein
	 if(timer-m.clock>200)then 
	  m.status=0 --del
	 else
			local vecx=cos(m.angle)
 		local vecy=sin(m.angle)
			m.x+=vecx
			m.y+=vecy
			if((vecy*(hero.x-m.x)+(-vecx*(hero.y-m.y)))>0)then
				m.angle+=0.01
			else
				m.angle-=0.01
			end
		end	
	elseif(m.t==3)then -- manic
		if(m.x<0)then
		 m.status=0 --del
		else
			m.x-=cos(m.angle)
		 m.y-=sin(m.angle)
		end 
	end
end

function draw_missiles(m)
	if(m.t==0)then
		spr(2,camx+m.x,camy+m.y)	
	elseif(m.t==1)then
		spr(5,camx+m.x,camy+m.y)
	elseif(m.t==2)then
		draw_rotation(m.x,m.y,m.angle,48,8)
	elseif(m.t==3)then
	 spr(36,camx+m.x,camy+m.y)
	end	
	
 if(timer<m.clock+c_m_animate) circ(m.animate.x,m.animate.y,m.animate.r,m.animate.c)
	--[[foreach(m.animate,function(a)
	 if(timer<a.clock+c_p_animate)then
	  circ(a.x,a.y,a.r,a.c)
	 else
	  del(m.animate,a)
	 end 
	end)]]
end

-->8
----------
-- hero --
function make_hero()
	hero.x=20
	hero.y=74
	hero.width=8
	hero.height=6
	hero.oswidth=0
	hero.osheight=1
	--hero.i=false
 hero.shoot=0
 hero.missiles={}
 hero.smoke={
 	{x=18;y=77;r=3};
 	{x=16;y=77;r=3};
 	{x=15;y=77;r=2};
		{x=12;y=77;r=2};
		{x=10;y=77;r=1};
 	{x=8;y=77;r=1};
 	{x=6;y=77;r=4}
 	}
end

function update_hero()
 if(btn(0)and hero.x>0) hero.x-=1.5
 if(btn(1)and hero.x<123) hero.x+=1.5
 if(btn(2)and hero.y>uborder) hero.y-=1.5
 if(btn(3)and hero.y<(127-bborder-7)) hero.y+=1.5
	if(btn(4)and hero.shoot<(timer-10)) then
	 hero.shoot=timer
	 add(hero.missiles,make_missile(hero.x+8,hero.y+2,1,3,0))
	end
	if(btn(5)) fade=true
 -- missiles
	foreach(hero.missiles,function(m) 
		update_missiles(m)
	end)
	-- smoke
	if(timer%2==0)then
		foreach(hero.smoke,function(s)
			if((s.r==1)or(s.r>5))then 
				if(flr(rnd(5))==2)then
					s.x=hero.x-3;s.y=hero.y+3;s.r=4
				else
					s.x=hero.x-2;s.y=hero.y+3;s.r=3
				end
			else 
				if(s.r<4)then s.x-=2.6;s.r-=.5
				else s.x-=3.6;s.r+=.1 end
			end
		end)
	end
end

function draw_hero()
	pal()
	-- smoke
	fillp(23130.5)
	foreach(hero.smoke,function(s)
		if(s.r>3)then circfill(s.x,s.y,s.r,5)
		else circfill(s.x,s.y,s.r,7+s.r)
		end
		end)
	fillp()
	-- aircraft
	spr(1,camx+hero.x,camy+hero.y)
	-- missiles	
	foreach(hero.missiles,draw_missiles)
end

__gfx__
000000000600000009999990000000000022220002222220000ddddd00bb30000bbb330000bb330000bb33000000000000300000e000000e0000000000000000
00000000056000009ffffff90000000002eeee202efffff200d111200bbbb3000bbbb3000bbbbb300bbbbb30000300300300b000006660000000000000000000
007007000556cc709aaaaaf9000000902eefffe22eeeeef2011211200bb5b3000bb5b300bbb55bb3bbb55bb30b33b333333b33006655cc700000000000000000
0007700055555cc5099999900000089a2e77ffe202222220118121560b5853000b585300bb5885b3bb5885b333333b35b3b3bb39f5555cc50000000000000000
000770005555655500000000000499aa2e7f7fe200000000111121550bb5b3000bb5b300bb5f85b3bb5f85b3333333588b333339f55665550000000000000000
007007000066000000000000000004902ee77ee20000000001121120bbbbbb30bbbbbb30bbb55bb3bbb55bb303bb333b53bb33000066f0000000000000000000
0000000006600000000000000000000002eeee200000000000111200b00000b0bbbbbb300bbbbbb0bbbbbbb30000003000000b000fff00000000000000000000
000000000000000000000000000000000022220000000000000120000b000b0000bbb00000bbbb00bbbbbbb300000300000000b3e000000e0000000000000000
099999900000000009999990000000000022220000000000000000000bb0b3000bbbb30000000000bbbbbbb3b300000000000000060000000000000000000000
9ffffff9099999909aaaaaf90000000002eeee200000000000002200bbbbbb30bbbbbb3000000000bbbb3bb38500000000000000056000000000000000000000
9aaaaaf99ffffff99aaaaaa9000000002eefffe2000000000022ff20bbb5bb30bbbbbb30000000003bbbbbb333000000000000000556cc700000000000000000
099999909faaaff909999990000000002e77ffe20000000022eeeef2bb585b30bbb5bb3000000000bb3bb3b3000000000000000055555cc50000000000000000
000000009aaaaaf900000000000000002e777fe20000000022eeeef20bb5b3000b585b0000000000bbbbbb330220000000000000555565550000000000000000
000000009faaaaa900000000000000002ee77ee2000000000022ee2000bb300000b5b00000000000b3b0bbb32ef2000000000000006600000000000000000000
0000000009999990000000000000000002eeee20000000000000220000b03000b00b003000000000b0b0bb032ee2000000000000066000000000000000000000
000000000000000000000000000000000022220000000000000000000b000300bbb0bb3000000000b0000b030220000000000000000000000000000000000000
55555555555555550999999000000000002222000000000001234567000000000000000000000000000000000000000000000000000000000000000000000000
550b77b0550000b79aaaaaa90000000002eeee200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
50505b505050005b9aaaaaa9000000002ee7ffe20000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
500550055005050009999990000000002e777fe20000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
500050005000500000000000000000002e7777e20000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
555555555555500000000000000000002ee77ee20000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6000600060000000000000000000000002eeee200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
66666666666666660000000000000000002222000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
009999000000000009999990000000000022220000000000000000000bb0b3000000000000000000eeeeeeee0000000000000000000000000000000000000000
09aaaa90000990009aaaaaa90000000002eeee200000000000000000bbbbbb300000000000000000eeeeeeee0000000000000000000000000000000000000000
9a7777a9009aa9009ffffff9000000002ee777e20000000000000000bbb5bb300000000000000000eeeeeeee0000000000000000000000000000000000000000
9a7777a909a77a9009999990000000002e7777e20000000000000000bb585b300000000000000000eeeeeeee0000000000000000000000000000000000000000
9a7777a909a77a9000000000000000002e7777e200000000000000000bb5b3000000000000000000eeeeeeee0000000000000000000000000000000000000000
9a7777a9009aa90000000000000000002ee77ee2000000000000000002bb32000000000000000000eeeeeeee0000000000000000000000000000000000000000
09aaaa9000099000000000000000000002eeee20000000000000000002bf32000000000000000000eeeeeeee0000000000000000000000000000000000000000
009999000000000000000000000000000022220000000000000000000b2223000000000000000000000000000000000000000000000000000000000000000000
70007000707777077770770707770770700777078880888080808880008808080888088870007770077000070000555555555555555500000000000000000000
00078707878888788887887878887887877888708000808088808000080808080800080807078887788700700055cc6666666666666655000000000000000000
0007877787877878778787887787787887877700808080808080880008080808088008880078777787787000056c7000000000000007c6500000000000000000
000787878788887888878778778778778787887080808880808080000808080808000880777878878778777067c700000000000000007c760000000000000000
00078787878778787877877877877877878778708880808080808880088000800888080800787787877870075666000000000000000066650000000000000000
07007808778078787787877878887877877887000800800000800080080000000008000800078887788707000555600000000000000655500000000000000000
78700707007007070070700707770700700770070800800000800000000000000008000007007770077000700055555555555555555555000000000000000000
07000000000000000000000000000000000000700000800008880080000000000000000870000000000000070000555555555555555500000000000000000000
0000000012489999999999a77a999999999984210000000000666600000660000666660006666600060006600666666069999990999999906999996069999960
00000000000000000000000000000000000000000000000006999960006996006999996069999960696069966999999699600000000069909960699099606990
00000000228888888888eeeffeee88888888882200000000699669966999960006666996066669966960699669966660aaaaaa700007aa707aaaaa707aaaaaa0
0000000000000000000000000000000000000000000000007aa77aa7077aa70007aaaa70007aaaa77aaaaaa707aaaaa799606990006996009960699000006990
00000000556666667777777777777777666666550000000069966996066996600996666006666996066669960666669669999960009960006999996099999960
00000000000000000000000000000000000000000000000006999960699999960699999669999960000069966999999600000000000000000000000000000000
00000000882222333bbbbbbaabbbbbb3332222880000000000666600066666600066666006666600000006600666666000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
70000000000077707007070007070070777000800000000000000000000000000000000000000000000000000000000000000000566700006777777777777000
07000080000788878778787078787787888700000000000000000000000000000000000000000000000000000000000000000000566700005dc6666666667700
007008800078777787787887887877878778700700000000000000000000000000000000000000000000000000000000000000005667000051d6666666666770
00008080000788778888787878787787877870700000000000000000000000000000000000000000000000000000000000000000566670005666555555566677
00008080000077878778787778787787888700000000000000000000000000000000000000000000000000000000000000000000556667775667000000056667
00080080000777878778787078787787877000000000000000000000000000000000000000000000000000000000000000000000055666665667000000005667
00808880007888778778787078078877870077770000000000000000000000000000000000000000000000000000000000000000005566665667000000005667
00000000000777007007070007007700700000000000000000000000000000000000000000000000000000000000000000000000000555555667000000005667
77770888888888800888800888008008800000000088880000000000000000000000000000000000000000000000000000000000000056677777777756670000
00000800000080008000800800808008007777700877778000000000000000000000000000000000000000000000000000000000000056676666666656670000
00000088070080008000800800800808000000008787787800000000000000000000000000000000000000000000000000000000000056676666666656670000
00777000800800080008008888000080770000088787787800000000000000000000000000000000000000000000000000000000000656675555555556670000
77000000800807080008008080000080007770008777777800000000000000000000000000000000000000000000000000000000777766670000000056670000
00008888000800088880008008888800000007778877878800000000000000000000000000000000000000000000000000000000666666700000000056670000
00700000000000000000700000000000700000000877878000000000000000000000000000000000000000000000000000000000666666000000000056670000
87000000000000000000000000000000077708000088880000000000000000000000000000000000000000000000000000000000555550000000000056670000
0000000665000000000000000000000000650000000006500000000000000055500000200000000000000000d1d1d1d1dcdcdcdc000000000000000000000000
00000066665000000000000000065550066650000006666600655000000005555505002200000000000000001d1d1d1dcdcdcdcd000000000000000000000000
0000066666650066000000000066666566666650000000000666650000000555555550250000000000000000d1d1d1d1dcdcdcdc000000000000000000000000
00006666666656666500000006666666566666650000000066666665000006555555502500022000000000001d1d1d1dcdcdcdcd000000000000000000000000
0000666666666556665000006666666666666666006500006666666660006655555655550052550000000000d1d1d1d1dcdcdcdc000000000000000000000000
06555666666666656666500066766666666666660666650066665666660666555566655555555550000000001d1d1d1dcdcdcdcd000000000000000000000000
6666656666666665666666500767666666666666666666600660666066666655567665555655555505500005d1d1d1d1dcdcdcdc000000000000000000000000
66666666666666666666666500777766600776600000660000000000666766555666655566655555555550551d1d1d1dcdcdcdcd000000000000000000000000
7666666666666666666666660000055555550022000bb00000555555005555550000bb3bb3000000000000000000000000000000000000000000000000000000
7676666666666666666666662222255555650022003b3b000056555500556575000b6b63b6b00000000000000000000000000000000000000000000000000000
0767766666666666666666602222255555555555555333b3b655555522555555003b636336330000000000000000000000000000000000000000000000000000
007666666600666666600000666666555666655555533b333b555655266666550033666636300000000000000000000000000000000000000000000000000000
0007777660000766660000006766665556a66565556666663355555526a676550003666336600000000000000000000000000000000000000000000000000000
000000000000007760000000666666555666655556676766b6666665266666550506667636600000000000000000000000000000000000000000000000000000
0000000000000000000000006666665556a665555666666666766a65566666550556666666600000000000000000000000000000000000000000000000000000
0000000000000000000000006a6766555666655556676666666666655666a6555556666666605000000000000000000000000000000000000000000000000000
03333003330030003033333055555550000000000022222000000000000000005556666666655000000000000000000000000000000000000000000000000000
30000030003033033030000055bb5652222200000022222000000000000000005556666666655500000000000000000000000000000000000000000000000000
3003303333303030303330005b335552222200555522222000000000000000005556766676655500000000000000000000000000000000000000000000000000
30003030003030003030000033b3b552222200555522555500000000000000005556666666655550000000000000000000000000000000000000000000000000
0333003000303000303333303333b652666660555566655500000000000000005556767666655550000000000000000000000000000000000000000000000000
00000000000000000000000033333552666660555566655500000000000000005556666666655550000000000000000000000000000000000000000000000000
00000000000000000000000053435a52666660555566655500000000000000005556667766655550000000000000000000000000000000000000000000000000
00000000000000000000000055455552666660555566655500000000000000005556667766655550000000000000000000000000000000000000000000000000
0000055555550022002220000000002000000000000000000dddddd00dddddd00000000000000000000000000000000000000000000000000000000000000000
000005565565002200222000000002220000000000000000d227777dd227777d0000000000000000000000000000000000000000000000000000000000000000
066666555555555555522000005555220000000000000000d227227dd227227d0000000000000000000000000000000000000000000000000000000000000000
666666555666655555522000005555220000000000000000d272227dd272227d0000000000000000000000000000000000000000000000000000000000000000
676666555676656555666666005555220000022000000000d277772dd277777d0000000000000000000000000000000000000000000000000000000000000000
666766555666655556676766066666620000022000000000d722222dd722227d0000000000000000000000000000000000000000000000000000000000000000
666666555676655556666666667667625555555500000000d722222ed722227e0000000000000000000000000000000000000000000000000000000000000000
6767665556666555566766666666666255555555000000000eeeeee00eeeeee00000000000000000000000000000000000000000000000000000000000000000
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
2020202100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
8081828384404142434400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
9091929394979695949795000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
98990a87888a8987888a87000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
a8a91a6061626364000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000007071727374000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000a3a4a5a4a3a500a5000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000009c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
000f00002434300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010300001e650236502a65033650336502e650296502f650256501d65016650000000000018051000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000c0000153071c307173071230712307073070430703307013072500725007250073670700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010e00200c0431a31324615000020c0430000024655000000c0430000000000000000c0430000000000000000c0430000000003000020c0430000000000000000c0430000024655246250c043000000000000000
