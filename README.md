# Lucee CFML Engine Nix Flake
A complete Lucee CFML engine setup with Apache Tomcat, packaged as a Nix flake for reproducible environments.

## Quick Start
### Option 1: Initialize and Start
```bash
# Clone the repository
git clone https://github.com/emotions-ch/lucee-flake.git
cd lucee-flake

# Initialize Lucee instance directory
nix run .#init

# Start the server
nix run .#start
```

### Option 2: One-Step Start
```bash
nix run github:emotions-ch/lucee-flake
```

### Option 3: Development Environment
```bash
# Enter development shell
nix develop

# Available commands:
init-lucee     # Initialize instance directory
start-lucee    # Start server
stop-lucee     # Stop server
```

## Commands
### Available Scripts
- `init-lucee` - Initialize Lucee instance directory without starting
- `start-lucee` - Start Lucee with Tomcat server  
- `stop-lucee` - Stop running Lucee instance

### Using Nix Apps
```bash
nix run .#init    # Initialize only
nix run .#start   # Start server
nix run .#stop    # Stop server
```

## Instance Initialization
The `init-lucee` command creates a complete Lucee instance with:

1. Tomcat configuration files in `lucee-instance/conf/`
2. Lucee JAR file in `lucee-instance/lib/`
5. Lucee server and web configuration directories

### Directory Structure
```
lucee-instance/
├── conf/           # Tomcat configuration files
├── lib/            # Lucee JAR and Tomcat libraries
├── logs/           # Server and application logs
├── temp/           # Temporary files
├── work/           # Compiled JSPs and work files
├── lucee-server/   # Server-wide Lucee configuration
├── lucee-web/      # Web-context Lucee configuration
└── webapps/        # Your web applications
    ├── ROOT/       # Default site (localhost)
    │   └── WEB-INF/web.xml  # Lucee servlet configuration
```

## Configuration
### Environment Variables
- `CATALINA_BASE` - Instance directory (default: `./lucee-instance`)
- `CATALINA_HOME` - Tomcat installation (managed by Nix)
- `JAVA_HOME` - Java installation (managed by Nix)

### Customizing Tomcat
You can modify the configuration files before building:

1. **Edit `server.xml`** to:
   - Add virtual hosts
   - Change ports
   - Configure SSL
   - Add additional connectors

2. **Edit `web.xml`** to:
   - Configure Lucee servlet parameters
   - Add custom servlet mappings
   - Set up additional servlets

After making changes, rebuild with `nix build` or restart with `nix run`.

### Logs
Check logs in `lucee-instance/logs/`:
- `catalina.out` - Main Tomcat log
- `localhost_access_log.*.txt` - Access logs

## License
This flake configuration is provided as-is. Lucee and Tomcat have their own respective licenses.
