--神祝姬 莉欧拉
local m=182223070
local cm=_G["c"..m]
xpcall(function() require("expansions/script/NY-GRACEIA") end,function() require("script/NY-GRACEIA") end)
function cm.initial_effect(c)
	gracia.GenerateToken(c,182224004)
    gracia.RealeaseTokenToSpecialSummon(c,TYPE_MONSTER)
	
    --这张卡被送去墓地的场合，以自己墓地1张「神祝」卡为对象才能发动。
    --那张卡加入手卡。
    local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(48424886,1))
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCountLimit(1,m+2)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
end

function cm.filter(c)
	return c:IsSetCard(gracia.CardSet) and c:IsAbleToHand()
end
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and cm.filter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(cm.filter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectTarget(tp,cm.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end