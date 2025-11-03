#!/bin/bash

# Progress Tracking and ETA Calculator for Launchify

# Total number of setup steps
TOTAL_STEPS=14

# Timing data file
TIMING_FILE="$HOME/.launchify/timing-stats.json"
CURRENT_RUN_START=0
STEP_START_TIME=0

# Step names for display
declare -A STEP_NAMES
STEP_NAMES[1]="Creating Project"
STEP_NAMES[2]="Setting up Vercel"
STEP_NAMES[3]="Setting up Convex"
STEP_NAMES[4]="Setting up Axiom"
STEP_NAMES[5]="Setting up Clerk"
STEP_NAMES[6]="Setting up shadcn/ui"
STEP_NAMES[7]="Setting up AI Integration"
STEP_NAMES[8]="Setting up Admin Panel"
STEP_NAMES[9]="Setting up Feature Toggles"
STEP_NAMES[10]="Setting up GitHub CI/CD"
STEP_NAMES[11]="Generating Environment Files"
STEP_NAMES[12]="Creating Setup Guides"
STEP_NAMES[13]="Validating Build"
STEP_NAMES[14]="Initializing Git"

# Initialize progress tracking
init_progress() {
    CURRENT_RUN_START=$(date +%s)
    
    # Create timing stats file if it doesn't exist
    if [ ! -f "$TIMING_FILE" ]; then
        mkdir -p "$(dirname "$TIMING_FILE")"
        echo "{}" > "$TIMING_FILE"
    fi
}

# Start timing a step
start_step_timer() {
    STEP_START_TIME=$(date +%s)
}

# End timing a step and update statistics
end_step_timer() {
    local step=$1
    local end_time=$(date +%s)
    local duration=$((end_time - STEP_START_TIME))
    
    # Update running average in timing file (simplified - just store last duration)
    # In a real implementation, you'd calculate running average
    # For now, we'll use default estimates
}

# Show progress bar
show_progress() {
    local current_step=$1
    local step_name="${STEP_NAMES[$current_step]}"
    
    # Calculate percentage
    local percent=$((current_step * 100 / TOTAL_STEPS))
    
    # Calculate ETA
    local eta=$(calculate_eta "$current_step")
    
    # Build progress bar
    local bar_width=40
    local filled=$((bar_width * current_step / TOTAL_STEPS))
    local empty=$((bar_width - filled))
    
    local bar="["
    for ((i=0; i<filled; i++)); do bar+="█"; done
    for ((i=0; i<empty; i++)); do bar+="░"; done
    bar+="]"
    
    # Display progress
    echo ""
    echo -e "${CYAN}═══════════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}Progress: ${bar} ${percent}%${NC}"
    echo -e "${BLUE}Step ${current_step}/${TOTAL_STEPS}: ${step_name}${NC}"
    if [ -n "$eta" ]; then
        echo -e "${YELLOW}Estimated time remaining: ${eta}${NC}"
    fi
    echo -e "${GREEN}💾 Progress automatically saved (Ctrl+C safe)${NC}"
    echo -e "${CYAN}═══════════════════════════════════════════════════════════${NC}"
    echo ""
}

# Calculate estimated time remaining
calculate_eta() {
    local current_step=$1
    local remaining_steps=$((TOTAL_STEPS - current_step))
    
    if [ $remaining_steps -le 0 ]; then
        echo ""
        return
    fi
    
    # Estimate based on current runtime (rough estimate)
    local current_runtime=$(($(date +%s) - CURRENT_RUN_START))
    local avg_time_per_step=$((current_runtime / current_step))
    
    # Use default estimates for remaining steps if we don't have data
    # Typical times: Project creation (30s), Service setup (20s each), Build (60s)
    local estimated_remaining=0
    
    for ((step=current_step+1; step<=TOTAL_STEPS; step++)); do
        case $step in
            1) estimated_remaining=$((estimated_remaining + 30)) ;;  # Project creation
            13) estimated_remaining=$((estimated_remaining + 60)) ;; # Build validation
            *) estimated_remaining=$((estimated_remaining + 15)) ;;  # Other steps
        esac
    done
    
    # Blend with actual average if we have data
    if [ $current_step -gt 2 ]; then
        local calculated_remaining=$((avg_time_per_step * remaining_steps))
        estimated_remaining=$(((estimated_remaining + calculated_remaining) / 2))
    fi
    
    # Format time nicely
    format_time $estimated_remaining
}

# Format seconds into human-readable time
format_time() {
    local seconds=$1
    
    if [ $seconds -lt 60 ]; then
        echo "${seconds}s"
    elif [ $seconds -lt 3600 ]; then
        local minutes=$((seconds / 60))
        local secs=$((seconds % 60))
        echo "${minutes}m ${secs}s"
    else
        local hours=$((seconds / 3600))
        local minutes=$(((seconds % 3600) / 60))
        echo "${hours}h ${minutes}m"
    fi
}

# Show completion summary
show_completion_summary() {
    local total_time=$(($(date +%s) - CURRENT_RUN_START))
    local formatted_time=$(format_time $total_time)
    
    echo ""
    echo -e "${GREEN}═══════════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}All steps completed successfully!${NC}"
    echo -e "${GREEN}Total setup time: ${formatted_time}${NC}"
    echo -e "${GREEN}═══════════════════════════════════════════════════════════${NC}"
    echo ""
}

