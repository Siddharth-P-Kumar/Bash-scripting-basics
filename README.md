# 🚀 Bash Scripting Basics - Complete Learning Roadmap

A comprehensive collection of 20 bash scripts designed to take you from complete beginner to DevOps-ready bash scripting expert. Each script is thoroughly documented with explanations, use cases, and real-world applications.

## 📚 Learning Path Overview

This repository is organized into progressive difficulty levels, ensuring a smooth learning curve from basic concepts to advanced DevOps automation.

### 🎯 What You'll Learn
- **Bash Fundamentals**: Variables, loops, functions, conditionals
- **File Operations**: Reading, writing, processing files and directories  
- **System Administration**: Process management, monitoring, logging
- **DevOps Skills**: Docker management, Git automation, API testing
- **Security**: System hardening, security scanning, best practices
- **Advanced Topics**: Database operations, network utilities, error handling

## 📁 Repository Structure

```
bash-scripting-basics/
├── 01-basics/           # Fundamental bash concepts
├── 02-intermediate/     # File operations and advanced features
├── 03-devops/          # DevOps and system administration
├── 04-advanced/        # Advanced scripting and automation
└── README.md           # This file
```

## 🎓 Script Categories

### 📖 01-basics/ - Foundation Scripts
Perfect for absolute beginners to understand bash fundamentals.

| Script | Description | Key Concepts |
|--------|-------------|--------------|
| `01-hello-world.sh` | Your first bash script | Shebang, echo, comments, basic variables |
| `02-variables.sh` | Variable types and usage | String/numeric variables, environment vars, arrays |
| `03-input-args.sh` | User input and arguments | Command line args, read input, parameter handling |
| `04-conditionals.sh` | Decision making | if-else, case statements, comparisons |
| `05-loops.sh` | Iteration and repetition | for, while, until loops, loop control |
| `06-functions.sh` | Code organization | Function definition, parameters, return values |

### 🔧 02-intermediate/ - Building Skills
Intermediate concepts for file handling and system interaction.

| Script | Description | Key Concepts |
|--------|-------------|--------------|
| `07-file-operations.sh` | File and directory management | File tests, permissions, find, grep |
| `08-string-manipulation.sh` | Text processing | String operations, regex, pattern matching |
| `09-arrays.sh` | Data structures | Indexed/associative arrays, array operations |
| `10-error-handling.sh` | Robust scripting | Error handling, debugging, logging |

### 🛠️ 03-devops/ - DevOps Essentials
Real-world DevOps automation and system administration.

| Script | Description | Key Concepts |
|--------|-------------|--------------|
| `11-system-info.sh` | System monitoring | CPU, memory, disk usage, system stats |
| `12-log-analyzer.sh` | Log analysis and monitoring | Pattern matching, log parsing, alerts |
| `13-backup-system.sh` | Automated backups | File archiving, rotation, scheduling |
| `14-process-monitor.sh` | Process management | Process control, resource monitoring |
| `15-network-utils.sh` | Network diagnostics | Ping, port scanning, bandwidth monitoring |
| `16-docker-manager.sh` | Container management | Docker operations, container lifecycle |
| `17-git-manager.sh` | Version control automation | Git operations, repository management |

### 🚀 04-advanced/ - Expert Level
Advanced scripting for complex automation and security.

| Script | Description | Key Concepts |
|--------|-------------|--------------|
| `18-database-ops.sh` | Database management | MySQL/PostgreSQL operations, backups |
| `19-api-testing.sh` | API automation | REST API testing, monitoring, benchmarking |
| `20-security-scanner.sh` | Security auditing | System hardening, vulnerability scanning |

## 🚀 Quick Start Guide

### Prerequisites
- Linux/Unix system (Ubuntu, CentOS, macOS)
- Bash shell (version 4.0+)
- Basic terminal knowledge

### Installation
```bash
# Clone the repository
git clone https://github.com/yourusername/bash-scripting-basics.git
cd bash-scripting-basics

# Make all scripts executable
find . -name "*.sh" -exec chmod +x {} \;
```

### Running Scripts
```bash
# Basic usage
./01-basics/01-hello-world.sh

# Scripts with arguments
./01-basics/03-input-args.sh arg1 arg2

# DevOps scripts with commands
./03-devops/11-system-info.sh --output system_report.txt
./03-devops/16-docker-manager.sh list
./04-advanced/19-api-testing.sh get https://api.github.com/users/octocat
```

## 📋 Learning Roadmap

### Week 1: Bash Fundamentals
- [ ] Complete all scripts in `01-basics/`
- [ ] Understand variables, loops, and functions
- [ ] Practice with different input methods

### Week 2: Intermediate Concepts  
- [ ] Master file operations and string manipulation
- [ ] Learn array handling and error management
- [ ] Build your first utility scripts

### Week 3: DevOps Applications
- [ ] System monitoring and log analysis
- [ ] Backup automation and process management
- [ ] Network utilities and diagnostics

