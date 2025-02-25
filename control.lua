local Timer = require "timer"

local bStarted = false
local bStopped = false
local bInitiated = false
local bMBeg = false
local bMEnd = false
local bReset = false
local bDBeg = false
local bDEnd = false
local bInter = false
local nState = 0
local resetToggle = 0
local isPressed = false
local tMillingDone = false
local tMillingTimer = Timer()
local tDrillingDone = false
local tDrillingTimer = Timer()
local tDelayDrill = Timer()
local tDelayMill = Timer()
local wasPressed = false
local stopWasPressed = false
local nState = 0
local tDelayDrillDone
local tDelayMillDone
local i_counter = 0
local lState = 0
local startButtonTimer = Timer()
local startButtonTimerDone
local triggerCount

function control()
    
end


function control1()
    if version == "state" then
        if I10_button_start then
            startButtonTimerDone = startButtonTimer:set(true, 3.5)
            if startButtonTimerDone then
                i_counter = 0
            end
        else
            startButtonTimer:reset()
        end

        if i_counter == 3 then
            Q05_loading_station_conveyor = false
        end

        if lState == 0 then
            if I05_loading_station_sensor_end then
                lState = 1
            end
        end
        if lState == 1 then
            i_counter = i_counter + 1
            lState = 2
        end
        if lState == 2 then
            if I05_loading_station_sensor_end then
            else
                lState = 0
            end
        end
    end


    if I05_loading_station_sensor_end then
        triggerCount = triggerCount + 1
    else
        triggerCount = 0
    end

    if triggerCount == 1 then
        i_counter = i_counter + 1
    end

    if I10_button_start then
        startButtonTimerDone = startButtonTimer:set(true, 3.5)
        if startButtonTimerDone then
            i_counter = 0
        end
    else
        startButtonTimer:reset()
    end



    if I11_button_stop then
        nState = 100
        Q05_loading_station_conveyor = false
        if version then
            print("In total, ", i_counter, ", products transported. --" .. version)
        else
            print("No counting method is used")
        end
    end

    if nState == 0 then
        Q06_milling_station_conveyor = false
        Q08_drilling_station_conveyor = false
        Q07_milling_station_processing = false
        Q09_drilling_station_processing = false
        if I10_button_start then
            nState = 10
        end
    end

    if nState == 10 then
        if i_counter == 3 then
            Q05_loading_station_conveyor = false
        else
            Q05_loading_station_conveyor = true
        end
        Q08_drilling_station_conveyor = true
        Q06_milling_station_conveyor = true
        Q07_milling_station_processing = false
        Q09_drilling_station_processing = false
        if I06_milling_station_sensor then
            nState = 20
        end
    end

    if nState == 20 then
        Q06_milling_station_conveyor = false
        Q08_drilling_station_conveyor = true
        Q07_milling_station_processing = true
        Q09_drilling_station_processing = false
        if tMillingTimer:set(true, 5) then
            nState = 30
        end
    end

    if nState == 30 then
        tDelayMillDone = tDelayMill:set(true, 3)
        if tDelayMillDone then
            Q06_milling_station_conveyor = false
        else
            Q06_milling_station_conveyor = true
        end
        Q08_drilling_station_conveyor = true
        Q07_milling_station_processing = false
        Q09_drilling_station_processing = false
        if I08_drilling_station_sensor then
            nState = 40
        end
    end

    if nState == 40 then
        if tDelayMill:read(false, 3) then
            Q06_milling_station_conveyor = false
        else
            Q06_milling_station_conveyor = true
        end
        Q08_drilling_station_conveyor = false
        Q07_milling_station_processing = false
        Q09_drilling_station_processing = true
        if tDrillingTimer:set(true, 3) then
            tDelayDrillDone = tDelayDrill:set(true, 3)
            if tDelayDrillDone then
                nState = 0
                tDelayMill:reset()
                tDelayDrill:reset()
                tMillingTimer:reset()
                tDrillingTimer:reset()
            else
                Q09_drilling_station_processing = false
                Q08_drilling_station_conveyor = true
            end
        end
    end

    if nState == 100 then
        Q08_drilling_station_conveyor = false
        Q06_milling_station_conveyor = false
        Q07_milling_station_processing = false
        Q05_loading_station_conveyor = false
        Q09_drilling_station_processing = false
        if I12_button_reset then
            nState = 0
            tDelayMill:reset()
            tDelayDrill:reset()
            tMillingTimer:reset()
            tDrillingTimer:reset()
        end
    end

    if love.mouse.isDown(2) then         -- for now linked to the RMB
        Q01_slider_1_forward = true
        Q02_slider_1_backward = false
        Q03_slider_2_forward = true
        Q04_slider_2_backward = false
    end

    if love.mouse.isDown(3) then         -- for now linked to the MMB
        Q01_slider_1_forward = false
        Q02_slider_1_backward = true
        Q03_slider_2_forward = false
        Q04_slider_2_backward = true
    end

    if I01_slider_1_sensor_front then
        Q01_slider_1_forward = false
    end

    if I02_slider_1_sensor_rear then
        Q02_slider_1_backward = false
    end

    if I03_slider_2_sensor_front then
        Q03_slider_2_forward = false
    end

    if I04_slider_2_sensor_rear then
        Q04_slider_2_backward = false
    end

    if I11_button_stop then
        Q01_slider_1_forward = false
        Q02_slider_1_backward = true
        Q03_slider_2_forward = false
        Q04_slider_2_backward = true
    end
end
