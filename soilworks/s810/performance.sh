#!/system/bin/sh
#Original author: Alcolawl
#Original script By: RogerF81 + adanteon
#Settings By: RogerF81
#Device: Nexus 6P
#Codename: SoilWork UNIFIED
#SoC: Snapdragon 810
#Last Updated: 30/01/2018
#Credits: @Alcolawl @soniCron @Asiier @Freak07 @Mostafa Wael @Senthil360 @TotallyAnxious @RenderBroken @ZeroInfinity @Kyuubi10 @ivicask @RogerF81 @joshuous @boyd95 @ZeroKool76 @adanteon
codename=Soilwork
stype=balanced
version=V3.0
cdate=$(date)
#Initializing log

#Turn off core_control
echo 0 > /sys/module/msm_thermal/core_control/enabled

##Configuring stune & cpuset
if [ -d "/dev/stune" ]; then
	echo 10 > /dev/stune/top-app/schedtune.boost
	echo 0 > /dev/stune/background/schedtune.boost
	echo 0 > /dev/stune/foreground/schedtune.boost
	echo 0 > /dev/stune/schedtune.prefer_idle
	echo 0 > /proc/sys/kernel/sched_child_runs_first
	echo 5 > /proc/sys/kernel/sched_cfs_boost
	echo 0 > /dev/stune/background/schedtune.prefer_idle
	echo 0 > /dev/stune/foreground/schedtune.prefer_idle
	echo 1 > /dev/stune/top-app/schedtune.prefer_idle
	if [ -e "/proc/sys/kernel/sched_autogroup_enabled" ]; then
		echo 0 > /proc/sys/kernel/sched_autogroup_enabled
	fi
	if [ -e "/proc/sys/kernel/sched_is_big_little" ]; then
		echo 1 > /proc/sys/kernel/sched_is_big_little
	fi
	if [ -e "/proc/sys/kernel/sched_boost" ]; then
		echo 0 > /proc/sys/kernel/sched_boost
	fi
fi
echo 64 > /proc/sys/kernel/sched_nr_migrate
echo 10 > /proc/sys/kernel/sched_initial_task_util

if [ -d "/dev/cpuset" ]; then
	echo 0 > /dev/cpuset/background/cpus
	echo 0-1 > /dev/cpuset/system-background/cpus
fi

#Do not decrease sleep time
sleep 1

big_max_value=0
little_max_value=0
big_min_value=0
little_min_value=0

little_max_value=$(cat /sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_max_freq);
big_max_value=$(cat /sys/devices/system/cpu/cpu4/cpufreq/cpuinfo_max_freq);
little_min_value=$(cat /sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_min_freq);
big_min_value=$(cat /sys/devices/system/cpu/cpu4/cpufreq/cpuinfo_min_freq);

#Turn on all cores
chmod 644 /sys/devices/system/cpu/online
echo 0-7 > /sys/devices/system/cpu/online
echo 1 > /sys/devices/system/cpu/cpu0/online
echo 1 > /sys/devices/system/cpu/cpu1/online
echo 1 > /sys/devices/system/cpu/cpu2/online
echo 1 > /sys/devices/system/cpu/cpu3/online
echo 1 > /sys/devices/system/cpu/cpu4/online
echo 1 > /sys/devices/system/cpu/cpu5/online
echo 1 > /sys/devices/system/cpu/cpu6/online
echo 1 > /sys/devices/system/cpu/cpu7/online
chmod 444 /sys/devices/system/cpu/online


#Apply settings to LITTLE cluster

