# What is this?
A collection of scripts to {build, run, push} a Docker image to Docker Hub.

> So what?

Well, this Docker image contains a Debian userland of AMD64/x86-64 architecture.

> Pfft! Why should I care...

But _this_ Debian in turn contains other Debian userlands...

> Okay so you do a `chroot`, been there done that.

... of differing architectures via `schroot` and qemu user-mode emulation -- working transparently.

> Hmm, tell me more.

This permits easy testing across many architectures. E.g. the `for_each_arch` function which runs a command within each defined architecture's environment in turn:
```
$ for_each_arch file /bin/true
/bin/true: ELF 64-bit LSB shared object, ARM aarch64, version 1 (SYSV), dynamica
/bin/true: ELF 32-bit MSB shared object, MIPS, MIPS32 rel2 version 1 (SYSV), dyn
/bin/true: ELF 32-bit LSB shared object, MIPS, MIPS32 rel2 version 1 (SYSV), dyn
```

> Oh that is neat. But I could also just have spun up 3 full-system QEMUs and installed 3 Linux distros.

True, but:

   0. This takes care of all the setup. With these scripts, moving to other {arch, debian version} is super easy.
   1. It would run slower since you now emulate peripherals and another Linux kernel. BTW, which boards would you pick?
   2. This runs under the same Linux kernel so the different programs under each architectures can interact normally; named pipes, even shared memory and IPC. 

> Cool! This would be great for automated {build, run-time} testing of various Linux software following a {git clone, configure, make, test}-pattern.

Yes! And when running, one could use gdb with `rbreak`, `info variables` and `commands` to dump scalar variables to a log. Diffing the logs between MIPS and MIPSel (with suitable magic) would reveal endianess bugs encountered. This forms the idea for an empirical endianess-bug detector.


# Caveats

There is just one caveat: For now, Docker `--privileged` is required as binfmt must be mounted. There are ways around this though by patching QEMU user mode itself.


# I just want the pre-built image
OK but this is my personal one, https://hub.docker.com/r/mpedoticon/debian_foreign/ .
Disclaimer: Not production ready! I may change this image into a banana if I feel like it.

