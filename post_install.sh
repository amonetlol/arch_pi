#!/bin/bash

# Obtém o usuário atual e o diretório home
CURRENT_USER=$(whoami)
USER_HOME=$(eval echo ~$CURRENT_USER)
LOG_FILE="${USER_HOME}/Downloads/post_install.log"

# Cria ou limpa o arquivo de log
echo "Início da execução: $(date)" > "${LOG_FILE}"

# Exibe uma caixa de seleção múltipla
opcoes=$(zenity --list --checklist \
  --title="Pio's Arch Post Install" \
  --text="Marque as opções desejadas" \
  --width=1000 \
  --height=600 \
  --multiple \
  --separator="," \
  --print-column=2 \
  --hide-column=2 \
  --column="Opções" --column="variavel" --column="Ação" \
  --ok-label="OK" \
  --cancel-label="Cancelar" \
  TRUE twe "Tweaks" \
  TRUE vm "Vmware Guest" \
  TRUE ref "Reflector" \
  TRUE aur_helper "Yay" \
  TRUE ft "Fastfetch" \
  TRUE nv "Neovim" \
  TRUE alias_ "Alias" \
  TRUE star "Starship" \
  TRUE debloat "Debloat Gnome" \
  TRUE nerdapp "Nerd Apps" \
  TRUE app "Apps" \
  TRUE misc "Misc Apps" \
  TRUE files "File System" \
  TRUE font "Fonts" \
  TRUE bashrc "Tuning Bashrc" \
  FALSE flat "Flatpak" \
  FALSE extra "Apps Extras" \
  TRUE wall "Wallpaper" \
  TRUE chao "Chaotic" \
  TRUE hide "Hidden Shortcut" \
  TRUE rice "Cursor, Tema e Icones")

# Verifica se o usuário cancelou
case $? in
  1)
    echo "Cancelado pelo usuário." | tee -a "${LOG_FILE}"
    exit 1
    ;;
esac

# Atualizando o sistema
cmnds="pacman -Syu --noconfirm;"

IFS="," read -ra comandos <<< "$opcoes"

