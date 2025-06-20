#!/usr/bin/env python3

import subprocess
import sys
import shlex
import os

def check_dependencies():
    """Check required dependencies."""
    for cmd in ['entr', 'git', 'task']:
        if subprocess.call(['which', cmd], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL) != 0:
            print(f"❌ Error: {cmd} is not installed.")
            sys.exit(1)

def run_cmd(cmd):
    """Run a shell command and return output as string."""
    return subprocess.check_output(cmd, shell=True, text=True).strip()

def run_cmd_no_fail(cmd):
    """Run a shell command, return True if success else False."""
    try:
        subprocess.check_call(cmd, shell=True)
        return True
    except subprocess.CalledProcessError:
        return False

def list_pending_tasks():
    """List pending tasks in the TDD project."""
    print("📋 Pending TDD Tasks:")
    try:
        output = run_cmd('task project:TDD status:pending')
        print(output if output else "No pending tasks found.")
    except subprocess.CalledProcessError:
        print("⚠️ Failed to list tasks.")

def count_pending_tasks():
    """Count pending tasks."""
    try:
        output = run_cmd('task project:TDD status:pending +PENDING count')
        return int(output)
    except Exception:
        return 0

def prompt_task_management():
    """Manage task selection or creation."""
    while True:
        pending_count = count_pending_tasks()

        if pending_count == 0:
            print("🎯 No pending tasks. Let's create a new one!")
            desc = input("Enter new task description: ").strip()
            subprocess.run(['task', 'add', 'project:TDD', desc])
            subprocess.run(['task', '+LATEST', 'start'])
            print(f"🆕 Created and started task: {desc}")
            return

        list_pending_tasks()
        print("-------------------------")
        print("Choose an option:")
        print("1) Create a new task")
        print("2) Continue an existing task")
        print("3) Edit an existing task")
        print("4) Delete a task")
        choice = input("Enter your choice (1/2/3/4): ").strip()

        if choice == '1':
            desc = input("Enter new task description: ").strip()
            subprocess.run(['task', 'add', 'project:TDD', desc])
            subprocess.run(['task', '+LATEST', 'start'])
            print(f"🆕 Created and started task: {desc}")
            return
        elif choice == '2':
            task_id = input("Enter the ID of the task you want to continue: ").strip()
            subprocess.run(['task', task_id, 'start'])
            desc = run_cmd(f'task _get {task_id}.description')
            print(f"🚀 Started Task: {desc}")
            return
        elif choice == '3':
            task_id = input("Enter the ID of the task you want to edit: ").strip()
            current_desc = run_cmd(f'task _get {task_id}.description')
            print(f"Current Description: {current_desc}")
            new_desc = input("Enter the new task description: ").strip()
            subprocess.run(['task', task_id, 'modify', f'description:{new_desc}'])
            print("✏️ Task updated.")
        elif choice == '4':
            task_id = input("Enter the ID of the task you want to delete: ").strip()
            subprocess.run(['task', task_id, 'delete'])
            print("🗑️ Task deleted.")
        else:
            print("❌ Invalid choice. Try again.")

def build_find_args(file_patterns):
    """Construct find command arguments based on file patterns."""
    args = []
    for pattern in file_patterns:
        args.extend(['-name', pattern, '-o'])
    args.pop()  # Remove last -o
    return args

def main():
    check_dependencies()

    file_pattern_input = input("Enter the file pattern(s) to watch (e.g. *.cs *.rb *.js): ").strip()
    if not file_pattern_input:
        print("No file pattern entered. Using default '*.cs *.fs'")
        file_pattern_input = "*.cs *.fs"

    test_command = input("Enter the test command to run (e.g. dotnet test, ruby test_*.rb, npm test): ").strip()
    if not test_command:
        print("No test command entered. Exiting.")
        sys.exit(1)

    file_patterns = file_pattern_input.split()

    # Manage tasks (create/start/edit/delete)
    prompt_task_management()

    print("✅ TDD session ready. Watching files...")

    find_cmd = ['find', '.', '-type', 'f', '('] + build_find_args(file_patterns) + [')']

    try:
        subprocess.check_output(find_cmd)
    except subprocess.CalledProcessError as e:
        print(f"⚠️ Error running find command: {e}")
        sys.exit(1)

    # Get active task ID & description
    ACTIVE_TASK_ID = run_cmd('task +ACTIVE _ids | head -n1')
    ACTIVE_TASK_DESC = run_cmd(f'task _get {ACTIVE_TASK_ID}.description')

    # Create temporary branch for TCR session
    branch_name = f"TCR_{ACTIVE_TASK_ID}"
    run_cmd(f"git checkout -b {branch_name}")

    error_log = "/tmp/tcr_errors.log"

    # Build the entr command pipeline
    entr_cmd = f"""
    echo '🔍 Running tests...'
    if {test_command}; then
        echo '✅ Tests passed. Committing...'
        git add .
        git commit -m "TCR: {ACTIVE_TASK_DESC}" --no-verify
        echo '🎯 Marking active task as done...'
        task {ACTIVE_TASK_ID} done
        notify-send "TCR: Tests Passed!"   # Desktop notification
    else
        echo '❌ Tests failed. Reverting changes...'
        git stash push -m 'Tests failed. Auto-stashed changes'
        echo '📝 Annotating active task with failure...'
        task {ACTIVE_TASK_ID} annotate 'Test failed. See console output for details.'
        echo "❌ Test Failure Logged" >> {error_log}
        notify-send "TCR: Tests Failed!"   # Desktop notification
    fi
    """

    # Launch find | entr with the above script
    find_proc = subprocess.Popen(find_cmd, stdout=subprocess.PIPE)
    entr_proc = subprocess.Popen(
        ['entr', '-c', 'bash', '-c', entr_cmd],
        stdin=find_proc.stdout
    )
    find_proc.stdout.close()  # Allow find_proc to receive a SIGPIPE if entr_proc exits
    entr_proc.communicate()

    print("--- TCR Watcher Stopped ---")

if __name__ == "__main__":
    main()

