;; This "home-environment" file can be passed to 'guix home reconfigure'
;; to reproduce the content of your profile.  This is "symbolic": it only
;; specifies package names.  To reproduce the exact same profile, you also
;; need to capture the channels being used, as returned by "guix describe".
;; See the "Replicating Guix" section in the manual.

(use-modules (gnu home)
             (gnu home services)
             (gnu home services shells)
             (gnu home services shepherd)
             (gnu home services xdg)
             (gnu packages)
             (gnu packages emacs)
             (gnu packages syncthing)
             (gnu services)
             (gnu services shepherd)
             (gnu services xorg)
             (guix transformations)
             (guix gexp))

(home-environment
 (packages
  (map (compose list specification->package+output)
       (list "dwm-w"
             "dmenu"
             "ranger"
             "file"
             "fish"
             "alacritty"
             "fontconfig"
             "font-google-noto"
             ;; tools
             "tmux"
             "htop"
             "fzf"
             "ncdu"
             "ripgrep"
             "exa"
             "bat"
             "zoxide"
             "hyperfine"
             ;; Xorg
             "xorg-server"
             "xf86-input-libinput"
             "xf86-video-fbdev"
             "xinit"
             "xsel"
             "xset"
             "setxkbmap"
             "sx"
             ;; dev
             "direnv"
             "emacs"
             "kakoune"
             "kak-lsp"
             "git"
             "git-lfs"
             "subversion"
             "diffstat"
             "tokei"
             ;; multimedia
             "mpv"
             "yt-dlp"
             "pipewire"
             ;; misc
             "weechat"
             "syncthing"
             "squashfs-tools-ng")))
 (services
   (list
    (simple-service 'my-profile
                    home-shell-profile-service-type
                    (list (plain-file "profile"
                                      (string-join '("case $(tty) in"
                                                     "/dev/tty1) exec startx;;"
                                                     "esac") "\n"))))
    (simple-service 'my-env-vars
                    home-environment-variables-service-type
                    ;; TODO dir_colors solarized
                    '(("PATH" . "$HOME/bin:$PATH")
                      ("EDITOR" . "$HOME/bin/e")
                      ("PAGER" . "$HOME/bin/p")
                      ("VISUAL" . "'emacsclient -c'")
                      ("BAT_THEME" . "ansi")))
    (service home-xdg-user-directories-service-type
             (home-xdg-user-directories-configuration
              (desktop "$HOME/desktop")
              (documents "$HOME/documents")
              (download "$HOME/download")
              (music "$HOME/music")
              (pictures "$HOME/pictures")
              (publicshare "$HOME")
              (templates "$HOME")
              (videos "$HOME/videos")))
    (simple-service 'my-home-services
                    home-shepherd-service-type
                    (list (shepherd-service
                           (provision '(syncthing))
                           (documentation "Run `syncthing' without calling the browser")
                           (start #~(make-forkexec-constructor
                                     (list #$(file-append syncthing "/bin/syncthing")
                                           "-no-browser"
                                           "-logflags=3" ;; prefix with date & time
                                           (string-append "-logfile=" (getenv "HOME") "/.log/syncthing.log"))))
                           (stop #~(make-kill-destructor)))
                          (shepherd-service
                           (provision '(emacs))
                           (documentation "Run `emacs --daemon'")
                           (start #~(make-forkexec-constructor
                                     (list #$(file-append emacs "/bin/emacs")
                                           "--fg-daemon")))
                           (stop #~(make-system-destructor "emacsclient -e '(kill-emacs)'"))
                           (respawn? #f)))))))
