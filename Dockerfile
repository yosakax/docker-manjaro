FROM manjarolinux/base:latest
LABEL maintainer="Yasuhiro OSAKA(fallingfluit.gmail.com)"

ARG BUILDERNAME=builder
ARG USERNAME=yosaka

RUN pacman-mirrors -c Japan,United_States\
 && pacman -Sy\
 && pacman -Syu --noconfirm --needed git sudo wget curl go base-devel
RUN usermod -l ${USERNAME} ${BUILDERNAME}\
 && groupmod -n ${USERNAME}  ${BUILDERNAME}\
 && usermod -d /home/${USERNAME} -m ${USERNAME}
RUN usermod -aG wheel ${USERNAME}\
 && passwd -d ${USERNAME}\
 && printf "%%wheel ALL=(ALL) NOPASSWD:ALL\n" | tee -a /etc/sudoers.d/wheel\
 && printf "[user]\ndefault=${USERNAME}\n" | tee /etc/wsl.conf

RUN localedef -f UTF-8 -i ja_JP ja_JP.UTF-8
ENV LANG="ja_JP.UTF-8" \
    LANGUAGE="ja_JP:ja" \
    LC_ALL="ja_JP.UTF-8"

USER ${USERNAME}
ENV SHELL /bin/bash

RUN cd \
 && git clone https://aur.archlinux.org/yay-bin \
 && cd yay-bin\
 && makepkg -si --noconfirm\
 && cd .. \
 && rm -rf ./yay-bin

RUN yay -Syu && yay -Sy --noconfirm --needed neovim nvm tmux
RUN  echo 'source /usr/share/nvm/init-nvm.sh' >> /home/${USERNAME}/.bashrc
RUN source /usr/share/nvm/init-nvm.sh &&  nvm install --lts && node --version && npm --version

RUN curl https://pyenv.run | bash && \
    echo 'eval "$(pyenv init --path)"' >> /home/${USERNAME}/.bashrc && \
    echo 'eval "$(pyenv init -)"' >> /home/${USERNAME}/.bashrc
ENV PYENV_ROOT /home/${USERNAME}/.pyenv
ENV PATH $PYENV_ROOT/bin/:$PATH

RUN echo 'eval "$(pyenv virtualenv-init -)"' >> /home/${USERNAME}/.bashrc && \
    source /home/${USERNAME}/.bashrc && \
    pyenv install 3.8.2 && \
    pyenv virtualenv 3.8.2 vim

RUN /home/${USERNAME}/.pyenv/versions/vim/bin/python -m pip install -U pip && \
    /home/${USERNAME}/.pyenv/versions/vim/bin/python -m pip install pynvim

RUN git clone https://github.com/yosakax/dotfiles.git /home/${USERNAME}/.dotfiles
RUN ls -l /home/${USERNAME}/ && mkdir -p /home/${USERNAME}/.config/nvim && ln -s /home/${USERNAME}/.dotfiles/init.vim /home/${USERNAME}/.config/nvim/init.vim

RUN curl -sS https://starship.rs/install.sh | sh -s -- --yes && echo 'eval "$(starship init bash)"' >> /home/${USERNAME}/.bashrc
RUN echo 'alias vim="nvim"' >> /home/${USERNAME}/.bashrc
RUN echo 'alias l="ls -F"' >> /home/${USERNAME}/.bashrc
RUN echo 'alias la="ls -aF"' >> /home/${USERNAME}/.bashrc

WORKDIR /home/${USERNAME}