if [ -d /sys/devices/system/cpu/cpu0/cpufreq ]; then
	if [ -e /sys/devices/system/cpu/cpu0/cpufreq ]; then
		LGP=/sys/devices/system/cpu/cpu0/cpufreq
	fi
	AGL=/sys/devices/system/cpu/cpu0/cpufreq/scaling_available_governors;
	pnp_available=false;
	if [ -e /system/etc/pnp.xml ]; then
		pnp_available=true;
	fi
		
	
	if grep 'schedutil' $AGL; then
		if [ -e $AGL ]; then
			chmod 644 /sys/devices/system/cpu/cpu0/cpufreq/schedutil/*
			chmod 644 $LGP/schedutil/*
			echo schedutil > $LGP/scaling_governor
			sleep 1
			echo 500 > $LGP/schedutil/up_rate_limit_us
			echo 10000 > $LGP/schedutil/down_rate_limit_us
			if [ -e "$LGP/schedutil/iowait_boost_enable" ]; then
				echo 1 > $LGP/schedutil/iowait_boost_enable
			fi
			echo 10 > /sys/module/cpu_boost/parameters/dynamic_stune_boost
			echo 1 > /proc/sys/kernel/sched_cstate_aware
			if [ -e "/proc/sys/kernel/sched_use_walt_task_util" ]; then
				echo 1 > /proc/sys/kernel/sched_use_walt_task_util
				echo 1 > /proc/sys/kernel/sched_use_walt_cpu_util
				echo 15 > /proc/sys/kernel/sched_walt_init_task_load_pct
				echo 10000000 > /proc/sys/kernel/sched_walt_cpu_high_irqload
			fi
			chmod 444 /sys/devices/system/cpu/cpu0/cpufreq/schedutil/*
			chmod 444 $LGP/schedutil/*
		fi
	
	elif grep 'interactive' $AGL; then
		if [ -e $AGL ]; then
			echo 68 > /proc/sys/kernel/sched_upmigrate
			echo 33 > /proc/sys/kernel/sched_downmigrate
			echo 10 > /proc/sys/kernel/sched_small_wakee_task_load
			echo 10 > /proc/sys/kernel/sched_init_task_load
			if [ -e /proc/sys/kernel/sched_enable_power_aware ]; then
				echo 1 > /proc/sys/kernel/sched_enable_power_aware
			fi
			echo 1 > /proc/sys/kernel/sched_enable_thread_grouping
			echo 25 > /proc/sys/kernel/sched_big_waker_task_load
			echo 2 > /proc/sys/kernel/sched_window_stats_policy
			echo 5 > /proc/sys/kernel/sched_ravg_hist_size
			if [ -e /proc/sys/kernel/sched_upmigrate_min_nice ]; then
				echo 9 > /proc/sys/kernel/sched_upmigrate_min_nice
			fi
			echo 5 > /proc/sys/kernel/sched_spill_nr_run
			echo 74 > /proc/sys/kernel/sched_spill_load
			echo 1 > /proc/sys/kernel/sched_enable_thread_grouping
			echo 1 > /proc/sys/kernel/sched_restrict_cluster_spill
			if [ -e /proc/sys/kernel/sched_wakeup_load_threshold ]; then
				echo 110 > /proc/sys/kernel/sched_wakeup_load_threshold
			fi
			echo 10 > /proc/sys/kernel/sched_rr_timeslice_ms
			if [ -e "/proc/sys/kernel/sched_enable_power_aware" ]; then
				echo 1 > /proc/sys/kernel/sched_enable_power_aware
			fi
			if [ -e "/proc/sys/kernel/sched_migration_fixup" ]; then
				echo 1 > /proc/sys/kernel/sched_migration_fixup
			fi
			if [ -e "/sys/devices/system/cpu/cpu0/cpufreq/interactive/screen_off_maxfreq" ]; then
				echo 600000 > $LGP/interactive/screen_off_maxfreq
			fi
			if [ -e "/sys/devices/system/cpu/cpu0/cpufreq/interactive/powersave_bias" ]; then
				echo 1 > $LGP/interactive/powersave_bias
			fi
			if [ -e $AGL ]; then
				echo interactive > $LGP/scaling_governor
				sleep 1
				chmod 644 /sys/devices/system/cpu/cpu0/cpufreq/interactive/*
				chmod 644 $LGP/interactive/*
				if [ "pnp_available" == "false" ]; then
					echo "interactive will be set on LITTLE cluster"
					echo 70 600000:40 672000:58 768000:82 960000:89 1248000:94 > /sys/devices/system/cpu/cpu0/cpufreq/interactive/target_loads
				else
					echo "PnP detected! Tweaks will be set accordingly"
					echo 70 1248000:86 > /sys/devices/system/cpu/cpu0/cpufreq/interactive/target_loads
				fi
				echo 356940 > /sys/devices/system/cpu/cpu0/cpufreq/interactive/timer_slack
				echo 1248000 > /sys/devices/system/cpu/cpu0/cpufreq/interactive/hispeed_freq
				chmod 644 /sys/devices/system/cpu/cpu0/cpufreq/interactive/timer_rate
				echo 15000 > /sys/devices/system/cpu/cpu0/cpufreq/interactive/timer_rate
				echo 0 600000:20000 960000:40000 > /sys/devices/system/cpu/cpu0/cpufreq/interactive/above_hispeed_delay
				echo 400 > /sys/devices/system/cpu/cpu0/cpufreq/interactive/go_hispeed_load
				echo 0 > $LGP/interactive/min_sample_time	
				echo 0 > $LGP/interactive/max_freq_hysteresis
				echo 1 > $LGP/interactive/ignore_hispeed_on_notif
				echo 0 > $LGP/interactive/boost
				echo 0 > $LGP/interactive/fast_ramp_down
				echo 0 > $LGP/interactive/align_windows
				echo 1 > $LGP/interactive/use_migration_notif
				echo 1 > $LGP/interactive/use_sched_load
				echo 0 > $LGP/interactive/boostpulse_duration
				echo 0 > $LGP/interactive/io_is_busy
				echo 0 > $LGP/interactive/enable_prediction
				chmod 444 /sys/devices/system/cpu/cpu0/cpufreq/interactive/*
				chmod 444 $LGP/interactive/*
			fi
		fi
	fi
fi


#Apply settings to big cluster

if [ -d /sys/devices/system/cpu/cpu4/cpufreq ]; then
	if [ -e /sys/devices/system/cpu/cpu4/cpufreq ]; then
		BGP=/sys/devices/system/cpu/cpu4/cpufreq
	fi

	AGB=/sys/devices/system/cpu/cpu2/cpufreq/scaling_available_governors;

	if grep 'schedutil' $AGB; then
		if [ -e $AGB ]; then
			chmod 644 /sys/devices/system/cpu/cpu2/cpufreq/schedutil/*
			chmod 644 $BGP/schedutil/*
			echo schedutil > $BGP/scaling_governor
			sleep 1
			echo 500 > $BGP/schedutil/up_rate_limit_us
			echo 10000 > $BGP/schedutil/down_rate_limit_us
			if [ -e "$BGP/schedutil/iowait_boost_enable" ]; then
				echo 1 > $BGP/schedutil/iowait_boost_enable
			fi
			chmod 444 /sys/devices/system/cpu/cpu2/cpufreq/schedutil/*
			chmod 444 $BGP/schedutil/*
		fi
		
	elif grep 'interactive' $AGB; then
		if [ -e $AGB ]; then
			echo interactive > $BGP/scaling_governor
			sleep 1
			chmod 644 /sys/devices/system/cpu/cpu4/cpufreq/interactive/*
			chmod 644 $BGP/interactive/*
			if [ "pnp_available" == "false" ]; then
				echo 70 633000:48 768000:57 1248000:74 1440000:86 > /sys/devices/system/cpu/cpu4/cpufreq/interactive/target_loads
			else
				echo "PnP detected! Tweaks will be set accordingly"
				echo 70 1440000:88 > /sys/devices/system/cpu/cpu4/cpufreq/interactive/target_loads
			fi
			chmod 444 /sys/devices/system/cpu/cpu4/cpufreq/interactive/target_loads
			echo 178470 > $BGP/interactive/timer_slack
			echo 1958400 > $BGP/interactive/hispeed_freq
			chmod 644 $BGP/interactive/timer_rate
			echo 15000 > $BGP/interactive/timer_rate
			echo 10000 1440000:50000 > $BGP/interactive/above_hispeed_delay
			echo 400 > $BGP/interactive/go_hispeed_load
			echo 0 > $BGP/interactive/min_sample_time		
			echo 0 > $BGP/interactive/max_freq_hysteresis
			echo 1 > $BGP/interactive/ignore_hispeed_on_notif
			echo 0 > $BGP/interactive/boost
			echo 0 > $BGP/interactive/fast_ramp_down
			echo 0 > $BGP/interactive/align_windows
			echo 1 > $BGP/interactive/use_migration_notif
			echo 1 > $BGP/interactive/use_sched_load
			echo 0 > $BGP/interactive/boostpulse_duration
			echo 0 > $BGP/interactive/io_is_busy
			echo 0 > $BGP/interactive/enable_prediction
			chmod 444 /sys/devices/system/cpu/cpu4/cpufreq/interactive/*
			chmod 444 $BGP/interactive/*
		fi
	fi
fi


# #Tweak VoxPopuli -- Only on EAS kernels
# if [ -d /dev/voxpopuli/ ]; then
	# VOX_P=/dev/voxpopuli/
	# echo 1 > $VOX_P/enable_interaction_boost	#Main switch
	# echo 0 > $VOX_P/fling_min_boost_duration
	# echo 2500 > $VOX_P/fling_max_boost_duration
	# echo 10 > $VOX_P/fling_boost_topapp
	# echo 940 > $VOX_P/fling_min_freq_big	
	# echo 960 > $VOX_P/fling_min_freq_little
	# echo 200 > $VOX_P/touch_boost_duration
	# echo 5 > $VOX_P/touch_boost_topapp
	# echo 806 > $VOX_P/touch_min_freq_big
	# echo 960 > $VOX_P/touch_min_freq_little
# fi

# #Tweak input boost -- Only Sultanized ROMs
# if [ -e "/sys/kernel/cpu_input_boost" ]; then
	# chmod 644 /sys/kernel/cpu_input_boost/*
	# echo 1 > /sys/kernel/cpu_input_boost/enable
	# echo 66 > /sys/kernel/cpu_input_boost/ib_duration_ms
	# echo 537600 537600 > /sys/kernel/cpu_input_boost/ib_freqs
	# chmod 444 /sys/kernel/cpu_input_boost/*
# fi

# #Tweak cpu boost
if [ -e "/sys/module/cpu_boost" ]; then
	if [ -e "/sys/module/cpu_boost/parameters/input_boost_enabled" ]; then
		chmod 644 /sys/module/cpu_boost/parameters/input_boost_enabled
		echo 1 > /sys/module/cpu_boost/parameters/input_boost_enabled
	fi
	chmod 644 /sys/module/cpu_boost/parameters/input_boost_freq
	echo 0:768000 1:0 2:0 3:0 4:0 5:0 6:0 7:0 > /sys/module/cpu_boost/parameters/input_boost_freq
	chmod 644 /sys/module/cpu_boost/parameters/input_boost_ms
	echo 1000 > /sys/module/cpu_boost/parameters/input_boost_ms
	if [ -e "/sys/module/msm_performance/parameters/touchboost/sched_boost_on_input " ]; then
		echo N > /sys/module/msm_performance/parameters/touchboost/sched_boost_on_input
	fi
fi

sleep 1

#I/0 & block tweaks
string3=/sys/block/mmcblk0/queue/scheduler;
deadline=false;
cfq=false;
if grep 'deadline' $string3; then
	deadline=true;
fi
if grep 'cfq' $string3; then
	cfq=true;
fi
if [ -e $string3 ]; then

	if [ "$deadline" == "true" ]; then
		echo "setting deadline"
		echo 512 > /sys/block/mmcblk0/bdi/read_ahead_kb
		echo "deadline" > /sys/block/mmcblk0/queue/scheduler
		echo 16 > /sys/block/mmcblk0/queue/iosched/fifo_batch
		echo 1 > /sys/block/mmcblk0/queue/iosched/front_merges
		echo 250 > /sys/block/mmcblk0/queue/iosched/read_expire
		echo 2500 > /sys/block/mmcblk0/queue/iosched/write_expire
		echo 1 > /sys/block/mmcblk0/queue/iosched/writes_starved
		echo 0 > /sys/block/mmcblk0/queue/add_random
		echo 0 > /sys/block/mmcblk0/queue/iostats
		echo 1 > /sys/block/mmcblk0/queue/nomerges
		echo 0 > /sys/block/mmcblk0/queue/rotational
		echo 1 > /sys/block/mmcblk0/queue/rq_affinity
		echo 1024 > /sys/block/mmcblk1/bdi/read_ahead_kb
		echo "deadline" > /sys/block/mmcblk1/queue/scheduler
		echo 16 > /sys/block/mmcblk1/queue/iosched/fifo_batch
		echo 1 > /sys/block/mmcblk1/queue/iosched/front_merges
		echo 250 > /sys/block/mmcblk1/queue/iosched/read_expire
		echo 2500 > /sys/block/mmcblk1/queue/iosched/write_expire
		echo 1 > /sys/block/mmcblk1/queue/iosched/writes_starved
		echo 0 > /sys/block/mmcblk1/queue/add_random
		echo 0 > /sys/block/mmcblk1/queue/iostats
		echo 1 > /sys/block/mmcblk1/queue/nomerges
		echo 0 > /sys/block/mmcblk1/queue/rotational
		echo 1 > /sys/block/mmcblk1/queue/rq_affinity
		echo "deadline" > /sys/block/mmcblk0rpmb/queue/scheduler
		echo 16 > /sys/block/mmcblk0rpmb/queue/iosched/fifo_batch
		echo 1 > /sys/block/mmcblk0rpmb/queue/iosched/front_merges
		echo 250 > /sys/block/mmcblk0rpmb/queue/iosched/read_expire
		echo 2500 > /sys/block/mmcblk0rpmb/queue/iosched/write_expire
		echo 1 > /sys/block/mmcblk0rpmb/queue/iosched/writes_starved
		echo 0 > /sys/block/mmcblk0rpmb/queue/add_random
		echo 0 > /sys/block/mmcblk0rpmb/queue/iostats
		echo 1 > /sys/block/mmcblk0rpmb/queue/nomerges
		echo 0 > /sys/block/mmcblk0rpmb/queue/rotational
		echo 1 > /sys/block/mmcblk0rpmb/queue/rq_affinity
		
	elif [ "$cfq" == "true" ]; then
		echo "setting cfq"
		echo 512 > /sys/block/mmcblk0/bdi/read_ahead_kb
		echo "cfq" > /sys/block/mmcblk0/queue/scheduler
		echo 1 > /sys/block/mmcblk0/queue/iosched/back_seek_penalty
		echo 16384 > /sys/block/mmcblk0/queue/iosched/back_seek_max
		echo 120 > /sys/block/mmcblk0/queue/iosched/fifo_expire_sync
		echo 250 > /sys/block/mmcblk0/queue/iosched/fifo_expire_async
		echo 0 > /sys/block/mmcblk0/queue/iosched/slice_idle
		echo 8 > /sys/block/mmcblk0/queue/iosched/group_idle
		echo 1 > /sys/block/mmcblk0/queue/iosched/low_latency
		echo 10 > /sys/block/mmcblk0/queue/iosched/quantum
		echo 40 > /sys/block/mmcblk0/queue/iosched/slice_async
		echo 2 > /sys/block/mmcblk0/queue/iosched/slice_async_rq
		echo 100 > /sys/block/mmcblk0/queue/iosched/slice_sync
		echo 300 > /sys/block/mmcblk0/queue/iosched/target_latencymax_time
		echo 0 > /sys/block/mmcblk0/queue/add_random
		echo 0 > /sys/block/mmcblk0/queue/iostats
		echo 1 > /sys/block/mmcblk0/queue/nomerges
		echo 0 > /sys/block/mmcblk0/queue/rotational
		echo 1 > /sys/block/mmcblk1/queue/rq_affinity
		echo 1024 > /sys/block/mmcblk1/bdi/read_ahead_kb
		echo "cfq" > /sys/block/mmcblk1/queue/scheduler
		echo 1 > /sys/block/mmcblk1/queue/iosched/back_seek_penalty
		echo 16384 > /sys/block/mmcblk1/queue/iosched/back_seek_max
		echo 120 > /sys/block/mmcblk1/queue/iosched/fifo_expire_sync
		echo 250 > /sys/block/mmcblk1/queue/iosched/fifo_expire_async
		echo 0 > /sys/block/mmcblk1/queue/iosched/slice_idle
		echo 8 > /sys/block/mmcblk1/queue/iosched/group_idle
		echo 1 > /sys/block/mmcblk1/queue/iosched/low_latency
		echo 10 > /sys/block/mmcblk1/queue/iosched/quantum
		echo 40 > /sys/block/mmcblk1/queue/iosched/slice_async
		echo 2 > /sys/block/mmcblk1/queue/iosched/slice_async_rq
		echo 100 > /sys/block/mmcblk1/queue/iosched/slice_sync
		echo 300 > /sys/block/mmcblk1/queue/iosched/target_latencymax_time
		echo 0 > /sys/block/mmcblk1/queue/add_random
		echo 0 > /sys/block/mmcblk1/queue/iostats
		echo 1 > /sys/block/mmcblk1/queue/nomerges
		echo 0 > /sys/block/mmcblk1/queue/rotational
		echo 1 > /sys/block/mmcblk1/queue/rq_affinity
		echo "cfq" > /sys/block/mmcblk0rpmb/queue/scheduler
		echo 1 > /sys/block/mmcblk0rpmb/queue/iosched/back_seek_penalty
		echo 16384 > /sys/block/mmcblk0rpmb/queue/iosched/back_seek_max
		echo 120 > /sys/block/mmcblk0rpmb/queue/iosched/fifo_expire_sync
		echo 250 > /sys/block/mmcblk0rpmb/queue/iosched/fifo_expire_async
		echo 0 > /sys/block/mmcblk0rpmb/queue/iosched/slice_idle
		echo 8 > /sys/block/mmcblk0rpmb/queue/iosched/group_idle
		echo 1 > /sys/block/mmcblk0rpmb/queue/iosched/low_latency
		echo 10 > /sys/block/mmcblk0rpmb/queue/iosched/quantum
		echo 40 > /sys/block/mmcblk0rpmb/queue/iosched/slice_async
		echo 2 > /sys/block/mmcblk0rpmb/queue/iosched/slice_async_rq
		echo 100 > /sys/block/mmcblk0rpmb/queue/iosched/slice_sync
		echo 300 > /sys/block/mmcblk0rpmb/queue/iosched/target_latencymax_time
		echo 0 > /sys/block/mmcblk0rpmb/queue/add_random
		echo 0 > /sys/block/mmcblk0rpmb/queue/iostats
		echo 1 > /sys/block/mmcblk0rpmb/queue/nomerges
		echo 0 > /sys/block/mmcblk0rpmb/queue/rotational
		echo 1 > /sys/block/mmcblk0rpmb/queue/rq_affinity
		
	else
		echo "I/0 governor won't be changed"
		echo 512 > /sys/block/mmcblk0/bdi/read_ahead_kb
		echo 0 > /sys/block/mmcblk0/queue/add_random
		echo 0 > /sys/block/mmcblk0/queue/iostats
		echo 1 > /sys/block/mmcblk0/queue/nomerges
		echo 0 > /sys/block/mmcblk0/queue/rotational
		echo 1 > /sys/block/mmcblk1/queue/rq_affinity
		echo 1024 > /sys/block/mmcblk1/bdi/read_ahead_kb
		echo 0 > /sys/block/mmcblk1/queue/add_random
		echo 0 > /sys/block/mmcblk1/queue/iostats
		echo 1 > /sys/block/mmcblk1/queue/nomerges
		echo 0 > /sys/block/mmcblk1/queue/rotational
		echo 1 > /sys/block/mmcblk1/queue/rq_affinity
		echo 1024 > /sys/block/mmcblk0rpmb/bdi/read_ahead_kb
		echo 0 > /sys/block/mmcblk0rpmb/queue/add_random
		echo 0 > /sys/block/mmcblk0rpmb/queue/iostats
		echo 1 > /sys/block/mmcblk0rpmb/queue/nomerges
		echo 0 > /sys/block/mmcblk0rpmb/queue/rotational
		echo 1 > /sys/block/mmcblk0rpmb/queue/rq_affinity	
	fi
fi
echo 128 > /sys/block/mmcblk0/queue/nr_requests

#TCP tweaks
echo 1 > /proc/sys/net/ipv4/tcp_low_latency


## zRam
if [ -e /sys/block/zram0 ]; then
	echo 64 > /sys/block/zram0/queue/nr_requests
fi

##Pnp, if available
if [ -e /sys/power/pnpmgr ]; then
	echo 0 > /sys/power/pnpmgr/touch_boost
	echo 844800 > /sys/power/pnpmgr/cluster/little/cpu0/thermal_freq
	echo 307200 > /sys/power/pnpmgr/cluster/little/cpu0/scaling_min_freq
	echo 1248000 > /sys/power/pnpmgr/cluster/big/cpu0/thermal_freq
	echo 307200 > /sys/power/pnpmgr/cluster/big/cpu0/scaling_min_freq
fi	

## FS
echo 60 > /proc/sys/fs/lease-break-time
echo 32768 > /proc/sys/fs/inotify/max_queued_events
echo 256 > /proc/sys/fs/inotify/max_user_instances
echo 16384 > /proc/sys/fs/inotify/max_user_watches

##LMK
if [ -e "/sys/module/lowmemorykiller/parameters/enable_adaptive_lmk" ]; then 
	chmod 664 /sys/module/lowmemorykiller/parameters/enable_adaptive_lmk
	chown root /sys/module/lowmemorykiller/parameters/enable_adaptive_lmk
	echo 0 > /sys/module/lowmemorykiller/parameters/enable_adaptive_lmk
	chmod 444 /sys/module/lowmemorykiller/parameters/enable_adaptive_lmk
fi

# # Enable bus-dcvs
# for cpubw in /sys/class/devfreq/*qcom,cpubw* ; do
    # echo "bw_hwmon" > $cpubw/governor
    # echo 50 > $cpubw/polling_interval
    # echo 1525 > $cpubw/min_freq
    # echo "1525 5195 11863 13763" > $cpubw/bw_hwmon/mbps_zones
    # echo 4 > $cpubw/bw_hwmon/sample_ms
    # echo 34 > $cpubw/bw_hwmon/io_percent
    # echo 20 > $cpubw/bw_hwmon/hist_memory
    # echo 10 > $cpubw/bw_hwmon/hyst_length
    # echo 0 > $cpubw/bw_hwmon/low_power_ceil_mbps
    # echo 34 > $cpubw/bw_hwmon/low_power_io_percent
    # echo 20 > $cpubw/bw_hwmon/low_power_delay
    # echo 0 > $cpubw/bw_hwmon/guard_band_mbps
    # echo 250 > $cpubw/bw_hwmon/up_scale
    # echo 1600 > $cpubw/bw_hwmon/idle_mbps
# done
# for memlat in /sys/class/devfreq/*qcom,memlat-cpu* ; do
    # echo "mem_latency" > $memlat/governor
    # echo 10 > $memlat/polling_interval
# done
# echo "cpufreq" > /sys/class/devfreq/soc:qcom,mincpubw/governor

#Virtual Memory
echo 100 > /proc/sys/vm/dirty_expire_centisecs
echo 300 > /proc/sys/vm/dirty_writeback_centisecs
echo 0 > /proc/sys/vm/oom_kill_allocating_task
echo 3 > /proc/sys/vm/page-cluster
echo 0 > /proc/sys/vm/swappiness
echo 50 > /proc/sys/vm/vfs_cache_pressure
echo 40 > /proc/sys/vm/dirty_ratio
echo 20 > /proc/sys/vm/dirty_background_ratio
echo 1 > /proc/sys/vm/overcommit_memory
echo 0 > /proc/sys/vm/overcommit_ratio
echo 64 > /proc/sys/kernel/random/read_wakeup_threshold
echo 896 > /proc/sys/kernel/random/write_wakeup_threshold

#Turn on cores
chmod 664 /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq
chmod 664 /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq
chmod 664 /sys/devices/system/cpu/cpu4/cpufreq/scaling_max_freq
chmod 664 /sys/devices/system/cpu/cpu4/cpufreq/scaling_min_freq
echo $little_max_value > /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq
echo $little_min_value > /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq
echo $big_max_value > /sys/devices/system/cpu/cpu4/cpufreq/scaling_max_freq
echo $big_min_value > /sys/devices/system/cpu/cpu4/cpufreq/scaling_min_freq
chmod 644 /sys/devices/system/cpu/online
echo "0-7" > /sys/devices/system/cpu/online
chmod 444 /sys/devices/system/cpu/online
chmod 644 /sys/devices/system/cpu/offline
echo "" > /sys/devices/system/cpu/offline
chmod 444 /sys/devices/system/cpu/offline
echo 1 > /sys/devices/system/cpu/cpu0/online
echo 1 > /sys/devices/system/cpu/cpu1/online
echo 1 > /sys/devices/system/cpu/cpu2/online
echo 1 > /sys/devices/system/cpu/cpu3/online
echo 1 > /sys/devices/system/cpu/cpu4/online
echo 1 > /sys/devices/system/cpu/cpu5/online
echo 1 > /sys/devices/system/cpu/cpu6/online
echo 1 > /sys/devices/system/cpu/cpu7/online

#Enable Core Control and Disable MSM Thermal Throttling allowing for longer sustained performance
if [ -e "/sys/module/msm_thermal/core_control/enabled" ]; then
# re-enable thermal hotplug
	# re-enable thermal and BCL hotplug
	if [ -e "/sys/devices/soc/soc:qcom,bcl/mode" ]; then
		echo -n disable > /sys/devices/soc/soc:qcom,bcl/mode
		echo $bcl_hotplug_mask > /sys/devices/soc/soc:qcom,bcl/hotplug_mask
		echo $bcl_soc_hotplug_mask > /sys/devices/soc/soc:qcom,bcl/hotplug_soc_mask
		echo -n enable > /sys/devices/soc/soc:qcom,bcl/mode
	fi
	echo N > /sys/module/msm_thermal/parameters/enabled
	echo 0 > /sys/module/msm_thermal/vdd_restriction/enabled
	echo 1 > /sys/module/msm_thermal/core_control/enabled
fi



cdate=$(date)
