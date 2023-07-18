NYGracia={}
gracia=NYGracia

NYGracia.CardSet=0xf79

function NYGracia.GenerateToken(c, limiteCode, tokenCode)
    local function GenerateTokenFilter(fc)
        return fc:IsSetCard(NYGracia.CardSet) and fc:IsAbleToGrave()
    end
    local function GenerateTokenCost(e,tp,eg,ep,ev,re,r,rp,chk)
        if chk==0 then return Duel.IsExistingMatchingCard(GenerateTokenFilter,tp,LOCATION_DECK,0,1,e:GetHandler()) end
        Duel.SendtoGrave(tp,GenerateTokenFilter,1,1,REASON_COST)
    end
    function GenerateTokenTarget(e,tp,eg,ep,ev,re,r,rp,chk)
        if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and
            Duel.IsPlayerCanSpecialSummonMonster(tp,tokenCode,0,TYPES_TOKEN_MONSTER,0,0,4,RACE_FAIRY,ATTRIBUTE_LIGHT) end
        Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
        Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0)
    end
    function GenerateTokenOperationSpecialLimite(e,lc,sump,sumtype,sumpos,targetp,se)
        return not lc:IsSetCard(NYGracia.CardSet) and lc:IsLocation(LOCATION_EXTRA)
    end
    function GenerateTokenOperation(e,tp,eg,ep,ev,re,r,rp)
        if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0
            or not Duel.IsPlayerCanSpecialSummonMonster(tp,tokenCode,0,TYPES_TOKEN_MONSTER,0,0,4,RACE_FAIRY,ATTRIBUTE_LIGHT) then return end
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_FIELD)
        e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
        e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
        e1:SetTargetRange(1,0)
        e1:SetTarget(GenerateTokenOperationSpecialLimite)
        e1:SetReset(RESET_PHASE+PHASE_END)
        Duel.RegisterEffect(e1,tp)
        local token=Duel.CreateToken(tp,182224001)
        Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP)
    end

	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,limiteCode)
	e1:SetCost(GenerateTokenCost)
	e1:SetTarget(GenerateTokenTarget)
	e1:SetOperation(GenerateTokenOperation)
	c:RegisterEffect(e1)
end

--注：通过不设置OperationInfo和EFFECT_FLAG_CANNOT_DISABLE来达成无种类效果。
function NYGracia. RealeaseTokenToSpecialSummon(c, type)
    local summontype = SUMMON_TYPE_SPECIAL
    if type==TYPE_RITUAL then
        summontype = SUMMON_TYPE_RITUAL
    elseif type==TYPE_FUSION then
        summontype = SUMMON_TYPE_FUSION
    elseif type==TYPE_SYNCHRO then
        summontype = SUMMON_TYPE_SYNCHRO
    elseif type==TYPE_XYZ then
        summontype = SUMMON_TYPE_XYZ
    elseif type==TYPE_LINK then
        summontype = SUMMON_TYPE_LINK
    end
    local function SpecialSummonCostFilter(fc)
        return c:IsCode(182224001)
    end
    local function SpecialSummonCost(e,tp,eg,ep,ev,re,r,rp,chk)
        if chk==0 then return Duel.CheckReleaseGroup(tp,SpecialSummonCostFilter,1,nil,tp) end
        local g=Duel.SelectReleaseGroup(tp,SpecialSummonCostFilter,1,1,nil,tp)
        if (type~=TYPE_XYZ) then
            g:AddCard(e:GetHandler())
        end
        Duel.Release(g,REASON_COST)
    end
    local function SpecialSummonTargetFilter(tc,e,tp,ctype)
        local levelranklinkcheck = tc:IsLevel(8) or tc:IsRank(4) or tc:IsLink(3)
        local materialcheck = true;
        if type==TYPE_FUSION then
            materialcheck = tc:CheckFusionMaterial()
        elseif type==TYPE_SYNCHRO then
            materialcheck = tc:CheckSynchroMaterial()
        elseif type==TYPE_XYZ then
            materialcheck = tc:CheckXyzMaterial()
        end
        local result = tc:IsType(ctype) and tc:IsSetCard(NYGracia.CardSet) 
            and levelranklinkcheck and materialcheck
            and tc:IsCanBeSpecialSummoned(e,summontype,tp,false,false)
        if type~=nil and type~=TYPE_RITUAL then
            result = result and Duel.GetLocationCountFromEx(tp,tp,nil,tc)>0
        end
        return result
    end
    local function SpecialSummonTarget(e,tp,eg,ep,ev,re,r,rp,chk)
        if chk==0 then return aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_FMATERIAL)
            and Duel.IsExistingMatchingCard(SpecialSummonTargetFilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,type) end
    end
    local function SpecialSummonOperation(e,tp,eg,ep,ev,re,r,rp)
        --超量召唤特殊处理
        if type==TYPE_XYZ then
            local tc=e:GetHandler()
            Duel.SpecialSummon(tc,SUMMON_TYPE_SPECIAL,tp,tp,false,false,POS_FACEUP)
            Duel.BreakEffect()
            if not aux.MustMaterialCheck(tc,tp,EFFECT_MUST_BE_XMATERIAL) then return end
            if tc:IsFaceup() and tc:IsRelateToEffect(e) and tc:IsControler(tp) and not tc:IsImmuneToEffect(e) then
                Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
                local g=Duel.SelectMatchingCard(tp,SpecialSummonTargetFilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,c)
                local mc=g:GetFirst()
                if sc then
                    local mg=tc:GetOverlayGroup()
                    if mg:GetCount()~=0 then
                        Duel.Overlay(mc,mg)
                    end
                    mc:SetMaterial(Group.FromCards(c))
                    Duel.Overlay(mc,Group.FromCards(c))
                    Duel.SpecialSummon(mc,summontype,tp,tp,false,false,POS_FACEUP)
                    mc:CompleteProcedure()
                end
            end
        --融合、同调、连接
        elseif (type==TYPE_FUSION or type==TYPE_SYNCHRO or type==TYPE_LINK) then
            if not aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_FMATERIAL) then return end
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
            local g=Duel.SelectMatchingCard(tp,SpecialSummonTargetFilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,nil)
            local tc=g:GetFirst()
            if tc then
                tc:SetMaterial(nil)
                Duel.SpecialSummon(tc,summontype,tp,tp,false,false,POS_FACEUP)
                tc:CompleteProcedure()
            end
        --卡组的特殊召唤、仪式
        else
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
            local g=Duel.SelectMatchingCard(tp,SpecialSummonTargetFilter,tp,LOCATION_DECK,0,1,1,nil,e,tp,nil)
            local tc=g:GetFirst()
            if tc then
                if type==TYPE_RITUAL then tc:SetMaterial(nil) end
                Duel.SpecialSummon(tc,summontype,tp,tp,false,false,POS_FACEUP)
                tc:CompleteProcedure()
            end
        end
    end

    local e1=Effect.CreateEffect(c)
    if type ~=TYPE_FUSION then
            e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
        else
            e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
    end
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCost(SpecialSummonCost)
	e1:SetTarget(SpecialSummonTarget)
    e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    e1:SetRange(LOCATION_HAND)
	e1:SetOperation(SpecialSummonOperation)
	c:RegisterEffect(e1)
end