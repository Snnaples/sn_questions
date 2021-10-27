
local Proxy = module("vrp", "lib/Proxy")

local vRP = Proxy.getInterface('vRP');

local internalQuestions = {}

local removeInternalQuestion = function(user_id)
  for i = 1, #internalQuestions do
     if internalQuestions[i].asker == user_id then table.remove(internalQuestions,i) end;
  end
end

local findInternalQuestion = function(user_id)
  for i = 1, #internalQuestions do
    if internalQuestions[i].asker == user_id then return internalQuestions[i] end;
  end
  return nil
end

RegisterCommand('n', function(player,args,r)

  local questionMessage = r:sub(3)
  local user_id = vRP.getUserId{player}

  if not user_id then return end;
  if not questionMessage then return TriggerClientEvent('chatMessage', player, '^1Eroare^0: Intrebare prea scurta!') end;  
  if #questionMessage <= 5 then return TriggerClientEvent('chatMessage', player, '^1Eroare^0: Intrebare prea scurta!') end;
  if findInternalQuestion(user_id) ~= nil then return TriggerClientEvent('chatMessage', player, '^1Eroare^0: Ai pus deja o intrebare!') end; 

  local name = GetPlayerName(player)

  table.insert(internalQuestions,{
    asker = user_id,
    question = questionMessage,
    askerSource = player,
    askerName = name
  })


  TriggerClientEvent('chatMessage', player,'[^6RT^0] Un membru staff iti va raspunde in curand!')
  vRP.sendStaffMessage{'[^4INTREBARE^0] ' .. name .. ' [^4' .. user_id .. '^0] ' ..' a intrebat: ' .. questionMessage}

end)

RegisterCommand('questions', function(player)
  local user_id = vRP.getUserId{player}

  if not vRP.isUserTrialHelper{user_id} then return TriggerClientEvent('chatMessage', player, '^1Eroare^0: Nu ai acces la aceasta comanda!') end;
  if #internalQuestions == 0 then return TriggerClientEvent('chatMessage', player, '^1Eroare^0: Nu sunt intrebari active!') end;

  for _,qObject in pairs(internalQuestions) do
    TriggerClientEvent('chatMessage', player,'[^6RT^0] ' .. qObject.askerName .. ' [^6' .. qObject.asker .. '^0]: ' .. qObject.question   )
  end

end)

RegisterCommand('nr', function(player,args,r)
  local user_id = vRP.getUserId{player}

  if not vRP.isUserTrialHelper{user_id} then return TriggerClientEvent('chatMessage', player, '^1Eroare^0: Nu ai acces la aceasta comanda!') end;
  
  local askerId = tonumber(args[1])
  if not askerId then return TriggerClientEvent('chatMessage', player, '^1Eroare^0: /nr <id>') end;
  if askerId == '' or askerId <= 0 then return TriggerClientEvent('chatMessage', player, '^1Eroare^0: /nr <id>') end;

  local qObject = findInternalQuestion(askerId)
  local lengthOfAskerId = args[1]:len()

  local answerString = r:sub(4 + lengthOfAskerId )

  if #answerString <= 3 then return TriggerClientEvent('chatMessage', player, '^1Eroare^0: Raspuns prea scurt!') end;
  if not answerString then return TriggerClientEvent('chatMessage', player, '^1Eroare^0: Raspuns invalid!') end;

  if type(qObject) ~= 'table' then return TriggerClientEvent('chatMessage', player, '^1Eroare^0: Acest id nu are o intrebare activa!') end;

  TriggerClientEvent('chatMessage', qObject.askerSource, '[^6RT^0] Un membru staff ti-a raspuns: ' .. answerString  )
  TriggerClientEvent('chatMessage', player,'I-ai raspuns lui ^1' .. qObject.askerName .. '^0: ' .. answerString )
  removeInternalQuestion(askerId)
end)




