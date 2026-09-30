local SCRIPT_VERSION = 3.5
local ROOT_NAME = "Psy Ability"
local SCRIPT_AUTHOR = "DreenWolks"
local PREDICTION_AUTHOR = "pengpeng"
local Prediction
do
Prediction = {}

local Utils_ok, Utils = pcall(require, "utils")
if not Utils_ok then Utils = nil end

local DASH_BUCKET_1 = { speed = 635.0, duration = 0.62 }
local DASH_BUCKET_2 = { speed = 579.0, duration = 0.68 }
local DASH_BUCKET_3 = { speed = 562.0, duration = 0.70 }

local DEFAULT_DASH_BUCKET = DASH_BUCKET_2

local HERO_DASH_BUCKETS = {
    hero_haze       = DASH_BUCKET_1,
    hero_orion      = DASH_BUCKET_1,
    hero_astro      = DASH_BUCKET_1,
    hero_yamato     = DASH_BUCKET_1,
    hero_wraith     = DASH_BUCKET_2,
    hero_gigawatt   = DASH_BUCKET_2,
    hero_inferno    = DASH_BUCKET_2,
    hero_viper      = DASH_BUCKET_2,
    hero_drifter    = DASH_BUCKET_2,
    hero_lash       = DASH_BUCKET_2,
    hero_mirage     = DASH_BUCKET_2,
    hero_viscous    = DASH_BUCKET_2,
    hero_synth      = DASH_BUCKET_2,
    hero_bookworm   = DASH_BUCKET_2,
    hero_chrono     = DASH_BUCKET_2,
    hero_magician   = DASH_BUCKET_2,
    hero_doorman    = DASH_BUCKET_2,
    hero_hornet     = DASH_BUCKET_2,
    hero_warden     = DASH_BUCKET_2,
    hero_ghost      = DASH_BUCKET_2,
    hero_vampirebat = DASH_BUCKET_2,
    hero_bebop      = DASH_BUCKET_3,
    hero_dynamo     = DASH_BUCKET_3,
    hero_atlas      = DASH_BUCKET_3,
    hero_kelvin     = DASH_BUCKET_3,
    hero_forge      = DASH_BUCKET_3,
    hero_krill      = DASH_BUCKET_3,
    hero_shiv       = DASH_BUCKET_3,
    hero_frank      = DASH_BUCKET_3,
    hero_punkgoat   = DASH_BUCKET_3,
    hero_nano       = DASH_BUCKET_3,
}

local function get_dash_stats(hero_name)
    return HERO_DASH_BUCKETS[hero_name] or DEFAULT_DASH_BUCKET
end

local HERO_SPEEDS = {
    hero_atlas      = { move = 241.51, sprint = 60.38,  total = 301.89 },
    hero_bebop      = { move = 243.40, sprint = 150.94, total = 394.34 },
    hero_punkgoat   = { move = 264.15, sprint = 60.38,  total = 324.53 },
    hero_nano       = { move = 271.70, sprint = 60.38,  total = 332.08 },
    hero_drifter    = { move = 260.38, sprint = 60.38,  total = 320.75 },
    hero_dynamo     = { move = 252.83, sprint = 60.38,  total = 313.21 },
    hero_orion      = { move = 237.74, sprint = 60.38,  total = 298.11 },
    hero_haze       = { move = 309.43, sprint = 60.38,  total = 369.81 },
    hero_astro      = { move = 309.43, sprint = 60.38,  total = 369.81 },
    hero_inferno    = { move = 252.83, sprint = 60.38,  total = 313.21 },
    hero_kelvin     = { move = 252.83, sprint = 41.51,  total = 294.34 },
    hero_ghost      = { move = 237.74, sprint = 98.11,  total = 335.85 },
    hero_lash       = { move = 271.70, sprint = 79.25,  total = 350.94 },
    hero_forge      = { move = 252.83, sprint = 60.38,  total = 313.21 },
    hero_vampirebat = { move = 249.06, sprint = 60.38,  total = 309.43 },
    hero_mirage     = { move = 264.15, sprint = 60.38,  total = 324.53 },
    hero_krill      = { move = 301.89, sprint = 60.38,  total = 362.26 },
    hero_bookworm   = { move = 260.38, sprint = 132.08, total = 392.45 },
    hero_chrono     = { move = 252.83, sprint = 60.38,  total = 313.21 },
    hero_synth      = { move = 271.70, sprint = 60.38,  total = 332.08 },
    hero_gigawatt   = { move = 252.83, sprint = 22.64,  total = 275.47 },
    hero_shiv       = { move = 252.83, sprint = 60.38,  total = 313.21 },
    hero_magician   = { move = 271.70, sprint = 60.38,  total = 332.08 },
    hero_doorman    = { move = 298.11, sprint = 60.38,  total = 358.49 },
    hero_frank      = { move = 237.74, sprint = 41.51,  total = 279.25 },
    hero_hornet     = { move = 298.11, sprint = 60.38,  total = 358.49 },
    hero_viscous    = { move = 271.70, sprint = 60.38,  total = 332.08 },
    hero_viper      = { move = 260.38, sprint = 60.38,  total = 320.75 }, 
    hero_warden     = { move = 237.74, sprint = 60.38,  total = 298.11 },
    hero_wraith     = { move = 271.70, sprint = 60.38,  total = 332.08 },
    hero_yamato     = { move = 309.43, sprint = 60.38,  total = 369.81 },
}

local function calculate_mean_speeds()
    local sum_move, sum_sprint, sum_total, count = 0, 0, 0, 0
    for _, speeds in pairs(HERO_SPEEDS) do
        sum_move = sum_move + speeds.move
        sum_sprint = sum_sprint + speeds.sprint
        sum_total = sum_total + speeds.total
        count = count + 1
    end
    return {
        move = sum_move / count,
        sprint = sum_sprint / count,
        total = sum_total / count
    }
end

local MEAN_HERO_SPEEDS = calculate_mean_speeds()

local SPIRIT_SCALING = {
    hero_orion    = 0.31698,
    hero_gigawatt = 0.45283,
    hero_viper    = 0.52075,
}

local CROUCH = {
    BASE = 181.13,
    PENALTY = 166.04,
}

local MASK_SOLID = 0x1

local VELOCITY_CONFIG = {
    HISTORY_SIZE = 8,
    MIN_DELTA_TIME = 0.001,
    MAX_DELTA_TIME = 0.5,
    VELOCITY_SMOOTHING = 0.3,
    ACCEL_SMOOTHING = 0.2,
    STALE_THRESHOLD = 1.0,
}

local entity_tracking = {}


local function create_tracking_data()
    return {
        positions = {},
        velocity = Vector(0, 0, 0),
        acceleration = Vector(0, 0, 0),
        last_update = 0,
        write_index = 1,
    }
end

local function add_position_sample(data, pos, time)
    data.positions[data.write_index] = { pos = pos, time = time }
    data.write_index = (data.write_index % VELOCITY_CONFIG.HISTORY_SIZE) + 1
end

local function get_oldest_sample(data, current_time)
    local oldest = nil
    local oldest_time = current_time
    
    for i = 1, VELOCITY_CONFIG.HISTORY_SIZE do
        local sample = data.positions[i]
        if sample and (current_time - sample.time) < VELOCITY_CONFIG.MAX_DELTA_TIME then
            if sample.time < oldest_time then
                oldest_time = sample.time
                oldest = sample
            end
        end
    end
    
    return oldest
end

local function get_newest_sample(data)
    local newest = nil
    local newest_time = 0
    
    for i = 1, VELOCITY_CONFIG.HISTORY_SIZE do
        local sample = data.positions[i]
        if sample and sample.time > newest_time then
            newest_time = sample.time
            newest = sample
        end
    end
    
    return newest
end

local function calculate_velocity_from_history(data, current_time)
    local samples = {}
    local count = 0
    
    for i = 1, VELOCITY_CONFIG.HISTORY_SIZE do
        local sample = data.positions[i]
        if sample and (current_time - sample.time) < VELOCITY_CONFIG.MAX_DELTA_TIME then
            count = count + 1
            samples[count] = sample
        end
    end
    
    if count < 2 then
        return Vector(0, 0, 0)
    end
    
    table.sort(samples, function(a, b) return a.time < b.time end)
    
    local total_weight = 0
    local weighted_vel = Vector(0, 0, 0)
    
    for i = 2, count do
        local prev = samples[i - 1]
        local curr = samples[i]
        local dt = curr.time - prev.time
        
        if dt > VELOCITY_CONFIG.MIN_DELTA_TIME then
            local vel = (curr.pos - prev.pos) / dt
            local weight = i / count
            weighted_vel = weighted_vel + vel * weight
            total_weight = total_weight + weight
        end
    end
    
    if total_weight > 0 then
        return weighted_vel / total_weight
    end
    
    return Vector(0, 0, 0)
end

local function smooth_vector(current, target, factor)
    return current + (target - current) * factor
end

local function update_entity_tracking(ent, current_time)
    if not ent or not ent:valid() then
        return Vector(0, 0, 0), Vector(0, 0, 0)
    end
    
    local handle = ent:get_handle()
    local current_pos = ent:get_origin()
    
    if not current_pos then
        return Vector(0, 0, 0), Vector(0, 0, 0)
    end
    
    if not entity_tracking[handle] then
        entity_tracking[handle] = create_tracking_data()
    end
    
    local data = entity_tracking[handle]
    local dt = current_time - data.last_update
    
    if dt < VELOCITY_CONFIG.MIN_DELTA_TIME then
        return data.velocity, data.acceleration
    end
    
    local prev_velocity = data.velocity
    
    add_position_sample(data, current_pos, current_time)
    data.last_update = current_time
    
    local raw_velocity = calculate_velocity_from_history(data, current_time)
    
    data.velocity = smooth_vector(data.velocity, raw_velocity, VELOCITY_CONFIG.VELOCITY_SMOOTHING)
    
    if dt < VELOCITY_CONFIG.MAX_DELTA_TIME then
        local raw_accel = (data.velocity - prev_velocity) / dt
        data.acceleration = smooth_vector(data.acceleration, raw_accel, VELOCITY_CONFIG.ACCEL_SMOOTHING)
    end
    
    return data.velocity, data.acceleration
end

function Prediction.GetTrackedVelocity(ent)
    if not ent or not ent:valid() then
        return Vector(0, 0, 0), Vector(0, 0, 0)
    end
    
    local current_time = global_vars.curtime()
    return update_entity_tracking(ent, current_time)
end

function Prediction.HasValidTracking(ent)
    if not ent or not ent:valid() then
        return false
    end
    
    local handle = ent:get_handle()
    local data = entity_tracking[handle]
    
    if not data then
        return false
    end
    
    local current_time = global_vars.curtime()
    return (current_time - data.last_update) < VELOCITY_CONFIG.STALE_THRESHOLD
end

