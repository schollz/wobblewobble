local Wobble={}


function Wobble:new(args)
  local l=setmetatable({},{__index=Wobble})
  local args=args==nil and {} or args

  return l
end

function Wobble:rebuild_menu(v)
  self.param_names={"minval","maxval","freq","period","modulation"}
  for _,param_name in ipairs(self.param_names) do
    for i=1,4 do
      if i==v then
        params:show(i..param_name)
      else
        params:hide(i..param_name)
      end
    end
  end
end

function Wobble:init()
  -- setup modulations
  self.modulations={"constant","sine","triangle","wobbly sine","snek","lorenz","henon","random walk"}
  self.outputs={"none"}
  for _, mod in ipairs(self.modulations) do 
    table.insert(self.outputs,mod)
  end

  -- setup engine
  engine.load("Wobble",function(v)
    print("engine loaded")
    params:default()
    params:bang()
  end)
  engine.name="Wobble"

  -- setup parameters
  params:add_group("WOBBLE",21)
  params:add{type="option",id="crow",name="crow",options={"1","2","3","4"},default=1,action=function(v)
    self:rebuild_menu(v)
    _menu.rebuild_params()
  end
  }
  for i=1,4 do
    params:add{type="option",id=i.."modulation",name="modulation",options=self.modulations,default=1,action=function(v)
      engine.mod(i,v,params:get(i.."freq"),params:get(i.."minval"),params:get(i.."maxval"))
    end
    }
    local do_update=true
    params:add{type="control",id=i.."period",name="period",controlspec=controlspec.new(0,300,'lin',0,1,'s',0.01/300),action=function(v)
      if not do_update then 
        do return end 
      end
      do_update=false
      params:set(i.."freq",1/v)
      engine.hz(i,1/v)
      do_update=true
    end
    }
    params:add{type="control",id=i.."freq",name="freq",controlspec=controlspec.new(0,300,'lin',0,1,'hz',0.01/300),action=function(v)
      if not do_update then 
        do return end 
      end
      do_update=false
      params:set(i.."period",1/v)
      engine.hz(i,v)
      do_update=true
    end
    }
    params:add{type="control",id=i.."minval",name="min",controlspec=controlspec.new(-5,10,'lin',0,0,'',0.01/20),action=function(v)
      engine.minval(i,v)
    end
    }
    params:add{type="control",id=i.."maxval",name="max",controlspec=controlspec.new(-5,10,'lin',0,5,'',0.01/20),action=function(v)
      engine.maxval(i,v)
    end
    }
  end

  -- setup crow
  for i=1,4 do
    crow.output[i].slew=1/15 -- slew is equal to update time in supercollider
  end

  -- setup osc
  self.wf={}
  for i=1,4 do 
    self.wf[i]={}
    for j=1,128 do 
      self.wf[i][j]=0
    end
  end
  osc.event=function(path,args,from)
   if path=="wobble" then
     local i=tonumber(args[1])
     if i~=nil and i>=1 and i<=4 then
       for j=1,127 do
         self.wf[i][j]=self.wf[i][j+1]
       end
       local volts=util.clamp(tonumber(args[2]),-5,10)
       crow.output[i].volts=volts
       self.wf[i][128]=math.floor(util.linlin(-5,10,64,1,volts))
     end
   end
  end

  self:rebuild_menu(1)
end

function Wobble:get()
  local i=params:get("crow")
  return {
    crow=i,
    name=self.modulations[params:get(i.."modulation")],
    wf=self.wf[i],freq=params:get(i.."freq"),
    min=params:get(i.."minval"),
    max=params:get(i.."maxval"),
  }
end

return Wobble