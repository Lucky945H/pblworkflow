# flake.nix
{
  description = "happyluck's pbl workflow";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
      
        pkgs=import nixpkgs {
          inherit system;
          config = {
            allowUnfree = true;
            
          };
        };

      in {       
        devShells.default = pkgs.mkShell {
          

#          关键点3: 指明在构建时需要用到哪些主机工具
          # nativeBuildInputs = with cross.buildPackages; [
            
          #   # 可以在这里添加其他构建时需要的工具
          # ];
          packages=with pkgs;[
            agent-browser
            opencode
            git
            python314
            nodejs_24
            google-chrome
            pandoc
            libreoffice
            poppler-utils
            python314Packages.defusedxml
            python314Packages.requests
            python314Packages.pillow
            python314Packages.markitdown
            python314Packages.ddgs
            python314Packages.python-docx
            python314Packages.jieba
            python314Packages.wordcloud
          ];
env = {
            # 这里可以设置一些环境变量，例如：
            # CC = "${cross.buildPackages.gcc}/bin/x86_64-w64-mingw32-gcc";
            # CXX = "${cross.buildPackages.gcc}/bin/x86_64-w64-mingw32-g++";
            AGENT_BROWSER_EXECUTABLE_PATH="${pkgs.google-chrome}/bin/google-chrome-stable"; # 设置环境变量，指向 Chrome 可执行文件的路径
            ANYSEARCH_API_KEY="${builtins.readFile ./anysearchkey.env}";
          };
  shellHook = ''
    
    echo "欢迎进入pbl workflow环境，输入opencode打开opencode tui吧"
    echo "关于配置API，自定义SKILL以及其他高级用法请参阅相关官方文档"
    npm install
    export NODE_PATH="$PWD/node_modules"
  '';

          
        };
      }
    );
}
