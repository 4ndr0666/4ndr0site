## Use pip list --outdated for install updates
python3 -m pip install --exists-action w --break-system-packages-U $(python3 -m pip list outdated 2> /dev/null | grep -v 'Version' | grep -v '\-\-\-\-\-\-' | awk '{printf $1 " " }' && echo)
```

## That fckn nvim command:
:w !sudo tee %
```

## Get all links of a website
lynx -dump http://www.domain.com | awk '/http/{print $2}'
```

## Reinstall pip
python -m ensurepip --upgrade
```

## Reinstall Nvchad
git clone https://github.com/NvChad/NvChad ~/.config/nvim --depth 1 && nvim
```

## Pip completions
python -m pip completion --zsh >> ~/.zprofile
```

## An fzf package list you can delete from
pacman -Qq | fzf --multi --preview 'pacman -Qi {}' | xargs -r -o sudo pacman -Rns
```

## Oneliner to use nvm while using zsh nvm plugin
PROFILE=/dev/null bash -c 'curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash'

## List all non git committed files and gzip them
GITFOLDER="/home/Build/Git_clone/4ndr0site" && mkdir -p "${GITFOLDER}-archives" && git ls-files --others --exclude-standard | tar czf "${GITFOLDER}-archives/uploads-$(date '+%Y%m%d%H%M').tar.gz" -T -
```

## Get status of all git repo
find ~ -name ".git" 2> /dev/null | sed 's/\/.git/\//g' | awk '{print "-------------------------\n\033[1;32mGit Repo:\033[0m " $1; system("git --git-dir="$1".git --work-tree="$1" status")}'
```

## Find most recent modified files in a dir and all subdirs
find /path/to/dir -type f -mtime -7 -print0 | xargs -0 ls -lt | head
```

## Show 10 larget open files
lsof / | awk '{ if($7 > 1048576) print $7/1048576 "MB" " " $9 " " $1 }' | sort -n -u | tail
```

## Find hidden files
find . -name '.*hidden-file*'
```

## Missing files
sudo ls -lai /lost+found/ 
```

## Unhide all hiden files in the dir
find . -maxdepth 1 -type f -name '\.*' | sed -e 's,^\./\.,,' | sort | xargs -iname mv .name name
```

## Rename all files in dir by capitalizing first letter of every word
ls | perl -ne 'chomp; $f=$_; tr/A-Z/a-z/; s/(?<![.'"'"'])\b\w/\u$&/g; print qq{mv "$f" "$_"\n}'
```

## Replace sequences of the same character with a single one
echo heeeeeeelllo | sed 's/\(.\)\1\+/\1/g'
```

## Sort and remove dupes from files. Display only uniq lines from files.
sort file1 file2 | uniq -u
```

## Sort and remove dupes in one files
vi +'%!sort | uniq' +wq file.txt
```

## Print lines of file2 that are missing in file 1
grep -vxFf file1 file2
```

## Find hardlinks to files
find /home -xdev -samefile file1
```

