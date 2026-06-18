--Hydra, Ocean Amphiptere of The Beast
local s,id=GetID()
function s.initial_effect(c)
	--Link Summon
	Link.AddProcedure(c,nil,2,3,s.lcheck)
	c:EnableReviveLimit()
	--Direct Attack
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_DIRECT_ATTACK)
	e1:SetCondition(s.condition)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCondition(s.condition1)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetCondition(s.atkcon)
	e3:SetOperation(s.atkop)
	c:RegisterEffect(e3)
	--Reveal and send to grave	
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,0))
	e5:SetCategory(CATEGORY_TOGRAVE)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e5:SetProperty(EFFECT_FLAG_DELAY)
	e5:SetCode(EVENT_MSET)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCountLimit(1,id)
	e5:SetCondition(aux.zptcon(nil))
	e5:SetTarget(s.rvtg)
	e5:SetOperation(s.rvop)
	c:RegisterEffect(e5)
	local e6=e5:Clone()
	e6:SetCode(EVENT_SPSUMMON_SUCCESS)
	e6:SetCondition(aux.zptcon(s.spcfilter))
	c:RegisterEffect(e6)
	--Reveal and send from Extra to grave
	local e7=Effect.CreateEffect(c)
	e7:SetDescription(aux.Stringid(id,4))
	e7:SetCategory(CATEGORY_TOGRAVE)
	e7:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e7:SetProperty(EFFECT_FLAG_DELAY)
	e7:SetCode(EVENT_FLIP)
	e7:SetRange(LOCATION_MZONE)
	e7:SetCountLimit(1,{id,1})	
	e7:SetCondition(s.extgcon)
	e7:SetTarget(s.extg)
	e7:SetOperation(s.extgop)
	c:RegisterEffect(e7)
	--"Voyed" material check
	local e8=Effect.CreateEffect(c)
	e8:SetType(EFFECT_TYPE_SINGLE)
	e8:SetCode(EFFECT_MATERIAL_CHECK)
	e8:SetValue(s.valcheck)
	c:RegisterEffect(e8)
end
s.listed_names={6200}
function s.lcheck(g,lc,sumtype,tp)
	return g:IsExists(Card.IsType,1,nil,TYPE_FLIP,lc,sumtype,tp)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetMutualLinkedGroupCount()>0
end
function s.condition1(e)
	local c=e:GetHandler()
	return c:IsLinkSummoned() and c:GetFlagEffect(id)~=0
end
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetAttackTarget()==nil and e:GetHandler():IsHasEffect(EFFECT_DIRECT_ATTACK)
		and Duel.IsExistingMatchingCard(aux.NOT(Card.IsHasEffect),tp,0,LOCATION_MZONE,1,nil,EFFECT_IGNORE_BATTLE_TARGET)
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local effs={c:GetCardEffect(EFFECT_DIRECT_ATTACK)}
	local eg=Group.CreateGroup()
	for _,eff in ipairs(effs) do
		eg:AddCard(eff:GetOwner())
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EFFECT)
	local ec = #eg==1 and eg:GetFirst() or eg:Select(tp,1,1,nil):GetFirst()
	if c==ec then
		local e4=Effect.CreateEffect(c)
		e4:SetType(EFFECT_TYPE_SINGLE)
		e4:SetCode(EFFECT_SET_ATTACK_FINAL)
		e4:SetRange(LOCATION_MZONE)
		e4:SetValue(c:GetBaseAttack())
		e4:SetReset(RESET_EVENT|RESETS_STANDARD_DISABLE|RESET_PHASE|PHASE_DAMAGE_CAL)
		c:RegisterEffect(e4)
	end
end
function s.spcfilter(c)
	return c:IsFacedown()
