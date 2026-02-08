ITEM.Name = "Flask"
ITEM.Description = "A flask used for storing genetic materials."
ITEM.Model = "models/zerochain/props_bloodlab/zbl_flask.mdl"
ITEM.Base = "base_darkrp"
ITEM.Stackable = false
ITEM.DropStack = false

function ITEM:GetName()
	local name = "Undefind"

	local genName = self:GetData("GenName")
	local genValue = self:GetData("GenValue")
	local genType = self:GetData("GenType")

	if genType == 1 then
		name = "Sample"
	elseif genType == 2 then
		if zbl.config.Vaccines[genValue] and zbl.config.Vaccines[genValue].isvirus then
			name = "Virus"
		else
			name = "Abillity"
		end
	elseif genType == 3 then
		name = "Cure"
	end

	name = name .. " [" .. genName .. "]"

	return self:GetData("Name", name)
end

function ITEM:GetDescription()

	local desc = self.Description

	local genType = self:GetData("GenType")

	if genType then
		desc = "+" .. self:GetData("GenPoints") .. " DNA"
	end

	return self:GetData("Description", desc)
end

function ITEM:CanPickup(pl, ent)
	if ent:GetGenType() > 0 then
		return true
	else
		return false
	end
end

function ITEM:SaveData(ent)
	self:SetData("GenType", ent:GetGenType())
	self:SetData("GenValue", ent:GetGenValue())
	self:SetData("GenName", ent:GetGenName())
	self:SetData("GenPoints", ent:GetGenPoints())
	self:SetData("GenClass", ent:GetGenClass())
end

function ITEM:LoadData(ent)
	ent:SetGenType(self:GetData("GenType"))
	ent:SetGenValue(self:GetData("GenValue"))
	ent:SetGenName(self:GetData("GenName"))
	ent:SetGenPoints(self:GetData("GenPoints"))
	ent:SetGenClass(self:GetData("GenClass"))
end
