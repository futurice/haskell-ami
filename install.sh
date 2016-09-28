#!/bin/sh

set -ex

case $1 in
## Add hvr-ppa
apt-repos)
	apt-get -yq update
    apt-get -yq --no-install-suggests --no-install-recommends --force-yes install software-properties-common python-software-properties
	apt-add-repository -y "ppa:hvr/ghc" 
	apt-get update
;;

# Essential packages
apt-packages)
    apt-get -yq --no-install-suggests --no-install-recommends --force-yes install \
        cabal-install-head \
        cabal-install-1.24 \
        alex-3.1.7 \
        happy-1.19.5 \
        ghc-7.0.4 \
        ghc-7.2.2 \
        ghc-7.4.2 \
        ghc-7.6.3 \
        ghc-7.8.4 \
        ghc-7.10.3 \
        ghc-8.0.1 \
        vim \
        curl \
        git \
        tmux \
        pkg-config \
        libfftw3-dev \
        liblapack-dev \
        liblzma-dev \
        libpq-dev \
        libyaml-dev \
        g++ gcc libc6-dev libffi-dev libgmp-dev make xz-utils zlib1g-dev git gnupg \
        zlib1g-dev
;;

# Very minimal vim setup
vimrc)
cat > $HOME/.vimrc <<'EOF'
set nocp                                                                           
set nu                                                                             
set nomodeline                                                                     
set noexpandtab                                                                    
set nowrap  
set backspace=2
set whichwrap+=<,>,h,l
set encoding=utf-8
set termencoding=utf-8
set ruler
set splitbelow
set splitright
set showmode
set cmdheight=1
EOF
;;

# additions to bashrc
bashrc)

if [ -f $HOME/.bashrc_orig ]; then
    cp $HOME/.bashrc_orig $HOME/.bashrc
else
    cp $HOME/.bashrc $HOME/.bashrc_orig
fi

echo '. ~/bashrc_extra' >> .bashrc

cat > $HOME/.bashrc_extra << 'EOF'
PATH=$HOME/.local/bin:$PATH
$(ghc-select ghc-8.0.1 cabal-head alex-3.1.7 happy-1.19.5)
$(stack --bash-completion-script stack)
EOF
;;

# ghc-select is nice
ghc-select)
    cd $HOME
    if [ ! -d ghc-select ]; then
        git clone https://github.com/phadej/ghc-select.git
        cd ghc-select
        export PATH=/opt/ghc/8.0.1/bin:/opt/cabal/head/bin:$PATH
        cabal update
        cabal new-build
        mkdir -p $HOME/.local/bin
        cp `find dist-newstyle/build -name ghc-select -type f | head -n 1` $HOME/.local/bin/
        $(ghc-select ghc-8.0.1 cabal-head)
        cd $HOME
    fi
;;

# hackage-cli is nice too
hackage-cli)
    cd $HOME
    if [ ! -d hackage-cli ]; then
        git clone https://github.com/hackage-trustees/hackage-cli.git
        cd hackage-cli
        $(ghc-select ghc-8.0.1 cabal-head)
        cabal new-build
        cp `find dist-newstyle/build -name hackage-cli -type f | head -n 1` $HOME/.local/bin/
    fi
;;

stack)
    curl -L https://www.stackage.org/stack/linux-x86_64 | tar xz --wildcards --strip-components=1 -C ~/.local/bin '*/stack' 
    stack update
;;

packdeps)
    if [ ! -d packdeps ]; then
        $(ghc-select ghc-8.0.1 cabal-head)
        cabal get packdeps
        mv packdeps-* packdeps
        cd packdeps
        cabal new-build
        cp `find dist-newstyle/build -name packdeps -type f | head -n 1` $HOME/.local/bin/
    fi
;;

all)
    sudo sh $0 apt-repos
    sudo sh $0 apt-packages
    sh $0 vimrc
    sh $0 bashrc
    sh $0 ghc-select
    sh $0 hackage-cli
    sh $0 stack
    sh $0 packdeps
;;

esac
