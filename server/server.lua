local RSGCore = exports['rsg-core']:GetCoreObject()
lib.locale()

---------------------------------------------
-- increase xp fuction
---------------------------------------------
local function IncreasePlayerXP(source, xpGain, xpType)
    local Player = RSGCore.Functions.GetPlayer(source)
    if Player then
        local currentXP = Player.Functions.GetRep(xpType)
        local newXP = currentXP + xpGain
        Player.Functions.AddRep(xpType, newXP)
        TriggerClientEvent('ox_lib:notify', source, { title = string.format(locale('sv_lang_12'), xpGain, xpType), type = 'inform', duration = 7000 })
    end
end

---------------------------------------------
-- check player xp
---------------------------------------------
RSGCore.Functions.CreateCallback('rex-blacksmith:server:checkxp', function(source, cb, xptype)
    local Player = RSGCore.Functions.GetPlayer(source)
    if Player then
        local currentXP = Player.Functions.GetRep(xptype)
        cb(currentXP)
    end
end)

---------------------------------------------
-- admin command for blacksmith reset /resetblacksmith blacksmithid
---------------------------------------------
RSGCore.Commands.Add('resetblacksmith', locale('sv_lang_7'), { { name = 'blacksmithid', help = locale('sv_lang_8') } }, true, function(source, args)

    local blacksmithid = args[1]
    local result = MySQL.prepare.await("SELECT COUNT(*) as count FROM rex_blacksmith WHERE blacksmithid = ?", { blacksmithid })

    if result == 1 then
        -- update rex_blacksmith table
        MySQL.update('UPDATE rex_blacksmith SET owner = ? WHERE blacksmithid = ?', {'vacant', blacksmithid})
        MySQL.update('UPDATE rex_blacksmith SET rent = ? WHERE blacksmithid = ?', {0, blacksmithid})
        MySQL.update('UPDATE rex_blacksmith SET rent = ? WHERE blacksmithid = ?', {0, blacksmithid})
        MySQL.update('UPDATE rex_blacksmith SET status = ? WHERE blacksmithid = ?', {'closed', blacksmithid})
        MySQL.update('UPDATE rex_blacksmith SET money = ? WHERE blacksmithid = ?', {0.00, blacksmithid})
        -- delete stock in rex_blacksmith_stock
        MySQL.Async.execute('DELETE FROM rex_blacksmith_stock WHERE blacksmithid = ?', { blacksmithid })
        -- update funds in management_funds
        MySQL.update('UPDATE management_funds SET amount = ? WHERE job_name = ?', {0, blacksmithid})
        -- delete job in player_jobs
        MySQL.Async.execute('DELETE FROM player_jobs WHERE job = ?', { blacksmithid })
        -- delete stashes
        MySQL.Async.execute('DELETE FROM inventories WHERE identifier = ?', { blacksmithid..'_crafting' })
        MySQL.Async.execute('DELETE FROM inventories WHERE identifier = ?', { blacksmithid..'_playershare' })
        MySQL.Async.execute('DELETE FROM inventories WHERE identifier = ?', { blacksmithid..'_stock_' })
        TriggerClientEvent('ox_lib:notify', source, {title = locale('sv_lang_9'), type = 'success', duration = 7000 })
    else
        TriggerClientEvent('ox_lib:notify', source, {title = locale('sv_lang_10'), type = 'error', duration = 7000 })
    end

end, 'admin')

---------------------------------------------
-- count owned blacksmiths
---------------------------------------------
RSGCore.Functions.CreateCallback('rex-blacksmith:server:countowned', function(source, cb)
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)
    local citizenid = Player.PlayerData.citizenid
    local result = MySQL.prepare.await("SELECT COUNT(*) as count FROM rex_blacksmith WHERE owner = ?", { citizenid })
    if result then
        cb(result)
    else
        cb(nil)
    end
end)

---------------------------------------------
-- get data
---------------------------------------------
RSGCore.Functions.CreateCallback('rex-blacksmith:server:getblacksmithdata', function(source, cb, blacksmithid)
    MySQL.query('SELECT * FROM rex_blacksmith WHERE blacksmithid = ?', { blacksmithid }, function(result)
        if result[1] then
            cb(result)
        else
            cb(nil)
        end
    end)
end)

---------------------------------------------
-- check stock
---------------------------------------------
RSGCore.Functions.CreateCallback('rex-blacksmith:server:checkstock', function(source, cb, blacksmithid)
    MySQL.query('SELECT * FROM rex_blacksmith_stock WHERE blacksmithid = ?', { blacksmithid }, function(result)
        if result[1] then
            cb(result)
        else
            cb(nil)
        end
    end)
end)

