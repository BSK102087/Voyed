--Voyed, Phantom of The Beast
local s,id=GetID()
function s.initial_effect(c)
	Pendulum.AddProcedure(c,false)
	--Synchro Summon
	Synchro.AddProcedure(c,nil,1,1,aux.FilterSummonCode(6200),1,1)
	c:EnableReviveLimit()
	--Special Summon "Voyed, Emissary of The Beast"
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--Activate 1 Effect
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,{id,1})
	e4:SetCondition(s.nonquickcon)
	e4:SetTarget(s.spztg)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetType(EFFECT_TYPE_QUICK_O)
	e5:SetCode(EVENT_FREE_CHAIN)
	e5:SetCondition(s.quickcon)
	c:RegisterEffect(e5)
	--FLIP
	local e7=Effect.CreateEffect(c)
	e7:SetDescription(aux.Stringid(id,7))
	e7:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP+EFFECT_TYPE_TRIGGER_O)
	e7:SetProperty(EFFECT_FLAG_DELAY)
	e7:SetOperation(s.revop)
	c:RegisterEffect(e7)
end
s.listed_names={6200}
function s.spvfilter(c,e,tp)
	return c:IsCode(6200) and (c:IsFaceup() or c:IsLocation(LOCATION_DECK+LOCATION_HAND+LOCATION_GRAVE)) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 
		and Duel.IsExistingMatchingCard(s.spvfilter,tp,LOCATION_DECK+LOCATION_REMOVED+LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) end 
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,LOCATION_DECK+LOCATION_REMOVED+LOCATION_HAND+LOCATION_GRAVE)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local tc=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spvfilter),tp,LOCATION_DECK+LOCATION_REMOVED+LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp):GetFirst()
	if tc and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		local e2=Effect.CreateEffect(c)
		e2:SetDescription(aux.Stringid(id,1))
		e2:SetProperty(EFFECT_FLAG_CLIENT_HINT)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_ATTACK_ALL)
		e2:SetValue(1)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
		local e3=Effect.CreateEffect(c)
		e3:SetDescription(3208)
		e3:SetProperty(EFFECT_FLAG_CLIENT_HINT)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_PIERCE)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e3)
	end
	Duel.SpecialSummonComplete()
end
function s.nonquickcon(e,tp,eg,ep,ev,re,r,rp)
	return not Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_PZONE,LOCATION_PZONE,1,nil)
end
function s.quickcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_PZONE,LOCATION_PZONE,1,nil)
end
function s.spztg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local b1=Duel.IsExistingMatchingCard(aux.AND(Card.IsFaceup,Card.IsCanTurnSet),tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
	local b2=Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1) 
	if chk==0 then return b1 or b2 end 
	local op=Duel.SelectEffect(tp,
		{b1,aux.Stringid(id,3)},
		{true,aux.Stringid(id,4)},
		{b2,aux.Stringid(id,5)})
	e:SetLabel(op)
	if op==1 then
		e:SetCategory(CATEGORY_POSITION)
		e:SetOperation(s.posop)
	elseif op==2 then
		e:SetCategory(CATEGORY_CONTROL)
		e:SetOperation(s.contop)
	elseif op==3 then
		e:SetOperation(s.pzop)
	end
end
function s.posop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)
	local tc=Duel.SelectMatchingCard(tp,aux.AND(Card.IsFaceup,Card.IsCanTurnSet),tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil):GetFirst()
	if tc then
		Duel.HintSelection(tc)
		Duel.ChangePosition(tc,POS_FACEDOWN_DEFENSE)
	end
end
function s.pzop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	end
end
function s.contop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(id,6))
	e6:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e6:SetCode(EVENT_PHASE+PHASE_BATTLE_START)
	e6:SetReset(RESET_PHASE+PHASE_BATTLE_START)
	e6:SetCountLimit(1)
	e6:SetOperation(s.contop1)
	Duel.RegisterEffect(e6,tp)
end
function s.contop1(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)
	local g=Duel.SelectMatchingCard(tp,Card.IsControlerCanBeChanged,tp,0,LOCATION_MZONE,1,1,nil)
	if #g>0 then
		Duel.HintSelection(g)
		Duel.GetControl(g,tp)
	end
end
function s.revop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local e8=Effect.CreateEffect(c)
	e8:SetDescription(aux.Stringid(id,8))
	e8:SetType(EFFECT_TYPE_FIELD)
	e8:SetCode(EFFECT_REFLECT_BATTLE_DAMAGE)
	e8:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e8:SetTargetRange(1,0)
	e8:SetValue(1)
	e8:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e8,tp)
	local e9=Effect.CreateEffect(c)
	e9:SetType(EFFECT_TYPE_FIELD)
	e9:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e9:SetTargetRange(LOCATION_MZONE,0)
	e9:SetReset(RESET_PHASE|PHASE_END)
	e9:SetValue(1)
	Duel.RegisterEffect(e9,tp)
	local e10=Effect.CreateEffect(c)
	e10:SetType(EFFECT_TYPE_FIELD)
	e10:SetCode(EFFECT_SET_ATTACK_FINAL)
	e10:SetTargetRange(LOCATION_MZONE,0)
	e10:SetValue(0)
	e10:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e10,tp)
	local e11=e10:Clone()
	e11:SetCode(EFFECT_SET_DEFENSE_FINAL)
	Duel.RegisterEffect(e11,tp)
end		