local Wobble={}


function Wobble:new(args)
  local l=setmetatable({},{__index=Wobble})
  local args=args==nil and {} or arg
  l.use_grid=args.use_grid or false
  return l
end

function Wobble:grid_init()
  for i=2,5 do
    self.g:led(1,i,15)
  end
  self.g:refresh()
end

function Wobble:grid_key(x,y,z)
  local currentout=params:get("crow")

  if x==1 and y==1 and z==1 then
    self.tog=1-self.tog
    self.g:led(1,1,15*self.tog)
  end

  if y>1 and y<6 then
    local crowmodkey=(y-1).."modulation"
    local currentmod=params:get(crowmodkey)

    if (x>0 and x<=#self.modulations) then
      self.g:led(currentmod,y,0)
      self.g:led(x,y,15)
      params:set(crowmodkey,x)
      params:set("crow",y-1)
    end
  end

  self.g:refresh()
end

function Wobble:rebuild_menu(v)
  for _,param_name in ipairs(self.param_names) do
    for i=1,4 do
      if i==v then
        params:show(i..param_name)
      else
        params:hide(i..param_name)
      end
    end
  end
  for _,param_name in ipairs(self.midi_names) do
    for i=1,4 do
      if i==v and params:get(i.."miditype")==1 then
        --print("showing "..v)
        params:show(i..param_name)
      else
        params:hide(i..param_name)
      end
    end
  end
  for i=1,4 do
    if params:get(i.."midiin")==1 then
      for _,param_name in ipairs(self.midi_names) do
        params:hide(i..param_name)
      end
      params:hide(i.."miditype")
    end
  end
end

function Wobble:init()
  self.update_rate=15
  -- menu stuff
  self.param_names={"minval","maxval","freq","period","modulation","midiin","miditype","clampmin","clampmax","meta","meta2"}
  self.midi_names={"level","attack","decay","sustain","release"}
  self.midi_types={"envelope","any note","top note"}
  -- setup modulations
  self.modulations={"constant","sine","triangle","wobbly sine","snek","lorenz","henon","random walk","latoocarfian","fbsine","quad","standardmap","cookie"}
  self.outputs={"none"}
  -- grid toggle
  self.tog=0

  if self.use_grid then
    -- initiate the grid
    self.g=grid.connect()
    self.g.key=function(x,y,z)
      self:grid_key(x,y,z)
    end
    self:grid_init()
  end

  for _,mod in ipairs(self.modulations) do
    table.insert(self.outputs,mod)
  end

  -- setup engine
  engine.load("Wobble",function(v)
    print("engine loaded")
    params:default()
    params:bang()
    params:set("crow",1)
    self:rebuild_menu(1)
  end)
  engine.name="Wobble"

  -- setup midi
  self.mididevice_list={"none"}
  local midi_channels={"all"}
  for i=1,16 do
    table.insert(midi_channels,i)
  end
  for _,dev in pairs(midi.devices) do
    if dev.port~=nil then
      local name=string.lower(dev.name)
      table.insert(self.mididevice_list,name)
      print("adding "..name.." to port "..dev.port)
      local connection=midi.connect(dev.port)
      local notes={}
      connection.event=function(data)
        for i=1,4 do
          if self.mididevice_list[params:get(i.."midiin")]==name then
            -- process midi
            local d=midi.to_msg(data)
            if d.type=="note_on" then
              print(i,name,"midi on",d.note)
              local highest_note=true
              if params:get(i.."miditype")==3 then -- top note
                for k,_ in pairs(notes) do
                  if k>d.note then
                    highest_note=false
                    break
                  end
                end
              end
              if highest_note then
                engine.setmidi(i,d.note)
              end
              notes[d.note]=true
            elseif d.type=="note_off" then
              print(i,name,"midi off",d.note)
              notes[d.note]=nil
              local have_notes=false
              for k,v in pairs(notes) do
                have_notes=true
                break
              end
              if not have_notes then
                engine.setmidi(i,0)
              else
                if params:get(i.."miditype")==3 then -- top note
                  highest_note=-1
                  for k,_ in pairs(notes) do
                    if k>highest_note then
                      highest_note=k
                    end
                  end
                  if highest_note>-1 then
                    engine.setmidi(i,highest_note)
                  end
                end
              end
            end
          end
        end
        -- if d.ch~=midi_channels[params:get("midichannel")] and params:get("midichannel")>1 then
        --   do return end
        -- end
        -- if d.type=="note_on" then
        --   skeys:on({name=available_instruments[instrument_current].id,midi=data[2],velocity=data[3]})
        -- elseif d.type=="note_off" then
        --   skeys:off({name=available_instruments[instrument_current].id,midi=data[2]})
        -- end
      end
    end
  end

  -- setup parameters
  params:add_group("WOBBLE",1+16*4)
  params:add{type="option",id="crow",name="crow",options={"1","2","3","4"},default=1,action=function(v)
    self:rebuild_menu(v)
    if _menu.mode then
      _menu.rebuild_params()
    end
  end}
  for i=1,4 do
    params:add{type="option",id=i.."modulation",name="modulation",options=self.modulations,default=1,action=function(v)
      engine.mod(i,v,
        params:get(i.."freq"),
        params:get(i.."minval"),
        params:get(i.."maxval"),
        params:get(i.."level"),
        params:get(i.."attack"),
        params:get(i.."decay"),
        params:get(i.."sustain"),
        params:get(i.."release"),
        params:get(i.."meta"),
      params:get(i.."meta2"))
      self:setmidi(i)
    end}
    local do_update=true
    params:add{type="control",id=i.."period",name="period",controlspec=controlspec.new(0,300,'lin',0,1,'s',0.01/300),action=function(v)
      if not do_update then
        do return end
      end
      do_update=false
      params:set(i.."freq",1/v)
      engine.hz(i,1/v)
      do_update=true
    end}
    params:add{type="control",id=i.."freq",name="freq",controlspec=controlspec.new(0,300,'lin',0,1,'hz',0.01/300),action=function(v)
      if not do_update then
        do return end
      end
      do_update=false
      params:set(i.."period",1/v)
      engine.hz(i,v)
      do_update=true
    end}

    params:add{type="control",id=i.."meta",name="meta",controlspec=controlspec.new(-300,300,'lin',0,0,'metas',0.01/300),action=function(v)
      if not do_update then
        do return end
      end
      do_update=false
      engine.meta(i,v)
      do_update=true
    end}

    params:add{type="control",id=i.."meta2",name="meta2",controlspec=controlspec.new(-300,300,'lin',0,0,'metas',0.01/300),action=function(v)
      if not do_update then
        do return end
      end
      do_update=false
      engine.meta(i,v)
      do_update=true
    end}

    params:add{type="control",id=i.."minval",name="lfo min",controlspec=controlspec.new(-5,10,'lin',0,0,'',0.01/15),action=function(v)
      engine.minval(i,v)
    end}
    params:add{type="control",id=i.."maxval",name="lfo max",controlspec=controlspec.new(-5,10,'lin',0,5,'',0.01/15),action=function(v)
      engine.maxval(i,v)
    end}
    params:add{type="control",id=i.."clampmin",name="clamp min",controlspec=controlspec.new(-5,10,'lin',0,-5,'',0.01/15)}
    params:add{type="control",id=i.."clampmax",name="clamp max",controlspec=controlspec.new(-5,10,'lin',0,10,'',0.01/15)}
    params:add{type="option",id=i.."midiin",name="midi input",options=self.mididevice_list,default=1,action=function(v)
      self:setmidi(i)
      self:rebuild_menu(i)
      if _menu.mode then
        _menu.rebuild_params()
      end
    end}
    params:add{type="option",id=i.."miditype",name="midi type",options=self.midi_types,default=1,action=function(v)
      self:setmidi(i)
      self:rebuild_menu(i)
      if _menu.mode then
        _menu.rebuild_params()
      end
    end}
    params:add{type="control",id=i.."level",name="level",controlspec=controlspec.new(0,10,'lin',0,5,'v',0.1/10),action=function(v)
      engine.level(i,v)
    end}
    params:add{type="control",id=i.."attack",name="attack",controlspec=controlspec.new(0,10,'lin',0,0.2,'s',0.01/10),action=function(v)
      engine.attack(i,v)
    end}
    params:add{type="control",id=i.."decay",name="decay",controlspec=controlspec.new(0,10,'lin',0,0.5,'s',0.01/10),action=function(v)
      engine.decay(i,v)
    end}
    params:add{type="control",id=i.."sustain",name="sustain",controlspec=controlspec.new(0,100,'lin',0,100,'%',1/100),action=function(v)
      engine.sustain(i,v/100)
    end}
    params:add{type="control",id=i.."release",name="release",controlspec=controlspec.new(0,10,'lin',0,0.5,'s',0.01/10),action=function(v)
      engine.release(i,v)
    end}
  end

  -- setup crow outputs
  self.wf={}
  for i=1,4 do
    self.wf[i]={}
    for j=1,128 do
      self.wf[i][j]=0
    end
    crow.output[i].slew=1/self.update_rate -- slew is equal to update time in supercollider
  end

  -- setup crow inputs
  self.wfin={}
  for i=1,2 do
    self.wfin[i]={}
    for j=1,128 do
      self.wfin[i][j]=0
    end
    crow.input[i].mode("stream",1/self.update_rate)
    crow.input[i].stream=function(v)
      for j=1,127 do
        self.wfin[i][j]=self.wfin[i][j+1]
      end
      self.wfin[i][128]=math.floor(util.linlin(-5,10,64,1,v))

      -- TODO: make this optional
      -- do_update=false
      -- curfreq=params:get("1freq")
      -- engine.hz(i,v+curfreq)
      -- do_update=true
    end
  end




  osc.event=function(path,args,from)
    if path=="wobble" then
      local i=tonumber(args[1])
      if i~=nil and i>=1 and i<=4 then
        for j=1,127 do
          self.wf[i][j]=self.wf[i][j+1]
        end
        local volts=util.clamp(tonumber(args[2]),params:get(i.."clampmin"),params:get(i.."clampmax"))
        crow.output[i].volts=volts
        self.wf[i][128]=math.floor(util.linlin(-5,10,64,1,volts))
      end
    end
  end


end

function Wobble:setmidi(i)
  if params:get(i.."midiin")==1 then
    print("adding nothing")
    engine.addenv(i,0)
    engine.addmidi(i,0)
  elseif params:get(i.."miditype")==1 then
    print("adding env")
    engine.addenv(i,1)
    engine.addmidi(i,0)
  else
    print("adding midi")
    engine.addenv(i,0)
    engine.addmidi(i,1)
  end
end

function Wobble:get(input_num)
  if input_num>0 then
    -- return crow input
    return {
      crow=input_num,
      name="",
      freq=1/15,
      min=-5,
      max=10,
      meta=0,
      meta2=0,
      wf=self.wfin[input_num],
      miditype="",
      midi="",
    }
  else
    local i=params:get("crow")
    if self.wf==nil or self.wf[i]==nil then
      do return end
    end
    local midiname=self.mididevice_list[params:get(i.."midiin")]
    if midiname=="none" then
      midiname=""
    end
    return {
      crow=i,
      name=self.modulations[params:get(i.."modulation")],
      wf=self.wf[i],
      freq=params:get(i.."freq"),
      min=params:get(i.."minval"),
      max=params:get(i.."maxval"),
      meta=params:get(i.."meta"),
      meta2=params:get(i.."meta2"),
      midi=midiname,
      miditype=self.midi_types[params:get(i.."miditype")],
    }
  end
end



return Wobble