---------------------------------------------
-- update stock or add new stock
---------------------------------------------
RegisterNetEvent('rex-blacksmith:server:newstockitem', function(blacksmithid, item, amount, price)
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)
    local itemcount = MySQL.prepare.await("SELECT COUNT(*) as count FROM rex_blacksmith_stock WHERE blacksmithid = ? AND item = ?", { blacksmithid, item })
    if itemcount == 0 then
        MySQL.Async.execute('INSERT INTO rex_blacksmith_stock (blacksmithid, item, stock, price) VALUES (@blacksmithid, @item, @stock, @price)',
        {
            ['@blacksmithid'] = blacksmithid,
            ['@item'] = item,
            ['@stock'] = amount,
            ['@price'] = price
        })
        Player.Functions.RemoveItem(item, amount)
        TriggerClientEvent('rsg-inventory:client:ItemBox', src, RSGCore.Shared.Items[item], 'remove', amount)
    else
        MySQL.query('SELECT * FROM rex_blacksmith_stock WHERE blacksmithid = ? AND item = ?', { blacksmithid, item }, function(data)
            local stockupdate = (amount + data[1].stock)
            MySQL.update('UPDATE rex_blacksmith_stock SET stock = ? WHERE blacksmithid = ? AND item = ?',{stockupdate, blacksmithid, item})
            MySQL.update('UPDATE rex_blacksmith_stock SET price = ? WHERE blacksmithid = ? AND item = ?',{price, blacksmithid, item})
            Player.Functions.RemoveItem(item, amount)
            TriggerClientEvent('rsg-inventory:client:ItemBox', src, RSGCore.Shared.Items[item], 'remove', amount)
        end)
    end
end)

---------------------------------------------
-- buy item amount / add money to account
---------------------------------------------
RegisterNetEvent('rex-blacksmith:server:buyitem', function(amount, item, newstock, price, label, blacksmithid)
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)
    local money = Player.PlayerData.money[Config.Money]
    local totalcost = (price * amount)
    if money >= totalcost then
        MySQL.update('UPDATE rex_blacksmith_stock SET stock = ? WHERE blacksmithid = ? AND item = ?', {newstock, blacksmithid, item})
        Player.Functions.RemoveMoney(Config.Money, totalcost)
        Player.Functions.AddItem(item, amount)
        TriggerClientEvent('rsg-inventory:client:ItemBox', src, RSGCore.Shared.Items[item], 'add', amount)
        MySQL.query('SELECT * FROM rex_blacksmith WHERE blacksmithid = ?', { blacksmithid }, function(data2)
            local moneyupdate = (data2[1].money + totalcost)
            MySQL.update('UPDATE rex_blacksmith SET money = ? WHERE blacksmithid = ?',{moneyupdate, blacksmithid})
        end)
    else
        TriggerClientEvent('ox_lib:notify', src, {title = locale('sv_lang_1')..Config.Money, type = 'error', duration = 7000 })
    end
end)

---------------------------------------------
-- remove stock item
---------------------------------------------
RegisterNetEvent('rex-blacksmith:server:removestockitem', function(data)
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)
    MySQL.query('SELECT * FROM rex_blacksmith_stock WHERE blacksmithid = ? AND item = ?', { data.blacksmithid, data.item }, function(result)
        Player.Functions.AddItem(result[1].item, result[1].stock)
        TriggerClientEvent('rsg-inventory:client:ItemBox', src, RSGCore.Shared.Items[result[1].item], 'remove', result[1].stock)
        MySQL.Async.execute('DELETE FROM rex_blacksmith_stock WHERE id = ?', { result[1].id })
    end)
end)

---------------------------------------------
-- get money
---------------------------------------------
RSGCore.Functions.CreateCallback('rex-blacksmith:server:getmoney', function(source, cb, blacksmithid)
    MySQL.query('SELECT * FROM rex_blacksmith WHERE blacksmithid = ?', { blacksmithid }, function(result)
        if result[1] then
            cb(result[1])
        else
            cb(nil)
        end
    end)
end)

---------------------------------------------
-- withdraw money
---------------------------------------------
RegisterNetEvent('rex-blacksmith:server:withdrawfunds', function(amount, blacksmithid)
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)
    MySQL.query('SELECT * FROM rex_blacksmith WHERE blacksmithid = ?', {blacksmithid} , function(result)
        if result[1] ~= nil then
            if result[1].money >= amount then
                local updatemoney = (result[1].money - amount)
                MySQL.update('UPDATE rex_blacksmith SET money = ? WHERE blacksmithid = ?', { updatemoney, blacksmithid })
                Player.Functions.AddMoney(Config.Money, amount)
            end
        end
    end)
end)

