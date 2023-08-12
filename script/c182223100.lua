--神祝圣像·女神迦莱蕾娜
local m=182223100
local cm=_G["c"..m]
function cm.initial_effect(c)
    local eactive=Effect.CreateEffect(c)
	eactive:SetType(EFFECT_TYPE_ACTIVATE)
	eactive:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(eactive)

    --1回合1次，自己主要阶段才能发动。
    --从自己卡组上面把3张卡翻开。可以从那之中选1张卡加入手卡。剩下的卡回到卡组。
    local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(cm.e1tg)
	e1:SetOperation(cm.e1op)
	c:RegisterEffect(e1)

    --自己场上的「神祝」怪兽成为对方的效果的对象时或者被选择作为对方怪兽的攻击对象时,
    --从手卡把一只的「神祝」怪兽除外才能发动。那个效果或者那次攻击无效。
    --那之后，双方把卡组洗切，从各自卡组最上面把1张卡翻开，
    --翻开的卡种类（魔法·陷阱·怪兽）相同的场合，根据卡种类的以下效果适用。
    --●怪兽：从卡组·额外卡组把1只8星·4阶·连接3的「神祝」怪兽无视召唤条件当作上级·仪式·融合·同调·超量·连接召唤特殊召唤。
    --●魔法：从自己墓地把1张「神祝」魔法卡发动，那张卡的发动与效果不能被无效化。
    --●陷阱：从卡组把1张「神祝」陷阱卡加入手牌，那张卡的发动从手卡也能用。
    local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EVENT_BE_BATTLE_TARGET)
	e2:SetCountLimit(1,m)
	e2:SetCondition(cm.e2con)
    e2:SetCost(cm.e2cost)
	e2:SetTarget(cm.e2tg)
	e2:SetOperation(cm.e2op)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCategory(CATEGORY_NEGATE+CATEGORY_SPECIAL_SUMMON)
	e3:SetCode(EVENT_BECOME_TARGET)
	e3:SetCondition(cm.e3con)
    e3:SetTarget(cm.e3tg)
    e3:SetOperation(cm.e3op)
	c:RegisterEffect(e3)

end

--#region e1
function cm.e1tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>=3
		and Duel.GetDecktopGroup(tp,3):IsExists(Card.IsAbleToHand,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function cm.e1op(e,tp,eg,ep,ev,re,r,rp)
	Duel.ConfirmDecktop(tp,3)
	local g=Duel.GetDecktopGroup(tp,3)
	if #g>0 then
		Duel.DisableShuffleCheck()
		Duel.Hint(HINT_SELECTMSG,p,HINTMSG_ATOHAND)
		local sc=g:Select(tp,1,1,nil):GetFirst()
		if sc:IsAbleToHand() then
			Duel.SendtoHand(sc,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,sc)
			Duel.ShuffleHand(tp)
            Duel.ShuffleDeck(tp)
		else
			Duel.SendtoGrave(sc,REASON_RULE)
		end
	end
end
--#endregion

--#region e2
function cm.e2con(e,tp,eg,ep,ev,re,r,rp)
	local at=Duel.GetAttackTarget()
	return at:IsControler(tp) and at:IsFaceup() and at:IsSetCard(0xf79)
end
function cm.e2costfilter(c)
	return c:IsSetCard(0xf79) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
end
function cm.e2cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cm.e2costfilter,tp,LOCATION_HAND,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,cm.e2costfilter,tp,LOCATION_HAND,0,1,1,nil)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function cm.e2tg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local tg=Duel.GetAttacker()
	if chkc then return chkc==tg end
	if chk==0 then return tg:IsOnField() and tg:IsCanBeEffectTarget(e) end
	Duel.SetTargetCard(tg)
