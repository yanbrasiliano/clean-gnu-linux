
# Clean GNU/Linux - Automating Tasks 🧹

## Introduction
Clean GNU/Linux is a script designed to automate various cleaning tasks in Debian-based Linux distributions. This tool helps maintain a clean and efficient operating system environment by simplifying routine maintenance.

---

## Features
- **APT Maintenance**: Updates, upgrades, and cleans unused packages.
- **Cache Cleaning**: Clears cache and temporary directories.
- **Docker Cleanup**: Removes unused Docker images, containers, and volumes.
- **Dry-Run Mode**: Simulates actions without making changes.
- **Customizable Options**: Use flags to tailor the cleaning process.

---

## Getting Started

### Prerequisites
- A Debian-based Linux distribution.
- Root privileges for system-wide cleanup tasks.
- Basic knowledge of terminal commands.

### Installation

1. **Clone the Repository**
   Clone the Clean GNU/Linux repository to your local machine:
   ```bash
   git clone https://github.com/yanbrasiliano/clean-gnu-linux.git
   ```

2. **Set Script Permissions**
   Navigate to the cloned repository directory and make the script executable:
   ```bash
   cd clean-gnu-linux
   chmod +x cleaning.sh
   ```

3. **Run the Script**
   Execute the script with the desired options:
   ```bash
   ./cleaning.sh [options]
   ```

---

## Usage

### Options
- **`--dry-run`**: Simulate cleaning actions without making changes.
- **`--skip-docker`**: Skip cleaning Docker-related resources.
- **`--help`**: Display a detailed help message with usage instructions.

### Examples
1. **Dry-Run Simulation**
   ```bash
   ./cleaning.sh --dry-run
   ```
   Simulates the cleaning process without deleting files or modifying the system.

2. **Skip Docker Cleanup**
   ```bash
   ./cleaning.sh --skip-docker
   ```
   Runs the cleaning script but skips all Docker-related cleanup tasks.

3. **Show Help**
   ```bash
   ./cleaning.sh --help
   ```
   Displays the help message with detailed usage instructions.

---

## Contributing
Contributions are welcome! To contribute:
1. Fork the repository.
2. Create a feature branch.
3. Submit a pull request with your enhancements.

Feel free to share bug fixes, optimizations, or new features.

---

## License
This script is distributed under the MIT License. For more details, refer to the LICENSE file in the repository.

---

## Enjoy the script and happy cleaning! 🏁