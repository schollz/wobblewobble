-- wobble 

ww=include("wobblewobble/lib/wobblewobble")

function init()
 ww:init()
 clock.run(function()
 	while true do
 		clock.sleep(1/15)
 		redraw()
 	end
 end)
end

function key(k,z)
	if k==2 and z==1 then 
		params:delta("modulation",-1)
	elseif k==3 and z==1 then 
		params:delta("modulation",1)
	end

end

function enc(k,d)
	if k==1 then
		params:delta(params:get("modulation").."freq",d)
	elseif k==2 then 
		params:delta(params:get("modulation").."minval",d)
	else
		params:delta(params:get("modulation").."maxval",d)
	end
end

function redraw()
	screen.clear()
	local cur=ww:get()

	screen.level(15)
	for i=1,128 do
		screen.line(i,cur.wf[i])
		screen.stroke()
		screen.move(i,cur.wf[i])
	end

	screen.level(8)
	local s= cur.name.." @ "..cur.freq.." hz ["..(math.floor(cur.min*100)/100)..","..(math.floor(cur.max*100)/100).."]"
	screen.rect(2,64-15,screen.text_extents(s)+4,10)
	screen.fill()
	screen.level(0)
	screen.move(4,64-8)
	screen.text(s)
	screen.stroke()

	screen.level(8)
	local s=""
	for i=1,4 do 
		if params:get(i.."crow")-1==params:get("modulation") then 
			if s=="" then 
				s = "crow "..i
			else
				s = s..", "..i
			end
		end
	end
	if s~="" then
		screen.rect(2,2,screen.text_extents(s)+4,8)
		screen.fill()
		screen.level(0)
		screen.move(4,8)
		screen.text(s)
		screen.stroke()
	end

	screen.update()
end

function rerun()
  norns.script.load(norns.state.script)
end
