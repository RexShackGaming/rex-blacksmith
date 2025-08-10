local RSGCore = exports['rsg-core']:GetCoreObject()
lib.locale()

---------------------------------------------
-- get system and correct menu
---------------------------------------------
RegisterNetEvent('rex-blacksmith:client:openblacksmith', function(blacksmithid, jobaccess, name)
    if not Config.EnableRentSystem then
        local PlayerData = RSGCore.Functions.GetPlayerData()
        local playerjob = PlayerData.job.name
        if playerjob == jobaccess then
            TriggerEvent('rex-blacksmith:client:openjobmenu', blacksmithid, status)
        else
            TriggerEvent('rex-blacksmith:client:opencustomermenu', blacksmithid, status)
        end
    else
        RSGCore.Functions.TriggerCallback('rex-blacksmith:server:getblacksmithdata', function(result)
            local owner = result[1].owner
            local status = result[1].status
            if owner ~= 'vacant' then
                local PlayerData = RSGCore.Functions.GetPlayerData()
                local playerjob = PlayerData.job.name
                if playerjob == jobaccess then
                    TriggerEvent('rex-blacksmith:client:openrentjobmenu', blacksmithid, status)
                else
                    TriggerEvent('rex-blacksmith:client:opencustomermenu', blacksmithid, status)
                end
            else
                TriggerEvent('rex-blacksmith:client:rentblacksmith', blacksmithid, name)
            end
        end, blacksmithid)
    end
end)

---------------------------------------------
-- blacksmith job menu (non rent)
---------------------------------------------
RegisterNetEvent('rex-blacksmith:client:openjobmenu', function(blacksmithid, status)
    lib.registerContext({
        id = 'blacksmith_job_menu',
        title = locale('cl_lang_1'),
        options = {
            {
                title = locale('cl_lang_2'),
                icon = 'fa-solid fa-store',
                event = 'rex-blacksmith:client:ownerviewitems',
                args = { blacksmithid = blacksmithid },
                arrow = true
            },
            {
                title = locale('cl_lang_3'),
                icon = 'fa-solid fa-circle-plus',
                iconColor = 'green',
                event = 'rex-blacksmith:client:newstockitem',
                args = { blacksmithid = blacksmithid },
                arrow = true
            },
            {
                title = locale('cl_lang_4'),
                icon = 'fa-solid fa-circle-minus',
                iconColor = 'red',
                event = 'rex-blacksmith:client:removestockitem',
                args = { blacksmithid = blacksmithid },
                arrow = true
            },
            {
                title = locale('cl_lang_5'),
                icon = 'fa-solid fa-sack-dollar',
                event = 'rex-blacksmith:client:withdrawmoney',
                args = { blacksmithid = blacksmithid },
                arrow = true
            },
            {
                title = locale('cl_lang_6'),
                icon = 'fa-solid fa-box',
                event = 'rex-blacksmith:client:ownerstoragemenu',
                args = { blacksmithid = blacksmithid },
                arrow = true
            },
            {
                title = locale('cl_lang_7'),
                icon = 'fa-solid fa-box',
                event = 'rex-blacksmith:client:craftingmenu',
                args = { blacksmithid = blacksmithid },
                arrow = true
            },
            {
                title = locale('cl_lang_9'),
                icon = 'fa-solid fa-user-tie',
                event = 'rsg-bossmenu:client:mainmenu',
                arrow = true
            },
        }
    })
    lib.showContext('blacksmith_job_menu')
end)

