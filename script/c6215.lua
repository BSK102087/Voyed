--Tarragon, Floral Dragon of The Beast
local s,id=GetID()
function s.initial_effect(c)
	--Link Summon procedure
	c:EnableReviveLimit()
	Link.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsType,TYPE_PENDULUM),3,3,s.lcheck)
	--Double pierce
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_PIERCE)
	e1:SetValue(DOUBLE_DAMAGE)
	e1:SetCondition(s.condition)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCondition(s.condition1)
	c:RegisterEffect(e2)
	--Zone lock
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCountLimit(1,id)
	e3:SetTarget(s.hhtg)
	e3:SetOperation(s.hhop)
	c:RegisterEffect(e3)
	--Banish Temporarily 
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(id,1))
	e6:SetCategory(CATEGORY_REMOVE)
	e6:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e6:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e6:SetRange(LOCATION_MZONE)
	e6:SetCode(EVENT_TO_DECK)
	e6:SetCountLimit(1,{id,1})
	e6:SetTarget(s.bttg)
	e6:SetOperation(s.btop)
	c:RegisterEffect(e6)
	--Place monster as a Continuous Spell/Trap
	local e9=Effect.CreateEffect(c)
	e9:SetDescription(aux.Stringid(id,2))
	e9:SetCategory(CATEGORY_REMOVE)
	e9:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e9:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e9:SetRange(LOCATION_MZONE)
	e9:SetCode(EVENT_REMOVE)
	e9:SetCountLimit(1,{id,2})
	e9:SetTarget(s.pltg)
	e9:SetOperation(s.plop)
	c:RegisterEffect(e9)
	--"Voyed" material check
	local e12=Effect.CreateEffect(c)
	e12:SetType(EFFECT_TYPE_SINGLE)
	e12:SetCode(EFFECT_MATERIAL_CHECK)
	e12:SetValue(s.valcheck)
	c:RegisterEffect(e12)
end
s.listed_names={6200}
function s.lcheck(g,lc,sumtype,tp)
	return g:CheckDifferentProperty(Card.GetScale,lc,sumtype,tp)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetMutualLinkedGroupCount()>0
end
function s.condition1(e)
	local c=e:GetHandler()
	return c:IsLinkSummoned() and c:GetFlagEffect(id)~=0
end
function s.valcheck(e,c)
	local g=c:GetMaterial()
	if g:IsExists(Card.IsCode,1,nil,6200) then
		c:RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD&~(RESET_TOFIELD|RESET_LEAVE|RESET_TEMP_REMOVE),0,1)
	end
end
function s.hhtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(1-tp,LOCATION_MZONE,PLAYER_NONE,0)+Duel.GetLocationCount(1-tp,LOCATION_SZONE,PLAYER_NONE,0)>0 end
end
function s.hhop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local zone=Duel.SelectDisableField(tp,1,0,LOCATION_MZONE,0)
	if tp==1 then
		zone=((zone&0xffff)<<16)|((zone>>16)&0xffff)
	end
	local zone1=Duel.SelectDisableField(tp,1,0,LOCATION_SZONE,0)
	if tp==1 then
		zone1=((zone1&0xffff)<<16)|((zone1>>16)&0xffff)
	end
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_DISABLE_FIELD)
	e4:SetValue(zone)
	e4:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e4,tp)
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetCode(EFFECT_DISABLE_FIELD)
	e5:SetValue(zone1)
	e5:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e5,tp)
end
function s.filter(c)
	return c:IsAbleToRemove()
end
function s.bttg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and s.filter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
end
function s.btop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	local seq=tc:GetSequence()
	if tc:IsControler(1-tp) then seq=seq+16 end
	if tc:IsRelateToEffect(e) and Duel.Remove(tc,0,REASON_EFFECT|REASON_TEMPORARY)~=0 then
		local e7=Effect.CreateEffect(c)
		e7:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e7:SetCode(EVENT_PHASE|PHASE_END)
		e7:SetReset(RESET_PHASE+PHASE_END)
		e7:SetLabelObject(tc)
		e7:SetCountLimit(1)
		e7:SetCondition(s.rtcon)
		e7:SetOperation(s.retop)
		Duel.RegisterEffect(e7,tp)
		local e8=Effect.CreateEffect(c)
		e8:SetType(EFFECT_TYPE_FIELD)
		e8:SetCode(EFFECT_DISABLE_FIELD)
		e8:SetLabel(seq)
		e8:SetLabelObject(tc)
		e8:SetCondition(s.discon)
		e8:SetOperation(s.disop)
		Duel.RegisterEffect(e8,tp)
	end
end
function s.rtcon(e,tp,eg,ep,ev,re,r,rp)
	return tp==Duel.GetTurnPlayer()
end
function s.retop(e,tp,eg,ep,ev,re,r,rp)
	Duel.ReturnToField(e:GetLabelObject())
end
function s.discon(e,c)
	if e:GetLabelObject():IsLocation(LOCATION_REMOVED) then
		return true
	else
		e:Reset()
		return false
	end
end
function s.disop(e,tp)
	local dis1=(0x1<<e:GetLabel())
	return dis1
end
function s.plfilter(c)
	local p=c:GetOwner()
	return c:IsFaceup() and Duel.GetLocationCount(p,LOCATION_SZONE)>0 and not c:IsForbidden() and c:CheckUniqueOnField(p)
end
function s.pltg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.plfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.plfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	Duel.SelectTarget(tp,s.plfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
function s.plop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) or tc:IsImmuneToEffect(e) then return end
	local p=tc:GetOwner()
	if Duel.GetLocationCount(p,LOCATION_SZONE)==0 then
		Duel.SendtoGrave(tc,REASON_RULE,nil,PLAYER_NONE) 
	elseif tc:CheckUniqueOnField(p) and Duel.MoveToField(tc,tp,p,LOCATION_SZONE,POS_FACEUP,tc:IsMonsterCard()) then
		local op=Duel.SelectEffect(tp,
		{true,aux.Stringid(id,3)},
		{true,aux.Stringid(id,4)})
		if op==1 then
			--Treated as a Continuous Spell
			local e10=Effect.CreateEffect(c)
			e10:SetType(EFFECT_TYPE_SINGLE)
			e10:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e10:SetCode(EFFECT_CHANGE_TYPE)
			e10:SetValue(TYPE_SPELL|TYPE_CONTINUOUS)
			e10:SetReset((RESET_EVENT|RESETS_STANDARD)&~RESET_TURN_SET)
			tc:RegisterEffect(e10)
		elseif op==2 then
			--Treated as a Continuous Trap
			local e11=Effect.CreateEffect(c)
			e11:SetType(EFFECT_TYPE_SINGLE)
			e11:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e11:SetCode(EFFECT_CHANGE_TYPE)
			e11:SetValue(TYPE_TRAP|TYPE_CONTINUOUS)
			e11:SetReset((RESET_EVENT|RESETS_STANDARD)&~RESET_TURN_SET)
			tc:RegisterEffect(e11)
		end
	end
end