---------------------------------------------
-- rent blacksmith
---------------------------------------------
RegisterNetEvent('rex-blacksmith:server:rentblacksmith', function(blacksmithid)
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)
    local money = Player.PlayerData.money[Config.Money]
    local citizenid = Player.PlayerData.citizenid
    if money > Config.RentStartup then
        Player.Functions.RemoveMoney(Config.Money, Config.RentStartup)
        Player.Functions.SetJob(blacksmithid, 2)
        if Config.LicenseRequired then
            Player.Functions.RemoveItem('blacksmithlicence', 1)
            TriggerClientEvent('rsg-inventory:client:ItemBox', src, RSGCore.Shared.Items['blacksmithlicence'], 'remove', 1)
        end
        MySQL.update('UPDATE rex_blacksmith SET owner = ? WHERE blacksmithid = ?',{ citizenid, blacksmithid })
        MySQL.update('UPDATE rex_blacksmith SET rent = ? WHERE blacksmithid = ?',{ Config.RentStartup, blacksmithid })
        MySQL.update('UPDATE rex_blacksmith SET status = ? WHERE blacksmithid = ?', {'open', blacksmithid})
        TriggerClientEvent('ox_lib:notify', src, {title = locale('sv_lang_2'), type = 'success', duration = 7000 })
    else
        TriggerClientEvent('ox_lib:notify', src, {title = locale('sv_lang_3'), type = 'error', duration = 7000 })
    end
end)

---------------------------------------------
-- add blacksmith rent
---------------------------------------------
RegisterNetEvent('rex-blacksmith:server:addrentmoney', function(rentmoney, blacksmithid)
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)
    MySQL.query('SELECT * FROM rex_blacksmith WHERE blacksmithid = ?', { blacksmithid }, function(result)
        local currentrent = result[1].rent
        local rentupdate = (currentrent + rentmoney)
        if rentupdate >= Config.MaxRent then
            TriggerClientEvent('ox_lib:notify', src, {title = 'Can\'t add that much rent!', type = 'error', duration = 7000 })
        else
            Player.Functions.RemoveMoney(Config.Money, rentmoney)
            MySQL.update('UPDATE rex_blacksmith SET rent = ? WHERE blacksmithid = ?',{ rentupdate, blacksmithid })
            MySQL.update('UPDATE rex_blacksmith SET status = ? WHERE blacksmithid = ?', {'open', blacksmithid})
            TriggerClientEvent('ox_lib:notify', src, {title = locale('sv_lang_4'), type = 'success', duration = 7000 })
        end
    end)
end)

---------------------------------------------
-- check player has the ingredients
---------------------------------------------
RSGCore.Functions.CreateCallback('rex-blacksmith:server:checkingredients', function(source, cb, ingredients)
    local src = source
    local hasItems = false
    local icheck = 0
    local Player = RSGCore.Functions.GetPlayer(src)
    for k, v in pairs(ingredients) do
        if exports['rsg-inventory']:GetItemCount(src, v.item) >= v.amount then
            icheck = icheck + 1
            if icheck == #ingredients then
                cb(true)
            end
        else
            TriggerClientEvent('ox_lib:notify', src, {title = locale('sv_lang_5'), type = 'error', duration = 7000 })
            cb(false)
            return
        end
    end
end)

---------------------------------------------
-- finish crafting / give item
---------------------------------------------
RegisterNetEvent('rex-blacksmith:server:finishcrafting', function(data)
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)
    local receive = data.receive
    local giveamount = data.giveamount
    for k, v in pairs(data.ingredients) do
        Player.Functions.RemoveItem(v.item, v.amount)
    end
    Player.Functions.AddItem(receive, giveamount)
    Player.Functions.RemoveItem(data.bpc, 1)
    TriggerClientEvent('rsg-inventory:client:ItemBox', src, RSGCore.Shared.Items[data.bpc], 'remove', 1)
    TriggerClientEvent('rsg-inventory:client:ItemBox', src, RSGCore.Shared.Items[receive], 'add', giveamount)
    IncreasePlayerXP(src, 1, 'crafting')
end)

---------------------------------------------
-- blacksmith storage
---------------------------------------------
RegisterServerEvent('rex-blacksmith:server:openstorage', function(data)
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)
    if not Player then return end
    local storagedata = { label = data.name, maxweight = data.maxweight, slots = data.maxslots }
    local stashName = data.blacksmithid ..'_'.. data.storetype
    exports['rsg-inventory']:OpenInventory(src, stashName, storagedata)
end)

---------------------------------------------
-- blacksmith rent system
---------------------------------------------
lib.cron.new(Config.BlacksmithCronJob, function ()

    if not Config.EnableRentSystem then
        print(locale('sv_lang_11'))
        return
    end

    local result = MySQL.query.await('SELECT * FROM rex_blacksmith')

    if not result then goto continue end

    for i = 1, #result do

        local blacksmithid = result[i].blacksmithid
        local owner = result[i].owner
        local rent = result[i].rent
        local money = result[i].money

        if rent >= 1 then
            local moneyupdate = (rent - Config.RentPerHour)
            MySQL.update('UPDATE rex_blacksmith SET rent = ? WHERE blacksmithid = ?', {moneyupdate, blacksmithid})
            MySQL.update('UPDATE rex_blacksmith SET status = ? WHERE blacksmithid = ?', {'open', blacksmithid})
        else
            MySQL.update('UPDATE rex_blacksmith SET status = ? WHERE blacksmithid = ?', {'closed', blacksmithid})
        end

    end

    ::continue::

    if Config.ServerNotify then
        print(locale('sv_lang_6'))
    end

end)
