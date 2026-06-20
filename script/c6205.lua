--Siren, Celestial Harvester of The Beast
local s,id=GetID()
function s.initial_effect(c)
	Pendulum.AddProcedure(c)
	--"Voyed, Emissary of The Beast" or Level 5 or higher monster that mention it can be Normal Summoned without tribute
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SUMMON_PROC)
	e1:SetRange(LOCATION_PZONE)
	e1:SetTargetRange(LOCATION_HAND,0)
	e1:SetCondition(s.ntcon)
	e1:SetTarget(aux.FieldSummonProcTg(s.nttg))
	c:RegisterEffect(e1)
	--Position Change (face-down)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_POSITION)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.postg)
	e2:SetOperation(s.posop)
	c:RegisterEffect(e2)
	--Destroy/Banish Replace
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EFFECT_DESTROY_REPLACE)
	e3:SetRange(LOCATION_PZONE)
	e3:SetTarget(s.reptg)
	e3:SetValue(s.repval)
	e3:SetOperation(s.repop)
	c:RegisterEffect(e3)
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EFFECT_SEND_REPLACE)
	e4:SetRange(LOCATION_PZONE)
	e4:SetTarget(s.reptg1)
	e4:SetValue(s.repval1)
	e4:SetOperation(s.repop)
	c:RegisterEffect(e4)
	--FLIP
	local e8=Effect.CreateEffect(c)
	e8:SetDescription(aux.Stringid(id,3))
	e8:SetCategory(CATEGORY_POSITION)
	e8:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP+EFFECT_TYPE_TRIGGER_O)
	e8:SetProperty(EFFECT_FLAG_DELAY)
	e8:SetCountLimit(1,{id,1})
	e8:SetOperation(s.chposop)
	c:RegisterEffect(e8)
	--Special Summon/Scale
	local e11=Effect.CreateEffect(c)
	e11:SetDescription(aux.Stringid(id,4))
	e11:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e11:SetCode(EVENT_SUMMON_SUCCESS)
	e11:SetProperty(EFFECT_FLAG_DELAY)
	e11:SetRange(LOCATION_HAND+LOCATION_GRAVE+LOCATION_EXTRA)
	e11:SetCountLimit(1,{id,2})
	e11:SetTarget(s.spztg)
	c:RegisterEffect(e11)
	--Same as above, but upon special summon
	local e12=e11:Clone()
	e12:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e12)
end
s.listed_names={6200}
function s.ntcon(e,c,minc)
	if c==nil then return true end
	return minc==0 and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
end
function s.nttg(e,c)
	return (c:IsLevelAbove(5) and c:ListsCode(6200)) or c:IsCode(6200)
end
function s.postg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(aux.AND(Card.IsFacedown,Card.IsCanChangePosition),tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_POSITION,nil,1,tp,0)
end
function s.posop(e,tp,eg,ep,ev,re,r,rp,chk)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)
	local tc=Duel.SelectMatchingCard(tp,aux.AND(Card.IsFacedown,Card.IsCanChangePosition),tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil):GetFirst()
	if tc then
		Duel.HintSelection(tc)
		local pos=Duel.SelectPosition(tp,tc,POS_FACEUP_ATTACK+POS_FACEUP_DEFENSE)
		Duel.ChangePosition(tc,pos)
	end
end
function s.repfilter(c,tp)
	return c:IsFaceup() and c:IsControler(tp) and c:IsLocation(LOCATION_ONFIELD) and (c:IsCode(6200) or c:ListsCode(6200))
		and not c:IsReason(REASON_REPLACE) and c:IsReason(REASON_EFFECT)
end
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return eg:IsExists(s.repfilter,1,nil,tp) and not e:GetHandler():IsStatus(STATUS_DESTROY_CONFIRMED) end
	return Duel.SelectEffectYesNo(tp,e:GetHandler(),96)
end
function s.repval(e,c)
	return s.repfilter(c,e:GetHandlerPlayer())
