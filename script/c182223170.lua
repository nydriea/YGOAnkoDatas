--神祝圣像 女神伊婕丝
local m=182223170
local cm=_G["c"..m]
function cm.initial_effect(c)
    --Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	e1:SetCondition(aux.dscon)
	c:RegisterEffect(e1)

	--对方场上的怪兽的攻击力·守备力下降500。
    local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(0,LOCATION_MZONE)
	e2:SetValue(500)
	c:RegisterEffect(e2)
    local e3=e2:Clone()
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e3)

    --这张卡被送去墓地的场合，从卡组把1只「神祝」怪兽送去墓地才能发动。
    --在自己场上把1只「神祝衍生物」（天使族·光·4星·攻/守0）特殊召唤。
    --这个效果的发动后，直到回合结束时自己不是“神祝”怪兽不能从额外卡组特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetCountLimit(1,m)
	e4:SetCost(cm.e4cost)
	e4:SetTarget(cm.e4tg)
	e4:SetOperation(cm.e4op)
	c:RegisterEffect(e4)

    --自己·对方的主要阶段，从自己的手卡·场上把1只「神祝」怪兽解放才能发动。
    --进行1次投掷硬币。
    --表的场合，从自己的手卡·场上·卡组选1张「神祝」的魔法·陷阱卡送去墓地。
    --那之后，可以选对方墓地的1只怪兽回到卡组。
    --里的场合，从自己的场上·墓地·除外选1张「神祝」魔法·陷阱卡回到卡组。
    --那之后，可以选自己卡组的1只怪兽送去墓地。
    local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(146746,0))
	e5:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e5:SetType(EFFECT_TYPE_QUICK_O)
	e5:SetCode(EVENT_FREE_CHAIN)
	e5:SetHintTiming(0,TIMING_MAIN_END)
	e5:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCountLimit(1,146746)
	e5:SetCondition(cm.e5con)
	e5:SetCost(cm.e5cost)
	e5:SetTarget(cm.e5tg)
	e5:SetOperation(cm.e5op)
	c:RegisterEffect(e5)
end

--#region e4
function cm.e4costfilter(fc)
    return fc:IsSetCard(0xf79) and fc:IsAbleToGrave() and fc:IsType(TYPE_MONSTER)
end
function cm.e4cost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(GenerateTokenCostFilter,tp,LOCATION_DECK,0,1,nil,e:GetHandler()) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local g=Duel.SelectMatchingCard(tp,GenerateTokenCostFilter,tp,LOCATION_DECK,0,1,1,nil,e:GetHandler())
    Duel.SendtoGrave(g,REASON_COST)
end
function cm.e4tg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and
        Duel.IsPlayerCanSpecialSummonMonster(tp,tokenCode,0,TYPES_TOKEN_MONSTER,0,0,4,RACE_FAIRY,ATTRIBUTE_LIGHT) end
    Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0)
end
function cm.e4splimit(e,lc,sump,sumtype,sumpos,targetp,se)
    return not lc:IsSetCard(0xf79) and lc:IsLocation(LOCATION_EXTRA)
end
function cm.e4op(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0
        or not Duel.IsPlayerCanSpecialSummonMonster(tp,tokenCode,0,TYPES_TOKEN_MONSTER,0,0,4,RACE_FAIRY,ATTRIBUTE_LIGHT) then return end
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e1:SetTargetRange(1,0)
    e1:SetTarget(cm.e4splimit)
    e1:SetReset(RESET_PHASE+PHASE_END)
    Duel.RegisterEffect(e1,tp)
    local token=Duel.CreateToken(tp,182224001)
    Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP)
end
--#endregion

--#region e5
function cm.e5con(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2
end
function cm.e5costfilter(c,tp)
	return c:IsType(TYPE_MONSTER) and c:IsReleasable() and c:IsSetCard(0xf79)
end
function cm.e5cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cm.e5costfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
	local g=Duel.SelectMatchingCard(tp,cm.e5costfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil,tp)
	Duel.Release(g,REASON_COST)
end
function cm.e5tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_COIN,nil,0,tp,1)
end
function cm.e5opfrontfilter1(c)
    return c:IsSetCard(0xf79) and c:IsAbleToGrave() and c:IsType(TYPE_SPELL+TYPE_TRAP)
end
function cm.e5opfrontfilter2(c)
    return c:IsType(TYPE_MONSTER) and c:IsAbleToDeck()
end
function cm.e5opinsidefilter1(c)
    return c:IsSetCard(0xf79) and c:IsAbleToDeck() and c:IsType(TYPE_SPELL+TYPE_TRAP)
end
function cm.e5opinsidefilter2(c)
    return c:IsType(TYPE_MONSTER) and c:IsAbleToGrave()
end
function cm.e5op(e,tp,eg,ep,ev,re,r,rp)
	local coin=Duel.TossCoin(tp,1)
	if coin==1 then
		local fg1=Duel.GetMatchingGroup(cm.e5opfrontfilter1,tp,LOCATION_HAND+LOCATION_SZONE+LOCATION_DECK,0,nil)
        if fg1:GetCount()>0 then
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
            local tgc=fg1:Select(tp,1,1)
            local fg2=Duel.GetMatchingGroup(cm.e5opfrontfilter2,tp,0,LOCATION_GRAVE,nil)
            if (Duel.SendtoGrave(tgc,REASON_EFFECT) and fg2:GetCount()>0) then
                Duel.BreakEffect()
                Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
                local tdc=fg2:Select(tp,1,1)
                Duel.SendtoDeck(tdc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
            end
        end
    else
		local ig1=Duel.GetMatchingGroup(cm.e5opfrontfilter1,tp,LOCATION_SZONE+LOCATION_GRAVE+LOCATION_REMOVED,0,nil)
        if ig1:GetCount()>0 then
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
            local tdc=ig1:Select(tp,1,1)
            local ig2=Duel.GetMatchingGroup(cm.e5opfrontfilter2,tp,LOCATION_DECK,0,nil)
            if (Duel.SendtoDeck(tdc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT) and ig2:GetCount()>0) then
                Duel.BreakEffect()
                Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
                local tgc=ig2:Select(tp,1,1)
                Duel.SendtoGrave(tgc,REASON_EFFECT)
            end
        end
	end
end
--#endregion