# Lucee CFML Engine Nix Flake

A complete Lucee CFML engine setup with Apache Tomcat, packaged as a Nix flake for reproducible environments.

## Quick Start

### Option 1: Initialize and Start
```bash
# Clone the repository
git clone <this-repo>
cd lucee-flake

# Initialize Lucee instance directory
nix run .#init

# Start the server
nix run .#start
```

### Option 2: One-Step Start
```bash
nix run github:yourusername/lucee-flake
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
3. Processed web.xml files with correct directory paths
4. Ready-to-use ROOT and example.com webapps
5. Lucee server and web configuration directories

### Accessing Your Sites
- **Main site**: http://localhost:8080
- **Example site**: http://localhost:8080 (with Host header: example.com)

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
    └── example.com/ # Example virtual host
        └── WEB-INF/web.xml  # Lucee servlet configuration
```

### Adding CFML Files

1. **For the main site**: Add `.cfm` files to `lucee-instance/webapps/ROOT/`
2. **For virtual hosts**: Add files to `lucee-instance/webapps/yoursite.com/`

### Adding New Sites

1. Run `init-lucee` to create base structure
2. Create new webapp: `mkdir -p lucee-instance/webapps/yoursite.com/WEB-INF`
3. Copy web.xml: `cp lucee-instance/webapps/ROOT/WEB-INF/web.xml lucee-instance/webapps/yoursite.com/WEB-INF/`
4. Add virtual host to `lucee-instance/conf/server.xml`
5. Add your CFML files to the webapp directory

### Testing CFML Processing

Create a test file to verify Lucee is working:

```cfm
<!-- test.cfm -->
<cfoutput>
<h1>Lucee Test</h1>
<p>Current Time: #now()#</p>
<p>Server Info: #server.lucee.version#</p>
</cfoutput>
```

Place in `lucee-instance/webapps/ROOT/test.cfm` and visit http://localhost:8080/test.cfm

## Configuration

### Configuration Files
The flake includes separate configuration files for easy customization:

- **`server.xml`** - Tomcat server configuration with virtual hosts
- **`web.xml`** - Lucee servlet configuration for web applications

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

## Development

This flake includes everything you need for Lucee development:
- Java 11 (LTS)
- Tomcat 9 with Lucee pre-installed
- Convenient start/stop scripts
- Pre-configured example sites

## Troubleshooting

### Port Already in Use
If port 8080 is busy, edit `lucee-instance/conf/server.xml` and change:
```xml
<Connector port="8080" protocol="HTTP/1.1" ... />
```

### Permissions Issues
Make sure the `lucee-instance` directory is writable:
```bash
chmod -R u+w lucee-instance
```

### Logs
Check logs in `lucee-instance/logs/`:
- `catalina.out` - Main Tomcat log
- `localhost_access_log.*.txt` - Access logs

## What This Flake Provides

Following the Lucee installation instructions, this flake:

1. ✅ Downloads `lucee-5.3.6.61.jar`
2. ✅ Places it in Tomcat's `lib` folder
3. ✅ Configures `server.xml` with multiple hosts
4. ✅ Creates proper directory structure for webapps
5. ✅ Sets up `web.xml` with Lucee servlet mappings
6. ✅ Includes REST servlet configuration
7. ✅ Provides example CFML pages

## License

This flake configuration is provided as-is. Lucee and Tomcat have their own respective licenses.
