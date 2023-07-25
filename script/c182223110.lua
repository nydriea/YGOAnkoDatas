--神祝姬 阿雅
local m=182223110
local cm=_G["c"..m]
xpcall(function() require("expansions/script/NY-GRACEIA") end,function() require("script/NY-GRACEIA") end)
function cm.initial_effect(c)
    gracia.GenerateToken(c,182224005)
    gracia.RealeaseTokenToSpecialSummon(c,TYPE_LINK)
	
    --这张卡被送去墓地的场合才能发动。
    --这个回合，自己在通常召唤外加上只有1次，自己主要阶段可以把1只怪兽召唤。
    local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,m+2)
    e1:SetCondition(cm.condition)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
end
function cm.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFlagEffect(tp,m)==0 and Duel.GetTurnPlayer()==tp
end
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.IsPlayerCanSummon(tp) and Duel.IsPlayerCanAdditionalSummon(tp) end
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,2))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
	e1:SetTargetRange(LOCATION_HAND+LOCATION_MZONE,0)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
	Duel.RegisterFlagEffect(tp,m,RESET_PHASE+PHASE_END,0,1)
end