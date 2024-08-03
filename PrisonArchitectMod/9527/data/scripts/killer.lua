function Create()
end

function Update(timePassed)

    local x = Object.GetProperty("Pos.x");
    local y = Object.GetProperty("Pos.y");

    local nearbyPrisoners = Object.GetNearbyObjects("Prisoner", 1);
		for prisonerName,prisonerDistance in pairs(nearbyPrisoners) do
				Object.SetProperty(prisonerName, "Damage", math.min(tonumber(Object.GetProperty(prisonerName, "Damage")) + 1, 1));
				break;
		end
	Object.Delete()
end


    