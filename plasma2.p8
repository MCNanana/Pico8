pico-8 cartridge // http://www.pico-8.com 
version 27 
__lua__ 
pal={5,6,7,10} 
 
function _init() 
	t=0 
end 
 
function _update() 
	t+=.01 
end 
 
function _draw() 
	plasma() 
end 
-->8 
function dist(x,width,y,height) 
	x-=width 
	y-=height 
	return sqrt(x*x+y*y) 
end 
 
function plasma() 
	cls(10) 
	local col=0 
	for x=0,128 do 
		for y=0,128 do 
			col=0 
			--col=64+(64*t*sin(x/128)) 
			local d=dist(x,64,y,64)/10 
			--col+=8+8*t*sin(d/20) 
			--col+=8+8*t*sin(d/20) 
			--col+=8*t*sin(sqrt(x*x*y*y*x*x*y*y)/50) 
			--col+=8+8*t*sin(x/40) 
			--col+=8+8*t*sin(y/100) 
			--col+=8*t*sin((x+y)/60) 
			dx=x/128 
			dy=y/128 
			col+=sin(t+dx/10) 
			cx=dx+1*sin(t/10) 
			cy=dy+2*sin(t/10) 
			col+=sin(sqrt(cx*cx+cy*cy)+t) 
			col=flr(col%5)		 
			pset(x,y,pal[col]) 
			--pset(x,y,col) 
		end 
	end 
end 
__gfx__ 
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000 
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000 
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000 
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000 
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000 
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000 