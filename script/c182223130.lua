--神祝姬 塔丽娅
local m=182223130
local cm=_G["c"..m]
function cm.initial_effect(c)
    cm.GenerateToken(c,182224006)
    cm.RealeaseTokenToSpecialSummon(c,TYPE_RITUAL)

    local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,m+2)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
end

function cm.filter1(c)
	return c:IsSetCard(0xf79) and c:IsAbleToGrave() and c:IsType(TYPE_MONSTER)
end
function cm.filter2(c)
	return c:IsSetCard(0xf79) and c:IsAbleToGrave() and c:IsType(TYPE_SPELL+TYPE_TRAP)
end
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cm.filter1,tp,LOCATION_DECK,0,1,nil)
        and Duel.IsExistingMatchingCard(cm.filter2,tp,LOCATION_DECK,0,1,nil)end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,cm.filter1,tp,LOCATION_DECK,0,1,1,nil)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local sg=Duel.SelectMatchingCard(tp,cm.filter2,tp,LOCATION_DECK,0,1,1,nil)
    g:Merge(sg)
	if g:GetCount()>0 then
        Duel.SendtoGrave(g, REASON_EFFECT)
	end
end

function cm.GenerateToken(c, tokenCode)
    local function GenerateTokenCostFilter(fc)
        return fc:IsSetCard(0xf79) and fc:IsAbleToGrave() and fc:IsType(TYPE_MONSTER)
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
        return not lc:IsSetCard(0xf79) and lc:IsLocation(LOCATION_EXTRA)
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
    local function SpecialSummonCostFilter(fc)
        return fc:IsCode(182224001)
    end
    local function SpecialSummonCost(e,tp,eg,ep,ev,re,r,rp,chk)
        if chk==0 then return Duel.CheckReleaseGroup(tp,SpecialSummonCostFilter,1,nil,tp) end
        local g=Duel.SelectReleaseGroup(tp,SpecialSummonCostFilter,1,1,nil,tp)
        g:AddCard(e:GetHandler())
        Duel.Release(g,REASON_COST)
    end
    local function SpecialSummonTargetFilter(tc,e,tp)
        return tc:IsLevel(8) and tc:IsSetCard(0xf79) and tc:IsType(TYPE_RITUAL) and Duel.GetLocationCount(tp, LOCATION_MZONE)>0
            and tc:IsCanBeSpecialSummoned(e,SUMMON_TYPE_RITUAL,tp,false,true)
    end
    local function SpecialSummonTarget(e,tp,eg,ep,ev,re,r,rp,chk)
        if chk==0 then return Duel.IsExistingMatchingCard(SpecialSummonTargetFilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,nil,e,tp) end
    end
    local function SpecialSummonOperation(e,tp,eg,ep,ev,re,r,rp)
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
        local g=Duel.SelectMatchingCard(tp,SpecialSummonTargetFilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,1,nil,e,tp)
        local tc=g:GetFirst()
        if tc then
            Duel.SpecialSummon(tc,SUMMON_TYPE_RITUAL,tp,tp,false,true,POS_FACEUP)
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