---------------------------------------------
-- blacksmith job menu (rent)
---------------------------------------------
RegisterNetEvent('rex-blacksmith:client:openrentjobmenu', function(blacksmithid, status)
    if status == 'open' then
        lib.registerContext({
            id = 'blacksmith_job_menu',
            title = locale('cl_lang_1'),
            options = {
                {
                    title = locale('cl_lang_2'),
                    icon = 'fa-solid fa-store',
                    event = 'rex-blacksmith:client:ownerviewitems',
                    args = { blacksmithid = blacksmithid },
                    arrow = true
                },
                {
                    title = locale('cl_lang_3'),
                    icon = 'fa-solid fa-circle-plus',
                    iconColor = 'green',
                    event = 'rex-blacksmith:client:newstockitem',
                    args = { blacksmithid = blacksmithid },
                    arrow = true
                },
                {
                    title = locale('cl_lang_4'),
                    icon = 'fa-solid fa-circle-minus',
                    iconColor = 'red',
                    event = 'rex-blacksmith:client:removestockitem',
                    args = { blacksmithid = blacksmithid },
                    arrow = true
                },
                {
                    title = locale('cl_lang_5'),
                    icon = 'fa-solid fa-sack-dollar',
                    event = 'rex-blacksmith:client:withdrawmoney',
                    args = { blacksmithid = blacksmithid },
                    arrow = true
                },
                {
                    title = locale('cl_lang_6'),
                    icon = 'fa-solid fa-box',
                    event = 'rex-blacksmith:client:ownerstoragemenu',
                    args = { blacksmithid = blacksmithid },
                    arrow = true
                },
                {
                    title = locale('cl_lang_7'),
                    icon = 'fa-solid fa-box',
                    event = 'rex-blacksmith:client:craftingmenu',
                    args = { blacksmithid = blacksmithid },
                    arrow = true
                },
                {
                    title = locale('cl_lang_8'),
                    icon = 'fa-solid fa-box',
                    event = 'rex-blacksmith:client:rentmenu',
                    args = { blacksmithid = blacksmithid },
                    arrow = true
                },
                {
                    title = locale('cl_lang_9'),
                    icon = 'fa-solid fa-user-tie',
                    event = 'rsg-bossmenu:client:mainmenu',
                    arrow = true
                },
            }
        })
        lib.showContext('blacksmith_job_menu')
    else
        lib.registerContext({
            id = 'blacksmith_job_menu',
            title = locale('cl_lang_1'),
            options = {
                {
                    title = locale('cl_lang_8'),
                    icon = 'fa-solid fa-box',
                    event = 'rex-blacksmith:client:rentmenu',
                    args = { blacksmithid = blacksmithid },
                    arrow = true
                },
            }
        })
        lib.showContext('blacksmith_job_menu')
    end
end)

---------------------------------------------
-- blacksmith customer menu
---------------------------------------------
RegisterNetEvent('rex-blacksmith:client:opencustomermenu', function(blacksmithid, status)
    if status == 'closed' then
        lib.notify({ title = locale('cl_lang_10'), type = 'error', duration = 7000 })
        return
    end
    lib.registerContext({
        id = 'blacksmith_customer_menu',
        title = locale('cl_lang_11'),
        options = {
            {
                title = locale('cl_lang_12'),
                icon = 'fa-solid fa-store',
                event = 'rex-blacksmith:client:customerviewitems',
                args = { blacksmithid = blacksmithid },
                arrow = true
            },
            {
                title = locale('cl_lang_13'),
                icon = 'fa-solid fa-box',
                event = 'rex-blacksmith:client:storageplayershare',
                args = { blacksmithid = blacksmithid },
                arrow = true
            },
        }
    })
    lib.showContext('blacksmith_customer_menu')
end)

---------------------------------------------
-- blacksmith rent money menu
---------------------------------------------
RegisterNetEvent('rex-blacksmith:client:rentmenu', function(data)

    RSGCore.Functions.TriggerCallback('rex-blacksmith:server:getblacksmithdata', function(result)
    
        local rent = result[1].rent
        if rent > 50  then rentColorScheme = 'green' end
        if rent <= 50 and rent > 10 then rentColorScheme = 'yellow' end
        if rent <= 10 then rentColorScheme = 'red' end
        
        lib.registerContext({
            id = 'blacksmith_rent_menu',
            title = locale('cl_lang_14'),
            menu = 'blacksmith_job_menu',
            options = {
                {
                    title = locale('cl_lang_15')..rent,
                    progress = rent,
                    colorScheme = rentColorScheme,
                },
                {
                    title = locale('cl_lang_16'),
                    icon = 'fa-solid fa-dollar-sign',
                    event = 'rex-blacksmith:client:payrent',
                    args = { blacksmithid = data.blacksmithid },
                    arrow = true
                },
            }
        })
        lib.showContext('blacksmith_rent_menu')

    end, data.blacksmithid)
    
end)

