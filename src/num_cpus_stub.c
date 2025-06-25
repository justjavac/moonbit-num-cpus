// Copyright 2025 justjavac
//
// Licensed under the MIT License
//
// C FFI implementation for getting CPU count on native platforms

#include <stdlib.h>

#ifdef _WIN32
// Windows implementation
#include <windows.h>

int moonbit_get_cpu_count() {
    SYSTEM_INFO sysinfo;
    GetSystemInfo(&sysinfo);
    return (int)sysinfo.dwNumberOfProcessors;
}

#elif defined(__APPLE__) || defined(__linux__) || defined(__unix__) || defined(__unix)
// Unix-like systems (Linux, macOS, Unix)
#include <unistd.h>

int moonbit_get_cpu_count() {
    // Use sysconf to get the number of processors online
    long cpus = sysconf(_SC_NPROCESSORS_ONLN);
    
    // If sysconf fails, return 1 as a safe fallback
    if (cpus < 1) {
        return 1;
    }
    
    return (int)cpus;
}

#else
// Fallback for unknown platforms
int moonbit_get_cpu_count() {
    // Return 1 as a safe default for unknown platforms
    return 1;
}

#endif
