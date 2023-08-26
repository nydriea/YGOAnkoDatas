--神碑王战 沃坦王
local m=182225010
local cm=_G["c"..m]
function cm.initial_effect(c)
	c:SetUniqueOnField(1,0,m)
	c:EnableReviveLimit()
    aux.AddXyzProcedure(c,nil,9,3,nil,nil,99)

    local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(cm.e1filter)
	c:RegisterEffect(e1)

    --1回合1次，自己·对方的结束阶段才能发动。
    --从墓地把1张「神碑」速攻魔法卡在自己场上盖放。
    --这个效果盖放的卡从场上离开的场合除外。
    local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetCountLimit(1)
	e2:SetTarget(cm.e2tg)
	e2:SetOperation(cm.e2op)
	c:RegisterEffect(e2)

    --把这张卡1个超量素材取除才能发动。
    --从卡组把1张「王战的舞台」或「神碑之泉」加入手卡。
    --这个效果发动后的回合，自己不是「王战」或「神碑」怪兽不能特殊召唤。
    local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,m)
	e3:SetCost(cm.e3cost)
	e3:SetTarget(cm.e3tg)
	e3:SetOperation(cm.e3op)
	c:RegisterEffect(e3)
end

--#region e1
function cm.e1filter(e,te)
	return te:GetOwner()~=e:GetOwner()
end
--#endregion e1

--#region e2
function cm.e2filter(c,tp)
	return c:IsType(TYPE_QUICKPLAY+TYPE_SPELL) and c: IsSetCard(0x17f) and c:IsSSetable(true)
        and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
end
function cm.e2tg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and cm.e2filter(chkc,tp) end
	if chk==0 then return Duel.IsExistingTarget(cm.e2filter,tp,0,LOCATION_GRAVE,1,nil,tp) end
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,nil,1,0,0)
end
function cm.e2op(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local tc=Duel.SelectMatchingCard(tp,cm.e2filter,tp,0,LOCATION_GRAVE,1,1,nil,tp):GetFirst()
	if tc:IsRelateToEffect(e) and Duel.SSet(tp,tc)~=0 then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		tc:RegisterEffect(e1,true)
	end
end
--#endregion

--#region e3
function cm.e3cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
function cm.e3filter(c)
	return (c:IsCode(38053381) or c:IsCode(92107604)) and c:IsAbleToHand()
end
function cm.e3tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cm.e3filter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_SEARCH+CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function cm.e3op(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,cm.e3filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,tp,REASON_EFFECT)
	end
end
--#endregion