end
function cm.e2op(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetAttacker()
	if tc:IsRelateToEffect(e) and Duel.NegateAttack() then
		Duel.BreakEffect()
		cm.aftereffect(e,tp,eg,ep,ev,re,r,rp)
	end
end
--#endregion

--#region e3
function cm.e3confilter(c,tp)
	return c:IsFaceup() and c:IsControler(tp) and c:IsLocation(LOCATION_MZONE) and c:IsSetCard(0xf79)
end
function cm.e3con(e,tp,eg,ep,ev,re,r,rp)
	if rp~=1-tp or not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	return g and g:IsExists(cm.e3confilter,1,nil,tp)
end
function cm.e3tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
end
function cm.e3op(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateEffect(ev) then
		Duel.BreakEffect()
		cm.aftereffect(e,tp,eg,ep,ev,re,r,rp)
    end
end
--#endregion

--#region aftereffect
function cm.aespfilter(c,e,tp)
    local lrlcheck= (c:IsLevel(8) and c:IsRank(4) and c:IsLink(3))
    return lrlcheck and c:IsType(TYPE_MONSTER) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
    and ((c:IsLocation(LOCATION_DECK) and Duel.GetMZoneCount(tp)>0)
        or (c:IsLocation(LOCATION_EXTRA) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0))
end
function cm.aeactivespellfilter(c,e,tp)
    return c:IsType(TYPE_SPELL) and c:GetActivateEffect():IsActivatable(tp,true,true)
end
function cm.aesearchtrapfilter(c,e,tp)
    return c:IsType(TYPE_TRAP) and c:IsAbleToHand()
end
function cm.aftereffect(e,tp,eg,ep,ev,re,r,rp)
	Duel.ShuffleDeck(tp)
	Duel.ShuffleDeck(1-tp)
	Duel.ConfirmDecktop(tp,1)
	Duel.ConfirmDecktop(1-tp,1)
    local tc1=Duel.GetDecktopGroup(tp,1):GetFirst()
	local tc2=Duel.GetDecktopGroup(1-tp,1):GetFirst()
	if not tc1 or not tc2 then return end
    if (tc1.IsType(TYPE_MONSTER) and tc2.IsType(TYPE_MONSTER)) then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
        local g=Duel.SelectMatchingCard(tp,cm.aespfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,1,nil,e,tp)
		local sc=g:GetFirst()
        if g:GetCount()>0 then
            local summontype = SUMMON_TYPE_SPECIAL
            if sc.IsType(TYPE_RITUAL) then
                summontype = SUMMON_TYPE_RITUAL
            elseif sc.IsType(TYPE_FUSION) then
                summontype = SUMMON_TYPE_FUSION
            elseif sc.IsType(TYPE_SYNCHRO) then
                summontype = SUMMON_TYPE_SYNCHRO
            elseif sc.IsType(TYPE_XYZ) then
                summontype = SUMMON_TYPE_XYZ
            elseif sc.IsType(TYPE_LINK) then
                summontype = SUMMON_TYPE_LINK
            end
			if summontype~=TYPE_RITUAL then
            	Duel.SpecialSummon(g,summontype,tp,tp,false,false,POS_FACEUP)
			else
            	Duel.SpecialSummon(g,summontype,tp,tp,false,true,POS_FACEUP)
        end
    elseif (tc1.IsType(TYPE_SPELL) and tc2.IsType(TYPE_SPELL)) then
        Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(m,1))
        local sc=Duel.SelectMatchingCard(tp,cm.aeactivespellfilter,tp,LOCATION_GRAVE,0,1,1,nil,tp):GetFirst()
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_CANNOT_INACTIVATE)
        e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
        e1:SetValue(1)
        c:RegisterEffect(e1)
        local e2=e1:Clone()
		e2:SetCode(EFFECT_CANNOT_DISEFFECT)
		e2:SetValue(1)
		tc:RegisterEffect(e2)
        Duel.MoveToField(sc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
        local te=sc:GetActivateEffect()
        local tep=sc:GetControler()
        local cost=te:GetCost()
        if cost then cost(te,tep,eg,ep,ev,re,r,rp,1) end
        Duel.RaiseEvent(sc,m,te,0,tp,tp,Duel.GetCurrentChain())
    elseif (tc1.IsType(TYPE_TRAP) and tc2.IsType(TYPE_TRAP)) then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
        local sc=Duel.SelectMatchingCard(tp,cm.aesearchtrapfilter,tp,LOCATION_GRAVE,0,1,1,nil,tp):GetFirst()
        if Duel.SendtoHand(sc,nil,REASON_EFFECT)~=0 then
            local e1=Effect.CreateEffect(c)
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_TRAP_ACT_IN_HAND)
            sc:RegisterEffect(e1)
        end
    end
end
--#endregion