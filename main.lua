local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/Okorix/moddedlinorialib/main/source.lua"))()
local ThemeManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/Okorix/moddedlinorialib/main/addons/ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/Okorix/moddedlinorialib/main/addons/SaveManager.lua"))()

local Window = Library:CreateWindow({
    Title = 'TESTIRUEM.LUA | CRIMINALITY',
    Center = true,
    AutoShow = true,
    TabPadding = 8
})

local Tabs = {
    Visuals = Window:AddTab('Visuals'),
}

local PlayerLeftGroupbox = Tabs.Main:AddLeftGroupbox('Player')
