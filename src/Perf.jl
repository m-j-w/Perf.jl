"""
# Module Perf

Leverage the 'perf' capabilities of the Linux kernel from within Julia.
"""
module Perf

using CpuId: cpufeature



include("kernel.jl")     # Kernel API


#
# Howto create a group leader: http://stackoverflow.com/a/42092180/5294141
#

#=

Initialize group leader:

struct perf_event_attr pea;
int fd1, fd2;
uiwt64_t id1, id2;

memset(&pea, 0, sizeof(struct perf_event_attr));
pea.type = PERF_TYPE_HARDWARE;
pea.size = sizeof(struct perf_event_attr);
pea.config = PERF_COUNT_HW_CPU_CYCLES;
pea.disabled = 1;
pea.exclude_kernel = 1;
pea.exclude_hv = 1;
pea.read_format = PERF_FORMAT_GROUP | PERF_FORMAT_ID;
fd1 = syscall(__NR_perf_event_open, &pea, 0, -1, -1, 0);

Get identifier of first counter

ioctl(fd1, PERF_EVENT_IOC_ID, &id1);

Initialize group members:

memset(&pea, 0, sizeof(struct perf_event_attr));
pea.type = PERF_TYPE_SOFTWARE;
pea.size = sizeof(struct perf_event_attr);
pea.config = PERF_COUNT_SW_PAGE_FAULTS;
pea.disabled = 1;
pea.exclude_kernel = 1;
pea.exclude_hv = 1;
pea.read_format = PERF_FORMAT_GROUP | PERF_FORMAT_ID;
fd2 = syscall(__NR_perf_event_open, &pea, 0, -1, fd1, 0);
                                            // ^^^^^^
ioctl(fd2, PERF_EVENT_IOC_ID, &id2);






Measure:

ioctl(fd1, PERF_EVENT_IOC_RESET, PERF_IOC_FLAG_GROUP);
ioctl(fd1, PERF_EVENT_IOC_ENABLE, PERF_IOC_FLAG_GROUP);
do_something();
ioctl(fd1, PERF_EVENT_IOC_DISABLE, PERF_IOC_FLAG_GROUP);

# Read results:

struct read_format {
    uint64_t nr;
    struct {
        uint64_t value;
        uint64_t id;
    } values[/*2*/];
};

char buf[4096];
struct read_format* rf = (struct read_format*) buf;
uint64_t val1, val2;

read(fd1, buf, sizeof(buf));
for (i = 0; i < rf->nr; i++) {
  if (rf->values[i].id == id1) {
    val1 = rf->values[i].value;
  } else if (rf->values[i].id == id2) {
    val2 = rf->values[i].value;
  }
}
printf("cpu cycles: %"PRIu64"\n", val1);
printf("page faults: %"PRIu64"\n", val2);

=#


"""
    perf_event_paranoia() ::Int

Determine the kernel's paranoia level from
`/proc/sys/kernel/perf_event_paranoia`.  If the file doesn't exist, and, thus,
the kernel doesn't provide performance events, then a `SystemError` is thrown.
"""
perf_event_paranoia() ::Int =
            open( x-> readstring(x) |> y->parse(Int,y),
                 "/proc/sys/kernel/perf_event_paranoid")

"""
    perf_permits_rdpmc() ::Bool

Determine whether the kernel direct access to performance counters via a
`rdpmc` instruction by reading `/sys/bus/event_source/devices/cpu/rdpmc`.
This file must have a value larger zero to indicate reading being permitted.

See `man 2 perf_event_open` for details.
"""
perf_permits_rdpmc() ::Bool =
        0 < open( x-> readstring(x) |> y->parse(Int,y),
                 "/sys/bus/event_source/devices/cpu/rdpmc")


"""
Module initialisation and requirement checking.
"""
function __init__()

    #
    # Here we try to initialize performance counters, and provide
    # instructions if something doesn't seem correct.
    #

    println("Checking availability of performance monitoring counters...")

    # Does the CPU indicate availability of PMC?
    !cpufeature(:PDCM) || warning("CPU does not support PMC.")

    # Is /proc/sys/kernel/perf_event_paranoid present?
    # And does it permit access by containing a value of 2 or less?

    # Did we already build the kernel constant extraction file?


    # Does the current kernel match the extraction file?


    # Create the default hardware counters, but leave them disabled.
    # We place these defaults into one single counter group.


end


end # module Perf
