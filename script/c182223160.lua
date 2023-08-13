--神祝法咒 烈风之矢
local m=182223160
local cm=_G["c"..m]
function cm.initial_effect(c)
    --自己场上有「神祝」怪兽存在的场合，以对方场上1只表侧表示的卡为对象才能发动。
    --那张卡的效果直到回合结束时无效。
    --自己场上有8星·4阶·连接3以上的「神祝」怪兽存在的场合，
    --可以再选对方场上的1张卡，那张卡的效果直到回合结束时无效。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e1:SetCondition(cm.con)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.activate)
	c:RegisterEffect(e1)

    --自己场上有8星·4阶·连接3以上的「神祝」怪兽存在的场合，这张卡的发动从手卡也能用。
    local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	e2:SetCondition(cm.handcon)
	c:RegisterEffect(e2)
end

--#region e1
function cm.filter(c)
	return c:IsFaceup() and c:IsSetCard(0xf79) and
        (c:IsLevelAbove(8) or c:IsRankAbove(4) or  c:IsLinkAbove(3))
end
function cm.con(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(cm.filter,tp,LOCATION_MZONE,0,1,nil)
end
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and aux.NegateAnyFilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(aux.NegateAnyFilter,tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)
	Duel.SelectTarget(tp,aux.NegateAnyFilter,tp,0,LOCATION_ONFIELD,1,1,nil)
end
function cm.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsCanBeDisabledByEffect(e) then
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
        local sg=Duel.GetMatchingGroup(aux.NegateAnyFilter,tp,0,LOCATION_ONFIELD,1,1,nil)
		if Duel.IsExistingMatchingCard(cm.filter,tp,LOCATION_MZONE,0,1,nil) and sg:GetCount()>0
            and Duel.SelectYesNo(tp,aux.Stringid(m,0)) then
                Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)
                local sc=sg:Select(tp,1,1,nil):GetFirst()
                Duel.NegateRelatedChain(sc,RESET_TURN_SET)
				local e3=e1:Clone()
				local e4=e1:Clone()
                sc:RegisterEffect(e3)
                sc:RegisterEffect(e4)
		end
	end
end
--#endregion

--#region e2
function cm.handcon(e)
	return Duel.IsExistingMatchingCard(cm.filter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
--#endregion