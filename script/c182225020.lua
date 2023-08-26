--王战侍女 甘格洛特
local m=182225020
local cm=_G["c"..m]
function cm.initial_effect(c)
	c:SetUniqueOnField(1,0,m)
    c:SetSPSummonOnce(m)

    --自己场上没有怪兽或只有「王战」怪兽存在的场合，这张卡可以从手卡特殊召唤。
    local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(cm.e1con)
	c:RegisterEffect(e1)

    --从自己墓地把1张「王战」卡除外才能发动。
    --从卡组把1张「王战」卡加入手卡或送去墓地，这张卡的等级变为9星。
    local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,m)
	e2:SetCost(cm.e2cost)
	e2:SetTarget(cm.e2tg)
	e2:SetOperation(cm.e2op)
	c:RegisterEffect(e2)
end

--#region e1
function cm.e1filter(c)
	return c:IsFaceup() and c:IsSetCard(0x134)
end
function cm.e1con(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and (Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0) or Duel.GetMatchingGroupCount(cm.e1filter,tp,LOCATION_MZONE,0,nil))
end
--#endregion

--#endregion e2
function cm.e2costfilter(c,tp)
	return c:IsSetCard(0x134) and c:IsAbleToRemoveAsCost() and Duel.IsExistingMatchingCard(cm.e2targetfilter,tp,LOCATION_DECK,0,1,nil)
end
function cm.e2targetfilter(c)
	return c:IsSetCard(0x134) and c:IsAbleToHand()
end
function cm.e2cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cm.e2costfilter,tp,LOCATION_GRAVE,0,1,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local tc=Duel.SelectMatchingCard(tp,cm.e2costfilter,tp,LOCATION_GRAVE,0,1,1,nil,tp):GetFirst()
	e:SetLabel(tc:GetCode())
	Duel.Remove(tc,POS_FACEUP,REASON_COST)
end
function cm.e2tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function cm.e2op(e,tp,eg,ep,ev,re,r,rp)
	local code=e:GetLabel()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,cm.e2targetfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
--#endregion