pico-8 cartridge // http://www.pico-8.com 
version 27 
__lua__ 
pal={5,6,7,10} 
 
function _init() 
	t=0 
	init_blob() 
end 
 
function _update() 
	t+=.01 
	update_blob() 
end 
 
function _draw() 
	draw_blob() 
end 
-->8 
-- plasma 
 
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
-->8 
-- blob 
-- http://mathieuturcotte.ca/textes/quadtree/ 
 
blob={} 
screen=64*128 
min_threshold=0.92 
med_threshold=1.02 
max_threshold=1.2 
pal={4,9,10} 
 
function make_blob(r,dirx,diry,x,y) 
	metablob={} 
	metablob.radius=r 
 metablob.dirx=dirx 
 metablob.diry=diry 
 metablob.x=x 
 metablob.y=y 
 metablob.xm=1 
 metablob.ym=1 
	return metablob 
end 
 
function add_blob() 
	add(blob,make_blob(10,3,-1,30,80)) 
	add(blob,make_blob(10,-1,2,80,40)) 
	add(blob,make_blob(10,2,-2,20,60)) 
end 
 
function init_blob() 
	add_blob() 
end 
 
function update_blob() 
	local b 
	for i=1,#blob do 
 	b=blob[i] 
 	b.x+=(b.dirx*b.radius)/30+cos(t)/20 
 	b.y+=(b.diry*b.radius)/30+sin(t)/20 
 	 
		if(b.x<1)or(b.x>127) 
			or(b.y<1)or(b.y>127)then  
			del(blob,b) 
		end  
	end 
end 
 
function equation(b,x,y)   
 local dx=x-b.x 
 local dy=y-b.y 
 --return (b.radius/(abs(x-b.x)+abs(y-b.y))) 
 return (b.radius/sqrt(b.xm*dx*dx+b.ym*dy*dy)) 
end 
 
function draw_blob() 
	cls() 
	local sum 
	 
	for x=0,128 do 
		for y=0,128 do 
			sum=0 
			for i=1,#blob do 
 			b=blob[i] 
			  
 			sum+=equation(b,x,y) 
 			 
 			local col 
  		if(sum>max_threshold)then 
   		col=3 
			 elseif(sum>med_threshold)then   
			  col=2  
			 elseif(sum>min_threshold)then   
			  col=1 
  		end 
			 pset(x,y,pal[col])  
			end 
		end 
	end 
	print(flr(stat(1)),10,30,2) 
end 
 
__gfx__ 
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000 
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000 
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000 
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000 
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000 
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000 
