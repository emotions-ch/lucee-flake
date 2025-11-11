{
  description = "Lucee CFML Engine with Tomcat";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        
        # Lucee JAR
        lucee-jar = pkgs.stdenv.mkDerivation {
          name = "lucee-5.3.6.61.jar";
          src = pkgs.fetchurl {
            url = "https://cdn.lucee.org/lucee-5.3.6.61.jar";
            sha256 = "sha256-n4ok9YgOhH7+3V45VZMgvxuoqfLfrpEDfZwWTTMBZ3g=";
          };
          dontUnpack = true;
          installPhase = ''
            mkdir -p $out
            cp $src $out/lucee.jar
          '';
        };

        # Custom Tomcat with Lucee
        tomcat-lucee = pkgs.tomcat9.overrideAttrs (oldAttrs: {
          postInstall = (oldAttrs.postInstall or "") + ''
            # Copy Lucee JAR to lib folder
            cp ${lucee-jar}/lucee.jar $out/lib/
            
            # Copy Tomcat server configuration (from ./server.xml)
            cp ${./server.xml} $out/conf/server.xml
            
            # Create ROOT webapp directory structure with Lucee configuration
            mkdir -p $out/webapps/ROOT/WEB-INF
            
            # Copy Lucee web.xml configuration for ROOT webapp (from ./web.xml)
            cp ${./web.xml} $out/webapps/ROOT/WEB-INF/web.xml

            # Create example webapp directory structure
            mkdir -p $out/webapps/example.com/WEB-INF
            
            # Copy Lucee web.xml configuration for example.com webapp (from ./web.xml)
            cp ${./web.xml} $out/webapps/example.com/WEB-INF/web.xml
          '';
        });

        # Startup script
        startScript = pkgs.writeShellScriptBin "start-lucee" ''
          export CATALINA_HOME=${tomcat-lucee}
          export CATALINA_BASE=''${CATALINA_BASE:-./lucee-instance}
          export JAVA_HOME=${pkgs.openjdk11}
          
          # Create base directory if it doesn't exist
          if [ ! -d "$CATALINA_BASE" ]; then
            echo "Creating Lucee instance directory at $CATALINA_BASE"
            mkdir -p "$CATALINA_BASE"/{conf,logs,temp,work,webapps}
            
            # Copy configuration files
            cp -r ${tomcat-lucee}/conf/* "$CATALINA_BASE/conf/"
            cp -r ${tomcat-lucee}/webapps/* "$CATALINA_BASE/webapps/"
            
            # Set proper permissions
            chmod -R u+w "$CATALINA_BASE"
          fi
          
          echo "Starting Lucee with Tomcat..."
          echo "🌐 Main site: http://localhost:8080"
          echo "🌐 Example site: http://localhost:8080 (with Host header: example.com)"
          echo "📁 Instance directory: $CATALINA_BASE"
          echo "Press Ctrl+C to stop"
          
          exec ${tomcat-lucee}/bin/catalina.sh run
        '';

        # Stop script
        stopScript = pkgs.writeShellScriptBin "stop-lucee" ''
          export CATALINA_HOME=${tomcat-lucee}
          export CATALINA_BASE=''${CATALINA_BASE:-./lucee-instance}
          
          if [ -f "$CATALINA_BASE/logs/catalina.pid" ]; then
            echo "Stopping Lucee Tomcat instance..."
            ${tomcat-lucee}/bin/catalina.sh stop
          else
            echo "No running Lucee instance found"
          fi
        '';

        # Development shell
        devShell = pkgs.mkShell {
          buildInputs = with pkgs; [
            tomcat-lucee
            openjdk11
            startScript
            stopScript
          ];
          
          shellHook = ''
            echo "🚀 Lucee + Tomcat development environment ready!"
            echo ""
            echo "Available commands:"
            echo "  start-lucee    - Start Lucee with Tomcat"
            echo "  stop-lucee     - Stop Lucee Tomcat instance"
            echo ""
            echo "Configuration:"
            echo "  Tomcat home: ${tomcat-lucee}"
            echo "  Java home: ${pkgs.openjdk11}"
            echo ""
            echo "To start Lucee, run: start-lucee"
          '';
        };

      in {
        packages = {
          inherit lucee-jar tomcat-lucee;
          default = tomcat-lucee;
          start-lucee = startScript;
          stop-lucee = stopScript;
        };

        devShells.default = devShell;

        apps = {
          default = {
            type = "app";
            program = "${startScript}/bin/start-lucee";
          };
          
          start = {
            type = "app";
            program = "${startScript}/bin/start-lucee";
          };
          
          stop = {
            type = "app";
            program = "${stopScript}/bin/stop-lucee";
          };
        };
      });
}
