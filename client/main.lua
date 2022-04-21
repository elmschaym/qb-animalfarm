local QBCore = exports['qb-core']:GetCoreObject()

local isPressed = false

function SellingBlips()
    for _, v in pairs(Config.SellSpots) do
        local blip = AddBlipForCoord(v.x, v.y, v.z)
        SetBlipSprite(blip, 141)
        SetBlipDisplay(blip, 4)
        SetBlipScale(blip, 0.6)
        SetBlipColour(blip, 49)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString("Sell Meat")
        EndTextCommandSetBlipName(blip)
    end
end



function drawTxt(text)
    SetTextFont(0)
    SetTextProportional(0)
    SetTextScale(0.32, 0.32)
    SetTextColour(0, 255, 255, 255)
    SetTextDropShadow(0, 0, 0, 0, 255)
    SetTextEdge(1, 0, 0, 0, 255)
    SetTextDropShadow()
    SetTextOutline()
    SetTextCentre(1)
    SetTextEntry("STRING")
    AddTextComponentString(text)
    DrawText(0.5, 0.93)
end

function getAnimalMatch(hash)
    for _, v in pairs(Config.Animals) do if (v.hash == hash) then return v end end
end

function ShowHelpMsg(msg)   
    BeginTextCommandDisplayHelp('STRING')
    AddTextComponentSubstringPlayerName(msg)
    EndTextCommandDisplayHelp(0, false, true, -1)   
end

function loadAnimDict(dict)
    while (not HasAnimDictLoaded(dict)) do
        RequestAnimDict(dict)
        Citizen.Wait(0)
    end
end


Citizen.CreateThread(function()
    SellingBlips()  
    while true do
        local ped = PlayerPedId()  

        if not IsPedInAnyVehicle(ped, false) then
                local ent = GetClosestPed()
                if (tonumber(GetEntityHealth(ent)) < 1 ) then
                    while DoesEntityExist(ent) do
                            local pos = GetEntityCoords(ped)
                            local rpos = GetEntityCoords(ent)
                            local model = GetEntityModel(ent)
                            local animal = getAnimalMatch(model)
                            if (model and animal) then
                                if (GetDistanceBetweenCoords(pos, rpos.x, rpos.y, rpos.z, true) < 25) then
                                    if (DoesEntityExist(ent)) then
                                        if (tonumber(GetEntityHealth(ent)) < 1) then 

                                            DrawMarker(20, rpos.x, rpos.y, rpos.z + 0.8, 0, 0, 0,0, 0, 0, 0.5, 0.5, -0.25, 255, 60, 60, 150, 1, 1, 2, 0, 0, 0, 0)

                                            if (GetDistanceBetweenCoords(pos, rpos.x, rpos.y,rpos.z, true )< 1.1 ) then  
                                                              
                                                ShowHelpMsg('Press ~INPUT_PICKUP~ to Harvest Animal.')
                                                if IsControlJustPressed(0, 38) and not isPressed then
                                                            loadAnimDict('amb@medic@standing@kneel@base')
                                                            loadAnimDict('anim@gangops@facility@servers@bodysearch@')
                                                            TaskPlayAnim(GetPlayerPed(-1),"amb@medic@standing@kneel@base","base", 8.0, -8.0, -1, 1, 0,false, false, false)
                                                            TaskPlayAnim(GetPlayerPed(-1),"anim@gangops@facility@servers@bodysearch@","player_search", 8.0, -8.0, -1,48, 0, false, false, false)                                                
                                                            isPressed = true
                                                            QBCore.Functions.Progressbar("harv_anim", "Harvesting Animal", 5000, false, false, {
                                                                disableMovement = true,
                                                                disableCarMovement = false,
                                                                disableMouse = false,
                                                                disableCombat = true,
                                                            }, {}, {}, {}, function() 
                                                                ClearPedTasks(GetPlayerPed(-1))                                                                                                
                                                               -- TriggerServerEvent('cad-hunting:server:AddItem',ent.id, 1)   
                                                                DeleteEntity(ent)
                                                                TriggerServerEvent('QBCore:Server:AddItem', "meat", math.random(1, 3))
                                                                TriggerEvent("inventory:client:ItemBox", QBCore.Shared.Items['meat'], "add")
                                                                TriggerServerEvent('QBCore:Server:AddItem', "cowpelt", math.random(1, 3))
                                                                TriggerEvent("inventory:client:ItemBox", QBCore.Shared.Items['cowpelt'], "add")
                                                                
                                                              --  Citizen.Wait(100)   
                                                               isPressed = false                                                                          
                                                            end, function() -- Cancel
                                                                ClearPedTasks(GetPlayerPed(-1))     
                                                                QBCore.Functions.Notify("Canceled..", "error")                                                 
                                                               
                                                            end)                
                                                end
                                            end
                                        end
                                    else                        
                                        DeleteEntity(ent)
                                    end
                                else
                                    DeleteEntity(ent)
                                    QBCore.Functions.Notify("Bobo!! Baka mo kinain na nang uod.",'error', 15000)
                                end
                            end
                        Citizen.Wait(4)
                    end
                end
        end 
        for _, v in pairs(Config.SellSpots) do
            local pos = GetEntityCoords(ped)
            if #(vector3(pos.x, pos.y, pos.z)-vector3(v.x, v.y, v.z)) < 8 then
                DrawMarker(20, v.x, v.y, v.z, 0, 0, 0, 0, 0, 0, 0.5, 0.5,-0.25, 255, 60, 60, 150, 1, 1, 2, 0, 0, 0, 0)
                if #(vector3(pos.x, pos.y, pos.z)-vector3(v.x, v.y, v.z)) < 2 then                    
                    ShowHelpMsg('Press ~INPUT_PICKUP~ to Sell Hunting Items.')
                    if IsControlJustPressed(0, 38) then
                        TriggerServerEvent('hunting:server:sellmeat')
                    end
                end
            end
        end
        Citizen.Wait(4)
    end
end)