end
function s.repop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Destroy(e:GetHandler(),REASON_EFFECT+REASON_REPLACE)
	if Duel.IsExistingMatchingCard(Card.IsNegatableMonster,tp,0,LOCATION_MZONE,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_NEGATE)
		local g=Duel.SelectMatchingCard(tp,Card.IsNegatableMonster,tp,0,LOCATION_MZONE,1,1,nil)
		local tc=g:GetFirst()
		if tc then	
			Duel.BreakEffect()
			local e5=Effect.CreateEffect(c)
			e5:SetType(EFFECT_TYPE_SINGLE)
			e5:SetCode(EFFECT_DISABLE)
			e5:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e5)
			local e6=Effect.CreateEffect(c)
			e6:SetType(EFFECT_TYPE_SINGLE)
			e6:SetCode(EFFECT_DISABLE_EFFECT)
			e6:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e6)
			if tc:IsType(TYPE_TRAPMONSTER) then
				local e7=Effect.CreateEffect(c)
				e7:SetType(EFFECT_TYPE_SINGLE)
				e7:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
				e7:SetCode(EFFECT_DISABLE_TRAPMONSTER)
				e7:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
				tc:RegisterEffect(e7)
			end
		end
	end
end	
function s.repfilter1(c,tp)
	return c:IsFaceup() and c:IsControler(tp) and c:IsLocation(LOCATION_ONFIELD) and (c:IsCode(6200) or c:ListsCode(6200))
		and not c:IsReason(REASON_REPLACE) and c:IsReason(REASON_EFFECT) and c:GetDestination()==LOCATION_REMOVED
end
function s.repval1(e,c)
	return s.repfilter1(c,e:GetHandlerPlayer())
end
function s.reptg1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return eg:IsExists(s.repfilter1,1,nil,tp) end
	if e:GetHandler():GetDestination()==LOCATION_REMOVED then return false end
	return Duel.SelectEffectYesNo(tp,e:GetHandler(),96)
end
function s.chposop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local e9=Effect.CreateEffect(c)
	e9:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e9:SetCode(EVENT_PHASE+PHASE_BATTLE_START)
	e9:SetCountLimit(1)
	e9:SetCondition(s.atkposcon)
	e9:SetOperation(s.atkposop)
	e9:SetReset(RESET_PHASE+PHASE_BATTLE_START)
	Duel.RegisterEffect(e9,tp)
end
function s.atkposcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(nil,tp,0,LOCATION_MZONE,1,nil)
end
function s.atkposop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local sg=Duel.GetMatchingGroup(nil,tp,0,LOCATION_MZONE,nil)
	Duel.ChangePosition(sg,POS_FACEUP_ATTACK)
	local e10=Effect.CreateEffect(c)
	e10:SetType(EFFECT_TYPE_FIELD)
	e10:SetCode(EFFECT_MUST_ATTACK)
	e10:SetTargetRange(0,LOCATION_MZONE)
	e10:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e10,tp)
end
function s.spztg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local b1=Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and not c:IsLocation(LOCATION_EXTRA) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_ATTACK+POS_FACEDOWN_DEFENSE)
	local b2=Duel.GetLocationCountFromEx(tp,tp,nil,c)>0 and not c:IsLocation(LOCATION_HAND+LOCATION_GRAVE) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_ATTACK+POS_FACEDOWN_DEFENSE)
	local b3=Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1) 
	if chk==0 then return b1 or b2 or b3 end 
	local op=Duel.SelectEffect(tp,
		{b1,aux.Stringid(id,5)},
		{b2,aux.Stringid(id,6)},
		{b3,aux.Stringid(id,7)})
	e:SetLabel(op)
	if op==1 then
		e:SetCategory(CATEGORY_SPECIAL_SUMMON)
		e:SetOperation(s.spop)
	elseif op==2 then
		e:SetCategory(CATEGORY_SPECIAL_SUMMON)
		e:SetOperation(s.spop)
	elseif op==3 then
		e:SetOperation(s.pzop)
	end
	Duel.SetChainLimit(s.chainlm)
end
function s.chainlm(e,rp,tp)
	return tp==1-rp or not e:IsMonsterEffect()
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
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
