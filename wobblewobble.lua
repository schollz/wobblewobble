-- wobble v0.0.1
-- wobbly voltages for crow
--
-- llllllll.co/t/wobble
--
--
--
--    ▼ instructions below ▼
-- hold K1 to switch crow out
-- K2/K3 switch modulator
-- E1 changes frequency
-- E2 changes min
-- E3 changes max

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
		params:delta(params:get("crow").."modulation",-1)
		params:set(params:get("crow").."meta",0)
	elseif k==3 and z==1 then 
		params:delta(params:get("crow").."modulation",1)
		params:set(params:get("crow").."meta",0)
	elseif k==1 and z==1 then
		if params:get("crow")==4 then 
			params:set("crow",1)
		else
			params:delta("crow",1)
		end
	end

end

function enc(k,d)
	if k==1 then
		params:delta(params:get("crow").."freq",d)
	elseif k==2 then 
		params:delta(params:get("crow").."minval",d)
	elseif k==3 then
		params:delta(params:get("crow").."maxval",d)
	else
        -- fates specific, enc 4
		params:delta(params:get("crow").."meta",d)
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
	local s= cur.name
	screen.rect(2,64-20,screen.text_extents(s)+4,10)
	screen.fill()
	screen.level(0)
	screen.move(4,64-13)
	screen.text(s)
	screen.stroke()

	screen.level(8)
    s = string.format("%.2fhz,%.2f-%.2fv %.2f %.1f/%.1f", cur.freq, cur.min, cur.max, cur.meta, ww.input1, ww.input2)

	if cur.name=="constant" then
		s=string.format("%.2fhz %.2fv", cur.freq, cur.max)
	end

	screen.rect(2,64-7,screen.text_extents(s)+4,10)
	screen.fill()
	screen.level(0)
	screen.move(4,64-1)
	screen.text(s)
	screen.stroke()

	screen.level(8)
	local s="crow "..cur.crow
	if cur.midi ~= "" then 
		s=s.." < "..cur.midi.."/"..cur.miditype
	end
	screen.rect(2,2,screen.text_extents(s)+4,8)
	screen.fill()
	screen.level(0)
	screen.move(4,8)
	screen.text(s)
	screen.stroke()

	screen.update()
end

function rerun()
  norns.script.load(norns.state.script)
end
