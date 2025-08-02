#!/bin/bash

# Mensagem de aviso inicial
zenity --info \
	--title="AVISO" \
	--text="Esse menu pressupõe que você instalou o Arch (Gnome) através do archinstall, assim a maior parte das configurações já foi realizada"

# Exibe uma caixa de seleção múltipla com botões ON e OFF
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
  --extra-button="ON" \
  --extra-button="OFF" \
  TRUE vm "Vmware Guest" \
  TRUE aur_helper "Yay" \
  TRUE ft "Fastfetch" \
  TRUE nv "Neovim" \
  TRUE alias_ "Alias" \
  TRUE star "Starship" \
  TRUE debloat "Debloat Gnome" \
  TRUE twe "Tweaks" \
  TRUE nerdapp "Nerd Apps" \
  TRUE app "Apps" \
  TRUE misc "Misc Apps" \
  TRUE ref "Reflector" \
  TRUE files "File System" \
  TRUE font "Fonts" \
  TRUE bashrc "Tuning Bashrc" \
  FALSE flat "Flatpak" \
  TRUE rice "Cursor, Tema e Icones" \
  TRUE wall "Wallpaper" \
  TRUE chao "Chaotic" \
  TRUE hide "Hidden Shortcut")

# Verifica se o usuário clicou em ON, OFF ou cancelou
case $? in
  1)
    if [ "$opcoes" = "ON" ]; then
      opcoes="vm,aur_helper,ft,nv,alias_,star,debloat,twe,nerdapp,app,misc,ref,files,font,bashrc,flat,rice,wall,chao,hide"
    elif [ "$opcoes" = "OFF" ]; then
      opcoes=""
    else
      echo "Cancelado pelo usuário."
      exit 1
    fi
    ;;
esac

# Atualizando o sistema
cmnds="pacman -Syu --noconfirm;"

IFS="," read -ra comandos <<< "$opcoes"

