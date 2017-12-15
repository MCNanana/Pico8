pico-8 cartridge // http://www.pico-8.com
version 15
__lua__
cells={}
temp={}
t=0
speed=5
generation=0

function create_cell(i,j)
	cells[i*128+j]=1 
	temp[i*128+j]=1 
end

function update_cell(i,j)
	alivenb=0
	index=i*128+j

	for x=i-1,i+1 do
		for y=j-1,j+1 do
			tmpindex=x*128+y
			if (tmpindex!=index) then
				if (cells[tmpindex]==1) alivenb+=1
			end	
		end
	end	
	
	-- birth
	if	(cells[index]==0 
			and alivenb==3) then
		temp[index]=1
	-- death
	elseif	(cells[index]==1 
			and (alivenb<2 or alivenb>3)) then
		temp[index]=0
 -- nothing
 else	
  temp[index]=cells[index]	
	end
end	

function _init()
	for i=0,127 do
		for j=0,127 do
			cells[i*128+j]=0
			temp[i*128+j]=0
		end
	end
	
	--[[create_cell(10,10)
	create_cell(10,11)
	create_cell(10,12)]]
	
	create_cell(60,60)
	create_cell(61,60)
	create_cell(62,60)
	create_cell(63,60)
	create_cell(64,60)
	create_cell(65,60)
	create_cell(66,60)
	create_cell(67,60)
	create_cell(68,60)
	create_cell(69,60)
end

function _update()
	t+=1
	
	if (t>speed) then
		generation+=1

		-- update cells
		for i=1,126 do
			for j=1,126 do
				update_cell(i,j)
			end
		end

		t=0
		-- buffer copy
		for i=0,127 do
			for j=0,127 do
				cells[i*128+j]=temp[i*128+j]
			end
		end		
	end
	
	if (btn(0)) speed-=1
	if (btn(1)) speed+=1
end

function _draw()
	cls()
	for i=0,127 do
		for j=0,127 do
			if (cells[i*128+j]==1) then pset(i,j,7)	end
		end
	end
	print("generation: "..generation,1,1,6)
	print("speed: "..speed,80,1,6)
end
