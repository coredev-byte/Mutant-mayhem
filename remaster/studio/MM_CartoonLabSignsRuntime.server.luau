-- CAOS MUTANTE | reapply the cartoon lab plates if MM_World gets rebuilt.
-- Cosmetic only. Keeps Bootstrap / PlotService ownership text working.
local Styler = require(script.Parent:WaitForChild("MM_CartoonLabSignsV1"))
local watchedLabels=setmetatable({},{__mode="k"})
local function watchPlot(plot)
 if not (plot and plot:IsA("Model")) then return end
 Styler.StylePlot(plot)
 local sign=plot:FindFirstChild("Sign")
 local gui=sign and sign:FindFirstChild("BillboardGui")
 local label=gui and gui:FindFirstChild("TextLabel")
 if not (label and label:IsA("TextLabel")) or watchedLabels[label] then return end
 watchedLabels[label]=true
 local function fit()
  local length=utf8.len(label.Text) or #label.Text
  label.TextScaled=false
  if length<=9 then label.TextSize=30
  elseif length<=16 then label.TextSize=25
  elseif length<=24 then label.TextSize=20
  elseif length<=34 then label.TextSize=17
  else label.TextSize=14 end
 end
 fit()
 label:GetPropertyChangedSignal("Text"):Connect(fit)
end
local function watchWorld(world)
 if not (world and world.Name=="MM_World") then return end
 local function watchPlots(plots)
  if not (plots and plots:IsA("Folder") and plots.Name=="Plots") then return end
  Styler.Apply()
  for _,plot in ipairs(plots:GetChildren()) do watchPlot(plot) end
  plots.ChildAdded:Connect(function(plot)
   if plot:IsA("Model") then task.defer(function()
    if plot.Parent==plots then watchPlot(plot) end
   end) end
  end)
 end
 local plots=world:FindFirstChild("Plots")
 if plots then watchPlots(plots) end
 world.ChildAdded:Connect(function(child)
  if child.Name=="Plots" then task.defer(function() watchPlots(child) end) end
 end)
end
local world=workspace:FindFirstChild("MM_World")
if world then watchWorld(world) end
workspace.ChildAdded:Connect(function(child)
 if child.Name=="MM_World" then task.defer(function() watchWorld(child) end) end
end)
