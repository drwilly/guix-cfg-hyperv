;; This is an operating system configuration generated
;; by the graphical installer.

(use-modules (gnu)
             (gnu services avahi)
             (gnu services dbus)
             (gnu services sound))
(use-service-modules desktop networking ssh xorg)

(operating-system
 (locale "en_US.utf8")
 (timezone "Europe/Berlin")
 (keyboard-layout (keyboard-layout "de" "neo"))
 (host-name "guix")
 (users (cons* (user-account
                (name "w")
                (comment "W")
                (group "users")
                ;; (home-directory "/home/w")
                (supplementary-groups
                 '("wheel" "netdev" "audio" "video")))
               %base-user-accounts))
 (packages (cons* (specification->package "tmux")
                  (specification->package "ranger")
                  (specification->package "ncdu")
                  (specification->package "htop")
                  (specification->package "ripgrep")
                  (specification->package "fzf")
                  (specification->package "lsof")
                  (specification->package "font-google-noto")
                  (specification->package "nss-certs")
                  %base-packages))
 (services (cons* (service dhcp-client-service-type)
                  (service openssh-service-type
                           (openssh-configuration
                            (permit-root-login 'prohibit-password)
                            (password-authentication? #f)))
                  ;; (service xorg-server-service-type) ;; what does this do exactly?
                  ;; from %desktop-services
                  fontconfig-file-system-service
                  (service avahi-service-type)
                  (elogind-service)
                  (dbus-service)
                  (service ntp-service-type)
                  x11-socket-directory-service
                  (service alsa-service-type)
                  (modify-services %base-services
                                   (mingetty-service-type
                                    config => (if (string=? "tty1" (mingetty-configuration-tty config))
                                                  (mingetty-configuration
                                                   (inherit config)
                                                   (auto-login "w"))
                                                  config))
                                   (guix-service-type
                                    config => (guix-configuration
                                               (inherit config)
                                               (substitute-urls
                                                (cons* "https://substitutes.nonguix.org"
                                                       %default-substitute-urls))
                                               (authorized-keys
                                                (cons* (plain-file "non-guix.pub"
                                                                   "(public-key
                                                                    (ecc (curve Ed25519)
                                                                         (q #C1FD53E5D4CE971933EC50C9F307AE2171A2D3B52C804642A7A35F84F3A4EA98#)))")
                                                       %default-authorized-guix-keys)))))))
 (file-systems (cons* (file-system
                       (mount-point "/")
                       (device (file-system-label "ROOT"))
                       (type "ext4"))
                      %base-file-systems))
 (bootloader (bootloader-configuration
              (bootloader grub-bootloader)
              (targets '("/dev/sda"))
              (keyboard-layout keyboard-layout)))
 (kernel-arguments (cons* "video=hyperv_fb:1600x900"
                          %default-kernel-arguments))
 (initrd-modules (cons* "hv_storvsc"
                        "hv_vmbus"
                        %base-initrd-modules)))
