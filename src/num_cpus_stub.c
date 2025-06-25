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

int moonbit_get_physical_cpu_count() {
    // On Windows, we need to use GetLogicalProcessorInformation
    PSYSTEM_LOGICAL_PROCESSOR_INFORMATION buffer = NULL;
    DWORD returnLength = 0;
    
    // First call to get the required buffer size
    GetLogicalProcessorInformation(buffer, &returnLength);
    
    if (returnLength == 0) {
        // Fallback to logical processor count
        return moonbit_get_cpu_count();
    }
    
    buffer = (PSYSTEM_LOGICAL_PROCESSOR_INFORMATION)malloc(returnLength);
    if (buffer == NULL) {
        return moonbit_get_cpu_count();
    }
    
    if (!GetLogicalProcessorInformation(buffer, &returnLength)) {
        free(buffer);
        return moonbit_get_cpu_count();
    }
    
    int physicalCores = 0;
    DWORD byteOffset = 0;
    
    while (byteOffset + sizeof(SYSTEM_LOGICAL_PROCESSOR_INFORMATION) <= returnLength) {
        PSYSTEM_LOGICAL_PROCESSOR_INFORMATION ptr = 
            (PSYSTEM_LOGICAL_PROCESSOR_INFORMATION)(((char*)buffer) + byteOffset);
            
        if (ptr->Relationship == RelationProcessorCore) {
            physicalCores++;
        }
        
        byteOffset += sizeof(SYSTEM_LOGICAL_PROCESSOR_INFORMATION);
    }
    
    free(buffer);
    return physicalCores > 0 ? physicalCores : moonbit_get_cpu_count();
}

#elif defined(__APPLE__) || defined(__linux__) || defined(__unix__) || defined(__unix)
// Unix-like systems (Linux, macOS, Unix)
#include <unistd.h>
#ifdef __APPLE__
#include <sys/types.h>
#include <sys/sysctl.h>
#endif
#ifdef __linux__
#include <stdio.h>
#include <string.h>
#endif

int moonbit_get_cpu_count() {
    // Use sysconf to get the number of processors online
    long cpus = sysconf(_SC_NPROCESSORS_ONLN);
    
    // If sysconf fails, return 1 as a safe fallback
    if (cpus < 1) {
        return 1;
    }
    
    return (int)cpus;
}

int moonbit_get_physical_cpu_count() {
#ifdef __APPLE__
    // On macOS, we can use sysctlbyname
    int physical_cpus = 0;
    size_t size = sizeof(physical_cpus);
    
    if (sysctlbyname("hw.physicalcpu", &physical_cpus, &size, NULL, 0) == 0) {
        return physical_cpus > 0 ? physical_cpus : moonbit_get_cpu_count();
    }
    
    // Fallback to logical CPU count
    return moonbit_get_cpu_count();
    
#elif defined(__linux__)
    // On Linux, we need to parse /proc/cpuinfo
    FILE *file = fopen("/proc/cpuinfo", "r");
    if (file == NULL) {
        return moonbit_get_cpu_count();
    }
    
    char line[256];
    int physical_cpus = 0;
    int core_id = -1;
    int physical_id = -1;
    int max_core_id = -1;
    int max_physical_id = -1;
    
    while (fgets(line, sizeof(line), file)) {
        if (strncmp(line, "core id", 7) == 0) {
            sscanf(line, "core id\t\t: %d", &core_id);
            if (core_id > max_core_id) {
                max_core_id = core_id;
            }
        } else if (strncmp(line, "physical id", 11) == 0) {
            sscanf(line, "physical id\t: %d", &physical_id);
            if (physical_id > max_physical_id) {
                max_physical_id = physical_id;
            }
        }
    }
    
    fclose(file);
    
    // Calculate physical cores: (max_core_id + 1) * (max_physical_id + 1)
    if (max_core_id >= 0 && max_physical_id >= 0) {
        physical_cpus = (max_core_id + 1) * (max_physical_id + 1);
        return physical_cpus > 0 ? physical_cpus : moonbit_get_cpu_count();
    }
    
    // Fallback to logical CPU count
    return moonbit_get_cpu_count();
    
#else
    // For other Unix-like systems, fallback to logical CPU count
    return moonbit_get_cpu_count();
#endif
}

#else
// Fallback for unknown platforms
int moonbit_get_cpu_count() {
    // Return 1 as a safe default for unknown platforms
    return 1;
}

int moonbit_get_physical_cpu_count() {
    // Return 1 as a safe default for unknown platforms
    return 1;
}

#endif