## Outputs list of PATH dirs sorted by line length
echo -e ${PATH//:/\\n} | awk '{print length, $0}' | sort -n | cut -f2- -d' '
```

## Forget all path locations
hash -r
```

## Make a script of last executed cmd
echo "!!" > foo.sh
```

## Reboot when eveything is hanging
$ <alt> + <print screen/sys rq> + <R> - <S> - <E> - <I> - <U> - <B>
```

## Recursively remove all empty directories
find . -type d -empty -delete
## sub-directories ##
find . -depth  -type d  -empty -exec rmdir {} \;
```

## recursively remove all "nodemodules" folders
find . -name "node_modules" -exec rm -rf '{}' +
```

## Delete orphan vim files
find . -type f -iname '*.un~' | while read UNDOFILE ; do FILE=$( echo "$UNDOFILE" | sed -r -e 's/.un~$//' -e 's&/\.([^/]*)&/\1&' ) ; [[ -e "$FILE" ]] || rm "$UNDOFILE" ; done
```

## Combine movies files with mencoder
mencoder cd1.avi cd2.avi -o movie.avi -ovc copy -oac copy
```

## Rotate movie files with mencoder
mencoder video.avi -o rotated-right.avi -oac copy -ovc lavc -vf rotate=1
```

## Print file oweners and perms of a dir tree
find /path/to/dir1 -printf "%U %G %m %p\n" > /tmp/dir1.txt
```
## Get latest version of file across all dirs
find . -name custlist\* | perl -ne '$path = $_; s?.*/??; $name = $_; $map{$name} = $path; ++$c; END { print $map{(sort(keys(%map)))[$c-1]} }'
```

## Copy or create files with specific perms and owners
install -b -m 600 /dev/null NEWFILE
```

## Color prompt for dev test environment
PS1='\[\e[1;31m\][\u@\h \W]\$\[\e[0m\] '
```

## Create and restore backups using cpio
find . -xdev -print0 | cpio -oa0V | gzip > path_to_save.cpio.gz
```

## Get available space on partition as single numeric value
df -P /path/to/dir | awk 'NR==2 {print $4}'
```

## Change label of drive without a gui
sudo mlabel -i /dev/sdd1 ::NewLabel
```

## Create a compressed file for rsync
GZIP='--rsyncable' tar cvzf bobsbackup.tar.gz /home/bob
```

## Proper intel packages
sudo pacman -S mesa lib32-mesa libva libva-intel-driver libva-mesa-driver
libva-vdpau-driver libva-utils lib32-libva lib32-libva-intel-driver
lib32-libva-mesa-driver lib32-libva-vdpau-driver intel-ucode iucode-tool
vulkan-intel lib32-vulkan-intel intel-gmmlib intel-graphics-compiler
intel-media-driver intel-media-sdk intel-opencl-clang libmfx
```
## Bashhub install
curl -OL "https://bashhub.com/setup?version=2.4.0-dev" && bash setup 2.4.0-dev
```

## Mini-brave
brave --disable-extensions --disable-plugins --disable-sync --no-zygote --disable-gpu --user-data-dir=~/brave_minimal_profile/ --no-sandbox --incognito --disable-web-security --disable-features=RendererCodeIntegrity --disable-site-isolation-trials --disable-features=IsolateOrigins --disable-features=site-per-process --disable-features=NetworkService --disable-features=VizDisplayCompositor --disable-features=VizHitTestSurfaceLayer --disable-features=VizHitTestDrawQuad --disable-features=VizHitTestDrawQuadWidget --disable-features=TranslateUI --disable-features=AutofillEnableIgnoreList --disable-features=ReadLater --disable-features=ExportPasswords --disable-features=SyncDisabledWithNoNetwork --disable-features=GlobalMediaControls --disable-features=ExportPasswordsInSettings --disable-features=DownloadRestrictions --disable-features=ImprovedCookieControls --disable-features=BluetootheDeviceChooser --disable-features=AudioServiceOutOfProcess --disable-features=WebOTP --disable-features=WebRtcHideLocalIpsWithMdns --disable-features=WebRtcUseEchoCanceller3 --disable-features=SmoothScrolling --no-crash-upload --disable-renderer-backgrounding --metrics-recording-only
```

## The ffmpeg command Topaz uses
$ ffmpeg "-hide_banner" "-nostdin" "-y" "-nostats" "-i" "Path/to/the/.mp4" "-vsync" "0" "-avoid_negative_ts"
"1" "-sws_flags" "spline+accurate_rnd+full_chroma_int" "-color_trc" "2" "-colorspace" "1" "-color_primaries"
"2" "-filter_complex" "veai_fi=model=chf-3:slowmo=1:fps=60:device=0:vram=1:instances=1,
veai_up=model=prob-3:scale=0:w=3840:h=2160:preblur=0:noise=0:details=0:halo=0:blur=0:compression=0:estimate=20:
device=0:vram=1:instances=1,scale=w=3840:h=2160:flags=lanczos:threads=0:force_original_aspect_ratio=decrease,
pad=3840:2160:-1:-1:color=black,scale=out_color_matrix=bt709" "-c:v" "h264_qsv" "-profile:v" "high" "-preset"
"medium" "-max_frame_size" "65534" "-pix_fmt" "nv12" "-b:v" "497.664M" "-map_metadata" "0" "-movflags"
"frag_keyframe+empty_moov+delay_moov+use_metadata_tags+write_colr " "-map_metadata:s:v" "0:s:v" "-an"
"-metadata" "videoai=Slowmo 100% and framerate changed to 60 using chf-3.
Enhanced using prob-3 auto with recover details at 0, dehalo at 0, reduce noise at 0, sharpen at 0,
revert compression at 0, and anti-alias/deblur at 0. Changed resolution to 3840x2160"
```

## Missing libKF5ConfigCore.so.5 and kcoreaddons
sudo pacman -Syu
sudo pacman -S kconfig kguiaddons karchive kcodecs libplist
```

## Chroot:
#v1
sudo mount -t proc proc /proc
sudo mount -t sysfs sys /sys
sudo mount -t devtmpfs dev /dev
sudo mount -t devpts devpts /dev/pts

#v2
cd /path/to/new/root
mount -t proc /proc proc/
mount -t sysfs /sys sys/
mount --rbind /dev dev/
mount --rbind /run run/
mount --rbind /sys/firmware/efi/efivars sys/firmware/efi/efivars/
```
