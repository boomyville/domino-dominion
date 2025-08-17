#!/usr/bin/env python3
"""
Godot 4.4 Build Encryption Script
Automates the process of setting up and compiling encrypted Godot export templates
for both Windows and Web builds
"""

import os
import sys
import subprocess
import shutil
import platform
import secrets
import time
from pathlib import Path

# Configuration
GODOT_SRC_DIR = "C:/godot"
EMSDK_DIR = "C:/emsdk"

def print_step(step_num, title):
    """Print a formatted step header"""
    print(f"\n{'='*80}")
    print(f"Step {step_num}: {title}")
    print(f"{'='*80}")

def run_command(command, cwd=None, shell=True):
    """Run a shell command and print output"""
    print(f"\n> {command}")
    try:
        result = subprocess.run(
            command,
            cwd=cwd,
            shell=shell,
            text=True,
            capture_output=True
        )
        if result.stdout:
            print(result.stdout)
        if result.stderr:
            print(f"ERROR: {result.stderr}")
        result.check_returncode()
        return True
    except subprocess.CalledProcessError:
        print("Command failed")
        return False

def check_requirements():
    """Check if all required tools are installed"""
    print_step(1, "Checking requirements")
    
    requirements_met = True
    
    # Check Git
    if not shutil.which("git"):
        print("❌ Git not found. Please install Git from https://git-scm.com/download/win")
        requirements_met = False
    else:
        print("✅ Git is installed")
    
    # Check Python
    if not shutil.which("python"):
        print("❌ Python not found. Please install Python from https://www.python.org/downloads/windows/")
        requirements_met = False
    else:
        print("✅ Python is installed")
    
    # Check SCons
    try:
        subprocess.run(["scons", "--version"], capture_output=True, text=True).check_returncode()
        print("✅ SCons is installed")
    except (subprocess.CalledProcessError, FileNotFoundError):
        print("❌ SCons not found. Installing...")
        run_command("pip install scons")
    
    # Check C++ compiler
    cpp_found = False
    if platform.system() == "Windows":
        try:
            subprocess.run(["cl"], stderr=subprocess.PIPE, stdout=subprocess.PIPE)
            print("✅ Visual Studio C++ compiler is installed")
            cpp_found = True
        except FileNotFoundError:
            pass
        
        if not cpp_found:
            try:
                subprocess.run(["gcc", "--version"], stderr=subprocess.PIPE, stdout=subprocess.PIPE)
                print("✅ MinGW/GCC compiler is installed")
                cpp_found = True
            except FileNotFoundError:
                pass
    
    if not cpp_found:
        print("❌ C++ compiler not found. Please install Visual Studio 2022 with C++ support or MinGW")
        requirements_met = False
    
    return requirements_met

def setup_directories():
    """Create necessary directories"""
    print_step(2, "Setting up directories")
    
    godot_path = Path(GODOT_SRC_DIR)
    emsdk_path = Path(EMSDK_DIR)
    
    godot_path.mkdir(exist_ok=True, parents=True)
    emsdk_path.mkdir(exist_ok=True, parents=True)
    
    print(f"✅ Created directory: {godot_path}")
    print(f"✅ Created directory: {emsdk_path}")
    
    return True

def clone_godot_source():
    """Clone the Godot source repository"""
    print_step(3, "Cloning Godot source code")
    
    godot_path = Path(GODOT_SRC_DIR)
    godot_git = godot_path / ".git"
    
    if godot_git.exists():
        print("Godot repository already exists, updating...")
        return run_command("git pull", cwd=GODOT_SRC_DIR)
    else:
        return run_command(f"git clone https://github.com/godotengine/godot.git {GODOT_SRC_DIR}")

def setup_encryption_key():
    """Generate or retrieve the encryption key"""
    print_step(4, "Setting up encryption key")
    
    key_path = Path(GODOT_SRC_DIR) / "godot.gdkey"
    encryption_key = os.environ.get("SCRIPT_AES256_ENCRYPTION_KEY", "")
    
    if not encryption_key:
        print("No encryption key provided, generating a new one...")
        encryption_key = secrets.token_hex(32)
        with open(key_path, "w") as f:
            f.write(encryption_key)
        print(f"✅ Generated new encryption key and saved to {key_path}")
    else:
        print("✅ Using encryption key from environment variable")
        with open(key_path, "w") as f:
            f.write(encryption_key)
    
    # Set the environment variable for the current process
    os.environ["SCRIPT_AES256_ENCRYPTION_KEY"] = encryption_key
    print(f"✅ Set SCRIPT_AES256_ENCRYPTION_KEY environment variable")
    
    return encryption_key

def compile_windows_template():
    """Compile the Windows export template"""
    print_step(5, "Compiling Windows export template")
    
    print("⚠️ This may take 20-30 minutes...")
    start_time = time.time()
    
    success = run_command("scons platform=windows target=template_release", cwd=GODOT_SRC_DIR)
    
    if success:
        duration = (time.time() - start_time) / 60
        print(f"✅ Windows template compiled in {duration:.1f} minutes")
        template_path = Path(GODOT_SRC_DIR) / "bin" / "godot.windows.template_release.exe"
        print(f"✅ Template location: {template_path}")
        return True
    else:
        print("❌ Windows template compilation failed")
        return False