--[[Citizen.CreateThread(function()
    SellingBlips()  
    local ped = PlayerPedId()    
    while true do
        for _, v in pairs(Config.SellSpots) do
            local pos = GetEntityCoords(ped)
            if #(vector3(pos.x, pos.y, pos.z)-vector3(v.x, v.y, v.z)) < 8 then
                DrawMarker(20, v.x, v.y, v.z, 0, 0, 0, 0, 0, 0, 0.5, 0.5,-0.25, 255, 60, 60, 150, 1, 1, 2, 0, 0, 0, 0)
                if #(vector3(pos.x, pos.y, pos.z)-vector3(v.x, v.y, v.z)) < 2 then                    
                    ShowHelpMsg('Press ~INPUT_PICKUP~ to Sell Hunting Items.')
                    if IsControlJustPressed(0, 38) then
                        TriggerServerEvent('hunting:server:sellmeat')
                    end
                end
            end
        end
        Citizen.Wait(4)
    end
end)--]]

RegisterNetEvent('cad-hunting:client:spawnanim')
AddEventHandler('cad-hunting:client:spawnanim', function(model)
    model           = (tonumber(model) ~= nil and tonumber(model) or GetHashKey(model))
    local playerPed = PlayerPedId()
    local coords    = GetEntityCoords(playerPed)
    local forward   = GetEntityForwardVector(playerPed)
    local x, y, z   = table.unpack(coords + forward * 1.0)

    Citizen.CreateThread(function()
        RequestModel(model)
        while not HasModelLoaded(model) do
            Citizen.Wait(1)
        end
        CreatePed(5, model, x, y, z, 0.0, true, false)
    end)
end)

function GetClosestPed()
    local closestPed = 0

    for ped in EnumeratePeds() do
        local distanceCheck = GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), GetEntityCoords(ped), true)
        if distanceCheck <= 1.5 and ped ~= GetPlayerPed(-1) and not IsPedAPlayer(ped)  then
            closestPed = ped
            break
        end
    end
    return closestPed
end

local entityEnumerator = {
    __gc = function(enum)
        if enum.destructor and enum.handle then
            enum.destructor(enum.handle)
        end
        enum.destructor = nil
        enum.handle = nil
    end
}

local function EnumerateEntities(initFunc, moveFunc, disposeFunc)
    return coroutine.wrap(
        function()
            local iter, id = initFunc()
            if not id or id == 0 then
                disposeFunc(iter)
                return
            end

            local enum = {handle = iter, destructor = disposeFunc}
            setmetatable(enum, entityEnumerator)

            local next = true
            repeat
                coroutine.yield(id)
                next, id = moveFunc(iter)
            until not next

            enum.destructor, enum.handle = nil, nil
            disposeFunc(iter)
        end
    )
end


function EnumeratePeds()
    return EnumerateEntities(FindFirstPed, FindNextPed, EndFindPed)
end

