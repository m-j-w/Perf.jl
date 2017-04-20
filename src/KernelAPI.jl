"""
# Module KernelAPI

The module `KernelAPI` is part of the package `Perf` and implements the
interface to the Linux kernel's performance event API.
"""
module KernelAPI


#
#  Types & Constants
#

"""

Directly taken from Linux definition
"""
@enum( PerfTypeId::UInt32,
    PERF_TYPE_HARDWARE   = 0,
    PERF_TYPE_SOFTWARE   = 1,
    PERF_TYPE_TRACEPOINT = 2,
    PERF_TYPE_HW_CACHE   = 3,
    PERF_TYPE_RAW        = 4,
    PERF_TYPE_BREAKPOINT = 5,
    PERF_TYPE_MAX,       # non-ABI
)



"""
Generalized performance event event_id types, used by the
attr.event_id parameter of the sys_perf_event_open()
syscall. Common hardware events, generalized by the kernel.

Direct copy of kernel definition.
"""
@enum( PerfHwId::UInt64,
    PERF_COUNT_HW_CPU_CYCLES                = 0,
    PERF_COUNT_HW_INSTRUCTIONS              = 1,
    PERF_COUNT_HW_CACHE_REFERENCES          = 2,
    PERF_COUNT_HW_CACHE_MISSES              = 3,
    PERF_COUNT_HW_BRANCH_INSTRUCTIONS       = 4,
    PERF_COUNT_HW_BRANCH_MISSES             = 5,
    PERF_COUNT_HW_BUS_CYCLES                = 6,
    PERF_COUNT_HW_STALLED_CYCLES_FRONTEND   = 7,
    PERF_COUNT_HW_STALLED_CYCLES_BACKEND    = 8,
    PERF_COUNT_HW_REF_CPU_CYCLES            = 9,
    PERF_COUNT_HW_MAX,                      # non-ABI
)


"""
Bits that can be set in attr.sample_type to request information
in the overflow packets.

Direct copy of kernel definition.
"""
@enum( PerfEventSampleFormat::UInt32,
    PERF_SAMPLE_IP              = one(UInt32) << 0,
    PERF_SAMPLE_TID             = one(UInt32) << 1,
    PERF_SAMPLE_TIME            = one(UInt32) << 2,
    PERF_SAMPLE_ADDR            = one(UInt32) << 3,
    PERF_SAMPLE_READ            = one(UInt32) << 4,
    PERF_SAMPLE_CALLCHAIN       = one(UInt32) << 5,
    PERF_SAMPLE_ID              = one(UInt32) << 6,
    PERF_SAMPLE_CPU             = one(UInt32) << 7,
    PERF_SAMPLE_PERIOD          = one(UInt32) << 8,
    PERF_SAMPLE_STREAM_ID       = one(UInt32) << 9,
    PERF_SAMPLE_RAW             = one(UInt32) << 10,
    PERF_SAMPLE_BRANCH_STACK    = one(UInt32) << 11,
    PERF_SAMPLE_REGS_USER       = one(UInt32) << 12,
    PERF_SAMPLE_STACK_USER      = one(UInt32) << 13,
    PERF_SAMPLE_WEIGHT          = one(UInt32) << 14,
    PERF_SAMPLE_DATA_SRC        = one(UInt32) << 15,
    PERF_SAMPLE_IDENTIFIER      = one(UInt32) << 16,
    PERF_SAMPLE_TRANSACTION     = one(UInt32) << 17,
    PERF_SAMPLE_REGS_INTR       = one(UInt32) << 18,
    PERF_SAMPLE_MAX             = one(UInt32) << 19, #  non-ABI
)


