-- wobblewobble v0.0.1
-- wobbly voltages for crow
--
-- llllllll.co/t/wobblewobble
--
--
--
--    ▼ instructions below ▼
-- hold K1+K2/K3 to switch crow
-- press K2/K3 to switch mod
-- E1 changes frequency
-- E2/E3changes lfo min/max
-- K1+E2 or K1+E3 changes meta

ww=include("wobblewobble/lib/wobblewobble")
holdk1=false
show_input=0

function init()
  ww:init({use_grid=true})
  clock.run(function()
    while true do
      clock.sleep(1/15)
      redraw()
    end
  end)
end

function key(k,z)
  if k>1 then
    if holdk1 then
      if k==2 and z==1 then
        print(params:get("crow"),show_input)
        if params:get("crow")==1 and show_input==0 then
          show_input=2
        elseif show_input==2 then
          show_input=1
        elseif show_input==1 then
          show_input=0
          params:set("crow",4)
        else
          params:delta("crow",-1)
        end
      elseif k==3 and z==1 then
        if params:get("crow")==4 and show_input==0 then
          show_input=1
        elseif show_input==1 then 
          show_input=2
        elseif show_input==2 then 
          show_input=0
          params:set("crow",1)
        else
          params:delta("crow",1)
        end
      end
    else
      if k==2 and z==1 then
        params:delta(params:get("crow").."modulation",-1)
        params:set(params:get("crow").."meta",0)
      elseif k==3 and z==1 then
        params:delta(params:get("crow").."modulation",1)
        params:set(params:get("crow").."meta",0)
      end
    end
  elseif k==1 then
    holdk1=z==1
  end

end

function enc(k,d)
  print(k)
  if k==1 then
    params:delta(params:get("crow").."freq",d)
  else
    -- fates specific, enc 4
    if k==4 then
      if ww.tog==0 then
        params:delta(params:get("crow").."meta",d)
      else
        params:delta(params:get("crow").."meta2",d)
      end
    end
  end
  if ww.tog==0 and not holdk1 then
    if k==2 then
      params:delta(params:get("crow").."minval",d)
    elseif k==3 then
      params:delta(params:get("crow").."maxval",d)
    end
  else
    if k==2 then
      params:delta(params:get("crow").."meta",d)
    elseif k==3 then
      params:delta(params:get("crow").."meta2",d)
    end
  end
end

function redraw()
  screen.clear()
  local cur=ww:get(show_input)

  screen.level(15)
  for i=1,128 do
    screen.line(i,cur.wf[i])
    screen.stroke()
    screen.move(i,cur.wf[i])
  end

  screen.level(8)
  local s=cur.name
  if s~="" then
    screen.rect(2,64-20,screen.text_extents(s)+4,10)
    screen.fill()
    screen.level(0)
    screen.move(4,64-13)
    screen.text(s)
    screen.stroke()
  end

  s=string.format("%.2fhz,%.2f - %.2fv",cur.freq,cur.min,cur.max)

  -- ww.input1, ww.input2

  if cur.name=="constant" then
    s=string.format("%.2fhz %.2fv",cur.freq,cur.max)
  end

  if ww.tog==0 or holdk1 then
    fg=0
    bg=8
  else
    fg=8
    bg=0
  end

  screen.level(bg)
  screen.rect(2,64-7,screen.text_extents(s)+4,10)
  screen.fill()
  screen.level(fg)
  screen.move(4,64-1)
  screen.text(s)
  screen.stroke()

  sm=string.format("%.2f %.2f",cur.meta,cur.meta2)

  if ww.tog==1 or holdk1 then
    fg=0
    bg=8
  else
    fg=8
    bg=0
  end

  -- only show if toggled
  if (ww.tog==1 or holdk1) and (show_input==0) then
    screen.level(bg)
    screen.rect(128-screen.text_extents(sm)-3,64-7,128-screen.text_extents(sm)+4,10)
    screen.fill()
    screen.level(fg)
    screen.move(128-screen.text_extents(sm)-1,64-1)
    screen.text(sm)
    screen.stroke()
  end

  -- screen.level(1)
  -- si=string.format("%.2f",ww.input2)
  -- screen.move(128-screen.text_extents(si)-1,8)
  -- screen.text(si)
  -- screen.stroke()

  -- screen.level(1)
  -- si=string.format("%.2f",ww.input1)
  -- screen.move(128-screen.text_extents(si)-22,8)
  -- screen.text(si)
  -- screen.stroke()

  screen.level(8)
  local s="crow "
  if show_input > 0 then 
    s=s.."input "
  end
  s=s..cur.crow
  if cur.midi~="" then
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