-------------------------------------------------------------------------------------------
-- job : view blacksmith items
-------------------------------------------------------------------------------------------
RegisterNetEvent('rex-blacksmith:client:ownerviewitems', function(data)

    RSGCore.Functions.TriggerCallback('rex-blacksmith:server:checkstock', function(result)

        if result == nil then
            lib.registerContext({
                id = 'blacksmith_no_inventory',
                title = locale('cl_lang_17'),
                menu = 'blacksmith_job_menu',
                options = {
                    {
                        title = locale('cl_lang_18'),
                        icon = 'fa-solid fa-box',
                        disabled = true,
                        arrow = false
                    }
                }
            })
            lib.showContext('blacksmith_no_inventory')
        else
            local options = {}
            for k,v in ipairs(result) do
                options[#options + 1] = {
                    title = RSGCore.Shared.Items[result[k].item].label..' ($'..result[k].price..')',
                    description = locale('cl_lang_19')..result[k].stock,
                    icon = 'fa-solid fa-box',
                    event = 'rex-blacksmith:client:buyitem',
                    icon = "nui://" .. Config.Img .. RSGCore.Shared.Items[tostring(result[k].item)].image,
                    image = "nui://" .. Config.Img .. RSGCore.Shared.Items[tostring(result[k].item)].image,
                    args = {
                        item = result[k].item,
                        stock = result[k].stock,
                        price = result[k].price,
                        label = RSGCore.Shared.Items[result[k].item].label,
                        blacksmithid = result[k].blacksmithid
                    },
                    arrow = true,
                }
            end
            lib.registerContext({
                id = 'blacksmith_inv_menu',
                title = locale('cl_lang_17'),
                menu = 'blacksmith_job_menu',
                position = 'top-right',
                options = options
            })
            lib.showContext('blacksmith_inv_menu')
        end
    end, data.blacksmithid)

end)

-------------------------------------------------------------------------------------------
-- customer : view blacksmith items
-------------------------------------------------------------------------------------------
RegisterNetEvent('rex-blacksmith:client:customerviewitems', function(data)
    RSGCore.Functions.TriggerCallback('rex-blacksmith:server:checkstock', function(result)
        if result == nil then
            lib.registerContext({
                id = 'blacksmith_no_inventory',
                title = locale('cl_lang_17'),
                menu = 'blacksmith_customer_menu',
                options = {
                    {
                        title = locale('cl_lang_18'),
                        icon = 'fa-solid fa-box',
                        disabled = true,
                        arrow = false
                    }
                }
            })
            lib.showContext('blacksmith_no_inventory')
        else
            local options = {}
            for k,v in ipairs(result) do
                options[#options + 1] = {
                    title = RSGCore.Shared.Items[result[k].item].label..' ($'..result[k].price..')',
                    description = locale('cl_lang_19')..result[k].stock,
                    icon = 'fa-solid fa-box',
                    event = 'rex-blacksmith:client:buyitem',
                    icon = "nui://" .. Config.Img .. RSGCore.Shared.Items[tostring(result[k].item)].image,
                    image = "nui://" .. Config.Img .. RSGCore.Shared.Items[tostring(result[k].item)].image,
                    args = {
                        item = result[k].item,
                        stock = result[k].stock,
                        price = result[k].price,
                        label = RSGCore.Shared.Items[result[k].item].label,
                        blacksmithid = result[k].blacksmithid
                    },
                    arrow = true,
                }
            end
            lib.registerContext({
                id = 'blacksmith_inv_menu',
                title = locale('cl_lang_17'),
                menu = 'blacksmith_customer_menu',
                position = 'top-right',
                options = options
            })
            lib.showContext('blacksmith_inv_menu')
        end
    end, data.blacksmithid)

end)

-------------------------------------------------------------------
-- sort table function
-------------------------------------------------------------------
local function compareNames(a, b)
    return a.value < b.value
end