def setup_emscripten():
    """Set up the Emscripten SDK for Web export"""
    print_step(6, "Setting up Emscripten SDK")
    
    emsdk_path = Path(EMSDK_DIR)
    emsdk_git = emsdk_path / ".git"
    
    if emsdk_git.exists():
        print("Emscripten SDK already exists, updating...")
        run_command("git pull", cwd=EMSDK_DIR)
    else:
        run_command(f"git clone https://github.com/emscripten-core/emsdk.git {EMSDK_DIR}")
    
    # Install and activate latest Emscripten
    if platform.system() == "Windows":
        run_command(f"{EMSDK_DIR}\\emsdk.bat install latest", cwd=EMSDK_DIR)
        run_command(f"{EMSDK_DIR}\\emsdk.bat activate latest", cwd=EMSDK_DIR)
    else:
        run_command(f"{EMSDK_DIR}/emsdk install latest", cwd=EMSDK_DIR)
        run_command(f"{EMSDK_DIR}/emsdk activate latest", cwd=EMSDK_DIR)
    
    print("✅ Emscripten SDK set up successfully")
    return True

def compile_web_template():
    """Compile the Web export template"""
    print_step(7, "Compiling Web export template")
    
    print("⚠️ This may take 20-30 minutes...")
    start_time = time.time()
    
    # Source the Emscripten environment before compiling
    if platform.system() == "Windows":
        # On Windows, need to create a batch file to source env and compile
        batch_path = Path(GODOT_SRC_DIR) / "compile_web.bat"
        with open(batch_path, "w") as f:
            f.write(f"""
@echo off
call "{EMSDK_DIR}\\emsdk_env.bat"
cd /d {GODOT_SRC_DIR}
scons platform=web target=template_release
""")
        success = run_command(str(batch_path))
    else:
        # On Linux/Mac, can source and run in the same shell
        success = run_command(f"source {EMSDK_DIR}/emsdk_env.sh && scons platform=web target=template_release", cwd=GODOT_SRC_DIR)
    
    if success:
        duration = (time.time() - start_time) / 60
        print(f"✅ Web template compiled in {duration:.1f} minutes")
        template_path = Path(GODOT_SRC_DIR) / "bin" / ".web_zip" / "godot.web.template_release.wasm32.zip"
        print(f"✅ Template location: {template_path}")
        return True
    else:
        print("❌ Web template compilation failed")
        return False

def print_summary(windows_success, web_success, encryption_key):
    """Print a summary of the results"""
    print_step(8, "Summary")
    
    windows_template_path = Path(GODOT_SRC_DIR) / "bin" / "godot.windows.template_release.exe"
    web_template_path = Path(GODOT_SRC_DIR) / "bin" / ".web_zip" / "godot.web.template_release.wasm32.zip"
    key_path = Path(GODOT_SRC_DIR) / "godot.gdkey"
    
    # Write summary to file
    summary_path = Path(GODOT_SRC_DIR) / "encryption_setup_summary.md"
    with open(summary_path, "w") as f:
        f.write("# Godot Encryption Setup Summary\n\n")
        
        f.write("## Windows Template\n")
        f.write(f"Location: {windows_template_path}\n")
        f.write(f"Compilation: {'✅ Success' if windows_success else '❌ Failed'}\n\n")
        
        f.write("## Web Template\n")
        f.write(f"Location: {web_template_path}\n")
        f.write(f"Compilation: {'✅ Success' if web_success else '❌ Failed'}\n\n")
        
        f.write("## Encryption Key\n")
        f.write(f"Stored in: {key_path}\n\n")
        
        f.write("## Next Steps\n")
        f.write("1. Open Godot Editor → Project → Export → Windows/Web\n")
        f.write("2. Enable \"Advanced Options\"\n")
        f.write("3. Set the release template to the paths above\n")
        f.write("4. In the Encryption tab:\n")
        f.write("   - Enable \"Encrypt Exported PCK\"\n")
        f.write("   - Enable \"Encrypt Index\"\n")
        f.write("   - In \"Filters to include files/folders\" type \"*.*\" to encrypt all files\n")
        f.write("   - Or use \"*.tscn, *.gd, *.tres\" to encrypt only scenes, scripts and resources\n")
        f.write("5. Click \"Export Project\" and uncheck \"Export with debug\"\n")
    
    print("\n=== GODOT ENCRYPTION SETUP COMPLETE ===\n")
    print(f"Summary saved to: {summary_path}")
    print("\nNext steps:")
    print("1. Open Godot Editor → Project → Export → Windows/Web")
    print("2. Enable \"Advanced Options\"")
    print("3. Set the release template to the paths shown above")
    print("4. In the Encryption tab:")
    print("   - Enable \"Encrypt Exported PCK\"")
    print("   - Enable \"Encrypt Index\"") 
    print("   - In \"Filters to include files/folders\" type \"*.*\" to encrypt all files")
    print("   - Or use \"*.tscn, *.gd, *.tres\" to encrypt only specific file types")
    print("5. Click \"Export Project\" and uncheck \"Export with debug\"")
    print("\nYour encryption key is stored in:", key_path)

def main():
    """Main function"""
    print("\n========== GODOT 4.4 BUILD ENCRYPTION AUTOMATION ==========\n")
    
    if not check_requirements():
        print("\n❌ Some requirements are not met. Please install missing tools and try again.")
        return False
    
    setup_directories()
    clone_godot_source()
    encryption_key = setup_encryption_key()
    
    windows_success = compile_windows_template()
    
    setup_emscripten()
    web_success = compile_web_template()
    
    print_summary(windows_success, web_success, encryption_key)
    return True

if __name__ == "__main__":
    main()