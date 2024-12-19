#!/usr/bin/env python3
# coding=utf-8


import threading
import os
import sys
import datetime
import psutil

interval = 1
ratios = []
lock = threading.Lock()

log_time = datetime.datetime.now().strftime("%y-%m-%d %H-%M-%S")
output_file_name = "top_uti %s.txt" % log_time


def write_utilization(pid):
    global ratios

    # cmd = "ps aux | grep ryu-manager | grep -v grep"

    try:
        cpu_percent = pid.cpu_percent()

        value = cpu_percent
        print(value)

        # res.split()

        lock.acquire()
        ratios.append(value)
        lock.release()
    except ValueError:
        print("error parsing value")
        return
    except IndexError:
        print("no ryu process working")
        ratios.append(0.0)
    except Exception:
        print("error")

    inner_timer = threading.Timer(interval, write_utilization, args=(pid,))
    inner_timer.start()

    lock.acquire()
    if len(ratios) == 10:
        with open(file=output_file_name, mode="a+") as f:
            f.write("\n".join([str(num) for num in ratios]))
            f.write("\n")
        ratios.clear()
    lock.release()


if __name__ == "__main__":
    cmd = "ps -ef | grep mycontroller | grep -v grep | awk '{print $2}'"
    try:
        pid = int(os.popen(cmd).readlines()[1])
        print(pid)
    except Exception:
        print("no ryu pid")

    with open(file=output_file_name, mode="a+")as f:
        f.write(datetime.datetime.now().strftime("%y-%m-%d %H-%M-%S"))
        f.write("\n")

    pid = psutil.Process(pid)
    timer = threading.Timer(interval, write_utilization, args = (pid, ))

    timer.start()