"""
The format of the data returned by read() on a perf event fd,
as specified by attr.read_format:

struct read_format {
 { u64      value;
   { u64        time_enabled; } && PERF_FORMAT_TOTAL_TIME_ENABLED
   { u64        time_running; } && PERF_FORMAT_TOTAL_TIME_RUNNING
   { u64        id;           } && PERF_FORMAT_ID
 } && !PERF_FORMAT_GROUP

 { u64      nr;
   { u64        time_enabled; } && PERF_FORMAT_TOTAL_TIME_ENABLED
   { u64        time_running; } && PERF_FORMAT_TOTAL_TIME_RUNNING
   { u64        value;
     { u64  id;           } && PERF_FORMAT_ID
   }        cntr[nr];
 } && PERF_FORMAT_GROUP
};

Direct copy of kernel definition.
"""
@enum( PerfEventReadFormat::UInt64,
    PERF_FORMAT_UNKNOWN             = 0,
    PERF_FORMAT_TOTAL_TIME_ENABLED  = one(UInt64) << 0,
    PERF_FORMAT_TOTAL_TIME_RUNNING  = one(UInt64) << 1,
    PERF_FORMAT_ID                  = one(UInt64) << 2,
    PERF_FORMAT_GROUP               = one(UInt64) << 3,
    PERF_FORMAT_MAX                 = one(UInt64) << 4,     # non-ABI
)


"""
Keep in sync with kernel definition of `perf_event_attr` in
`<kernel_headers_dir>/include/uapi/linux/perf_event.h`.


It appears there are several versions of this struct, as defined by
```
#define PERF_ATTR_SIZE_VER0 64  /* sizeof first published struct */
#define PERF_ATTR_SIZE_VER1 72  /* add: config2 */
#define PERF_ATTR_SIZE_VER2 80  /* add: branch_sample_type */
#define PERF_ATTR_SIZE_VER3 96  /* add: sample_regs_user */
                                /* add: sample_stack_user */
#define PERF_ATTR_SIZE_VER4 104 /* add: sample_regs_intr */
#define PERF_ATTR_SIZE_VER5 112 /* add: aux_watermark */
```
"""
struct PerfEventAttr

    # This is taken from Linxu Kernel 4.10.0

    typeid              ::PerfTypeId    # original field name: 'type'
    size                ::UInt32        # set this to sizeof(PerfEventAttr) for the kernel to check compatibility issues
    config              ::UInt64        # Depending on `typeid`, one of the given unions
    sample              ::UInt64
    sample_type         ::UInt64
    read_format         ::PerfEventReadFormat
    flags               ::UInt64
    wakeup              ::UInt32
    bp_type             ::UInt32
    bp_addr             ::UInt64
    bp_len              ::UInt64
    branch_sample_type  ::UInt64
    sample_regs_user    ::UInt64
    sample_stack_user   ::UInt32
    clockid             ::Int32
    sample_regs_intr    ::UInt64
    aux_watermark       ::UInt32
    sample_max_stack    ::UInt16
    __reserved_2        ::UInt16

end

CpuCycleCounter() = PerfEventAttr( PERF_TYPE_HARDWARE
                                 , sizeof(PerfEventAttr)
                                 , PERF_COUNT_HW_CPU_CYCLES
                                 , 0, 0, PERF_FORMAT_UNKNOWN
                                 , 0b0110_0001, 0, 0, 0, 0
                                 , 0, 0, 0, 0, 0, 0, 0, 0)

sizeof(PerfEventAttr) != 112 &&
    warning("Type 'struct Perf.PerfEventAttr' does not meet kernel definition.")


"""
Linux syscall identifier for perf_event_open.

Keep in sync with `<linux-headers>/include/uapi/asm-generic/unistd.h`
"""
const __NR_perf_event_open = 298

#
#  Kernel API Wrapper
#

"""
Open and initialize the Linux kernel's performance monitor device.  This
basically wraps the low-level interface in a way like the kernel's API is
defined.
"""
function perf_event_open( attr::Ref{PerfEventAttr}
                        , pid::Int32, cpu::Int32
                        , group_fd::Int32, flags::UInt32
                        ) ::Int32

    ccall( :syscall, Int32
         , ( Int32, Ref{PerfEventAttr}, Int32, Int32, Int32, UInt32 )
         , __NR_perf_event_open, attr, pid, cpu, group_fd, flags )

end


#function test

end # module KernelAPI
