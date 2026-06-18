--Voyed, Trickster of The Beast
local s,id=GetID()
function s.initial_effect(c)
	--Link Summon
	Link.AddProcedure(c,s.matfilter,1,1)
	c:EnableReviveLimit()
	--Material ATK
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetOperation(s.atkop)
	c:RegisterEffect(e1)
	--Become "Voyed"
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetCode(EFFECT_CHANGE_CODE)
	e2:SetTarget(s.utg)
	e2:SetValue(6200)
	c:RegisterEffect(e2)
	--Reveal
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DRAW+CATEGORY_DECKDES)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id)
	e3:SetTarget(s.tg)
	e3:SetOperation(s.op)
	c:RegisterEffect(e3)
end
s.listed_names={6200}
function s.matfilter(c,scard,sumtype,tp)
	return c:IsCode(6200)
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=c:GetMaterial()
	if not c:IsLinkSummoned() then return end
	local val=0
	local tc=g:GetFirst()
	for tc in aux.Next(g) do
		local a=tc:GetBaseAttack()
		if a<0 then a=0 end
		val=val+a
	end
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_SET_BASE_ATTACK)
	e4:SetValue(val/2)
	e4:SetReset(RESET_EVENT|RESETS_STANDARD_DISABLE)
	c:RegisterEffect(e4)
end
function s.utg(e,c)
	return e:GetHandler():GetLinkedGroup():IsContains(c)
end
function s.rescon(sg,e,tp,mg)
	return sg:FilterCount(Card.IsMonster,nil)<=1
		and sg:FilterCount(Card.IsSpell,nil)<=1
		and sg:FilterCount(Card.IsTrap,nil)<=1
end
function s.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local g=Duel.GetFieldGroup(tp,LOCATION_HAND,0)
	local ty=0
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsPlayerCanSpecialSummonMonster(tp,6201,0,TYPES_TOKEN|TYPE_TUNER,0,0,4,RACE_BEAST,ATTRIBUTE_LIGHT) then ty=ty | TYPE_MONSTER end
	if Duel.IsPlayerCanDraw(tp,1) then ty=ty | TYPE_SPELL end
	if Duel.IsPlayerCanDiscardDeck(tp,1) then ty=ty | TYPE_TRAP end
	if chk==0 then return ty>0 and g:IsExists(Card.IsType,1,nil,ty) end
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local g=Duel.GetFieldGroup(tp,LOCATION_HAND,0)
	local ty=0
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsPlayerCanSpecialSummonMonster(tp,6201,0,TYPES_TOKEN|TYPE_TUNER,0,0,4,RACE_BEAST,ATTRIBUTE_LIGHT) then ty=ty | TYPE_MONSTER end
	if Duel.IsPlayerCanDraw(tp,1) then ty=ty | TYPE_SPELL end
	if Duel.IsPlayerCanDiscardDeck(tp,1) then ty=ty | TYPE_TRAP end
	if ty==0 then return end
	local sg=aux.SelectUnselectGroup(g:Filter(Card.IsType,nil,ty),e,tp,1,3,s.rescon,1,tp,HINTMSG_CONFIRM)
	local lb=0
	for tc in aux.Next(sg) do
		lb=lb | tc:GetType()
	end
	lb=lb & 0x7
	Duel.ConfirmCards(1-tp,sg)
	Duel.ShuffleHand(tp)
	Duel.BreakEffect()
	if lb & TYPE_MONSTER ~=0 then
		local token=Duel.CreateToken(tp,6201)
		Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP)
	end
	if lb & TYPE_SPELL ~=0 then
		Duel.Draw(tp,1,REASON_EFFECT)
	end
	if lb & TYPE_TRAP ~=0 then
		Duel.DiscardDeck(tp,1,REASON_EFFECT)
	end
end