for opcao in "${comandos[@]}"; do
	case "$opcao" in
		"vm")
			cmnds+=" pacman -S --needed --noconfirm open-vm-tools fuse2 gtkmm3;"
			cmnds+=" systemctl enable --now vmtoolsd;"
			;;
		"aur_helper")
			cmnds+=" if ! command -v git &>/dev/null; then pacman -S --noconfirm git; fi;"
			cmnds+=" if [ ! -d \"\$HOME/.src\" ]; then mkdir -p \"\$HOME/.src\" && cd \"\$HOME/.src\" && git clone https://aur.archlinux.org/yay-bin && cd yay-bin && makepkg --noconfirm -si; else cd \"\$HOME/.src\" && git clone https://aur.archlinux.org/yay-bin && cd yay-bin && makepkg --noconfirm -si; fi;"
			;;
		"ft")
			cmnds+=" mkdir -p \"\${HOME}/.config/fastfetch/\";"
			cmnds+=" curl -sSLo \"\${HOME}/.config/fastfetch/config.jsonc\" https://raw.githubusercontent.com/amonetlol/arch_vm/refs/heads/main/fastfetch_ChrisTitus-config.jsonc;"
			cmnds+=" pacman -S ttf-cousine-nerd ttf-hack-nerd --noconfirm;"
			cmnds+=" gsettings set org.gnome.desktop.interface monospace-font-name 'Hack Nerd Font Mono 12';"
			;;
		"nv")
			cmnds+=" git clone https://github.com/amonetlol/nvim_gruvbox.git ~/.config/nvim;"
			cmnds+=" yay -S --needed --noconfirm fd ripgrep lua51 luarocks tree-sitter-cli xclip nodejs python-pynvim npm wl-clipboard python-pip lazygit fzf;"
			cmnds+=" rm -rf ~/.config/nvim/.git;"
			cmnds+=" rm -rf ~/.config/nvim/.gitignore;"
			;;
		"alias_")
			cmnds+=" curl -sSLo \"\${HOME}/.aliases.sh\" https://github.com/amonetlol/arch/raw/refs/heads/main/aliases.sh;"
			cmnds+=" echo 'source ~/.aliases.sh' >> ~/.bashrc;"
			;;
		"star")
			cmnds+=" pacman -S starship --noconfirm;"
			cmnds+=" wget -O ~/.config/starship.toml https://raw.githubusercontent.com/amonetlol/terminal-bash/refs/heads/main/starship-arch-os.toml;"
			cmnds+=" echo 'eval \"\$(starship init bash)\"' >> ~/.bashrc;"
			;;
		"debloat")
			cmnds+=" pacman -Rns --noconfirm decibels snapshot malcontent epiphany simple-scan gnome-music gnome-weather gnome-characters gnome-contacts gnome-maps gnome-calendar gnome-software gnome-tour;"
			;;
		"twe")
			cmnds+=" sed -i 's/^\s*#\s*DefaultTimeoutStopSec=.*/DefaultTimeoutStopSec=10s/' /etc/systemd/system.conf;"
			cmnds+=" echo 'MAKEFLAGS=\"-j\$(nproc)\"' | tee -a /etc/makepkg.conf;"
			cmnds+=" systemctl enable fstrim.timer;"
			;;
		"nerdapp")
			cmnds+=" yay -S --noconfirm btop eza duf tldr fd fzf inxi zoxide;"
			;;
		"app")
			cmnds+=" yay -S --noconfirm firefox firefox-i18n-pt-br extension-manager vlc totem gnome-tweaks sushi google-chrome brave-bin;"
			;;
		"misc")
			cmnds+=" yay -S --noconfirm usbutils net-tools inetutils ffmpegthumbnailer intel-ucode base-devel power-profiles-daemon zip unzip unrar p7zip lzop 7zip xz;"
			;;
		"ref")
			cmnds+=" pacman -S --noconfirm reflector rsync;"
			cmnds+=" reflector --country Brazil --latest 10 --sort rate --save /etc/pacman.d/mirrorlist;"
			;;
		"files")
			cmnds+=" pacman -S --noconfirm dosfstools ntfs-3g cifs-utils exfat-utils gvfs gvfs-afc gvfs-dnssd gvfs-goa gvfs-google gvfs-gphoto2 gvfs-mtp gvfs-nfs gvfs-onedrive gvfs-smb gvfs-wsdd;"
			;;
		"font")
			cmnds+=" yay -S --noconfirm ttf-bitstream-vera ttf-dejavu ttf-liberation adobe-source-code-pro-fonts adobe-source-sans-fonts adobe-source-serif-fonts ttf-anonymous-pro ttf-droid ttf-ubuntu-font-family ttf-roboto ttf-roboto-mono ttf-font-awesome ttf-fira-code ttf-fira-mono ttf-fira-sans cantarell-fonts ttf-hack-nerd ttf-meslo-nerd ttf-cascadia-code-nerd ttf-poppins ttf-intel-one-mono;"
			cmnds+=" gsettings set org.gnome.desktop.interface font-name 'Poppins Regular 12';"
			cmnds+=" gsettings set org.gnome.desktop.interface document-font-name 'Poppins Regular 12';"
			;;
		"bashrc")
			cmnds+=" echo '# Options' >> ~/.bashrc;"
			cmnds+=" echo 'shopt -s autocd                  # Auto cd' >> ~/.bashrc;"
			cmnds+=" echo 'shopt -s cdspell                 # Correct cd typos' >> ~/.bashrc;"
			cmnds+=" echo 'shopt -s checkwinsize            # Update windows size on command' >> ~/.bashrc;"
			cmnds+=" echo 'shopt -s histappend              # Append History instead of overwriting file' >> ~/.bashrc;"
			cmnds+=" echo 'shopt -s cmdhist                 # Bash attempts to save all lines of a multiple-line command in the same history entry' >> ~/.bashrc;"
			cmnds+=" echo 'shopt -s extglob                 # Extended pattern' >> ~/.bashrc;"
			cmnds+=" echo 'shopt -s no_empty_cmd_completion # No empty completion' >> ~/.bashrc;"
			cmnds+=" echo 'shopt -s expand_aliases          # Expand aliases' >> ~/.bashrc;"
			cmnds+=" echo '' >> ~/.bashrc;"
			cmnds+=" echo '# History' >> ~/.bashrc;"
			cmnds+=" echo 'export HISTSIZE=1000                    # History will save N commands' >> ~/.bashrc;"
			cmnds+=" echo 'export HISTFILESIZE=\${HISTSIZE}         # History will remember N commands' >> ~/.bashrc;"
			cmnds+=" echo 'export HISTCONTROL=ignoredups:erasedups # Ingore duplicates and spaces (ignoreboth)' >> ~/.bashrc;"
			cmnds+=" echo 'export HISTTIMEFORMAT=\"%F %T \"          # Add date to history' >> ~/.bashrc;"
			cmnds+=" echo '' >> ~/.bashrc;"
			cmnds+=" echo '# History ignore list' >> ~/.bashrc;"
			cmnds+=" echo 'export HISTIGNORE=\"&:ls:ll:la:cd:exit:clear:history:q:c\"' >> ~/.bashrc;"
			cmnds+=" echo '' >> ~/.bashrc;"
			cmnds+=" echo '# Ignore upper and lowercase when TAB completion' >> ~/.bashrc;"
			cmnds+=" echo 'bind \"set completion-ignore-case on\"' >> ~/.bashrc;"
			cmnds+=" echo '' >> ~/.bashrc;"
			cmnds+=" echo '' >> ~/.bashrc;"
			cmnds+=" echo '# Init zoxide (autojump)' >> ~/.bashrc;"
			cmnds+=" echo '# use j ou ji (com fzf)' >> ~/.bashrc;"
			cmnds+=" echo 'command -v zoxide &>/dev/null && eval \"\$(zoxide init bash --cmd j)\"' >> ~/.bashrc;"
			;;
		"flat")
			cmnds+=" pacman -S --noconfirm flatpak;"
			;;
		"rice")
			cmnds+=" if ! command -v git &>/dev/null; then pacman -S --noconfirm git; fi;"
			cmnds+=" if [ ! -d \"\$HOME/.src\" ]; then mkdir -p \"\$HOME/.src\"; fi;"
			cmnds+=" git clone https://github.com/yeyushengfan258/Afterglow-Cursors \$HOME/.src/After;"
			cmnds+=" git clone https://github.com/yeyushengfan258/Reversal-gtk-theme \$HOME/.src/Reversal;"
			cmnds+=" git clone https://github.com/yeyushengfan258/McMuse-icon-theme \$HOME/.src/McMuse;"
			cmnds+=" chmod +x \$HOME/.src/After/install.sh;"
			cmnds+=" chmod +x \$HOME/.src/Reversal/install.sh;"
			cmnds+=" chmod +x \$HOME/.src/McMuse/install.sh;"
			cmnds+=" \$HOME/.src/McMuse/install.sh -c -blue;"
			cmnds+=" \$HOME/.src/Reversal/install.sh -l;"
			cmnds+=" \$HOME/.src/After/install.sh;"
			cmnds+=" gtk-update-icon-cache ~/.local/share/icons/McMuse-blue-dark 2>/dev/null;"
			cmnds+=" gtk-update-icon-cache /usr/share/icons/McMuse-blue-dark 2>/dev/null;"
			cmnds+=" gsettings set org.gnome.desktop.interface cursor-theme 'Afterglow-cursors';"
			cmnds+=" gsettings set org.gnome.desktop.interface icon-theme 'McMuse-blue-dark';"
			cmnds+=" gsettings set org.gnome.desktop.interface gtk-theme 'Reversal';"
			cmnds+=" gsettings set org.gnome.shell.extensions.user-theme name 'Reversal';"
			;;
		"wall")
			cmnds+=" WALLPAPER_URL=\"https://raw.githubusercontent.com/amonetlol/rice/main/0130.jpg\";"
			cmnds+=" DEST_DIR=\"\$HOME/Imagens/Wallpapers\";"
			cmnds+=" DEST_FILE=\"\$DEST_DIR/0130.jpg\";"
			cmnds+=" if [ ! -d \"\$DEST_DIR\" ]; then mkdir -p \"\$DEST_DIR\" || { echo \"Erro ao criar a pasta \$DEST_DIR\"; exit 1; }; echo \"Pasta \$DEST_DIR criada.\"; else echo \"Pasta \$DEST_DIR já existe.\"; fi;"
			cmnds+=" if ! command -v wget &>/dev/null; then pacman -S --noconfirm wget; fi;"
			cmnds+=" if wget -O \"\$DEST_FILE\" \"\$WALLPAPER_URL\"; then echo \"Download concluído: \$DEST_FILE\"; else echo \"Erro ao baixar o wallpaper.\"; exit 1; fi;"
			cmnds+=" gsettings set org.gnome.desktop.background picture-uri \"file://\$DEST_FILE\";"
			cmnds+=" gsettings set org.gnome.desktop.background picture-uri-dark \"file://\$DEST_FILE\" 2>/dev/null;"
			;;
		"chao")
			cmnds+=" pacman-key --recv-key 3056513887B78AEB --keyserver keyserver.ubuntu.com;"
			cmnds+=" pacman-key --lsign-key 3056513887B78AEB;"
			cmnds+=" pacman -U --noconfirm 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst';"
			cmnds+=" pacman -U --noconfirm 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst';"
			cmnds+=" echo '[chaotic-aur]' | tee -a /etc/pacman.conf;"
			cmnds+=" echo 'Include = /etc/pacman.d/chaotic-mirrorlist' | tee -a /etc/pacman.conf;"
			cmnds+=" pacman -Syu --noconfirm;"
			;;
		"hide")
			cmnds+=" apps=(\"btop\" \"htop\" \"avahi-discover\" \"picom\" \"nvim\" \"Alacritty\" \"rofi-theme-selector\" \"bvnc\" \"bssh\" \"arandr\" \"vim\" \"ranger\" \"kitty\" \"kvantummanager\" \"meld\" \"qt5ct\" \"qt6ct\" \"qv4l2\" \"qvidcap\" \"nvim\" \"stoken-gui\" \"stoken-gui-small\" \"tint2\" \"yad-settings\" \"org.gnome.Extensions\" \"fish\" \"yad-icon-browser\" \"micro\" \"yelp\");"
			cmnds+=" mkdir -p ~/.local/share/applications/;"
			cmnds+=" for app in \"\${apps[@]}\"; do if [ -f \"/usr/share/applications/\$app.desktop\" ]; then cp \"/usr/share/applications/\$app.desktop\" ~/.local/share/applications/; echo \"NoDisplay=true\" >> ~/.local/share/applications/\$app.desktop; echo \"Ocultado: \$app\"; else echo \"Arquivo \$app.desktop não encontrado\"; fi; done;"
			;;
	esac
done

(
	pkexec bash -c "$cmnds"
) |
	zenity --progress \
	--title="Executando as ações" \
	--pulsate \
	--auto-close \
	--auto-kill

# Mensagem de aviso final
zenity --info \
	--title="AVISO" \
	--text="Processos finalizados"
