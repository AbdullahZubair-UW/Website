;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!


;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets. It is optional.
(setq user-full-name "Abdullah Zubair"
      user-mail-address "abdzub@hotmail.com")

(add-to-list 'default-frame-alist '(fullscreen . maximized))
(require 'use-package-ensure)
(setq use-package-always-ensure t)

(map! :i "C-x C-s" nil)
;; Doom exposes five (optional) variables for controlling fonts in Doom:
;;
;; - `doom-font' -- the primary font to use
;; - `doom-variable-pitch-font' -- a non-monospace font (where applicable)
;; - `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;; - `doom-unicode-font' -- for unicode glyphs
;; - `doom-serif-font' -- for the `fixed-pitch-serif' face
;;
;; See 'C-h v doom-font' for documentation and more examples of what they
;; accept. For example:
;;
;; (setq doom-font (font-spec :family "Source Code Pro" :size 14 :weight 'semi-light)
;;       doom-variable-pitch-font (font-spec :family "Source Code Pro" :size 14))

(use-package aas
  :hook (LaTeX-mode . aas-activate-for-major-mode)
  :hook (org-mode . aas-activate-for-major-mode))
  ;; disable snippets by redefining them with a nil expansion

(use-package! let-alist)
(use-package! flycheck
  :init (global-flycheck-mode))

;; Kill current buffer automaticlly
(defun hrs/kill-current-buffer ()
  "Kill the current buffer without prompting."
  (interactive)
  (kill-buffer (current-buffer)))

(global-set-key (kbd "C-x k") 'hrs/kill-current-buffer)
 
;;Webmode
(use-package web-mode
  :config
  (setq web-mode-markup-indent-offset 2
        web-mode-css-indent-offset 2
        web-mode-code-indent-offset 2
        web-mode-indent-style 2))

(use-package rainbow-mode
  :hook web-mode)


;; Org Mode
(use-package org)
(use-package org-superstar
  :config
  (setq org-superstar-special-todo-items t)
  (setq org-hide-leading-stars t)
  (add-hook 'org-mode-hook (lambda ()
                             (org-superstar-mode 1)
                             )))

(use-package! graphviz-dot-mode)
(add-to-list 'org-src-lang-modes '("dot" . graphviz-dot))
(setq org-src-fontify-natively t)
(setq org-src-tab-acts-natively t)
(setq org-src-window-setup 'current-window)
(setq org-adapt-indentation nil)
(setq org-confirm-babel-evaluate nil)
(use-package! htmlize)
(setq org-html-postamble nil)
(setq org-latex-pdf-process
      '("pdflatex -shell-escape -interaction nonstopmode -output-directory %o %f"
        "pdflatex -shell-escape -interaction nonstopmode -output-directory %o %f"
        "pdflatex -shell-escape -interaction nonstopmode -output-directory %o %f"))
(add-to-list 'org-latex-packages-alist '("" "minted"))
(setq org-latex-listings 'minted)
;; (add-to-list 'org-latex-logfiles-extensions "tex")

;; (use-package laas

;;   :hook (LaTeX-mode . laas-mode))

;; (setq evil-vsplit-window-right t
;;       evil-split-window-below t)

(setq-default require-final-newline nil)

(use-package! haskell-mode)

(defadvice! prompt-for-buffer (&rest _)
  :after '(evil-window-split evil-window-vsplit)
  (consult-buffer))

(setq proof-script-fly-past-comments t)
(setq proof-follow-mode 'ignore)


(map! :map evil-window-map
      "SPC" #'rotate-layout
      ;; Navigation
      "<left>"     #'evil-window-left
      "<down>"     #'evil-window-down
      "<up>"       #'evil-window-up
      "<right>"    #'evil-window-right
      ;; Swapping windows
      "C-<left>"       #'+evil/window-move-left
      "C-<down>"       #'+evil/window-move-down
      "C-<up>"         #'+evil/window-move-up
      "C-<right>"      #'+evil/window-move-right)

(defun LaTeX-save-and-compile ()
  "Save and compile the tex project using latexmk.
If compilation fails, split the current window and open error-buffer
then jump to the error line, if errors corrected, close the error-buffer
window and close the *TeX help* buffer."
  (interactive)
  (progn
	;; ;; turn off smartparens because LaTeX-electric-left-right-brace
	;; ;; offers more for specific LaTeX mode
	;; ;; Since SP is always triggered later by sth., so put these two lines here
	;; (turn-off-smartparens-mode)
	;; (setq LaTeX-electric-left-right-brace t)
	(let ((TeX-save-query nil)
		  (TeX-process-asynchronous nil)
		  (master-file (TeX-master-file)))
	  (TeX-save-document "")
	  ;; clean all generated files before compile
	  ;; DO NOT do it when up-to-date, remove this line in proper time
	  (TeX-clean t)
	  (TeX-run-TeX "latexmk"
				   (TeX-command-expand "latexmk -pdflatex='pdflatex -file-line-error -synctex=1' -pdf %s")
				   master-file)
	  (if (plist-get TeX-error-report-switches (intern master-file))
		  ;; avoid creating multiple windows to show the *TeX Help* error buffer
		  (if (get-buffer-window (get-buffer "*TeX Help*"))
			  (TeX-next-error)
			(progn
			  (split-window-horizontally -10)
			  (TeX-next-error)))
		;; if no errors, delete *TeX Help* window and buffer
		(if (get-buffer "*TeX Help*")
			(progn
			  (if (get-buffer-window (get-buffer "*TeX Help*"))
				  (delete-windows-on "*TeX Help*"))
			  (kill-buffer "*TeX Help*")))))))
(add-hook 'LaTeX-mode-hook
		  (lambda ()
			(setq LaTeX-item-indent 0)
			(visual-line-mode)
			(flyspell-mode)
      (setq fill-column 125)
			;; make the code look like the pdf file, C-c C-o ... for commands
			;; If it should be activated in all AUCTEX modes, use TeX-mode-hook
			;; instead of LaTeX-mode-hook.
			(TeX-fold-mode 1)
			;; usepackage
			(setq tex-tree-roots t)
			(LaTeX-math-mode)
			;; this line have to be here to make company work
			(company-auctex-init)
			;; disable smartparens-mode completely and use
			;; LaTeX-electric-left-right-brace instea
			(setq LaTeX-electric-left-right-brace t)
			;; the following line will inset braces after _ or ^
			;; unnecessarily most of time
			;; (setq TeX-electric-sub-and-superscript t)
			;; NOTE: C-c C-a to combine C-c C-c and C-c C-v
			;; C-u C-c C-c latexmk (or others like View) so you can change the command line
			;; jump: the following makes viewing the pdf right at the line of the tex file
			(add-to-list 'TeX-command-list
						 '("latexmk" "latexmk -pdflatex='pdflatex -file-line-error -synctex=1' -pdf %s"
						   TeX-run-command nil t :help "Run latexmk") t)
			(setq TeX-command-default "latexmk")
			(push '("%(masterdir)" (lambda nil (file-truename (TeX-master-directory))))
				  TeX-expand-list)
			(push "Zathura"
				  TeX-view-program-list)
			(push '(output-pdf "Zathura") TeX-view-program-selection)
			(TeX-source-correlate-mode)
			(server-force-delete)  ;; WARNING: Kills any existing edit server
			(setq TeX-source-correlate-method 'synctex
				  TeX-source-correlate-start-server t)
			;;
			(bind-keys :map LaTeX-mode-map
					   ;; default C-c C-e rebound and cannot be rebound
					   ("C-c C-x e" . LaTeX-environment)
					   ("C-c C-x s" . LaTeX-section)
					   ("C-c C-x m" . TeX-insert-macro)
					   ("C-x C-s" . LaTeX-save-and-compile)
					   ;; default C-c. not working and replaced by org-time-stamp
					   ("C-c m" . LaTeX-mark-environment)
					   ;; ("<tab>" . TeX-complete-symbol)
					   ("M-<return>" . LaTeX-insert-item)
					   )))
(setq LaTeX-command-section-level t)
;; C-c C-c without prompt, use Clean by default, to clean aux and log files
;; Use "Clean All" to clean files including generated pdf file
;; Or use M-x Tex-clean (Clean) and prefix(Clean All)
;; (setq TeX-command-force "Clean")
(setq TeX-clean-confirm nil)
;; RefTex -- built-in
;; Turn on RefTeX in AUCTeX
(add-hook 'LaTeX-mode-hook 'turn-on-reftex)
;; Activate nice interface between RefTeX and AUCTeX
(setq reftex-plug-into-AUCTeX t)
;; magic-latex-buffer
;; (require 'magic-latex-buffer)
;; (add-hook 'LaTeX-mode-hook 'magic-latex-buffer)
;; latex-preview-pane
;; (add-hook 'LaTeX-mode-hook 'latex-preview-pane-mode)
(setq
 ;; Function for reading \includegraphics files
 LaTeX-includegraphics-read-file 'LaTeX-includegraphics-read-file-relative
 ;; Strip known extensions from image file name
 LaTeX-includegraphics-strip-extension-flag nil)
;; (setq LaTeX-section-hook
;;		  '(LaTeX-section-heading
;;			LaTeX-section-title
;;			LaTeX-section-toc
;;			LaTeX-section-section
;;			LaTeX-section-label))
(eval-after-load "proof-script" '(progn
                                   (define-key proof-mode-map [(control n)] 
                                     'proof-assert-next-command-interactive)
                                   (define-key proof-mode-map [(control b)] 
                                     'proof-undo-last-successful-command)
                                   ))


(defun LaTeX-indent-item ()
  "Provide proper indentation for LaTeX \"itemize\",\"enumerate\", and
\"description\" environments.

  \"\\item\" is indented `LaTeX-indent-level' spaces relative to
  the the beginning of the environment.

  Continuation lines are indented either twice
  `LaTeX-indent-level', or `LaTeX-indent-level-item-continuation'
  if the latter is bound."
  (save-match-data
    (let* ((offset LaTeX-indent-level)
           (contin (or (and (boundp 'LaTeX-indent-level-item-continuation)
                            LaTeX-indent-level-item-continuation)
                       (* 2 LaTeX-indent-level)))
           (re-beg "\\\\begin{")
           (re-end "\\\\end{")
           (re-env "\\(itemize\\|\\enumerate\\|description\\)")
           (indent (save-excursion
                     (when (looking-at (concat re-beg re-env "}"))
                       (end-of-line))
                     (LaTeX-find-matching-begin)
                     (current-column))))
      (cond ((looking-at (concat re-beg re-env "}"))
             (or (save-excursion
                   (beginning-of-line)
                   (ignore-errors
                     (LaTeX-find-matching-begin)
                     (+ (current-column)
                        (if (looking-at (concat re-beg re-env "}"))
                            contin
                          offset))))
                 indent))
             ((looking-at (concat re-end re-env "}"))
              indent)
            ((looking-at "\\\\item")
             (+ offset indent))
            (t
             (+ contin indent))))))

(defcustom LaTeX-indent-level-item-continuation 5
  "*Indentation of continuation lines for items in itemize-like
environments."
  :group 'LaTeX-indentation
  :type 'integer)

(eval-after-load "latex"
  '(setq LaTeX-indent-environment-list
         (nconc '(("itemize" LaTeX-indent-item)
                  ("enumerate" LaTeX-indent-item)
                  ("description" LaTeX-indent-item))
                LaTeX-indent-environment-list)))


;;
;; If you or Emacs can't find your font, use 'M-x describe-font' to look them
;; up, `M-x eval-region' to execute elisp code, and 'M-x doom/reload-font' to
;; refresh your font settings. If Emacs still can't find your font, it likely
;; wasn't installed correctly. Font issues are rarely Doom issues!

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
(setq doom-theme 'doom-one)

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type t)

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/org/")


(after! company
  (setq company-idle-delay 0.1
        company-minimum-prefix-length 2)
  (setq company-show-numbers t)
  (define-key company-active-map (kbd "<tab>") 'nil)
  (add-hook 'evil-normal-state-entry-hook #'company-abort)) ;; make aborting less annoying.

;; Whenever you reconfigure a package, make sure to wrap your config in an
;; `after!' block, otherwise Doom's defaults may override your settings. E.g.
;;
;;   (after! PACKAGE
;;     (setq x y))
;;
;; The exceptions to this rule:
;;
;;   - Setting file/directory variables (like `org-directory')
;;   - Setting variables which explicitly tell you to set them before their
;;     package is loaded (see 'C-h v VARIABLE' to look up their documentation).
;;   - Setting doom variables (which start with 'doom-' or '+').
;;
;; Here are some additional functions/macros that will help you configure Doom.
;;
;; - `load!' for loading external *.el files relative to this one
;; - `use-package!' for configuring packages
;; - `after!' for running code after a package has loaded
;; - `add-load-path!' for adding directories to the `load-path', relative to
;;   this file. Emacs searches the `load-path' when you load packages with
;;   `require' or `use-package'.
;; - `map!' for binding new keys
;;
;; To get information about any of these functions/macros, move the cursor over
;; the highlighted symbol at press 'K' (non-evil users must press 'C-c c k').
;; This will open documentation for it, including demos of how they are used.
;; Alternatively, use `C-h o' to look up a symbol (functions, variables, faces,
;; etc).
;;
;; You can also try 'gd' (or 'C-c c d') to jump to their definition and see how
;; they are implemented.
