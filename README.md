# GTNH-OC-NanoForge

Universal Nano Forge T4 automation for GTNH using OpenComputers and AE2.

## Current stage

The first version is a read-only diagnostic. It detects exposed OC components and their methods, and checks whether an ME fluid reader can see Magmatter. It does not start machines or move items or fluids.

## Run in OpenOS

Use an OpenComputers computer with an installed OpenOS hard disk, screen and keyboard. Connect an Adapter to the AE2 network (with the relevant OC/AE2 integration, if available) and, if possible, another Adapter to the Nano Forge controller.

With an Internet Card installed and enabled:

```sh
wget -f https://raw.githubusercontent.com/Crazerium/GTNH-OC-NanoForge/main/probe.lua /home/probe.lua
lua /home/probe.lua
```

The probe prints a summary to the terminal and saves a full log as `/home/probe.log`. To review or copy it:

```sh
cat /home/probe.log
```

If the Internet Card is not available, copy the contents of `probe.lua` into an OC file using `edit /home/probe.lua`.

Share the output of `probe.log` for the next stage. We need to verify which component exposes ME fluids, what units it returns, and how the Nano Forge can be observed before implementing transfer and start logic.

## Planned behavior

When sufficient Magmatter is available in ME, use the appropriate quantity for the current craft. Otherwise craft normally without Magmatter and display `Missing X Magmatter`. The craft-selection and fluid transfer implementation will be designed after hardware probing.
