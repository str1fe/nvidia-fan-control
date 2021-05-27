require 'logger'
log = Logger.new('/tmp/fan_control.log')

MAX_FAN = 100
MIN_FAN = 40

FAN_INCREASE_TEMP = 60
FAN_DECREASE_TEMP = 50

FAN_STEP = 10

def step_up(lvl)
  if (lvl + FAN_STEP) > MAX_FAN
    MAX_FAN
  else
    lvl + FAN_STEP
  end
end

def step_down(lvl)
  if (lvl - FAN_STEP) < MIN_FAN
    MIN_FAN
  else
    lvl - FAN_STEP
  end
end

def set_fan_lvl(gpu_id, lvl)
  return if lvl < MIN_FAN

  `DISPLAY=:0 XAUTHORITY=/var/run/lightdm/root/:0 nvidia-settings -c :0 -a [gpu:#{gpu_id}]/GPUFanControlState=1`
  `DISPLAY=:0 XAUTHORITY=/var/run/lightdm/root/:0 nvidia-settings -c :0 -a [fan:#{gpu_id}]/GPUTargetFanSpeed=#{lvl}`
end

def at_max_lvl?(lvl)
  lvl == MAX_FAN
end

def at_min_lvl?(lvl)
  lvl == MIN_FAN
end

gpus = []
raw_info = `nvidia-smi --query-gpu=temperature.gpu,fan.speed --id --format=csv,noheader`
raw_info.split("\n").each_with_index do |info, gpu_id|
  info = info.split(",")

  gpus << { id: gpu_id, temp: info.first.to_i, fan_speed: info.last.to_i }
end

gpus.each do |gpu|
  if gpu[:temp] > FAN_INCREASE_TEMP
    next if at_max_lvl?(gpu[:fan_speed])

    log.info("Change gpu #{gpu[:id]} (#{gpu[:temp]}c) from #{gpu[:fan_speed]} to #{step_up(gpu[:fan_speed])}")
    log.info(set_fan_lvl(gpu[:id], step_up(gpu[:fan_speed])))
  elsif gpu[:temp] < FAN_DECREASE_TEMP
    next if at_min_lvl?(gpu[:fan_speed])

    log.info("Change gpu #{gpu[:id]} (#{gpu[:temp]}c) from #{gpu[:fan_speed]} to #{step_down(gpu[:fan_speed])}")
    log.info(set_fan_lvl(gpu[:id], step_down(gpu[:fan_speed])))
  end
end
