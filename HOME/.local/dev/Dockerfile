FROM bitnami/minideb

RUN apt update && apt install -y wget curl gpg

# add new user and add to sudo group
RUN useradd --create-home ccw && \
    usermod -aG sudo ccw

# fish shell
RUN echo 'deb http://download.opensuse.org/repositories/shells:/fish:/release:/3/Debian_11/ /' | tee /etc/apt/sources.list.d/shells:fish:release:3.list && \
    curl -fsSL https://download.opensuse.org/repositories/shells:fish:release:3/Debian_11/Release.key | gpg --dearmor | tee /etc/apt/trusted.gpg.d/shells_fish_release_3.gpg > /dev/null && \
    apt update && \
    apt install -y fish && \
    chsh --shell $(which fish) ccw

# common utilities
RUN apt install -y sudo git subversion ripgrep xclip xsel build-essential python3 python3-venv tar unzip ncurses-bin pip

# so that ccw can use sudo command
RUN passwd --delete ccw
USER ccw

# install development tooling and runtime ------------------------------------------ 
# dotnet latest
RUN cd /tmp && wget https://dot.net/v1/dotnet-install.sh -O dotnet-install.sh && \
    sudo chmod +x dotnet-install.sh && \
    ./dotnet-install.sh --channel 7.0 && \
    rm -rf /tmp/dotnet-install.sh && \
    sudo ln -s $HOME/.dotnet/dotnet /usr/local/bin/dotnet && \
    `# https://learn.microsoft.com/en-us/dotnet/core/install/linux-debian#dependencies` \
    sudo apt install -y libicu67

ARG TARGETARCH

# golang 1.20.4
RUN sudo mkdir -p /usr/local/go && \
    wget "https://go.dev/dl/go1.20.4.linux-${TARGETARCH}.tar.gz" -O "/tmp/go1.20.4.linux-${TARGETARCH}.tar.gz" && \
    sudo tar -xzf "/tmp/go1.20.4.linux-${TARGETARCH}.tar.gz" -C /usr/local && \
    rm -rf "/tmp/go1.20.4.linux-${TARGETARCH}.tar.gz" && \
    sudo ln -s /usr/local/go/bin/go /usr/local/bin/go

# nodejs
RUN curl -sL install-node.vercel.app/lts | sudo bash -s -- --yes

# rust
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y && \
    ls $HOME/.cargo/bin | awk '{print "/home/ccw/.cargo/bin/"$0}' | xargs sudo ln -s -t /usr/local/bin

# neovim
RUN /bin/bash -c "if [[ $TARGETARCH == "amd64" ]]; then \
      curl https://raw.githubusercontent.com/chewcw/dtfs/main/install-nvim.sh | bash; \
    else \
      cd /usr/local && sudo svn checkout https://github.com/chewcw/nv-built-aarch64/trunk/nvim; \
    fi"
# symlink for neovim
RUN sudo ln -sf /usr/local/nvim/bin/nvim /usr/bin/nvim

WORKDIR /workspace

# update neovim to latest configuration
RUN mkdir -p $HOME/.config && \
    cd $HOME/.config && \
    svn checkout https://github.com/chewcw/dtfs/trunk/HOME/.config/nvim

# use vi mode in fish shell
RUN mkdir -p $HOME/.config/fish && touch $HOME/.config/fish/config.fish && \
    echo 'fish_vi_key_bindings' >> /home/ccw/.config/fish/config.fish

# install alacritty terminfo so that neovim can show undercurl
RUN wget https://github.com/alacritty/alacritty/releases/download/v0.12.0/alacritty.info -O /tmp/alacritty.info && \
    sudo tic -xe alacritty,alacritty-direct /tmp/alacritty.info && \
    rm -rf /tmp/alacritty.info

# this env is necessary for neovim undercurl to work
ENV TERM=
# this env is necessary for neovim xclip integration to work
ENV DISPLAY=

COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
