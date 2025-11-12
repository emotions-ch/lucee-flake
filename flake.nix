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
    java = pkgs.openjdk25;

    # Lucee JAR
    lucee-jar = pkgs.stdenv.mkDerivation {
      name = "lucee-7.0.0.395.jar";
      src = pkgs.fetchurl {
        url = "https://cdn.lucee.org/${lucee-jar.name}";
        sha256 = "sha256-H5S1nWj0sRSXiuwBacKNb+6gN7JQ7njjZMjPh+c90wE=";
      };
      dontUnpack = true;
      installPhase = ''
        mkdir -p $out
        cp $src $out/lucee.jar
      '';
    };

    # Custom Tomcat with Lucee
    tomcat-lucee = pkgs.tomcat11.overrideAttrs (oldAttrs: {
      postInstall = (oldAttrs.postInstall or "") + ''
        # Copy Lucee JAR to lib folder
        cp ${lucee-jar}/lucee.jar $out/lib/
      '';
    });

    # Startup script
    startScript = pkgs.writeShellScriptBin "start-lucee" ''
      export CATALINA_HOME=${tomcat-lucee}
      export CATALINA_BASE=''${CATALINA_BASE:-./lucee-instance}
      export JAVA_HOME=${java}

      # Ensure Lucee JAR is in classpath by using local lib directory
      export CLASSPATH="$CATALINA_BASE/lib/*:$CATALINA_HOME/lib/*"

      # Initialize Catalina base if server.xml doesn't exist
      if [ ! -f "$CATALINA_BASE/conf/server.xml" ]; then
        init-lucee
      else
        echo "Using existing Lucee instance at $CATALINA_BASE"
      fi

      echo "Starting Lucee with Tomcat..."
      echo "🌐 Main site: http://localhost:8080"
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

    # Init script (initialize without starting)
    initScript = pkgs.writeShellScriptBin "init-lucee" ''
      export CATALINA_HOME=${tomcat-lucee}
      export CATALINA_BASE=''${CATALINA_BASE:-./lucee-instance}

      # Initialize Catalina base if server.xml doesn't exist
      if [ ! -f "$CATALINA_BASE/conf/server.xml" ]; then
        echo "Initializing Lucee instance directory at $CATALINA_BASE"

        # Create directory structure
        mkdir -p "$CATALINA_BASE"/{conf,logs,temp,work,webapps,lib}

        # Copy configuration files
        cp -r ${tomcat-lucee}/conf/* "$CATALINA_BASE/conf/"

        # Copy Tomcat lib files and add Lucee JAR
        cp -r ${tomcat-lucee}/lib/* "$CATALINA_BASE/lib/"
        cp ${lucee-jar}/lucee.jar "$CATALINA_BASE/lib/"

        # Create Lucee server and web directories
        mkdir -p "$CATALINA_BASE/lucee-server"
        mkdir -p "$CATALINA_BASE/lucee-web"

        # Create ROOT webapp with Lucee configuration
        mkdir -p "$CATALINA_BASE/webapps/ROOT/WEB-INF"

        # Set proper permissions
        chmod -R u+w "$CATALINA_BASE"

        echo "✅ Lucee instance initialized successfully at $CATALINA_BASE"
        echo ""
        echo "You can now:"
        echo "  - Add CFML files to $CATALINA_BASE/webapps/ROOT/"
        echo "  - Start the server with: start-lucee"
        echo "  - Modify configuration in $CATALINA_BASE/conf/"
      else
        echo "Lucee instance already exists at $CATALINA_BASE"
        echo "Use 'start-lucee' to start the server"
      fi
    '';

    # Development shell
    devShell = pkgs.mkShell {
      buildInputs = with pkgs; [
        tomcat-lucee
        java
        startScript
        stopScript
        initScript
        zsh
      ];

      shellHook = ''
        echo "🚀 Lucee + Tomcat development environment ready!"
        echo ""
        echo "Available commands:"
        echo "  init-lucee     - Initialize Lucee instance directory"
        echo "  start-lucee    - Start Lucee with Tomcat"
        echo "  stop-lucee     - Stop Lucee Tomcat instance"
        echo ""
        echo "Configuration:"
        echo "  Tomcat home: ${tomcat-lucee}"
        echo "  Java home: ${java}"
        echo ""
        echo "Quick start: init-lucee && start-lucee"
        exec zsh
      '';
    };

  in {
    packages = {
      inherit lucee-jar tomcat-lucee;
      default = tomcat-lucee;
      init-lucee = initScript;
      start-lucee = startScript;
      stop-lucee = stopScript;
    };

    devShells.default = devShell;

    apps = {
      default = {
        type = "app";
        program = "${startScript}/bin/start-lucee";
      };

      init = {
        type = "app";
        program = "${initScript}/bin/init-lucee";
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
