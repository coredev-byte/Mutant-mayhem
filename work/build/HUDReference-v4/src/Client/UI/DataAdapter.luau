local Rep=game:GetService("ReplicatedStorage")
local remote=Rep.MM.Remotes.Action
local D={State=nil,Busy=false,Changed=Instance.new("BindableEvent"),Notice=Instance.new("BindableEvent")}
function D.Accept(s)
 if not s or s.Loading then return end D.State=s D.Changed:Fire(s)
end
function D.Send(action,arg)
 if D.Busy then D.Notice:Fire("Aguarde a ação anterior terminar.") return end
 D.Busy=true local ticket={} D.Ticket=ticket
 task.delay(12,function() if D.Ticket==ticket and D.Busy then D.Notice:Fire("Servidor demorando para responder. Aguardando confirmação…") end end)
 local ok,result=pcall(function() return remote:InvokeServer(action,arg) end)
 D.Busy=false D.Ticket=nil
 if not ok or type(result)~="table" then D.Notice:Fire("Conexão interrompida. Tente novamente.") return end
 D.Accept(result.State) if result.Message then D.Notice:Fire(result.Message) end
 return result
end
function D.Travel(destination,action,arg)
 local r=D.Send("Go",destination) if r and r.Ok and action then return D.Send(action,arg) end return r
end
function D.Start()
 Rep.MM.Remotes.Update.OnClientEvent:Connect(function(p)
  if not D.Busy then D.Accept(p.State) end if p.Message then D.Notice:Fire(p.Message) end
 end)
 task.spawn(function() for _=1,20 do D.Send("State") if D.State then break end task.wait(1) end end)
end
return D
