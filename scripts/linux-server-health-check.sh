
#!/usr/bin/env bash

# Linux Server Health Check
# Collects basic system health information.
# Read-only checks; does not change system configuration.

set -u

REPORT_FILE="linux-health-report-$(date +%Y%m%d-%H%M%S).txt"

section() {
    printf '\n===== %s =====\n' "$1"
}

{
    echo "LINUX SERVER HEALTH CHECK"
    echo "Generated at: $(date)"
    echo "Hostname: $(hostname)"
    echo

    section "OPERATING SYSTEM"
    if [[ -r /etc/os-release ]]; then
        . /etc/os-release
        echo "Distribution: ${PRETTY_NAME:-Unknown}"
    else
        echo "Distribution information unavailable."
    fi
    echo "Kernel: $(uname -r)"
    echo "Architecture: $(uname -m)"
    echo "Uptime: $(uptime -p 2>/dev/null || uptime)"

    section "CPU"
    if command -v nproc >/dev/null 2>&1; then
        echo "Logical CPU count: $(nproc)"
    else
        echo "Logical CPU count: unavailable"
    fi
    if [[ -r /proc/loadavg ]]; then
        echo "Load average (1, 5, 15 min): $(cat /proc/loadavg)"
    fi

    section "MEMORY"
    if command -v free >/dev/null 2>&1; then
        free -h
    else
        echo "The 'free' command is unavailable."
    fi

    section "DISK USAGE"
    if command -v df >/dev/null 2>&1; then
        df -hP -x tmpfs -x devtmpfs
    else
        echo "The 'df' command is unavailable."
    fi

    section "FAILED SYSTEMD SERVICES"
    if command -v systemctl >/dev/null 2>&1; then
        systemctl --failed --no-pager 2>&1 ||
            echo "Unable to query systemd services."
    else
        echo "systemctl is unavailable; systemd may not be in use."
    fi

    section "END OF REPORT"
    echo "Report file: $REPORT_FILE"

} > "$REPORT_FILE" 2>&1

echo "Health check completed."
echo "Report saved to: $REPORT_FILE"
