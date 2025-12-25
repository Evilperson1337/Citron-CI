# 🚨 NIGHTLY BUILD - Citron CI Automated Build

## ⚠️ IMPORTANT DISCLAIMER

**THESE ARE UNOFFICIAL NIGHTLY BUILDS**

- **Automated**: These are automated builds generated from the latest source code
- **Unofficial**: These builds are **NOT** official releases nor are they associated with, endorsed by, or affiliated with the Citron development team
- **Use at Your Own Risk**: Nightly builds may contain bugs, crashes, or incomplete features

[**Official Citron Builds**](https://git.citron-emu.org/Citron/Emulator/releases)

---

## 📋 Build Information

```
Citron Nightly Build ({commit_hash})
```

**Citron Upstream Commit:** [`{commit_hash}`](https://git.citron-emu.org/Citron/Emulator/commit/{full_hash})

**Build Type:** Nightly (Automated CI Build)  
**Version:** {version}  
**Branch:** {branch_name}  
**Build Date:** {date}  
**Build Time (UTC):** {time}

---

## 🎯 What Are Nightly Builds?

Nightly builds are **automated compilation** of the latest source code from the Citron Emulator project. They are generated daily to provide early access to:

- ✨ **Latest Features**: Brand new features that may not be stable
- 🐛 **Recent Fixes**: Bug fixes that haven't been tested thoroughly
- 🔧 **Experimental Changes**: Code that is still in development

**⚠️ WARNING**: These builds are **highly experimental** and may:
- Crash unexpectedly
- Have broken features
- Corrupt save data
- Perform poorly
- Be incompatible with previous versions

**💡 Recommendation**: Only use nightly builds if you:
- Want to test the latest features
- Are comfortable with potential crashes and bugs
- Know how to report issues effectively
- Have backups of your save data

---

## 📦 Available Builds

### 🐧 Linux Builds

**amd64 (Generic)**
- **Type:** Standard
- **Platform:** Linux
- **Architecture:** amd64
- **Description:** For older CPUs (amd64 baseline)
- **Format:** AppImage
- **Compatibility:** Most Linux distributions on 64-bit Intel/AMD processors
- [**Download Here**]({asset_linux_amd64})

**amd64-v3**
- **Type:** Optimized
- **Platform:** Linux (including Steam Deck)
- **Architecture:** amd64-v3
- **Description:** Optimized for modern CPUs & Steam Deck
- **Format:** AppImage
- **Compatibility:** Modern Intel/AMD processors (Haswell 2013+ and newer), Steam Deck
- [**Download Here**]({asset_linux_amd64_v3})

**arm64**
- **Type:** Standard
- **Platform:** Linux
- **Architecture:** arm64 (aarch64)
- **Description:** arm64 builds for ARM-based systems
- **Format:** AppImage
- **Compatibility:** arm64 devices (Raspberry Pi 4/5, ARM-based SBCs, newer ARM laptops)
- [**Download Here**]({asset_linux_arm64})

### 🪟 Windows Builds

**amd64**
- **Type:** Standard
- **Platform:** Windows
- **Architecture:** amd64
- **Description:** Standard Windows builds
- **Format:** zip archive
- **Compatibility:** Windows 10 (64-bit) and Windows 11
- [**Download Here**]({asset_windows_amd64})

### 🍎 macOS Builds

**arm64**
- **Type:** Standard
- **Platform:** macOS
- **Architecture:** arm64 (Apple Silicon)
- **Description:** Apple Silicon builds
- **Format:** dmg
- **Compatibility:** Macs with Apple Silicon (M1, M2, M3, M4 series)
- [**Download Here**]({asset_macos_arm64})

### 🤖 Android Builds

**arm64-v8a**
- **Type:** Standard
- **Platform:** Android
- **Architecture:** arm64
- **Description:** Modern Android devices
- **Format:** apk
- **Compatibility:** Android 10.0+ on arm64 devices
- [**Download Here**]({asset_android_arm64})

---

## 🐛 Reporting Issues

**Before reporting issues with nightly builds:**

1. **Check if it's already fixed**: Compare with the latest official release
2. **Verify it's reproducible**: Test multiple times and different scenarios
3. **Provide details**: Include commit hash, build date, platform, and steps to reproduce
4. **Check upstream**: Report issues to the official Citron project, not the CI build maintainer

**Official Issue Tracker:** [Citron Git Issues](https://git.citron-emu.org/Citron/Emulator/issues)

---

## 🔗 Resources & Links

- **Official Citron Website:** [citron-emu.org](https://citron-emu.org)
- **Latest Commits:** [Citron Emulator Git](https://git.citron-emu.org/Citron/Emulator/commits/branch/main)
- **Documentation:** [Citron Emulator Documentation](https://citron-emu.org/docs)
- **Community Support:** [Discord Server](https://discord.gg/citron-emu)
- **Source Code:** [Citron Git Repository](https://git.citron-emu.org/Citron/Emulator)

---

## 📝 Build System Information

These builds are generated automatically by the **Citron-CI** build system:
- **Build Scripts:** [GitHub Repository](https://github.com/Citron-CI/Citron-CI)
- **Build Frequency:** Nightly (automated)
- **CI System:** GitHub Actions
- **Build Platform:** Multiple platforms for maximum compatibility

---

## ⚖️ License & Legal

- **Citron Emulator License:** See official Citron project for licensing information
- **Build System:** These automated builds are provided as-is for testing purposes
- **No Warranty:** Absolutely no warranty is provided with these builds

---

**🔔 Remember**: These are **automated nightly builds** intended for **testing and development purposes only**. For stable, supported builds, please use the **official releases** from the Citron development team.

**Last Updated:** {date}