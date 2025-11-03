cat > ~/sys-bar <<'SH'
#!/usr/bin/env bash
# Burn-in-safe status bar: rotates order & drifts horizontally once per minute.

bat(){
  if command -v pi-top >/dev/null 2>&1; then
    pi-top battery 2>/dev/null | awk -F': ' '
      /Capacity/ {c=$2} /Charging State/ {s=$2}
      END{st=(s==1?"Charging":(s==2?"Discharging":"Unknown"));
          if(c=="")c="?"; printf "Battery %s%% (%s)",c,st}'
  else
    for d in /sys/class/power_supply/* 2>/dev/null; do
      [ -r "$d/capacity" ] || continue
      c=$(cat "$d/capacity" 2>/dev/null)
      s=$(cat "$d/status" 2>/dev/null)
      [ -n "$c" ] && { printf "Battery %s%% (%s)" "$c" "${s:-Unknown}"; return; }
    done
    printf "Battery ? (Unknown)"
  fi
}
cpu(){
  read _ a b c i _ < /proc/stat; sleep 0.5
  read _ a2 b2 c2 i2 _ < /proc/stat
  t=$(( (a2-a)+(b2-b)+(c2-c)+(i2-i) ))
  id=$((i2-i)); [ $t -gt 0 ] || t=1
  u=$(( (1000*(t-id)/t + 5)/10 ))
  if command -v vcgencmd >/dev/null 2>&1; then
    tc=$(vcgencmd measure_temp | sed 's/^temp=//;s/\..*//;s/'"'"'C//')
    t_out=" @$tc°C"
  else t_out=""; fi
  if [ -r /sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq ]; then
    khz=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq)
    ghz=$(awk -v k="$khz" 'BEGIN{printf "%.2f", k/1000000}')
    f_out=" ${ghz}GHz"
  else f_out=""; fi
  gov="?"
  [ -r /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor ] &&
    gov=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor)
  read la1 la5 la15 _ < /proc/loadavg
  printf "CPU %d%%%s%s | gov=%s | LA %s %s %s" "$u" "$t_out" "$f_out" "$gov" "$la1" "$la5" "$la15"
}
mem(){
  tot=$(awk '/MemTotal/{print$2}' /proc/meminfo)
  ava=$(awk '/MemAvailable/{print$2}' /proc/meminfo)
  [ -n "$tot" ] || { printf "RAM ?"; return; }
  use=$((tot-ava)); pct=$(( (1000*use/tot + 5)/10 ))
  printf "RAM %d%% (%d/%dMB)" "$pct" "$((use/1024))" "$((tot/1024))"
}
disk(){ read use used total < <(df -hP / | awk 'NR==2{print $5,$3,$2}')
  printf "DISK %s (%s/%s)" "$use" "$used" "$total"; }
wifi(){
  if iw dev wlan0 link 2>/dev/null | grep -q 'Connected'; then
    ssid=$(iw dev wlan0 link | awk -F': ' '/SSID/{print $2}')
    sig=$(iw dev wlan0 link | awk -F': ' '/signal/{print $2}' | awk '{print $1}')
    printf "WiFi %s (%s dBm)" "${ssid:-?}" "${sig:-?}"
  else printf "WiFi down"; fi
}
ipaddr(){
  ip -4 -br addr show wlan0 2>/dev/null | awk '$2~/UP/{sub(/\/.*/,"",$3);
    printf "IP %s (wlan0)",$3; exit}' && exit 0
  ip -4 -br addr show eth0  2>/dev/null | awk '$2~/UP/{sub(/\/.*/,"",$3);
    printf "IP %s (eth0)",$3; exit}' && exit 0
  printf "IP none"
}
clock(){ date "+%H:%M %d-%b-%y"; }

SEG=( "$(bat)" "$(cpu)" "$(mem)" "$(disk)" "$(wifi)" "$(ipaddr)" "$(clock)" )
n=${#SEG[@]}
seed=$(($(date +%s)/60)); rot=$((seed % n)); pad=$((seed % 9))
printf "%*s" "$pad" ""
(IFS=' | '; echo "${SEG[@]:$rot} ${SEG[@]:0:$rot}")
SH
chmod +x ~/sys-bar