function Prediction.CleanupStaleTracking()
    local current_time = global_vars.curtime()
    local to_remove = {}
    
    for handle, data in pairs(entity_tracking) do
        if (current_time - data.last_update) > VELOCITY_CONFIG.STALE_THRESHOLD * 2 then
            to_remove[#to_remove + 1] = handle
        end
    end
    
    for _, handle in ipairs(to_remove) do
        entity_tracking[handle] = nil
    end
end

function Prediction.ResetTracking(ent)
    if not ent or not ent:valid() then
        return
    end
    entity_tracking[ent:get_handle()] = nil
end

function Prediction.ResetAllTracking()
    entity_tracking = {}
end



local function get_hero_name(ent)
    if not ent or not ent:valid() then return nil end
    
    local name = ent:get_name()
    if name and HERO_SPEEDS[name] then
        return name
    end
    
    local class_name = ent:get_class_name()
    if class_name then
        local hero_match = string.match(class_name, "(hero_%w+)")
        if hero_match and HERO_SPEEDS[hero_match] then
            return hero_match
        end
    end
    
    local success, hero_data = pcall(function()
        local hero_comp = ent["m_CCitadelHeroComponent"]
        if hero_comp then
            local spawned_hero = hero_comp["m_spawnedHero"]
            if spawned_hero then
                local hero_data_ptr = spawned_hero["m_pHeroData"]
                if hero_data_ptr then
                    return hero_data_ptr["m_pszHeroId"]
                end
            end
        end
        return nil
    end)
    
    if success and hero_data then
        return hero_data
    end
    
    local vdata_name = ent:get_vdata_class_name()
    if vdata_name then
        local hero_match = string.match(vdata_name, "(hero_%w+)")
        if hero_match then
            return hero_match
        end
    end
    
    return nil
end

local function get_spirit_power(ent)
    if not ent or not ent:valid() then return 0 end
    local success, spirit = pcall(function()
        return ent:get_modifier_value(EModifierValue.MODIFIER_VALUE_TECH_POWER, 0)
    end)
    if success and spirit then return spirit end
    return 0
end

local function get_hero_speeds(ent)
    local hero_name = get_hero_name(ent)
    local speeds = HERO_SPEEDS[hero_name] or MEAN_HERO_SPEEDS
    
    local base_speed = speeds.move
    local sprint_speed = speeds.total
    
    if hero_name and SPIRIT_SCALING[hero_name] then
        local spirit = get_spirit_power(ent)
        local bonus = spirit * SPIRIT_SCALING[hero_name]
        base_speed = base_speed + bonus
        sprint_speed = sprint_speed + bonus
    end
    
    return {
        base = base_speed,
        sprint = sprint_speed,
        crouch = CROUCH.BASE
    }
end

local function is_local_player(ent)
    if not ent or not ent:valid() then return false end
    local local_pawn = entity_list.local_pawn()
    if not local_pawn or not local_pawn:valid() then return false end
    return ent:get_handle() == local_pawn:get_handle()
end



function Prediction.PredictPlayer(ent, time, cmd_buttons, cmd_move_x, cmd_move_y, cmd_yaw, aim_mode, use_acceleration)
    if not ent or not ent:valid() then return Vector(0, 0, 0) end

    local current_origin = ent:get_origin()
    if not current_origin then return Vector(0, 0, 0) end

    local aim_offset = Vector(0, 0, 0)
    local target_bone = "spine_0"
    if aim_mode == "head" then
        target_bone = "head"
    end

    local bone_pos = ent:get_bone_pos(target_bone)
    if bone_pos then
        aim_offset = bone_pos - current_origin
    end

    local vel, accel
    if is_local_player(ent) then
        vel = ent:get_velocity()
        accel = Vector(0, 0, 0)
    else
        vel, accel = Prediction.GetTrackedVelocity(ent)
    end

    local displacement
    if use_acceleration and accel then
        displacement = vel * time + accel * (0.5 * time * time)
    else
        displacement = vel * time
    end
    
    local predicted_pos = current_origin + displacement

    local final_pos = predicted_pos
    local clip_ok, clip_tr = pcall(function()
        return trace.line(
            current_origin,
            predicted_pos,
            0, 0, 0,
            MASK_SOLID,
            0,
            function(e)
                return e and e:valid() and e:get_index() == ent:get_index()
            end
        )
    end)

    if clip_ok and clip_tr and clip_tr.fraction < 1.0 then
        final_pos = current_origin + (displacement * clip_tr.fraction * 0.95)
    end

    final_pos = final_pos + aim_offset

    return final_pos
end

function Prediction.PredictPlayerAdvanced(ent, time, aim_mode, options)
    if not ent or not ent:valid() then return Vector(0, 0, 0) end
    
    options = options or {}
    local use_acceleration = options.use_acceleration ~= false
    local clamp_to_max_speed = options.clamp_to_max_speed or false
    
    local current_origin = ent:get_origin()
    if not current_origin then return Vector(0, 0, 0) end

    local aim_offset = Vector(0, 0, 0)
    local target_bone = aim_mode == "head" and "head" or "spine_0"
    local bone_pos = ent:get_bone_pos(target_bone)
    if bone_pos then
        aim_offset = bone_pos - current_origin
    end

    local vel, accel
    if is_local_player(ent) then
        vel = ent:get_velocity()
        accel = Vector(0, 0, 0)
    else
        vel, accel = Prediction.GetTrackedVelocity(ent)
    end
    
    if clamp_to_max_speed then
        local speeds = get_hero_speeds(ent)
        local max_speed = speeds.sprint
        local current_speed = vel:Length2D()
        
        if current_speed > max_speed then
            local scale = max_speed / current_speed
            vel = Vector(vel.x * scale, vel.y * scale, vel.z)
        end
    end

    local displacement
    if use_acceleration then
        displacement = vel * time + accel * (0.5 * time * time)
    else
        displacement = vel * time
    end
    
    local predicted_pos = current_origin + displacement

    local tr = trace.line(
        current_origin,
        predicted_pos,
        0, 0, 0,
        MASK_SOLID,
        0,
        function(e)
            return e and e:valid() and e:get_index() == ent:get_index()
        end
    )

    local final_pos = predicted_pos
    if tr.fraction < 1.0 then
        final_pos = current_origin + (displacement * tr.fraction * 0.95)
    end

    return final_pos + aim_offset
end


function Prediction.GetHeroSpeeds(ent) return get_hero_speeds(ent) end
function Prediction.GetHeroName(ent) return get_hero_name(ent) end
function Prediction.GetAllHeroSpeeds() return HERO_SPEEDS end
function Prediction.GetMeanSpeeds() return MEAN_HERO_SPEEDS end
function Prediction.GetDashStats(hero_name) return get_dash_stats(hero_name) end



function Prediction.PredictArc(source_pos, target, speed, gravity, aim_bone)
    if not target or not target:valid() then return nil, 0 end
    gravity  = gravity or 800
    aim_bone = aim_bone or "spine_0"

    if speed <= 0 then
        return target:get_bone_pos(aim_bone) or target:get_origin(), 0
    end

    local predicted_pos = Prediction.PredictPlayer(target, 0, nil, nil, nil, nil, aim_bone)
    local t = 0.0

    for i = 1, 6 do
        local dx = math.sqrt(
            (predicted_pos.x - source_pos.x) * (predicted_pos.x - source_pos.x) +
            (predicted_pos.y - source_pos.y) * (predicted_pos.y - source_pos.y)
        )
        local new_t = dx / speed
        if math.abs(new_t - t) < 0.005 then break end
        t = new_t
        predicted_pos = Prediction.PredictPlayer(target, t, nil, nil, nil, nil, aim_bone)
    end

    local gravity_comp = 0.5 * gravity * t * t
    local arc_pos = Vector(predicted_pos.x, predicted_pos.y, predicted_pos.z + gravity_comp)

    return arc_pos, t
end


function Prediction.WillHitWall(start_pos, direction, max_distance)
    local z_offset = 20
    local trace_start = Vector(start_pos.x, start_pos.y, start_pos.z + z_offset)
    local dir = Vector(direction.x, direction.y, 0):Normalized()
    local trace_end = Vector(
        trace_start.x + dir.x * max_distance,
        trace_start.y + dir.y * max_distance,
        trace_start.z
    )

    local ok, tr = pcall(function()
        return trace.line(trace_start, trace_end, 0, 0, 0, MASK_SOLID, 0, nil)
    end)

    if ok and tr then
        return tr.fraction < 0.99, tr
    end
    return false, nil
end


function Prediction.PredictKnockback(source_pos, target, knockback_metres, options)
    if not target or not target:valid() then
        return { will_hit_wall = false }
    end
    options = options or {}

    local UNIT_METER = 37.7358490566
    local knockback_dist = knockback_metres * UNIT_METER
    local target_pos = target:get_origin()

    local dir = Vector(
        target_pos.x - source_pos.x,
        target_pos.y - source_pos.y,
        0
    ):Normalized()

    local will_hit, tr = Prediction.WillHitWall(target_pos, dir, knockback_dist)

    local result = {
        will_hit_wall  = will_hit,
        direction      = dir,
        knockback_dist = knockback_dist,
    }

    if will_hit and tr then
        result.wall_dist = knockback_dist * tr.fraction
        result.wall_pos = Vector(
            target_pos.x + dir.x * knockback_dist * tr.fraction,
            target_pos.y + dir.y * knockback_dist * tr.fraction,
            target_pos.z
        )
        result.final_pos = result.wall_pos
    else
        result.wall_dist = knockback_dist
        result.final_pos = Vector(
            target_pos.x + dir.x * knockback_dist,
            target_pos.y + dir.y * knockback_dist,
            target_pos.z
        )
    end

    return result
end


function Prediction.EstimateMovementState(entity)
    if not entity or not entity:valid() then
        return { state = "unknown", speed = 0, airborne = false, on_ground = false, cc_state = "none" }
    end

    local vel, _ = Prediction.GetTrackedVelocity(entity)
    local speed_2d = vel:Length2D()

    local hero_name = get_hero_name(entity)
    local speeds = HERO_SPEEDS[hero_name] or MEAN_HERO_SPEEDS

    local on_ground = false
    local ok_flags, flags = pcall(function() return entity.m_fFlags end)
    if ok_flags and flags then
        on_ground = (flags % 2) == 1
    else
        on_ground = math.abs(vel.z) < 10
    end

    local cc_state = "none"
    if Utils then
        if Utils.IsStunned(entity) then
            cc_state = "stunned"
        elseif Utils.IsImmobilized(entity) then
            cc_state = "immobilized"
        end
    end

    local result = {
        speed       = speed_2d,
        velocity    = vel,
        hero_speeds = speeds,
        airborne    = not on_ground,
        on_ground   = on_ground,
        cc_state    = cc_state,
    }

    if cc_state == "stunned" then
        result.state = "stunned"
        return result
    elseif cc_state == "immobilized" then
        result.state = "immobilized"
        return result
    end

    if speed_2d < 10 then
        result.state = "idle"
    elseif speed_2d < CROUCH.BASE + 20 then
        result.state = "crouching"
    elseif speed_2d < speeds.move + 20 then
        result.state = "walking"
    elseif speed_2d < speeds.total + 50 then
        result.state = "sprinting"
    else
        result.state = "dashing"
    end

    return result
end


function Prediction.SimulateBounce(start_pos, direction, max_bounces, max_range_metres, options)
    options = options or {}
    local UNIT_METER = 37.7358490566
    local max_range  = (max_range_metres or 100) * UNIT_METER
    max_bounces = max_bounces or 3

    local positions   = { start_pos }
    local current_pos = start_pos
    local current_dir = Vector(direction.x, direction.y, direction.z):Normalized()
    local total_dist  = 0

    for i = 1, max_bounces do
        local remaining = max_range - total_dist
        if remaining <= 0 then break end

        local trace_start = Vector(current_pos.x, current_pos.y, current_pos.z + 10)
        local trace_end   = Vector(
            trace_start.x + current_dir.x * remaining,
            trace_start.y + current_dir.y * remaining,
            trace_start.z + current_dir.z * remaining
        )

        local ok, tr = pcall(function()
            return trace.line(trace_start, trace_end, 0, 0, 0, MASK_SOLID, 0,
                options.ignore_filter or nil)
        end)

        if ok and tr and tr.fraction < 0.99 then
            local hit_pos = Vector(
                trace_start.x + (trace_end.x - trace_start.x) * tr.fraction,
                trace_start.y + (trace_end.y - trace_start.y) * tr.fraction,
                trace_start.z + (trace_end.z - trace_start.z) * tr.fraction
            )
            positions[#positions + 1] = hit_pos
            total_dist = total_dist + remaining * tr.fraction

            if tr.normal then
                local dot = current_dir.x * tr.normal.x
                          + current_dir.y * tr.normal.y
                          + current_dir.z * tr.normal.z
                current_dir = Vector(
                    current_dir.x - 2 * dot * tr.normal.x,
                    current_dir.y - 2 * dot * tr.normal.y,
                    current_dir.z - 2 * dot * tr.normal.z
                ):Normalized()
            else
                current_dir = Vector(-current_dir.x, -current_dir.y, current_dir.z):Normalized()
            end

            current_pos = Vector(
                hit_pos.x + current_dir.x * 2,
                hit_pos.y + current_dir.y * 2,
                hit_pos.z + current_dir.z * 2
            )
        else
            local end_pos = Vector(
                current_pos.x + current_dir.x * remaining,
                current_pos.y + current_dir.y * remaining,
                current_pos.z + current_dir.z * remaining
            )
            positions[#positions + 1] = end_pos
            break
        end
    end

    return positions
end


function Prediction.IsPositionVisible(from_pos, to_pos, threshold)
    if not from_pos or not to_pos then return false end
    threshold = threshold or 0.95
    local ok, tr = pcall(function()
        return trace.line(from_pos, to_pos, 0, 0, 0, 0, 0, function() return false end)
    end)
    if ok and tr and tr.fraction then
        return tr.fraction > threshold
    end
    return false
end

function Prediction.IsEntityVisible(from_pos, to_pos, target_entity, max_dist)
    if not from_pos or not to_pos or not target_entity then return false end
    max_dist = max_dist or from_pos:Distance(to_pos)

    local visible = false
    pcall(function()
        local local_pawn = entity_list.local_pawn()
        local tr = trace.line(from_pos, to_pos, 0x4001, 0, 0, 0, 0, function(ent)
            if local_pawn and ent == local_pawn then return true end
            return false
        end)
        if tr then
            visible = tr:is_visible_entity(target_entity, max_dist)
        end
    end)
    if visible then return true end

    pcall(function()
        visible = trace.bullet(from_pos, to_pos, 1.0, target_entity)
    end)
    return visible
end

function Prediction.FindNearbyWalls(origin, max_distance, num_rays, z_offset)
    if not origin then return {} end
    num_rays = num_rays or 16
    z_offset = z_offset or 60

    local trace_origin = Vector(origin.x, origin.y, origin.z + z_offset)
    local walls = {}

    for i = 0, num_rays - 1 do
        local angle = (i / num_rays) * math.pi * 2
        local dir_x = math.cos(angle)
        local dir_y = math.sin(angle)

        local trace_end = Vector(
            trace_origin.x + dir_x * max_distance,
            trace_origin.y + dir_y * max_distance,
            trace_origin.z
        )

        local ok, tr = pcall(function()
            return trace.line(trace_origin, trace_end, 0, 0, 0, MASK_SOLID, 0, nil)
        end)

        if ok and tr and tr.fraction < 1.0 then
            local hit_dist = tr.fraction * max_distance
            local hit_pos = Vector(
                trace_origin.x + dir_x * hit_dist,
                trace_origin.y + dir_y * hit_dist,
                trace_origin.z
            )

            local normal
            if tr.normal then
                normal = tr.normal
            else
                normal = Vector(-dir_x, -dir_y, 0)
            end

            walls[#walls + 1] = {
                pos       = hit_pos,
                distance  = hit_dist,
                normal    = normal,
                angle_rad = angle,
            }
        end
    end

    table.sort(walls, function(a, b) return a.distance < b.distance end)
    return walls
end

function Prediction.FindClosestWall(origin, max_distance, num_rays)
    local walls = Prediction.FindNearbyWalls(origin, max_distance, num_rays)
    if #walls == 0 then return nil, nil, nil end
    local w = walls[1]
    return w.pos, w.normal, w.distance
end

function Prediction.FindBestWallTarget(origin, max_wall_dist, camera_pos, camera_angles, num_rays)
    local walls = Prediction.FindNearbyWalls(origin, max_wall_dist, num_rays)
    if #walls == 0 then return nil end

    local best = nil
    local best_fov = math.huge

    for _, wall in ipairs(walls) do
        if Prediction.IsPositionVisible(camera_pos, wall.pos) then
            local aim_angle = utils.calc_angle(camera_pos, wall.pos)
            local fov = utils.get_fov(camera_angles, aim_angle)
            if fov < best_fov then
                best_fov = fov
                best = {
                    pos      = wall.pos,
                    distance = wall.distance,
                    normal   = wall.normal,
                    fov      = fov,
                }
            end
        end
    end

    return best
end

function Prediction.SimulateMovementPredict(ent, time, aim_mode)
    if not ent or not ent:valid() then return Vector(0, 0, 0) end

    local aim_offset = Vector(0, 0, 0)
    local target_bone = (aim_mode == "head") and "head" or "spine_0"
    local bone_pos = ent:get_bone_pos(target_bone)
    local current_origin = ent:get_origin()
    if bone_pos and current_origin then
        aim_offset = bone_pos - current_origin
    end

    local ok, sim_pos = pcall(function()
        local final_pos = nil
        ent:simulate_movement(function(pos, vel)
            final_pos = pos
        end)
        return final_pos
    end)

    if ok and sim_pos then
        return sim_pos + aim_offset
    end

    return Prediction.PredictPlayer(ent, time, nil, nil, nil, nil, aim_mode)
end


function Prediction.GetSpeedModifier(ent)
    if not ent or not ent:valid() then return 1.0 end
    local ok, val = pcall(function()
        return ent:get_modifier_value(EModifierValue.MODIFIER_VALUE_BASE_MOVE_SPEED_PERCENT, 100)
    end)
    if ok and val and val ~= 100 then
        return val / 100.0
    end
    return 1.0
end


function Prediction.IsOnGround(ent)
    if not ent or not ent:valid() then return false end
    local ok, flags = pcall(function() return ent.m_fFlags end)
    if ok and flags then
        return (flags % 2) == 1
    end
    return false
end

function Prediction.SolveLeadPoint(target, base_pos, source_pos, opts)
    if not target or not target:valid() or not base_pos or not source_pos then
        return base_pos, 0
    end
    opts = opts or {}
    local proj_speed = opts.projectile_speed or 0
    local scale      = opts.scale or 1.0
    local max_lead   = opts.max_lead or 0.25
    local use_accel  = opts.use_acceleration or false
    local wall_clip  = opts.wall_clip or false
    local min_speed  = opts.min_speed or 45

    if proj_speed <= 0 then return base_pos, 0 end

    local vel, accel = Prediction.GetTrackedVelocity(target)
    vel = vel or Vector(0, 0, 0)
    accel = accel or Vector(0, 0, 0)
    if math.sqrt(vel.x * vel.x + vel.y * vel.y) < min_speed then
        return base_pos, 0
    end

    local function lead_for(t)
        local ht = use_accel and (0.5 * t * t) or 0
        return Vector(
            base_pos.x + vel.x * t + accel.x * ht,
            base_pos.y + vel.y * t + accel.y * ht,
            base_pos.z
        )
    end

    local t = math.min((source_pos:Distance(base_pos) / proj_speed) * scale, max_lead)
    for _ = 1, 2 do
        local p = lead_for(t)
        t = math.min((source_pos:Distance(p) / proj_speed) * scale, max_lead)
    end

    local predicted = lead_for(t)

    if wall_clip then
        local ok, tr = pcall(function()
            return trace.line(base_pos, predicted, 0, 0, 0, MASK_SOLID, 0, nil)
        end)
        if ok and tr and tr.fraction < 1.0 then
            predicted = Vector(
                base_pos.x + (predicted.x - base_pos.x) * tr.fraction * 0.95,
                base_pos.y + (predicted.y - base_pos.y) * tr.fraction * 0.95,
                base_pos.z
            )
        end
    end

    return predicted, t
end
end
local UNITS_PER_METER = 100
local TARGET_COLOR = Color(255, 35, 35, 255)
local FOV_COLOR = Color(255, 35, 35, 115)
local FONT = nil

local IN_ATTACK = (InputBitMask_t and InputBitMask_t.IN_ATTACK) or 1
local ABILITY_MASK = ((InputBitMask_t and InputBitMask_t.IN_ABILITY1) or 8589934592)
                   | ((InputBitMask_t and InputBitMask_t.IN_ABILITY2) or 17179869184)
                   | ((InputBitMask_t and InputBitMask_t.IN_ABILITY3) or 34359738368)
                   | ((InputBitMask_t and InputBitMask_t.IN_ABILITY4) or 68719476736)
local CAST_WINDOW = 0.35
local IN_ABILITY3 = (InputBitMask_t and InputBitMask_t.IN_ABILITY3) or 34359738368
local DM_CART_WINDOW = 0.35
local DM_SLOT_BITS = {
    [0] = (InputBitMask_t and InputBitMask_t.IN_ABILITY1) or 8589934592,
    [1] = (InputBitMask_t and InputBitMask_t.IN_ABILITY2) or 17179869184,
    [2] = (InputBitMask_t and InputBitMask_t.IN_ABILITY3) or 34359738368,
    [3] = (InputBitMask_t and InputBitMask_t.IN_ABILITY4) or 68719476736,
}

local PRIORITY_OPTIONS = { "Closest", "Low Life", "FOV" }
local AIM_BONE_OPTIONS = { "Auto", "Head", "Neck", "Chest", "Pelvis", "Feet" }
local AIM_BONE_CHAINS = {
    [0] = { "spine_2", "spine_1", "spine", "pelvis", "neck_0", "head" },
    [1] = { "head" },
    [2] = { "neck_0" },
    [3] = { "spine_1" },
    [4] = { "pelvis" },
}
local AIM_FALLBACK_HEIGHT = 58
local BONE_DISPLAY_NAMES = {
    head = "Head", neck_0 = "Neck", spine_2 = "Upper Chest",
    spine_1 = "Chest", spine = "Stomach", pelvis = "Pelvis", feet = "Feet"
}
local SKELETON_BONES = { "head", "neck_0", "spine_2", "spine_1", "spine", "pelvis" }
local function safe_create(parent, name, side)
    local ok, result = pcall(function()
        if side ~= nil then return parent:Create(name, side) end
        return parent:Create(name)
    end)
    return (ok and result) or parent
end

local function safe_switch(parent, name, default, icon)
    local ok, result = pcall(function()
        if icon then return parent:Switch(name, default, icon) end
        return parent:Switch(name, default)
    end)
    if ok and result then return result end
    ok, result = pcall(function() return parent:Switch(name, default) end)
    if ok and result then return result end
    return { Get = function() return default end, Set = function() end, ToolTip = function() end, Gear = function() return parent end }
end

local function safe_slider(parent, name, minv, maxv, default, fmt)
    local ok, result = pcall(function() return parent:Slider(name, minv, maxv, default, fmt) end)
    if ok and result then return result end
    return { Get = function() return default end, Set = function() end, ToolTip = function() end }
end

local function safe_combo(parent, name, items, default)
    local ok, result = pcall(function() return parent:Combo(name, items, default) end)
    if ok and result then return result end
    return { Get = function() return default end, Set = function() end, ToolTip = function() end }
end

local function safe_bind(parent, name, key)
    local ok, result = pcall(function() return parent:Bind(name, key) end)
    if ok and result then return result end
    return { IsDown = function() return false end, Get = function() return key end, ToolTip = function() end }
end

local function make_gear(control, label, fallback)
    local ok, gear = pcall(function() return control:Gear(label) end)
    return (ok and gear) or fallback
end

local tab_aim = Menu.Create(ROOT_NAME, "", ROOT_NAME, "Aim")
local tab_visual = Menu.Create(ROOT_NAME, "", ROOT_NAME, "Visual")
local tab_debug = Menu.Create(ROOT_NAME, "", ROOT_NAME, "Debug")

local main_group = safe_create(tab_aim, "Main", Enum.GroupSide.Left)
local target_group = safe_create(tab_aim, "Target", Enum.GroupSide.Left)
local tuning_group = safe_create(tab_aim, "Target Settings", Enum.GroupSide.Right)
local head_group = safe_create(tab_aim, "Head Items", Enum.GroupSide.Right)
local visual_group = safe_create(tab_visual, "Visual", Enum.GroupSide.Left)
local debug_group = safe_create(tab_debug, "Debug", Enum.GroupSide.Left)

local HERO_TRANSITION = 4.0
local HERO_DISPLAY = {
    hero_vampirebat = "Mina",
}
local function hero_display_name(internal)
    if not internal then return "?" end
    if HERO_DISPLAY[internal] then return HERO_DISPLAY[internal] end
    local loc
    pcall(function() loc = GameLocalizer and GameLocalizer.Find(internal) end)
    if type(loc) == "string" and loc ~= "" and not loc:find("^hero_") then
        return loc
    end
    local s = internal:gsub("^hero_", "")
    if #s == 0 then return internal end
    return s:sub(1, 1):upper() .. s:sub(2)
end

local tab_hero = Menu.Create(ROOT_NAME, "", ROOT_NAME, "Hero")

local hero_status_group = safe_create(tab_hero, "Hero", Enum.GroupSide.Left)
local hero_status_label
pcall(function() hero_status_label = hero_status_group:Label("Join a match with a hero.") end)

local hero_groups = {}
local HERO_CTRLS = {}

local dm = {}
do
    local g = safe_create(tab_hero, "Doorman Bell Functions", Enum.GroupSide.Left)
    dm.target_bell          = safe_switch(g, "Target Bell", true)
    dm.priority_target_bell = safe_switch(g, "Priority Target Bell", false)
    dm.auto_shot_bell       = safe_switch(g, "Auto Shot Bell", false)
    dm.bell_range           = safe_slider(g, "Bell Distance", 0, 100, 60, "%dm")
    dm.bell_height          = safe_slider(g, "Bell Aim Height", -120, 120, 0, "%d")
    dm.trigger_radius       = safe_switch(g, "Trigger Radius", true)
    local dm_trg_gear       = make_gear(dm.trigger_radius, "Trigger Settings", g)
    dm.auto_trigger_radius  = safe_switch(dm_trg_gear, "Auto Ability Radius", true)
    dm.shot_delay           = safe_slider(g, "Shot Delay", 0, 500, 80, "%dms")
    pcall(function() dm.target_bell:ToolTip("Targets the Bell (Doorman's bell). Required for the other Bell options.") end)
    pcall(function() dm.priority_target_bell:ToolTip("Silent Aim Assist prioritizes the Bell over aiming at enemies.") end)
    pcall(function() dm.auto_shot_bell:ToolTip("Auto-shoots the Bell (respecting Trigger Radius and Shot Delay).") end)
    pcall(function() dm.auto_trigger_radius:ToolTip("Uses the Bell ability's real range as the trigger radius (otherwise 5m).") end)
    hero_groups["hero_doorman"] = { g }
    HERO_CTRLS["hero_doorman"] = {
        dm.target_bell, dm.priority_target_bell, dm.auto_shot_bell,
        dm.bell_range, dm.bell_height, dm.trigger_radius, dm.auto_trigger_radius, dm.shot_delay,
    }
    pcall(function() g:Visible(false) end)
end

do
    local g = safe_create(tab_hero, "Doorman Cart Functions", Enum.GroupSide.Right)
    dm.cart_predict    = safe_switch(g, "Cart Prediction", true)
    dm.cart_speed      = safe_slider(g, "Cart Speed", 4, 30, 12, "%dm/s")
    dm.cart_cast_delay = safe_slider(g, "Cart Cast Delay", 0, 600, 250, "%dms")
    dm.cart_lead_scale = safe_slider(g, "Lead Scale", 50, 150, 100, "%d%%")
    dm.cart_max_lead   = safe_slider(g, "Max Lead", 100, 2000, 1200, "%dms")
    pcall(function() dm.cart_predict:ToolTip("When casting the Cart, psilent goes to the enemy's predicted position (accounts for their movement).") end)
    pcall(function() dm.cart_speed:ToolTip("Cart travel speed, used to compute the lead. Calibrate by observing.") end)
    local list = HERO_CTRLS["hero_doorman"]
    list[#list + 1] = dm.cart_predict
    list[#list + 1] = dm.cart_speed
    list[#list + 1] = dm.cart_cast_delay
    list[#list + 1] = dm.cart_lead_scale
    list[#list + 1] = dm.cart_max_lead
    table.insert(hero_groups["hero_doorman"], g)
    pcall(function() g:Visible(false) end)
end

do
    local g = safe_create(tab_hero, "Doorman Abilities Settings", Enum.GroupSide.Right)
    dm.ability = {}
    local abilities = {
        { slot = 0, name = "Bomb (Bell)",      opts = { "On Enemy", "On Floor", "Instant Cast", "Off" } },
        { slot = 1, name = "Doorway (Portal)", opts = { "On Enemy", "Off" } },
        { slot = 2, name = "Luggage Cart",     opts = { "On Enemy", "Instant Cast", "Off" }, ic_dist = 20 },
        { slot = 3, name = "Hotel (Ult)",      opts = { "Instant Cast", "Off" } },
    }
    local list = HERO_CTRLS["hero_doorman"]
    for _, a in ipairs(abilities) do
        local sw = safe_switch(g, a.name, false)
        local gear = make_gear(sw, a.name .. " Settings", g)
        local cast_type = safe_combo(gear, "Cast Type", a.opts, 0)
        pcall(function() cast_type:ToolTip("On Enemy: casts directly on the enemy.\nOn Floor (Bell only): on the enemy's ground/feet.\nInstant Cast: auto-casts when an enemy enters range (checks cooldown).") end)
        local entry = { enabled = sw, cast_type = cast_type, opts = a.opts, name = a.name }
        if a.ic_dist then
            entry.ic_distance = safe_slider(gear, "Instant Cast Distance", 0, 35, a.ic_dist, "%dm")
            pcall(function() entry.ic_distance:ToolTip("Max distance for Instant Cast to trigger (0-35m).") end)
        end
        dm.ability[a.slot] = entry
        list[#list + 1] = sw
    end
    table.insert(hero_groups["hero_doorman"], g)
    pcall(function() g:Visible(false) end)
end

local lg = {}
do
    local g = safe_create(tab_hero, "Lady Geist Abilities", Enum.GroupSide.Left)
    lg.ability = {}
    local abilities = {
        { slot = 0, name = "Essence Bomb",        opts = { "On Enemy", "Off" }, bomb = true },
        { slot = 1, name = "Life Drain",          opts = { "Instant Cast", "Off" } },
        { slot = 2, name = "Malice",              opts = { "On Enemy", "Off" } },
        { slot = 3, name = "Soul Exchange (Ult)", opts = { "Instant Cast", "Off" }, ult = true },
    }
    local list = {}
    for _, a in ipairs(abilities) do
        local sw = safe_switch(g, a.name, false)
        local gear = make_gear(sw, a.name .. " Settings", g)
        local cast_type = safe_combo(gear, "Cast Type", a.opts, 0)
        pcall(function() cast_type:ToolTip("On Enemy: Silent Aim Assist aims the ability at the enemy.\nInstant Cast: auto-casts when the condition is met (checks cooldown).\nOff: disables psilent for this ability when casting it (raw aim).") end)
        local entry = { enabled = sw, cast_type = cast_type, opts = a.opts, name = a.name }
        if a.ult then
            entry.ult_hp_pct = safe_slider(gear, "Cast at My HP %", 1, 100, 20, "%d%%")
            pcall(function() entry.ult_hp_pct:ToolTip("Auto-casts the Ult when YOUR health drops to this percentage or below (e.g. 20% = fires when you're at 20% HP or less).") end)
        end
        if a.bomb then
            entry.bomb_predict = safe_switch(gear, "Prediction", false)
            pcall(function() entry.bomb_predict:ToolTip("Leads moving targets so the bomb lands where they're heading (horizontal lead, keeps the same aim height).") end)
            entry.bomb_lead_scale = safe_slider(gear, "Lead Scale", 0, 200, 100, "%d%%")
            pcall(function() entry.bomb_lead_scale:ToolTip("How much to lead. 100% = full flight time. Increase if the bomb lands behind the target (compensates the arming time); decrease if it overshoots.") end)
        end
        lg.ability[a.slot] = entry
        list[#list + 1] = sw
    end
    hero_groups["hero_ghost"] = { g }
    HERO_CTRLS["hero_ghost"] = list
    pcall(function() g:Visible(false) end)
end

local tab_items = Menu.Create(ROOT_NAME, "", ROOT_NAME, "Items")
local item_cfg_group = safe_create(tab_items, "Configuration", Enum.GroupSide.Left)
local ui_item_autodetect = safe_switch(item_cfg_group, "Auto Detect Enemies", false)
pcall(function() ui_item_autodetect:ToolTip("ON: automatically marks, in each item's hero list, only the enemy heroes in the match (overrides manual selection). OFF: you pick the heroes manually.") end)
local item_groups = {
    weapon = safe_create(tab_items, "Item Balistico", Enum.GroupSide.Left),
    vital  = safe_create(tab_items, "Item Vital", Enum.GroupSide.Left),
    spirit = safe_create(tab_items, "Item Espiritual", Enum.GroupSide.Right),
}
local ITEM_DEFS = {
    weapon = {
        { "FleetFoot",       "upgrade_fleetfoot_boots" },
        { "Split Shot",      "upgrade_split_shot" },
        { "Alchemical Fire", "upgrade_thermal_detonator" },
        { "Blood Tribute",   "upgrade_blood_tribute" },
        { "Capacitor",       "upgrade_capacitor" },
    },
    vital = {
        { "Grit",               "upgrade_grit" },
        { "Dispel Magic",       "upgrade_reduce_debuff_duration" },
        { "Fury Trance",        "upgrade_fury_trance" },
        { "Healing Nova",       "upgrade_health_nova" },
        { "Majestic Leap",      "upgrade_rocket_booster" },
        { "Metal Skin",         "upgrade_metal_skin" },
        { "Rescue Beam",        "upgrade_rescue_beam" },
        { "Guardian Ward",      "upgrade_guardian_ward" },
        { "Restorative Locket", "upgrade_restorative_locket" },
        { "Return Fire",        "upgrade_return_fire" },
        { "Colossus",           "upgrade_colossus" },
        { "Divine Barrier",     "upgrade_divine_barrier" },
        { "Infuser",            "upgrade_infuser" },
        { "Phantom Strike",     "upgrade_phantom_strike" },
        { "Unstoppable",        "upgrade_unstoppable" },
        { "Vampiric Burst",     "upgrade_surging_power" },
    },
    spirit = {
        { "Cursed Relic",   "upgrade_glitch" },
        { "Knockdown",      "upgrade_target_stun" },
        { "Slowing Hex",    "upgrade_containment" },
        { "Cold Front",     "upgrade_cold_front" },
        { "Arctic Blast",   "upgrade_arctic_blast" },
        { "Disarming Hex",  "upgrade_greater_withering_whip" },
        { "Silence Wave",   "upgrade_targeted_silence" },
        { "Decay",          "upgrade_rupture" },
        { "Scourge",        "upgrade_discord" },
        { "Spirit Sap",     "upgrade_spirit_sap" },
        { "Rusted Barrel",  "upgrade_withering_whip" },
        { "Vortex Web",     "upgrade_aoe_root" },
        { "Echo Shard",     "upgrade_ability_power_shard" },
        { "Ethereal Shift", "upgrade_self_bubble" },
        { "Focus Lens",     "upgrade_focus_lens" },
        { "Magic Carpet",   "upgrade_magic_carpet" },
        { "Refresher",      "upgrade_ability_refresher" },
    },
}
local DEBUFF_TARGETS = {
    { "hero_atlas",      "Abrams",      "atlas" },
    { "hero_fencer",     "Apollo",      "fencer" },
    { "hero_bebop",      "Bebop",       "bebop" },
    { "hero_punkgoat",   "Billy",       "punkgoat" },
    { "hero_nano",       "Calico",      "nano" },
    { "hero_doorman",    "The Doorman", "doorman" },
    { "hero_drifter",    "Drifter",     "drifter" },
    { "hero_dynamo",     "Dynamo",      "dynamo" },
    { "hero_necro",      "Graves",      "necro" },
    { "hero_orion",      "Grey Talon",  "orion" },
    { "hero_haze",       "Haze",        "haze" },
    { "hero_astro",      "Holiday",     "astro" },
    { "hero_inferno",    "Infernus",    "inferno" },
    { "hero_kelvin",     "Kelvin",      "kelvin" },
    { "hero_ghost",      "Lady Geist",  "ghost" },
    { "hero_lash",       "Lash",        "lash" },
    { "hero_forge",      "McGinnis",    "forge" },
    { "hero_vampirebat", "Mina",        "vampirebat" },
    { "hero_mirage",     "Mirage",      "mirage" },
    { "hero_krill",      "Mo & Krill",  "krill" },
    { "hero_bookworm",   "Paige",       "bookworm" },
    { "hero_chrono",     "Paradox",     "chrono" },
    { "hero_synth",      "Pocket",      "synth" },
    { "hero_gigawatt",   "Seven",       "gigawatt" },
    { "hero_shiv",       "Shiv",        "shiv" },
    { "hero_werewolf",   "Silver",      "werewolf" },
    { "hero_magician",   "Sinclair",    "magician" },
    { "hero_priest",     "Venator",     "priest" },
    { "hero_frank",      "Victor",      "frank" },
    { "hero_hornet",     "Vindicta",    "hornet" },
    { "hero_viscous",    "Viscous",     "viscous" },
    { "hero_viper",      "Vyper",       "viper" },
    { "hero_warden",     "Warden",      "warden" },
    { "hero_wraith",     "Wraith",      "wraith" },
    { "hero_yamato",     "Yamato",      "yamato" },
}
local KNOCKDOWN_FLYERS = {
    { "hero_hornet", "Vindicta",   "hornet" },
    { "hero_orion",  "Grey Talon", "archer" },
    { "hero_lash",   "Lash",       "lash" },
}
local CURSED_TARGETS = {
    { "hero_dynamo",   "Dynamo",      "dynamo" },
    { "hero_fencer",   "Apollo",      "fencer" },
    { "hero_doorman",  "The Doorman", "doorman" },
    { "hero_haze",     "Haze",        "haze" },
    { "hero_lash",     "Lash",        "lash" },
    { "hero_gigawatt", "Seven",       "gigawatt" },
    { "hero_werewolf", "Silver",      "werewolf" },
    { "hero_magician", "Sinclair",    "magician" },
    { "hero_priest",   "Venator",     "priest" },
    { "hero_vampirebat", "Mina",      "vampirebat" },
    { "hero_warden",   "Warden",      "warden" },
    { "hero_atlas",    "Abrams",      "atlas" },
    { "hero_drifter",  "Drifter",     "drifter" },
    { "hero_astro",    "Holiday",     "astro" },
    { "hero_ghost",    "Lady Geist",  "ghost" },
    { "hero_necro",    "Graves",      "necro" },
    { "hero_forge",    "McGinnis",    "forge" },
    { "hero_krill",    "Mo & Krill",  "krill" },
    { "hero_bookworm", "Paige",       "bookworm" },
    { "hero_synth",    "Pocket",      "synth" },
    { "hero_wraith",   "Wraith",      "wraith" },
}
local DEBUFF_ITEMS = {
    upgrade_containment = { range = 25, all_option = true, names = {
        "upgrade_containment", "upgrade_improved_containment", "upgrade_greater_containment" } },
    upgrade_greater_withering_whip = { range = 32, all_option = true, names = {
        "upgrade_greater_withering_whip" } },
    upgrade_glitch = { range = 20, ult = true, all_option = true, roster = CURSED_TARGETS, names = {
        "upgrade_glitch", "upgrade_improved_glitch", "upgrade_greater_glitch" } },
    upgrade_targeted_silence = { range = 40, all_option = true, names = {
        "upgrade_targeted_silence", "upgrade_improved_targeted_silence", "upgrade_greater_targeted_silence" } },
    upgrade_target_stun = { range = 45, flyer = true, all_option = true, names = {
        "upgrade_target_stun", "upgrade_improved_target_stun", "upgrade_greater_target_stun" } },
    upgrade_rupture       = { range = 20, all = true, names = { "upgrade_rupture" } },
    upgrade_discord       = { range = 35, all = true, names = { "upgrade_discord" } },
    upgrade_spirit_sap    = { range = 40, all = true, names = { "upgrade_spirit_sap" } },
    upgrade_withering_whip = { range = 32, all_option = true, names = { "upgrade_withering_whip" } },
    upgrade_aoe_root      = { range = 30, all = true, min_enemies = true, aoe_radius = 12,
        margin = true, names = { "upgrade_aoe_root" } },
    upgrade_arctic_blast  = { range = 12, all = true, aoe = true, margin = true, names = { "upgrade_arctic_blast" } },
    upgrade_cold_front    = { range = 12, all = true, aoe = true, margin = true, max_m = 20, range_max = 20,
        names = { "upgrade_cold_front" } },
}

local function build_hero_selector(gear, roster, title, all_setup)
    pcall(function() gear:Label(title) end)
    if all_setup then all_setup() end
    local switches = {}
    for _, h in ipairs(roster) do
        switches[h[1]] = safe_switch(gear, h[2], true)
    end
    return {
        switches = switches,
        Get = function(_, id)
            local sw = id and switches[id]
            if not sw then return false end
            local v = false
            pcall(function() v = sw:Get() end)
            return v == true
        end,
    }
end

local function build_all_selector(gear, title)
    pcall(function() gear:Label(title) end)
    local sw = safe_switch(gear, "All", true)
    pcall(function() sw:ToolTip("Works on any enemy hero.") end)
    return {
        all = sw,
        Get = function()
            local v = false
            pcall(function() v = sw:Get() end)
            return v == true
        end,
    }
end

local items_ui = {}
local items_list = {}
local debuff_entries = {}
local echo_shard_entry = nil
local ethereal_entry = nil

local ETH = {}
ETH.modes = {
    abrams     = { "ult_dive" },
    billy      = { "chaingang" },
    geist      = { "swap" },
    holiday    = { "lasso" },
    lash       = { "ult_lock_a", "ult_grab_a", "ground_strike" },
    pocket     = { "affliction", "affliction_mod" },
    rem        = { "naptime" },
    shiv       = { "kill" },
    warden     = { "lockdown" },
}
ETH.extra = {
    apollo = {
        { type = "particle", id = "fencer_ult_dash_ground_line.vpcf", delay = 0 },
    },
    victor = {
        { type = "modifier", pat = "reviving", delay = 2.0 },
    },
    wraith = {
        { type = "particle", id = "wraith_psychic_lift_cast.vpcf", self_only = true, delay = 0 },
    },
    mina = {
        { type = "modifier", pat = "ability_vampirebat_batswarm/debuff", self_only = true, delay = 0 },
    },
    haze = {
        { type = "modifier", pat = "ability_bullet_flurry", delay = 0 },
    },
    billy = {
        { type = "modifier", pat = "ability_punkgoat_tether/waiting_for_pull", delay = 0 },
    },
}
ETH.range = {
    abrams  = 10,
    apollo  = 27,
    doorman = 7,
    dynamo  = 9,
    billy   = 14,
    haze    = 15,
    holiday = 20,
    wraith  = 13,
    shiv    = 6,
    victor  = 18,
}
ETH.range_default = 30
ETH.range_margin  = 1.15

ETH.dir = {
}


ETH.names = {
    abrams = "Abrams", apollo = "Apollo", billy = "Billy",
    doorman = "Doorman", dynamo = "Dynamo", geist = "Lady Geist",
    haze = "Haze", holiday = "Holiday",
    lash = "Lash", mina = "Mina",
    pocket = "Pocket", rem = "Rem",
    shiv = "Shiv", victor = "Victor",
    warden = "Warden", wraith = "Wraith",
}
ETH.hero_list = {}
for k, name in pairs(ETH.names) do ETH.hero_list[#ETH.hero_list + 1] = { key = k, name = name } end
table.sort(ETH.hero_list, function(a, b) return a.name < b.name end)
ETH.internal = {
    abrams = "hero_atlas", apollo = "hero_fencer", billy = "hero_punkgoat",
    doorman = "hero_doorman", dynamo = "hero_dynamo", geist = "hero_ghost",
    haze = "hero_haze", holiday = "hero_astro", lash = "hero_lash",
    mina = "hero_vampirebat", pocket = "hero_synth", rem = "hero_familiar",
    shiv = "hero_shiv", victor = "hero_frank", warden = "hero_warden",
    wraith = "hero_wraith",
}

for _, cat in ipairs({ "weapon", "vital", "spirit" }) do
    local g = item_groups[cat]
    for _, def in ipairs(ITEM_DEFS[cat]) do
        local label, id = def[1], def[2]
        local entry = { enabled = safe_switch(g, label, false), label = label, id = id, cat = cat }
        local dcfg = id and DEBUFF_ITEMS[id]
        if dcfg then
            local gear = make_gear(entry.enabled, label .. " Settings", g)
            entry.mode  = safe_combo(gear, "Auto Cast", { "Off", "Auto", "Key" }, 1)
            entry.key   = safe_bind(gear, "Key", Enum.ButtonCode.KEY_NONE or 0)
            entry.auto_range = safe_switch(gear, "Auto Range", true)
            local rmax = dcfg.range_max or 60
            entry.range = safe_slider(gear, "Activation Distance", 5, rmax, math.min(dcfg.range, rmax), "%dm")
            entry.flyer = dcfg.flyer or false
            entry.max_m = dcfg.max_m
            entry.aoe = dcfg.aoe or false
            entry.aoe_prop = dcfg.aoe_prop or "EndRadius"
            entry.margin = dcfg.margin or false
            entry.ult = dcfg.ult or false
            entry.names = dcfg.names or { id }
            if dcfg.min_enemies then
                entry.aoe_radius = dcfg.aoe_radius or 12
                entry.min_enemies = safe_slider(gear, "Min Enemies in Radius", 1, 6, 2, "%d")
                pcall(function() entry.min_enemies:ToolTip("Only casts when at least this many enemy heroes are within the item's AoE radius around the target.") end)
            end
            local all_setup = nil
            if dcfg.all_option then
                all_setup = function()
                    entry.all_enable = safe_switch(gear, "All", false)
                    pcall(function() entry.all_enable:ToolTip("ON: ignores the hero list and casts on the first enemy that enters range (any hero). OFF: uses the normal list/condition.") end)
                    local all_gear = make_gear(entry.all_enable, "All Settings", gear)
                    entry.all_auto_range = safe_switch(all_gear, "Auto Range", true)
                    pcall(function() entry.all_auto_range:ToolTip("ON: uses the item's automatic range. OFF: uses the manual 'Distance' below.") end)
                    entry.all_range = safe_slider(all_gear, "Distance", 5, 60, dcfg.range, "%dm")
                end
            end
            if dcfg.all then
                entry.heroes = build_all_selector(gear, "Target Heroes:")
            else
                local roster = dcfg.roster or (entry.flyer and KNOCKDOWN_FLYERS) or DEBUFF_TARGETS
                local title = entry.ult and "Heroes (auto on ult):"
                    or (entry.flyer and "Flyers (auto in air):" or "Target Heroes:")
                entry.heroes = build_hero_selector(gear, roster, title, all_setup)
            end
            pcall(function()
                entry.mode:ToolTip("Off: disabled. Auto: auto-casts when a target hero enters range. Key: only while the key is held.")
            end)
            pcall(function()
                entry.auto_range:ToolTip("ON: uses the item's real cast range as the trigger distance, so it never fires out of range. OFF: uses the Activation Distance below.")
            end)
            pcall(function()
                entry.range:ToolTip("Max distance (m) for the auto-cast to trigger (insta cast). Only applies when Auto Range is OFF. Always capped to the item's real range.")
            end)
            debuff_entries[#debuff_entries + 1] = entry
        elseif id == "upgrade_ability_power_shard" then
            local gear = make_gear(entry.enabled, label .. " Settings", g)
            entry.echo_auto = safe_switch(gear, "Auto (recharge on ability use)", true)
            pcall(function() entry.echo_auto:ToolTip("ON: as soon as you use the ability imbued with Echo Shard, Echo Shard is used instantly to reset its cooldown. OFF: does not auto-cast.") end)
            entry.echo_slot = safe_combo(gear, "Imbued Ability",
                { "Auto", "Ability 1", "Ability 2", "Ability 3", "Ability 4 (Ult)" }, 0)
            pcall(function() entry.echo_slot:ToolTip("Which ability has Echo Shard imbued. Auto = auto-detects. If Auto doesn't work, pick the ability (1-4) manually.") end)
            echo_shard_entry = entry
        elseif id == "upgrade_self_bubble" then
            local gear = make_gear(entry.enabled, label .. " Settings", g)
            entry.es_c4 = safe_switch(gear, "Damage Threshold", false)
            pcall(function() entry.es_c4:ToolTip("Fires when you take a lot of damage in a short time (damage accumulated within the seconds window).") end)
            local g4 = make_gear(entry.es_c4, "Damage Threshold", gear)
            entry.es_c4_window = safe_slider(g4, "Window (s)", 1, 10, 3, "%ds")
            entry.es_c4_dmg = safe_slider(g4, "Damage taken", 50, 3000, 400, "%d")
            entry.es_c5 = safe_switch(gear, "Dodge Enemy Ult", false)
            pcall(function() entry.es_c5:ToolTip("Auto Dodge for Some Ultimates (similar to the Umbrella Dodger, but I plan to implement more options).") end)
            local g5 = make_gear(entry.es_c5, "Dodge Enemy Ult", gear)
            entry.es_c5_heroes = {}
            entry.es_c5_eye = {}
            pcall(function() g5:Label("Heroes (ult dodge):") end)
            for _, h in ipairs(ETH.hero_list) do
                local hsw = safe_switch(g5, h.name, true)
                entry.es_c5_heroes[h.key] = hsw
                if h.key == "apollo" or h.key == "holiday" or h.key == "shiv" then
                    local ag = make_gear(hsw, h.name .. " Settings", g5)
                    local eyesw = safe_switch(ag, "Eye on Eye", false)
                    entry.es_c5_eye[h.key] = eyesw
                    pcall(function() eyesw:ToolTip("ON: only use Ethereal against " .. h.name .. "'s ult if you're SEEING him (on your screen). Extra protection against ults that don't come at you / when he isn't aiming at you.") end)
                elseif h.key == "doorman" then
                    local dg = make_gear(hsw, h.name .. " Settings", g5)
                    entry.es_c5_doorman_mode = safe_combo(dg, "Ult mode", { "Avoid (early)", "Escape at end" }, 0)
                    pcall(function() entry.es_c5_doorman_mode:ToolTip("Avoid (early): uses Ethereal as soon as it detects the Doorman channeling the ult (Hotel) near you (7m), before you're pulled in. Escape at end: lets the ult (6.5s) almost finish and uses Ethereal with ~0.75s left to leave cleanly (dodges the late-checkout damage).") end)
                end
            end
            entry.es_c6 = safe_switch(gear, "(coming soon)", false)
            pcall(function() entry.es_c6:ToolTip("Coming soon.") end)
            ethereal_entry = entry
        end
        items_list[#items_list + 1] = entry
        if id then items_ui[id] = entry end
    end
end

local ui = {}

ui.enable = safe_switch(main_group, "Enable", true)
ui.enable_key = safe_bind(main_group, "Enable Toggle Key", Enum.ButtonCode.KEY_NONE or 0)

ui.stop_on_los = safe_switch(main_group, "Wall Checker", true)

ui.target_enemy = { Get = function() return true end }
ui.psilent = { Get = function() return true end }

ui.fov = safe_slider(target_group, "Target FOV", 1, 500, 160, "%d")
ui.show_fov = safe_switch(target_group, "Show FOV", true)
ui.priority = safe_combo(target_group, "Priority", PRIORITY_OPTIONS, 0)

ui.silent_aim = safe_switch(target_group, "Silent Aim Assist", true)
local silent_aim_gear = make_gear(ui.silent_aim, "Silent Aim Assist", target_group)
ui.silent_aim_key = safe_bind(silent_aim_gear, "Hold Key Psy Ability", Enum.ButtonCode.KEY_LSHIFT)
ui.silent_aim_always = safe_switch(silent_aim_gear, "Psy Always Active (ignore key)", false)
ui.turn_to_target = { Get = function() return true end }
ui.turn_strength  = { Get = function() return 100 end }
ui.aim_on_attack = safe_switch(silent_aim_gear, "Psilent on Bullets", true)
pcall(function() ui.aim_on_attack:ToolTip("ON: aim assist works on your bullets/M1 too.\nOFF: your M1 uses your real crosshair, and aim assist only helps when you cast an ability.") end)
ui.m1_hit_chance = safe_slider(silent_aim_gear, "Psilent HitChance", 0, 100, 100, "%d%%")
pcall(function() ui.m1_hit_chance:ToolTip("Chance that each M1 shot is assisted by psilent. 100% = every shot aims; lower values leave some shots on your raw crosshair (configurable hit rate). Only affects M1 -- abilities are not affected.") end)

ui.min_dist = safe_slider(tuning_group, "Min Distance", 0, 30, 0, "%dm")
ui.max_dist = safe_slider(tuning_group, "Max Distance", 5, 80, 35, "%dm")
ui.aim_bone = safe_combo(tuning_group, "Aim Bone", AIM_BONE_OPTIONS, 0)
ui.predict = safe_switch(tuning_group, "Prediction", true)
ui.proj_speed = safe_slider(tuning_group, "Projectile Speed", 0, 200, 0, "%dm/s")
ui.prediction_scale = safe_slider(tuning_group, "Prediction Scale", 0, 200, 100, "%d%%")
ui.max_lead = safe_slider(tuning_group, "Max Lead", 0, 500, 250, "%dms")
ui.use_accel = safe_switch(tuning_group, "Use Acceleration", false)
pcall(function() ui.use_accel:ToolTip("Also accounts for the target speeding up or changing direction, not just their current speed. Turn off if the aim feels jittery.") end)
ui.pred_wall_clip = safe_switch(tuning_group, "Wall-Limit Prediction", true)
pcall(function() ui.pred_wall_clip:ToolTip("Stops the predicted (led) aim point from being pushed through walls/structures -- if the lead would cross solid geometry, it's pulled back to just before the wall.") end)

ui.head_mode = safe_combo(head_group, "Head Items", { "Off", "On" }, 0)
pcall(function() ui.head_mode:ToolTip("Items: Express Shot, Headshot Booster, Headhunter, Mystic Shot.") end)

ui.draw_target = safe_switch(visual_group, "Draw Target", true)
ui.show_bones = safe_switch(visual_group, "Show Aim Bone", false)
ui.target_color = visual_group:ColorPicker("Target Color", TARGET_COLOR)
ui.fov_color = visual_group:ColorPicker("FOV Color", FOV_COLOR)

ui.debug = safe_switch(debug_group, "Debug Logs", false)

local state = {
    target_cache_time = -1,
    target_cache = nil,
    players_cache = nil,
    players_cache_t = -1,
    target_bone_name = nil,
    enable_key_prev = false,
    pred_cleanup_t = 0,
    ability_seen_t = -999,
    hero_transition_until = 0,
    hero_loaded = {},
    dm_last_bell_shot = 0,
    dm_cart_window_until = 0,
    dm_ability_window = {},
    dm_instant_last = {},
    dm_off_suppress_until = 0,
    lg_instant_last = {},
    lg_ability_window = {},
    lg_suppress_until = 0,
    m1_assist_on = true,
    m1_roll_t = 0,
    m1_was_firing = false,
    aim_force_head = false,
    debuff_last = {},
    debuff_dbg_t = {},
    item_cd = {},
    leap_until = {},
    ult_cd = {},
    ult_until = {},
    item_auto_t = 0,
    item_owned = {},
}

local function get_combo_index(control, options, fallback)
    local ok, value = pcall(function() return control:Get() end)
    if not ok or value == nil then return fallback end
    if type(value) == "number" then
        if value >= 0 and value < #options then return math.floor(value) end
        return fallback
    end
    local text = string.lower(tostring(value))
    for i, label in ipairs(options) do
        if text == string.lower(label) or text:find(string.lower(label), 1, true) then return i - 1 end
    end
    return fallback
end

local function handle_enable_toggle()
    local down = false
    pcall(function() down = ui.enable_key:IsDown() end)
    if down and not state.enable_key_prev then
        pcall(function() ui.enable:Set(not ui.enable:Get()) end)
    end
    state.enable_key_prev = down
end

_G.__psy_dbglog = _G.__psy_dbglog or {}
local function debug_print(fmt, ...)
    if ui.debug:Get() then
        local msg = string.format(fmt, ...)
        print("[PsyAbility] " .. msg)
        local L = _G.__psy_dbglog
        L[#L + 1] = msg
        while #L > 60 do table.remove(L, 1) end
    end
end

local function register_callback(cb_obj, cb_name, handler_id, handler_fn)
    _G.__psyability_cb_mux = _G.__psyability_cb_mux or {}
    _G.__psyability_cb_mux[cb_name] = _G.__psyability_cb_mux[cb_name] or {}
    _G.__psyability_cb_mux[cb_name][handler_id] = handler_fn
    cb_obj:set(function(...)
        for _, fn in pairs(_G.__psyability_cb_mux[cb_name]) do
            local ok, err = pcall(fn, ...)
            if not ok then print("[PsyAbility] " .. tostring(err)) end
        end
    end)
end

local function is_valid_entity(ent)
    if not ent or not ent.valid then return false end
    local ok, valid = pcall(function() return ent:valid() end)
    return ok and valid or false
end

local function get_local_pawn()
    local ok, pawn = pcall(function() return entity_list.local_pawn() end)
    if not ok or not pawn then return nil end
    return is_valid_entity(pawn) and pawn or nil
end

local function get_text(ent)
    if not is_valid_entity(ent) then return "" end
    local values = {}
    local methods = { "get_name", "get_class_name", "get_class" }
    for _, method in ipairs(methods) do
        local fn = ent[method]
        if type(fn) == "function" then
            local ok, value = pcall(fn, ent)
            if ok and value then values[#values + 1] = tostring(value) end
        end
    end
    return string.lower(table.concat(values, " "))
end

local function is_alive(ent)
    if not is_valid_entity(ent) then return false end
    local ok, alive = pcall(function() return ent:is_alive() end)
    if ok then return alive == true end
    local health = nil
    pcall(function() health = ent.m_iHealth end)
    if health ~= nil and health <= 0 then return false end
    return true
end

local function is_player_pawn(ent)
    if not is_valid_entity(ent) then return false end
    local text = get_text(ent)
    return text:find("playerpawn", 1, true) ~= nil or text:find("citadelplayer", 1, true) ~= nil
end

local function get_health(ent)
    if not is_valid_entity(ent) then return 999999 end
    local ok, value = pcall(function() return ent.m_iHealth end)
    if ok and type(value) == "number" then return value end
    ok, value = pcall(function() return ent:get_health() end)
    if ok and type(value) == "number" then return value end
    return 999999
end

local function get_origin(ent)
    if not is_valid_entity(ent) then return nil end
    local ok, pos = pcall(function() return ent:get_origin() end)
    if ok and pos then return pos end
    return nil
end

local function get_velocity(ent)
    if not is_valid_entity(ent) then return Vector(0, 0, 0) end
    local ok, vel = pcall(function() return ent:get_velocity() end)
    if ok and vel then return vel end
    local fields = { "m_vecVelocity", "m_vecAbsVelocity", "m_vecBaseVelocity" }
    for _, field in ipairs(fields) do
        ok, vel = pcall(function() return ent[field] end)
        if ok and vel then return vel end
    end
    return Vector(0, 0, 0)
end

local function get_screen_center()
    local ok, size = pcall(function() return Render.ScreenSize() end)
    if ok and size and size.x and size.y then return size.x * 0.5, size.y * 0.5 end
    return 960, 540
end

local world_fov_distance
local function get_target_base_pos(target)
    local origin = get_origin(target)
    if not origin then return nil end

    if state.aim_force_head then
        local ok, hp = pcall(function() return target:get_bone_pos("head") end)
        if ok and hp then
            state.target_bone_name = "head"
            return hp
        end
    end

    local choice = get_combo_index(ui.aim_bone, AIM_BONE_OPTIONS, 0)

    if choice == 5 then
        state.target_bone_name = "feet"
        return Vector(origin.x, origin.y, origin.z)
    end

    if choice == 0 then
        local best_pos, best_bone, best_score = nil, nil, math.huge
        for _, bone in ipairs(SKELETON_BONES) do
            local ok, pos = pcall(function() return target:get_bone_pos(bone) end)
            if ok and pos then
                local score = world_fov_distance(pos)
                if score and score < best_score then
                    best_score, best_pos, best_bone = score, pos, bone
                end
            end
        end
        if best_pos then
            state.target_bone_name = best_bone
            return best_pos
        end
        for _, bone in ipairs(AIM_BONE_CHAINS[0]) do
            local ok, pos = pcall(function() return target:get_bone_pos(bone) end)
            if ok and pos then
                state.target_bone_name = bone
                return pos
            end
        end
        state.target_bone_name = nil
        return Vector(origin.x, origin.y, origin.z + AIM_FALLBACK_HEIGHT)
    end

    local chain = AIM_BONE_CHAINS[choice] or AIM_BONE_CHAINS[0]
    for _, bone in ipairs(chain) do
        local ok, pos = pcall(function() return target:get_bone_pos(bone) end)
        if ok and pos then
            state.target_bone_name = bone
            return pos
        end
    end
    for _, bone in ipairs(AIM_BONE_CHAINS[0]) do
        local ok, pos = pcall(function() return target:get_bone_pos(bone) end)
        if ok and pos then
            state.target_bone_name = bone
            return pos
        end
    end
    state.target_bone_name = nil
    return Vector(origin.x, origin.y, origin.z + AIM_FALLBACK_HEIGHT)
end

local function get_target_aim_pos(target)
    local origin = get_origin(target)
    if not origin then return nil end
    local base = get_target_base_pos(target) or Vector(origin.x, origin.y, origin.z + AIM_FALLBACK_HEIGHT)
    local z = state.target_bone_name and base.z or (origin.z + AIM_FALLBACK_HEIGHT)
    local pos = Vector(base.x, base.y, z)
    if not ui.predict:Get() then return pos end
    local pawn = get_local_pawn()
    local pawn_pos = get_origin(pawn)
    if not pawn_pos then return pos end

    if Prediction then
        local predicted = Prediction.SolveLeadPoint(target, pos, pawn_pos, {
            projectile_speed = ui.proj_speed:Get() * UNITS_PER_METER,
            scale            = ui.prediction_scale:Get() / 100,
            max_lead         = ui.max_lead:Get() / 1000,
            use_acceleration = ui.use_accel:Get(),
            wall_clip        = ui.pred_wall_clip:Get(),
        })
        return predicted or pos
    end

    local vel = get_velocity(target)
    local speed = math.sqrt((vel.x or 0) * (vel.x or 0) + (vel.y or 0) * (vel.y or 0))
    if speed < 45 then return pos end
    local projectile_speed = ui.proj_speed:Get() * UNITS_PER_METER
    if projectile_speed <= 0 then return pos end
    local travel = pawn_pos:Distance(pos) / projectile_speed
    local lead = math.min(travel * ui.prediction_scale:Get() / 100, ui.max_lead:Get() / 1000)
    return Vector(pos.x + vel.x * lead, pos.y + vel.y * lead, pos.z)
end

function world_fov_distance(pos)
    if not pos then return nil, nil end
    local screen_pos, on_screen = Render.WorldToScreen(pos)
    if not on_screen or not screen_pos then return nil, nil end
    local cx, cy = get_screen_center()
    local dx = screen_pos.x - cx
    local dy = screen_pos.y - cy
    return math.sqrt(dx * dx + dy * dy), screen_pos
end

local function has_los(pawn, target, from_pos, to_pos)
    if not ui.stop_on_los:Get() then return true end
    if not is_valid_entity(pawn) or not is_valid_entity(target) then return false end
    if not from_pos or not to_pos then return false end
    local ok_vis, visible = pcall(function() return target:is_visible() end)
    if ok_vis and visible == false then return false end
    if trace and trace.line then
        local ok_trace, clear = pcall(function()
            local tr = trace.line(Vector(from_pos.x, from_pos.y, from_pos.z + 55), to_pos)
            if not tr then return true end
            local fraction = tr.fraction or tr.frac or 1
            if fraction >= 0.95 then return true end
            local hit = tr.hit_entity or tr.entity
            return hit == target
        end)
        if ok_trace then return clear == true end
    end
    return true
end

local function target_fov_limit()
    return math.max(1, math.min(500, ui.fov:Get()))
end

local function priority_mode()
    local ok, value = pcall(function() return ui.priority:Get() end)
    if not ok or value == nil then return 0 end
    if type(value) == "string" then
        value = value:lower()
        if value:find("low", 1, true) then return 1 end
        if value:find("fov", 1, true) then return 2 end
        return 0
    end
    return value
end

local function score_target(pawn_pos, target_pos, fov_dist, ent)
    local mode = priority_mode()
    local dist = pawn_pos:Distance(target_pos)
    if mode == 1 then return get_health(ent) * 1000 + dist end
    if mode == 2 then return fov_dist or dist end
    return dist
end

local function get_players_cached()
    local now = global_vars.curtime()
    if state.players_cache and (now - (state.players_cache_t or -1)) < 0.1 then
        return state.players_cache
    end
    local ok, players = pcall(function() return entity_list.by_class_name("C_CitadelPlayerPawn") end)
    if ok and players then
        state.players_cache = players
        state.players_cache_t = now
    end
    return state.players_cache
end

local function find_target()
    local pawn = get_local_pawn()
    if not is_valid_entity(pawn) then return nil end
    if not ui.target_enemy:Get() then return nil end
    local pawn_pos = get_origin(pawn)
    if not pawn_pos then return nil end
    local players = get_players_cached()
    if not players then return nil end
    local best, best_score = nil, math.huge
    local min_dist = ui.min_dist:Get() * UNITS_PER_METER
    local max_dist = ui.max_dist:Get() * UNITS_PER_METER
    local fov_limit = target_fov_limit()
    for _, ent in ipairs(players) do
        if ent ~= pawn and is_player_pawn(ent) and is_alive(ent) then
            local team_ok = true
            pcall(function() team_ok = ent.m_iTeamNum ~= pawn.m_iTeamNum end)
            if team_ok then
                local target_pos = get_origin(ent)
                local aim_pos = get_target_aim_pos(ent)
                if target_pos and aim_pos then
                    local dist = pawn_pos:Distance(target_pos)
                    local fov_dist = world_fov_distance(aim_pos)
                    if dist >= min_dist and dist <= max_dist and fov_dist and fov_dist <= fov_limit and has_los(pawn, ent, pawn_pos, aim_pos) then
                        local score = score_target(pawn_pos, target_pos, fov_dist, ent)
                        if score < best_score then
                            best = ent
                            best_score = score
                        end
                    end
                end
            end
        end
    end
    return best
end

local function get_target_cached()
    local now = global_vars.curtime()
    if (now - state.target_cache_time) < 0.05 and is_valid_entity(state.target_cache) then
        return state.target_cache
    end
    state.target_cache = find_target()
    state.target_cache_time = now
    return state.target_cache
end

local function apply_psilent(cmd, aim_pos)
    if not ui.psilent:Get() or not aim_pos then return false end
    local ok = pcall(function() cmd:set_psilent_at_pos(aim_pos) end)
    return ok
end

local function normalize_yaw(deg)
    while deg > 180 do deg = deg - 360 end
    while deg < -180 do deg = deg + 360 end
    return deg
end

local function apply_view_to_pos(cmd, from_pos, aim_pos, strength)
    if not cmd or not from_pos or not aim_pos then return false end
    strength = math.max(0, math.min(1, strength or 1))
    if strength <= 0 then return false end
    local ok, result = pcall(function()
        local angles = cmd.viewangles
        if not angles then return false end
        local dx = aim_pos.x - from_pos.x
        local dy = aim_pos.y - from_pos.y
        local dz = aim_pos.z - (from_pos.z + 55)
        local hyp = math.sqrt(dx * dx + dy * dy)
        local atan2 = math.atan2 or math.atan
        local target_pitch = -math.deg(atan2(dz, hyp))
        local target_yaw = math.deg(atan2(dy, dx))
        local cur_pitch = angles.pitch or angles.x or angles[1] or 0
        local cur_yaw = angles.yaw or angles.y or angles[2] or 0
        local new_pitch = cur_pitch + (target_pitch - cur_pitch) * strength
        local new_yaw = cur_yaw + normalize_yaw(target_yaw - cur_yaw) * strength
        if angles.pitch ~= nil then angles.pitch = new_pitch elseif angles.x ~= nil then angles.x = new_pitch else angles[1] = new_pitch end
        if angles.yaw ~= nil then angles.yaw = new_yaw elseif angles.y ~= nil then angles.y = new_yaw else angles[2] = new_yaw end
        pcall(function() angles:Normalize() end)
        cmd.viewangles = angles
        return true
    end)
    return ok and result == true
end

local function dm_cast_type_of(slot)
    local a = dm.ability and dm.ability[slot]
    if not a then return nil end
    local idx = get_combo_index(a.cast_type, a.opts, 0)
    return a.opts[idx + 1]
end

local function dm_off_ability_pressed(buttons)
    if state.hero_cur ~= "hero_doorman" or not dm.ability then return false end
    for slot = 0, 3 do
        local a = dm.ability[slot]
        if a and a.enabled:Get() and dm_cast_type_of(slot) == "Off" then
            local bit = DM_SLOT_BITS[slot]
            if bit and (buttons & bit) ~= 0 then return true end
        end
    end
    return false
end

local function lg_off_pressed(buttons)
    if state.hero_cur ~= "hero_ghost" or not lg.ability then return false end
    for slot = 0, 3 do
        local a = lg.ability[slot]
        if a and a.enabled:Get() then
            local idx = get_combo_index(a.cast_type, a.opts, 0)
            if a.opts[idx + 1] == "Off" then
                local bit = DM_SLOT_BITS[slot]
                if bit and (buttons & bit) ~= 0 then return true end
            end
        end
    end
    return false
end

local HEAD_ITEMS = {
    "upgrade_express_shot",
    "upgrade_headshot_booster",
    "upgrade_headhunter",
    "upgrade_crackshot",
}
local HEAD_MODE_OPTS = { "Off", "On" }
local function head_mode()
    return HEAD_MODE_OPTS[get_combo_index(ui.head_mode, HEAD_MODE_OPTS, 0) + 1] or "Off"
end
local function head_items_ready(pawn)
    if not is_valid_entity(pawn) or #HEAD_ITEMS == 0 then return false end
    for _, name in ipairs(HEAD_ITEMS) do
        local ok, ab = pcall(function() return pawn:get_ability(name) end)
        if ok and is_valid_entity(ab) then
            local cd = nil
            pcall(function() cd = ab:get_cooldown() end)
            if cd and cd <= 0.05 then return true end
        end
    end
    return false
end

local function handle_aim(cmd)
    if not ui.enable:Get() then return end
    local pawn = get_local_pawn()
    if not is_valid_entity(pawn) or not is_alive(pawn) then return end

    if not ui.silent_aim:Get() or not ui.psilent:Get() then return end
    if not (ui.silent_aim_always:Get() or ui.silent_aim_key:IsDown()) then return end

    local off_now = global_vars.curtime()
    local off_buttons = (cmd.button_state0 or 0) | (cmd.button_state1 or 0) | (cmd.button_state2 or 0)
    if dm_off_ability_pressed(off_buttons) then state.dm_off_suppress_until = off_now + 0.35 end
    if off_now <= state.dm_off_suppress_until then return end

    if lg_off_pressed(off_buttons) then state.lg_suppress_until = off_now + 0.35 end
    if off_now <= state.lg_suppress_until then return end

    if not ui.aim_on_attack:Get() then
        local b0, b1, b2 = 0, 0, 0
        pcall(function() b0 = cmd.button_state0 or 0 end)
        pcall(function() b1 = cmd.button_state1 or 0 end)
        pcall(function() b2 = cmd.button_state2 or 0 end)
        local buttons = b0 | b1 | b2
        local now = global_vars.curtime()
        if (buttons & ABILITY_MASK) ~= 0 then
            state.ability_seen_t = now
        end
        local in_cast_window = (now - state.ability_seen_t) <= CAST_WINDOW
        if (buttons & IN_ATTACK) ~= 0 and not in_cast_window then
            return
        end
    end

    if ui.aim_on_attack:Get() then
        local b0, b1, b2 = 0, 0, 0
        pcall(function() b0 = cmd.button_state0 or 0 end)
        pcall(function() b1 = cmd.button_state1 or 0 end)
        pcall(function() b2 = cmd.button_state2 or 0 end)
        local buttons = b0 | b1 | b2
        local now = global_vars.curtime()
        if (buttons & ABILITY_MASK) ~= 0 then state.ability_seen_t = now end
        local in_cast_window = (now - state.ability_seen_t) <= CAST_WINDOW
        local firing_m1 = (buttons & IN_ATTACK) ~= 0 and not in_cast_window
        if firing_m1 then
            if (not state.m1_was_firing) or (now - state.m1_roll_t) >= 0.1 then
                state.m1_assist_on = (math.random(1, 100) <= ui.m1_hit_chance:Get())
                state.m1_roll_t = now
            end
            state.m1_was_firing = true
            if not state.m1_assist_on then return end
        else
            state.m1_was_firing = false
        end
    end

    local target = get_target_cached()
    if not is_valid_entity(target) or not is_alive(target) then return end

    state.aim_force_head = (head_mode() == "On") and head_items_ready(pawn)
    local aim_pos = get_target_aim_pos(target)
    state.aim_force_head = false
    if not aim_pos then return end

    local pawn_pos = get_origin(pawn)
    if not has_los(pawn, target, pawn_pos, aim_pos) then return end

    local did_psilent = apply_psilent(cmd, aim_pos)

    local did_turn = false
    if ui.turn_to_target:Get() then
        did_turn = apply_view_to_pos(cmd, pawn_pos, aim_pos, ui.turn_strength:Get() / 100)
    end

    if did_psilent or did_turn then
        local where = state.target_bone_name and (BONE_DISPLAY_NAMES[state.target_bone_name] or state.target_bone_name) or "fallback height"
        debug_print("Aiming at target (%s) [psilent=%s turn=%s @ %d%%]",
            where, tostring(did_psilent), tostring(did_turn), ui.turn_strength:Get())
    end
end

local DM_BELL_CLASS = "CDoormanBombProjectile"
local DM_BELL_HEIGHT = 35
local DM_DEFAULT_TRIGGER_RADIUS = 5 * UNITS_PER_METER
local DM_BELL_ABILITY_NAMES = {
    "citadel_ability_doorman_bomb", "ability_doorman_bomb", "doorman_bomb", "doorman_call_bell",
}
local DM_BELL_PATTERNS = { "bell", "doormanbomb", "doorman_bomb", "doorman_call_bell", "call_bell", "doorman_bell" }

local function dm_ability_text(ability)
    local v = {}
    for _, m in ipairs({ "get_name", "get_class_name" }) do
        local f = ability[m]
        if type(f) == "function" then
            local ok, val = pcall(f, ability)
            if ok and val then v[#v + 1] = tostring(val) end
        end
    end
    return string.lower(table.concat(v, " "))
end

local function dm_get_bell_ability(pawn)
    for _, name in ipairs(DM_BELL_ABILITY_NAMES) do
        local ok, ab = pcall(function() return pawn:get_ability(name) end)
        if ok and is_valid_entity(ab) then return ab end
    end
    for slot = 0, 1 do
        local ok, ab = pcall(function() return pawn:get_ability_by_slot(slot) end)
        if ok and is_valid_entity(ab) then
            local t = dm_ability_text(ab)
            for _, p in ipairs(DM_BELL_PATTERNS) do
                if t:find(p, 1, true) then return ab end
            end
        end
    end
    return nil
end

local function dm_read_ability_range(ability)
    if not is_valid_entity(ability) then return nil end
    for _, m in ipairs({ "get_cast_range", "get_range", "get_radius", "get_aoe_radius" }) do
        local ok_fn, fn = pcall(function() return ability[m] end)
        if ok_fn and type(fn) == "function" then
            local ok, v = pcall(function() return fn(ability) end)
            v = ok and tonumber(v) or nil
            if v and v > 0 then return v end
        end
    end
    for _, fld in ipairs({ "m_flCastRange", "m_flAbilityRange", "m_flRange", "m_flRadius", "m_flAOERadius", "m_flAuraRadius" }) do
        local ok, v = pcall(function() return ability[fld] end)
        v = ok and tonumber(v) or nil
        if v and v > 0 then return v end
    end
    return nil
end

local function dm_effective_trigger_radius(pawn)
    local radius = DM_DEFAULT_TRIGGER_RADIUS
    if dm.auto_trigger_radius:Get() then
        local ab = dm_get_bell_ability(pawn)
        local r = dm_read_ability_range(ab)
        if r and r > 0 then radius = r end
    end
    return radius
end

local function dm_get_nearest_bell(pawn, pawn_pos)
    local max_range = dm.bell_range:Get() * UNITS_PER_METER
    local fov_limit = target_fov_limit()
    local best, best_d = nil, math.huge
    local ok, bells = pcall(function() return entity_list.by_class_name(DM_BELL_CLASS) end)
    if ok and bells then
        for _, b in ipairs(bells) do
            if is_valid_entity(b) then
                local bp = get_origin(b)
                if bp then
                    local d = pawn_pos:Distance(bp)
                    if d <= max_range and d < best_d then
                        local aim = Vector(bp.x, bp.y, bp.z + DM_BELL_HEIGHT + dm.bell_height:Get())
                        local fov_dist = world_fov_distance(aim)
                        if fov_dist and fov_dist <= fov_limit then
                            best, best_d = b, d
                        end
                    end
                end
            end
        end
    end
    return best
end

local function dm_bell_aim_pos(bell)
    local o = get_origin(bell)
    if not o then return nil end
    return Vector(o.x, o.y, o.z + DM_BELL_HEIGHT + dm.bell_height:Get())
end

local DM_CONTENTS_SOLID = 0x1C1003
local DM_COLLISION_GROUP = 4

local function dm_bell_los(pawn, from_pos, to_pos)
    if not ui.stop_on_los:Get() then return true end
    if not from_pos or not to_pos then return false end
    if not (trace and trace.line) then return true end
    local ok, clear = pcall(function()
        local tr = trace.line(
            Vector(from_pos.x, from_pos.y, from_pos.z + 55), to_pos,
            DM_CONTENTS_SOLID, 0, 0, 7, DM_COLLISION_GROUP,
            function() return false end
        )
        if not tr then return true end
        local frac = tr.fraction or tr.frac or 1
        return frac >= 0.95
    end)
    if ok then return clear == true end
    return false
end

local function dm_enemy_in_bell_radius(pawn, bell, radius)
    local bp = get_origin(bell)
    if not bp then return false end
    local lteam = nil
    pcall(function() lteam = pawn.m_iTeamNum end)
    local ok, players = pcall(function() return entity_list.by_class_name("C_CitadelPlayerPawn") end)
    if not ok or not players then return false end
    for _, p in ipairs(players) do
        if p ~= pawn and is_valid_entity(p) and is_alive(p) then
            local et = nil
            pcall(function() et = p.m_iTeamNum end)
            if et ~= lteam then
                local pp = get_origin(p)
                if pp and bp:Distance(pp) <= radius then return true end
            end
        end
    end
    return false
end

local function handle_doorman(cmd)
    if not ui.enable:Get() then return end
    if state.hero_cur ~= "hero_doorman" then return end
    if not dm.target_bell:Get() then return end
    local pawn = get_local_pawn()
    if not is_valid_entity(pawn) or not is_alive(pawn) then return end
    local pawn_pos = get_origin(pawn)
    if not pawn_pos then return end
    local now = global_vars.curtime()

    if dm.auto_shot_bell:Get() then
        local delay = dm.shot_delay:Get() / 1000
        if now - state.dm_last_bell_shot >= delay then
            local bell = dm_get_nearest_bell(pawn, pawn_pos)
            if bell then
                local trigger_ok = true
                if dm.trigger_radius:Get() then
                    trigger_ok = dm_enemy_in_bell_radius(pawn, bell, dm_effective_trigger_radius(pawn))
                end
                if trigger_ok then
                    local aim = dm_bell_aim_pos(bell)
                    if aim and dm_bell_los(pawn, pawn_pos, aim) then
                        apply_psilent(cmd, aim)
                        pcall(function() cmd:add_buttonstate1(IN_ATTACK) end)
                        state.dm_last_bell_shot = now
                        return
                    end
                end
            end
        end
    end

    if not dm.priority_target_bell:Get() then return end
    local silent_active = ui.silent_aim:Get() and ui.psilent:Get()
        and (ui.silent_aim_always:Get() or ui.silent_aim_key:IsDown())
    if not silent_active then return end
    local bell = dm_get_nearest_bell(pawn, pawn_pos)
    if not bell then return end
    local aim = dm_bell_aim_pos(bell)
    if not aim or not dm_bell_los(pawn, pawn_pos, aim) then return end
    apply_psilent(cmd, aim)
end

local function dm_cart_predicted_pos(target, target_pos, source_pos)
    local vel = Vector(0, 0, 0)
    if Prediction then vel = Prediction.GetTrackedVelocity(target) or vel else vel = get_velocity(target) end
    local speed = math.sqrt((vel.x or 0) * (vel.x or 0) + (vel.y or 0) * (vel.y or 0))
    if speed < 45 or not source_pos then return target_pos end
    local cart_speed = math.max(1, dm.cart_speed:Get() * UNITS_PER_METER)
    local cast_delay = math.max(0, dm.cart_cast_delay:Get()) / 1000
    local lead_scale = math.max(0.1, dm.cart_lead_scale:Get() / 100)
    local max_lead = math.max(0.05, dm.cart_max_lead:Get() / 1000)
    local dist = source_pos:Distance(target_pos)
    local lead = math.min((cast_delay + (dist / cart_speed)) * lead_scale, max_lead)
    local first = Vector(target_pos.x + vel.x * lead, target_pos.y + vel.y * lead, target_pos.z)
    local refined = source_pos:Distance(first)
    lead = math.min((cast_delay + (refined / cart_speed)) * lead_scale, max_lead)
    return Vector(target_pos.x + vel.x * lead, target_pos.y + vel.y * lead, target_pos.z)
end

local function handle_doorman_cart(cmd)
    if not ui.enable:Get() then return end
    if state.hero_cur ~= "hero_doorman" then return end
    if not dm.cart_predict:Get() then return end
    if dm_cast_type_of(2) ~= "On Enemy" then return end
    local now = global_vars.curtime()
    local buttons = (cmd.button_state0 or 0) | (cmd.button_state1 or 0) | (cmd.button_state2 or 0)
    if (buttons & IN_ABILITY3) ~= 0 then
        state.dm_cart_window_until = now + DM_CART_WINDOW
    end
    if now > state.dm_cart_window_until then return end

    local pawn = get_local_pawn()
    if not is_valid_entity(pawn) or not is_alive(pawn) then return end
    local pawn_pos = get_origin(pawn)
    if not pawn_pos then return end
    local target = get_target_cached()
    if not is_valid_entity(target) or not is_alive(target) then return end
    local target_pos = get_origin(target)
    if not target_pos then return end

    local predicted = dm_cart_predicted_pos(target, target_pos, pawn_pos)
    if not predicted then return end
    if not has_los(pawn, target, pawn_pos, predicted) then return end
    apply_psilent(cmd, predicted)
end

local DM_FLOOR_HEIGHT = 40
local function dm_on_floor_aim(pawn_pos, target, height_off, dist_off)
    local o = get_origin(target)
    if not o then return nil end
    local aim = Vector(o.x, o.y, o.z + (height_off or 0))
    if dist_off and dist_off ~= 0 and pawn_pos then
        local dx = aim.x - pawn_pos.x
        local dy = aim.y - pawn_pos.y
        local len = math.sqrt(dx * dx + dy * dy)
        if len > 0.001 then
            aim = Vector(aim.x + (dx / len) * dist_off, aim.y + (dy / len) * dist_off, aim.z)
        end
    end
    return aim
end

local function dm_cast_name(a)
    local idx = get_combo_index(a.cast_type, a.opts, 0)
    return a.opts[idx + 1] or "On Enemy"
end

local function dm_ability_range(ability)
    if not is_valid_entity(ability) then return nil end
    for _, prop in ipairs({ "AbilityCastRange", "Radius" }) do
        local ok, v = pcall(function() return ability:get_scaled_property(prop) end)
        v = ok and tonumber(v) or nil
        if v and v > 0 then return v end
    end
    return nil
end

local function dm_instant_target(pawn, pawn_pos, range, use_fov)
    local lteam = nil
    pcall(function() lteam = pawn.m_iTeamNum end)
    local fov_limit = use_fov and target_fov_limit() or nil
    local ok, ps = pcall(function() return entity_list.by_class_name("C_CitadelPlayerPawn") end)
    if not ok or not ps then return nil end
    local best, best_d = nil, math.huge
    for _, p in ipairs(ps) do
        if p ~= pawn and is_valid_entity(p) and is_alive(p) then
            local et = nil
            pcall(function() et = p.m_iTeamNum end)
            if et ~= lteam then
                local pp = get_origin(p)
                if pp then
                    local d = pawn_pos:Distance(pp)
                    if d <= range and d < best_d then
                        local in_fov = true
                        if use_fov then
                            local fd = world_fov_distance(Vector(pp.x, pp.y, pp.z + 55))
                            in_fov = fd ~= nil and fd <= fov_limit
                        end
                        local aim = Vector(pp.x, pp.y, pp.z + DM_FLOOR_HEIGHT)
                        if in_fov and dm_bell_los(pawn, pawn_pos, aim) then
                            best, best_d = p, d
                        end
                    end
                end
            end
        end
    end
    return best
end

local function dm_handle_instant_cast(cmd, pawn, pawn_pos, slot, a, now)
    local ability = nil
    pcall(function() ability = pawn:get_ability_by_slot(slot) end)
    if not is_valid_entity(ability) then return end
    local can = 1
    pcall(function() can = ability:can_be_executed() end)
    if can ~= 0 then return end
    if now - (state.dm_instant_last[slot] or 0) < 0.25 then return end
    local range
    if a.ic_distance then
        range = a.ic_distance:Get() * UNITS_PER_METER
    else
        range = dm_ability_range(ability)
    end
    if not range or range <= 0 then return end
    local use_fov = a.ic_distance ~= nil
    local target = dm_instant_target(pawn, pawn_pos, range, use_fov)
    if not target then return end
    local o = get_origin(target)
    if not o then return end
    apply_psilent(cmd, Vector(o.x, o.y, o.z + DM_FLOOR_HEIGHT))
    pcall(function() cmd:add_buttonstate1(DM_SLOT_BITS[slot]) end)
    state.dm_instant_last[slot] = now
end

local function handle_doorman_abilities(cmd)
    if not ui.enable:Get() then return end
    if state.hero_cur ~= "hero_doorman" or not dm.ability then return end
    local pawn = get_local_pawn()
    if not is_valid_entity(pawn) or not is_alive(pawn) then return end
    local pawn_pos = get_origin(pawn)
    if not pawn_pos then return end
    local now = global_vars.curtime()
    local buttons = (cmd.button_state0 or 0) | (cmd.button_state1 or 0) | (cmd.button_state2 or 0)

    for slot = 0, 3 do
        local a = dm.ability[slot]
        if a and a.enabled:Get() then
            local ct = dm_cast_name(a)
            if ct == "Off" then
            elseif ct == "Instant Cast" then
                dm_handle_instant_cast(cmd, pawn, pawn_pos, slot, a, now)
            else
                local bit = DM_SLOT_BITS[slot]
                if bit and (buttons & bit) ~= 0 then
                    state.dm_ability_window[slot] = now + DM_CART_WINDOW
                end
                local win = state.dm_ability_window[slot]
                if win and now <= win then
                    if ct == "On Floor" then
                        local target = get_target_cached()
                        if is_valid_entity(target) and is_alive(target) then
                            local aim = dm_on_floor_aim(pawn_pos, target, DM_FLOOR_HEIGHT, 0)
                            if aim and has_los(pawn, target, pawn_pos, aim) then
                                apply_psilent(cmd, aim)
                            end
                        end
                    end
                end
            end
        end
    end
end

local LG_BODY_HEIGHT = 55
local LG_FEET_RANGE   = 25 * 39.37
local LG_PELVIS_RANGE = 35 * 39.37
local LG_HEAD_RANGE   = 42 * 39.37
local LG_BOMB_SPEED   = 2000

local function lg_bone_aim(target, bone, origin)
    local ok, p = pcall(function() return target:get_bone_pos(bone) end)
    if ok and p then return p end
    return Vector(origin.x, origin.y, origin.z + AIM_FALLBACK_HEIGHT)
end

local function lg_local_hp_pct(pawn)
    local hp = get_health(pawn)
    local maxhp = nil
    pcall(function() maxhp = pawn:get_max_health() end)
    if not maxhp or maxhp <= 0 then pcall(function() maxhp = pawn.m_iMaxHealth end) end
    if not maxhp or maxhp <= 0 then return 100 end
    return (hp / maxhp) * 100
end

local function lg_pick_target(pawn, pawn_pos, range)
    local lteam = nil
    pcall(function() lteam = pawn.m_iTeamNum end)
    local ok, ps = pcall(function() return entity_list.by_class_name("C_CitadelPlayerPawn") end)
    if not ok or not ps then return nil end
    local best, best_d = nil, math.huge
    for _, p in ipairs(ps) do
        if p ~= pawn and is_valid_entity(p) and is_alive(p) then
            local et = nil
            pcall(function() et = p.m_iTeamNum end)
            if et ~= lteam then
                local pp = get_origin(p)
                if pp then
                    local d = pawn_pos:Distance(pp)
                    if d <= range and d < best_d then
                        local aim = Vector(pp.x, pp.y, pp.z + LG_BODY_HEIGHT)
                        if dm_bell_los(pawn, pawn_pos, aim) then
                            best, best_d = p, d
                        end
                    end
                end
            end
        end
    end
    return best
end

local function lg_ability_ready(pawn, slot)
    local ability = nil
    pcall(function() ability = pawn:get_ability_by_slot(slot) end)
    if not is_valid_entity(ability) then return nil end
    local can = 1
    pcall(function() can = ability:can_be_executed() end)
    if can ~= 0 then return nil end
    return ability
end

local function lg_press_slot(cmd, slot)
    pcall(function()
        cmd:add_buttonstate1(DM_SLOT_BITS[slot])
        cmd:add_buttonstate2(DM_SLOT_BITS[slot])
    end)
end

local function lg_handle_ult_instant(cmd, pawn, pawn_pos, a, now)
    if now - (state.lg_instant_last[3] or 0) < 0.25 then return end
    if lg_local_hp_pct(pawn) > a.ult_hp_pct:Get() then return end
    local ability = lg_ability_ready(pawn, 3)
    if not ability then return end
    local range = dm_ability_range(ability)
    if not range or range <= 0 then return end
    local target = lg_pick_target(pawn, pawn_pos, range)
    if not target then return end
    local o = get_origin(target)
    if not o then return end
    apply_psilent(cmd, Vector(o.x, o.y, o.z + LG_BODY_HEIGHT))
    lg_press_slot(cmd, 3)
    state.lg_instant_last[3] = now
end

local function lg_handle_drain_instant(cmd, pawn, pawn_pos, now)
    if now - (state.lg_instant_last[1] or 0) < 0.25 then return end
    local ability = lg_ability_ready(pawn, 1)
    if not ability then return end
    local range = dm_ability_range(ability)
    if not range or range <= 0 then return end
    local target = dm_instant_target(pawn, pawn_pos, range, false)
    if not target then return end
    local o = get_origin(target)
    if not o then return end
    apply_psilent(cmd, Vector(o.x, o.y, o.z + LG_BODY_HEIGHT))
    lg_press_slot(cmd, 1)
    state.lg_instant_last[1] = now
end

local function handle_ladygeist(cmd)
    if not ui.enable:Get() then return end
    if state.hero_cur ~= "hero_ghost" or not lg.ability then return end
    local pawn = get_local_pawn()
    if not is_valid_entity(pawn) or not is_alive(pawn) then return end
    local pawn_pos = get_origin(pawn)
    if not pawn_pos then return end
    local now = global_vars.curtime()
    local buttons = (cmd.button_state0 or 0) | (cmd.button_state1 or 0) | (cmd.button_state2 or 0)

    for slot = 0, 3 do
        local a = lg.ability[slot]
        if a and a.enabled:Get() then
            local ct = dm_cast_name(a)
            if ct == "Instant Cast" then
                if slot == 3 then
                    lg_handle_ult_instant(cmd, pawn, pawn_pos, a, now)
                elseif slot == 1 then
                    lg_handle_drain_instant(cmd, pawn, pawn_pos, now)
                end
            elseif slot == 0 and ct == "On Enemy" then
                local bit = DM_SLOT_BITS[slot]
                if bit and (buttons & bit) ~= 0 then
                    state.lg_ability_window[slot] = now + DM_CART_WINDOW
                end
                local win = state.lg_ability_window[slot]
                local silent_active = ui.silent_aim:Get() and ui.psilent:Get()
                    and (ui.silent_aim_always:Get() or ui.silent_aim_key:IsDown())
                if silent_active and win and now <= win then
                    local target = get_target_cached()
                    if is_valid_entity(target) and is_alive(target) then
                        local o = get_origin(target)
                        if o then
                            local d = pawn_pos:Distance(o)
                            local aim
                            if d < LG_FEET_RANGE then
                                aim = Vector(o.x, o.y, o.z)
                            elseif d < LG_PELVIS_RANGE then
                                aim = lg_bone_aim(target, "pelvis", o)
                            elseif d <= LG_HEAD_RANGE then
                                aim = lg_bone_aim(target, "head", o)
                            end
                            if aim and Prediction and a.bomb_predict and a.bomb_predict:Get() then
                                local vel = Prediction.GetTrackedVelocity(target) or Vector(0, 0, 0)
                                if math.sqrt(vel.x * vel.x + vel.y * vel.y) >= 45 then
                                    local t = (d / LG_BOMB_SPEED) * (a.bomb_lead_scale:Get() / 100)
                                    aim = Vector(aim.x + vel.x * t, aim.y + vel.y * t, aim.z)
                                end
                            end
                            if aim and has_los(pawn, target, pawn_pos, aim) then
                                apply_psilent(cmd, aim)
                                apply_view_to_pos(cmd, pawn_pos, aim, 1.0)
                            end
                        end
                    end
                end
            end
        end
    end
end

local function get_font()
    if not FONT then FONT = Render.LoadFont("Arial", Enum.FontCreate.FONTFLAG_ANTIALIAS, 400) end
    return FONT
end

local function draw_visuals()
    if not ui.enable:Get() then return end
    local pawn = get_local_pawn()
    if not is_valid_entity(pawn) or not is_alive(pawn) then return end

    if ui.show_fov:Get() and ui.target_enemy:Get() then
        local cx, cy = get_screen_center()
        Render.Circle(Vec2(cx, cy), target_fov_limit(), ui.fov_color:Get(), 1)
    end

    if ui.draw_target:Get() then
        local target = get_target_cached()
        if is_valid_entity(target) then
            local aim_pos = get_target_aim_pos(target)
            local screen_pos, on_screen = Render.WorldToScreen(aim_pos)
            local color = ui.target_color:Get()
            if on_screen and screen_pos then
                Render.Circle(screen_pos, 10, color, 2)
                Render.Line(Vec2(screen_pos.x - 6, screen_pos.y), Vec2(screen_pos.x + 6, screen_pos.y), color, 1)
                Render.Line(Vec2(screen_pos.x, screen_pos.y - 6), Vec2(screen_pos.x, screen_pos.y + 6), color, 1)
            end
            if ui.show_bones:Get() then
                local font = get_font()
                for _, bone in ipairs(SKELETON_BONES) do
                    local ok, bpos = pcall(function() return target:get_bone_pos(bone) end)
                    if ok and bpos then
                        local bsp, b_on_screen = Render.WorldToScreen(bpos)
                        if b_on_screen and bsp then
                            local is_active = (bone == state.target_bone_name)
                            if is_active then
                                Render.Circle(bsp, 6, color, 2)
                                Render.Text(font, 11, BONE_DISPLAY_NAMES[bone] or bone, Vec2(bsp.x + 10, bsp.y - 6), color)
                            else
                                Render.Circle(bsp, 2, Color(190, 190, 190, 130), 1)
                            end
                        end
                    end
                end
            end
        end
    end
end

local DEBUFF_RANGE_MARGIN = 2

local function tech_radius_pct()
    local now = global_vars.curtime()
    if state.tech_radius_t and (now - state.tech_radius_t) < 1.0 then
        return state.tech_radius_pct or 0
    end
    state.tech_radius_t = now
    local pct = 0
    local H = _G.HERO_LIB
    local lp = get_local_pawn()
    if H and is_valid_entity(lp) then
        local abs = nil
        pcall(function() abs = lp:get_abilities() end)
        if type(abs) == "table" then
            for _, a in ipairs(abs) do
                local an = nil
                pcall(function() an = tostring(a:get_name()) end)
                if an and an:find("^upgrade_") then
                    local v = nil
                    pcall(function() v = H.get_cached_property_num(a, "TechRadiusMultiplier") end)
                    if type(v) == "number" then pct = pct + v end
                end
            end
        end
    end
    state.tech_radius_pct = pct
    return pct
end

local function debuff_range_m(entry, ab)
    local H = _G.HERO_LIB
    local cast_m = nil
    if ab and H then
        if entry.aoe then
            local base = nil
            pcall(function() base = H.get_cached_property_num(ab, entry.aoe_prop or "EndRadius") end)
            if type(base) == "number" and base > 0 then
                cast_m = base * (1 + tech_radius_pct() / 100)
            end
        else
            local units = nil
            pcall(function() units = ab:get_cast_range() end)
            if type(units) == "number" and units > 0 then
                local u2m = (H.UNITS_TO_METERS and H.UNITS_TO_METERS > 0) and H.UNITS_TO_METERS or 0.0265
                cast_m = units * u2m
            end
        end
        if not cast_m or cast_m <= 0 then
            pcall(function() cast_m = H.get_cached_property_num(ab, "AbilityCastRange") end)
        end
    end
    if not cast_m or cast_m <= 0 then cast_m = entry.range:Get() end
    if entry.max_m and cast_m > entry.max_m then cast_m = entry.max_m end
    local final
    if entry.auto_range:Get() then
        final = cast_m
    else
        final = math.min(entry.range:Get(), cast_m)
    end
    if entry.margin then
        final = final - DEBUFF_RANGE_MARGIN
        if final < 1 then final = 1 end
    end
    return final
end

local LEAP_WINDOW = 1.5
local FLYER_SIGNS = {
    hero_hornet = { mods = { "hornetleap" } },
    hero_orion  = { mods = { "airraid", "powerjump" } },
    hero_lash   = { cooldown_abils = { "lash_ultimate", "rocket_booster" } },
}

local function enemy_key(e)
    local k = nil
    pcall(function() k = e:get_index() end)
    return k or tostring(e)
end

local function enemy_ability_like(e, sub)
    local abs = nil
    pcall(function() abs = e:get_abilities() end)
    if type(abs) ~= "table" then return nil end
    sub = sub:lower()
    for _, a in ipairs(abs) do
        local an = ""
        pcall(function() an = tostring(a:get_name()):lower() end)
        if an:find(sub, 1, true) then return a end
    end
    return nil
end

local function enemy_modifier_names(e)
    local mods = nil
    pcall(function() mods = e:get_modifiers() end)
    if type(mods) ~= "table" then return {} end
    local names = {}
    for _, m in ipairs(mods) do
        local cn = nil
        pcall(function() cn = m:get_class_name() end)
        if not cn then pcall(function() cn = m:get_vdata_class_name() end) end
        if cn then names[#names + 1] = tostring(cn) end
    end
    return names
end

local function enemy_in_flight_ability(e, hero_name)
    local signs = FLYER_SIGNS[hero_name]
    if not signs then return false end
    if signs.mods and #signs.mods > 0 then
        for _, cn in ipairs(enemy_modifier_names(e)) do
            local lc = cn:lower():gsub("_", "")
            for _, p in ipairs(signs.mods) do
                if lc:find(p, 1, true) then return true end
            end
        end
    end
    if signs.cooldown_abils then
        local now = global_vars.curtime()
        local key = enemy_key(e)
        for _, sub in ipairs(signs.cooldown_abils) do
            local ab = enemy_ability_like(e, sub)
            if ab then
                local cd = nil
                pcall(function() cd = ab:get_cooldown() end)
                if type(cd) == "number" then
                    local pk = tostring(key) .. "|" .. sub
                    local prev = state.item_cd[pk]
                    if prev ~= nil and prev <= 0.3 and cd > 1.0 then
                        state.leap_until[key] = now + LEAP_WINDOW
                    end
                    state.item_cd[pk] = cd
                end
            end
        end
        local u = state.leap_until[key]
        if u and now < u then return true end
    end
    return false
end

local CURSED_ULT_SIGNS = {
    hero_dynamo     = { "self_vacuum", "vacuumaura" },
    hero_fencer     = { "fencer_ultimate" },
    hero_haze       = { "bullet_flurry" },
    hero_lash       = { "lash_ultimate", "lash_ult_lock", "lash_grab", "lash_ult_target", "rocket_booster" },
    hero_gigawatt   = { "storm_cloud" },
    hero_magician   = { "magician_copyult" },
    hero_priest     = { "priest_weaponswap" },
    hero_vampirebat = { "vampirebat_batswarm", "batswarm", "nox_nostra" },
    hero_warden     = { "riot_protocol" },
    hero_doorman    = { "doorman_hotel" },
    hero_werewolf   = { "werewolf_transformation" },
    hero_astro      = { "gravity_lasso" },
    hero_ghost      = { "health_swap" },
    hero_atlas      = { "bull_leap" },
    hero_drifter    = { "drifter_darkness" },
    hero_necro      = { "necro_gravestone" },
    hero_forge      = { "rocket_barrage" },
    hero_krill      = { "ult_combo" },
    hero_bookworm   = { "bookworm_knightcharge", "knightcharge" },
    hero_synth      = { "synth_affliction" },
    hero_wraith     = { "psychic_lift" },
}
local PARTICLE_ULT_SIGNS = {
    hero_fencer   = { "fencer_ultimate" },
    hero_dynamo   = { "dynamo_singularity" },
    hero_werewolf = { "werewolf_transform" },
    hero_doorman  = { "doorman_hotel", "doorman_ultimate" },
    hero_atlas    = { "abrams_leap" },
    hero_drifter  = { "drifter_anim_darkness" },
    hero_necro    = { "necro_gravestone" },
    hero_astro    = { "astro_lasso" },
    hero_lash     = { "lash_ultimate", "lash_death_slam" },
    hero_ghost    = { "ghost_blood_exchange" },
    hero_bookworm = { "bookworm_ultimate" },
    hero_vampirebat = { "vampirebat_batswarm" },
}
local ULT_PARTICLE_WINDOW = 1.2

local function enemy_using_ult(e, hero_name)
    local key = enemy_key(e)
    local u = state.ult_until[key]
    if u and global_vars.curtime() < u then return true end
    local sigs = CURSED_ULT_SIGNS[hero_name]
    if sigs then
        local mods = nil
        pcall(function() mods = e:get_modifiers() end)
        if type(mods) == "table" then
            for _, m in ipairs(mods) do
                local nm = nil
                pcall(function() nm = m:get_name() end)
                if nm then
                    nm = tostring(nm):lower()
                    for _, s in ipairs(sigs) do
                        if nm:find(s, 1, true) then return true end
                    end
                end
            end
        end
    end
    return false
end

local function on_ult_particle(info)
    if type(info) ~= "table" then return end
    local nm = info.name
    if type(nm) ~= "string" then return end
    local ent = info.entity
    if not is_valid_entity(ent) then return end
    local hn = nil
    pcall(function() hn = ent:get_name() end)
    if not hn then return end
    local sigs = PARTICLE_ULT_SIGNS[hn]
    if not sigs then return end
    local lname = nm:lower()
    for _, s in ipairs(sigs) do
        if lname:find(s, 1, true) then
            local k = enemy_key(ent)
            local t = global_vars.curtime()
            state.ult_until[k] = t + ULT_PARTICLE_WINDOW
            state.ult_used_at = state.ult_used_at or {}
            state.ult_used_at[k] = t
            return
        end
    end
end

local function pos_on_screen(pos)
    if not pos then return false end
    local on = false
    pcall(function()
        local sp, onscreen = Render.WorldToScreen(pos)
        on = (onscreen == true) and (sp ~= nil)
    end)
    return on
end

local CURSED_HERO_CFG = {
    hero_dynamo  = { preempt_m = 15, ult_cd = 230 },
    hero_ghost   = { preempt_m = 8, ult_cd = 185 },
    hero_krill   = { preempt_m = 10, ult_cd = 140 },
    hero_synth   = { preempt_m = 15, ult_cd = 150 },
    hero_werewolf = { delay = 2.0 },
    hero_drifter = { try_window = 1.5 },
    hero_necro   = { try_window = 1.5 },
    hero_lash    = { bypass_screen = true },
    hero_bookworm = { max_m = 20 },
    hero_wraith  = { preempt_m = 20, ult_cd = 0 },
}

local function has_unstoppable(e)
    local mods = nil
    pcall(function() mods = e:get_modifiers() end)
    if type(mods) ~= "table" then return false end
    for _, m in ipairs(mods) do
        local nm = nil
        pcall(function() nm = m:get_name() end)
        if nm and tostring(nm):lower():find("unstoppable", 1, true) then return true end
    end
    return false
end

local function has_refresher(e)
    local mods = nil
    pcall(function() mods = e:get_modifiers() end)
    if type(mods) ~= "table" then return false end
    for _, m in ipairs(mods) do
        local nm = nil
        pcall(function() nm = m:get_name() end)
        if nm and tostring(nm):lower():find("ability_refresher", 1, true) then return true end
    end
    return false
end

local CDR_ITEMS = {
    { "transcendent_cooldown", 0.25 },
    { "cooldown_reduction",    0.20 },
}
local function enemy_cdr(e)
    local mods = nil
    pcall(function() mods = e:get_modifiers() end)
    if type(mods) ~= "table" then return 0 end
    local best = 0
    for _, m in ipairs(mods) do
        local nm = nil
        pcall(function() nm = m:get_name() end)
        if nm then
            nm = tostring(nm):lower()
            for _, it in ipairs(CDR_ITEMS) do
                if nm:find(it[1], 1, true) and it[2] > best then best = it[2] end
            end
        end
    end
    return best
end

local function cursed_ult_target(entry, lp, lp_pos, range_m)
    local H = _G.HERO_LIB
    if not H then return nil end
    local u_per_m = (H.UNITS_TO_METERS and H.UNITS_TO_METERS > 0) and (1 / H.UNITS_TO_METERS) or 37.7
    local ok, list = pcall(H.get_heroes_in_radius, lp, lp_pos, range_m * u_per_m, false, true, false)
    if not ok or type(list) ~= "table" then return nil end
    local now = global_vars.curtime()
    state.cursed_seen = state.cursed_seen or {}
    state.cursed_start = state.cursed_start or {}
    state.ult_used_at = state.ult_used_at or {}
    local best, best_pri, best_d = nil, -1, math.huge
    for _, e in ipairs(list) do
        if is_valid_entity(e) and is_alive(e) then
            local nm = nil
            pcall(function() nm = e:get_name() end)
            local enabled = false
            if nm then pcall(function() enabled = entry.heroes:Get(nm) end) end
            if enabled and not has_unstoppable(e) then
                local bad = false
                pcall(function() bad = H.is_invulnerable(e) or H.is_untargetable(e) end)
                if not bad then
                    local key = enemy_key(e)
                    local cfg = CURSED_HERO_CFG[nm]
                    local raw = enemy_using_ult(e, nm)
                    if raw then
                        if not state.cursed_seen[key] then
                            state.cursed_seen[key] = true
                            state.cursed_start[key] = now
                            state.ult_used_at[key] = now
                        end
                    else
                        state.cursed_seen[key] = false
                    end
                    local ulting = raw
                    if ulting and cfg and cfg.delay then
                        if (now - (state.cursed_start[key] or now)) < cfg.delay then
                            ulting = false
                        end
                    end
                    if ulting and cfg and cfg.try_window then
                        if (now - (state.cursed_start[key] or now)) > cfg.try_window then
                            ulting = false
                        end
                    end
                    local preempt = false
                    if not ulting and cfg and cfg.preempt_m then
                        local last = state.ult_used_at[key] or -1e9
                        local eff_cd = (cfg.ult_cd or 200) * (1 - enemy_cdr(e))
                        local ult_ready = (now - last) >= eff_cd or has_refresher(e)
                        if ult_ready then
                            local ep = H.get_target_pos(e) or get_origin(e)
                            if ep and (lp_pos:Distance(ep) / u_per_m) <= cfg.preempt_m and pos_on_screen(ep) then
                                preempt = true
                            end
                        end
                    end
                    if ulting or preempt then
                        local ep = nil
                        pcall(function() ep = H.get_target_pos(e) end)
                        if not ep then ep = get_origin(e) end
                        local screen_ok = (cfg and cfg.bypass_screen) or pos_on_screen(ep)
                        if ep and screen_ok then
                            local d = lp_pos:Distance(ep)
                            local within = (not cfg or not cfg.max_m) or ((d / u_per_m) <= cfg.max_m)
                            local pri = has_refresher(e) and 1 or 0
                            if within and (pri > best_pri or (pri == best_pri and d < best_d)) then
                                best, best_pri, best_d = e, pri, d
                            end
                        end
                    end
                end
            end
        end
    end
    return best
end

local function resolve_item_ability(lp, entry)
    for _, n in ipairs(entry.names or { entry.id }) do
        local ab = nil
        pcall(function() ab = lp:get_ability(n) end)
        if ab then return ab, n end
    end
    return nil, nil
end

local function count_enemies_near(lp, pos, radius_m)
    local H = _G.HERO_LIB
    if not H or not pos then return 0 end
    local u_per_m = (H.UNITS_TO_METERS and H.UNITS_TO_METERS > 0) and (1 / H.UNITS_TO_METERS) or 37.7
    local ok, list = pcall(H.get_heroes_in_radius, lp, pos, radius_m * u_per_m, false, true, false)
    if not ok or type(list) ~= "table" then return 0 end
    local n = 0
    for _, e in ipairs(list) do
        if is_valid_entity(e) and is_alive(e) then
            local bad = false
            pcall(function() bad = H.is_invulnerable(e) or H.is_untargetable(e) end)
            if not bad then n = n + 1 end
        end
    end
    return n
end

local function debuff_target_for(entry, lp, lp_pos, range_m)
    local H = _G.HERO_LIB
    if not H then return nil end
    local u_per_m = (H.UNITS_TO_METERS and H.UNITS_TO_METERS > 0) and (1 / H.UNITS_TO_METERS) or 37.7
    local radius = range_m * u_per_m
    local ok, list = pcall(H.get_heroes_in_radius, lp, lp_pos, radius, false, true, false)
    if not ok or type(list) ~= "table" then return nil end
    local best, best_d = nil, math.huge
    for _, e in ipairs(list) do
        if is_valid_entity(e) and is_alive(e) then
            local nm = nil
            pcall(function() nm = e:get_name() end)
            local enabled = false
            if nm then pcall(function() enabled = entry.heroes:Get(nm) end) end
            if enabled then
                local bad = false
                pcall(function() bad = H.is_invulnerable(e) or H.is_untargetable(e) end)
                if entry.flyer and not bad then
                    if not enemy_in_flight_ability(e, nm) then bad = true end
                    if ui.debug:Get() then
                        local t = state.debuff_dbg_t[nm or "?"] or 0
                        local now = global_vars.curtime()
                        if now - t > 1.0 then
                            state.debuff_dbg_t[nm or "?"] = now
                            debug_print("flyer %s mods: %s", tostring(nm), table.concat(enemy_modifier_names(e), ", "))
                        end
                    end
                end
                if not bad then
                    local ep = get_origin(e)
                    if ep then
                        local d = lp_pos:Distance(ep)
                        local los = false
                        pcall(function() los = H.no_obs_to_target(e) end)
                        if los and d < best_d then
                            best, best_d = e, d
                        end
                    end
                end
            end
        end
    end
    return best
end

local function debuff_target_any(entry, lp, lp_pos, range_m)
    local H = _G.HERO_LIB
    if not H then return nil end
    local u_per_m = (H.UNITS_TO_METERS and H.UNITS_TO_METERS > 0) and (1 / H.UNITS_TO_METERS) or 37.7
    local ok, list = pcall(H.get_heroes_in_radius, lp, lp_pos, range_m * u_per_m, false, true, false)
    if not ok or type(list) ~= "table" then return nil end
    local best, best_d = nil, math.huge
    for _, e in ipairs(list) do
        if is_valid_entity(e) and is_alive(e) then
            local bad = false
            pcall(function() bad = H.is_invulnerable(e) or H.is_untargetable(e) end)
            if not bad then
                local ep = get_origin(e)
                if ep then
                    local d = lp_pos:Distance(ep)
                    local los = false
                    pcall(function() los = H.no_obs_to_target(e) end)
                    if los and d < best_d then best, best_d = e, d end
                end
            end
        end
    end
    return best
end

local function debuff_all_active(entry)
    return entry.all_enable ~= nil and entry.all_enable:Get() == true
end

local function debuff_all_range_m(entry, ab)
    if entry.all_auto_range and entry.all_auto_range:Get() then
        return debuff_range_m(entry, ab)
    end
    return (entry.all_range and entry.all_range:Get()) or debuff_range_m(entry, ab)
end

local function handle_debuff_items(cmd)
    if not ui.enable:Get() then return end
    local H = _G.HERO_LIB
    if not H then return end
    if #debuff_entries == 0 then return end
    local lp = get_local_pawn()
    if not is_valid_entity(lp) then return end
    local lp_pos = get_origin(lp)
    if not lp_pos then return end
    local now = global_vars.curtime()
    for _, entry in ipairs(debuff_entries) do
        if entry.enabled:Get() then
            local mode = get_combo_index(entry.mode, { "Off", "Auto", "Key" }, 1)
            if mode ~= 0 then
                local key_ok = true
                if mode == 2 then
                    key_ok = false
                    pcall(function() key_ok = entry.key:IsDown() end)
                end
                if key_ok then
                    local ab, ab_name = resolve_item_ability(lp, entry)
                    local ready = false
                    if ab then pcall(function() ready = H.is_ability_ready(ab) end) end
                    local last = state.debuff_last[entry.id] or 0
                    if ui.debug:Get() then
                        local t = state.debuff_dbg_t["d" .. entry.id] or 0
                        if now - t > 0.7 then
                            state.debuff_dbg_t["d" .. entry.id] = now
                            if not ab then
                                debug_print("%s: item NOT equipped (tried: %s)", entry.label, table.concat(entry.names or { entry.id }, ", "))
                            elseif not ready then
                                local cd = -1; pcall(function() cd = ab:get_cooldown() end)
                                debug_print("%s: not ready (cd=%.1f)", entry.label, cd)
                            else
                                local tg
                                if debuff_all_active(entry) then
                                    local rng = debuff_all_range_m(entry, ab)
                                    tg = debuff_target_any(entry, lp, lp_pos, rng)
                                    if not tg then
                                        debug_print("%s [All]: ready, NO enemy within %dm (+LOS)", entry.label, rng)
                                    end
                                elseif entry.ult then
                                    local rng = debuff_range_m(entry, ab)
                                    tg = cursed_ult_target(entry, lp, lp_pos, rng)
                                    if not tg then
                                        debug_print("%s: ready, waiting for a marked hero to use their ult (on screen, within %dm)", entry.label, rng)
                                    end
                                else
                                    local rng = debuff_range_m(entry, ab)
                                    tg = debuff_target_for(entry, lp, lp_pos, rng)
                                    if not tg then
                                        debug_print("%s: ready, NO valid target within %dm (marked hero? in range+LOS?)", entry.label, rng)
                                    end
                                end
                            end
                        end
                    end
                    if ab and ready and (now - last) > 0.40 then
                        local range_m = debuff_range_m(entry, ab)
                        local target
                        if debuff_all_active(entry) then
                            target = debuff_target_any(entry, lp, lp_pos, debuff_all_range_m(entry, ab))
                        elseif entry.ult then
                            target = cursed_ult_target(entry, lp, lp_pos, range_m)
                        else
                            target = debuff_target_for(entry, lp, lp_pos, range_m)
                        end
                        if target then
                            local aim = nil
                            pcall(function() aim = H.get_target_pos(target) end)
                            if not aim then aim = get_origin(target) end
                            local cluster_ok = true
                            if entry.min_enemies and aim then
                                local need = entry.min_enemies:Get()
                                local have = count_enemies_near(lp, aim, entry.aoe_radius or 12)
                                cluster_ok = have >= need
                                if not cluster_ok and ui.debug:Get() then
                                    local t = state.debuff_dbg_t["c" .. entry.id] or 0
                                    if now - t > 0.7 then
                                        state.debuff_dbg_t["c" .. entry.id] = now
                                        debug_print("%s: %d/%d enemies within %dm radius -- waiting for cluster",
                                            entry.label, have, need, entry.aoe_radius or 12)
                                    end
                                end
                            end
                            if aim and cluster_ok then
                                if entry.aoe then
                                    pcall(function() H.cast_ability(cmd, lp, ab) end)
                                    state.debuff_last[entry.id] = now
                                    debug_print("Debuff %s [%s] -> AoE 360 (sem psilent)", entry.label, tostring(ab_name))
                                elseif entry.ult then
                                    local can = false
                                    pcall(function() can = cmd:can_psilent_at_pos(aim) end)
                                    if not can then
                                        apply_view_to_pos(cmd, lp_pos, aim, 1.0)
                                    end
                                    pcall(function() cmd:set_psilent_at_pos(aim) end)
                                    pcall(function() H.cast_ability(cmd, lp, ab) end)
                                    state.debuff_last[entry.id] = now
                                    debug_print("Cursed %s -> %s (instant, snap=%s)", entry.label,
                                        tostring(target:get_name()), tostring(not can))
                                else
                                    local can = false
                                    pcall(function() can = cmd:can_psilent_at_pos(aim) end)
                                    if ui.debug:Get() then
                                        local t = state.debuff_dbg_t[entry.id] or 0
                                        if now - t > 0.5 then
                                            state.debuff_dbg_t[entry.id] = now
                                            local cm = nil
                                            pcall(function() cm = H.get_ability_cast_mode(ab) end)
                                            debug_print("%s: target=%s can_psilent=%s cast_mode=%s (1=INSTANT)",
                                                entry.label, tostring(target:get_name()), tostring(can), tostring(cm))
                                        end
                                    end
                                    if can then
                                        pcall(function() cmd:set_psilent_at_pos(aim) end)
                                        pcall(function() H.cast_ability(cmd, lp, ab) end)
                                        state.debuff_last[entry.id] = now
                                        debug_print("Debuff %s [%s] -> %s (psilent)", entry.label, tostring(ab_name), tostring(target:get_name()))
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end

local function handle_item_autotoggle()
    local now = global_vars.curtime()
    if now - state.item_auto_t < 0.5 then return end
    state.item_auto_t = now

    local held = {}
    local lp = get_local_pawn()
    if is_valid_entity(lp) then
        local abs = nil
        pcall(function() abs = lp:get_abilities() end)
        if type(abs) == "table" then
            for _, a in ipairs(abs) do
                local an = nil
                pcall(function() an = tostring(a:get_name()) end)
                if an and an:find("^upgrade_") then held[an] = true end
            end
        end
    end

    for _, entry in ipairs(items_list) do
        local owned = false
        if entry.id and held[entry.id] then owned = true end
        if not owned and entry.names then
            for _, n in ipairs(entry.names) do
                if held[n] then owned = true break end
            end
        end
        local prev = state.item_owned[entry]
        if prev ~= owned then
            pcall(function() entry.enabled:Set(owned) end)
            debug_print("Item %s -> %s", entry.label, owned and "ON (comprado)" or "OFF (sem o item)")
        end
        state.item_owned[entry] = owned
    end
end

local function handle_item_autodetect()
    if not ui_item_autodetect or not ui_item_autodetect:Get() then
        state.eth_autodetect_applied = nil
        return
    end
    local now = global_vars.curtime()
    if now - (state.item_autodetect_t or 0) < 1.0 then return end
    state.item_autodetect_t = now

    local present = {}
    local lp = get_local_pawn()
    local myteam = nil
    if is_valid_entity(lp) then pcall(function() myteam = lp.m_iTeamNum end) end
    local ok, players = pcall(function() return entity_list.by_class_name("C_CitadelPlayerPawn") end)
    if ok and type(players) == "table" then
        for _, p in ipairs(players) do
            if is_valid_entity(p) and p ~= lp then
                local t = nil; pcall(function() t = p.m_iTeamNum end)
                if t ~= myteam then
                    local nm = nil; pcall(function() nm = p:get_name() end)
                    if nm then present[tostring(nm)] = true end
                end
            end
        end
    end

    for _, entry in ipairs(debuff_entries) do
        local sw = entry.heroes and entry.heroes.switches
        if type(sw) == "table" then
            for hid, swobj in pairs(sw) do
                if swobj then
                    local want = present[hid] == true
                    local cur = nil; pcall(function() cur = swobj:Get() end)
                    if cur ~= want then pcall(function() swobj:Set(want) end) end
                end
            end
        end
    end

    if ethereal_entry and type(ethereal_entry.es_c5_heroes) == "table" and not state.eth_autodetect_applied then
        local any = false
        for _ in pairs(present) do any = true; break end
        if any then
            for key, swobj in pairs(ethereal_entry.es_c5_heroes) do
                local internal = ETH.internal and ETH.internal[key]
                if swobj and internal then
                    pcall(function() swobj:Set(present[internal] == true) end)
                end
            end
            state.eth_autodetect_applied = true
        end
    end
end

local ECHO_SLOT_OPTS = { "Auto", "Ability 1", "Ability 2", "Ability 3", "Ability 4 (Ult)" }
local ECHO_ITEM = "upgrade_ability_power_shard"

local function get_echo_item(lp)
    for s = 0, 31 do
        local ab = nil; pcall(function() ab = lp:get_ability_by_slot(s) end)
        if ab then
            local nm = nil; pcall(function() nm = ab:get_name() end)
            if nm and tostring(nm):find(ECHO_ITEM, 1, true) then return ab end
        end
    end
    local ab = nil; pcall(function() ab = lp:get_ability(ECHO_ITEM) end)
    return ab
end

local function handle_echo_shard(cmd)
    if not ui.enable:Get() then return end
    local entry = echo_shard_entry
    if not entry or not entry.enabled:Get() then return end
    if not (entry.echo_auto and entry.echo_auto:Get()) then return end
    local H = _G.HERO_LIB
    if not H then return end
    local lp = get_local_pawn()
    if not is_valid_entity(lp) or not is_alive(lp) then
        state.echo_prevcd = nil
        return
    end
    local now = global_vars.curtime()

    local hn = nil; pcall(function() hn = lp:get_name() end)
    if hn ~= state.echo_hero then
        state.echo_hero = hn
        state.echo_prevcd = nil; state.echo_learned = nil; state.echo_pending = nil
    end

    local echo = get_echo_item(lp)
    if not echo then state.echo_prevcd = nil; return end
    local echo_cd = -1; pcall(function() echo_cd = echo:get_cooldown() end)
    local echo_ready = (echo_cd ~= nil and echo_cd <= 0.1)

    local mode = 0
    if entry.echo_slot then mode = get_combo_index(entry.echo_slot, ECHO_SLOT_OPTS, 0) end
    local manual_slot = (mode >= 1) and (mode - 1) or nil

    local cd = {}
    for s = 0, 3 do
        local c = -1
        pcall(function()
            local a = lp:get_ability_by_slot(s)
            if a then c = a:get_cooldown() end
        end)
        cd[s] = c or -1
    end
    local prev = state.echo_prevcd

    if state.echo_pending then
        local pend = state.echo_pending
        if echo_cd and echo_cd > 0.4 then
            local found = nil
            for s = 0, 3 do
                local pc = pend.precd[s]
                if pc and pc > 1.0 and cd[s] and cd[s] < 0.6 then found = s; break end
            end
            found = found or pend.slot
            state.echo_learned = found
            if ui.debug:Get() then debug_print("Echo Shard: imbued ability LEARNED = slot %d (Echo was consumed)", found) end
            state.echo_pending = nil
        elseif now - pend.t > 0.5 then
            if ui.debug:Get() then debug_print("Echo Shard: slot %d is not the imbued one (Echo not consumed)", pend.slot) end
            state.echo_pending = nil
        end
    end

    local function cast_on(s)
        local p, c = prev and prev[s], cd[s]
        return p ~= nil and p <= 0.15 and c and c > 0.4
    end

    local target = manual_slot or state.echo_learned
    local debounce = (now - (state.echo_last or 0)) > 0.4

    if prev and echo_ready and debounce and not state.echo_pending then
        if target ~= nil then
            if cd[target] and cd[target] > 0.5 then
                pcall(function() H.cast_ability(cmd, lp, echo) end)
                state.echo_last = now
                debug_print("Echo Shard -> recarga (slot %d, cd %.1fs)", target, cd[target])
            end
        elseif not manual_slot then
            for s = 0, 3 do
                if cast_on(s) then
                    pcall(function() H.cast_ability(cmd, lp, echo) end)
                    state.echo_last = now
                    state.echo_pending = { slot = s, t = now, precd = { [0] = cd[0], [1] = cd[1], [2] = cd[2], [3] = cd[3] } }
                    if ui.debug:Get() then debug_print("Echo Shard: testando slot %d...", s) end
                    break
                end
            end
        end
    end

    state.echo_prevcd = cd
end

local CC_SELF_SIGNS = {
    "stun", "silence", "root", "rooted", "snare", "ensnare", "immobilize",
    "sleep", "disarm", "tether", "leash", "lasso", "grab", "lift", "trapped",
    "frozen", "freeze", "slow", "hex",
}

local function ethereal_self_cc(lp)
    local mods = nil; pcall(function() mods = lp:get_modifiers() end)
    if type(mods) ~= "table" then return nil end
    for _, m in ipairs(mods) do
        local nm = nil; pcall(function() nm = m:get_name() end)
        if nm then
            nm = tostring(nm):lower()
            for _, s in ipairs(CC_SELF_SIGNS) do
                if nm:find(s, 1, true) then return nm end
            end
        end
    end
    return nil
end

local function ethereal_enemy_ult(lp, lp_pos, range_m)
    local H = _G.HERO_LIB
    if not H or not lp_pos then return nil end
    local u_per_m = (H.UNITS_TO_METERS and H.UNITS_TO_METERS > 0) and (1 / H.UNITS_TO_METERS) or 37.7
    local ok, list = pcall(H.get_heroes_in_radius, lp, lp_pos, range_m * u_per_m, false, true, false)
    if not ok or type(list) ~= "table" then return nil end
    for _, e in ipairs(list) do
        if is_valid_entity(e) and is_alive(e) then
            local hn = nil; pcall(function() hn = e:get_name() end)
            if hn and enemy_using_ult(e, hn) then return hn end
        end
    end
    return nil
end

local function eth_build_lookups()
    local db = _G.PARRY_DB
    if type(db) ~= "table" then return nil end
    local lk = { self_pat = {}, ult = { self_mods = {}, enemy_mods = {}, particles = {}, self_particles = {} } }
    local function add_self(modes)
        if type(modes) ~= "table" then return end
        for _, mc in pairs(modes) do
            if type(mc) == "table" and mc.type == "modifier" and mc.self_only then
                local pat = mc.pattern or mc.id
                if pat then lk.self_pat[#lk.self_pat + 1] = tostring(pat):lower() end
            end
        end
    end
    for _, hd in pairs(db) do if type(hd) == "table" then add_self(hd.modes) end end
    local idb = _G.ITEMS_DB
    if type(idb) == "table" and type(idb.modes) == "table" then add_self(idb.modes) end
    local HL = _G.HERO_LIB
    local u_per_m = (HL and HL.UNITS_TO_METERS and HL.UNITS_TO_METERS > 0) and (1 / HL.UNITS_TO_METERS) or 37.7
    for hk, modelist in pairs(ETH.modes) do
        local hd = db[hk]
        if hd and type(hd.modes) == "table" then
            local range_m = ETH.range[hk] or ETH.range_default
            local range_u = range_m * u_per_m * ETH.range_margin
            local range_sqr = range_u * range_u
            for _, mk in ipairs(modelist) do
                local mc = hd.modes[mk]
                if type(mc) == "table" then
                    local delay = tonumber(mc.delay) or 0
                    if mc.type == "modifier" and (mc.pattern or mc.id) then
                        local pat = tostring(mc.pattern or mc.id):lower()
                        if mc.self_only then
                            lk.ult.self_mods[#lk.ult.self_mods + 1] = { pat = pat, delay = delay, hero = hk }
                        else
                            lk.ult.enemy_mods[#lk.ult.enemy_mods + 1] = { pat = pat, delay = delay, hero = hk, range_sqr = range_sqr }
                        end
                    elseif mc.type == "particle" and mc.id then
                        local id = tostring(mc.id):lower()
                        local p = { delay = delay, hero = hk, range_sqr = range_sqr }
                        lk.ult.particles[id] = p
                        local short = id:match("([^/]+)$"); if short then lk.ult.particles[short] = p end
                    end
                end
            end
        end
    end
    for hk, entries in pairs(ETH.extra) do
        local range_m = ETH.range[hk] or ETH.range_default
        local range_u = range_m * u_per_m * ETH.range_margin
        local range_sqr = range_u * range_u
        for _, ex in ipairs(entries) do
            local delay = tonumber(ex.delay) or 0
            if ex.type == "modifier" and ex.pat then
                local pat = tostring(ex.pat):lower()
                local entry = { pat = pat, delay = delay, hero = hk,
                    use_mod_duration = ex.use_mod_duration, fallback_delay = ex.fallback_delay,
                    lead = ex.lead, min_duration = ex.min_duration }
                if ex.self_only then
                    lk.ult.self_mods[#lk.ult.self_mods + 1] = entry
                else
                    entry.range_sqr = range_sqr
                    lk.ult.enemy_mods[#lk.ult.enemy_mods + 1] = entry
                end
            elseif ex.type == "particle" and ex.id then
                local id = tostring(ex.id):lower()
                local p = { delay = delay, hero = hk, range_sqr = range_sqr }
                local tbl = ex.self_only and lk.ult.self_particles or lk.ult.particles
                tbl[id] = p
                local short = id:match("([^/]+)$"); if short then tbl[short] = p end
            end
        end
    end
    return lk
end

local function on_eth_particle(info)
    local lk = state.eth_lk
    if not lk or not lk.ult then return end
    local nm = info and info.name
    if type(nm) ~= "string" then return end
    local ln = nm:lower()
    local short = ln:match("([^/]+)$")
    local ent = info.entity
    if not is_valid_entity(ent) then return end
    local lp = get_local_pawn()
    if not is_valid_entity(lp) then return end
    local sp = lk.ult.self_particles[ln]
    if sp == nil and short then sp = lk.ult.self_particles[short] end
    if sp ~= nil and ent == lp then
        state.eth_self_part_fire = state.eth_self_part_fire or {}
        state.eth_self_part_fire[sp.hero or "?"] = { at = global_vars.curtime() + (sp.delay or 0) }
    end
    local p = lk.ult.particles[ln]
    if p == nil and short then p = lk.ult.particles[short] end
    if p == nil then return end
    local et, lt; pcall(function() et = ent.m_iTeamNum end); pcall(function() lt = lp.m_iTeamNum end)
    if et ~= nil and lt ~= nil and et == lt then return end
    state.eth_part_fire = state.eth_part_fire or {}
    state.eth_part_fire[enemy_key(ent)] = { at = global_vars.curtime() + (p.delay or 0), hero = p.hero, range_sqr = p.range_sqr }
end

local function on_doorman_particle(info)
    local nm = info and info.name
    if type(nm) ~= "string" then return end
    local ln = nm:lower()
    if not (ln:find("doorman_hotel_channel_start", 1, true) or ln:find("doorman_hotel_cast", 1, true)) then return end
    local ent = info.entity
    if not is_valid_entity(ent) then return end
    local lp = get_local_pawn()
    if not is_valid_entity(lp) then return end
    local et, lt; pcall(function() et = ent.m_iTeamNum end); pcall(function() lt = lp.m_iTeamNum end)
    if et ~= nil and lt ~= nil and et == lt then return end
    state.eth_doorman_cast = { at = global_vars.curtime(), pos = get_origin(ent) }
end

local function on_eth_add_entity(ent)
    if not is_valid_entity(ent) then return end
    local cn = nil; pcall(function() cn = ent:get_class_name() end)
    if type(cn) ~= "string" then return end
    local kind
    if cn:find("SelfVacuum", 1, true) then kind = "vacuum"
    elseif cn:find("Fencer_Ultimate", 1, true) then kind = "fencer"
    else return end
    state.eth_abils = state.eth_abils or {}
    local kept = {}
    for _, rec in ipairs(state.eth_abils) do
        if is_valid_entity(rec.ab) then
            if rec.ab == ent then return end
            kept[#kept + 1] = rec
        end
    end
    if #kept < 32 then kept[#kept + 1] = { ab = ent, kind = kind } end
    state.eth_abils = kept
end

local function eth_dist_sqr(a, b)
    if not a or not b then return math.huge end
    local dx = (a.x or 0) - (b.x or 0)
    local dy = (a.y or 0) - (b.y or 0)
    local dz = (a.z or 0) - (b.z or 0)
    return dx * dx + dy * dy + dz * dz
end

ETH.dash_min_speed_u = 500
local function eth_in_dash_corridor(en, en_pos, lp_pos, range_m, width_m)
    if not en_pos or not lp_pos then return false end
    local H = _G.HERO_LIB
    local u_per_m = (H and H.UNITS_TO_METERS and H.UNITS_TO_METERS > 0) and (1 / H.UNITS_TO_METERS) or 37.7
    local v = nil; pcall(function() v = en.m_vecVelocity end)
    if not v then pcall(function() v = en.m_vecAbsVelocity end) end
    if not v then return false end
    local vx, vy = v.x or 0, v.y or 0
    local sp = math.sqrt(vx * vx + vy * vy)
    if sp < ETH.dash_min_speed_u then return false end
    local fx, fy = vx / sp, vy / sp
    local dx = (lp_pos.x or 0) - (en_pos.x or 0)
    local dy = (lp_pos.y or 0) - (en_pos.y or 0)
    local range_u = range_m * u_per_m
    local width_u = width_m * u_per_m
    local fwd_dist = dx * fx + dy * fy
    if fwd_dist < -width_u or fwd_dist > range_u then return false end
    local px = dx - fx * fwd_dist
    local py = dy - fy * fwd_dist
    return (px * px + py * py) <= (width_u * width_u)
end

local function eth_los(en, lp_pos, en_pos)
    local vis = nil; pcall(function() vis = en:is_visible() end)
    if vis == false then return false end
    if not lp_pos or not en_pos then return false end
    if trace and trace.line then
        local clear = true
        pcall(function()
            local tr = trace.line(Vector(lp_pos.x, lp_pos.y, lp_pos.z + 55),
                                  Vector(en_pos.x, en_pos.y, en_pos.z + 55))
            if tr then
                local frac = tr.fraction or tr.frac or 1
                if frac < 0.9 then
                    local hit = tr.hit_entity or tr.entity
                    clear = (hit == en)
                end
            end
        end)
        return clear
    end
    return true
end

local ETH_RANGE_ITEMS = {
    { "upgrade_tech_range", 0.35 },
    { "upgrade_magic_reach", 0.20 },
}
local function eth_enemy_range_mult(mods)
    if type(mods) ~= "table" then return 1 end
    local bonus = 0
    for _, m in ipairs(mods) do
        local mn = nil; pcall(function() mn = m:get_name() end)
        if mn then
            mn = tostring(mn):lower()
            for _, it in ipairs(ETH_RANGE_ITEMS) do
                if mn:find(it[1], 1, true) then bonus = bonus + it[2] end
            end
        end
    end
    return 1 + bonus
end

local function eth_ult_check(lp, lp_pos, entry)
    local lk = state.eth_lk
    local H = _G.HERO_LIB
    if not lk or not lk.ult then return nil end
    local now = global_vars.curtime()
    local heroes = entry and entry.es_c5_heroes
    local eye_tbl = entry and entry.es_c5_eye
    local function eye_blocks(hk, en_pos)
        if not eye_tbl then return false end
        local sw = eye_tbl[hk]
        if not sw then return false end
        local on = false; pcall(function() on = (sw:Get() == true) end)
        if not on then return false end
        return not pos_on_screen(en_pos)
    end
    local function hero_on(hk)
        if not heroes then return true end
        local sw = heroes[hk]
        if not sw then return true end
        local v = true; pcall(function() v = sw:Get() end)
        return v == true
    end
    state.eth_mod_seen = state.eth_mod_seen or {}
    local matched = {}
    local function scan(mods, list, tagprefix, dist2, rmult)
        if type(mods) ~= "table" then return nil end
        rmult = rmult or 1
        for _, m in ipairs(mods) do
            local mn = nil; pcall(function() mn = m:get_name() end)
            if mn then
                mn = tostring(mn):lower()
                for _, e in ipairs(list) do
                    if hero_on(e.hero) and mn:find(e.pat, 1, true)
                       and (dist2 == nil or not e.range_sqr or dist2 <= e.range_sqr * rmult * rmult) then
                        local key = tagprefix .. e.pat
                        matched[key] = true
                        local rec = state.eth_mod_seen[key]
                        if not rec then
                            local d = e.delay or 0
                            if e.use_mod_duration then
                                local ok, dur = pcall(function() return m:get_duration() end)
                                if ok and type(dur) == "number" and dur >= (e.min_duration or 0.4) then
                                    d = math.max(0, dur - (e.lead or 0.2))
                                else
                                    d = e.fallback_delay or d
                                end
                            end
                            rec = { fire = now + d }
                            state.eth_mod_seen[key] = rec
                        end
                        if now >= rec.fire then return e.hero or e.pat end
                    end
                end
            end
        end
        return nil
    end
    local mymods = nil; pcall(function() mymods = lp:get_modifiers() end)
    local r = scan(mymods, lk.ult.self_mods, "self:", nil)
    if r then return "ult on you (" .. tostring(r) .. ")" end
    if state.eth_self_part_fire then
        for hk, fa in pairs(state.eth_self_part_fire) do
            if type(fa) == "table" and fa.at then
                if now > fa.at + 2.0 then
                    state.eth_self_part_fire[hk] = nil
                elseif now >= fa.at and hero_on(hk) then
                    return "ult on you particle (" .. tostring(hk) .. ")"
                end
            end
        end
    end
    if lp_pos and H then
        local ok, list = pcall(H.get_heroes_in_radius, lp, lp_pos, 4000, false, true, false)
        if ok and type(list) == "table" then
            local pf = state.eth_part_fire or {}
            for _, en in ipairs(list) do
                if is_valid_entity(en) and is_alive(en) and eth_los(en, lp_pos, get_origin(en)) then
                    local k = enemy_key(en)
                    local en_pos = get_origin(en)
                    local dist2 = eth_dist_sqr(lp_pos, en_pos)
                    local emods = nil; pcall(function() emods = en:get_modifiers() end)
                    local rmult = eth_enemy_range_mult(emods)
                    local fa = pf[k]
                    if fa and fa.at and now >= fa.at and now <= fa.at + 1.0 and hero_on(fa.hero) then
                        local dir = ETH.dir[fa.hero]
                        local hit
                        if dir then
                            hit = eth_in_dash_corridor(en, en_pos, lp_pos,
                                dir.range * ETH.range_margin * rmult, dir.width * ETH.range_margin)
                        else
                            hit = (not fa.range_sqr) or (dist2 <= fa.range_sqr * rmult * rmult)
                        end
                        if hit and eye_blocks(fa.hero, en_pos) then hit = false end
                        if hit and fa.hero == "apollo" and state.eth_apollo_readable then hit = false end
                        if hit then return "ult particle (" .. tostring(fa.hero) .. ")" end
                    end
                    local rr = scan(emods, lk.ult.enemy_mods, "enemy:" .. tostring(k) .. ":", dist2, rmult)
                    if rr and not eye_blocks(rr, en_pos) then return "enemy ult (" .. tostring(rr) .. ")" end
                end
            end
        end
    end
    for key in pairs(state.eth_mod_seen) do if not matched[key] then state.eth_mod_seen[key] = nil end end
    if state.eth_part_fire then
        for k, fa in pairs(state.eth_part_fire) do
            if type(fa) ~= "table" or not fa.at or now > fa.at + 2.0 then state.eth_part_fire[k] = nil end
        end
    end
    return nil
end

local function eth_db_self_cc(lp)
    local lk = state.eth_lk
    if not lk then return nil end
    local mods = nil; pcall(function() mods = lp:get_modifiers() end)
    if type(mods) ~= "table" then return nil end
    for _, m in ipairs(mods) do
        local mn = nil; pcall(function() mn = m:get_name() end)
        if mn then
            mn = tostring(mn):lower()
            for _, p in ipairs(lk.self_pat) do if mn:find(p, 1, true) then return mn end end
        end
    end
    return nil
end

local function eth_dynamo_check(lp, lp_pos, entry)
    local heroes = entry and entry.es_c5_heroes
    if heroes and heroes.dynamo then
        local on = true; pcall(function() on = heroes.dynamo:Get() end)
        if on ~= true then return nil end
    end
    local abils = state.eth_abils
    if not abils or #abils == 0 or not lp_pos then return nil end
    local lt = nil; pcall(function() lt = lp.m_iTeamNum end)
    local casting = false
    for _, rec in ipairs(abils) do
        if rec.kind == "vacuum" and is_valid_entity(rec.ab) then
            local cd = nil; pcall(function() cd = rec.ab.m_bInCastDelay end)
            if cd == true then
                local tn = nil; pcall(function() tn = rec.ab.m_iTeamNum end)
                if tn ~= nil and lt ~= nil and tn ~= lt then casting = true; break end
            end
        end
    end
    if not casting then return nil end
    local H = _G.HERO_LIB
    if not H then return nil end
    local ok, list = pcall(H.get_heroes_in_radius, lp, lp_pos, 4000, false, true, false)
    if not ok or type(list) ~= "table" then return nil end
    local u_per_m = (H.UNITS_TO_METERS and H.UNITS_TO_METERS > 0) and (1 / H.UNITS_TO_METERS) or 37.7
    for _, en in ipairs(list) do
        if is_valid_entity(en) and is_alive(en) then
            local nm = nil; pcall(function() nm = en:get_name() end)
            if type(nm) == "string" and nm:find("hero_dynamo", 1, true) then
                local emods = nil; pcall(function() emods = en:get_modifiers() end)
                local rng = (ETH.range.dynamo or 9) * u_per_m * ETH.range_margin * eth_enemy_range_mult(emods)
                if eth_dist_sqr(lp_pos, get_origin(en)) <= rng * rng then
                    return "dynamo singularity (windup)"
                end
            end
        end
    end
    return nil
end

local function eth_apollo_check(lp, lp_pos, entry)
    state.eth_apollo_readable = false
    local heroes = entry and entry.es_c5_heroes
    if heroes and heroes.apollo then
        local on = true; pcall(function() on = heroes.apollo:Get() end)
        if on ~= true then return nil end
    end
    local abils = state.eth_abils
    if not abils or #abils == 0 or not lp_pos then return nil end
    local lt = nil; pcall(function() lt = lp.m_iTeamNum end)
    local dir
    for _, rec in ipairs(abils) do
        if rec.kind == "fencer" and is_valid_entity(rec.ab) then
            local st = nil; pcall(function() st = rec.ab.m_eUltState end)
            if type(st) == "number" and st >= 1 then
                local tn = nil; pcall(function() tn = rec.ab.m_iTeamNum end)
                if tn ~= nil and lt ~= nil and tn ~= lt then
                    state.eth_apollo_readable = true
                    if st == 1 or st == 2 then
                        local d = nil; pcall(function() d = rec.ab.m_vDashDirection end)
                        if d then dir = d; break end
                    end
                end
            end
        end
    end
    if not dir then return nil end
    local dx, dy = dir.x or 0, dir.y or 0
    local dlen = math.sqrt(dx * dx + dy * dy)
    if dlen < 0.1 then return nil end
    local fx, fy = dx / dlen, dy / dlen
    local H = _G.HERO_LIB
    if not H then return nil end
    local ok, list = pcall(H.get_heroes_in_radius, lp, lp_pos, 4000, false, true, false)
    if not ok or type(list) ~= "table" then return nil end
    local u_per_m = (H.UNITS_TO_METERS and H.UNITS_TO_METERS > 0) and (1 / H.UNITS_TO_METERS) or 37.7
    local range_u = (ETH.range.apollo or 27) * u_per_m * ETH.range_margin
    local width_u = 7 * u_per_m * ETH.range_margin * 1.3
    for _, en in ipairs(list) do
        if is_valid_entity(en) and is_alive(en) then
            local nm = nil; pcall(function() nm = en:get_name() end)
            if type(nm) == "string" and nm:find("hero_fencer", 1, true) then
                local ep = get_origin(en)
                if ep then
                    local rx, ry = (lp_pos.x or 0) - (ep.x or 0), (lp_pos.y or 0) - (ep.y or 0)
                    local fwd = rx * fx + ry * fy
                    local side = math.abs(rx * (-fy) + ry * fx)
                    if fwd >= -width_u and fwd <= range_u and side <= width_u then
                        return "apollo dash (direction)"
                    end
                end
            end
        end
    end
    return nil
end

local function eth_doorman_check(lp, lp_pos, entry)
    local heroes = entry and entry.es_c5_heroes
    if heroes and heroes.doorman then
        local on = true; pcall(function() on = heroes.doorman:Get() end)
        if on ~= true then return nil end
    end
    local now = global_vars.curtime()
    local mode = 0
    if entry and entry.es_c5_doorman_mode then
        mode = get_combo_index(entry.es_c5_doorman_mode, { "Avoid (early)", "Escape at end" }, 0)
    end
    if mode == 1 then
        local mods = nil; pcall(function() mods = lp:get_modifiers() end)
        if type(mods) ~= "table" then state.eth_doorman_seen = nil; return nil end
        local hm = nil
        for _, m in ipairs(mods) do
            local mn = nil; pcall(function() mn = m:get_name() end)
            if mn then
                local ln = mn:lower()
                if ln:find("ability_doorman_hotel/hotel", 1, true) or ln:find("doorman_hotel", 1, true)
                   or ln:find("hotel_guest", 1, true) then hm = m; break end
            end
        end
        if not hm then state.eth_doorman_seen = nil; return nil end
        local rec = state.eth_doorman_seen
        if not rec then
            local dur = nil; pcall(function() dur = hm:get_duration() end)
            if type(dur) ~= "number" or dur < 4.0 then dur = 6.5 end
            rec = { fire = now + math.max(0, dur - 0.10) }
            state.eth_doorman_seen = rec
        end
        if now >= rec.fire then return "doorman hotel (escape at end)" end
        return nil
    end
    local H = _G.HERO_LIB
    if not (lp_pos and H) then return nil end
    local u_per_m = (H.UNITS_TO_METERS and H.UNITS_TO_METERS > 0) and (1 / H.UNITS_TO_METERS) or 37.7
    local base_u = (ETH.range.doorman or 7) * u_per_m * ETH.range_margin
    local dc = state.eth_doorman_cast
    if dc and dc.at and (now - dc.at) <= 1.2 and dc.pos then
        if eth_dist_sqr(lp_pos, dc.pos) <= (base_u * 1.3) * (base_u * 1.3) then
            if ui.debug:Get() then debug_print("Doorman avoid: channel particle") end
            return "doorman channel (avoid)"
        end
    end
    local ok, list = pcall(H.get_heroes_in_radius, lp, lp_pos, 4000, false, true, false)
    if ok and type(list) == "table" then
        for _, en in ipairs(list) do
            if is_valid_entity(en) and is_alive(en) then
                local en_pos = get_origin(en)
                if eth_los(en, lp_pos, en_pos) then
                    local emods = nil; pcall(function() emods = en:get_modifiers() end)
                    if type(emods) == "table" then
                        local rng = base_u * eth_enemy_range_mult(emods)
                        if eth_dist_sqr(lp_pos, en_pos) <= rng * rng then
                            for _, m in ipairs(emods) do
                                local mn = nil; pcall(function() mn = m:get_name() end)
                                if mn and mn:lower():find("ability_doorman_hotel/track_enemy", 1, true) then
                                    if ui.debug:Get() then debug_print("Doorman avoid: modifier track_enemy") end
                                    return "doorman channeling (avoid)"
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    return nil
end

local function handle_ethereal(cmd)
    if not ui.enable:Get() then return end
    local entry = ethereal_entry
    if not entry or not entry.enabled:Get() then return end
    local H = _G.HERO_LIB
    if not H then return end
    local lp = get_local_pawn()
    if not is_valid_entity(lp) or not is_alive(lp) then
        state.es_prev_hp = nil
        state.es_dmg_log = nil
        return
    end
    local now = global_vars.curtime()

    if state.eth_lk == nil and type(_G.PARRY_DB) == "table" then
        state.eth_lk = eth_build_lookups()
        if state.eth_lk and ui.debug:Get() then
            debug_print("Ethereal: DB Counterspell (%d CC self, %d ult-self, %d ult-enemy mods)",
                #state.eth_lk.self_pat, #state.eth_lk.ult.self_mods, #state.eth_lk.ult.enemy_mods)
        end
    end

    state.es_dmg_log = state.es_dmg_log or {}
    local hp = nil; pcall(function() hp = H.get_health(lp) end)
    if hp then
        local prev = state.es_prev_hp
        if prev and hp < prev then
            state.es_dmg_log[#state.es_dmg_log + 1] = { t = now, d = prev - hp }
        end
        state.es_prev_hp = hp
    end
    local cutoff = now - 10.0
    local kept = {}
    for _, e in ipairs(state.es_dmg_log) do if e.t >= cutoff then kept[#kept + 1] = e end end
    state.es_dmg_log = kept

    local ab = nil; pcall(function() ab = lp:get_ability("upgrade_self_bubble") end)
    if not ab then return end
    local ready = false; pcall(function() ready = H.is_ability_ready(ab) end)
    if not ready then return end
    if now - (state.es_last or 0) < 0.5 then return end

    local checks = {}
    local lp_pos = get_origin(lp)
    if entry.es_c4 and entry.es_c4:Get() then
        local win = entry.es_c4_window:Get()
        local thr = entry.es_c4_dmg:Get()
        local since = now - win
        local sum = 0
        for _, e in ipairs(state.es_dmg_log) do if e.t >= since then sum = sum + e.d end end
        checks[#checks + 1] = { met = sum >= thr, why = string.format("dano %d>=%d em %ds", math.floor(sum), thr, win) }
    end
    if entry.es_c5 and entry.es_c5:Get() then
        local threat = eth_apollo_check(lp, lp_pos, entry)
        if not threat then
            if state.eth_lk and state.eth_lk.ult then threat = eth_ult_check(lp, lp_pos, entry)
            else threat = ethereal_enemy_ult(lp, lp_pos, 30) end
        end
        if not threat then threat = eth_doorman_check(lp, lp_pos, entry) end
        if not threat then threat = eth_dynamo_check(lp, lp_pos, entry) end
        checks[#checks + 1] = { met = threat ~= nil, why = tostring(threat) }
    end

    if #checks == 0 then return end

    local fire, reason = false, nil
    for _, c in ipairs(checks) do
        if c.met then fire = true; reason = c.why; break end
    end

    if fire then
        pcall(function() H.cast_ability(cmd, lp, ab) end)
        state.es_last = now
        debug_print("Ethereal Shift -> activated (%s)", reason)
    end
end

register_callback(callback.on_particle_create, "on_particle_create", "psyability", function(info)
    on_ult_particle(info)
    on_eth_particle(info)
    on_doorman_particle(info)
end)

register_callback(callback.on_add_entity, "on_add_entity", "psyability", function(ent)
    on_eth_add_entity(ent)
end)
register_callback(callback.on_late_add_entity, "on_late_add_entity", "psyability", function(ent)
    on_eth_add_entity(ent)
end)

register_callback(callback.on_createmove, "on_createmove", "psyability", function(cmd)
    do
        local abils = state.eth_abils
        local s = {}
        if abils then
            for _, ab in ipairs(abils) do
                if is_valid_entity(ab) then
                    local cd, tn
                    pcall(function() cd = ab.m_bInCastDelay end)
                    pcall(function() tn = ab.m_iTeamNum end)
                    s[#s + 1] = tostring(tn) .. (cd == true and ":CAST" or "")
                    if cd == true then _G.__dyn_seen_cast = { t = global_vars.curtime(), team = tn } end
                end
            end
        end
        _G.__dyn_cache_dump = "n=" .. tostring(abils and #abils or 0) .. " [" .. table.concat(s, ",") .. "]"
    end
    handle_enable_toggle()
    handle_item_autotoggle()
    handle_item_autodetect()
    handle_aim(cmd)
    handle_doorman(cmd)
    handle_doorman_cart(cmd)
    handle_doorman_abilities(cmd)
    handle_ladygeist(cmd)
    handle_debuff_items(cmd)
    handle_echo_shard(cmd)
    handle_ethereal(cmd)
    if Prediction then
        local now = global_vars.curtime()
        if now - state.pred_cleanup_t > 2.0 then
            state.pred_cleanup_t = now
            Prediction.CleanupStaleTracking()
        end
    end
end)

local function get_local_hero_name()
    local pawn = get_local_pawn()
    if not is_valid_entity(pawn) then return nil end
    local name = nil
    pcall(function() name = pawn:get_name() end)
    if type(name) == "string" and name:find("hero_", 1, true) then return name end
    return nil
end

local function set_status_text(txt)
    if hero_status_label then
        pcall(function() hero_status_label:ForceLocalization(txt) end)
    end
end

local function set_ctrls_disabled(list, disabled)
    if not list then return end
    for _, w in ipairs(list) do
        pcall(function() w:Disabled(disabled) end)
    end
end

local function apply_hero_display(active_hero)
    pcall(function() hero_status_group:Visible(active_hero == nil) end)
    for hn, groups in pairs(hero_groups) do
        local vis = (hn == active_hero)
        for _, g in ipairs(groups) do
            pcall(function() g:Visible(vis) end)
        end
    end
end

local function update_hero_menu()
    local now = global_vars.curtime()
    local name = get_local_hero_name()

    if name ~= state.hero_cur then
        state.hero_cur = name
        state.hero_applied = nil
        if name and not state.hero_loaded[name] then
            state.hero_transition_until = now + HERO_TRANSITION
        else
            state.hero_transition_until = 0
        end
    end

    local desired
    if not name then
        desired = "idle"
    elseif now < state.hero_transition_until then
        desired = "loading"
    elseif HERO_CTRLS[name] then
        desired = "ready"
    else
        desired = "unknown"
    end

    if desired == state.hero_applied then return end
    state.hero_applied = desired

    for _, list in pairs(HERO_CTRLS) do set_ctrls_disabled(list, true) end

    if desired == "idle" then
        set_status_text("Join a match with a hero.")
        apply_hero_display(nil)
    elseif desired == "unknown" then
        set_status_text("A menu has not yet been created for the hero " .. hero_display_name(name) .. ". If you'd like to add your menu to the Psy Ability, please send a DM to DreenWolks.")
        apply_hero_display(nil)
    elseif desired == "loading" then
        set_status_text("")
        apply_hero_display(name)
    elseif desired == "ready" then
        state.hero_loaded[name] = true
        set_status_text("")
        apply_hero_display(name)
        set_ctrls_disabled(HERO_CTRLS[name], false)
    end
end

register_callback(callback.on_draw, "on_draw", "psyability", function()
    update_hero_menu()
    draw_visuals()
end)

debug_print("Psy Ability loaded (version %s) by %s | prediction by %s (%s)",
    tostring(SCRIPT_VERSION), SCRIPT_AUTHOR, PREDICTION_AUTHOR, Prediction and "loaded" or "FAILED to load")