-------------------------------------------------------------------
-- add / update stock item
-------------------------------------------------------------------
RegisterNetEvent('rex-blacksmith:client:newstockitem', function(data)

    local items = {}

    for k,v in pairs(RSGCore.Functions.GetPlayerData().items) do
        local content = { value = v.name, label = v.label..' ('..v.amount..')' }
        items[#items + 1] = content
    end

    table.sort(items, compareNames)

    local item = lib.inputDialog(locale('cl_lang_20'), {
        { 
            type = 'select',
            options = items,
            label = locale('cl_lang_21'),
            required = true
        },
        { 
            type = 'input',
            label = locale('cl_lang_22'),
            icon = 'fa-solid fa-hashtag',
            required = true
        },
        { 
            type = 'input',
            label = locale('cl_lang_23'),
            placeholder = '0.00',
            icon = 'fa-solid fa-dollar-sign',
            required = true
        },
    })
    
    if not item then 
        return 
    end
    
    local hasItem = RSGCore.Functions.HasItem(item[1], tonumber(item[2]))
    
    if hasItem then
        TriggerServerEvent('rex-blacksmith:server:newstockitem', data.blacksmithid, item[1], tonumber(item[2]), tonumber(item[3]))
        lib.notify({ title = 'Item Added', type = 'success', duration = 7000 })
    else
        lib.notify({ title = locale('cl_lang_24'), type = 'error', duration = 7000 })
    end

end)

-------------------------------------------------------------------------------------------
-- remove stock item
-------------------------------------------------------------------------------------------
RegisterNetEvent('rex-blacksmith:client:removestockitem', function(data)
    RSGCore.Functions.TriggerCallback('rex-blacksmith:server:checkstock', function(result)
        if result == nil then
            lib.registerContext({
                id = 'blacksmith_no_stock',
                title = locale('cl_lang_25'),
                menu = 'blacksmith_owner_menu',
                options = {
                    {
                        title = locale('cl_lang_26'),
                        icon = 'fa-solid fa-box',
                        disabled = true,
                        arrow = false
                    }
                }
            })
            lib.showContext('blacksmith_no_stock')
        else
            local options = {}
            for k,v in ipairs(result) do
                options[#options + 1] = {
                    title = RSGCore.Shared.Items[result[k].item].label,
                    description = locale('cl_lang_19')..result[k].stock,
                    icon = 'fa-solid fa-box',
                    serverEvent = 'rex-blacksmith:server:removestockitem',
                    icon = "nui://" .. Config.Img .. RSGCore.Shared.Items[tostring(result[k].item)].image,
                    image = "nui://" .. Config.Img .. RSGCore.Shared.Items[tostring(result[k].item)].image,
                    args = {
                        item = result[k].item,
                        blacksmithid = result[k].blacksmithid
                    },
                    arrow = true,
                }
            end
            lib.registerContext({
                id = 'blacksmith_stock_menu',
                title = locale('cl_lang_25'),
                menu = 'blacksmith_job_menu',
                position = 'top-right',
                options = options
            })
            lib.showContext('blacksmith_stock_menu')
        end
    end, data.blacksmithid)
end)

-------------------------------------------------------------------------------------------
-- withdraw money 
-------------------------------------------------------------------------------------------
RegisterNetEvent('rex-blacksmith:client:withdrawmoney', function(data)
    RSGCore.Functions.TriggerCallback('rex-blacksmith:server:getmoney', function(result)
        local input = lib.inputDialog(locale('cl_lang_27'), {
            { 
                type = 'input',
                label = locale('cl_lang_28')..result.money,
                icon = 'fa-solid fa-dollar-sign',
                required = true
            },
        })
        if not input then
            return 
        end
        local withdraw = tonumber(input[1])
        if withdraw <= result.money then
            TriggerServerEvent('rex-blacksmith:server:withdrawfunds', withdraw, data.blacksmithid)
        else
            lib.notify({ title = locale('cl_lang_29'), type = 'error', duration = 7000 })
        end
    end, data.blacksmithid)
end)

---------------------------------------------
-- buy item amount
---------------------------------------------
RegisterNetEvent('rex-blacksmith:client:buyitem', function(data)
    local input = lib.inputDialog(locale('cl_lang_30')..data.label, {
        { 
            label = locale('cl_lang_31'),
            type = 'input',
            required = true,
            icon = 'fa-solid fa-hashtag'
        },
    })
    if not input then
        return
    end
    
    local amount = tonumber(input[1])
    
    if data.stock >= amount then
        local newstock = (data.stock - amount)
        TriggerServerEvent('rex-blacksmith:server:buyitem', amount, data.item, newstock, data.price, data.label, data.blacksmithid)
    else
        lib.notify({ title = locale('cl_lang_32'), type = 'error', duration = 7000 })
    end
end)

---------------------------------------------
-- rent blacksmith
---------------------------------------------
RegisterNetEvent('rex-blacksmith:client:rentblacksmith', function(blacksmithid, name)
    
    local input = lib.inputDialog(locale('cl_lang_33')..name, {
        {
            label = locale('cl_lang_34')..Config.RentStartup,
            type = 'select',
            options = {
                { value = 'yes', label = locale('cl_lang_35') },
                { value = 'no',  label = locale('cl_lang_36') }
            },
            required = true
        },
    })

    -- check there is an input
    if not input then
        return 
    end

    -- if no then return
    if input[1] == 'no' then
        return
    end

    RSGCore.Functions.TriggerCallback('rsg-multijob:server:checkjobs', function(canbuy)
        if not canbuy then
            lib.notify({ title = locale('cl_lang_50'), type = 'error', duration = 7000 })
            return
        else
            RSGCore.Functions.TriggerCallback('rex-blacksmith:server:countowned', function(result)

                if result >= Config.MaxBlacksmiths then
                    lib.notify({ title = locale('cl_lang_48'), description = locale('cl_lang_49'), type = 'error', duration = 7000 })
                    return
                end
        
                -- check player has a licence
                if Config.LicenseRequired then
                    local hasItem = RSGCore.Functions.HasItem('blacksmithlicence', 1)
        
                    if hasItem then
                        TriggerServerEvent('rex-blacksmith:server:rentblacksmith', blacksmithid)
                    else
                        lib.notify({ title = locale('cl_lang_37'), type = 'error', duration = 7000 })
                    end
                else
                    TriggerServerEvent('rex-blacksmith:server:rentblacksmith', blacksmithid)
                end
            
            end)
        end
    end)
end)

-------------------------------------------------------------------------------------------
-- pay rent
-------------------------------------------------------------------------------------------
RegisterNetEvent('rex-blacksmith:client:payrent', function(data)
    local input = lib.inputDialog(locale('cl_lang_38'), {
        { 
            label = locale('cl_lang_39'),
            type = 'input',
            icon = 'fa-solid fa-dollar-sign',
            required = true
        },
    })
    if not input then
        return 
    end
    TriggerServerEvent('rex-blacksmith:server:addrentmoney', input[1], data.blacksmithid)
end)

---------------------------------------------
-- owner blacksmith storage menu
---------------------------------------------
RegisterNetEvent('rex-blacksmith:client:ownerstoragemenu', function(data)
    lib.registerContext({
        id = 'owner_storage_menu',
        title = locale('cl_lang_43'),
        menu = 'blacksmith_job_menu',
        options = {
            {
                title = locale('cl_lang_40'),
                icon = 'fa-solid fa-box',
                serverEvent = 'rex-blacksmith:server:openstorage',
                args = { 
                    blacksmithid = data.blacksmithid,
                    maxweight = Config.PlayerShareMaxWeight,
                    maxslots = Config.PlayerShareMaxSlots,
                    name = Config.PlayerShareName,
                    storetype = 'playershare'
                },
                arrow = true
            },
            {
                title = locale('cl_lang_41'),
                icon = 'fa-solid fa-box',
                serverEvent = 'rex-blacksmith:server:openstorage',
                args = { 
                    blacksmithid = data.blacksmithid,
                    maxweight = Config.CraftingMaxWeight,
                    maxslots = Config.CraftingMaxSlots,
                    name = Config.CraftingName,
                    storetype = 'crafting'
                },
                arrow = true
            },
            {
                title = locale('cl_lang_42'),
                icon = 'fa-solid fa-box',
                serverEvent = 'rex-blacksmith:server:openstorage',
                args = { 
                    blacksmithid = data.blacksmithid,
                    maxweight = Config.StockMaxWeight,
                    maxslots = Config.StockMaxSlots,
                    name = Config.StockName,
                    storetype = 'stock'
                },
                arrow = true
            },
        }
    })
    lib.showContext('owner_storage_menu')
end)

---------------------------------------------
-- customer blacksmith storage menu
---------------------------------------------
RegisterNetEvent('rex-blacksmith:client:storageplayershare', function(data)
    lib.registerContext({
        id = 'customer_storage_menu',
        title = locale('cl_lang_43'),
        menu = 'blacksmith_customer_menu',
        options = {
            {
                title = locale('cl_lang_40'),
                icon = 'fa-solid fa-box',
                serverEvent = 'rex-blacksmith:server:openstorage',
                args = { 
                    blacksmithid = data.blacksmithid,
                    maxweight = Config.PlayerShareMaxWeight,
                    maxslots = Config.PlayerShareMaxSlots,
                    name = Config.PlayerShareName,
                    storetype = 'playershare'
                },
                arrow = true
            },
        }
    })
    lib.showContext('customer_storage_menu')
end)
