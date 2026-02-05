if SERVER then return end

ztm = ztm or {}
ztm.manhole_stencils = ztm.manhole_stencils or {}
ztm.buyermachine_stencils = ztm.buyermachine_stencils or {}



local function Create_ClientSideModel(ent,model)
	ent.csModel = ClientsideModel(model)
	ent.csModel:SetPos(ent:GetPos())
	ent.csModel:SetAngles(ent:GetAngles())
	ent.csModel:SetParent(ent)
	ent.csModel:SetNoDraw(true)
end

hook.Add("PreDrawTranslucentRenderables", "ztm_stencil", function(depth, skybox)
	if skybox then return end
	if depth then return end

	for k, s in pairs(ztm.manhole_stencils) do
		if not IsValid(s) then continue end
		if not ztm.f.InDistance(LocalPlayer():GetPos(), s:GetPos(), 400) then continue end
		if (s.RenderStencil == false) then continue end

		render.ClearStencil()
		render.SetStencilEnable(true)
		render.SetStencilWriteMask(255)
		render.SetStencilTestMask(255)
		render.SetStencilReferenceValue(57)
		render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_ALWAYS)
		render.SetStencilPassOperation(STENCILOPERATION_REPLACE)
		render.SetStencilFailOperation(STENCIL_ZERO)
		render.SetStencilZFailOperation(STENCIL_ZERO)

		local angle = s:GetAngles()
		cam.Start3D2D(s:GetPos(), angle, 0.5)

			surface.SetDrawColor(ztm.default_colors["black02"])
			draw.NoTexture()
			ztm.f.draw_Circle( 0, 0, 41, 20 )
		cam.End3D2D()

		render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_EQUAL)
		render.SuppressEngineLighting(false)
		render.DepthRange(0, 0.6)

		if IsValid(s.csModel) then
			s.csModel:DrawModel()
		else
			Create_ClientSideModel(s,"models/zerochain/props_trashman/ztm_manhole_stencil.mdl")
		end

		render.SuppressEngineLighting(false)
		render.SetStencilEnable(false)
		render.DepthRange(0, 1)
	end


	for k, s in pairs(ztm.buyermachine_stencils) do
		if not IsValid(s) then continue end
		if not ztm.f.InDistance(LocalPlayer():GetPos(), s:GetPos(), 400) then continue end

		render.ClearStencil()
		render.SetStencilEnable(true)
		render.SetStencilWriteMask(255)
		render.SetStencilTestMask(255)
		render.SetStencilReferenceValue(57)
		render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_ALWAYS)
		render.SetStencilPassOperation(STENCILOPERATION_REPLACE)
		render.SetStencilFailOperation(STENCIL_ZERO)
		render.SetStencilZFailOperation(STENCILOPERATION_KEEP)


		cam.Start3D2D(s:LocalToWorld(Vector(0,3.8,50)), s:LocalToWorldAngles(Angle(0,180,90)), 1)
			surface.DrawRect( -18, -2, 36, 31 )
			surface.SetDrawColor(ztm.default_colors["black02"])
			draw.NoTexture()
		cam.End3D2D()

		render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_EQUAL)
		render.DepthRange(0, 0.5)

		if IsValid(s.csModel) then
			s.csModel:DrawModel()

		else
			Create_ClientSideModel(s,"models/zerochain/props_trashman/ztm_buyermachine_stencil.mdl")
		end



		if IsValid(s.csBlockModel) then
			local attach = s:GetAttachment(1)

			if attach then

				s.csBlockModel:SetPos(attach.Pos)
				local ang = attach.Ang
				ang:RotateAroundAxis(attach.Ang:Right(), 90)
				s.csBlockModel:SetAngles(ang)
			end

			if s:GetIsInserting() then
				s.csBlockModel:DrawModel()
			end
		else

			s.csBlockModel = ClientsideModel("models/zerochain/props_trashman/ztm_recycleblock.mdl")

			local attach = s:GetAttachment(1)

			if IsValid(s.csBlockModel) and attach then

				s.csBlockModel:SetPos(attach.Pos)
				local ang = attach.Ang
				ang:RotateAroundAxis(attach.Ang:Up(), 90)
				s.csBlockModel:SetAngles(ang)
				s.csBlockModel:SetParent(s, 1)
				s.csBlockModel:SetNoDraw(true)
			end
		end

		render.DepthRange(0, 1)
		render.SetStencilEnable(false)
	end

end)
