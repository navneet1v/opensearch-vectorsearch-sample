import matplotlib.pyplot
import psutil
import time
import argparse
import json
import signal
import sys
import matplotlib
import os

class MemParser:
    def __init__(self, json=False, output=False, graphname="", rss=False):
        self.json = json
        self.output = output
        self.mem_stats = {
            'vms': [],
            'rss': [],
            'annrss': [],
            'time': [],
        }
        self.start_time = time.time()
        self.graphname = graphname
        self.rss = rss
    
    def get_anonymous_rss(self, pid):
        try:
            with open(f"/proc/{pid}/smaps", "r") as f:
                smaps = f.read()
            
            anonymous_rss = 0
            for line in smaps.splitlines():
                if line.startswith("Anonymous:"):
                    anonymous_rss += int(line.split()[1])
            
            return anonymous_rss
        except (IOError, ValueError):
            return None

    def __call__(self, meminfo, pid):
        annrss = self.get_anonymous_rss(pid)
        if self.output:
            print(str((int)(time.time() - self.start_time)) + ":", annrss, file=sys.stderr)
        self.mem_stats['vms'].append(meminfo.vms)
        self.mem_stats['rss'].append(meminfo.rss)
        self.mem_stats['annrss'].append(annrss * 1024)
        self.mem_stats['time'].append(time.time() - self.start_time)
    
    def graph(self):
        graph_stats = self.mem_stats['vms'] if not self.rss else self.mem_stats['annrss']
        mem_sizes = [1, 1024, 1024*1024, 1024*1024*1024]
        mem_names = ['B', 'KB', 'MB', 'GB']
        max_size = max(graph_stats)
        factor = 1
        name = "B"
        for i in range(len(mem_sizes)):
            if max_size >= mem_sizes[i]:
                factor = mem_sizes[i]
                name = mem_names[i]
            else:
                break
        matplotlib.pyplot.plot(self.mem_stats['time'], [i / factor for i in graph_stats])
        y_formatter = matplotlib.ticker.ScalarFormatter(useOffset=False)
        ax = matplotlib.pyplot.gca()
        ax.yaxis.set_major_formatter(y_formatter)
        matplotlib.pyplot.xlabel('Time (s)')
        matplotlib.pyplot.ylabel('Memory Usage (' + name + ')')
        matplotlib.pyplot.subplots_adjust(bottom=.12, left=.18)
        matplotlib.pyplot.title('Memory Usage Over Time')
        matplotlib.pyplot.savefig(self.graphname)

    def flush(self):
        if self.json:
            print(json.dumps(self.mem_stats))
        else:
            print(self.mem_stats)
        if self.graphname != "":
            self.graph()

class Exiter:
    def __init__(self, parser):
        self.parser = parser
    
    def __call__(self, signum, frame):
        self.parser.flush()
        exit(0)

if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        prog='pidmem',
        description=
        """
        A program that logs memory usage of a running process id.
        To exit, just press Ctrl+C. The logs will be generated afterwards.
        """
    )
    parser.add_argument('pid', type=int, help='Process ID')
    parser.add_argument('-d', '--delay', type=float, default=1, help='Delay between samples in seconds (can be a float value)')
    parser.add_argument('-o', '--output', action='store_true', help='Output the memory usage to stderr')
    parser.add_argument('-j', '--json', action='store_true', help='Output the memory usage in json format')
    parser.add_argument('-g', '--graph', type=str, default="", metavar="FILENAME", help='Output a graph of the memory usage')
    parser.add_argument('-t', '--time_limit', type=float, default=1000000, help='Max amount of time to log for')
    parser.add_argument('-r', '--rss', action='store_true', help='Use RSS instead of VMS for graph')
    args = parser.parse_args()
    pid = int(args.pid)
    process = psutil.Process(pid)
    memparser = MemParser(args.json, args.output, args.graph, args.rss)
    signal.signal(signal.SIGINT, Exiter(memparser))
    signal.signal(signal.SIGTERM, Exiter(memparser))
    start_time = time.time_ns()
    ticks = 0
    while True:
        time.sleep(max(start_time + ticks * int(args.delay * 1000000000) - time.time_ns(), 0) / 1000000000)
        if((time.time_ns() - start_time) / 1000000000 >= args.time_limit):
            Exiter(memparser)(0, 0)
        memory_info = process.memory_info()
        memparser(memory_info, pid)
        ticks += 1