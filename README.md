# completions
zsh completions and some nice helper functions.

## how to install

load this into your ZSH plugin manager.

### [zi](https://github.com/z-shell/zi)

Add `zi light hwknsj/completions` to `~/.zshrc`.

### [zinit](https://github.com/zdharma-continuum/zinit)

Add `zinit light hwknsj/completions` to `~/.zshrc`.

### [oh-my-zsh](https://github.com/ohmyzsh/ohmyzsh)

**NOTE**: I rename the cloning directory to `hwknsj-completions` to avoid confusion with other completion plugins you may have (e.g. the excellent [zsh-users/zsh-completions](https://github.com/zsh-users/zsh-completions)).

```sh
git clone https://github.com/hwknsj/completions.git \
  ${ZSH_CUSTOM:-${ZSH:-~/.oh-my-zsh}/custom}/plugins/hwknsj-completions
```

then list it under the `plugins` section:

```sh
# .zshrc
plugins = (
    # ...
    hwknsj-completions
    # ...
)
```

## usage

### vid-compress

the `vid-compress` function is intended to convert screen recordings to demo workflows to colleagues. by default, it **does not include audio and downsizes to 1080p**. 
**Requires `ffmpeg`** which i recommend installing via Homebrew like `brew install ffmpeg-full`. It is important to install `ffmpeg-full` instead of regular `ffmpeg` because it will make use of some additional components in order to get the best compression and adjust the playback speed of the final result.

example:
```sh
vid-compress -c 28 -s 1.5 ./screen-recording-or-whatever.mov [PATH_TO_OUTPUT]
# -c is the quality scale: lower is higher quality–22 is standard for web
# -s is the playback rate: 1.5 → 1.5x playback speed.
```

```sh
Usage: vid-compress [-s speed] [-c crf] [-y height] [-a] input.mp4 output.mp4
Options:
  -s SPEED    Set playback speed (default: 1.25)
  -c CRF      Set compression level (0-51, higher = more compression, default: 28)
  -y HEIGHT   Set output height (default: 1080)
  -a          Keep audio (default: no audio)
  --help  Show this help
```

Note the output path is optional. by default it will output to the same directory with `-compressed.mp4` appended to the name. It performs a lot of compression without significant quality loss.

For example, a `112MB` video is compressed to `3.0MB`.
