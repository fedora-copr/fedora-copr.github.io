---
title: Fedora RISC-V 64-bit now available in Copr
author: Copr Team
layout: post
---

We are happy to announce that Fedora RISC-V 64-bit (riscv64) build targets are now available in Copr! The following chroots have been added to mock-core-configs and enabled:

- `fedora-42-riscv64`
- `fedora-43-riscv64`

## Important notes

We currently **do not have native RISC-V hardware** in our infrastructure. All riscv64 builds are performed using QEMU emulation on x86_64 machines. Because of this:

- **Expect longer build times** compared to native architectures
- **Not everything may work perfectly** — some packages might fail to build or behave unexpectedly due to emulation limitations

If you encounter any issues, please let us know!
