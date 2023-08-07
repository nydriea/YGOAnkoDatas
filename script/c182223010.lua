--神祝姬 蜜莉恩
local m=182223010
local cm=_G["c"..m]
function cm.initial_effect(c)
	cm.GenerateToken(c,182224001)
    cm.RealeaseTokenToSpecialSummon(c,TYPE_XYZ)

    --这张卡被送去墓地的场合，以这张卡以外自己墓地5只「神祝」怪兽为对象才能发动。
    --那些怪兽回到卡组洗切。那之后，自己从卡组抽2张。
    local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW+CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,m+2)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
end

function cm.filter(c,e,tp)
	return c:IsSetCard(0xf79) and c:IsAbleToDeck()
end
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and cm.filter(chkc) end
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2)
		and Duel.IsExistingTarget(cm.filter,tp,LOCATION_GRAVE,0,5,e:GetHandler()) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectTarget(tp,cm.filter,tp,LOCATION_GRAVE,0,5,5,e:GetHandler())
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,g:GetCount(),0,0)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
    local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	if not tg or tg:FilterCount(Card.IsRelateToEffect,nil,e)~=5 then return end
	Duel.SendtoDeck(tg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	local g=Duel.GetOperatedGroup()
	if g:IsExists(Card.IsLocation,1,nil,LOCATION_DECK) then Duel.ShuffleDeck(tp) end
	local ct=g:FilterCount(Card.IsLocation,nil,LOCATION_DECK+LOCATION_EXTRA)
	if ct==5 then
		Duel.BreakEffect()
		Duel.Draw(tp,2,REASON_EFFECT)
	end
end

function cm.GenerateToken(c, tokenCode)
    local function GenerateTokenCostFilter(fc)
        return fc:IsSetCard(NY0xf79) and fc:IsAbleToGrave()
    end
    local function GenerateTokenCost(e,tp,eg,ep,ev,re,r,rp,chk)
        if chk==0 then return Duel.IsExistingMatchingCard(GenerateTokenCostFilter,tp,LOCATION_DECK,0,1,nil,e:GetHandler()) end
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
        local g=Duel.SelectMatchingCard(tp,GenerateTokenCostFilter,tp,LOCATION_DECK,0,1,1,nil,e:GetHandler())
        Duel.SendtoGrave(g,REASON_COST)
    end
    local function GenerateTokenTarget(e,tp,eg,ep,ev,re,r,rp,chk)
        if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and
            Duel.IsPlayerCanSpecialSummonMonster(tp,tokenCode,0,TYPES_TOKEN_MONSTER,0,0,4,RACE_FAIRY,ATTRIBUTE_LIGHT) end
        Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
        Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0)
    end
    local function GenerateTokenOperationSpeciallimit(e,lc,sump,sumtype,sumpos,targetp,se)
        return not lc:IsSetCard(NY0xf79) and lc:IsLocation(LOCATION_EXTRA)
    end
    local function GenerateTokenOperation(e,tp,eg,ep,ev,re,r,rp)
        if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0
            or not Duel.IsPlayerCanSpecialSummonMonster(tp,tokenCode,0,TYPES_TOKEN_MONSTER,0,0,4,RACE_FAIRY,ATTRIBUTE_LIGHT) then return end
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_FIELD)
        e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
        e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
        e1:SetTargetRange(1,0)
        e1:SetTarget(GenerateTokenOperationSpeciallimit)
        e1:SetReset(RESET_PHASE+PHASE_END)
        Duel.RegisterEffect(e1,tp)
        local token=Duel.CreateToken(tp,182224001)
        Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP)
    end

    local code=c:GetCode()
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e1:SetDescription(aux.Stringid(code,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,code)
	e1:SetCost(GenerateTokenCost)
	e1:SetTarget(GenerateTokenTarget)
	e1:SetOperation(GenerateTokenOperation)
	c:RegisterEffect(e1)
end


--注：通过不设置OperationInfo和EFFECT_FLAG_CANNOT_DISABLE来达成无种类效果。
function cm.RealeaseTokenToSpecialSummon(c, type)
    local summontype = SUMMON_TYPE_SPECIAL
    local mustbematerial = nil
    if type==TYPE_RITUAL then
        summontype = SUMMON_TYPE_RITUAL
    elseif type==TYPE_FUSION then
        summontype = SUMMON_TYPE_FUSION
        mustbematerial=EFFECT_MUST_BE_FMATERIAL
    elseif type==TYPE_SYNCHRO then
        summontype = SUMMON_TYPE_SYNCHRO
        mustbematerial=EFFECT_MUST_BE_SMATERIAL
    elseif type==TYPE_XYZ then
        summontype = SUMMON_TYPE_XYZ
        mustbematerial=EFFECT_MUST_BE_XMATERIAL
    elseif type==TYPE_LINK then
        summontype = SUMMON_TYPE_LINK
        mustbematerial=EFFECT_MUST_BE_LMATERIAL
    end
    local function SpecialSummonCostFilter(fc)
        return fc:IsCode(182224001)
    end
    local function SpecialSummonCost(e,tp,eg,ep,ev,re,r,rp,chk)
        if chk==0 then return Duel.CheckReleaseGroup(tp,SpecialSummonCostFilter,1,nil,tp) end
        local g=Duel.SelectReleaseGroup(tp,SpecialSummonCostFilter,1,1,nil,tp)
        g:AddCard(e:GetHandler())
        Duel.Release(g,REASON_COST)
    end
    local function SpecialSummonTargetFilter(tc,e,tp,ctype)
        local levelranklinkcheck = tc:IsLevel(8) or tc:IsRank(4) or tc:IsLink(3)
        local result = tc:IsType(ctype) and tc:IsSetCard(NY0xf79)
            and levelranklinkcheck 

        if ctype~=TYPE_MONSTER and ctype~=TYPE_RITUAL then
            result = result and Duel.GetLocationCountFromEx(tp,tp,nil,tc)>0 and tc:IsCanBeSpecialSummoned(e,summontype,tp,false,false)
        else
            if ctype==TYPE_RITUAL then
                result = result and Duel.GetLocationCount(tp, LOCATION_MZONE)>0 tc:IsCanBeSpecialSummoned(e,summontype,tp,false,true)
            else
                result = result and Duel.GetLocationCount(tp, LOCATION_MZONE)>0 tc:IsCanBeSpecialSummoned(e,summontype,tp,false,false)
            end
        end
        return result
    end
    local function SpecialSummonTarget(e,tp,eg,ep,ev,re,r,rp,chk)
        if chk==0 then
            if (type==TYPE_FUSION or type==TYPE_SYNCHRO or type==TYPE_XYZ or type==TYPE_LINK)  then
                return aux.MustMaterialCheck(nil,tp,mustbematerial)
                and Duel.IsExistingMatchingCard(SpecialSummonTargetFilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,type) 
            else
                return Duel.IsExistingMatchingCard(SpecialSummonTargetFilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,nil,e,tp,type)
            end
        end
    end
    local function SpecialSummonOperation(e,tp,eg,ep,ev,re,r,rp)
        --融合、同调、超量、连接
        if (type==TYPE_FUSION or type==TYPE_SYNCHRO or type==TYPE_XYZ or type==TYPE_LINK) then
            if not aux.MustMaterialCheck(nil,tp,mustbematerial) then return end
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
            local g=Duel.SelectMatchingCard(tp,SpecialSummonTargetFilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,type)
            local tc=g:GetFirst()
            if tc then
                tc:SetMaterial(nil)
                if Duel.SpecialSummon(tc,summontype,tp,tp,false,false,POS_FACEUP)~=0 and  type==TYPE_XYZ then
                    Duel.BreakEffect()
                    Duel.Overlay(tc,Group.FromCards(e:GetHandler()))
                end
            end
        else
            --卡组的特殊召唤、仪式
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
            local g=Duel.SelectMatchingCard(tp,SpecialSummonTargetFilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,1,nil,e,tp,type)
            local tc=g:GetFirst()
            if tc then
                if type==TYPE_RITUAL then
                    tc:SetMaterial(nil)
                    Duel.SpecialSummon(tc,summontype,tp,tp,false,true,POS_FACEUP)
                else
                    Duel.SpecialSummon(tc,summontype,tp,tp,false,false,POS_FACEUP)
                end
            end
        end
    end

    local code=c:GetCode()
    local e1=Effect.CreateEffect(c)
    if type ~=TYPE_FUSION then
            e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
        else
            e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
    end
    e1:SetDescription(aux.Stringid(code,1))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCost(SpecialSummonCost)
	e1:SetTarget(SpecialSummonTarget)
    e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    e1:SetRange(LOCATION_HAND+LOCATION_MZONE)
	e1:SetOperation(SpecialSummonOperation)
	c:RegisterEffect(e1)
end
