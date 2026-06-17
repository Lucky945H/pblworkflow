# flake.nix
{
  description = "happyluck's pbl workflow";
  nixConfig = {
    # 国内镜像优先，保留官方缓存作为回退
    extra-substituters = [
      "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store"
      "https://mirrors.ustc.edu.cn/nix-channels/store"
    ];
    extra-trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
    ];
  };

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
            AGENT_BROWSER_EXECUTABLE_PATH="${pkgs.google-chrome}/bin/google-chrome-stable"; # 设置环境变量，指向 Chrome 可执行文件的路径
#            ANYSEARCH_API_KEY="${ if builtins.pathExists ./anysearchkey.env then builtins.readFile ./anysearchkey.env else ""}";
#            RUNCOMFY_TOKEN="${ if builtins.pathExists ./runcomfy.env then builtins.readFile ./runcomfy.env else ""}";
          };
  shellHook = ''
    if [ -f .env ]; then
      set -a
      source .env
      set +a
      echo "✅ 从 .env 加载环境变量"
    fi 
   
    echo "欢迎进入pbl workflow环境，输入opencode打开opencode tui吧"
    echo "关于配置API，自定义SKILL以及其他高级用法请参阅相关官方文档"
    npm install
    export NODE_PATH="$PWD/node_modules"
  '';

          
        };
      }
    );
}
