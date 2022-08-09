pico-8 cartridge // http://www.pico-8.com
version 32
__lua__

t=0
mypal={6,7,10,9,8}
sprnb=17
done=false

function _draw()
	cls()
 t+=.2

	talk()
	--flag()
end

function countdown()
	local temp=flr(t)%2
	
	if(temp==0)and(not done)then
		sprnb+=1
		if(sprnb==21)then sprnb=34
		elseif(sprnb==37)then sprnb=50
		elseif(sprnb==53)then flag()
		end
		done=true
	elseif(temp!=0)then
		done=false
	end
	
	print(temp,10,10,7)
	spr(sprnb,60,60)
end

function cosinus()
	for i=1,127 do
		pset(i,50+5*cos((i+t*20)/50),7)
		--pset(i,50+cos((i+t*40)/30),7)
	end
end

function flag()
	local c,z,s,yos
	
	for i=0,7 do
		for j=0,7 do
			c=sget(i,8+j)
			
			--z=sin(t)+i*t*.2
			z=cos((i+t*40)/10)
			yos=2*cos((i+t*40)/20)
			print(z,2,t,7)
			if(z>0)then s=0
			else s=1
			end

			if(c==5)then
				palt(1,true) 
				palt(0,false) 
				spr(1+s,40+i*8,40+j*8+yos)
				palt()
			elseif(c==7)then 
				spr(3+s,40+i*8,40+j*8+yos)		
			end
		end	
	end
	
	pal(10,7)
	sspr(40,0,24,8,55,56)
	sspr(40,0,24,8,56,55)
	sspr(40,0,24,8,57,56)
	sspr(40,0,24,8,56,57)
	pal()
	sspr(40,0,24,8,56,56)
	--spr(5,56,56)
	--spr(6,64,56)
	--spr(7,72,56)
end

function synthwave()
	local c,tc
	cls()
 t+=.02

 for i=0,23 do
 	tc=i/8+sin(t-i*.2)*.5+3
  c=mid(tc,1,5)
  line(0,i,31,i,mypal[flr(c)])
  --print(tc.." - "..c.." - "..mypal[flr(c)],60,6+i*7,7)
 end
 pal(1,0)
 spr(9,0,0,4,3)
 pal(1,1)
 --c=mid(i/8+sin(t-i*.2)*.5+1,1,8)
end

function talk()
	if(t%18<8)then
		pal(9,14)
		pal(10,15)
	else
		pal(9,15)
		pal(10,14)
	end
	sspr(0,32,16,16,50,50,16,16)
	pal()
