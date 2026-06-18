--Voyed, Emissary of The Beast
local s,id=GetID()
function s.initial_effect(c)
	Pendulum.AddProcedure(c)
	--Pendulum Set
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_POSITION)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.rptg)
	e1:SetOperation(s.rpop)
	c:RegisterEffect(e1)
end
function s.rpfilter(c)
	return c:IsType(TYPE_PENDULUM) and c:IsType(TYPE_EFFECT) and c:IsAttack(2950) and c:IsDefense(2950) and not c:IsForbidden()
end
function s.rptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.rpfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_POSITION,nil,1,tp,LOCATION_MZONE)
end
function s.rpop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.Destroy(c,REASON_EFFECT)>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
		local g=Duel.SelectMatchingCard(tp,s.rpfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,1,nil)
		if Duel.MoveToField(g:GetFirst(),tp,tp,LOCATION_PZONE,POS_FACEUP,true) then 
		local b1=Duel.IsExistingMatchingCard(aux.AND(Card.IsFacedown,Card.IsCanChangePosition),tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
		local b2=Duel.IsExistingMatchingCard(aux.AND(Card.IsFaceup,Card.IsCanTurnSet),tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
		if not ((b1 or b2) and Duel.SelectYesNo(tp,aux.Stringid(id,1))) then return end
		local op=Duel.SelectEffect(tp,
			{b1,aux.Stringid(id,2)},
			{b2,aux.Stringid(id,3)})
			if op==1 then
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)
				local tc=Duel.SelectMatchingCard(tp,aux.AND(Card.IsFacedown,Card.IsCanChangePosition),tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil):GetFirst()
				if tc then
					Duel.HintSelection(tc)
					local pos=Duel.SelectPosition(tp,tc,POS_FACEUP_ATTACK+POS_FACEUP_DEFENSE)
					Duel.BreakEffect()
					Duel.ChangePosition(tc,pos)
				end
			elseif op==2 then
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)
				local tc=Duel.SelectMatchingCard(tp,aux.AND(Card.IsFaceup,Card.IsCanTurnSet),tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil):GetFirst()
				if tc then
					Duel.HintSelection(tc)
					Duel.ChangePosition(tc,POS_FACEDOWN_DEFENSE)
				end
			end
		end
	end
end