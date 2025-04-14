<div align="center">
  <img src="https://i.kym-cdn.com/photos/images/original/001/480/747/941.gif" alt="meme of doom guy sitting at a desk in front of computer followed by angrily throwing the computer into garbage">
  <h2>Tweaking Dotfiles is Eternal</h2>
</div>

_You need to be inside dotfiles dir to perform these commands._

Link each folder to home using stow, for example:

```sh
stow scripts -t ~
```

Or link all using:

```sh
ls -d */ | xargs -I {} stow {} -t ~
```

Unlink using:

```sh
stow -D scripts/ -t ~
```

You can safely ignore warnings about BUG from stow when unlinking.