for opcao in "${comandos[@]}"; do
	case "$opcao" in
		"twe")
			cmnds+=" sed -i 's/^\s*#\s*DefaultTimeoutStopSec=.*/DefaultTimeoutStopSec=10s/' /etc/systemd/system.conf;"
			cmnds+=" echo 'MAKEFLAGS=\"-j\$(nproc)\"' | tee -a /etc/makepkg.conf;"
			cmnds+=" systemctl enable fstrim.timer;"
			cmnds+=" echo -e \"\e[33mTweaks concluído.\e[0m\";"
			;;
		"vm")
			cmnds+=" pacman -S --needed --noconfirm open-vm-tools fuse2 gtkmm3;"
			cmnds+=" systemctl enable --now vmtoolsd;"
			cmnds+=" echo -e \"\e[33mVmware Guest concluído.\e[0m\";"
			;;
		"ref")
			cmnds+=" pacman -S --noconfirm reflector rsync;"
			cmnds+=" reflector --country Brazil --latest 10 --sort rate --save /etc/pacman.d/mirrorlist;"
			cmnds+=" echo -e \"\e[33mReflector concluído.\e[0m\";"
			;;
		"aur_helper")
			cmnds+=" if ! command -v git &>/dev/null; then pacman -S --noconfirm git; fi;"
			cmnds+=" mkdir -p \"${USER_HOME}/Downloads/.src\" && chown ${CURRENT_USER}:${CURRENT_USER} \"${USER_HOME}/Downloads/.src\" && chmod 755 \"${USER_HOME}/Downloads/.src\";"
			cmnds+=" if [ ! -d \"${USER_HOME}/Downloads/.src/yay-bin\" ]; then cd \"${USER_HOME}/Downloads/.src\" && runuser -u ${CURRENT_USER} -- git clone https://aur.archlinux.org/yay-bin && cd yay-bin && runuser -u ${CURRENT_USER} -- makepkg --noconfirm -si; else cd \"${USER_HOME}/Downloads/.src/yay-bin\" && runuser -u ${CURRENT_USER} -- git pull && runuser -u ${CURRENT_USER} -- makepkg --noconfirm -si; fi;"
			cmnds+=" echo -e \"\e[33mYay concluído.\e[0m\";"
			;;
		"ft")
			cmnds+=" mkdir -p \"${USER_HOME}/.config/fastfetch/\";"
			cmnds+=" curl -sSLo \"${USER_HOME}/.config/fastfetch/config.jsonc\" https://raw.githubusercontent.com/amonetlol/arch_vm/refs/heads/main/fastfetch_ChrisTitus-config.jsonc;"
			cmnds+=" pacman -S --noconfirm fastfetch ttf-cousine-nerd ttf-hack-nerd;"
			cmnds+=" runuser -u ${CURRENT_USER} -- gsettings set org.gnome.desktop.interface monospace-font-name 'Hack Nerd Font Mono 12';"
			cmnds+=" echo -e \"\e[33mFastfetch concluído.\e[0m\";"
			;;
		"nv")
			cmnds+=" runuser -u ${CURRENT_USER} -- git clone https://github.com/amonetlol/nvim_gruvbox.git ${USER_HOME}/.config/nvim;"
			cmnds+=" yay -S --needed --noconfirm neovim fd ripgrep lua51 lua51-jsregexp luarocks tree-sitter-cli xclip nodejs python-pynvim npm wl-clipboard python-pip lazygit fzf;"
			cmnds+=" rm -rf ${USER_HOME}/.config/nvim/.git;"
			cmnds+=" rm -rf ${USER_HOME}/.config/nvim/.gitignore;"
			cmnds+=" echo -e \"\e[33mNeovim concluído.\e[0m\";"
			;;
		"alias_")
			cmnds+=" runuser -u ${CURRENT_USER} -- curl -sSLo \"${USER_HOME}/.aliases.sh\" https://github.com/amonetlol/arch/raw/refs/heads/main/aliases.sh;"
			cmnds+=" echo 'source ${USER_HOME}/.aliases.sh' >> ${USER_HOME}/.bashrc;"
			cmnds+=" echo -e \"\e[33mAlias concluído.\e[0m\";"
			;;
		"star")
			cmnds+=" pacman -S starship --noconfirm;"
			cmnds+=" runuser -u ${CURRENT_USER} -- wget -O ${USER_HOME}/.config/starship.toml https://raw.githubusercontent.com/amonetlol/terminal-bash/refs/heads/main/starship-arch-os.toml;"
			cmnds+=" echo 'eval \"\$(starship init bash)\"' >> ${USER_HOME}/.bashrc;"
			cmnds+=" echo -e \"\e[33mStarship concluído.\e[0m\";"
			;;
		"debloat")
			cmnds+=" pacman -Rns --noconfirm decibels snapshot malcontent epiphany simple-scan gnome-music gnome-weather gnome-characters gnome-contacts gnome-maps gnome-calendar gnome-software gnome-tour;"
			cmnds+=" echo -e \"\e[33mDebloat Gnome concluído.\e[0m\";"
			;;
		"nerdapp")
			cmnds+=" yay -S --noconfirm btop eza duf tldr fd fzf inxi zoxide;"
			cmnds+=" echo -e \"\e[33mNerd Apps concluído.\e[0m\";"
			;;
		"app")
			cmnds+=" yay -S --noconfirm gnome-tweaks sushi firefox firefox-i18n-pt-br;"
			cmnds+=" echo -e \"\e[33mApps concluído.\e[0m\";"
			;;
		"misc")
			cmnds+=" yay -S --noconfirm usbutils net-tools inetutils ffmpegthumbnailer intel-ucode base-devel power-profiles-daemon zip unzip unrar p7zip lzop 7zip xz;"
			cmnds+=" echo -e \"\e[33mMisc Apps concluído.\e[0m\";"
			;;
		"files")
			cmnds+=" pacman -S --noconfirm dosfstools ntfs-3g cifs-utils exfat-utils gvfs gvfs-afc gvfs-dnssd gvfs-goa gvfs-google gvfs-gphoto2 gvfs-mtp gvfs-nfs gvfs-onedrive gvfs-smb gvfs-wsdd;"
			cmnds+=" echo -e \"\e[33mFile System concluído.\e[0m\";"
			;;
		"font")
			cmnds+=" yay -S --noconfirm ttf-bitstream-vera ttf-dejavu ttf-liberation adobe-source-code-pro-fonts adobe-source-sans-fonts adobe-source-serif-fonts ttf-anonymous-pro ttf-droid ttf-ubuntu-font-family ttf-font-awesome ttf-fira-code ttf-fira-mono ttf-fira-sans cantarell-fonts ttf-hack-nerd ttf-meslo-nerd ttf-cascadia-code-nerd;"
			cmnds+=" runuser -u ${CURRENT_USER} -- git clone https://github.com/amonetlol/fonts ${USER_HOME}/.local/share/fonts;"
			cmnds+=" runuser -u ${CURRENT_USER} -- fc-cache -vf;"
			cmnds+=" runuser -u ${CURRENT_USER} -- gsettings set org.gnome.desktop.interface font-name 'Poppins Regular 12';"
			cmnds+=" runuser -u ${CURRENT_USER} -- gsettings set org.gnome.desktop.interface document-font-name 'Poppins Regular 12';"
			cmnds+=" runuser -u ${CURRENT_USER} -- gsettings set org.gnome.desktop.wm.preferences button-layout ':minimize,maximize,close';"
			cmnds+=" echo -e \"\e[33mFonts concluído.\e[0m\";"
			;;
		"bashrc")
			cmnds+=" echo '# Options' >> ${USER_HOME}/.bashrc;"
			cmnds+=" echo 'shopt -s autocd                  # Auto cd' >> ${USER_HOME}/.bashrc;"
			cmnds+=" echo 'shopt -s cdspell                 # Correct cd typos' >> ${USER_HOME}/.bashrc;"
			cmnds+=" echo 'shopt -s checkwinsize            # Update windows size on command' >> ${USER_HOME}/.bashrc;"
			cmnds+=" echo 'shopt -s histappend              # Append History instead of overwriting file' >> ${USER_HOME}/.bashrc;"
			cmnds+=" echo 'shopt -s cmdhist                 # Bash attempts to save all lines of a multiple-line command in the same history entry' >> ${USER_HOME}/.bashrc;"
			cmnds+=" echo 'shopt -s extglob                 # Extended pattern' >> ${USER_HOME}/.bashrc;"
			cmnds+=" echo 'shopt -s no_empty_cmd_completion # No empty completion' >> ${USER_HOME}/.bashrc;"
			cmnds+=" echo 'shopt -s expand_aliases          # Expand aliases' >> ${USER_HOME}/.bashrc;"
			cmnds+=" echo '' >> ${USER_HOME}/.bashrc;"
			cmnds+=" echo '# History' >> ${USER_HOME}/.bashrc;"
			cmnds+=" echo 'export HISTSIZE=1000                    # History will save N commands' >> ${USER_HOME}/.bashrc;"
			cmnds+=" echo 'export HISTFILESIZE=\${HISTSIZE}         # History will remember N commands' >> ${USER_HOME}/.bashrc;"
			cmnds+=" echo 'export HISTCONTROL=ignoredups:erasedups # Ingore duplicates and spaces (ignoreboth)' >> ${USER_HOME}/.bashrc;"
			cmnds+=" echo 'export HISTTIMEFORMAT=\"%F %T \"          # Add date to history' >> ${USER_HOME}/.bashrc;"
			cmnds+=" echo '' >> ${USER_HOME}/.bashrc;"
			cmnds+=" echo '# History ignore list' >> ${USER_HOME}/.bashrc;"
			cmnds+=" echo 'export HISTIGNORE=\"&:ls:ll:la:cd:exit:clear:history:q:c\"' >> ${USER_HOME}/.bashrc;"
			cmnds+=" echo '' >> ${USER_HOME}/.bashrc;"
			cmnds+=" echo '# Ignore upper and lowercase when TAB completion' >> ${USER_HOME}/.bashrc;"
			cmnds+=" echo 'bind \"set completion-ignore-case on\"' >> ${USER_HOME}/.bashrc;"
			cmnds+=" echo '' >> ${USER_HOME}/.bashrc;"
			cmnds+=" echo '' >> ${USER_HOME}/.bashrc;"
			cmnds+=" echo '# Init zoxide (autojump)' >> ${USER_HOME}/.bashrc;"
			cmnds+=" echo '# use j ou ji (com fzf)' >> ${USER_HOME}/.bashrc;"
			cmnds+=" echo 'command -v zoxide &>/dev/null && eval \"\$(zoxide init bash --cmd j)\"' >> ${USER_HOME}/.bashrc;"
			cmnds+=" echo -e \"\e[33mTuning Bashrc concluído.\e[0m\";"
			;;
		"flat")
			cmnds+=" pacman -S --noconfirm flatpak;"
			cmnds+=" echo -e \"\e[33mFlatpak concluído.\e[0m\";"
			;;
		"extra")
			cmnds+=" yay -S --noconfirm extension-manager vlc totem google-chrome brave-bin;"
			cmnds+=" echo -e \"\e[33mApps Extras concluído.\e[0m\";"
			;;
		"wall")
			cmnds+=" runuser -u ${CURRENT_USER} -- wget -O \"${USER_HOME}/Imagens/0130.jpg\" https://github.com/amonetlol/arch_pi/raw/refs/heads/main/0130.jpg;"
			cmnds+=" runuser -u ${CURRENT_USER} -- gsettings set org.gnome.desktop.background picture-uri \"file://${USER_HOME}/Imagens/0130.jpg\";"
			cmnds+=" runuser -u ${CURRENT_USER} -- gsettings set org.gnome.desktop.background picture-uri-dark \"file://${USER_HOME}/Imagens/0130.jpg\";"
			cmnds+=" echo -e \"\e[33mWallpaper concluído.\e[0m\";"
			;;
		"chao")
			cmnds+=" pacman-key --recv-key 3056513887B78AEB --keyserver keyserver.ubuntu.com;"
			cmnds+=" pacman-key --lsign-key 3056513887B78AEB;"
			cmnds+=" pacman -U --noconfirm 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst';"
			cmnds+=" pacman -U --noconfirm 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst';"
			cmnds+=" echo '[chaotic-aur]' | tee -a /etc/pacman.conf;"
			cmnds+=" echo 'Include = /etc/pacman.d/chaotic-mirrorlist' | tee -a /etc/pacman.conf;"
			cmnds+=" pacman -Syu --noconfirm;"
			cmnds+=" echo -e \"\e[33mChaotic concluído.\e[0m\";"
			;;
		"hide")
			cmnds+=" apps=(\"btop\" \"htop\" \"avahi-discover\" \"picom\" \"nvim\" \"Alacritty\" \"rofi-theme-selector\" \"bvnc\" \"bssh\" \"arandr\" \"vim\" \"ranger\" \"kitty\" \"kvantummanager\" \"meld\" \"qt5ct\" \"qt6ct\" \"qv4l2\" \"qvidcap\" \"nvim\" \"stoken-gui\" \"stoken-gui-small\" \"tint2\" \"yad-settings\" \"org.gnome.Extensions\" \"fish\" \"yad-icon-browser\" \"micro\" \"yelp\");"
			cmnds+=" mkdir -p ${USER_HOME}/.local/share/applications/ && chown ${CURRENT_USER}:${CURRENT_USER} ${USER_HOME}/.local/share/applications/;"
			cmnds+=" for app in \"\${apps[@]}\"; do if [ -f \"/usr/share/applications/\${app}.desktop\" ]; then cp \"/usr/share/applications/\${app}.desktop\" ${USER_HOME}/.local/share/applications/; echo \"NoDisplay=true\" >> ${USER_HOME}/.local/share/applications/\${app}.desktop; echo \"Ocultado: \${app}\"; else echo \"Arquivo \${app}.desktop não encontrado\"; fi; done;"
			cmnds+=" echo -e \"\e[33mHidden Shortcut concluído.\e[0m\";"
			;;
		"rice")
			cmnds+=" if ! command -v git &>/dev/null; then pacman -S --noconfirm git; fi;"
			cmnds+=" mkdir -p \"${USER_HOME}/Downloads/.src\" && chown ${CURRENT_USER}:${CURRENT_USER} \"${USER_HOME}/Downloads/.src\" && chmod 755 \"${USER_HOME}/Downloads/.src\";"
			cmnds+=" runuser -u ${CURRENT_USER} -- git clone https://github.com/yeyushengfan258/Afterglow-Cursors ${USER_HOME}/Downloads/.src/After;"
			cmnds+=" runuser -u ${CURRENT_USER} -- git clone https://github.com/yeyushengfan258/Reversal-gtk-theme ${USER_HOME}/Downloads/.src/Reversal;"
			cmnds+=" runuser -u ${CURRENT_USER} -- git clone https://github.com/yeyushengfan258/McMuse-icon-theme ${USER_HOME}/Downloads/.src/McMuse;"
			cmnds+=" chmod +x ${USER_HOME}/Downloads/.src/After/install.sh;"
			cmnds+=" chmod +x ${USER_HOME}/Downloads/.src/Reversal/install.sh;"
			cmnds+=" chmod +x ${USER_HOME}/Downloads/.src/McMuse/install.sh;"
			cmnds+=" runuser -u ${CURRENT_USER} -- ${USER_HOME}/Downloads/.src/McMuse/install.sh -c -blue;"
			cmnds+=" runuser -u ${CURRENT_USER} -- ${USER_HOME}/Downloads/.src/Reversal/install.sh -l;"
			cmnds+=" runuser -u ${CURRENT_USER} -- ${USER_HOME}/Downloads/.src/After/install.sh;"
			cmnds+=" runuser -u ${CURRENT_USER} -- gtk-update-icon-cache ${USER_HOME}/.local/share/icons/McMuse-blue-dark 2>/dev/null;"
			cmnds+=" gtk-update-icon-cache /usr/share/icons/McMuse-blue-dark 2>/dev/null;"
			cmnds+=" runuser -u ${CURRENT_USER} -- gsettings set org.gnome.desktop.interface cursor-theme 'Afterglow-cursors';"
			cmnds+=" runuser -u ${CURRENT_USER} -- gsettings set org.gnome.desktop.interface icon-theme 'McMuse-blue-dark';"
			cmnds+=" runuser -u ${CURRENT_USER} -- gsettings set org.gnome.desktop.interface gtk-theme 'Reversal';"
			cmnds+=" runuser -u ${CURRENT_USER} -- gsettings set org.gnome.shell.extensions.user-theme name 'Reversal';"
			cmnds+=" echo -e \"\e[33mCursor, Tema e Icones concluído.\e[0m\";"
			;;
	esac
done

(
	pkexec bash -c "$cmnds" | tee -a "${LOG_FILE}"
) |
	zenity --progress \
	--title="Executando as ações" \
	--pulsate \
	--auto-close \
	--auto-kill

# Mensagem de aviso final
zenity --info \
	--title="AVISO" \
	--text="Processos finalizados. Log salvo em ${LOG_FILE}"
echo "Fim da execução: $(date)" >> "${LOG_FILE}"
