local Wobble={}


function Wobble:new(args)
  local l=setmetatable({},{__index=Wobble})
  local args=args==nil and {} or args

  return l
end

function Wobble:init()
  -- setup modulations
  self.modulations={"sine","wobbly sine","drunk snek","lorenz","henon","random walk"}
  self.outputs={"none"}
  for _, mod in ipairs(self.modulations) do 
    table.insert(self.outputs,mod)
  end

  -- setup engine
  engine.load("Wobble",function(v)
    print("engine loaded")
  end)
  engine.name="Wobble"

  -- setup parameters
  self.param_names={"minval","maxval","freq","period"}
  params:add_group("WOBBLE",#self.modulations*4+1+4+2)
  params:add_separator("crow outputs")
  for i=1,4 do
    params:add{type="option",id=i.."crow",name="crow "..i,options=self.outputs,default=2,action=function(v)

    end
    }
  end
  params:add_separator("modulations")
  params:add{type="option",id="modulation",name="modulation",options=self.modulations,default=1,action=function(v)
    for _,param_name in ipairs(self.param_names) do
      for i,_ in ipairs(self.modulations) do
        if i==v then
          params:show(i..param_name)
        else
          params:hide(i..param_name)
        end
      end
    end
    _menu.rebuild_params()
  end
  }
  local do_update=true
  for i,_ in ipairs(self.modulations) do
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
    params:add{type="control",id=i.."minval",name="min",controlspec=controlspec.new(-10,10,'lin',0,0,'',0.01/20),action=function(v)
      engine.minval(i,v)
    end
    }
    params:add{type="control",id=i.."maxval",name="max",controlspec=controlspec.new(-10,10,'lin',0,1,'',0.01/20),action=function(v)
      engine.maxval(i,v)
    end
    }
  end

  -- setup osc
  self.wf={}
  for i, _ in ipairs(self.modulations) do 
    self.wf[i]={}
    for j=1,128 do 
      self.wf[i][j]=0
    end
  end
  osc.event=function(path,args,from)
   if path=="wobble" then
     local i=tonumber(args[1])
     if i~=nil and i+0>0 then
       for j=1,127 do
         self.wf[i][j]=self.wf[i][j+1]
       end
       self.wf[i][128]=math.floor(util.linlin(params:get(i.."minval"),params:get(i.."maxval"),1,64,tonumber(args[2])))
     end
   end
  end

  for _,param_name in ipairs(self.param_names) do
    for i,_ in ipairs(self.modulations) do
      if i==1 then
        params:show(i..param_name)
      else
        params:hide(i..param_name)
      end
    end
  end
end

function Wobble:get()
  local i=params:get("modulation")
  return {name=self.modulations[i],wf=self.wf[i],freq=params:get(i.."freq"),min=params:get(i.."minval"),max=params:get(i.."maxval")}
end

return Wobble