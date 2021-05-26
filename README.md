# nvidia-fan-control

Use a more aggressive fan curve than default

# how to use

1. Install ruby `pacman -S ruby`
2. clone repo
3. edit crontab `crontab -e` with `* * * * * /usr/bin/ruby /[YOUR PATH]/nvidia-fan-control/gpu_control.rb`

It will check temps every minute and make adjustments to fan levels
