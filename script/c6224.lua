--Beast Orbital Goliath	
local s,id=GetID()
function s.initial_effect(c)
	Pendulum.AddProcedure(c,false)
	c:SetUniqueOnField(1,0,aux.FilterBoolFunction(Card.IsSetCard,0x226))
	--Xyz Summon
	Xyz.AddProcedure(c,s.xyzfilter,nil,3,s.ovfilter,aux.Stringid(id,0),nil,nil,false,s.xyzcheck)
	c:EnableReviveLimit()
	c:AddMustBeXyzSummoned()
	--Shuffle/Negate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.shncon)
	e1:SetCost(s.shncost)
	e1:SetTarget(s.shntg)
	e1:SetOperation(s.shnop)
	c:RegisterEffect(e1)
	--Set/Scale
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,3))
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetTarget(s.sstg)
	c:RegisterEffect(e2)
	--Xyz Summon
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,6))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_PZONE)
	e4:SetCountLimit(1,{id,2})
	e4:SetCost(s.xyzcost)
	e4:SetTarget(s.xyztg)
	e4:SetOperation(s.xyzop)
	c:RegisterEffect(e4)
	--FLIP
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,7))
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP+EFFECT_TYPE_TRIGGER_O)
	e5:SetProperty(EFFECT_FLAG_DELAY)
	e5:SetCountLimit(1,{id,3})
	e5:SetCondition(s.doublebattlephasecon)
	e5:SetOperation(s.doublebattlephase)
	c:RegisterEffect(e5)
end
s.listed_names={6200}
function s.ovfilter(c,tp,lc,xyzc)
	return c:IsFaceup() and (c:IsSummonCode(lc,SUMMON_TYPE_XYZ,tp,6200) and c:IsType(TYPE_NORMAL,lc,SUMMON_TYPE_XYZ,tp) and c:IsType(TYPE_PENDULUM,lc,SUMMON_TYPE_XYZ,tp) and c:IsPendulumSummoned()) 
end
function s.xyzfilter(c,xyz,sumtype,tp)
	return c:IsType(TYPE_PENDULUM,xyz,sumtype,tp)
end
function s.xyzcheck(g,tp,xyz)
	return g:GetClassCount(Card.GetScale)==1
end
function s.shncon(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED)
end
function s.shncost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
function s.shntg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToDeck,tp,0,LOCATION_GRAVE+LOCATION_REMOVED,1,nil) end
	local g=Duel.GetMatchingGroup(Card.IsAbleToDeck,tp,0,LOCATION_GRAVE+LOCATION_REMOVED,nil)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,#g,0,LOCATION_GRAVE+LOCATION_REMOVED)
end
function s.shnop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsAbleToDeck,tp,0,LOCATION_GRAVE+LOCATION_REMOVED,nil)
	if Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)>0 and Duel.IsExistingMatchingCard(Card.IsNegatable,tp,0,LOCATION_ONFIELD,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
		local g1=Duel.GetMatchingGroup(Card.IsNegatable,tp,0,LOCATION_ONFIELD,nil)
		local c=e:GetHandler()
		for tc in g1:Iter() do
			tc:NegateEffects(c,nil,true)
		end
	end
end
function s.sstg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local b1=e:GetHandler():IsCanTurnSet()
	local b2=Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1) 
	if chk==0 then return b1 or b2 end 
	local op=Duel.SelectEffect(tp,
		{b1,aux.Stringid(id,4)},
		{b2,aux.Stringid(id,5)})
	e:SetLabel(op)
	if op==1 then
		e:SetCategory(CATEGORY_POSITION)
		e:SetOperation(s.posop)
	elseif op==2 then
		e:SetOperation(s.pzop)
	end
end
function s.posop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		Duel.ChangePosition(c,POS_FACEDOWN_DEFENSE)
	end
end
function s.pzop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	end
end	
function s.xyzcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToExtraAsCost() end
	Duel.SendtoDeck(e:GetHandler(),nil,2,REASON_COST)
end
function s.desfilter(c,e)
	return (c:IsFaceup() or c:IsLocation(LOCATION_GRAVE)) and c:HasLevel() and c:IsCanBeEffectTarget(e)
end
function s.rescon(sg,e,tp,mg)
	return sg:GetClassCount(Card.GetLevel)==1
end
function s.xyz1filter(c,e,tp)
	return c:IsType(TYPE_XYZ) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0 and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false)
end
function s.xyztg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	local g=Duel.GetMatchingGroup(s.desfilter,0,LOCATION_GRAVE+LOCATION_REMOVED,LOCATION_GRAVE+LOCATION_REMOVED,nil,e)
	if chk==0 then return #g>=2 and aux.SelectUnselectGroup(g,e,tp,2,2,s.rescon,0) 
		and Duel.IsExistingMatchingCard(s.xyz1filter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	local dg=aux.SelectUnselectGroup(g,e,tp,2,2,s.rescon,1,tp,HINTMSG_DESTROY)
	Duel.SetTargetCard(dg)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,dg,#dg,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.xyzop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local dg=Duel.GetTargetCards(e)
	if #dg>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sg=Duel.SelectMatchingCard(tp,s.xyz1filter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp):GetFirst()
		if sg and Duel.SpecialSummon(sg,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP) then
			Duel.Overlay(sg,dg,true)
		end
		if not sg:ListsCode(6200) then
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetReset(RESET_EVENT|RESETS_STANDARD)
			sg:RegisterEffect(e1)
			local e2=Effect.CreateEffect(e:GetHandler())
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_DISABLE_EFFECT)
			e2:SetReset(RESET_EVENT+0x1fe0000)
			sg:RegisterEffect(e2)
		end
		sg:CompleteProcedure()
	end
end
function s.doublebattlephasecon(e,tp)
	return not Duel.IsPlayerAffectedByEffect(tp,EFFECT_BP_TWICE)
end
function s.doublebattlephase(e,tp,eg,ep,ev,re,r,rp)
	if Duel.IsPlayerAffectedByEffect(tp,EFFECT_BP_TWICE) then return end
	local turn_ct=Duel.GetTurnCount()
	local ct=Duel.IsTurnPlayer(tp) and Duel.IsBattlePhase() and 2 or 1
	--You can conduct your next Battle Phase twice
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(id,8))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_BP_TWICE)
	e1:SetTargetRange(1,0)
	e1:SetValue(1)
	e1:SetCondition(function() return ct==1 or Duel.GetTurnCount()~=turn_ct end)
	e1:SetReset(RESET_PHASE|PHASE_BATTLE|RESET_SELF_TURN,ct)
	Duel.RegisterEffect(e1,tp)
end