end
__gfx__
00000000110055111110011100776600000770000aa000aa000aa00a0000a0a00000000011111111111111111111111111111111000000000000000000000000
0000000010000651110005110777776000777600a00a0a00a0a00a0a0000a0a00000000011111111111111111111111111111111000000000000000000000000
0070070000005665100055517777767607776660a0000a00a0a00a0a0000a0a00000000011111000000000001111000000011111000000000000000000000000
0007700000000505000005007777777677777677a0000a00a0a00a0a0000a0a00000000011110000000000001110000000011111000000000000000000000000
0007700000000000000000007777777777777777a0aa0a00a0a00a0a0000a0a00000000011100000000000001100000000011111000000000000000000000000
0070070000000000100000017777777707777770a00a0a00a0aaaa0a000000000000000011100000000000001100010000011111000000000000000000000000
0000000010000001110000110777777000777700a00a0a00a0a00a0a0000a0a00000000011100000000000001111110000011111000000000000000000000000
00000000110000111110011100777700000770000aa000aa00a00a0aaaa0a0a00000000011100000111111111111110000011111000000000000000000000000
557755775577557700009990000009900000009900e8e80000000000000000000000000011100000000000001111110000011111000000000000000000000000
55775577557755770009000900000999000000990888f8f000000000000000000000000011100000000000001111110000011111000000000000000000000000
7755775577557755000000090000009900000099e8e8e7e800000000000000000000000011100000001111111111110000011111000000000000000000000000
77557755775577550000099000000990000000998888f8f800000000000000000000000011100000011111111111110000011111000000000000000000000000
5577557755775577000000090000009900000099e8e8e8e800000000000000000000000011100000011111111111110000011111000000000000000000000000
55775577557755770000000900000099000000998888888800000000000000000000000011100000011111111111110000011111000000000000000000000000
775577557755775500090009000009990000009908e8e8e000000000000000000000000011100000011111111111110000011111000000000000000000000000
77557755775577550000999000000990000000990088880000000000000000000000000011100000011111111111110000011111000000000000000000000000
00000000111111110000999000000990000000990000000000000000000000000000000011100000011111111111110000011111000000000000000000000000
00000000111111110009000900000999000000990000000000000000000000000000000011100000011111111111110000011111000000000000000000000000
00000000111111110000000900000009000000990000000000000000000000000000000011100000011111111111110000011111000000000000000000000000
00000000111111110000009000000099000000990000000000000000000000000000000011100000011111111111100000011111000000000000000000000000
00000000111111110000990000000990000000990000000000000000000000000000000011100000011111111111000000001111000000000000000000000000
00000000111111110009000000000990000000990000000000000000000000000000000011111111111111111111111111111111000000000000000000000000
00000000111111110009000000000990000000990000000000000000000000000000000011111111111111111111111111111111000000000000000000000000
00000000111111110009999900000999000000990000000000000000000000000000000011111111111111111111111111111111000000000000000000000000
00000000000000000000990000000990000000990000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000009990000009990000000990000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000090000000990000000990000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000090000000990000000990000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000090000000990000000990000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000090000000990000000990000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000090000000990000000990000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000009999900009999000000990000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000555555000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00555555555555000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00555555555555500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
05555555555555500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0555555ee55555500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0555e5eeeee555550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
055eeeeeeeeee5500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0feeee3eee3ee5000000000000000000000000000000000000000000000000001111111100000000000000000000000000000000000000000000000000000000
0efeeeeeeeeee0000000000000000000000000000000000000000000000000001111111100000000000000000000000000000000000000000000000000000000
0efeeeeeeeeee0000000000000000000000000000000000000000000000000001111111100000000000000000000000000000000000000000000000000000000
0eeeee9fff9ee0000000000000000000000000000000000000000000000000001111111100000000000000000000000000000000000000000000000000000000
00eeeeeaaaeee0000000000000000000000000000000000000000000000000001111111100000000000000000000000000000000000000000000000000000000
000eeeeeeeee00000000000000000000000000000000000000000000000000001111111100000000000000000000000000000000000000000000000000000000
00000eeeeee000000000000000000000000000000000000000000000000000001111111100000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000001111111100000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000001111111100000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000001111111100000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000001111111100000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000001111111100000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000001111111100000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000001111111100000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000001111111100000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000001111111100000000000000000000000000000000000000000000000000000000
00000000000000001111111111111111000000000000000011111111111111111111111100000000000000000000000000000000000000000000000000000000
00000000000000001111111111111111000000000000000011111111111111111111111100000000000000000000000000000000000000000000000000000000
00000000000000001111111111111111000000000000000011111111111111111111111100000000000000000000000000000000000000000000000000000000
00000000000000001111111111111111000000000000000011111111111111111111111100000000000000000000000000000000000000000000000000000000
00000000000000001111111111111111000000000000000011111111111111111111111100000000000000000000000000000000000000000000000000000000
00000000000000001111111111111111000000000000000011111111111111111111111100000000000000000000000000000000000000000000000000000000
00000000000000001111111111111111000000000000000011111111111111111111111100000000000000000000000000000000000000000000000000000000
00000000000000001111111111111111000000000000000011111111111111111111111100000000000000000000000000000000000000000000000000000000
