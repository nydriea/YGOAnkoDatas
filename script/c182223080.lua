--神祝大天使 莉欧拉·密海伊勒
local m=182223080
local cm=_G["c"..m]
xpcall(function() require("expansions/script/NY-GRACEIA") end,function() require("script/NY-GRACEIA") end)
function cm.initial_effect(c)
    c:SetUniqueOnField(1,0,m)

    --自己·对方的回合把自己墓地的1张「神祝」卡除外，以自己场上1只「神祝」怪兽为对象才能发动。
    --自己从卡组抽1张。这个回合，作为对象的怪兽不会成为效果的对象，不会被效果破坏。
    local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(3966653,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(cm.e1cost)
	e1:SetTarget(cm.e1tg)
	e1:SetOperation(cm.e1op)
	c:RegisterEffect(e1)
end

--#region e1
function cm.e1costfilter(c)
	return c:IsSetCard(gracia.CardSet) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
end
function cm.e1cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cm.e1costfilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,cm.e1costfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function cm.e1targetfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_MONSTER) and c:IsSetCard(gracia.CardSet)
end
function cm.e1tg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and cm.e1targetfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(cm.e1targetfilter,tp,LOCATION_MZONE,0,1,nil) 
        and Duel.IsPlayerCanDraw(tp,1) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,cm.e1targetfilter,tp,LOCATION_MZONE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function cm.e1op(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if tc:IsRelateToEffect(e) and tc:IsFaceup() and Duel.Draw (tp,1,REASON_EFFECT)~=0 then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
		e2:SetValue(1)
		tc:RegisterEffect(e2)
    end
end
--#endregion