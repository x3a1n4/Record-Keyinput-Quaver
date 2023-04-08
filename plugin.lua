-- draw() is the the entry point
function draw()
    imgui.Begin("Record Keypresses")

    -- Make long note sensitivity input
    local ln_sens = get("ln_sens", 100)
    _, ln_sens = imgui.InputInt("Long Note Sensitivity", ln_sens)
    state.SetValue("ln_sens", ln_sens)

    -- Make audio offset input
    local aud_off = get("aud_off", -50)
    _, aud_off = imgui.InputInt("Audio Offset", aud_off)
    state.SetValue("aud_off", aud_off)

    -- Debug
    imgui.Text("Debug" .. tostring(ln_sens))
    
    -- Make toggle recording button
    local isRecording = get("isRecording", false)

    if isRecording then
        local stopRecordButton = imgui.Button("Stop Recording")

        if stopRecordButton then
            -- Stopped Recording
            state.SetValue("isRecording", false)
        end
    else
        local startRecordButton = imgui.Button("Start Recording")
        
        if startRecordButton then
            -- Started Recording!
            -- Create new layer
            actions.CreateLayer(utils.CreateEditorLayer("Recorded Layer"))
            state.SetValue("isRecording", true)
        end
        
    end

    -- Recording!
    if isRecording then

        -- Check Key Presses
        local column_keys = {
            [keys.D] = 1,
            [keys.F] = 2,
            [keys.J] = 3,
            [keys.K] = 4
        }

        for key, column in pairs(column_keys) do
            -- Save that key was pressed
            if utils.IsKeyPressed(key) then
                state.SetValue("pressed" .. tostring(key), state.SongTime)
                
            end

            -- Check that key was released
            if utils.IsKeyReleased(key) then
                -- Get time that key was pressed
                local startTime = get("pressed" .. tostring(key), -1)
                local timeDiff = state.SongTime - startTime
                
                if timeDiff > ln_sens then
                    -- Making a long note
                    actions.PlaceHitObject(utils.CreateHitObject(
                        startTime + aud_off, 
                        column, 
                        state.SongTime + aud_off
                        )
                    )
                else
                    -- Making a short note
                    actions.PlaceHitObject(utils.CreateHitObject(
                        startTime + aud_off, 
                        column
                        )
                    )
                end
                
            end
        end
    end

    imgui.End()

    -- Create window with option to start recording, long note sensitivity
    

end

function get(identifier, defaultValue)
    return state.GetValue(identifier) or defaultValue
end