### Week 4: Advanced Automation
- [ ] Container and Git management
- [ ] Database operations and API testing
- [ ] Security scanning and hardening

## 💡 Script Features

### 🔍 Comprehensive Documentation
Every script includes:
- **Purpose**: What the script does
- **Usage**: How to run it with examples
- **Parameters**: All available options
- **Comments**: Line-by-line explanations
- **Error Handling**: Robust error management
- **Logging**: Activity tracking and debugging

### 🛡️ Production Ready
- Input validation and sanitization
- Proper error handling and exit codes
- Configurable parameters and defaults
- Logging and monitoring capabilities
- Security best practices

### 🎯 Real-World Applications
- **System Administration**: Monitoring, backups, maintenance
- **DevOps Automation**: CI/CD, deployment, infrastructure
- **Development Tools**: Git automation, API testing, database management
- **Security Operations**: Scanning, hardening, compliance

## 📖 Usage Examples

### System Monitoring
```bash
# Get comprehensive system information
./03-devops/11-system-info.sh --output server_status.txt

# Monitor processes in real-time
./03-devops/14-process-monitor.sh monitor

# Analyze log files for errors
./03-devops/12-log-analyzer.sh /var/log/syslog "error|warning"
```

### DevOps Automation
```bash
# Backup important directories
./03-devops/13-backup-system.sh backup /home/user/projects

# Manage Docker containers
./03-devops/16-docker-manager.sh run nginx web-server
./03-devops/16-docker-manager.sh stats

# Automate Git operations
./03-devops/17-git-manager.sh status
./03-devops/17-git-manager.sh backup
```

### API Testing and Monitoring
```bash
# Test REST APIs
./04-advanced/19-api-testing.sh get https://api.github.com/users/octocat
./04-advanced/19-api-testing.sh monitor https://httpbin.org/status/200 30

# Run API test suite
./04-advanced/19-api-testing.sh test api_tests.conf
```

## 🔧 Advanced Configuration

### Environment Setup
```bash
# Create configuration directory
mkdir -p ~/.bash_scripts_config

# Set up logging
export SCRIPT_LOG_DIR="/var/log/bash_scripts"
mkdir -p $SCRIPT_LOG_DIR

# Add to your .bashrc for permanent setup
echo 'export PATH=$PATH:~/bash-scripting-basics' >> ~/.bashrc
```

### Custom Configuration Files
Many scripts support configuration files for repeated use:

```bash
# Database configuration
./04-advanced/18-database-ops.sh setup

# API testing configuration  
./04-advanced/19-api-testing.sh setup
```

## 🛡️ Security Considerations

### File Permissions
```bash
# Secure script permissions
chmod 755 *.sh

# Protect configuration files
chmod 600 ~/.db_config ~/.api_config
```

### Best Practices Implemented
- Input validation and sanitization
- Secure temporary file handling
- Proper credential management
- Logging without sensitive data
- Error handling without information disclosure

## 🤝 Contributing

We welcome contributions! Here's how you can help:

### Adding New Scripts
1. Follow the existing naming convention
2. Include comprehensive documentation
3. Add error handling and logging
4. Test on multiple systems
5. Update this README

### Improving Existing Scripts
1. Fork the repository
2. Create a feature branch
3. Make your improvements
4. Test thoroughly
5. Submit a pull request

### Reporting Issues
- Use GitHub Issues for bug reports
- Include system information and error messages
- Provide steps to reproduce the issue

## 📚 Additional Resources

### Learning Materials
- [Bash Manual](https://www.gnu.org/software/bash/manual/)
- [Advanced Bash Scripting Guide](https://tldp.org/LDP/abs/html/)
- [ShellCheck](https://www.shellcheck.net/) - Script analysis tool

### Tools and Utilities
- **ShellCheck**: Static analysis for shell scripts
- **Bash Debugger**: Interactive debugging
- **Bats**: Bash testing framework

### Related Projects
- [Awesome Shell](https://github.com/alebcay/awesome-shell)
- [Pure Bash Bible](https://github.com/dylanaraps/pure-bash-bible)

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Bash community for excellent documentation
- DevOps practitioners for real-world use cases
- Open source contributors for inspiration
- Students and learners for feedback and suggestions

## 📞 Support

- **Issues**: [GitHub Issues](https://github.com/yourusername/bash-scripting-basics/issues)
- **Discussions**: [GitHub Discussions](https://github.com/yourusername/bash-scripting-basics/discussions)
- **Documentation**: Check individual script headers for detailed usage

---

## 🎯 Next Steps

1. **Start with basics**: Begin with `01-hello-world.sh`
2. **Practice regularly**: Try to write one script per day
3. **Experiment**: Modify scripts for your specific needs
4. **Share**: Contribute back to the community
5. **Build**: Create your own automation projects

**Happy Scripting! 🚀**

---

*This repository is designed to be your complete guide to bash scripting. Whether you're a system administrator, DevOps engineer, or developer, these scripts will help you automate tasks and improve your productivity.*
