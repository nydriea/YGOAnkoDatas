--神祝大天使 塔丽娅·阿拉瑞尔
local m=182223140
local cm=_G["c"..m]
xpcall(function() require("expansions/script/NY-GRACEIA") end,function() require("script/NY-GRACEIA") end)
function cm.initial_effect(c)
	c:EnableReviveLimit()
	c:SetUniqueOnField(1,0,m)
	
    --把这张卡以外的自己场上1只表侧表示的「神祝」怪兽除外才能发动。
    --从卡组把1张「神祝」魔法·陷阱卡加入手卡。
    --为这个效果发动而把8星·4阶·连接3以上的「神祝」怪兽除外的场合，
    --可以再从卡组把1张和那个卡名不同的「神祝」魔法·陷阱卡加入手卡。
    local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,m)
	e1:SetCost(cm.e1cost)
	e1:SetTarget(cm.e1tg)
	e1:SetOperation(cm.e1op)
	c:RegisterEffect(e1)

    --1回合1次，自己对「神祝」怪兽召唤·特殊召唤成功的场合才能发动。
    --把对方的额外卡组确认，选那之内的1只怪兽里侧表示除外。
    local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,EFFECT_COUNT_CODE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCondition(cm.e2con)
	e2:SetTarget(cm.e2tg)
	e2:SetOperation(cm.e2op)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
end

--#region e1
function cm.e1costfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(gracia.CardSet) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
        and Duel.GetMZoneCount(tp,c,tp,LOCATION_REASON_CONTROL)>0
end
function cm.e1cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetAttackAnnouncedCount()==0
		and Duel.IsExistingMatchingCard(cm.e1costfilter,tp,LOCATION_MZONE,0,1,e:GetHandler(),tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,cm.e1costfilter,tp,LOCATION_MZONE,0,1,1,e:GetHandler(),tp)
    e:SetLabelObject(g:GetFirst())
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function cm.e1targetfilter(c)
	return c:IsSetCard(gracia.CardSet) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
function cm.e1tg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.IsExistingMatchingCard(cm.e1targetfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function cm.e1op(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,cm.e1targetfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
        local costcard=e:GetLabelObject()
        local g2=Duel.GetMatchingGroup(cm.e1targetfilter,tp,LOCATION_DECK,0,nil)
        if (costcard:IsLevelAbove(8) or  costcard:IsRankAbove(4) or costcard:IsLinkAbove(3)) and g2:GetCount()>0
            and Duel.SelectYesNo(tp,aux.Stringid(m,1)) then
				Duel.BreakEffect()
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
				local sg=g2:Select(tp,1,1,nil)
				Duel.SendtoHand(sg,nil,REASON_EFFECT)
				Duel.ConfirmCards(1-tp,sg)
        end
	end
end
--#endregion

--#region e2
function cm.e2con(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(Card.IsSummonPlayer,1,nil, tp)
end
function cm.e2triggerfilter(c,e,tp)
	return c:IsSetCard(gracia.CardSet) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function cm.e2targetfilter(c,tp)
	return c:IsAbleToRemove(tp,POS_FACEDOWN)
end
function cm.e2tg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and cm.e2triggerfilter(chkc,e,tp) end
    if chk==0 then return Duel.IsExistingMatchingCard(cm.e2targetfilter,tp,0,LOCATION_EXTRA,1,nil,tp) end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,1-tp,LOCATION_EXTRA)
end
function cm.e2op(e,tp,eg,ep,ev,r,r,rp)
	local g=Duel.GetFieldGroup(tp,0,LOCATION_EXTRA)
	Duel.ConfirmCards(tp,g)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local sg=g:FilterSelect(tp,cm.e2targetfilter,1,1,nil,tp)
	if #sg>0 then
		Duel.Remove(sg,POS_FACEDOWN,REASON_EFFECT)
	end
	Duel.ShuffleExtra(1-tp)
end
--#endregion