end
function s.rvtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_HAND,1,nil) end
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
function s.tgfilterM(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToGrave()
end
function s.tgfilterS(c)
	return c:IsType(TYPE_SPELL) and c:IsAbleToGrave()
end
function s.tgfilterT(c)
	return c:IsType(TYPE_TRAP) and c:IsAbleToGrave()
end
function s.rvop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
	local sg=g:RandomSelect(tp,1)
	local tc=sg:GetFirst()
	if tc then
		Duel.ConfirmCards(tp,tc)
		Duel.ShuffleHand(1-tp)
		if tc:IsMonster() and Duel.IsExistingMatchingCard(s.tgfilterM,tp,LOCATION_DECK,0,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
			Duel.BreakEffect()
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
			local dg=Duel.SelectMatchingCard(tp,s.tgfilterM,tp,LOCATION_DECK,0,1,1,nil)
			if #dg>0 then
				Duel.SendtoGrave(dg,REASON_EFFECT)
			end
		elseif tc:IsSpell() and Duel.IsExistingMatchingCard(s.tgfilterS,tp,LOCATION_DECK,0,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
			Duel.BreakEffect()
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
			local dg=Duel.SelectMatchingCard(tp,s.tgfilterS,tp,LOCATION_DECK,0,1,1,nil)
			if #dg>0 then
				Duel.SendtoGrave(dg,REASON_EFFECT)
			end
		elseif tc:IsType(TYPE_TRAP) and Duel.IsExistingMatchingCard(s.tgfilterT,tp,LOCATION_DECK,0,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
			Duel.BreakEffect()
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
			local dg=Duel.SelectMatchingCard(tp,s.tgfilterT,tp,LOCATION_DECK,0,1,1,nil)
			if #dg>0 then
				Duel.SendtoGrave(dg,REASON_EFFECT)
			end
		end
	end
end
function s.cfilter(c,g)
	return g:IsContains(c)
end
function s.extgcon(e,tp,eg,ep,ev,re,r,rp)
	local lg=e:GetHandler():GetLinkedGroup()
	return lg and eg:IsExists(s.cfilter,1,nil,lg)
end
function s.extg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(tp,0,LOCATION_EXTRA)>0 end
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
function s.tgfilterF(c)
	return c:IsType(TYPE_FUSION) and c:IsAbleToGrave()
end
function s.tgfilterS(c)
	return c:IsType(TYPE_SYNCHRO) and c:IsAbleToGrave()
end
function s.tgfilterxyz(c)
	return c:IsType(TYPE_XYZ) and c:IsAbleToGrave()
end
function s.tgfilterL(c)
	return c:IsType(TYPE_LINK) and c:IsAbleToGrave()
end
function s.extgop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetFieldGroup(1-tp,LOCATION_EXTRA,0)
	local sg=g:RandomSelect(tp,1)
	local tc=sg:GetFirst()
	if tc then
		Duel.ConfirmCards(tp,tc)
		if tc:IsType(TYPE_FUSION) and Duel.IsExistingMatchingCard(s.tgfilterF,tp,LOCATION_EXTRA,0,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(id,5)) then
			Duel.BreakEffect()
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
			local dg=Duel.SelectMatchingCard(tp,s.tgfilterF,tp,LOCATION_EXTRA,0,1,1,nil)
			if #dg>0 then
				Duel.SendtoGrave(dg,REASON_EFFECT)
			end
		elseif tc:IsType(TYPE_SYNCHRO) and Duel.IsExistingMatchingCard(s.tgfilterS,tp,LOCATION_EXTRA,0,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(id,6)) then
			Duel.BreakEffect()
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
			local dg=Duel.SelectMatchingCard(tp,s.tgfilterS,tp,LOCATION_EXTRA,0,1,1,nil)
			if #dg>0 then
				Duel.SendtoGrave(dg,REASON_EFFECT)
			end
		elseif tc:IsType(TYPE_XYZ) and Duel.IsExistingMatchingCard(s.tgfilterxyz,tp,LOCATION_EXTRA,0,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(id,7)) then
			Duel.BreakEffect()
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
			local dg=Duel.SelectMatchingCard(tp,s.tgfilterxyz,tp,LOCATION_EXTRA,0,1,1,nil)
			if #dg>0 then
				Duel.SendtoGrave(dg,REASON_EFFECT)
			end
		elseif tc:IsType(TYPE_LINK) and Duel.IsExistingMatchingCard(s.tgfilterL,tp,LOCATION_EXTRA,0,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(id,8)) then
			Duel.BreakEffect()
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
			local dg=Duel.SelectMatchingCard(tp,s.tgfilterL,tp,LOCATION_EXTRA,0,1,1,nil)
			if #dg>0 then
				Duel.SendtoGrave(dg,REASON_EFFECT)
			end	
		end
	end
end
function s.valcheck(e,c)
	local g=c:GetMaterial()
	if g:IsExists(Card.IsCode,1,nil,6200) then
		c:RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD&~(RESET_TOFIELD|RESET_LEAVE|RESET_TEMP_REMOVE),0,1)
	end
end