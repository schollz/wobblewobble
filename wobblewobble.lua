-- wobble v0.0.1
-- wobbly voltages for crow
--
-- llllllll.co/t/wobble
--
--
--
--    ▼ instructions below ▼
-- K1+K2/K3 switches crow
-- K2/K3 switch modulator
-- E1 changes frequency
-- E2 changes min
-- E3 changes max

ww=include("wobblewobble/lib/wobblewobble")
holdk1=false

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
  if k>1 then
    if holdk1 then
      if k==2 and z==1 then
        if params:get("crow")==1 then
          params:set("crow",4)
        else
          params:delta("crow",-1)
        end
      elseif k==3 and z==1 then
        if params:get("crow")==4 then
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
  if ww.tog==0 then
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
  local cur=ww:get()

  screen.level(15)
  for i=1,128 do
    screen.line(i,cur.wf[i])
    screen.stroke()
    screen.move(i,cur.wf[i])
  end

  screen.level(8)
  local s=cur.name
  screen.rect(2,64-20,screen.text_extents(s)+4,10)
  screen.fill()
  screen.level(0)
  screen.move(4,64-13)
  screen.text(s)
  screen.stroke()

  s=string.format("%.2fhz,%.2f - %.2fv",cur.freq,cur.min,cur.max)

  -- ww.input1, ww.input2

  if cur.name=="constant" then
    s=string.format("%.2fhz %.2fv",cur.freq,cur.max)
  end

  if ww.tog==0 then
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

  if ww.tog==1 then
    fg=0
    bg=8
  else
    fg=8
    bg=0
  end

  screen.level(bg)
  screen.rect(128-screen.text_extents(sm)-3,64-7,128-screen.text_extents(sm)+4,10)
  screen.fill()
  screen.level(fg)
  screen.move(128-screen.text_extents(sm)-1,64-1)
  screen.text(sm)
  screen.stroke()

  screen.level(1)
  si=string.format("%.2f",ww.input2)
  screen.move(128-screen.text_extents(si)-1,8)
  screen.text(si)
  screen.stroke()

  screen.level(1)
  si=string.format("%.2f",ww.input1)
  screen.move(128-screen.text_extents(si)-22,8)
  screen.text(si)
  screen.stroke()

  screen.level(8)
  local s="crow "..cur.crow
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


