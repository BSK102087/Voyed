--Pipa, Ultrasonic Bullfrog of The Beast
local s,id=GetID()
function s.initial_effect(c)
	Pendulum.AddProcedure(c,false)
	--Xyz Summon
	Xyz.AddProcedure(c,aux.FilterBoolFunction(Card.IsType,TYPE_FLIP),5,2)
	c:EnableReviveLimit()
	--Special Summon/Scale
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_REMOVE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.spztg)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_TO_GRAVE)
	c:RegisterEffect(e2)
	--Add 1 card attached to this card to the hand
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,3))
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,{id,1})
	e3:SetTarget(s.thtg)
	e3:SetOperation(s.thop)
	c:RegisterEffect(e3)
	--Special Summon (Battle Phase)
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,4))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_PZONE)
	e4:SetCountLimit(1,{id,2})
	e4:SetTarget(s.sptg)
	e4:SetOperation(s.spop)
	c:RegisterEffect(e4)
	--FLIP
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,11))
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP+EFFECT_TYPE_TRIGGER_O)
	e5:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e5:SetCountLimit(1,{id,2})
	e5:SetTarget(s.atttg)
	e5:SetOperation(s.attop)
	c:RegisterEffect(e5)
end
s.listed_names={6200}
s.pendulum_level=5
function s.spztg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local b1=Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_ATTACK+POS_FACEDOWN_DEFENSE)
	local b2=Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1) 
	if chk==0 then return b1 or b2 end 
	local op=Duel.SelectEffect(tp,
		{b1,aux.Stringid(id,1)},
		{b2,aux.Stringid(id,2)})
	e:SetLabel(op)
	if op==1 then
		e:SetCategory(CATEGORY_SPECIAL_SUMMON)
		e:SetOperation(s.spop2)
	elseif op==2 then
		e:SetOperation(s.pzop)
	end
end
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP_ATTACK+POS_FACEDOWN_DEFENSE) then 
		if c:IsFacedown() then
			Duel.ConfirmCards(1-tp,c)
		end
	end
end	
function s.pzop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	end
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=e:GetHandler():GetOverlayGroup()
	if chk==0 then return #g>0 and g:IsExists(Card.IsAbleToHand,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local og=c:GetOverlayGroup()
	if #og==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=og:FilterSelect(tp,Card.IsAbleToHand,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_DESTROY,nil,1,tp,LOCATION_ONFIELD)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE+LOCATION_REMOVED)
end
function s.vfilter(c)
	return c:IsCode(6200)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.IsExistingMatchingCard(s.vfilter,tp,LOCATION_ONFIELD,0,1,nil) and Duel.SelectEffectYesNo(tp,c,aux.Stringid(id,5)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		local g1=Duel.SelectMatchingCard(tp,s.vfilter,tp,LOCATION_ONFIELD,0,1,1,nil)
		Duel.HintSelection(g1)
		Duel.Destroy(g1,REASON_EFFECT)
	elseif c:IsRelateToEffect(e) then
		Duel.Destroy(c,REASON_EFFECT) 
	end	
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,10))
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e5:SetCode(EVENT_PHASE+PHASE_BATTLE_START)
	e5:SetReset(RESET_PHASE+PHASE_BATTLE_START)
	e5:SetCountLimit(1)
	e5:SetOperation(s.spop1)
	Duel.RegisterEffect(e5,tp)
end
function s.spfilter(c,e,tp)
	return (c:IsType(TYPE_FLIP) or c:IsType(TYPE_XYZ)) and c:IsFaceup() and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_ATTACK+POS_FACEDOWN_DEFENSE)
end
function s.spop1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local tc=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE+LOCATION_REMOVED,LOCATION_GRAVE+LOCATION_REMOVED,1,1,nil,e,tp):GetFirst()
	if Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_ATTACK+POS_FACEDOWN_DEFENSE) then
		if tc:IsFacedown() then
			Duel.ConfirmCards(1-tp,tc)
		end
	end
end	
function s.dattchfilter1(c)
	return c:IsType(TYPE_XYZ)
end
function s.atttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.dattchfilter1(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.dattchfilter1,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,s.dattchfilter1,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
function s.attop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		local g1=Duel.GetMatchingGroup(nil,tp,0,LOCATION_ONFIELD,nil)
		local g2=Duel.GetMatchingGroup(nil,tp,0,LOCATION_HAND,nil)
		local sg=Group.CreateGroup()
		if #g1>0 and (#g2==0 or Duel.SelectYesNo(tp,aux.Stringid(id,6))) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATTACH)
			local sg1=g1:Select(tp,1,1,tc)
			Duel.HintSelection(sg1)
			sg:Merge(sg1)
		end
		if #g2>0 and (#sg==0 or Duel.SelectYesNo(tp,aux.Stringid(id,7))) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATTACH)
			local sg2=g2:RandomSelect(tp,1)
			sg:Merge(sg2)
		end
	Duel.Overlay(tc,sg,true) 
	end
end