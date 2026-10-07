# berserk-login-screen
Berserk login screen with animations and rain

An SDDM theme (Qt 6): the hands slide in and reach toward each other, the Brand of Sacrifice fades in and drips blood, and rain falls over everything with the occasional lightning flash. A matching static [hyprlock](https://github.com/hyprwm/hyprlock) lock screen is included.

## Install

### Login screen (SDDM)

```sh
sudo cp -r . /usr/share/sddm/themes/berserk-rain
sudo rm -rf /usr/share/sddm/themes/berserk-rain/{.git,hyprlock}
printf '[Theme]\nCurrent=berserk-rain\n' | sudo tee /etc/sddm.conf.d/zz-berserk-rain.conf
```

Or choose it under **System Settings → Colors & Themes → Login Screen (SDDM)** on KDE.

Preview without logging out:

```sh
sddm-greeter-qt6 --test-mode --theme .
```

Optional extras in the same config file under `[General]`:

```ini
[General]
InputMethod=   # hide the on-screen keyboard (EndeavourOS enables it)
Numlock=on
```

### Lock screen (hyprlock)

```sh
cp hyprlock/lockscreen.jpg ~/.config/hypr/
cp hyprlock/hyprlock.conf ~/.config/hypr/
```

hyprlock only supports static images, so the lock screen has no rain or animations.

## Customize

In `Main.qml`:

- **Drip frequency / size:** `minPause`, `maxPause` (ms) and `w` on the `BloodDrip` lines
- **Slide-in speed:** the `duration: 2400` values in the intro animation
- **Rain:** `emitRate` (amount) and `magnitude` (speed) on the two `Emitter` blocks
- **Lightning:** delete the `Timer` that calls `lightning.start()` to turn it off

## Files

| File | Purpose |
| --- | --- |
| `Main.qml` | The theme: layers, animations, rain, login form |
| `BloodDrip.qml` | One animated drip point |
| `hand_left.png`, `hand_right.png`, `logo.png` | Wallpaper elements cut out as transparent layers |
| `background.jpg` | Full wallpaper, upscaled 4x with Real-ESRGAN |
| `raindrop.png` | Rain particle sprite |
